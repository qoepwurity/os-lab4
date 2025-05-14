#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

#define NCHILD 4
#define LOOP 200

static int child_list[NCHILD];       // 자식 PID 저장용
static int worktime;

int workload(int n) {
    int i, j = 0;
    for (i = 0; i < n; i++)
        j = j * i + 1;
    return j;
}

void
run_child(int me)
{
    // child 0 : 8 tick 이전 yield, child 1 : 16 tick …, child 2 : 32 tick …
    // child 3 : yield 안 함
    if (me < 3) {
        int target_ts[4] = { 8, 16, 32 };
        int target = target_ts[me];

        for (int rt = 0; rt < LOOP; rt++) {
            for (int j = 0; j < target; j++) {     
                workload(worktime);       
                workload(worktime);
                sleep(0);                    // 스스로 양보
            }
        }
    }
    else {
        for (int j = 0; j < LOOP; j++)
            workload(4000000);
    }
    exit();
}

static int
is_child(int pid)
{
    for (int i = 0; i < NCHILD; i++)
        if (child_list[i] == pid)
            return 1;
    return 0;
}

int
main(int argc, char* argv[])
{
    struct pstat st;
    int pid;

    if (argc != 2) {
        printf(1, "usage: mytest counter");
        exit();
    }
    else {
        worktime = atoi(argv[1]);;
    }

    /* 1. 정책 = 2 (MLFQ w/o tracking) */
    if (setschedpolicy(2) < 0) {
        printf(1, "setSchedPolicy failed\n");
        exit();
    }

    /* 2. 자식 4개 생성 */
    for (int i = 0; i < NCHILD; i++) {
        pid = fork();
        if (pid < 0) {
            printf(1, "fork failed\n");
            exit();
        }
        if (pid == 0) {           // child
            run_child(i);
        }
        else {
            child_list[i] = pid;    // ★ parent: PID 저장
        }
    }

    /* 3. parent : 자식 종료 대기 */
    for (int i = 0; i < NCHILD; i++)
        wait();

    /* 4. 스케줄링 정보 수집 */
    if (getpinfo(&st) < 0) {
        printf(1, "getpinfo failed\n");
        exit();
    }

    /* 5. child PID만 출력 */
    for (int i = 0; i < NPROC; i++) {
        if (!is_child(st.pid[i]))   // child만 출력
            continue;

        printf(1, "PID %d\n", st.pid[i]);
        printf(1, "  PRIORITY %d\n", st.priority[i]);
        for (int m = 3; m >= 0; m--) {
            printf(1, "    level %d ticks used  %d\n", m, st.ticks[i][m]);
            printf(1, "    level %d ticks wait  %d\n", m, st.wait_ticks[i][m]);
        }
    }

    exit();
}