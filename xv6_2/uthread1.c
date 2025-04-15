#include "types.h"
#include "stat.h"
#include "user.h"
#include "syscall.h"

/* Possible states of a thread; */
#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2

#define STACK_SIZE  8192
#define MAX_THREAD  4

typedef struct thread thread_t, *thread_p;
typedef struct mutex mutex_t, *mutex_p;

struct thread {
  int        sp;                /* saved stack pointer */
  char stack[STACK_SIZE];       /* the thread's stack */
  int        state;             /* FREE, RUNNING, RUNNABLE */
};
static thread_t all_thread[MAX_THREAD];
thread_p  current_thread;
thread_p  next_thread;
extern void thread_switch(void);

static void 
thread_schedule(void)
{
  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == RUNNABLE && t != current_thread) {
      next_thread = t;
      break;
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  }

  if (next_thread == 0) {
    // printf(2, "thread_schedule: no runnable threads\n");
    // exit();
    if (current_thread->state == FREE) {
      printf(1, "No more runnable threads. Exiting.\n");
      exit();
    }
    next_thread = current_thread;// 주석 제외 지피티 추가
  }

  if (current_thread != next_thread) {         /* switch threads?  */
    // 여기에 상태 출력!
  printf(1, "switching from 0x%x (state=%d) to 0x%x (state=%d)\n",
         (uint)current_thread, current_thread->state,
         (uint)next_thread, next_thread->state); //확인용 지피티 추가
    next_thread->state = RUNNING;
    if(current_thread != &all_thread[0] && current_thread->state == RUNNING){
      current_thread->state = RUNNABLE;
    }
    thread_switch();
  } else
    next_thread = 0;
}

void 
thread_init(void)
{
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
  uthread_init((int)thread_schedule);
}

void 
thread_create(void (*func)())
{
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }

  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
  t->sp -= 4;                              // space for return address
  * (int *) (t->sp) = (int)func;           // push return address on stack
  t->sp -= 28;                             // space for registers that thread_switch expects
  t->state = RUNNABLE;
  uthread_count(1);

  printf(1, "thread_create: t=0x%x sp=0x%x func=0x%x\n", (uint)t, t->sp, (uint)func);
}

static void 
mythread(void)
{
  printf(1, ">> entered mythread: current_thread = 0x%x\n", (uint)current_thread);
  int i;
  printf(1, "my thread running\n");
  for (i = 0; i < 100; i++) {
    printf(1, "my thread 0x%x\n", (int) current_thread);
  }
  printf(1, "my thread: exit\n");
  current_thread->state = FREE;
  uthread_count(-1);
  thread_schedule(); // 지피티 추가
}

int 
main(int argc, char *argv[]) 
{
  uthread_init((int)thread_switch);
  //thread_init();
  thread_create(mythread);
  thread_create(mythread);
  thread_schedule();
  return 0;
}
