#include "types.h"
#include "user.h"
#include "pstat.h"

void do_yield_work(int count)
{
  int i, j = 0;
  for (i = 0; i < count; i++)
  {
    j += i * j + 1;
    yield(); // 📌 매 루프마다 CPU 양보
  }
}

int main(int argc, char *argv[])
{
  struct pstat ps;
  int pid;

  int ret = setSchedPolicy(1);
  printf(1, "setSchedPolicy(1) returned: %d\n", ret);

  // 스케줄링 정책: MLFQ
  if (setSchedPolicy(1) < 0)
  {
    printf(1, "Failed to set scheduling policy\n");
    exit();
  }

  pid = fork();
  if (pid == 0)
  {
    // 자식 프로세스: 일부러 yield 반복
    do_yield_work(50);
    exit();
  }
  else
  {
    wait();     // 여전히 wait 하지만...
    sleep(100); // 추가로 잠깐 더 대기하여 stats 반영되게 함
    getpinfo(&ps);
  }

  // getpinfo 확인
  if (getpinfo(&ps) < 0)
  {
    printf(1, "getpinfo failed\n");
    exit();
  }

  // 출력
  int i;
  for (i = 0; i < NPROC; i++)
  {
    if (ps.inuse[i])
    {
      printf(1, "pid %d | priority %d\n", ps.pid[i], ps.priority[i]);
      printf(1, "ticks: [%d %d %d %d]\n",
             ps.ticks[i][0], ps.ticks[i][1], ps.ticks[i][2], ps.ticks[i][3]);
      printf(1, "wait_ticks: [%d %d %d %d]\n",
             ps.wait_ticks[i][0], ps.wait_ticks[i][1], ps.wait_ticks[i][2], ps.wait_ticks[i][3]);
    }
  }

  exit();
}
