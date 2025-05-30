#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "pstat.h"
#include "spinlock.h"

extern int proc_priority[NPROC];
extern int proc_ticks[NPROC][4];
extern int proc_wait_ticks[NPROC][4];

struct proc* find_proc_by_pid(int pid);
void print_user_page_table(struct proc *p);
pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);

extern struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;  // current heap size
  if(growproc(n) < 0)   // heap size 늘림. 현재는 heap만 늘림?
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// 이거 추가
int
sys_uthread_init(void)
{
  int addr;
  if (argint(0, &addr) < 0)
    return -1;
  myproc()->scheduler = addr;
  return 0;
}



int
sys_check_thread(void) {
  int op;
  if (argint(0, &op) < 0)  // 사용자로부터 인자 하나 받음
    return -1;

  struct proc* p = myproc();
  p->check_thread += op;  // +1 또는 -1

  return 0;
}


int
sys_getpinfo(void) {
  struct pstat *ps;
  if (argptr(0, (void *)&ps, sizeof(*ps)) < 0)
    return -1;

  acquire(&ptable.lock);
  for (int i = 0; i < NPROC; i++) {
    struct proc *p = &ptable.proc[i];
    ps->inuse[i] = (p->state != UNUSED);
    ps->pid[i] = p->pid;
    ps->priority[i] = proc_priority[i];
    ps->state[i] = p->state;
    for (int j = 0; j < 4; j++) {
      ps->ticks[i][j] = proc_ticks[i][j];
      ps->wait_ticks[i][j] = proc_wait_ticks[i][j];
    }
  }
  release(&ptable.lock);
  return 0;
}


int
sys_setSchedPolicy(void) {
  int policy;
  if (argint(0, &policy) < 0)
    return -1;
  
  pushcli();
  mycpu()->sched_policy = policy;
  popcli();

  cprintf("✅ sched_policy set to %d\n", policy);
  return 0;
}

int
sys_yield(void)
{
  yield();
  return 0;
}

void 
print_user_page_table(struct proc *p) {
  cprintf("START PAGE TABLE (pid %d)\n", p->pid);
  pde_t *pgdir = p->pgdir;
  for(uint va = 0; va < KERNBASE; va += PGSIZE) {
    pte_t *pte = walkpgdir(pgdir, (void*)va, 0);
    if(!pte)
      continue;
    if(!(*pte & PTE_P))
      continue;
    // 페이지 번호 = va / PGSIZE
    int vpn = va / PGSIZE;
    char uork = (*pte & PTE_U) ? 'U' : 'K';
    char w = (*pte & PTE_W) ? 'W' : '-';
    uint ppn = PTE_ADDR(*pte) >> 12; // 물리 페이지 번호
    cprintf("%d P %c %c %x\n", vpn, uork, w, ppn);
  }
  cprintf("END PAGE TABLE\n");
}

int 
sys_printpt(void) {
  int pid;
  if(argint(0, &pid) < 0)
    return -1;
  struct proc *p = find_proc_by_pid(pid); // 아래에 별도 구현
  if(!p)
    return -1;
  print_user_page_table(p); // 별도 구현
  return 0;
}