
_mlfq3:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "user.h"
#include "pstat.h"

struct pstat global_st;

int workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++)
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 11                	jmp    27 <workload+0x27>
    j = j * i + 1;
  16:	8b 45 f8             	mov    -0x8(%ebp),%eax
  19:	0f af 45 fc          	imul   -0x4(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++)
  23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	7c e7                	jl     16 <workload+0x16>
  return j;
  2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  32:	c9                   	leave  
  33:	c3                   	ret    

00000034 <is_child>:

int is_child(int pid, int *child_pid, int count) {
  34:	55                   	push   %ebp
  35:	89 e5                	mov    %esp,%ebp
  37:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < count; i++) {
  3a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  41:	eb 21                	jmp    64 <is_child+0x30>
    if (child_pid[i] == pid)
  43:	8b 45 fc             	mov    -0x4(%ebp),%eax
  46:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  50:	01 d0                	add    %edx,%eax
  52:	8b 00                	mov    (%eax),%eax
  54:	39 45 08             	cmp    %eax,0x8(%ebp)
  57:	75 07                	jne    60 <is_child+0x2c>
      return 1;
  59:	b8 01 00 00 00       	mov    $0x1,%eax
  5e:	eb 11                	jmp    71 <is_child+0x3d>
  for (int i = 0; i < count; i++) {
  60:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  64:	8b 45 fc             	mov    -0x4(%ebp),%eax
  67:	3b 45 10             	cmp    0x10(%ebp),%eax
  6a:	7c d7                	jl     43 <is_child+0xf>
  }
  return 0;
  6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  71:	c9                   	leave  
  72:	c3                   	ret    

00000073 <print_proc_info>:

void print_proc_info(struct pstat *st, int *child_pid, int count, const char *title) {
  73:	55                   	push   %ebp
  74:	89 e5                	mov    %esp,%ebp
  76:	56                   	push   %esi
  77:	53                   	push   %ebx
  78:	83 ec 20             	sub    $0x20,%esp
  int wait_times[4] = {500, 320, 160, 80};
  7b:	c7 45 e0 f4 01 00 00 	movl   $0x1f4,-0x20(%ebp)
  82:	c7 45 e4 40 01 00 00 	movl   $0x140,-0x1c(%ebp)
  89:	c7 45 e8 a0 00 00 00 	movl   $0xa0,-0x18(%ebp)
  90:	c7 45 ec 50 00 00 00 	movl   $0x50,-0x14(%ebp)

  printf(1, "\n[ %s ] ----------------------------\n", title);
  97:	83 ec 04             	sub    $0x4,%esp
  9a:	ff 75 14             	push   0x14(%ebp)
  9d:	68 5c 0e 00 00       	push   $0xe5c
  a2:	6a 01                	push   $0x1
  a4:	e8 fc 09 00 00       	call   aa5 <printf>
  a9:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  b3:	e9 b8 01 00 00       	jmp    270 <print_proc_info+0x1fd>
    if (!st->inuse[i]) continue;
  b8:	8b 45 08             	mov    0x8(%ebp),%eax
  bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  be:	8b 04 90             	mov    (%eax,%edx,4),%eax
  c1:	85 c0                	test   %eax,%eax
  c3:	0f 84 9f 01 00 00    	je     268 <print_proc_info+0x1f5>
    if (!is_child(st->pid[i], child_pid, count)) continue;
  c9:	8b 45 08             	mov    0x8(%ebp),%eax
  cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  cf:	83 c2 40             	add    $0x40,%edx
  d2:	8b 04 90             	mov    (%eax,%edx,4),%eax
  d5:	83 ec 04             	sub    $0x4,%esp
  d8:	ff 75 10             	push   0x10(%ebp)
  db:	ff 75 0c             	push   0xc(%ebp)
  de:	50                   	push   %eax
  df:	e8 50 ff ff ff       	call   34 <is_child>
  e4:	83 c4 10             	add    $0x10,%esp
  e7:	85 c0                	test   %eax,%eax
  e9:	0f 84 7c 01 00 00    	je     26b <print_proc_info+0x1f8>

    printf(1, "pid %d | priority %d\n", st->pid[i], st->priority[i]);
  ef:	8b 45 08             	mov    0x8(%ebp),%eax
  f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  f5:	83 ea 80             	sub    $0xffffff80,%edx
  f8:	8b 14 90             	mov    (%eax,%edx,4),%edx
  fb:	8b 45 08             	mov    0x8(%ebp),%eax
  fe:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 101:	83 c1 40             	add    $0x40,%ecx
 104:	8b 04 88             	mov    (%eax,%ecx,4),%eax
 107:	52                   	push   %edx
 108:	50                   	push   %eax
 109:	68 82 0e 00 00       	push   $0xe82
 10e:	6a 01                	push   $0x1
 110:	e8 90 09 00 00       	call   aa5 <printf>
 115:	83 c4 10             	add    $0x10,%esp
    printf(1, "  ticks:      [%d %d %d %d]\n",
 118:	8b 55 08             	mov    0x8(%ebp),%edx
 11b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 11e:	c1 e0 04             	shl    $0x4,%eax
 121:	01 d0                	add    %edx,%eax
 123:	05 0c 04 00 00       	add    $0x40c,%eax
 128:	8b 18                	mov    (%eax),%ebx
 12a:	8b 55 08             	mov    0x8(%ebp),%edx
 12d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 130:	c1 e0 04             	shl    $0x4,%eax
 133:	01 d0                	add    %edx,%eax
 135:	05 08 04 00 00       	add    $0x408,%eax
 13a:	8b 08                	mov    (%eax),%ecx
 13c:	8b 55 08             	mov    0x8(%ebp),%edx
 13f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 142:	c1 e0 04             	shl    $0x4,%eax
 145:	01 d0                	add    %edx,%eax
 147:	05 04 04 00 00       	add    $0x404,%eax
 14c:	8b 10                	mov    (%eax),%edx
 14e:	8b 75 08             	mov    0x8(%ebp),%esi
 151:	8b 45 f4             	mov    -0xc(%ebp),%eax
 154:	83 c0 40             	add    $0x40,%eax
 157:	c1 e0 04             	shl    $0x4,%eax
 15a:	01 f0                	add    %esi,%eax
 15c:	8b 00                	mov    (%eax),%eax
 15e:	83 ec 08             	sub    $0x8,%esp
 161:	53                   	push   %ebx
 162:	51                   	push   %ecx
 163:	52                   	push   %edx
 164:	50                   	push   %eax
 165:	68 98 0e 00 00       	push   $0xe98
 16a:	6a 01                	push   $0x1
 16c:	e8 34 09 00 00       	call   aa5 <printf>
 171:	83 c4 20             	add    $0x20,%esp
           st->ticks[i][0], st->ticks[i][1], st->ticks[i][2], st->ticks[i][3]);
    printf(1, "  wait_ticks: [%d %d %d %d]\n",
 174:	8b 55 08             	mov    0x8(%ebp),%edx
 177:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17a:	c1 e0 04             	shl    $0x4,%eax
 17d:	01 d0                	add    %edx,%eax
 17f:	05 0c 08 00 00       	add    $0x80c,%eax
 184:	8b 18                	mov    (%eax),%ebx
 186:	8b 55 08             	mov    0x8(%ebp),%edx
 189:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18c:	c1 e0 04             	shl    $0x4,%eax
 18f:	01 d0                	add    %edx,%eax
 191:	05 08 08 00 00       	add    $0x808,%eax
 196:	8b 08                	mov    (%eax),%ecx
 198:	8b 55 08             	mov    0x8(%ebp),%edx
 19b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19e:	c1 e0 04             	shl    $0x4,%eax
 1a1:	01 d0                	add    %edx,%eax
 1a3:	05 04 08 00 00       	add    $0x804,%eax
 1a8:	8b 10                	mov    (%eax),%edx
 1aa:	8b 75 08             	mov    0x8(%ebp),%esi
 1ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b0:	83 e8 80             	sub    $0xffffff80,%eax
 1b3:	c1 e0 04             	shl    $0x4,%eax
 1b6:	01 f0                	add    %esi,%eax
 1b8:	8b 00                	mov    (%eax),%eax
 1ba:	83 ec 08             	sub    $0x8,%esp
 1bd:	53                   	push   %ebx
 1be:	51                   	push   %ecx
 1bf:	52                   	push   %edx
 1c0:	50                   	push   %eax
 1c1:	68 b5 0e 00 00       	push   $0xeb5
 1c6:	6a 01                	push   $0x1
 1c8:	e8 d8 08 00 00       	call   aa5 <printf>
 1cd:	83 c4 20             	add    $0x20,%esp
           st->wait_ticks[i][0], st->wait_ticks[i][1], st->wait_ticks[i][2], st->wait_ticks[i][3]);

    for (int q = 0; q < 4; q++) {
 1d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 1d7:	eb 44                	jmp    21d <print_proc_info+0x1aa>
      if (st->wait_ticks[i][q] >= wait_times[q]) {
 1d9:	8b 45 08             	mov    0x8(%ebp),%eax
 1dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1df:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
 1e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
 1e9:	01 ca                	add    %ecx,%edx
 1eb:	81 c2 00 02 00 00    	add    $0x200,%edx
 1f1:	8b 14 90             	mov    (%eax,%edx,4),%edx
 1f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1f7:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 1fb:	39 c2                	cmp    %eax,%edx
 1fd:	7c 1a                	jl     219 <print_proc_info+0x1a6>
        printf(1, "  boost condition met: wait_ticks[%d] >= %d (ignored in policy 3)\n", q, wait_times[q]);
 1ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 202:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 206:	50                   	push   %eax
 207:	ff 75 f0             	push   -0x10(%ebp)
 20a:	68 d4 0e 00 00       	push   $0xed4
 20f:	6a 01                	push   $0x1
 211:	e8 8f 08 00 00       	call   aa5 <printf>
 216:	83 c4 10             	add    $0x10,%esp
    for (int q = 0; q < 4; q++) {
 219:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 21d:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 221:	7e b6                	jle    1d9 <print_proc_info+0x166>
      }
    }

    if (st->priority[i] == 0 && st->ticks[i][0] > 0)
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	8b 55 f4             	mov    -0xc(%ebp),%edx
 229:	83 ea 80             	sub    $0xffffff80,%edx
 22c:	8b 04 90             	mov    (%eax,%edx,4),%eax
 22f:	85 c0                	test   %eax,%eax
 231:	75 39                	jne    26c <print_proc_info+0x1f9>
 233:	8b 55 08             	mov    0x8(%ebp),%edx
 236:	8b 45 f4             	mov    -0xc(%ebp),%eax
 239:	83 c0 40             	add    $0x40,%eax
 23c:	c1 e0 04             	shl    $0x4,%eax
 23f:	01 d0                	add    %edx,%eax
 241:	8b 00                	mov    (%eax),%eax
 243:	85 c0                	test   %eax,%eax
 245:	7e 25                	jle    26c <print_proc_info+0x1f9>
      printf(1, "  pid %d demoted to Q0\n", st->pid[i]);
 247:	8b 45 08             	mov    0x8(%ebp),%eax
 24a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 24d:	83 c2 40             	add    $0x40,%edx
 250:	8b 04 90             	mov    (%eax,%edx,4),%eax
 253:	83 ec 04             	sub    $0x4,%esp
 256:	50                   	push   %eax
 257:	68 17 0f 00 00       	push   $0xf17
 25c:	6a 01                	push   $0x1
 25e:	e8 42 08 00 00       	call   aa5 <printf>
 263:	83 c4 10             	add    $0x10,%esp
 266:	eb 04                	jmp    26c <print_proc_info+0x1f9>
    if (!st->inuse[i]) continue;
 268:	90                   	nop
 269:	eb 01                	jmp    26c <print_proc_info+0x1f9>
    if (!is_child(st->pid[i], child_pid, count)) continue;
 26b:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
 26c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 270:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 274:	0f 8e 3e fe ff ff    	jle    b8 <print_proc_info+0x45>
  }
}
 27a:	90                   	nop
 27b:	90                   	nop
 27c:	8d 65 f8             	lea    -0x8(%ebp),%esp
 27f:	5b                   	pop    %ebx
 280:	5e                   	pop    %esi
 281:	5d                   	pop    %ebp
 282:	c3                   	ret    

00000283 <measure_workload_unit>:

int measure_workload_unit() {
 283:	55                   	push   %ebp
 284:	89 e5                	mov    %esp,%ebp
 286:	83 ec 38             	sub    $0x38,%esp
  struct pstat *st = &global_st;
 289:	c7 45 d4 a0 13 00 00 	movl   $0x13a0,-0x2c(%ebp)
  int pid = getpid(), t0 = -1, t1 = -1;
 290:	e8 ec 06 00 00       	call   981 <getpid>
 295:	89 45 d0             	mov    %eax,-0x30(%ebp)
 298:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
 29f:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  int level = 3;
 2a6:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)

  // ⏱ 프로세스가 ptable에 등록될 때까지 대기
  while (1) {
    getpinfo(st);
 2ad:	83 ec 0c             	sub    $0xc,%esp
 2b0:	ff 75 d4             	push   -0x2c(%ebp)
 2b3:	e8 f9 06 00 00       	call   9b1 <getpinfo>
 2b8:	83 c4 10             	add    $0x10,%esp
    int found = 0;
 2bb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    for (int i = 0; i < NPROC; i++) {
 2c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 2c9:	eb 2b                	jmp    2f6 <measure_workload_unit+0x73>
      if (st->inuse[i] && st->pid[i] == pid) {
 2cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 2ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2d1:	8b 04 90             	mov    (%eax,%edx,4),%eax
 2d4:	85 c0                	test   %eax,%eax
 2d6:	74 1a                	je     2f2 <measure_workload_unit+0x6f>
 2d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 2db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2de:	83 c2 40             	add    $0x40,%edx
 2e1:	8b 04 90             	mov    (%eax,%edx,4),%eax
 2e4:	39 45 d0             	cmp    %eax,-0x30(%ebp)
 2e7:	75 09                	jne    2f2 <measure_workload_unit+0x6f>
        found = 1;
 2e9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
        break;
 2f0:	eb 0a                	jmp    2fc <measure_workload_unit+0x79>
    for (int i = 0; i < NPROC; i++) {
 2f2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 2f6:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 2fa:	7e cf                	jle    2cb <measure_workload_unit+0x48>
      }
    }
    if (found) break;
 2fc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 300:	75 0f                	jne    311 <measure_workload_unit+0x8e>
    sleep(1);  // 잠깐 대기
 302:	83 ec 0c             	sub    $0xc,%esp
 305:	6a 01                	push   $0x1
 307:	e8 85 06 00 00       	call   991 <sleep>
 30c:	83 c4 10             	add    $0x10,%esp
  while (1) {
 30f:	eb 9c                	jmp    2ad <measure_workload_unit+0x2a>
    if (found) break;
 311:	90                   	nop
  }

  for (int n = 1000000; n <= 50000000; n += 50000) {
 312:	c7 45 e0 40 42 0f 00 	movl   $0xf4240,-0x20(%ebp)
 319:	e9 25 01 00 00       	jmp    443 <measure_workload_unit+0x1c0>
    getpinfo(st);
 31e:	83 ec 0c             	sub    $0xc,%esp
 321:	ff 75 d4             	push   -0x2c(%ebp)
 324:	e8 88 06 00 00       	call   9b1 <getpinfo>
 329:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < NPROC; i++) {
 32c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
 333:	eb 51                	jmp    386 <measure_workload_unit+0x103>
      if (st->inuse[i] && st->pid[i] == pid) {
 335:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 338:	8b 55 dc             	mov    -0x24(%ebp),%edx
 33b:	8b 04 90             	mov    (%eax,%edx,4),%eax
 33e:	85 c0                	test   %eax,%eax
 340:	74 40                	je     382 <measure_workload_unit+0xff>
 342:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 345:	8b 55 dc             	mov    -0x24(%ebp),%edx
 348:	83 c2 40             	add    $0x40,%edx
 34b:	8b 04 90             	mov    (%eax,%edx,4),%eax
 34e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
 351:	75 2f                	jne    382 <measure_workload_unit+0xff>
        level = st->priority[i];
 353:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 356:	8b 55 dc             	mov    -0x24(%ebp),%edx
 359:	83 ea 80             	sub    $0xffffff80,%edx
 35c:	8b 04 90             	mov    (%eax,%edx,4),%eax
 35f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        t0 = st->ticks[i][level];
 362:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 365:	8b 55 dc             	mov    -0x24(%ebp),%edx
 368:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
 36f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 372:	01 ca                	add    %ecx,%edx
 374:	81 c2 00 01 00 00    	add    $0x100,%edx
 37a:	8b 04 90             	mov    (%eax,%edx,4),%eax
 37d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        break;
 380:	eb 0a                	jmp    38c <measure_workload_unit+0x109>
    for (int i = 0; i < NPROC; i++) {
 382:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
 386:	83 7d dc 3f          	cmpl   $0x3f,-0x24(%ebp)
 38a:	7e a9                	jle    335 <measure_workload_unit+0xb2>
      }
    }

    if (t0 < 0) continue;
 38c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 390:	0f 88 a5 00 00 00    	js     43b <measure_workload_unit+0x1b8>

    workload(n);
 396:	83 ec 0c             	sub    $0xc,%esp
 399:	ff 75 e0             	push   -0x20(%ebp)
 39c:	e8 5f fc ff ff       	call   0 <workload>
 3a1:	83 c4 10             	add    $0x10,%esp
    sleep(5);
 3a4:	83 ec 0c             	sub    $0xc,%esp
 3a7:	6a 05                	push   $0x5
 3a9:	e8 e3 05 00 00       	call   991 <sleep>
 3ae:	83 c4 10             	add    $0x10,%esp

    getpinfo(st);
 3b1:	83 ec 0c             	sub    $0xc,%esp
 3b4:	ff 75 d4             	push   -0x2c(%ebp)
 3b7:	e8 f5 05 00 00       	call   9b1 <getpinfo>
 3bc:	83 c4 10             	add    $0x10,%esp
    for (int i = 0; i < NPROC; i++) {
 3bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
 3c6:	eb 42                	jmp    40a <measure_workload_unit+0x187>
      if (st->inuse[i] && st->pid[i] == pid) {
 3c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 3cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
 3ce:	8b 04 90             	mov    (%eax,%edx,4),%eax
 3d1:	85 c0                	test   %eax,%eax
 3d3:	74 31                	je     406 <measure_workload_unit+0x183>
 3d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 3d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
 3db:	83 c2 40             	add    $0x40,%edx
 3de:	8b 04 90             	mov    (%eax,%edx,4),%eax
 3e1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
 3e4:	75 20                	jne    406 <measure_workload_unit+0x183>
        t1 = st->ticks[i][level];
 3e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 3e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
 3ec:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
 3f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 3f6:	01 ca                	add    %ecx,%edx
 3f8:	81 c2 00 01 00 00    	add    $0x100,%edx
 3fe:	8b 04 90             	mov    (%eax,%edx,4),%eax
 401:	89 45 f0             	mov    %eax,-0x10(%ebp)
        break;
 404:	eb 0a                	jmp    410 <measure_workload_unit+0x18d>
    for (int i = 0; i < NPROC; i++) {
 406:	83 45 d8 01          	addl   $0x1,-0x28(%ebp)
 40a:	83 7d d8 3f          	cmpl   $0x3f,-0x28(%ebp)
 40e:	7e b8                	jle    3c8 <measure_workload_unit+0x145>
      }
    }

    if (t1 > t0) {
 410:	8b 45 f0             	mov    -0x10(%ebp),%eax
 413:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 416:	7e 24                	jle    43c <measure_workload_unit+0x1b9>
      printf(1, "✅ workload(%d) → tick 증가 (Q%d, %d → %d)\n", n, level, t0, t1);
 418:	83 ec 08             	sub    $0x8,%esp
 41b:	ff 75 f0             	push   -0x10(%ebp)
 41e:	ff 75 f4             	push   -0xc(%ebp)
 421:	ff 75 ec             	push   -0x14(%ebp)
 424:	ff 75 e0             	push   -0x20(%ebp)
 427:	68 30 0f 00 00       	push   $0xf30
 42c:	6a 01                	push   $0x1
 42e:	e8 72 06 00 00       	call   aa5 <printf>
 433:	83 c4 20             	add    $0x20,%esp
      return n;
 436:	8b 45 e0             	mov    -0x20(%ebp),%eax
 439:	eb 2c                	jmp    467 <measure_workload_unit+0x1e4>
    if (t0 < 0) continue;
 43b:	90                   	nop
  for (int n = 1000000; n <= 50000000; n += 50000) {
 43c:	81 45 e0 50 c3 00 00 	addl   $0xc350,-0x20(%ebp)
 443:	81 7d e0 80 f0 fa 02 	cmpl   $0x2faf080,-0x20(%ebp)
 44a:	0f 8e ce fe ff ff    	jle    31e <measure_workload_unit+0x9b>
    }
  }

  printf(1, "❌ tick 증가 확인 실패\n");
 450:	83 ec 08             	sub    $0x8,%esp
 453:	68 64 0f 00 00       	push   $0xf64
 458:	6a 01                	push   $0x1
 45a:	e8 46 06 00 00       	call   aa5 <printf>
 45f:	83 c4 10             	add    $0x10,%esp
  return -1;
 462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 467:	c9                   	leave  
 468:	c3                   	ret    

00000469 <main>:



int main(void) {
 469:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 46d:	83 e4 f0             	and    $0xfffffff0,%esp
 470:	ff 71 fc             	push   -0x4(%ecx)
 473:	55                   	push   %ebp
 474:	89 e5                	mov    %esp,%ebp
 476:	51                   	push   %ecx
 477:	81 ec 34 0c 00 00    	sub    $0xc34,%esp
  struct pstat st;
  int i, pid;
  int child_pid[4];
  int workload_unit = 4000000;
 47d:	c7 45 e8 00 09 3d 00 	movl   $0x3d0900,-0x18(%ebp)
  int tick_unit = measure_workload_unit();  // workload 단위 측정
 484:	e8 fa fd ff ff       	call   283 <measure_workload_unit>
 489:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  if (tick_unit <= 0) {
 48c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 490:	7f 1b                	jg     4ad <main+0x44>
    printf(1, "❌ workload_unit 측정 실패 또는 너무 작음. 기본값 100000 사용\n");
 492:	83 ec 08             	sub    $0x8,%esp
 495:	68 84 0f 00 00       	push   $0xf84
 49a:	6a 01                	push   $0x1
 49c:	e8 04 06 00 00       	call   aa5 <printf>
 4a1:	83 c4 10             	add    $0x10,%esp
    tick_unit = 4000000;
 4a4:	c7 45 e4 00 09 3d 00 	movl   $0x3d0900,-0x1c(%ebp)
 4ab:	eb 05                	jmp    4b2 <main+0x49>
  } else measure_workload_unit();
 4ad:	e8 d1 fd ff ff       	call   283 <measure_workload_unit>

  setSchedPolicy(3);
 4b2:	83 ec 0c             	sub    $0xc,%esp
 4b5:	6a 03                	push   $0x3
 4b7:	e8 fd 04 00 00       	call   9b9 <setSchedPolicy>
 4bc:	83 c4 10             	add    $0x10,%esp
  printf(1, "✅ setSchedPolicy(3) 적용 완료\n");
 4bf:	83 ec 08             	sub    $0x8,%esp
 4c2:	68 d4 0f 00 00       	push   $0xfd4
 4c7:	6a 01                	push   $0x1
 4c9:	e8 d7 05 00 00       	call   aa5 <printf>
 4ce:	83 c4 10             	add    $0x10,%esp

  for (i = 0; i < 4; i++) {
 4d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4d8:	e9 d3 00 00 00       	jmp    5b0 <main+0x147>
    pid = fork();
 4dd:	e8 17 04 00 00       	call   8f9 <fork>
 4e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (pid < 0) {
 4e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 4e9:	79 1a                	jns    505 <main+0x9c>
      printf(1, "❌ fork failed at i = %d\n", i);
 4eb:	83 ec 04             	sub    $0x4,%esp
 4ee:	ff 75 f4             	push   -0xc(%ebp)
 4f1:	68 f9 0f 00 00       	push   $0xff9
 4f6:	6a 01                	push   $0x1
 4f8:	e8 a8 05 00 00       	call   aa5 <printf>
 4fd:	83 c4 10             	add    $0x10,%esp
 500:	e9 a7 00 00 00       	jmp    5ac <main+0x143>
    } else if (pid == 0) {
 505:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 509:	75 7f                	jne    58a <main+0x121>
      sleep(500);
 50b:	83 ec 0c             	sub    $0xc,%esp
 50e:	68 f4 01 00 00       	push   $0x1f4
 513:	e8 79 04 00 00       	call   991 <sleep>
 518:	83 c4 10             	add    $0x10,%esp
      printf(1, "Child index %d | pid %d\n", i, getpid());
 51b:	e8 61 04 00 00       	call   981 <getpid>
 520:	50                   	push   %eax
 521:	ff 75 f4             	push   -0xc(%ebp)
 524:	68 14 10 00 00       	push   $0x1014
 529:	6a 01                	push   $0x1
 52b:	e8 75 05 00 00       	call   aa5 <printf>
 530:	83 c4 10             	add    $0x10,%esp

      if (i < 2) {
 533:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
 537:	7f 28                	jg     561 <main+0xf8>
        for (int t = 0; t < 8; t++) {
 539:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 540:	eb 17                	jmp    559 <main+0xf0>
          workload(workload_unit);
 542:	83 ec 0c             	sub    $0xc,%esp
 545:	ff 75 e8             	push   -0x18(%ebp)
 548:	e8 b3 fa ff ff       	call   0 <workload>
 54d:	83 c4 10             	add    $0x10,%esp
          yield();
 550:	e8 6c 04 00 00       	call   9c1 <yield>
        for (int t = 0; t < 8; t++) {
 555:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 559:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
 55d:	7e e3                	jle    542 <main+0xd9>
        }
        while (1);  // 계속 RUNNABLE 상태 유지해서 wait_ticks 쌓이게
 55f:	eb fe                	jmp    55f <main+0xf6>
      } else {
        for (int t = 0; t < 300; t++) {
 561:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 568:	eb 12                	jmp    57c <main+0x113>
          workload(workload_unit);
 56a:	83 ec 0c             	sub    $0xc,%esp
 56d:	ff 75 e8             	push   -0x18(%ebp)
 570:	e8 8b fa ff ff       	call   0 <workload>
 575:	83 c4 10             	add    $0x10,%esp
        for (int t = 0; t < 300; t++) {
 578:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 57c:	81 7d ec 2b 01 00 00 	cmpl   $0x12b,-0x14(%ebp)
 583:	7e e5                	jle    56a <main+0x101>
        }
        exit();
 585:	e8 77 03 00 00       	call   901 <exit>
      }
    } else {
      child_pid[i] = pid;
 58a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58d:	8b 55 e0             	mov    -0x20(%ebp),%edx
 590:	89 94 85 d0 f3 ff ff 	mov    %edx,-0xc30(%ebp,%eax,4)
      printf(1, "✅ fork success: child index %d | pid %d\n", i, pid);
 597:	ff 75 e0             	push   -0x20(%ebp)
 59a:	ff 75 f4             	push   -0xc(%ebp)
 59d:	68 30 10 00 00       	push   $0x1030
 5a2:	6a 01                	push   $0x1
 5a4:	e8 fc 04 00 00       	call   aa5 <printf>
 5a9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 4; i++) {
 5ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5b0:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 5b4:	0f 8e 23 ff ff ff    	jle    4dd <main+0x74>
    }
  }

  // ⏱ 초기 상태 확인
  getpinfo(&st);
 5ba:	83 ec 0c             	sub    $0xc,%esp
 5bd:	8d 85 e0 f3 ff ff    	lea    -0xc20(%ebp),%eax
 5c3:	50                   	push   %eax
 5c4:	e8 e8 03 00 00       	call   9b1 <getpinfo>
 5c9:	83 c4 10             	add    $0x10,%esp
  print_proc_info(&st, child_pid, 4, "초기 상태");
 5cc:	68 5b 10 00 00       	push   $0x105b
 5d1:	6a 04                	push   $0x4
 5d3:	8d 85 d0 f3 ff ff    	lea    -0xc30(%ebp),%eax
 5d9:	50                   	push   %eax
 5da:	8d 85 e0 f3 ff ff    	lea    -0xc20(%ebp),%eax
 5e0:	50                   	push   %eax
 5e1:	e8 8d fa ff ff       	call   73 <print_proc_info>
 5e6:	83 c4 10             	add    $0x10,%esp

  // ⏱ 중간 상태 확인
  sleep(2);
 5e9:	83 ec 0c             	sub    $0xc,%esp
 5ec:	6a 02                	push   $0x2
 5ee:	e8 9e 03 00 00       	call   991 <sleep>
 5f3:	83 c4 10             	add    $0x10,%esp
  getpinfo(&st);
 5f6:	83 ec 0c             	sub    $0xc,%esp
 5f9:	8d 85 e0 f3 ff ff    	lea    -0xc20(%ebp),%eax
 5ff:	50                   	push   %eax
 600:	e8 ac 03 00 00       	call   9b1 <getpinfo>
 605:	83 c4 10             	add    $0x10,%esp
  print_proc_info(&st, child_pid, 4, "중간 상태");
 608:	68 69 10 00 00       	push   $0x1069
 60d:	6a 04                	push   $0x4
 60f:	8d 85 d0 f3 ff ff    	lea    -0xc30(%ebp),%eax
 615:	50                   	push   %eax
 616:	8d 85 e0 f3 ff ff    	lea    -0xc20(%ebp),%eax
 61c:	50                   	push   %eax
 61d:	e8 51 fa ff ff       	call   73 <print_proc_info>
 622:	83 c4 10             	add    $0x10,%esp

  // ⏱ 충분히 시간 경과 후 상태 확인
  sleep(2000);
 625:	83 ec 0c             	sub    $0xc,%esp
 628:	68 d0 07 00 00       	push   $0x7d0
 62d:	e8 5f 03 00 00       	call   991 <sleep>
 632:	83 c4 10             	add    $0x10,%esp
  getpinfo(&st);
 635:	83 ec 0c             	sub    $0xc,%esp
 638:	8d 85 e0 f3 ff ff    	lea    -0xc20(%ebp),%eax
 63e:	50                   	push   %eax
 63f:	e8 6d 03 00 00       	call   9b1 <getpinfo>
 644:	83 c4 10             	add    $0x10,%esp
  print_proc_info(&st, child_pid, 4, "충분히 시간 경과 후 상태");
 647:	68 78 10 00 00       	push   $0x1078
 64c:	6a 04                	push   $0x4
 64e:	8d 85 d0 f3 ff ff    	lea    -0xc30(%ebp),%eax
 654:	50                   	push   %eax
 655:	8d 85 e0 f3 ff ff    	lea    -0xc20(%ebp),%eax
 65b:	50                   	push   %eax
 65c:	e8 12 fa ff ff       	call   73 <print_proc_info>
 661:	83 c4 10             	add    $0x10,%esp

  // ✅ 무한 루프 중인 자식 종료
  for (i = 0; i < 4; i++) kill(child_pid[i]);
 664:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 66b:	eb 1a                	jmp    687 <main+0x21e>
 66d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 670:	8b 84 85 d0 f3 ff ff 	mov    -0xc30(%ebp,%eax,4),%eax
 677:	83 ec 0c             	sub    $0xc,%esp
 67a:	50                   	push   %eax
 67b:	e8 b1 02 00 00       	call   931 <kill>
 680:	83 c4 10             	add    $0x10,%esp
 683:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 687:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 68b:	7e e0                	jle    66d <main+0x204>

  for (i = 0; i < 4; i++) wait();
 68d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 694:	eb 09                	jmp    69f <main+0x236>
 696:	e8 6e 02 00 00       	call   909 <wait>
 69b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 69f:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 6a3:	7e f1                	jle    696 <main+0x22d>

  exit();
 6a5:	e8 57 02 00 00       	call   901 <exit>

000006aa <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 6aa:	55                   	push   %ebp
 6ab:	89 e5                	mov    %esp,%ebp
 6ad:	57                   	push   %edi
 6ae:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 6af:	8b 4d 08             	mov    0x8(%ebp),%ecx
 6b2:	8b 55 10             	mov    0x10(%ebp),%edx
 6b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b8:	89 cb                	mov    %ecx,%ebx
 6ba:	89 df                	mov    %ebx,%edi
 6bc:	89 d1                	mov    %edx,%ecx
 6be:	fc                   	cld    
 6bf:	f3 aa                	rep stos %al,%es:(%edi)
 6c1:	89 ca                	mov    %ecx,%edx
 6c3:	89 fb                	mov    %edi,%ebx
 6c5:	89 5d 08             	mov    %ebx,0x8(%ebp)
 6c8:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 6cb:	90                   	nop
 6cc:	5b                   	pop    %ebx
 6cd:	5f                   	pop    %edi
 6ce:	5d                   	pop    %ebp
 6cf:	c3                   	ret    

000006d0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 6d0:	55                   	push   %ebp
 6d1:	89 e5                	mov    %esp,%ebp
 6d3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 6d6:	8b 45 08             	mov    0x8(%ebp),%eax
 6d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 6dc:	90                   	nop
 6dd:	8b 55 0c             	mov    0xc(%ebp),%edx
 6e0:	8d 42 01             	lea    0x1(%edx),%eax
 6e3:	89 45 0c             	mov    %eax,0xc(%ebp)
 6e6:	8b 45 08             	mov    0x8(%ebp),%eax
 6e9:	8d 48 01             	lea    0x1(%eax),%ecx
 6ec:	89 4d 08             	mov    %ecx,0x8(%ebp)
 6ef:	0f b6 12             	movzbl (%edx),%edx
 6f2:	88 10                	mov    %dl,(%eax)
 6f4:	0f b6 00             	movzbl (%eax),%eax
 6f7:	84 c0                	test   %al,%al
 6f9:	75 e2                	jne    6dd <strcpy+0xd>
    ;
  return os;
 6fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6fe:	c9                   	leave  
 6ff:	c3                   	ret    

00000700 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 700:	55                   	push   %ebp
 701:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 703:	eb 08                	jmp    70d <strcmp+0xd>
    p++, q++;
 705:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 709:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	0f b6 00             	movzbl (%eax),%eax
 713:	84 c0                	test   %al,%al
 715:	74 10                	je     727 <strcmp+0x27>
 717:	8b 45 08             	mov    0x8(%ebp),%eax
 71a:	0f b6 10             	movzbl (%eax),%edx
 71d:	8b 45 0c             	mov    0xc(%ebp),%eax
 720:	0f b6 00             	movzbl (%eax),%eax
 723:	38 c2                	cmp    %al,%dl
 725:	74 de                	je     705 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 727:	8b 45 08             	mov    0x8(%ebp),%eax
 72a:	0f b6 00             	movzbl (%eax),%eax
 72d:	0f b6 d0             	movzbl %al,%edx
 730:	8b 45 0c             	mov    0xc(%ebp),%eax
 733:	0f b6 00             	movzbl (%eax),%eax
 736:	0f b6 c8             	movzbl %al,%ecx
 739:	89 d0                	mov    %edx,%eax
 73b:	29 c8                	sub    %ecx,%eax
}
 73d:	5d                   	pop    %ebp
 73e:	c3                   	ret    

0000073f <strlen>:

uint
strlen(char *s)
{
 73f:	55                   	push   %ebp
 740:	89 e5                	mov    %esp,%ebp
 742:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 745:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 74c:	eb 04                	jmp    752 <strlen+0x13>
 74e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 752:	8b 55 fc             	mov    -0x4(%ebp),%edx
 755:	8b 45 08             	mov    0x8(%ebp),%eax
 758:	01 d0                	add    %edx,%eax
 75a:	0f b6 00             	movzbl (%eax),%eax
 75d:	84 c0                	test   %al,%al
 75f:	75 ed                	jne    74e <strlen+0xf>
    ;
  return n;
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 764:	c9                   	leave  
 765:	c3                   	ret    

00000766 <memset>:

void*
memset(void *dst, int c, uint n)
{
 766:	55                   	push   %ebp
 767:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 769:	8b 45 10             	mov    0x10(%ebp),%eax
 76c:	50                   	push   %eax
 76d:	ff 75 0c             	push   0xc(%ebp)
 770:	ff 75 08             	push   0x8(%ebp)
 773:	e8 32 ff ff ff       	call   6aa <stosb>
 778:	83 c4 0c             	add    $0xc,%esp
  return dst;
 77b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 77e:	c9                   	leave  
 77f:	c3                   	ret    

00000780 <strchr>:

char*
strchr(const char *s, char c)
{
 780:	55                   	push   %ebp
 781:	89 e5                	mov    %esp,%ebp
 783:	83 ec 04             	sub    $0x4,%esp
 786:	8b 45 0c             	mov    0xc(%ebp),%eax
 789:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 78c:	eb 14                	jmp    7a2 <strchr+0x22>
    if(*s == c)
 78e:	8b 45 08             	mov    0x8(%ebp),%eax
 791:	0f b6 00             	movzbl (%eax),%eax
 794:	38 45 fc             	cmp    %al,-0x4(%ebp)
 797:	75 05                	jne    79e <strchr+0x1e>
      return (char*)s;
 799:	8b 45 08             	mov    0x8(%ebp),%eax
 79c:	eb 13                	jmp    7b1 <strchr+0x31>
  for(; *s; s++)
 79e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 7a2:	8b 45 08             	mov    0x8(%ebp),%eax
 7a5:	0f b6 00             	movzbl (%eax),%eax
 7a8:	84 c0                	test   %al,%al
 7aa:	75 e2                	jne    78e <strchr+0xe>
  return 0;
 7ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
 7b1:	c9                   	leave  
 7b2:	c3                   	ret    

000007b3 <gets>:

char*
gets(char *buf, int max)
{
 7b3:	55                   	push   %ebp
 7b4:	89 e5                	mov    %esp,%ebp
 7b6:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 7b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 7c0:	eb 42                	jmp    804 <gets+0x51>
    cc = read(0, &c, 1);
 7c2:	83 ec 04             	sub    $0x4,%esp
 7c5:	6a 01                	push   $0x1
 7c7:	8d 45 ef             	lea    -0x11(%ebp),%eax
 7ca:	50                   	push   %eax
 7cb:	6a 00                	push   $0x0
 7cd:	e8 47 01 00 00       	call   919 <read>
 7d2:	83 c4 10             	add    $0x10,%esp
 7d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 7d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7dc:	7e 33                	jle    811 <gets+0x5e>
      break;
    buf[i++] = c;
 7de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e1:	8d 50 01             	lea    0x1(%eax),%edx
 7e4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7e7:	89 c2                	mov    %eax,%edx
 7e9:	8b 45 08             	mov    0x8(%ebp),%eax
 7ec:	01 c2                	add    %eax,%edx
 7ee:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 7f2:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 7f4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 7f8:	3c 0a                	cmp    $0xa,%al
 7fa:	74 16                	je     812 <gets+0x5f>
 7fc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 800:	3c 0d                	cmp    $0xd,%al
 802:	74 0e                	je     812 <gets+0x5f>
  for(i=0; i+1 < max; ){
 804:	8b 45 f4             	mov    -0xc(%ebp),%eax
 807:	83 c0 01             	add    $0x1,%eax
 80a:	39 45 0c             	cmp    %eax,0xc(%ebp)
 80d:	7f b3                	jg     7c2 <gets+0xf>
 80f:	eb 01                	jmp    812 <gets+0x5f>
      break;
 811:	90                   	nop
      break;
  }
  buf[i] = '\0';
 812:	8b 55 f4             	mov    -0xc(%ebp),%edx
 815:	8b 45 08             	mov    0x8(%ebp),%eax
 818:	01 d0                	add    %edx,%eax
 81a:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 81d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 820:	c9                   	leave  
 821:	c3                   	ret    

00000822 <stat>:

int
stat(char *n, struct stat *st)
{
 822:	55                   	push   %ebp
 823:	89 e5                	mov    %esp,%ebp
 825:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 828:	83 ec 08             	sub    $0x8,%esp
 82b:	6a 00                	push   $0x0
 82d:	ff 75 08             	push   0x8(%ebp)
 830:	e8 0c 01 00 00       	call   941 <open>
 835:	83 c4 10             	add    $0x10,%esp
 838:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 83b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 83f:	79 07                	jns    848 <stat+0x26>
    return -1;
 841:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 846:	eb 25                	jmp    86d <stat+0x4b>
  r = fstat(fd, st);
 848:	83 ec 08             	sub    $0x8,%esp
 84b:	ff 75 0c             	push   0xc(%ebp)
 84e:	ff 75 f4             	push   -0xc(%ebp)
 851:	e8 03 01 00 00       	call   959 <fstat>
 856:	83 c4 10             	add    $0x10,%esp
 859:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 85c:	83 ec 0c             	sub    $0xc,%esp
 85f:	ff 75 f4             	push   -0xc(%ebp)
 862:	e8 c2 00 00 00       	call   929 <close>
 867:	83 c4 10             	add    $0x10,%esp
  return r;
 86a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 86d:	c9                   	leave  
 86e:	c3                   	ret    

0000086f <atoi>:

int
atoi(const char *s)
{
 86f:	55                   	push   %ebp
 870:	89 e5                	mov    %esp,%ebp
 872:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 875:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 87c:	eb 25                	jmp    8a3 <atoi+0x34>
    n = n*10 + *s++ - '0';
 87e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 881:	89 d0                	mov    %edx,%eax
 883:	c1 e0 02             	shl    $0x2,%eax
 886:	01 d0                	add    %edx,%eax
 888:	01 c0                	add    %eax,%eax
 88a:	89 c1                	mov    %eax,%ecx
 88c:	8b 45 08             	mov    0x8(%ebp),%eax
 88f:	8d 50 01             	lea    0x1(%eax),%edx
 892:	89 55 08             	mov    %edx,0x8(%ebp)
 895:	0f b6 00             	movzbl (%eax),%eax
 898:	0f be c0             	movsbl %al,%eax
 89b:	01 c8                	add    %ecx,%eax
 89d:	83 e8 30             	sub    $0x30,%eax
 8a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 8a3:	8b 45 08             	mov    0x8(%ebp),%eax
 8a6:	0f b6 00             	movzbl (%eax),%eax
 8a9:	3c 2f                	cmp    $0x2f,%al
 8ab:	7e 0a                	jle    8b7 <atoi+0x48>
 8ad:	8b 45 08             	mov    0x8(%ebp),%eax
 8b0:	0f b6 00             	movzbl (%eax),%eax
 8b3:	3c 39                	cmp    $0x39,%al
 8b5:	7e c7                	jle    87e <atoi+0xf>
  return n;
 8b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 8ba:	c9                   	leave  
 8bb:	c3                   	ret    

000008bc <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 8bc:	55                   	push   %ebp
 8bd:	89 e5                	mov    %esp,%ebp
 8bf:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 8c2:	8b 45 08             	mov    0x8(%ebp),%eax
 8c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 8c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 8cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 8ce:	eb 17                	jmp    8e7 <memmove+0x2b>
    *dst++ = *src++;
 8d0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8d3:	8d 42 01             	lea    0x1(%edx),%eax
 8d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	8d 48 01             	lea    0x1(%eax),%ecx
 8df:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 8e2:	0f b6 12             	movzbl (%edx),%edx
 8e5:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 8e7:	8b 45 10             	mov    0x10(%ebp),%eax
 8ea:	8d 50 ff             	lea    -0x1(%eax),%edx
 8ed:	89 55 10             	mov    %edx,0x10(%ebp)
 8f0:	85 c0                	test   %eax,%eax
 8f2:	7f dc                	jg     8d0 <memmove+0x14>
  return vdst;
 8f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 8f7:	c9                   	leave  
 8f8:	c3                   	ret    

000008f9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 8f9:	b8 01 00 00 00       	mov    $0x1,%eax
 8fe:	cd 40                	int    $0x40
 900:	c3                   	ret    

00000901 <exit>:
SYSCALL(exit)
 901:	b8 02 00 00 00       	mov    $0x2,%eax
 906:	cd 40                	int    $0x40
 908:	c3                   	ret    

00000909 <wait>:
SYSCALL(wait)
 909:	b8 03 00 00 00       	mov    $0x3,%eax
 90e:	cd 40                	int    $0x40
 910:	c3                   	ret    

00000911 <pipe>:
SYSCALL(pipe)
 911:	b8 04 00 00 00       	mov    $0x4,%eax
 916:	cd 40                	int    $0x40
 918:	c3                   	ret    

00000919 <read>:
SYSCALL(read)
 919:	b8 05 00 00 00       	mov    $0x5,%eax
 91e:	cd 40                	int    $0x40
 920:	c3                   	ret    

00000921 <write>:
SYSCALL(write)
 921:	b8 10 00 00 00       	mov    $0x10,%eax
 926:	cd 40                	int    $0x40
 928:	c3                   	ret    

00000929 <close>:
SYSCALL(close)
 929:	b8 15 00 00 00       	mov    $0x15,%eax
 92e:	cd 40                	int    $0x40
 930:	c3                   	ret    

00000931 <kill>:
SYSCALL(kill)
 931:	b8 06 00 00 00       	mov    $0x6,%eax
 936:	cd 40                	int    $0x40
 938:	c3                   	ret    

00000939 <exec>:
SYSCALL(exec)
 939:	b8 07 00 00 00       	mov    $0x7,%eax
 93e:	cd 40                	int    $0x40
 940:	c3                   	ret    

00000941 <open>:
SYSCALL(open)
 941:	b8 0f 00 00 00       	mov    $0xf,%eax
 946:	cd 40                	int    $0x40
 948:	c3                   	ret    

00000949 <mknod>:
SYSCALL(mknod)
 949:	b8 11 00 00 00       	mov    $0x11,%eax
 94e:	cd 40                	int    $0x40
 950:	c3                   	ret    

00000951 <unlink>:
SYSCALL(unlink)
 951:	b8 12 00 00 00       	mov    $0x12,%eax
 956:	cd 40                	int    $0x40
 958:	c3                   	ret    

00000959 <fstat>:
SYSCALL(fstat)
 959:	b8 08 00 00 00       	mov    $0x8,%eax
 95e:	cd 40                	int    $0x40
 960:	c3                   	ret    

00000961 <link>:
SYSCALL(link)
 961:	b8 13 00 00 00       	mov    $0x13,%eax
 966:	cd 40                	int    $0x40
 968:	c3                   	ret    

00000969 <mkdir>:
SYSCALL(mkdir)
 969:	b8 14 00 00 00       	mov    $0x14,%eax
 96e:	cd 40                	int    $0x40
 970:	c3                   	ret    

00000971 <chdir>:
SYSCALL(chdir)
 971:	b8 09 00 00 00       	mov    $0x9,%eax
 976:	cd 40                	int    $0x40
 978:	c3                   	ret    

00000979 <dup>:
SYSCALL(dup)
 979:	b8 0a 00 00 00       	mov    $0xa,%eax
 97e:	cd 40                	int    $0x40
 980:	c3                   	ret    

00000981 <getpid>:
SYSCALL(getpid)
 981:	b8 0b 00 00 00       	mov    $0xb,%eax
 986:	cd 40                	int    $0x40
 988:	c3                   	ret    

00000989 <sbrk>:
SYSCALL(sbrk)
 989:	b8 0c 00 00 00       	mov    $0xc,%eax
 98e:	cd 40                	int    $0x40
 990:	c3                   	ret    

00000991 <sleep>:
SYSCALL(sleep)
 991:	b8 0d 00 00 00       	mov    $0xd,%eax
 996:	cd 40                	int    $0x40
 998:	c3                   	ret    

00000999 <uptime>:
SYSCALL(uptime)
 999:	b8 0e 00 00 00       	mov    $0xe,%eax
 99e:	cd 40                	int    $0x40
 9a0:	c3                   	ret    

000009a1 <uthread_init>:

SYSCALL(uthread_init)
 9a1:	b8 16 00 00 00       	mov    $0x16,%eax
 9a6:	cd 40                	int    $0x40
 9a8:	c3                   	ret    

000009a9 <check_thread>:
SYSCALL(check_thread)
 9a9:	b8 17 00 00 00       	mov    $0x17,%eax
 9ae:	cd 40                	int    $0x40
 9b0:	c3                   	ret    

000009b1 <getpinfo>:

SYSCALL(getpinfo)
 9b1:	b8 18 00 00 00       	mov    $0x18,%eax
 9b6:	cd 40                	int    $0x40
 9b8:	c3                   	ret    

000009b9 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 9b9:	b8 19 00 00 00       	mov    $0x19,%eax
 9be:	cd 40                	int    $0x40
 9c0:	c3                   	ret    

000009c1 <yield>:
SYSCALL(yield)
 9c1:	b8 1a 00 00 00       	mov    $0x1a,%eax
 9c6:	cd 40                	int    $0x40
 9c8:	c3                   	ret    

000009c9 <printpt>:

 9c9:	b8 1b 00 00 00       	mov    $0x1b,%eax
 9ce:	cd 40                	int    $0x40
 9d0:	c3                   	ret    

000009d1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 9d1:	55                   	push   %ebp
 9d2:	89 e5                	mov    %esp,%ebp
 9d4:	83 ec 18             	sub    $0x18,%esp
 9d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 9da:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 9dd:	83 ec 04             	sub    $0x4,%esp
 9e0:	6a 01                	push   $0x1
 9e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
 9e5:	50                   	push   %eax
 9e6:	ff 75 08             	push   0x8(%ebp)
 9e9:	e8 33 ff ff ff       	call   921 <write>
 9ee:	83 c4 10             	add    $0x10,%esp
}
 9f1:	90                   	nop
 9f2:	c9                   	leave  
 9f3:	c3                   	ret    

000009f4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9f4:	55                   	push   %ebp
 9f5:	89 e5                	mov    %esp,%ebp
 9f7:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 9fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 a01:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 a05:	74 17                	je     a1e <printint+0x2a>
 a07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 a0b:	79 11                	jns    a1e <printint+0x2a>
    neg = 1;
 a0d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 a14:	8b 45 0c             	mov    0xc(%ebp),%eax
 a17:	f7 d8                	neg    %eax
 a19:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a1c:	eb 06                	jmp    a24 <printint+0x30>
  } else {
    x = xx;
 a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
 a21:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 a24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 a2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a31:	ba 00 00 00 00       	mov    $0x0,%edx
 a36:	f7 f1                	div    %ecx
 a38:	89 d1                	mov    %edx,%ecx
 a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3d:	8d 50 01             	lea    0x1(%eax),%edx
 a40:	89 55 f4             	mov    %edx,-0xc(%ebp)
 a43:	0f b6 91 74 13 00 00 	movzbl 0x1374(%ecx),%edx
 a4a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 a4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 a51:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a54:	ba 00 00 00 00       	mov    $0x0,%edx
 a59:	f7 f1                	div    %ecx
 a5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a5e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a62:	75 c7                	jne    a2b <printint+0x37>
  if(neg)
 a64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a68:	74 2d                	je     a97 <printint+0xa3>
    buf[i++] = '-';
 a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6d:	8d 50 01             	lea    0x1(%eax),%edx
 a70:	89 55 f4             	mov    %edx,-0xc(%ebp)
 a73:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 a78:	eb 1d                	jmp    a97 <printint+0xa3>
    putc(fd, buf[i]);
 a7a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a80:	01 d0                	add    %edx,%eax
 a82:	0f b6 00             	movzbl (%eax),%eax
 a85:	0f be c0             	movsbl %al,%eax
 a88:	83 ec 08             	sub    $0x8,%esp
 a8b:	50                   	push   %eax
 a8c:	ff 75 08             	push   0x8(%ebp)
 a8f:	e8 3d ff ff ff       	call   9d1 <putc>
 a94:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 a97:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 a9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a9f:	79 d9                	jns    a7a <printint+0x86>
}
 aa1:	90                   	nop
 aa2:	90                   	nop
 aa3:	c9                   	leave  
 aa4:	c3                   	ret    

00000aa5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 aa5:	55                   	push   %ebp
 aa6:	89 e5                	mov    %esp,%ebp
 aa8:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 aab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 ab2:	8d 45 0c             	lea    0xc(%ebp),%eax
 ab5:	83 c0 04             	add    $0x4,%eax
 ab8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 abb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 ac2:	e9 59 01 00 00       	jmp    c20 <printf+0x17b>
    c = fmt[i] & 0xff;
 ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
 aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 acd:	01 d0                	add    %edx,%eax
 acf:	0f b6 00             	movzbl (%eax),%eax
 ad2:	0f be c0             	movsbl %al,%eax
 ad5:	25 ff 00 00 00       	and    $0xff,%eax
 ada:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 add:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 ae1:	75 2c                	jne    b0f <printf+0x6a>
      if(c == '%'){
 ae3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 ae7:	75 0c                	jne    af5 <printf+0x50>
        state = '%';
 ae9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 af0:	e9 27 01 00 00       	jmp    c1c <printf+0x177>
      } else {
        putc(fd, c);
 af5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 af8:	0f be c0             	movsbl %al,%eax
 afb:	83 ec 08             	sub    $0x8,%esp
 afe:	50                   	push   %eax
 aff:	ff 75 08             	push   0x8(%ebp)
 b02:	e8 ca fe ff ff       	call   9d1 <putc>
 b07:	83 c4 10             	add    $0x10,%esp
 b0a:	e9 0d 01 00 00       	jmp    c1c <printf+0x177>
      }
    } else if(state == '%'){
 b0f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 b13:	0f 85 03 01 00 00    	jne    c1c <printf+0x177>
      if(c == 'd'){
 b19:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 b1d:	75 1e                	jne    b3d <printf+0x98>
        printint(fd, *ap, 10, 1);
 b1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b22:	8b 00                	mov    (%eax),%eax
 b24:	6a 01                	push   $0x1
 b26:	6a 0a                	push   $0xa
 b28:	50                   	push   %eax
 b29:	ff 75 08             	push   0x8(%ebp)
 b2c:	e8 c3 fe ff ff       	call   9f4 <printint>
 b31:	83 c4 10             	add    $0x10,%esp
        ap++;
 b34:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b38:	e9 d8 00 00 00       	jmp    c15 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 b3d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 b41:	74 06                	je     b49 <printf+0xa4>
 b43:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 b47:	75 1e                	jne    b67 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 b49:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b4c:	8b 00                	mov    (%eax),%eax
 b4e:	6a 00                	push   $0x0
 b50:	6a 10                	push   $0x10
 b52:	50                   	push   %eax
 b53:	ff 75 08             	push   0x8(%ebp)
 b56:	e8 99 fe ff ff       	call   9f4 <printint>
 b5b:	83 c4 10             	add    $0x10,%esp
        ap++;
 b5e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b62:	e9 ae 00 00 00       	jmp    c15 <printf+0x170>
      } else if(c == 's'){
 b67:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 b6b:	75 43                	jne    bb0 <printf+0x10b>
        s = (char*)*ap;
 b6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b70:	8b 00                	mov    (%eax),%eax
 b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 b75:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 b79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b7d:	75 25                	jne    ba4 <printf+0xff>
          s = "(null)";
 b7f:	c7 45 f4 9b 10 00 00 	movl   $0x109b,-0xc(%ebp)
        while(*s != 0){
 b86:	eb 1c                	jmp    ba4 <printf+0xff>
          putc(fd, *s);
 b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b8b:	0f b6 00             	movzbl (%eax),%eax
 b8e:	0f be c0             	movsbl %al,%eax
 b91:	83 ec 08             	sub    $0x8,%esp
 b94:	50                   	push   %eax
 b95:	ff 75 08             	push   0x8(%ebp)
 b98:	e8 34 fe ff ff       	call   9d1 <putc>
 b9d:	83 c4 10             	add    $0x10,%esp
          s++;
 ba0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba7:	0f b6 00             	movzbl (%eax),%eax
 baa:	84 c0                	test   %al,%al
 bac:	75 da                	jne    b88 <printf+0xe3>
 bae:	eb 65                	jmp    c15 <printf+0x170>
        }
      } else if(c == 'c'){
 bb0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 bb4:	75 1d                	jne    bd3 <printf+0x12e>
        putc(fd, *ap);
 bb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bb9:	8b 00                	mov    (%eax),%eax
 bbb:	0f be c0             	movsbl %al,%eax
 bbe:	83 ec 08             	sub    $0x8,%esp
 bc1:	50                   	push   %eax
 bc2:	ff 75 08             	push   0x8(%ebp)
 bc5:	e8 07 fe ff ff       	call   9d1 <putc>
 bca:	83 c4 10             	add    $0x10,%esp
        ap++;
 bcd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 bd1:	eb 42                	jmp    c15 <printf+0x170>
      } else if(c == '%'){
 bd3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 bd7:	75 17                	jne    bf0 <printf+0x14b>
        putc(fd, c);
 bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 bdc:	0f be c0             	movsbl %al,%eax
 bdf:	83 ec 08             	sub    $0x8,%esp
 be2:	50                   	push   %eax
 be3:	ff 75 08             	push   0x8(%ebp)
 be6:	e8 e6 fd ff ff       	call   9d1 <putc>
 beb:	83 c4 10             	add    $0x10,%esp
 bee:	eb 25                	jmp    c15 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 bf0:	83 ec 08             	sub    $0x8,%esp
 bf3:	6a 25                	push   $0x25
 bf5:	ff 75 08             	push   0x8(%ebp)
 bf8:	e8 d4 fd ff ff       	call   9d1 <putc>
 bfd:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 c00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c03:	0f be c0             	movsbl %al,%eax
 c06:	83 ec 08             	sub    $0x8,%esp
 c09:	50                   	push   %eax
 c0a:	ff 75 08             	push   0x8(%ebp)
 c0d:	e8 bf fd ff ff       	call   9d1 <putc>
 c12:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 c15:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 c1c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 c20:	8b 55 0c             	mov    0xc(%ebp),%edx
 c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c26:	01 d0                	add    %edx,%eax
 c28:	0f b6 00             	movzbl (%eax),%eax
 c2b:	84 c0                	test   %al,%al
 c2d:	0f 85 94 fe ff ff    	jne    ac7 <printf+0x22>
    }
  }
}
 c33:	90                   	nop
 c34:	90                   	nop
 c35:	c9                   	leave  
 c36:	c3                   	ret    

00000c37 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c37:	55                   	push   %ebp
 c38:	89 e5                	mov    %esp,%ebp
 c3a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 c3d:	8b 45 08             	mov    0x8(%ebp),%eax
 c40:	83 e8 08             	sub    $0x8,%eax
 c43:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c46:	a1 a8 1f 00 00       	mov    0x1fa8,%eax
 c4b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c4e:	eb 24                	jmp    c74 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c50:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c53:	8b 00                	mov    (%eax),%eax
 c55:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 c58:	72 12                	jb     c6c <free+0x35>
 c5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c5d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c60:	77 24                	ja     c86 <free+0x4f>
 c62:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c65:	8b 00                	mov    (%eax),%eax
 c67:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 c6a:	72 1a                	jb     c86 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c6f:	8b 00                	mov    (%eax),%eax
 c71:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c74:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c77:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c7a:	76 d4                	jbe    c50 <free+0x19>
 c7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c7f:	8b 00                	mov    (%eax),%eax
 c81:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 c84:	73 ca                	jae    c50 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 c86:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c89:	8b 40 04             	mov    0x4(%eax),%eax
 c8c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c93:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c96:	01 c2                	add    %eax,%edx
 c98:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c9b:	8b 00                	mov    (%eax),%eax
 c9d:	39 c2                	cmp    %eax,%edx
 c9f:	75 24                	jne    cc5 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 ca1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ca4:	8b 50 04             	mov    0x4(%eax),%edx
 ca7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 caa:	8b 00                	mov    (%eax),%eax
 cac:	8b 40 04             	mov    0x4(%eax),%eax
 caf:	01 c2                	add    %eax,%edx
 cb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cb4:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 cb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cba:	8b 00                	mov    (%eax),%eax
 cbc:	8b 10                	mov    (%eax),%edx
 cbe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cc1:	89 10                	mov    %edx,(%eax)
 cc3:	eb 0a                	jmp    ccf <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 cc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cc8:	8b 10                	mov    (%eax),%edx
 cca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ccd:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 ccf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cd2:	8b 40 04             	mov    0x4(%eax),%eax
 cd5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 cdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cdf:	01 d0                	add    %edx,%eax
 ce1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ce4:	75 20                	jne    d06 <free+0xcf>
    p->s.size += bp->s.size;
 ce6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ce9:	8b 50 04             	mov    0x4(%eax),%edx
 cec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cef:	8b 40 04             	mov    0x4(%eax),%eax
 cf2:	01 c2                	add    %eax,%edx
 cf4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cf7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 cfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cfd:	8b 10                	mov    (%eax),%edx
 cff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d02:	89 10                	mov    %edx,(%eax)
 d04:	eb 08                	jmp    d0e <free+0xd7>
  } else
    p->s.ptr = bp;
 d06:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d09:	8b 55 f8             	mov    -0x8(%ebp),%edx
 d0c:	89 10                	mov    %edx,(%eax)
  freep = p;
 d0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d11:	a3 a8 1f 00 00       	mov    %eax,0x1fa8
}
 d16:	90                   	nop
 d17:	c9                   	leave  
 d18:	c3                   	ret    

00000d19 <morecore>:

static Header*
morecore(uint nu)
{
 d19:	55                   	push   %ebp
 d1a:	89 e5                	mov    %esp,%ebp
 d1c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 d1f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 d26:	77 07                	ja     d2f <morecore+0x16>
    nu = 4096;
 d28:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 d2f:	8b 45 08             	mov    0x8(%ebp),%eax
 d32:	c1 e0 03             	shl    $0x3,%eax
 d35:	83 ec 0c             	sub    $0xc,%esp
 d38:	50                   	push   %eax
 d39:	e8 4b fc ff ff       	call   989 <sbrk>
 d3e:	83 c4 10             	add    $0x10,%esp
 d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 d44:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 d48:	75 07                	jne    d51 <morecore+0x38>
    return 0;
 d4a:	b8 00 00 00 00       	mov    $0x0,%eax
 d4f:	eb 26                	jmp    d77 <morecore+0x5e>
  hp = (Header*)p;
 d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d5a:	8b 55 08             	mov    0x8(%ebp),%edx
 d5d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 d60:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d63:	83 c0 08             	add    $0x8,%eax
 d66:	83 ec 0c             	sub    $0xc,%esp
 d69:	50                   	push   %eax
 d6a:	e8 c8 fe ff ff       	call   c37 <free>
 d6f:	83 c4 10             	add    $0x10,%esp
  return freep;
 d72:	a1 a8 1f 00 00       	mov    0x1fa8,%eax
}
 d77:	c9                   	leave  
 d78:	c3                   	ret    

00000d79 <malloc>:

void*
malloc(uint nbytes)
{
 d79:	55                   	push   %ebp
 d7a:	89 e5                	mov    %esp,%ebp
 d7c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d7f:	8b 45 08             	mov    0x8(%ebp),%eax
 d82:	83 c0 07             	add    $0x7,%eax
 d85:	c1 e8 03             	shr    $0x3,%eax
 d88:	83 c0 01             	add    $0x1,%eax
 d8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 d8e:	a1 a8 1f 00 00       	mov    0x1fa8,%eax
 d93:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 d9a:	75 23                	jne    dbf <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 d9c:	c7 45 f0 a0 1f 00 00 	movl   $0x1fa0,-0x10(%ebp)
 da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 da6:	a3 a8 1f 00 00       	mov    %eax,0x1fa8
 dab:	a1 a8 1f 00 00       	mov    0x1fa8,%eax
 db0:	a3 a0 1f 00 00       	mov    %eax,0x1fa0
    base.s.size = 0;
 db5:	c7 05 a4 1f 00 00 00 	movl   $0x0,0x1fa4
 dbc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 dc2:	8b 00                	mov    (%eax),%eax
 dc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dca:	8b 40 04             	mov    0x4(%eax),%eax
 dcd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 dd0:	77 4d                	ja     e1f <malloc+0xa6>
      if(p->s.size == nunits)
 dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dd5:	8b 40 04             	mov    0x4(%eax),%eax
 dd8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ddb:	75 0c                	jne    de9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 de0:	8b 10                	mov    (%eax),%edx
 de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 de5:	89 10                	mov    %edx,(%eax)
 de7:	eb 26                	jmp    e0f <malloc+0x96>
      else {
        p->s.size -= nunits;
 de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dec:	8b 40 04             	mov    0x4(%eax),%eax
 def:	2b 45 ec             	sub    -0x14(%ebp),%eax
 df2:	89 c2                	mov    %eax,%edx
 df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 df7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dfd:	8b 40 04             	mov    0x4(%eax),%eax
 e00:	c1 e0 03             	shl    $0x3,%eax
 e03:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e09:	8b 55 ec             	mov    -0x14(%ebp),%edx
 e0c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e12:	a3 a8 1f 00 00       	mov    %eax,0x1fa8
      return (void*)(p + 1);
 e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e1a:	83 c0 08             	add    $0x8,%eax
 e1d:	eb 3b                	jmp    e5a <malloc+0xe1>
    }
    if(p == freep)
 e1f:	a1 a8 1f 00 00       	mov    0x1fa8,%eax
 e24:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 e27:	75 1e                	jne    e47 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 e29:	83 ec 0c             	sub    $0xc,%esp
 e2c:	ff 75 ec             	push   -0x14(%ebp)
 e2f:	e8 e5 fe ff ff       	call   d19 <morecore>
 e34:	83 c4 10             	add    $0x10,%esp
 e37:	89 45 f4             	mov    %eax,-0xc(%ebp)
 e3a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 e3e:	75 07                	jne    e47 <malloc+0xce>
        return 0;
 e40:	b8 00 00 00 00       	mov    $0x0,%eax
 e45:	eb 13                	jmp    e5a <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e50:	8b 00                	mov    (%eax),%eax
 e52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 e55:	e9 6d ff ff ff       	jmp    dc7 <malloc+0x4e>
  }
}
 e5a:	c9                   	leave  
 e5b:	c3                   	ret    
