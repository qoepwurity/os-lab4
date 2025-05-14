#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "debug.h"
#include "pstat.h"          // bookkeeping struct remains separate

struct {
    struct spinlock lock;
    struct proc proc[NPROC];
} ptable;

// Separate global pstat table to avoid bloating ptable cache‑line footprint
static struct pstat pstat;

static struct proc* initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void* chan);

static int mlfq_ts[4] = { -1, 32, 16, 8 };   // TIME SLICE
static int mlfq_wait_ts[3] = { 500, 320, 160 };   // TIME SLICE

void
pinit(void)
{
    initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
    return mycpu() - cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
    mycpu(void)
{
    int apicid, i;

    if (readeflags() & FL_IF) {
        panic("mycpu called with interrupts enabled\n");
    }

    apicid = lapicid();
    // APIC IDs are not guaranteed to be contiguous. Maybe we should have
    // a reverse map, or reserve a register to store &cpus[i].
    for (i = 0; i < ncpu; ++i) {
        if (cpus[i].apicid == apicid) {
            return &cpus[i];
        }
    }
    panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
    myproc(void) {
    struct cpu* c;
    struct proc* p;
    pushcli();
    c = mycpu();
    p = c->proc;
    popcli();
    return p;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
    struct proc* p;
    char* sp;

    acquire(&ptable.lock);

    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
        if (p->state == UNUSED) {
            goto found;
        }

    release(&ptable.lock);
    return 0;

found:
    p->state = EMBRYO;
    p->pid = nextpid++;

    // pstat 초기화
    int idx = p - ptable.proc;
    pstat.inuse[idx] = 1;
    pstat.pid[idx] = p->pid;
    pstat.priority[idx] = 3;
    pstat.state[idx] = p->state;
    int i = 0;
    for (i = 0; i < 4; i++) {
        pstat.ticks[idx][i] = 0;
        pstat.wait_ticks[idx][i] = 0;
    }

    release(&ptable.lock);


    // Allocate kernel stack.
    if ((p->kstack = kalloc()) == 0) {
        p->state = UNUSED;
        return 0;
    }
    sp = p->kstack + KSTACKSIZE;

    // Leave room for trap frame.
    sp -= sizeof * p->tf;
    p->tf = (struct trapframe*)sp;

    // Set up new context to start executing at forkret,
    // which returns to trapret.
    sp -= 4;
    *(uint*)sp = (uint)trapret;

    sp -= sizeof * p->context;
    p->context = (struct context*)sp;
    memset(p->context, 0, sizeof * p->context);
    p->context->eip = (uint)forkret;

    return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
    struct proc* p;
    extern char _binary_initcode_start[], _binary_initcode_size[];

    p = allocproc();

    initproc = p;
    if ((p->pgdir = setupkvm()) == 0) {
        panic("userinit: out of memory?");
    }
    inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
    p->sz = PGSIZE;
    memset(p->tf, 0, sizeof(*p->tf));
    p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
    p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
    p->tf->es = p->tf->ds;
    p->tf->ss = p->tf->ds;
    p->tf->eflags = FL_IF;
    p->tf->esp = PGSIZE;
    p->tf->eip = 0;  // beginning of initcode.S

    safestrcpy(p->name, "initcode", sizeof(p->name));
    p->cwd = namei("/");

    // this assignment to p->state lets other cores
    // run this process. the acquire forces the above
    // writes to be visible, and the lock is also needed
    // because the assignment might not be atomic.
    acquire(&ptable.lock);

    p->state = RUNNABLE;

    release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
    uint sz;
    struct proc* curproc = myproc();

    sz = curproc->sz;
    if (n > 0) {
        if ((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
            return -1;
    }
    else if (n < 0) {
        if ((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
            return -1;
    }
    curproc->sz = sz;
    switchuvm(curproc);
    return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
    int i, pid;
    struct proc* np;
    struct proc* curproc = myproc();

    // Allocate process.
    if ((np = allocproc()) == 0) {
        return -1;
    }

    // Copy process state from proc.
    if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0) {
        kfree(np->kstack);
        np->kstack = 0;
        np->state = UNUSED;
        return -1;
    }
    np->sz = curproc->sz;
    np->parent = curproc;
    *np->tf = *curproc->tf;

    // Clear %eax so that fork returns 0 in the child.
    np->tf->eax = 0;

    for (i = 0; i < NOFILE; i++)
        if (curproc->ofile[i])
            np->ofile[i] = filedup(curproc->ofile[i]);
    np->cwd = idup(curproc->cwd);

    safestrcpy(np->name, curproc->name, sizeof(curproc->name));

    pid = np->pid;

    acquire(&ptable.lock);

    np->state = RUNNABLE;

    release(&ptable.lock);

    return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
    struct proc* curproc = myproc();
    struct proc* p;
    int fd;

    if (curproc == initproc)
        panic("init exiting");

    // Close all open files.
    for (fd = 0; fd < NOFILE; fd++) {
        if (curproc->ofile[fd]) {
            fileclose(curproc->ofile[fd]);
            curproc->ofile[fd] = 0;
        }
    }

    begin_op();
    iput(curproc->cwd);
    end_op();
    curproc->cwd = 0;

    acquire(&ptable.lock);

    // Parent might be sleeping in wait().
    wakeup1(curproc->parent);

    // Pass abandoned children to init.
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p->parent == curproc) {
            p->parent = initproc;
            if (p->state == ZOMBIE)
                wakeup1(initproc);
        }
    }

    // Jump into the scheduler, never to return.
    curproc->state = ZOMBIE;
    sched();
    panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
    struct proc* p;
    int havekids, pid;
    struct proc* curproc = myproc();

    acquire(&ptable.lock);
    for (;;) {
        // Scan through table looking for exited children.
        havekids = 0;
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
            if (p->parent != curproc)
                continue;
            havekids = 1;
            if (p->state == ZOMBIE) {
                // Found one.
                pid = p->pid;
                kfree(p->kstack);
                p->kstack = 0;
                freevm(p->pgdir);
                p->pid = 0;
                p->parent = 0;
                p->name[0] = 0;
                p->killed = 0;
                p->state = UNUSED;
                release(&ptable.lock);
                return pid;
            }
        }

        // No point waiting if we don't have any children.
        if (!havekids || curproc->killed) {
            release(&ptable.lock);
            return -1;
        }

        // Wait for children to exit.  (See wakeup1 call in proc_exit.)
        sleep(curproc, &ptable.lock);  //DOC: wait-sleep
    }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
    struct proc* p;
    struct proc* p_candidate;
    
    struct cpu* c = mycpu();
    c->proc = 0;

    int last_idx = 0;
    int last_priority = 0;

    for (;;) {
        // Enable interrupts on this processor.
        sti();

        acquire(&ptable.lock);

        int flag = 0;   // 현재 저장되어 있는 priority + 1 값으로도 사용

        for (int i = 1; i < NPROC + 1; i++) {
            int idx = (last_idx + i) % NPROC;
            if (ptable.proc[idx].state != RUNNABLE)
                continue;

            // 정책값이 0이면 RR
            if (c->sched_policy == 0) {
                p = &ptable.proc[idx];
                flag = 1;
                break;
            }

            int priority = pstat.priority[idx];

            // 장기 대기 시 승격 (정책값이 3이면 비활성화)
            if (c->sched_policy != 3 && priority != 3) {
                if (pstat.wait_ticks[idx][priority] % mlfq_wait_ts[priority] == 0 && pstat.wait_ticks[idx][priority] != 0) {
                    if (priority == 0) {    // 우선순위가 0일때 1을 FIFO를 위한 틱카운트로 썻으므로 초기화
                        pstat.wait_ticks[idx][1] = 0;
                    }
                    pstat.wait_ticks[idx][priority] = 0;
                    pstat.priority[idx]++;
                    priority++;
                    //cprintf("PRIORITY UP \n"); // FOR DEBUG
                }
            }

            pstat.wait_ticks[idx][priority]++;

            if (!flag) {                        // 처음 RUNNABLE을 마주하면 일단 할당
                p_candidate = &ptable.proc[idx];
                flag = priority + 1;            // 0이면 1이 저장
            }
            else if (priority >= flag) {        // 우선 순위가 더 높으면 할당
                p_candidate = &ptable.proc[idx];
                flag = priority + 1;
            }
            else if (flag - 1 == priority && priority == 0) { // 근데 후보 우선순위가 0이면 실행시간 기반 (짬순)으로 후보를 결정
                int candidx = p_candidate - ptable.proc;

                if (pstat.ticks[idx][0] + pstat.wait_ticks[idx][0] > pstat.wait_ticks[candidx][0] + pstat.wait_ticks[candidx][0])
                    p_candidate = &ptable.proc[idx];
            }
        }
        if (flag && c->sched_policy != 0) {
            flag--;                             // flag를 후보의 PRIORITY 값으로 조정
            if (flag >= last_priority)
                p = p_candidate;
            else if (p->state != RUNNABLE)
                p = p_candidate;

            flag = 1;
        }
        else if (p->state == RUNNABLE) {
            flag = 1;
        }

        // 위 과정에서 RUNNABLE이 하나라도 존재하면 컨텍스트 스위칭
        if (flag) {
            last_idx = p - ptable.proc;
            last_priority = pstat.priority[last_idx];

            pstat.ticks[last_idx][last_priority]++;

            // 우선순위가 0이면 우선순위 1인 wait_ticks에 실행시간 + 대기시간을 저장
            if (last_priority == 0) {
                //pstat.wait_ticks[last_idx][1] += pstat.wait_ticks[last_idx][0] + 1;
                //pstat.wait_ticks[last_idx][last_priority] = 0;
            }
            else {
                //pstat.wait_ticks[last_idx][last_priority] = 0;

                // 할당된 타임 슬라이스 전부 소모시 강등
                if (pstat.ticks[last_idx][last_priority] % mlfq_ts[last_priority] == 0) {
                    //pstat.ticks[last_idx][last_priority] = 0;
                    pstat.priority[last_idx]--;
                    last_priority--;
                    //cprintf("PRIORITY DOWN \n"); // FOR DEBUG
                }
            }

            c->proc = p;
            switchuvm(p);
            p->state = RUNNING;

            swtch(&(c->scheduler), p->context);
            switchkvm();

            c->proc = 0;
        }


        release(&ptable.lock);

    }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    int intena;
    struct proc* p = myproc();

    if (!holding(&ptable.lock))
        panic("sched ptable.lock");
    if (mycpu()->ncli != 1)
        panic("sched locks");
    if (p->state == RUNNING)
        panic("sched running");
    if (readeflags() & FL_IF)
        panic("sched interruptible");
    intena = mycpu()->intena;
    swtch(&p->context, mycpu()->scheduler);
    mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
    acquire(&ptable.lock);  //DOC: yieldlock
    myproc()->state = RUNNABLE;
    sched();
    release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
    static int first = 1;
    // Still holding ptable.lock from scheduler.
    release(&ptable.lock);

    if (first) {
        // Some initialization functions must be run in the context
        // of a regular process (e.g., they call sleep), and thus cannot
        // be run from main().
        first = 0;
        iinit(ROOTDEV);
        initlog(ROOTDEV);
    }

    // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void* chan, struct spinlock* lk)
{
    struct proc* p = myproc();

    if (p == 0)
        panic("sleep");

    if (lk == 0)
        panic("sleep without lk");

    // Must acquire ptable.lock in order to
    // change p->state and then call sched.
    // Once we hold ptable.lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup runs with ptable.lock locked),
    // so it's okay to release lk.
    if (lk != &ptable.lock) {  //DOC: sleeplock0
        acquire(&ptable.lock);  //DOC: sleeplock1
        release(lk);
    }
    // Go to sleep.
    p->chan = chan;
    p->state = SLEEPING;

    if (mycpu()->sched_policy >= 2) {
        // 정책값이 2이면 실행틱을 0으로
        int idx = p - ptable.proc;
        int priority = pstat.priority[idx];

        // 실행시간 0으로
        pstat.ticks[idx][priority] = 0;
    }

    sched();

    // Tidy up.
    p->chan = 0;

    // Reacquire original lock.
    if (lk != &ptable.lock) {  //DOC: sleeplock2
        release(&ptable.lock);
        acquire(lk);
    }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void* chan)
{
    struct proc* p;

    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
        if (p->state == SLEEPING && p->chan == chan)
            p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void* chan)
{
    acquire(&ptable.lock);
    wakeup1(chan);
    release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
    struct proc* p;

    acquire(&ptable.lock);
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p->pid == pid) {
            p->killed = 1;
            // Wake process from sleep if necessary.
            if (p->state == SLEEPING)
                p->state = RUNNABLE;
            release(&ptable.lock);
            return 0;
        }
    }
    release(&ptable.lock);
    return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    static char* states[] = {
    [UNUSED] "unused",
    [EMBRYO]    "embryo",
    [SLEEPING]  "sleep ",
    [RUNNABLE]  "runble",
    [RUNNING]   "run   ",
    [ZOMBIE]    "zombie"
    };
    int i;
    struct proc* p;
    char* state;
    uint pc[10];

    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
            state = states[p->state];
        else
            state = "???";
        cprintf("%d %s %s", p->pid, state, p->name);
        if (p->state == SLEEPING) {
            getcallerpcs((uint*)p->context->ebp + 2, pc);
            for (i = 0; i < 10 && pc[i] != 0; i++)
                cprintf(" %p", pc[i]);
        }
        cprintf("\n");
    }
}

int
getpinfo(struct pstat* ps)
{
    if (!ps)
        return -1;

    struct proc* p;
    struct pstat* kps = &pstat;

    int i = 0;
    acquire(&ptable.lock);
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p->state == UNUSED) {
            ps->inuse[i] = 0;
        }
        else {
            ps->inuse[i] = 1;
        }
        ps->inuse[i] = kps->inuse[i];
        ps->pid[i] = kps->pid[i];
        ps->priority[i] = kps->priority[i];
        ps->state[i] = kps->state[i];
        int j;
        for (j = 0; j < 4; j++) {
            ps->ticks[i][j] = kps->ticks[i][j];
            ps->wait_ticks[i][j] = kps->wait_ticks[i][j];
        }
        i++;
    }
    release(&ptable.lock);
    return 0;
}

int
sys_setschedpolicy(void)
{
    struct cpu* c;
    int pol;

    if (argint(0, &pol) < 0)
        return -1;

    // mycpu() 접근을 위한 락
    pushcli();
    c = mycpu();
    popcli();

    c->sched_policy = pol;

    return 0;
}
