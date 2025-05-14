#include "types.h"
#include "user.h"
#include "pstat.h"

int workload(int n) {
  volatile int i, j = 0;
  for (i = 0; i < n; i++)
    j = j * i + 1;
  return j;
}

int is_child(int pid, int *child_pid, int count) {
  for (int i = 0; i < count; i++) {
    if (child_pid[i] == pid)
      return 1;
  }
  return 0;
}

void print_proc_info(struct pstat *st, int *child_pid, int count, const char *title) {
  int wait_times[4] = {500, 320, 160, 80};

  printf(1, "\n[ %s ] ----------------------------\n", title);
  for (int i = 0; i < NPROC; i++) {
    if (!st->inuse[i]) continue;
    if (!is_child(st->pid[i], child_pid, count)) continue;

    printf(1, "pid %d | priority %d\n", st->pid[i], st->priority[i]);
    printf(1, "  ticks:      [%d %d %d %d]\n",
           st->ticks[i][0], st->ticks[i][1], st->ticks[i][2], st->ticks[i][3]);
    printf(1, "  wait_ticks: [%d %d %d %d]\n",
           st->wait_ticks[i][0], st->wait_ticks[i][1], st->wait_ticks[i][2], st->wait_ticks[i][3]);

    for (int q = 0; q < 4; q++) {
      if (st->wait_ticks[i][q] >= wait_times[q]) {
        printf(1, "  boost condition met: wait_ticks[%d] >= %d (ignored in policy 3)\n", q, wait_times[q]);
      }
    }

    if (st->priority[i] == 0 && st->ticks[i][0] > 0)
      printf(1, "  pid %d demoted to Q0\n", st->pid[i]);
  }
}


// tick을 1 증가시키는 workload 단위 측정 함수
int measure_workload_unit() {
  struct pstat st;
  int pid = getpid(), t0 = -1, t1 = -1;

  for (int n = 10000; n <= 300000; n += 5000) {
    getpinfo(&st);
    t0 = -1;

    for (int i = 0; i < NPROC; i++) {
      if (st.inuse[i] && st.pid[i] == pid) {
        t0 = st.ticks[i][3];
        break;
      }
    }

    if (t0 < 0) {
      printf(1, "❌ t0 not found at n=%d\n", n);
      continue;
    }

    volatile int tmp = workload(n);
    tmp += 0;
    sleep(10);  // 충분히 tick 반영 시간 확보

    getpinfo(&st);
    t1 = -1;
    for (int i = 0; i < NPROC; i++) {
      if (st.inuse[i] && st.pid[i] == pid) {
        t1 = st.ticks[i][3];
        break;
      }
    }

    if (t1 < 0) continue;
    if (t1 > t0) {
      printf(1, "✅ workload(%d) → tick 증가 (%d → %d)\n", n, t0, t1);
      return n;
    }
  }

  printf(1, "❌ tick 증가 확인 실패 (n 범위 초과)\n");
  return -1;
}



int main(void) {
  struct pstat st;
  int i, pid;
  int child_pid[4];
  int workload_unit = 4000000;
  //int tick_unit = measure_workload_unit();  // workload 단위 측정

  //if (tick_unit < 0) exit();

  setSchedPolicy(3);
  printf(1, "✅ setSchedPolicy(3) 적용 완료\n");

  for (i = 0; i < 4; i++) {
    pid = fork();
    if (pid < 0) {
      printf(1, "❌ fork failed at i = %d\n", i);
    } else if (pid == 0) {
      sleep(300);
      printf(1, "Child index %d | pid %d\n", i, getpid());

      if (i < 2) {
        for (int t = 0; t < 8; t++) {
          workload(workload_unit);
          yield();
        }
        while (1);  // 계속 RUNNABLE 상태 유지해서 wait_ticks 쌓이게
      } else {
        for (int t = 0; t < 300; t++) {
          workload(workload_unit);
        }
        exit();
      }
    } else {
      child_pid[i] = pid;
      printf(1, "✅ fork success: child index %d | pid %d\n", i, pid);
    }
  }

  // ⏱ 초기 상태 확인
  getpinfo(&st);
  print_proc_info(&st, child_pid, 4, "초기 상태");

  // ⏱ 중간 상태 확인
  sleep(1);
  getpinfo(&st);
  print_proc_info(&st, child_pid, 4, "중간 상태");

  // ⏱ 충분히 시간 경과 후 상태 확인
  sleep(2000);
  getpinfo(&st);
  print_proc_info(&st, child_pid, 4, "충분히 시간 경과 후 상태");

  // ✅ 무한 루프 중인 자식 종료
  for (i = 0; i < 4; i++) kill(child_pid[i]);

  for (i = 0; i < 4; i++) wait();

  exit();
}


