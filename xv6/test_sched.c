#include "types.h"
#include "user.h"
#include "pstat.h"

int workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++) {
    j += i * j + 1;
  }
  return j;
}

int main(int argc, char *argv[]) {
  struct pstat ps;
  int pid;

  // 1. 스케줄링 정책을 MLFQ로 설정
  if (setSchedPolicy(1) < 0) {
    printf(1, "Failed to set scheduling policy\n");
    exit();
  }

  // 2. 자식 프로세스 생성
  pid = fork();
  if (pid == 0) {
    // child
    workload(4000000);  // CPU 점유
    exit();
  } else {
    wait();  // 부모는 대기
  }

  // 3. getpinfo 호출
  if (getpinfo(&ps) < 0) {
    printf(1, "getpinfo failed\n");
    exit();
  }

  // 4. 결과 출력
  int i;
  for (i = 0; i < NPROC; i++) {
    if (ps.inuse[i]) {
      printf(1, "pid %d | priority %d\n", ps.pid[i], ps.priority[i]);
      printf(1, "ticks: [%d %d %d %d]\n",
        ps.ticks[i][0], ps.ticks[i][1], ps.ticks[i][2], ps.ticks[i][3]);
      printf(1, "wait_ticks: [%d %d %d %d]\n",
        ps.wait_ticks[i][0], ps.wait_ticks[i][1], ps.wait_ticks[i][2], ps.wait_ticks[i][3]);
    }
  }

  exit();
}
