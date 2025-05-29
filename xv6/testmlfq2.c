#include "types.h"
#include "user.h"
#include "pstat.h"

#define NUM_CHILDREN 3
int setSchedPolicy(int policy);

void spin(int count) {
  int i, x = 0;
  for (i = 0; i < count; i++)
    x += i % 10;
}

int
main(int argc, char *argv[])
{
  struct pstat st;

  // MLFQ w/o tracking 모드로 설정
  if (setSchedPolicy(2) < 0) {
    printf(1, "Failed to set sched policy\n");
    exit();
  }

  int i;
  for (i = 0; i < NUM_CHILDREN; i++) {
    if (fork() == 0) {
      // 자식: CPU 소모 작업 반복
      spin(1 << 25);  // 충분히 긴 루프
      exit();
    }
  }

  // 부모: 모든 자식 기다림
  for (i = 0; i < NUM_CHILDREN; i++) {
    wait();
  }

  // 정보 수집 및 출력
  if (getpinfo(&st) < 0) {
    printf(1, "Failed to get pinfo\n");
    exit();
  }

  for (i = 0; i < NPROC; i++) {
    if (st.inuse[i]) {
      printf(1, "PID %d: ", st.pid[i]);
      for (int l = 3; l >= 0; l--) {
        printf(1, "L%d: %d ", l, st.ticks[i][l]);
      }
      printf(1, "\n");
    }
  }

  exit();
}