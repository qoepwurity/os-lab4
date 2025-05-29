
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "types.h"
#include "user.h"
#include "pstat.h"

int workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++) {
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 11                	jmp    27 <workload+0x27>
    j += i * j + 1;
  16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  19:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f8             	add    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++) {
  23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	7c e7                	jl     16 <workload+0x16>
  }
  return j;
  2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  32:	c9                   	leave  
  33:	c3                   	ret    

00000034 <do_yield_work>:

void do_yield_work(int n) {
  34:	55                   	push   %ebp
  35:	89 e5                	mov    %esp,%ebp
  37:	83 ec 18             	sub    $0x18,%esp
  volatile int i, j = 0;
  3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for (i = 0; i < n; i++) {
  41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  48:	eb 1d                	jmp    67 <do_yield_work+0x33>
    j = j * i + 1;
  4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  50:	0f af c2             	imul   %edx,%eax
  53:	83 c0 01             	add    $0x1,%eax
  56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    yield();  // CPU 양보
  59:	e8 cb 06 00 00       	call   729 <yield>
  for (i = 0; i < n; i++) {
  5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  61:	83 c0 01             	add    $0x1,%eax
  64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6a:	39 45 08             	cmp    %eax,0x8(%ebp)
  6d:	7f db                	jg     4a <do_yield_work+0x16>
  }
}
  6f:	90                   	nop
  70:	90                   	nop
  71:	c9                   	leave  
  72:	c3                   	ret    

00000073 <print_stats>:

void print_stats(struct pstat *ps, int tracked_pid) {
  73:	55                   	push   %ebp
  74:	89 e5                	mov    %esp,%ebp
  76:	56                   	push   %esi
  77:	53                   	push   %ebx
  78:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  82:	e9 0e 01 00 00       	jmp    195 <print_stats+0x122>
    if (!ps->inuse[i]) continue;
  87:	8b 45 08             	mov    0x8(%ebp),%eax
  8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8d:	8b 04 90             	mov    (%eax,%edx,4),%eax
  90:	85 c0                	test   %eax,%eax
  92:	0f 84 f8 00 00 00    	je     190 <print_stats+0x11d>
    if (ps->pid[i] == tracked_pid) {
  98:	8b 45 08             	mov    0x8(%ebp),%eax
  9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  9e:	83 c2 40             	add    $0x40,%edx
  a1:	8b 04 90             	mov    (%eax,%edx,4),%eax
  a4:	39 45 0c             	cmp    %eax,0xc(%ebp)
  a7:	0f 85 e4 00 00 00    	jne    191 <print_stats+0x11e>
      printf(1, "📌 pid: %d | priority: %d\n", ps->pid[i], ps->priority[i]);
  ad:	8b 45 08             	mov    0x8(%ebp),%eax
  b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  b3:	83 ea 80             	sub    $0xffffff80,%edx
  b6:	8b 14 90             	mov    (%eax,%edx,4),%edx
  b9:	8b 45 08             	mov    0x8(%ebp),%eax
  bc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  bf:	83 c1 40             	add    $0x40,%ecx
  c2:	8b 04 88             	mov    (%eax,%ecx,4),%eax
  c5:	52                   	push   %edx
  c6:	50                   	push   %eax
  c7:	68 c4 0b 00 00       	push   $0xbc4
  cc:	6a 01                	push   $0x1
  ce:	e8 3a 07 00 00       	call   80d <printf>
  d3:	83 c4 10             	add    $0x10,%esp
      printf(1, "    ticks:      [%d %d %d %d]\n", 
  d6:	8b 55 08             	mov    0x8(%ebp),%edx
  d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  dc:	c1 e0 04             	shl    $0x4,%eax
  df:	01 d0                	add    %edx,%eax
  e1:	05 0c 04 00 00       	add    $0x40c,%eax
  e6:	8b 18                	mov    (%eax),%ebx
  e8:	8b 55 08             	mov    0x8(%ebp),%edx
  eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ee:	c1 e0 04             	shl    $0x4,%eax
  f1:	01 d0                	add    %edx,%eax
  f3:	05 08 04 00 00       	add    $0x408,%eax
  f8:	8b 08                	mov    (%eax),%ecx
  fa:	8b 55 08             	mov    0x8(%ebp),%edx
  fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 100:	c1 e0 04             	shl    $0x4,%eax
 103:	01 d0                	add    %edx,%eax
 105:	05 04 04 00 00       	add    $0x404,%eax
 10a:	8b 10                	mov    (%eax),%edx
 10c:	8b 75 08             	mov    0x8(%ebp),%esi
 10f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 112:	83 c0 40             	add    $0x40,%eax
 115:	c1 e0 04             	shl    $0x4,%eax
 118:	01 f0                	add    %esi,%eax
 11a:	8b 00                	mov    (%eax),%eax
 11c:	83 ec 08             	sub    $0x8,%esp
 11f:	53                   	push   %ebx
 120:	51                   	push   %ecx
 121:	52                   	push   %edx
 122:	50                   	push   %eax
 123:	68 e4 0b 00 00       	push   $0xbe4
 128:	6a 01                	push   $0x1
 12a:	e8 de 06 00 00       	call   80d <printf>
 12f:	83 c4 20             	add    $0x20,%esp
        ps->ticks[i][0], ps->ticks[i][1], ps->ticks[i][2], ps->ticks[i][3]);
      printf(1, "    wait_ticks: [%d %d %d %d]\n", 
 132:	8b 55 08             	mov    0x8(%ebp),%edx
 135:	8b 45 f4             	mov    -0xc(%ebp),%eax
 138:	c1 e0 04             	shl    $0x4,%eax
 13b:	01 d0                	add    %edx,%eax
 13d:	05 0c 08 00 00       	add    $0x80c,%eax
 142:	8b 18                	mov    (%eax),%ebx
 144:	8b 55 08             	mov    0x8(%ebp),%edx
 147:	8b 45 f4             	mov    -0xc(%ebp),%eax
 14a:	c1 e0 04             	shl    $0x4,%eax
 14d:	01 d0                	add    %edx,%eax
 14f:	05 08 08 00 00       	add    $0x808,%eax
 154:	8b 08                	mov    (%eax),%ecx
 156:	8b 55 08             	mov    0x8(%ebp),%edx
 159:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15c:	c1 e0 04             	shl    $0x4,%eax
 15f:	01 d0                	add    %edx,%eax
 161:	05 04 08 00 00       	add    $0x804,%eax
 166:	8b 10                	mov    (%eax),%edx
 168:	8b 75 08             	mov    0x8(%ebp),%esi
 16b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16e:	83 e8 80             	sub    $0xffffff80,%eax
 171:	c1 e0 04             	shl    $0x4,%eax
 174:	01 f0                	add    %esi,%eax
 176:	8b 00                	mov    (%eax),%eax
 178:	83 ec 08             	sub    $0x8,%esp
 17b:	53                   	push   %ebx
 17c:	51                   	push   %ecx
 17d:	52                   	push   %edx
 17e:	50                   	push   %eax
 17f:	68 04 0c 00 00       	push   $0xc04
 184:	6a 01                	push   $0x1
 186:	e8 82 06 00 00       	call   80d <printf>
 18b:	83 c4 20             	add    $0x20,%esp
 18e:	eb 01                	jmp    191 <print_stats+0x11e>
    if (!ps->inuse[i]) continue;
 190:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
 191:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 195:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 199:	0f 8e e8 fe ff ff    	jle    87 <print_stats+0x14>
        ps->wait_ticks[i][0], ps->wait_ticks[i][1], ps->wait_ticks[i][2], ps->wait_ticks[i][3]);
    }
  }
}
 19f:	90                   	nop
 1a0:	90                   	nop
 1a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1a4:	5b                   	pop    %ebx
 1a5:	5e                   	pop    %esi
 1a6:	5d                   	pop    %ebp
 1a7:	c3                   	ret    

000001a8 <main>:

int main(void) {
 1a8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 1ac:	83 e4 f0             	and    $0xfffffff0,%esp
 1af:	ff 71 fc             	push   -0x4(%ecx)
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	51                   	push   %ecx
 1b6:	81 ec 14 0c 00 00    	sub    $0xc14,%esp
  int pid;
  struct pstat ps;

  printf(1, "\n==== 스케줄링 정책 설정 & 통계 확인 테스트 ====\n");
 1bc:	83 ec 08             	sub    $0x8,%esp
 1bf:	68 24 0c 00 00       	push   $0xc24
 1c4:	6a 01                	push   $0x1
 1c6:	e8 42 06 00 00       	call   80d <printf>
 1cb:	83 c4 10             	add    $0x10,%esp

  // 정책 1: MLFQ with boosting
  if (setSchedPolicy(1) < 0) {
 1ce:	83 ec 0c             	sub    $0xc,%esp
 1d1:	6a 01                	push   $0x1
 1d3:	e8 49 05 00 00       	call   721 <setSchedPolicy>
 1d8:	83 c4 10             	add    $0x10,%esp
 1db:	85 c0                	test   %eax,%eax
 1dd:	79 17                	jns    1f6 <main+0x4e>
    printf(1, "❌ setSchedPolicy(1) 실패\n");
 1df:	83 ec 08             	sub    $0x8,%esp
 1e2:	68 65 0c 00 00       	push   $0xc65
 1e7:	6a 01                	push   $0x1
 1e9:	e8 1f 06 00 00       	call   80d <printf>
 1ee:	83 c4 10             	add    $0x10,%esp
    exit();
 1f1:	e8 73 04 00 00       	call   669 <exit>
  }

  pid = fork();
 1f6:	e8 66 04 00 00       	call   661 <fork>
 1fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (pid < 0) {
 1fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 202:	79 17                	jns    21b <main+0x73>
    printf(1, "❌ fork 실패\n");
 204:	83 ec 08             	sub    $0x8,%esp
 207:	68 83 0c 00 00       	push   $0xc83
 20c:	6a 01                	push   $0x1
 20e:	e8 fa 05 00 00       	call   80d <printf>
 213:	83 c4 10             	add    $0x10,%esp
    exit();
 216:	e8 4e 04 00 00       	call   669 <exit>
  } else if (pid == 0) {
 21b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 21f:	75 27                	jne    248 <main+0xa0>
    // 자식: CPU 작업
    printf(1, "✅ 자식: workload 시작\n");
 221:	83 ec 08             	sub    $0x8,%esp
 224:	68 94 0c 00 00       	push   $0xc94
 229:	6a 01                	push   $0x1
 22b:	e8 dd 05 00 00       	call   80d <printf>
 230:	83 c4 10             	add    $0x10,%esp
    workload(5000000);
 233:	83 ec 0c             	sub    $0xc,%esp
 236:	68 40 4b 4c 00       	push   $0x4c4b40
 23b:	e8 c0 fd ff ff       	call   0 <workload>
 240:	83 c4 10             	add    $0x10,%esp
    exit();
 243:	e8 21 04 00 00       	call   669 <exit>
  } else {
    wait();  // 자식 종료 대기
 248:	e8 24 04 00 00       	call   671 <wait>
    sleep(100);  // 통계 수집 시간 확보
 24d:	83 ec 0c             	sub    $0xc,%esp
 250:	6a 64                	push   $0x64
 252:	e8 a2 04 00 00       	call   6f9 <sleep>
 257:	83 c4 10             	add    $0x10,%esp
    if (getpinfo(&ps) < 0) {
 25a:	83 ec 0c             	sub    $0xc,%esp
 25d:	8d 85 f4 f3 ff ff    	lea    -0xc0c(%ebp),%eax
 263:	50                   	push   %eax
 264:	e8 b0 04 00 00       	call   719 <getpinfo>
 269:	83 c4 10             	add    $0x10,%esp
 26c:	85 c0                	test   %eax,%eax
 26e:	79 17                	jns    287 <main+0xdf>
      printf(1, "❌ getpinfo 실패\n");
 270:	83 ec 08             	sub    $0x8,%esp
 273:	68 b1 0c 00 00       	push   $0xcb1
 278:	6a 01                	push   $0x1
 27a:	e8 8e 05 00 00       	call   80d <printf>
 27f:	83 c4 10             	add    $0x10,%esp
      exit();
 282:	e8 e2 03 00 00       	call   669 <exit>
    }
    print_stats(&ps, pid);
 287:	83 ec 08             	sub    $0x8,%esp
 28a:	ff 75 f4             	push   -0xc(%ebp)
 28d:	8d 85 f4 f3 ff ff    	lea    -0xc0c(%ebp),%eax
 293:	50                   	push   %eax
 294:	e8 da fd ff ff       	call   73 <print_stats>
 299:	83 c4 10             	add    $0x10,%esp
  }

  // 정책 2: MLFQ without boosting
  if (setSchedPolicy(2) < 0) {
 29c:	83 ec 0c             	sub    $0xc,%esp
 29f:	6a 02                	push   $0x2
 2a1:	e8 7b 04 00 00       	call   721 <setSchedPolicy>
 2a6:	83 c4 10             	add    $0x10,%esp
 2a9:	85 c0                	test   %eax,%eax
 2ab:	79 17                	jns    2c4 <main+0x11c>
    printf(1, "❌ setSchedPolicy(2) 실패\n");
 2ad:	83 ec 08             	sub    $0x8,%esp
 2b0:	68 c6 0c 00 00       	push   $0xcc6
 2b5:	6a 01                	push   $0x1
 2b7:	e8 51 05 00 00       	call   80d <printf>
 2bc:	83 c4 10             	add    $0x10,%esp
    exit();
 2bf:	e8 a5 03 00 00       	call   669 <exit>
  }

  pid = fork();
 2c4:	e8 98 03 00 00       	call   661 <fork>
 2c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (pid == 0) {
 2cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2d0:	75 24                	jne    2f6 <main+0x14e>
    // 자식: yield 반복 → wait_ticks 높게 기대
    printf(1, "✅ 자식: yield workload 시작\n");
 2d2:	83 ec 08             	sub    $0x8,%esp
 2d5:	68 e4 0c 00 00       	push   $0xce4
 2da:	6a 01                	push   $0x1
 2dc:	e8 2c 05 00 00       	call   80d <printf>
 2e1:	83 c4 10             	add    $0x10,%esp
    do_yield_work(50);
 2e4:	83 ec 0c             	sub    $0xc,%esp
 2e7:	6a 32                	push   $0x32
 2e9:	e8 46 fd ff ff       	call   34 <do_yield_work>
 2ee:	83 c4 10             	add    $0x10,%esp
    exit();
 2f1:	e8 73 03 00 00       	call   669 <exit>
  } else {
    wait();
 2f6:	e8 76 03 00 00       	call   671 <wait>
    sleep(100);
 2fb:	83 ec 0c             	sub    $0xc,%esp
 2fe:	6a 64                	push   $0x64
 300:	e8 f4 03 00 00       	call   6f9 <sleep>
 305:	83 c4 10             	add    $0x10,%esp
    if (getpinfo(&ps) < 0) {
 308:	83 ec 0c             	sub    $0xc,%esp
 30b:	8d 85 f4 f3 ff ff    	lea    -0xc0c(%ebp),%eax
 311:	50                   	push   %eax
 312:	e8 02 04 00 00       	call   719 <getpinfo>
 317:	83 c4 10             	add    $0x10,%esp
 31a:	85 c0                	test   %eax,%eax
 31c:	79 17                	jns    335 <main+0x18d>
      printf(1, "❌ getpinfo 실패\n");
 31e:	83 ec 08             	sub    $0x8,%esp
 321:	68 b1 0c 00 00       	push   $0xcb1
 326:	6a 01                	push   $0x1
 328:	e8 e0 04 00 00       	call   80d <printf>
 32d:	83 c4 10             	add    $0x10,%esp
      exit();
 330:	e8 34 03 00 00       	call   669 <exit>
    }
    print_stats(&ps, pid);
 335:	83 ec 08             	sub    $0x8,%esp
 338:	ff 75 f4             	push   -0xc(%ebp)
 33b:	8d 85 f4 f3 ff ff    	lea    -0xc0c(%ebp),%eax
 341:	50                   	push   %eax
 342:	e8 2c fd ff ff       	call   73 <print_stats>
 347:	83 c4 10             	add    $0x10,%esp
  }

  // 정책 0: Round-robin
  if (setSchedPolicy(0) < 0) {
 34a:	83 ec 0c             	sub    $0xc,%esp
 34d:	6a 00                	push   $0x0
 34f:	e8 cd 03 00 00       	call   721 <setSchedPolicy>
 354:	83 c4 10             	add    $0x10,%esp
 357:	85 c0                	test   %eax,%eax
 359:	79 17                	jns    372 <main+0x1ca>
    printf(1, "❌ setSchedPolicy(0) 실패\n");
 35b:	83 ec 08             	sub    $0x8,%esp
 35e:	68 07 0d 00 00       	push   $0xd07
 363:	6a 01                	push   $0x1
 365:	e8 a3 04 00 00       	call   80d <printf>
 36a:	83 c4 10             	add    $0x10,%esp
    exit();
 36d:	e8 f7 02 00 00       	call   669 <exit>
  }

  pid = fork();
 372:	e8 ea 02 00 00       	call   661 <fork>
 377:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (pid == 0) {
 37a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 37e:	75 27                	jne    3a7 <main+0x1ff>
    printf(1, "✅ 자식: RR workload 시작\n");
 380:	83 ec 08             	sub    $0x8,%esp
 383:	68 28 0d 00 00       	push   $0xd28
 388:	6a 01                	push   $0x1
 38a:	e8 7e 04 00 00       	call   80d <printf>
 38f:	83 c4 10             	add    $0x10,%esp
    workload(5000000);
 392:	83 ec 0c             	sub    $0xc,%esp
 395:	68 40 4b 4c 00       	push   $0x4c4b40
 39a:	e8 61 fc ff ff       	call   0 <workload>
 39f:	83 c4 10             	add    $0x10,%esp
    exit();
 3a2:	e8 c2 02 00 00       	call   669 <exit>
  } else {
    wait();
 3a7:	e8 c5 02 00 00       	call   671 <wait>
    sleep(100);
 3ac:	83 ec 0c             	sub    $0xc,%esp
 3af:	6a 64                	push   $0x64
 3b1:	e8 43 03 00 00       	call   6f9 <sleep>
 3b6:	83 c4 10             	add    $0x10,%esp
    if (getpinfo(&ps) < 0) {
 3b9:	83 ec 0c             	sub    $0xc,%esp
 3bc:	8d 85 f4 f3 ff ff    	lea    -0xc0c(%ebp),%eax
 3c2:	50                   	push   %eax
 3c3:	e8 51 03 00 00       	call   719 <getpinfo>
 3c8:	83 c4 10             	add    $0x10,%esp
 3cb:	85 c0                	test   %eax,%eax
 3cd:	79 17                	jns    3e6 <main+0x23e>
      printf(1, "❌ getpinfo 실패\n");
 3cf:	83 ec 08             	sub    $0x8,%esp
 3d2:	68 b1 0c 00 00       	push   $0xcb1
 3d7:	6a 01                	push   $0x1
 3d9:	e8 2f 04 00 00       	call   80d <printf>
 3de:	83 c4 10             	add    $0x10,%esp
      exit();
 3e1:	e8 83 02 00 00       	call   669 <exit>
    }
    print_stats(&ps, pid);
 3e6:	83 ec 08             	sub    $0x8,%esp
 3e9:	ff 75 f4             	push   -0xc(%ebp)
 3ec:	8d 85 f4 f3 ff ff    	lea    -0xc0c(%ebp),%eax
 3f2:	50                   	push   %eax
 3f3:	e8 7b fc ff ff       	call   73 <print_stats>
 3f8:	83 c4 10             	add    $0x10,%esp
  }

  printf(1, "✅ 모든 테스트 완료\n");
 3fb:	83 ec 08             	sub    $0x8,%esp
 3fe:	68 48 0d 00 00       	push   $0xd48
 403:	6a 01                	push   $0x1
 405:	e8 03 04 00 00       	call   80d <printf>
 40a:	83 c4 10             	add    $0x10,%esp
  exit();
 40d:	e8 57 02 00 00       	call   669 <exit>

00000412 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 412:	55                   	push   %ebp
 413:	89 e5                	mov    %esp,%ebp
 415:	57                   	push   %edi
 416:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 417:	8b 4d 08             	mov    0x8(%ebp),%ecx
 41a:	8b 55 10             	mov    0x10(%ebp),%edx
 41d:	8b 45 0c             	mov    0xc(%ebp),%eax
 420:	89 cb                	mov    %ecx,%ebx
 422:	89 df                	mov    %ebx,%edi
 424:	89 d1                	mov    %edx,%ecx
 426:	fc                   	cld    
 427:	f3 aa                	rep stos %al,%es:(%edi)
 429:	89 ca                	mov    %ecx,%edx
 42b:	89 fb                	mov    %edi,%ebx
 42d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 430:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 433:	90                   	nop
 434:	5b                   	pop    %ebx
 435:	5f                   	pop    %edi
 436:	5d                   	pop    %ebp
 437:	c3                   	ret    

00000438 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 438:	55                   	push   %ebp
 439:	89 e5                	mov    %esp,%ebp
 43b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 43e:	8b 45 08             	mov    0x8(%ebp),%eax
 441:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 444:	90                   	nop
 445:	8b 55 0c             	mov    0xc(%ebp),%edx
 448:	8d 42 01             	lea    0x1(%edx),%eax
 44b:	89 45 0c             	mov    %eax,0xc(%ebp)
 44e:	8b 45 08             	mov    0x8(%ebp),%eax
 451:	8d 48 01             	lea    0x1(%eax),%ecx
 454:	89 4d 08             	mov    %ecx,0x8(%ebp)
 457:	0f b6 12             	movzbl (%edx),%edx
 45a:	88 10                	mov    %dl,(%eax)
 45c:	0f b6 00             	movzbl (%eax),%eax
 45f:	84 c0                	test   %al,%al
 461:	75 e2                	jne    445 <strcpy+0xd>
    ;
  return os;
 463:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 466:	c9                   	leave  
 467:	c3                   	ret    

00000468 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 468:	55                   	push   %ebp
 469:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 46b:	eb 08                	jmp    475 <strcmp+0xd>
    p++, q++;
 46d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 471:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 475:	8b 45 08             	mov    0x8(%ebp),%eax
 478:	0f b6 00             	movzbl (%eax),%eax
 47b:	84 c0                	test   %al,%al
 47d:	74 10                	je     48f <strcmp+0x27>
 47f:	8b 45 08             	mov    0x8(%ebp),%eax
 482:	0f b6 10             	movzbl (%eax),%edx
 485:	8b 45 0c             	mov    0xc(%ebp),%eax
 488:	0f b6 00             	movzbl (%eax),%eax
 48b:	38 c2                	cmp    %al,%dl
 48d:	74 de                	je     46d <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 48f:	8b 45 08             	mov    0x8(%ebp),%eax
 492:	0f b6 00             	movzbl (%eax),%eax
 495:	0f b6 d0             	movzbl %al,%edx
 498:	8b 45 0c             	mov    0xc(%ebp),%eax
 49b:	0f b6 00             	movzbl (%eax),%eax
 49e:	0f b6 c8             	movzbl %al,%ecx
 4a1:	89 d0                	mov    %edx,%eax
 4a3:	29 c8                	sub    %ecx,%eax
}
 4a5:	5d                   	pop    %ebp
 4a6:	c3                   	ret    

000004a7 <strlen>:

uint
strlen(char *s)
{
 4a7:	55                   	push   %ebp
 4a8:	89 e5                	mov    %esp,%ebp
 4aa:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 4ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 4b4:	eb 04                	jmp    4ba <strlen+0x13>
 4b6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 4ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4bd:	8b 45 08             	mov    0x8(%ebp),%eax
 4c0:	01 d0                	add    %edx,%eax
 4c2:	0f b6 00             	movzbl (%eax),%eax
 4c5:	84 c0                	test   %al,%al
 4c7:	75 ed                	jne    4b6 <strlen+0xf>
    ;
  return n;
 4c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4cc:	c9                   	leave  
 4cd:	c3                   	ret    

000004ce <memset>:

void*
memset(void *dst, int c, uint n)
{
 4ce:	55                   	push   %ebp
 4cf:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 4d1:	8b 45 10             	mov    0x10(%ebp),%eax
 4d4:	50                   	push   %eax
 4d5:	ff 75 0c             	push   0xc(%ebp)
 4d8:	ff 75 08             	push   0x8(%ebp)
 4db:	e8 32 ff ff ff       	call   412 <stosb>
 4e0:	83 c4 0c             	add    $0xc,%esp
  return dst;
 4e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4e6:	c9                   	leave  
 4e7:	c3                   	ret    

000004e8 <strchr>:

char*
strchr(const char *s, char c)
{
 4e8:	55                   	push   %ebp
 4e9:	89 e5                	mov    %esp,%ebp
 4eb:	83 ec 04             	sub    $0x4,%esp
 4ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4f4:	eb 14                	jmp    50a <strchr+0x22>
    if(*s == c)
 4f6:	8b 45 08             	mov    0x8(%ebp),%eax
 4f9:	0f b6 00             	movzbl (%eax),%eax
 4fc:	38 45 fc             	cmp    %al,-0x4(%ebp)
 4ff:	75 05                	jne    506 <strchr+0x1e>
      return (char*)s;
 501:	8b 45 08             	mov    0x8(%ebp),%eax
 504:	eb 13                	jmp    519 <strchr+0x31>
  for(; *s; s++)
 506:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 50a:	8b 45 08             	mov    0x8(%ebp),%eax
 50d:	0f b6 00             	movzbl (%eax),%eax
 510:	84 c0                	test   %al,%al
 512:	75 e2                	jne    4f6 <strchr+0xe>
  return 0;
 514:	b8 00 00 00 00       	mov    $0x0,%eax
}
 519:	c9                   	leave  
 51a:	c3                   	ret    

0000051b <gets>:

char*
gets(char *buf, int max)
{
 51b:	55                   	push   %ebp
 51c:	89 e5                	mov    %esp,%ebp
 51e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 521:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 528:	eb 42                	jmp    56c <gets+0x51>
    cc = read(0, &c, 1);
 52a:	83 ec 04             	sub    $0x4,%esp
 52d:	6a 01                	push   $0x1
 52f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 532:	50                   	push   %eax
 533:	6a 00                	push   $0x0
 535:	e8 47 01 00 00       	call   681 <read>
 53a:	83 c4 10             	add    $0x10,%esp
 53d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 540:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 544:	7e 33                	jle    579 <gets+0x5e>
      break;
    buf[i++] = c;
 546:	8b 45 f4             	mov    -0xc(%ebp),%eax
 549:	8d 50 01             	lea    0x1(%eax),%edx
 54c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 54f:	89 c2                	mov    %eax,%edx
 551:	8b 45 08             	mov    0x8(%ebp),%eax
 554:	01 c2                	add    %eax,%edx
 556:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 55a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 55c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 560:	3c 0a                	cmp    $0xa,%al
 562:	74 16                	je     57a <gets+0x5f>
 564:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 568:	3c 0d                	cmp    $0xd,%al
 56a:	74 0e                	je     57a <gets+0x5f>
  for(i=0; i+1 < max; ){
 56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56f:	83 c0 01             	add    $0x1,%eax
 572:	39 45 0c             	cmp    %eax,0xc(%ebp)
 575:	7f b3                	jg     52a <gets+0xf>
 577:	eb 01                	jmp    57a <gets+0x5f>
      break;
 579:	90                   	nop
      break;
  }
  buf[i] = '\0';
 57a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 57d:	8b 45 08             	mov    0x8(%ebp),%eax
 580:	01 d0                	add    %edx,%eax
 582:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 585:	8b 45 08             	mov    0x8(%ebp),%eax
}
 588:	c9                   	leave  
 589:	c3                   	ret    

0000058a <stat>:

int
stat(char *n, struct stat *st)
{
 58a:	55                   	push   %ebp
 58b:	89 e5                	mov    %esp,%ebp
 58d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 590:	83 ec 08             	sub    $0x8,%esp
 593:	6a 00                	push   $0x0
 595:	ff 75 08             	push   0x8(%ebp)
 598:	e8 0c 01 00 00       	call   6a9 <open>
 59d:	83 c4 10             	add    $0x10,%esp
 5a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 5a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a7:	79 07                	jns    5b0 <stat+0x26>
    return -1;
 5a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5ae:	eb 25                	jmp    5d5 <stat+0x4b>
  r = fstat(fd, st);
 5b0:	83 ec 08             	sub    $0x8,%esp
 5b3:	ff 75 0c             	push   0xc(%ebp)
 5b6:	ff 75 f4             	push   -0xc(%ebp)
 5b9:	e8 03 01 00 00       	call   6c1 <fstat>
 5be:	83 c4 10             	add    $0x10,%esp
 5c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 5c4:	83 ec 0c             	sub    $0xc,%esp
 5c7:	ff 75 f4             	push   -0xc(%ebp)
 5ca:	e8 c2 00 00 00       	call   691 <close>
 5cf:	83 c4 10             	add    $0x10,%esp
  return r;
 5d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5d5:	c9                   	leave  
 5d6:	c3                   	ret    

000005d7 <atoi>:

int
atoi(const char *s)
{
 5d7:	55                   	push   %ebp
 5d8:	89 e5                	mov    %esp,%ebp
 5da:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 5dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5e4:	eb 25                	jmp    60b <atoi+0x34>
    n = n*10 + *s++ - '0';
 5e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5e9:	89 d0                	mov    %edx,%eax
 5eb:	c1 e0 02             	shl    $0x2,%eax
 5ee:	01 d0                	add    %edx,%eax
 5f0:	01 c0                	add    %eax,%eax
 5f2:	89 c1                	mov    %eax,%ecx
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	8d 50 01             	lea    0x1(%eax),%edx
 5fa:	89 55 08             	mov    %edx,0x8(%ebp)
 5fd:	0f b6 00             	movzbl (%eax),%eax
 600:	0f be c0             	movsbl %al,%eax
 603:	01 c8                	add    %ecx,%eax
 605:	83 e8 30             	sub    $0x30,%eax
 608:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 60b:	8b 45 08             	mov    0x8(%ebp),%eax
 60e:	0f b6 00             	movzbl (%eax),%eax
 611:	3c 2f                	cmp    $0x2f,%al
 613:	7e 0a                	jle    61f <atoi+0x48>
 615:	8b 45 08             	mov    0x8(%ebp),%eax
 618:	0f b6 00             	movzbl (%eax),%eax
 61b:	3c 39                	cmp    $0x39,%al
 61d:	7e c7                	jle    5e6 <atoi+0xf>
  return n;
 61f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 622:	c9                   	leave  
 623:	c3                   	ret    

00000624 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
 627:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 62a:	8b 45 08             	mov    0x8(%ebp),%eax
 62d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 630:	8b 45 0c             	mov    0xc(%ebp),%eax
 633:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 636:	eb 17                	jmp    64f <memmove+0x2b>
    *dst++ = *src++;
 638:	8b 55 f8             	mov    -0x8(%ebp),%edx
 63b:	8d 42 01             	lea    0x1(%edx),%eax
 63e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 641:	8b 45 fc             	mov    -0x4(%ebp),%eax
 644:	8d 48 01             	lea    0x1(%eax),%ecx
 647:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 64a:	0f b6 12             	movzbl (%edx),%edx
 64d:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 64f:	8b 45 10             	mov    0x10(%ebp),%eax
 652:	8d 50 ff             	lea    -0x1(%eax),%edx
 655:	89 55 10             	mov    %edx,0x10(%ebp)
 658:	85 c0                	test   %eax,%eax
 65a:	7f dc                	jg     638 <memmove+0x14>
  return vdst;
 65c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 65f:	c9                   	leave  
 660:	c3                   	ret    

00000661 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 661:	b8 01 00 00 00       	mov    $0x1,%eax
 666:	cd 40                	int    $0x40
 668:	c3                   	ret    

00000669 <exit>:
SYSCALL(exit)
 669:	b8 02 00 00 00       	mov    $0x2,%eax
 66e:	cd 40                	int    $0x40
 670:	c3                   	ret    

00000671 <wait>:
SYSCALL(wait)
 671:	b8 03 00 00 00       	mov    $0x3,%eax
 676:	cd 40                	int    $0x40
 678:	c3                   	ret    

00000679 <pipe>:
SYSCALL(pipe)
 679:	b8 04 00 00 00       	mov    $0x4,%eax
 67e:	cd 40                	int    $0x40
 680:	c3                   	ret    

00000681 <read>:
SYSCALL(read)
 681:	b8 05 00 00 00       	mov    $0x5,%eax
 686:	cd 40                	int    $0x40
 688:	c3                   	ret    

00000689 <write>:
SYSCALL(write)
 689:	b8 10 00 00 00       	mov    $0x10,%eax
 68e:	cd 40                	int    $0x40
 690:	c3                   	ret    

00000691 <close>:
SYSCALL(close)
 691:	b8 15 00 00 00       	mov    $0x15,%eax
 696:	cd 40                	int    $0x40
 698:	c3                   	ret    

00000699 <kill>:
SYSCALL(kill)
 699:	b8 06 00 00 00       	mov    $0x6,%eax
 69e:	cd 40                	int    $0x40
 6a0:	c3                   	ret    

000006a1 <exec>:
SYSCALL(exec)
 6a1:	b8 07 00 00 00       	mov    $0x7,%eax
 6a6:	cd 40                	int    $0x40
 6a8:	c3                   	ret    

000006a9 <open>:
SYSCALL(open)
 6a9:	b8 0f 00 00 00       	mov    $0xf,%eax
 6ae:	cd 40                	int    $0x40
 6b0:	c3                   	ret    

000006b1 <mknod>:
SYSCALL(mknod)
 6b1:	b8 11 00 00 00       	mov    $0x11,%eax
 6b6:	cd 40                	int    $0x40
 6b8:	c3                   	ret    

000006b9 <unlink>:
SYSCALL(unlink)
 6b9:	b8 12 00 00 00       	mov    $0x12,%eax
 6be:	cd 40                	int    $0x40
 6c0:	c3                   	ret    

000006c1 <fstat>:
SYSCALL(fstat)
 6c1:	b8 08 00 00 00       	mov    $0x8,%eax
 6c6:	cd 40                	int    $0x40
 6c8:	c3                   	ret    

000006c9 <link>:
SYSCALL(link)
 6c9:	b8 13 00 00 00       	mov    $0x13,%eax
 6ce:	cd 40                	int    $0x40
 6d0:	c3                   	ret    

000006d1 <mkdir>:
SYSCALL(mkdir)
 6d1:	b8 14 00 00 00       	mov    $0x14,%eax
 6d6:	cd 40                	int    $0x40
 6d8:	c3                   	ret    

000006d9 <chdir>:
SYSCALL(chdir)
 6d9:	b8 09 00 00 00       	mov    $0x9,%eax
 6de:	cd 40                	int    $0x40
 6e0:	c3                   	ret    

000006e1 <dup>:
SYSCALL(dup)
 6e1:	b8 0a 00 00 00       	mov    $0xa,%eax
 6e6:	cd 40                	int    $0x40
 6e8:	c3                   	ret    

000006e9 <getpid>:
SYSCALL(getpid)
 6e9:	b8 0b 00 00 00       	mov    $0xb,%eax
 6ee:	cd 40                	int    $0x40
 6f0:	c3                   	ret    

000006f1 <sbrk>:
SYSCALL(sbrk)
 6f1:	b8 0c 00 00 00       	mov    $0xc,%eax
 6f6:	cd 40                	int    $0x40
 6f8:	c3                   	ret    

000006f9 <sleep>:
SYSCALL(sleep)
 6f9:	b8 0d 00 00 00       	mov    $0xd,%eax
 6fe:	cd 40                	int    $0x40
 700:	c3                   	ret    

00000701 <uptime>:
SYSCALL(uptime)
 701:	b8 0e 00 00 00       	mov    $0xe,%eax
 706:	cd 40                	int    $0x40
 708:	c3                   	ret    

00000709 <uthread_init>:

SYSCALL(uthread_init)
 709:	b8 16 00 00 00       	mov    $0x16,%eax
 70e:	cd 40                	int    $0x40
 710:	c3                   	ret    

00000711 <check_thread>:
SYSCALL(check_thread)
 711:	b8 17 00 00 00       	mov    $0x17,%eax
 716:	cd 40                	int    $0x40
 718:	c3                   	ret    

00000719 <getpinfo>:

SYSCALL(getpinfo)
 719:	b8 18 00 00 00       	mov    $0x18,%eax
 71e:	cd 40                	int    $0x40
 720:	c3                   	ret    

00000721 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 721:	b8 19 00 00 00       	mov    $0x19,%eax
 726:	cd 40                	int    $0x40
 728:	c3                   	ret    

00000729 <yield>:
SYSCALL(yield)
 729:	b8 1a 00 00 00       	mov    $0x1a,%eax
 72e:	cd 40                	int    $0x40
 730:	c3                   	ret    

00000731 <printpt>:

 731:	b8 1b 00 00 00       	mov    $0x1b,%eax
 736:	cd 40                	int    $0x40
 738:	c3                   	ret    

00000739 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 739:	55                   	push   %ebp
 73a:	89 e5                	mov    %esp,%ebp
 73c:	83 ec 18             	sub    $0x18,%esp
 73f:	8b 45 0c             	mov    0xc(%ebp),%eax
 742:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 745:	83 ec 04             	sub    $0x4,%esp
 748:	6a 01                	push   $0x1
 74a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 74d:	50                   	push   %eax
 74e:	ff 75 08             	push   0x8(%ebp)
 751:	e8 33 ff ff ff       	call   689 <write>
 756:	83 c4 10             	add    $0x10,%esp
}
 759:	90                   	nop
 75a:	c9                   	leave  
 75b:	c3                   	ret    

0000075c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 75c:	55                   	push   %ebp
 75d:	89 e5                	mov    %esp,%ebp
 75f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 762:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 769:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 76d:	74 17                	je     786 <printint+0x2a>
 76f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 773:	79 11                	jns    786 <printint+0x2a>
    neg = 1;
 775:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 77c:	8b 45 0c             	mov    0xc(%ebp),%eax
 77f:	f7 d8                	neg    %eax
 781:	89 45 ec             	mov    %eax,-0x14(%ebp)
 784:	eb 06                	jmp    78c <printint+0x30>
  } else {
    x = xx;
 786:	8b 45 0c             	mov    0xc(%ebp),%eax
 789:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 78c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 793:	8b 4d 10             	mov    0x10(%ebp),%ecx
 796:	8b 45 ec             	mov    -0x14(%ebp),%eax
 799:	ba 00 00 00 00       	mov    $0x0,%edx
 79e:	f7 f1                	div    %ecx
 7a0:	89 d1                	mov    %edx,%ecx
 7a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a5:	8d 50 01             	lea    0x1(%eax),%edx
 7a8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7ab:	0f b6 91 1c 10 00 00 	movzbl 0x101c(%ecx),%edx
 7b2:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 7b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 7b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7bc:	ba 00 00 00 00       	mov    $0x0,%edx
 7c1:	f7 f1                	div    %ecx
 7c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7c6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7ca:	75 c7                	jne    793 <printint+0x37>
  if(neg)
 7cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7d0:	74 2d                	je     7ff <printint+0xa3>
    buf[i++] = '-';
 7d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d5:	8d 50 01             	lea    0x1(%eax),%edx
 7d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7db:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7e0:	eb 1d                	jmp    7ff <printint+0xa3>
    putc(fd, buf[i]);
 7e2:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	01 d0                	add    %edx,%eax
 7ea:	0f b6 00             	movzbl (%eax),%eax
 7ed:	0f be c0             	movsbl %al,%eax
 7f0:	83 ec 08             	sub    $0x8,%esp
 7f3:	50                   	push   %eax
 7f4:	ff 75 08             	push   0x8(%ebp)
 7f7:	e8 3d ff ff ff       	call   739 <putc>
 7fc:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 7ff:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 803:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 807:	79 d9                	jns    7e2 <printint+0x86>
}
 809:	90                   	nop
 80a:	90                   	nop
 80b:	c9                   	leave  
 80c:	c3                   	ret    

0000080d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 80d:	55                   	push   %ebp
 80e:	89 e5                	mov    %esp,%ebp
 810:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 813:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 81a:	8d 45 0c             	lea    0xc(%ebp),%eax
 81d:	83 c0 04             	add    $0x4,%eax
 820:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 823:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 82a:	e9 59 01 00 00       	jmp    988 <printf+0x17b>
    c = fmt[i] & 0xff;
 82f:	8b 55 0c             	mov    0xc(%ebp),%edx
 832:	8b 45 f0             	mov    -0x10(%ebp),%eax
 835:	01 d0                	add    %edx,%eax
 837:	0f b6 00             	movzbl (%eax),%eax
 83a:	0f be c0             	movsbl %al,%eax
 83d:	25 ff 00 00 00       	and    $0xff,%eax
 842:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 845:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 849:	75 2c                	jne    877 <printf+0x6a>
      if(c == '%'){
 84b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 84f:	75 0c                	jne    85d <printf+0x50>
        state = '%';
 851:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 858:	e9 27 01 00 00       	jmp    984 <printf+0x177>
      } else {
        putc(fd, c);
 85d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 860:	0f be c0             	movsbl %al,%eax
 863:	83 ec 08             	sub    $0x8,%esp
 866:	50                   	push   %eax
 867:	ff 75 08             	push   0x8(%ebp)
 86a:	e8 ca fe ff ff       	call   739 <putc>
 86f:	83 c4 10             	add    $0x10,%esp
 872:	e9 0d 01 00 00       	jmp    984 <printf+0x177>
      }
    } else if(state == '%'){
 877:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 87b:	0f 85 03 01 00 00    	jne    984 <printf+0x177>
      if(c == 'd'){
 881:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 885:	75 1e                	jne    8a5 <printf+0x98>
        printint(fd, *ap, 10, 1);
 887:	8b 45 e8             	mov    -0x18(%ebp),%eax
 88a:	8b 00                	mov    (%eax),%eax
 88c:	6a 01                	push   $0x1
 88e:	6a 0a                	push   $0xa
 890:	50                   	push   %eax
 891:	ff 75 08             	push   0x8(%ebp)
 894:	e8 c3 fe ff ff       	call   75c <printint>
 899:	83 c4 10             	add    $0x10,%esp
        ap++;
 89c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8a0:	e9 d8 00 00 00       	jmp    97d <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 8a5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8a9:	74 06                	je     8b1 <printf+0xa4>
 8ab:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8af:	75 1e                	jne    8cf <printf+0xc2>
        printint(fd, *ap, 16, 0);
 8b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8b4:	8b 00                	mov    (%eax),%eax
 8b6:	6a 00                	push   $0x0
 8b8:	6a 10                	push   $0x10
 8ba:	50                   	push   %eax
 8bb:	ff 75 08             	push   0x8(%ebp)
 8be:	e8 99 fe ff ff       	call   75c <printint>
 8c3:	83 c4 10             	add    $0x10,%esp
        ap++;
 8c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8ca:	e9 ae 00 00 00       	jmp    97d <printf+0x170>
      } else if(c == 's'){
 8cf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8d3:	75 43                	jne    918 <printf+0x10b>
        s = (char*)*ap;
 8d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8d8:	8b 00                	mov    (%eax),%eax
 8da:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e5:	75 25                	jne    90c <printf+0xff>
          s = "(null)";
 8e7:	c7 45 f4 65 0d 00 00 	movl   $0xd65,-0xc(%ebp)
        while(*s != 0){
 8ee:	eb 1c                	jmp    90c <printf+0xff>
          putc(fd, *s);
 8f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f3:	0f b6 00             	movzbl (%eax),%eax
 8f6:	0f be c0             	movsbl %al,%eax
 8f9:	83 ec 08             	sub    $0x8,%esp
 8fc:	50                   	push   %eax
 8fd:	ff 75 08             	push   0x8(%ebp)
 900:	e8 34 fe ff ff       	call   739 <putc>
 905:	83 c4 10             	add    $0x10,%esp
          s++;
 908:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 90c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90f:	0f b6 00             	movzbl (%eax),%eax
 912:	84 c0                	test   %al,%al
 914:	75 da                	jne    8f0 <printf+0xe3>
 916:	eb 65                	jmp    97d <printf+0x170>
        }
      } else if(c == 'c'){
 918:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 91c:	75 1d                	jne    93b <printf+0x12e>
        putc(fd, *ap);
 91e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 921:	8b 00                	mov    (%eax),%eax
 923:	0f be c0             	movsbl %al,%eax
 926:	83 ec 08             	sub    $0x8,%esp
 929:	50                   	push   %eax
 92a:	ff 75 08             	push   0x8(%ebp)
 92d:	e8 07 fe ff ff       	call   739 <putc>
 932:	83 c4 10             	add    $0x10,%esp
        ap++;
 935:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 939:	eb 42                	jmp    97d <printf+0x170>
      } else if(c == '%'){
 93b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 93f:	75 17                	jne    958 <printf+0x14b>
        putc(fd, c);
 941:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 944:	0f be c0             	movsbl %al,%eax
 947:	83 ec 08             	sub    $0x8,%esp
 94a:	50                   	push   %eax
 94b:	ff 75 08             	push   0x8(%ebp)
 94e:	e8 e6 fd ff ff       	call   739 <putc>
 953:	83 c4 10             	add    $0x10,%esp
 956:	eb 25                	jmp    97d <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 958:	83 ec 08             	sub    $0x8,%esp
 95b:	6a 25                	push   $0x25
 95d:	ff 75 08             	push   0x8(%ebp)
 960:	e8 d4 fd ff ff       	call   739 <putc>
 965:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 968:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 96b:	0f be c0             	movsbl %al,%eax
 96e:	83 ec 08             	sub    $0x8,%esp
 971:	50                   	push   %eax
 972:	ff 75 08             	push   0x8(%ebp)
 975:	e8 bf fd ff ff       	call   739 <putc>
 97a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 97d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 984:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 988:	8b 55 0c             	mov    0xc(%ebp),%edx
 98b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98e:	01 d0                	add    %edx,%eax
 990:	0f b6 00             	movzbl (%eax),%eax
 993:	84 c0                	test   %al,%al
 995:	0f 85 94 fe ff ff    	jne    82f <printf+0x22>
    }
  }
}
 99b:	90                   	nop
 99c:	90                   	nop
 99d:	c9                   	leave  
 99e:	c3                   	ret    

0000099f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 99f:	55                   	push   %ebp
 9a0:	89 e5                	mov    %esp,%ebp
 9a2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9a5:	8b 45 08             	mov    0x8(%ebp),%eax
 9a8:	83 e8 08             	sub    $0x8,%eax
 9ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ae:	a1 38 10 00 00       	mov    0x1038,%eax
 9b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9b6:	eb 24                	jmp    9dc <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bb:	8b 00                	mov    (%eax),%eax
 9bd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 9c0:	72 12                	jb     9d4 <free+0x35>
 9c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9c8:	77 24                	ja     9ee <free+0x4f>
 9ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cd:	8b 00                	mov    (%eax),%eax
 9cf:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9d2:	72 1a                	jb     9ee <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d7:	8b 00                	mov    (%eax),%eax
 9d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9df:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9e2:	76 d4                	jbe    9b8 <free+0x19>
 9e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e7:	8b 00                	mov    (%eax),%eax
 9e9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9ec:	73 ca                	jae    9b8 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f1:	8b 40 04             	mov    0x4(%eax),%eax
 9f4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9fe:	01 c2                	add    %eax,%edx
 a00:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a03:	8b 00                	mov    (%eax),%eax
 a05:	39 c2                	cmp    %eax,%edx
 a07:	75 24                	jne    a2d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a09:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0c:	8b 50 04             	mov    0x4(%eax),%edx
 a0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a12:	8b 00                	mov    (%eax),%eax
 a14:	8b 40 04             	mov    0x4(%eax),%eax
 a17:	01 c2                	add    %eax,%edx
 a19:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a1c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a22:	8b 00                	mov    (%eax),%eax
 a24:	8b 10                	mov    (%eax),%edx
 a26:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a29:	89 10                	mov    %edx,(%eax)
 a2b:	eb 0a                	jmp    a37 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a30:	8b 10                	mov    (%eax),%edx
 a32:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a35:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a37:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3a:	8b 40 04             	mov    0x4(%eax),%eax
 a3d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a44:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a47:	01 d0                	add    %edx,%eax
 a49:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a4c:	75 20                	jne    a6e <free+0xcf>
    p->s.size += bp->s.size;
 a4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a51:	8b 50 04             	mov    0x4(%eax),%edx
 a54:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a57:	8b 40 04             	mov    0x4(%eax),%eax
 a5a:	01 c2                	add    %eax,%edx
 a5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a62:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a65:	8b 10                	mov    (%eax),%edx
 a67:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a6a:	89 10                	mov    %edx,(%eax)
 a6c:	eb 08                	jmp    a76 <free+0xd7>
  } else
    p->s.ptr = bp;
 a6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a71:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a74:	89 10                	mov    %edx,(%eax)
  freep = p;
 a76:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a79:	a3 38 10 00 00       	mov    %eax,0x1038
}
 a7e:	90                   	nop
 a7f:	c9                   	leave  
 a80:	c3                   	ret    

00000a81 <morecore>:

static Header*
morecore(uint nu)
{
 a81:	55                   	push   %ebp
 a82:	89 e5                	mov    %esp,%ebp
 a84:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a87:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a8e:	77 07                	ja     a97 <morecore+0x16>
    nu = 4096;
 a90:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a97:	8b 45 08             	mov    0x8(%ebp),%eax
 a9a:	c1 e0 03             	shl    $0x3,%eax
 a9d:	83 ec 0c             	sub    $0xc,%esp
 aa0:	50                   	push   %eax
 aa1:	e8 4b fc ff ff       	call   6f1 <sbrk>
 aa6:	83 c4 10             	add    $0x10,%esp
 aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 aac:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ab0:	75 07                	jne    ab9 <morecore+0x38>
    return 0;
 ab2:	b8 00 00 00 00       	mov    $0x0,%eax
 ab7:	eb 26                	jmp    adf <morecore+0x5e>
  hp = (Header*)p;
 ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac2:	8b 55 08             	mov    0x8(%ebp),%edx
 ac5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 acb:	83 c0 08             	add    $0x8,%eax
 ace:	83 ec 0c             	sub    $0xc,%esp
 ad1:	50                   	push   %eax
 ad2:	e8 c8 fe ff ff       	call   99f <free>
 ad7:	83 c4 10             	add    $0x10,%esp
  return freep;
 ada:	a1 38 10 00 00       	mov    0x1038,%eax
}
 adf:	c9                   	leave  
 ae0:	c3                   	ret    

00000ae1 <malloc>:

void*
malloc(uint nbytes)
{
 ae1:	55                   	push   %ebp
 ae2:	89 e5                	mov    %esp,%ebp
 ae4:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ae7:	8b 45 08             	mov    0x8(%ebp),%eax
 aea:	83 c0 07             	add    $0x7,%eax
 aed:	c1 e8 03             	shr    $0x3,%eax
 af0:	83 c0 01             	add    $0x1,%eax
 af3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 af6:	a1 38 10 00 00       	mov    0x1038,%eax
 afb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 afe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b02:	75 23                	jne    b27 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b04:	c7 45 f0 30 10 00 00 	movl   $0x1030,-0x10(%ebp)
 b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b0e:	a3 38 10 00 00       	mov    %eax,0x1038
 b13:	a1 38 10 00 00       	mov    0x1038,%eax
 b18:	a3 30 10 00 00       	mov    %eax,0x1030
    base.s.size = 0;
 b1d:	c7 05 34 10 00 00 00 	movl   $0x0,0x1034
 b24:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b2a:	8b 00                	mov    (%eax),%eax
 b2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b32:	8b 40 04             	mov    0x4(%eax),%eax
 b35:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b38:	77 4d                	ja     b87 <malloc+0xa6>
      if(p->s.size == nunits)
 b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3d:	8b 40 04             	mov    0x4(%eax),%eax
 b40:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b43:	75 0c                	jne    b51 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b48:	8b 10                	mov    (%eax),%edx
 b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b4d:	89 10                	mov    %edx,(%eax)
 b4f:	eb 26                	jmp    b77 <malloc+0x96>
      else {
        p->s.size -= nunits;
 b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b54:	8b 40 04             	mov    0x4(%eax),%eax
 b57:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b5a:	89 c2                	mov    %eax,%edx
 b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b65:	8b 40 04             	mov    0x4(%eax),%eax
 b68:	c1 e0 03             	shl    $0x3,%eax
 b6b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b71:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b74:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b7a:	a3 38 10 00 00       	mov    %eax,0x1038
      return (void*)(p + 1);
 b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b82:	83 c0 08             	add    $0x8,%eax
 b85:	eb 3b                	jmp    bc2 <malloc+0xe1>
    }
    if(p == freep)
 b87:	a1 38 10 00 00       	mov    0x1038,%eax
 b8c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b8f:	75 1e                	jne    baf <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b91:	83 ec 0c             	sub    $0xc,%esp
 b94:	ff 75 ec             	push   -0x14(%ebp)
 b97:	e8 e5 fe ff ff       	call   a81 <morecore>
 b9c:	83 c4 10             	add    $0x10,%esp
 b9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ba2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ba6:	75 07                	jne    baf <malloc+0xce>
        return 0;
 ba8:	b8 00 00 00 00       	mov    $0x0,%eax
 bad:	eb 13                	jmp    bc2 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb8:	8b 00                	mov    (%eax),%eax
 bba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bbd:	e9 6d ff ff ff       	jmp    b2f <malloc+0x4e>
  }
}
 bc2:	c9                   	leave  
 bc3:	c3                   	ret    
