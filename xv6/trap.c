#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"
#include "i8254.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[]; // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);
int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);

void tvinit(void)
{
  int i;

  for (i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void idtinit(void)
{
  lidt(idt, sizeof(idt));
}

// PAGEBREAK: 41
void trap(struct trapframe *tf)
{
  struct proc *p = myproc();
  if (tf->trapno == T_SYSCALL)
  {
    if (myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if (myproc()->killed)
      exit();
    return;
  }

  switch (tf->trapno)
  {
  case T_IRQ0 + IRQ_TIMER:
    if (cpuid() == 0)
    {
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();

    // 유저모드 + scheduler 설정된 경우만 실행
    if (p && p->state == RUNNING && p->scheduler)
    {
      if (p->check_thread >= 2)
      {
        p->tf->eip = p->scheduler;
      }
    }

    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE + 1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 0xB:
    i8254_intr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;

  case T_PGFLT:
    uint va = PGROUNDDOWN(rcr2());

    if (!p)
      break;

    if (va >= KERNBASE || (p->sz == 0))
    {
      // 커널 영역, 혹은 전체 해제된 경우: 접근 금지
      p->killed = 1;
      break;
    }

    pte_t *pte = walkpgdir(p->pgdir, (char *)va, 0);
    if (pte && (*pte & PTE_P)) {
        p->killed = 1;
        break;
    }

    // pte_t *pte = walkpgdir(p->pgdir, (char *)va, 0);
    // if (!pte || (*pte & PTE_P)) {
    //     p->killed = 1;
    //     break;
    // }

    // pte_t *pte = walkpgdir(p->pgdir, (char *)va, 0);
    // if (!pte)
    // {
    //   p->killed = 1;
    //   break;
    // }
    // if (*pte & PTE_P)
    // {
    //   p->killed = 1;
    //   break;
    // }

    char *mem = kalloc();
    if (mem == 0)
    {
      cprintf("allocuvm out of memory\n");
      p->killed = 1;
      break;
    }
    memset(mem, 0, PGSIZE);
    if (mappages(p->pgdir, (char *)va, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0)
    {
      kfree(mem);
      p->killed = 1;
      break;
    }

    lcr3(V2P(p->pgdir)); // TLB flush
    break;

  // PAGEBREAK: 13
  default:
    if (myproc() == 0 || (tf->cs & 3) == 0)
    {
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if (myproc() && myproc()->state == RUNNING &&
      tf->trapno == T_IRQ0 + IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
    exit();
}
