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

void do_yield_work(int n) {
  volatile int i, j = 0;
  for (i = 0; i < n; i++) {
    j = j * i + 1;
    yield();  // CPU 양보
  }
}

void print_stats(struct pstat *ps, int tracked_pid) {
  for (int i = 0; i < NPROC; i++) {
    if (!ps->inuse[i]) continue;
    if (ps->pid[i] == tracked_pid) {
      printf(1, "📌 pid: %d | priority: %d\n", ps->pid[i], ps->priority[i]);
      printf(1, "    ticks:      [%d %d %d %d]\n", 
        ps->ticks[i][0], ps->ticks[i][1], ps->ticks[i][2], ps->ticks[i][3]);
      printf(1, "    wait_ticks: [%d %d %d %d]\n", 
        ps->wait_ticks[i][0], ps->wait_ticks[i][1], ps->wait_ticks[i][2], ps->wait_ticks[i][3]);
    }
  }
}

int main(void) {
  int pid;
  struct pstat ps;

  printf(1, "\n==== 스케줄링 정책 설정 & 통계 확인 테스트 ====\n");

  // 정책 1: MLFQ with boosting
  if (setSchedPolicy(1) < 0) {
    printf(1, "❌ setSchedPolicy(1) 실패\n");
    exit();
  }

  pid = fork();
  if (pid < 0) {
    printf(1, "❌ fork 실패\n");
    exit();
  } else if (pid == 0) {
    // 자식: CPU 작업
    printf(1, "✅ 자식: workload 시작\n");
    workload(5000000);
    exit();
  } else {
    wait();  // 자식 종료 대기
    sleep(100);  // 통계 수집 시간 확보
    if (getpinfo(&ps) < 0) {
      printf(1, "❌ getpinfo 실패\n");
      exit();
    }
    print_stats(&ps, pid);
  }

  // 정책 2: MLFQ without boosting
  if (setSchedPolicy(2) < 0) {
    printf(1, "❌ setSchedPolicy(2) 실패\n");
    exit();
  }

  pid = fork();
  if (pid == 0) {
    // 자식: yield 반복 → wait_ticks 높게 기대
    printf(1, "✅ 자식: yield workload 시작\n");
    do_yield_work(50);
    exit();
  } else {
    wait();
    sleep(100);
    if (getpinfo(&ps) < 0) {
      printf(1, "❌ getpinfo 실패\n");
      exit();
    }
    print_stats(&ps, pid);
  }

  // 정책 0: Round-robin
  if (setSchedPolicy(0) < 0) {
    printf(1, "❌ setSchedPolicy(0) 실패\n");
    exit();
  }

  pid = fork();
  if (pid == 0) {
    printf(1, "✅ 자식: RR workload 시작\n");
    workload(5000000);
    exit();
  } else {
    wait();
    sleep(100);
    if (getpinfo(&ps) < 0) {
      printf(1, "❌ getpinfo 실패\n");
      exit();
    }
    print_stats(&ps, pid);
  }

  printf(1, "✅ 모든 테스트 완료\n");
  exit();
}
