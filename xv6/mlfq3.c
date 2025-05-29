#include "types.h"
#include "user.h"
#include "pstat.h"

struct pstat global_st;

int workload(int n) {
  int i, j = 0;
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

int measure_workload_unit() {
  struct pstat *st = &global_st;
  int pid = getpid(), t0 = -1, t1 = -1;
  int level = 3;

  // ⏱ 프로세스가 ptable에 등록될 때까지 대기
  while (1) {
    getpinfo(st);
    int found = 0;
    for (int i = 0; i < NPROC; i++) {
      if (st->inuse[i] && st->pid[i] == pid) {
        found = 1;
        break;
      }
    }
    if (found) break;
    sleep(1);  // 잠깐 대기
  }

  for (int n = 1000000; n <= 50000000; n += 50000) {
    getpinfo(st);
    for (int i = 0; i < NPROC; i++) {
      if (st->inuse[i] && st->pid[i] == pid) {
        level = st->priority[i];
        t0 = st->ticks[i][level];
        break;
      }
    }

    if (t0 < 0) continue;

    workload(n);
    sleep(5);

    getpinfo(st);
    for (int i = 0; i < NPROC; i++) {
      if (st->inuse[i] && st->pid[i] == pid) {
        t1 = st->ticks[i][level];
        break;
      }
    }

    if (t1 > t0) {
      printf(1, "✅ workload(%d) → tick 증가 (Q%d, %d → %d)\n", n, level, t0, t1);
      return n;
    }
  }

  printf(1, "❌ tick 증가 확인 실패\n");
  return -1;
}



int main(void) {
  struct pstat st;
  int i, pid;
  int child_pid[4];
  int workload_unit = 4000000;
  int tick_unit = measure_workload_unit();  // workload 단위 측정

  if (tick_unit <= 0) {
    printf(1, "❌ workload_unit 측정 실패 또는 너무 작음. 기본값 100000 사용\n");
    tick_unit = 4000000;
  } else measure_workload_unit();

  setSchedPolicy(3);
  printf(1, "✅ setSchedPolicy(3) 적용 완료\n");

  for (i = 0; i < 4; i++) {
    pid = fork();
    if (pid < 0) {
      printf(1, "❌ fork failed at i = %d\n", i);
    } else if (pid == 0) {
      sleep(500);
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
  sleep(2);
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


