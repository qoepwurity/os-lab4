
_mlfq3:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "types.h"
#include "user.h"
#include "pstat.h"

int workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  volatile int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++)
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 18                	jmp    2e <workload+0x2e>
    j = j * i + 1;
  16:	8b 55 f8             	mov    -0x8(%ebp),%edx
  19:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1c:	0f af c2             	imul   %edx,%eax
  1f:	83 c0 01             	add    $0x1,%eax
  22:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++)
  25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  28:	83 c0 01             	add    $0x1,%eax
  2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  31:	39 45 08             	cmp    %eax,0x8(%ebp)
  34:	7f e0                	jg     16 <workload+0x16>
  return j;
  36:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  39:	c9                   	leave  
  3a:	c3                   	ret    

0000003b <is_child>:

int is_child(int pid, int *child_pid, int count) {
  3b:	55                   	push   %ebp
  3c:	89 e5                	mov    %esp,%ebp
  3e:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < count; i++) {
  41:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  48:	eb 21                	jmp    6b <is_child+0x30>
    if (child_pid[i] == pid)
  4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  54:	8b 45 0c             	mov    0xc(%ebp),%eax
  57:	01 d0                	add    %edx,%eax
  59:	8b 00                	mov    (%eax),%eax
  5b:	39 45 08             	cmp    %eax,0x8(%ebp)
  5e:	75 07                	jne    67 <is_child+0x2c>
      return 1;
  60:	b8 01 00 00 00       	mov    $0x1,%eax
  65:	eb 11                	jmp    78 <is_child+0x3d>
  for (int i = 0; i < count; i++) {
  67:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  6e:	3b 45 10             	cmp    0x10(%ebp),%eax
  71:	7c d7                	jl     4a <is_child+0xf>
  }
  return 0;
  73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  78:	c9                   	leave  
  79:	c3                   	ret    

0000007a <print_proc_info>:

void print_proc_info(struct pstat *st, int *child_pid, int count, const char *title) {
  7a:	55                   	push   %ebp
  7b:	89 e5                	mov    %esp,%ebp
  7d:	56                   	push   %esi
  7e:	53                   	push   %ebx
  7f:	83 ec 20             	sub    $0x20,%esp
  int wait_times[4] = {500, 320, 160, 80};
  82:	c7 45 e0 f4 01 00 00 	movl   $0x1f4,-0x20(%ebp)
  89:	c7 45 e4 40 01 00 00 	movl   $0x140,-0x1c(%ebp)
  90:	c7 45 e8 a0 00 00 00 	movl   $0xa0,-0x18(%ebp)
  97:	c7 45 ec 50 00 00 00 	movl   $0x50,-0x14(%ebp)

  printf(1, "\n[ %s ] ----------------------------\n", title);
  9e:	83 ec 04             	sub    $0x4,%esp
  a1:	ff 75 14             	push   0x14(%ebp)
  a4:	68 e4 0d 00 00       	push   $0xde4
  a9:	6a 01                	push   $0x1
  ab:	e8 7a 09 00 00       	call   a2a <printf>
  b0:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ba:	e9 b8 01 00 00       	jmp    277 <print_proc_info+0x1fd>
    if (!st->inuse[i]) continue;
  bf:	8b 45 08             	mov    0x8(%ebp),%eax
  c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  c5:	8b 04 90             	mov    (%eax,%edx,4),%eax
  c8:	85 c0                	test   %eax,%eax
  ca:	0f 84 9f 01 00 00    	je     26f <print_proc_info+0x1f5>
    if (!is_child(st->pid[i], child_pid, count)) continue;
  d0:	8b 45 08             	mov    0x8(%ebp),%eax
  d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  d6:	83 c2 40             	add    $0x40,%edx
  d9:	8b 04 90             	mov    (%eax,%edx,4),%eax
  dc:	83 ec 04             	sub    $0x4,%esp
  df:	ff 75 10             	push   0x10(%ebp)
  e2:	ff 75 0c             	push   0xc(%ebp)
  e5:	50                   	push   %eax
  e6:	e8 50 ff ff ff       	call   3b <is_child>
  eb:	83 c4 10             	add    $0x10,%esp
  ee:	85 c0                	test   %eax,%eax
  f0:	0f 84 7c 01 00 00    	je     272 <print_proc_info+0x1f8>

    printf(1, "pid %d | priority %d\n", st->pid[i], st->priority[i]);
  f6:	8b 45 08             	mov    0x8(%ebp),%eax
  f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  fc:	83 ea 80             	sub    $0xffffff80,%edx
  ff:	8b 14 90             	mov    (%eax,%edx,4),%edx
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 108:	83 c1 40             	add    $0x40,%ecx
 10b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
 10e:	52                   	push   %edx
 10f:	50                   	push   %eax
 110:	68 0a 0e 00 00       	push   $0xe0a
 115:	6a 01                	push   $0x1
 117:	e8 0e 09 00 00       	call   a2a <printf>
 11c:	83 c4 10             	add    $0x10,%esp
    printf(1, "  ticks:      [%d %d %d %d]\n",
 11f:	8b 55 08             	mov    0x8(%ebp),%edx
 122:	8b 45 f4             	mov    -0xc(%ebp),%eax
 125:	c1 e0 04             	shl    $0x4,%eax
 128:	01 d0                	add    %edx,%eax
 12a:	05 0c 04 00 00       	add    $0x40c,%eax
 12f:	8b 18                	mov    (%eax),%ebx
 131:	8b 55 08             	mov    0x8(%ebp),%edx
 134:	8b 45 f4             	mov    -0xc(%ebp),%eax
 137:	c1 e0 04             	shl    $0x4,%eax
 13a:	01 d0                	add    %edx,%eax
 13c:	05 08 04 00 00       	add    $0x408,%eax
 141:	8b 08                	mov    (%eax),%ecx
 143:	8b 55 08             	mov    0x8(%ebp),%edx
 146:	8b 45 f4             	mov    -0xc(%ebp),%eax
 149:	c1 e0 04             	shl    $0x4,%eax
 14c:	01 d0                	add    %edx,%eax
 14e:	05 04 04 00 00       	add    $0x404,%eax
 153:	8b 10                	mov    (%eax),%edx
 155:	8b 75 08             	mov    0x8(%ebp),%esi
 158:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15b:	83 c0 40             	add    $0x40,%eax
 15e:	c1 e0 04             	shl    $0x4,%eax
 161:	01 f0                	add    %esi,%eax
 163:	8b 00                	mov    (%eax),%eax
 165:	83 ec 08             	sub    $0x8,%esp
 168:	53                   	push   %ebx
 169:	51                   	push   %ecx
 16a:	52                   	push   %edx
 16b:	50                   	push   %eax
 16c:	68 20 0e 00 00       	push   $0xe20
 171:	6a 01                	push   $0x1
 173:	e8 b2 08 00 00       	call   a2a <printf>
 178:	83 c4 20             	add    $0x20,%esp
           st->ticks[i][0], st->ticks[i][1], st->ticks[i][2], st->ticks[i][3]);
    printf(1, "  wait_ticks: [%d %d %d %d]\n",
 17b:	8b 55 08             	mov    0x8(%ebp),%edx
 17e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 181:	c1 e0 04             	shl    $0x4,%eax
 184:	01 d0                	add    %edx,%eax
 186:	05 0c 08 00 00       	add    $0x80c,%eax
 18b:	8b 18                	mov    (%eax),%ebx
 18d:	8b 55 08             	mov    0x8(%ebp),%edx
 190:	8b 45 f4             	mov    -0xc(%ebp),%eax
 193:	c1 e0 04             	shl    $0x4,%eax
 196:	01 d0                	add    %edx,%eax
 198:	05 08 08 00 00       	add    $0x808,%eax
 19d:	8b 08                	mov    (%eax),%ecx
 19f:	8b 55 08             	mov    0x8(%ebp),%edx
 1a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a5:	c1 e0 04             	shl    $0x4,%eax
 1a8:	01 d0                	add    %edx,%eax
 1aa:	05 04 08 00 00       	add    $0x804,%eax
 1af:	8b 10                	mov    (%eax),%edx
 1b1:	8b 75 08             	mov    0x8(%ebp),%esi
 1b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b7:	83 e8 80             	sub    $0xffffff80,%eax
 1ba:	c1 e0 04             	shl    $0x4,%eax
 1bd:	01 f0                	add    %esi,%eax
 1bf:	8b 00                	mov    (%eax),%eax
 1c1:	83 ec 08             	sub    $0x8,%esp
 1c4:	53                   	push   %ebx
 1c5:	51                   	push   %ecx
 1c6:	52                   	push   %edx
 1c7:	50                   	push   %eax
 1c8:	68 3d 0e 00 00       	push   $0xe3d
 1cd:	6a 01                	push   $0x1
 1cf:	e8 56 08 00 00       	call   a2a <printf>
 1d4:	83 c4 20             	add    $0x20,%esp
           st->wait_ticks[i][0], st->wait_ticks[i][1], st->wait_ticks[i][2], st->wait_ticks[i][3]);

    for (int q = 0; q < 4; q++) {
 1d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 1de:	eb 44                	jmp    224 <print_proc_info+0x1aa>
      if (st->wait_ticks[i][q] >= wait_times[q]) {
 1e0:	8b 45 08             	mov    0x8(%ebp),%eax
 1e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1e6:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
 1ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
 1f0:	01 ca                	add    %ecx,%edx
 1f2:	81 c2 00 02 00 00    	add    $0x200,%edx
 1f8:	8b 14 90             	mov    (%eax,%edx,4),%edx
 1fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1fe:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 202:	39 c2                	cmp    %eax,%edx
 204:	7c 1a                	jl     220 <print_proc_info+0x1a6>
        printf(1, "  boost condition met: wait_ticks[%d] >= %d (ignored in policy 3)\n", q, wait_times[q]);
 206:	8b 45 f0             	mov    -0x10(%ebp),%eax
 209:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 20d:	50                   	push   %eax
 20e:	ff 75 f0             	push   -0x10(%ebp)
 211:	68 5c 0e 00 00       	push   $0xe5c
 216:	6a 01                	push   $0x1
 218:	e8 0d 08 00 00       	call   a2a <printf>
 21d:	83 c4 10             	add    $0x10,%esp
    for (int q = 0; q < 4; q++) {
 220:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 224:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 228:	7e b6                	jle    1e0 <print_proc_info+0x166>
      }
    }

    if (st->priority[i] == 0 && st->ticks[i][0] > 0)
 22a:	8b 45 08             	mov    0x8(%ebp),%eax
 22d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 230:	83 ea 80             	sub    $0xffffff80,%edx
 233:	8b 04 90             	mov    (%eax,%edx,4),%eax
 236:	85 c0                	test   %eax,%eax
 238:	75 39                	jne    273 <print_proc_info+0x1f9>
 23a:	8b 55 08             	mov    0x8(%ebp),%edx
 23d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 240:	83 c0 40             	add    $0x40,%eax
 243:	c1 e0 04             	shl    $0x4,%eax
 246:	01 d0                	add    %edx,%eax
 248:	8b 00                	mov    (%eax),%eax
 24a:	85 c0                	test   %eax,%eax
 24c:	7e 25                	jle    273 <print_proc_info+0x1f9>
      printf(1, "  pid %d demoted to Q0\n", st->pid[i]);
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
 251:	8b 55 f4             	mov    -0xc(%ebp),%edx
 254:	83 c2 40             	add    $0x40,%edx
 257:	8b 04 90             	mov    (%eax,%edx,4),%eax
 25a:	83 ec 04             	sub    $0x4,%esp
 25d:	50                   	push   %eax
 25e:	68 9f 0e 00 00       	push   $0xe9f
 263:	6a 01                	push   $0x1
 265:	e8 c0 07 00 00       	call   a2a <printf>
 26a:	83 c4 10             	add    $0x10,%esp
 26d:	eb 04                	jmp    273 <print_proc_info+0x1f9>
    if (!st->inuse[i]) continue;
 26f:	90                   	nop
 270:	eb 01                	jmp    273 <print_proc_info+0x1f9>
    if (!is_child(st->pid[i], child_pid, count)) continue;
 272:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
 273:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 277:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 27b:	0f 8e 3e fe ff ff    	jle    bf <print_proc_info+0x45>
  }
}
 281:	90                   	nop
 282:	90                   	nop
 283:	8d 65 f8             	lea    -0x8(%ebp),%esp
 286:	5b                   	pop    %ebx
 287:	5e                   	pop    %esi
 288:	5d                   	pop    %ebp
 289:	c3                   	ret    

0000028a <measure_workload_unit>:


// tick을 1 증가시키는 workload 단위 측정 함수
int measure_workload_unit() {
 28a:	55                   	push   %ebp
 28b:	89 e5                	mov    %esp,%ebp
 28d:	81 ec 28 0c 00 00    	sub    $0xc28,%esp
  struct pstat st;
  int pid = getpid(), t0 = -1, t1 = -1;
 293:	e8 76 06 00 00       	call   90e <getpid>
 298:	89 45 e0             	mov    %eax,-0x20(%ebp)
 29b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
 2a2:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)

  for (int n = 10000; n <= 300000; n += 5000) {
 2a9:	c7 45 ec 10 27 00 00 	movl   $0x2710,-0x14(%ebp)
 2b0:	e9 49 01 00 00       	jmp    3fe <measure_workload_unit+0x174>
    getpinfo(&st);
 2b5:	83 ec 0c             	sub    $0xc,%esp
 2b8:	8d 85 e0 f3 ff ff    	lea    -0xc20(%ebp),%eax
 2be:	50                   	push   %eax
 2bf:	e8 7a 06 00 00       	call   93e <getpinfo>
 2c4:	83 c4 10             	add    $0x10,%esp
    t0 = -1;
 2c7:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)

    for (int i = 0; i < NPROC; i++) {
 2ce:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 2d5:	eb 3b                	jmp    312 <measure_workload_unit+0x88>
      if (st.inuse[i] && st.pid[i] == pid) {
 2d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 2da:	8b 84 85 e0 f3 ff ff 	mov    -0xc20(%ebp,%eax,4),%eax
 2e1:	85 c0                	test   %eax,%eax
 2e3:	74 29                	je     30e <measure_workload_unit+0x84>
 2e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 2e8:	83 c0 40             	add    $0x40,%eax
 2eb:	8b 84 85 e0 f3 ff ff 	mov    -0xc20(%ebp,%eax,4),%eax
 2f2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
 2f5:	75 17                	jne    30e <measure_workload_unit+0x84>
        t0 = st.ticks[i][3];
 2f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 2fa:	c1 e0 04             	shl    $0x4,%eax
 2fd:	8d 40 f8             	lea    -0x8(%eax),%eax
 300:	01 e8                	add    %ebp,%eax
 302:	2d 0c 08 00 00       	sub    $0x80c,%eax
 307:	8b 00                	mov    (%eax),%eax
 309:	89 45 f4             	mov    %eax,-0xc(%ebp)
        break;
 30c:	eb 0a                	jmp    318 <measure_workload_unit+0x8e>
    for (int i = 0; i < NPROC; i++) {
 30e:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
 312:	83 7d e8 3f          	cmpl   $0x3f,-0x18(%ebp)
 316:	7e bf                	jle    2d7 <measure_workload_unit+0x4d>
      }
    }

    if (t0 < 0) {
 318:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 31c:	79 1a                	jns    338 <measure_workload_unit+0xae>
      printf(1, "❌ t0 not found at n=%d\n", n);
 31e:	83 ec 04             	sub    $0x4,%esp
 321:	ff 75 ec             	push   -0x14(%ebp)
 324:	68 b7 0e 00 00       	push   $0xeb7
 329:	6a 01                	push   $0x1
 32b:	e8 fa 06 00 00       	call   a2a <printf>
 330:	83 c4 10             	add    $0x10,%esp
      continue;
 333:	e9 bf 00 00 00       	jmp    3f7 <measure_workload_unit+0x16d>
    }

    volatile int tmp = workload(n);
 338:	83 ec 0c             	sub    $0xc,%esp
 33b:	ff 75 ec             	push   -0x14(%ebp)
 33e:	e8 bd fc ff ff       	call   0 <workload>
 343:	83 c4 10             	add    $0x10,%esp
 346:	89 85 dc f3 ff ff    	mov    %eax,-0xc24(%ebp)
    tmp += 0;
 34c:	8b 85 dc f3 ff ff    	mov    -0xc24(%ebp),%eax
 352:	89 85 dc f3 ff ff    	mov    %eax,-0xc24(%ebp)
    sleep(10);  // 충분히 tick 반영 시간 확보
 358:	83 ec 0c             	sub    $0xc,%esp
 35b:	6a 0a                	push   $0xa
 35d:	e8 bc 05 00 00       	call   91e <sleep>
 362:	83 c4 10             	add    $0x10,%esp

    getpinfo(&st);
 365:	83 ec 0c             	sub    $0xc,%esp
 368:	8d 85 e0 f3 ff ff    	lea    -0xc20(%ebp),%eax
 36e:	50                   	push   %eax
 36f:	e8 ca 05 00 00       	call   93e <getpinfo>
 374:	83 c4 10             	add    $0x10,%esp
    t1 = -1;
 377:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
    for (int i = 0; i < NPROC; i++) {
 37e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 385:	eb 3b                	jmp    3c2 <measure_workload_unit+0x138>
      if (st.inuse[i] && st.pid[i] == pid) {
 387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 38a:	8b 84 85 e0 f3 ff ff 	mov    -0xc20(%ebp,%eax,4),%eax
 391:	85 c0                	test   %eax,%eax
 393:	74 29                	je     3be <measure_workload_unit+0x134>
 395:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 398:	83 c0 40             	add    $0x40,%eax
 39b:	8b 84 85 e0 f3 ff ff 	mov    -0xc20(%ebp,%eax,4),%eax
 3a2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
 3a5:	75 17                	jne    3be <measure_workload_unit+0x134>
        t1 = st.ticks[i][3];
 3a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3aa:	c1 e0 04             	shl    $0x4,%eax
 3ad:	8d 40 f8             	lea    -0x8(%eax),%eax
 3b0:	01 e8                	add    %ebp,%eax
 3b2:	2d 0c 08 00 00       	sub    $0x80c,%eax
 3b7:	8b 00                	mov    (%eax),%eax
 3b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
        break;
 3bc:	eb 0a                	jmp    3c8 <measure_workload_unit+0x13e>
    for (int i = 0; i < NPROC; i++) {
 3be:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 3c2:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 3c6:	7e bf                	jle    387 <measure_workload_unit+0xfd>
      }
    }

    if (t1 < 0) continue;
 3c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3cc:	78 28                	js     3f6 <measure_workload_unit+0x16c>
    if (t1 > t0) {
 3ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 3d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 3d4:	7e 21                	jle    3f7 <measure_workload_unit+0x16d>
      printf(1, "✅ workload(%d) → tick 증가 (%d → %d)\n", n, t0, t1);
 3d6:	83 ec 0c             	sub    $0xc,%esp
 3d9:	ff 75 f0             	push   -0x10(%ebp)
 3dc:	ff 75 f4             	push   -0xc(%ebp)
 3df:	ff 75 ec             	push   -0x14(%ebp)
 3e2:	68 d4 0e 00 00       	push   $0xed4
 3e7:	6a 01                	push   $0x1
 3e9:	e8 3c 06 00 00       	call   a2a <printf>
 3ee:	83 c4 20             	add    $0x20,%esp
      return n;
 3f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f4:	eb 2c                	jmp    422 <measure_workload_unit+0x198>
    if (t1 < 0) continue;
 3f6:	90                   	nop
  for (int n = 10000; n <= 300000; n += 5000) {
 3f7:	81 45 ec 88 13 00 00 	addl   $0x1388,-0x14(%ebp)
 3fe:	81 7d ec e0 93 04 00 	cmpl   $0x493e0,-0x14(%ebp)
 405:	0f 8e aa fe ff ff    	jle    2b5 <measure_workload_unit+0x2b>
    }
  }

  printf(1, "❌ tick 증가 확인 실패 (n 범위 초과)\n");
 40b:	83 ec 08             	sub    $0x8,%esp
 40e:	68 04 0f 00 00       	push   $0xf04
 413:	6a 01                	push   $0x1
 415:	e8 10 06 00 00       	call   a2a <printf>
 41a:	83 c4 10             	add    $0x10,%esp
  return -1;
 41d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 422:	c9                   	leave  
 423:	c3                   	ret    

00000424 <main>:



int main(void) {
 424:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 428:	83 e4 f0             	and    $0xfffffff0,%esp
 42b:	ff 71 fc             	push   -0x4(%ecx)
 42e:	55                   	push   %ebp
 42f:	89 e5                	mov    %esp,%ebp
 431:	51                   	push   %ecx
 432:	81 ec 34 0c 00 00    	sub    $0xc34,%esp
  struct pstat st;
  int i, pid;
  int child_pid[4];
  int workload_unit = 4000000;
 438:	c7 45 e8 00 09 3d 00 	movl   $0x3d0900,-0x18(%ebp)
  //int tick_unit = measure_workload_unit();  // workload 단위 측정

  //if (tick_unit < 0) exit();

  setSchedPolicy(3);
 43f:	83 ec 0c             	sub    $0xc,%esp
 442:	6a 03                	push   $0x3
 444:	e8 fd 04 00 00       	call   946 <setSchedPolicy>
 449:	83 c4 10             	add    $0x10,%esp
  printf(1, "✅ setSchedPolicy(3) 적용 완료\n");
 44c:	83 ec 08             	sub    $0x8,%esp
 44f:	68 38 0f 00 00       	push   $0xf38
 454:	6a 01                	push   $0x1
 456:	e8 cf 05 00 00       	call   a2a <printf>
 45b:	83 c4 10             	add    $0x10,%esp

  for (i = 0; i < 4; i++) {
 45e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 465:	e9 d3 00 00 00       	jmp    53d <main+0x119>
    pid = fork();
 46a:	e8 17 04 00 00       	call   886 <fork>
 46f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (pid < 0) {
 472:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 476:	79 1a                	jns    492 <main+0x6e>
      printf(1, "❌ fork failed at i = %d\n", i);
 478:	83 ec 04             	sub    $0x4,%esp
 47b:	ff 75 f4             	push   -0xc(%ebp)
 47e:	68 5d 0f 00 00       	push   $0xf5d
 483:	6a 01                	push   $0x1
 485:	e8 a0 05 00 00       	call   a2a <printf>
 48a:	83 c4 10             	add    $0x10,%esp
 48d:	e9 a7 00 00 00       	jmp    539 <main+0x115>
    } else if (pid == 0) {
 492:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 496:	75 7f                	jne    517 <main+0xf3>
      sleep(300);
 498:	83 ec 0c             	sub    $0xc,%esp
 49b:	68 2c 01 00 00       	push   $0x12c
 4a0:	e8 79 04 00 00       	call   91e <sleep>
 4a5:	83 c4 10             	add    $0x10,%esp
      printf(1, "Child index %d | pid %d\n", i, getpid());
 4a8:	e8 61 04 00 00       	call   90e <getpid>
 4ad:	50                   	push   %eax
 4ae:	ff 75 f4             	push   -0xc(%ebp)
 4b1:	68 78 0f 00 00       	push   $0xf78
 4b6:	6a 01                	push   $0x1
 4b8:	e8 6d 05 00 00       	call   a2a <printf>
 4bd:	83 c4 10             	add    $0x10,%esp

      if (i < 2) {
 4c0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
 4c4:	7f 28                	jg     4ee <main+0xca>
        for (int t = 0; t < 8; t++) {
 4c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4cd:	eb 17                	jmp    4e6 <main+0xc2>
          workload(workload_unit);
 4cf:	83 ec 0c             	sub    $0xc,%esp
 4d2:	ff 75 e8             	push   -0x18(%ebp)
 4d5:	e8 26 fb ff ff       	call   0 <workload>
 4da:	83 c4 10             	add    $0x10,%esp
          yield();
 4dd:	e8 6c 04 00 00       	call   94e <yield>
        for (int t = 0; t < 8; t++) {
 4e2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 4e6:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
 4ea:	7e e3                	jle    4cf <main+0xab>
        }
        while (1);  // 계속 RUNNABLE 상태 유지해서 wait_ticks 쌓이게
 4ec:	eb fe                	jmp    4ec <main+0xc8>
      } else {
        for (int t = 0; t < 300; t++) {
 4ee:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 4f5:	eb 12                	jmp    509 <main+0xe5>
          workload(workload_unit);
 4f7:	83 ec 0c             	sub    $0xc,%esp
 4fa:	ff 75 e8             	push   -0x18(%ebp)
 4fd:	e8 fe fa ff ff       	call   0 <workload>
 502:	83 c4 10             	add    $0x10,%esp
        for (int t = 0; t < 300; t++) {
 505:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 509:	81 7d ec 2b 01 00 00 	cmpl   $0x12b,-0x14(%ebp)
 510:	7e e5                	jle    4f7 <main+0xd3>
        }
        exit();
 512:	e8 77 03 00 00       	call   88e <exit>
      }
    } else {
      child_pid[i] = pid;
 517:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 51d:	89 94 85 d4 f3 ff ff 	mov    %edx,-0xc2c(%ebp,%eax,4)
      printf(1, "✅ fork success: child index %d | pid %d\n", i, pid);
 524:	ff 75 e4             	push   -0x1c(%ebp)
 527:	ff 75 f4             	push   -0xc(%ebp)
 52a:	68 94 0f 00 00       	push   $0xf94
 52f:	6a 01                	push   $0x1
 531:	e8 f4 04 00 00       	call   a2a <printf>
 536:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 4; i++) {
 539:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 53d:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 541:	0f 8e 23 ff ff ff    	jle    46a <main+0x46>
    }
  }

  // ⏱ 초기 상태 확인
  getpinfo(&st);
 547:	83 ec 0c             	sub    $0xc,%esp
 54a:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
 550:	50                   	push   %eax
 551:	e8 e8 03 00 00       	call   93e <getpinfo>
 556:	83 c4 10             	add    $0x10,%esp
  print_proc_info(&st, child_pid, 4, "초기 상태");
 559:	68 bf 0f 00 00       	push   $0xfbf
 55e:	6a 04                	push   $0x4
 560:	8d 85 d4 f3 ff ff    	lea    -0xc2c(%ebp),%eax
 566:	50                   	push   %eax
 567:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
 56d:	50                   	push   %eax
 56e:	e8 07 fb ff ff       	call   7a <print_proc_info>
 573:	83 c4 10             	add    $0x10,%esp

  // ⏱ 중간 상태 확인
  sleep(1);
 576:	83 ec 0c             	sub    $0xc,%esp
 579:	6a 01                	push   $0x1
 57b:	e8 9e 03 00 00       	call   91e <sleep>
 580:	83 c4 10             	add    $0x10,%esp
  getpinfo(&st);
 583:	83 ec 0c             	sub    $0xc,%esp
 586:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
 58c:	50                   	push   %eax
 58d:	e8 ac 03 00 00       	call   93e <getpinfo>
 592:	83 c4 10             	add    $0x10,%esp
  print_proc_info(&st, child_pid, 4, "중간 상태");
 595:	68 cd 0f 00 00       	push   $0xfcd
 59a:	6a 04                	push   $0x4
 59c:	8d 85 d4 f3 ff ff    	lea    -0xc2c(%ebp),%eax
 5a2:	50                   	push   %eax
 5a3:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
 5a9:	50                   	push   %eax
 5aa:	e8 cb fa ff ff       	call   7a <print_proc_info>
 5af:	83 c4 10             	add    $0x10,%esp

  // ⏱ 충분히 시간 경과 후 상태 확인
  sleep(2000);
 5b2:	83 ec 0c             	sub    $0xc,%esp
 5b5:	68 d0 07 00 00       	push   $0x7d0
 5ba:	e8 5f 03 00 00       	call   91e <sleep>
 5bf:	83 c4 10             	add    $0x10,%esp
  getpinfo(&st);
 5c2:	83 ec 0c             	sub    $0xc,%esp
 5c5:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
 5cb:	50                   	push   %eax
 5cc:	e8 6d 03 00 00       	call   93e <getpinfo>
 5d1:	83 c4 10             	add    $0x10,%esp
  print_proc_info(&st, child_pid, 4, "충분히 시간 경과 후 상태");
 5d4:	68 dc 0f 00 00       	push   $0xfdc
 5d9:	6a 04                	push   $0x4
 5db:	8d 85 d4 f3 ff ff    	lea    -0xc2c(%ebp),%eax
 5e1:	50                   	push   %eax
 5e2:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
 5e8:	50                   	push   %eax
 5e9:	e8 8c fa ff ff       	call   7a <print_proc_info>
 5ee:	83 c4 10             	add    $0x10,%esp

  // ✅ 무한 루프 중인 자식 종료
  for (i = 0; i < 4; i++) kill(child_pid[i]);
 5f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5f8:	eb 1a                	jmp    614 <main+0x1f0>
 5fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fd:	8b 84 85 d4 f3 ff ff 	mov    -0xc2c(%ebp,%eax,4),%eax
 604:	83 ec 0c             	sub    $0xc,%esp
 607:	50                   	push   %eax
 608:	e8 b1 02 00 00       	call   8be <kill>
 60d:	83 c4 10             	add    $0x10,%esp
 610:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 614:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 618:	7e e0                	jle    5fa <main+0x1d6>

  for (i = 0; i < 4; i++) wait();
 61a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 621:	eb 09                	jmp    62c <main+0x208>
 623:	e8 6e 02 00 00       	call   896 <wait>
 628:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 62c:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 630:	7e f1                	jle    623 <main+0x1ff>

  exit();
 632:	e8 57 02 00 00       	call   88e <exit>

00000637 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 637:	55                   	push   %ebp
 638:	89 e5                	mov    %esp,%ebp
 63a:	57                   	push   %edi
 63b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 63c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 63f:	8b 55 10             	mov    0x10(%ebp),%edx
 642:	8b 45 0c             	mov    0xc(%ebp),%eax
 645:	89 cb                	mov    %ecx,%ebx
 647:	89 df                	mov    %ebx,%edi
 649:	89 d1                	mov    %edx,%ecx
 64b:	fc                   	cld    
 64c:	f3 aa                	rep stos %al,%es:(%edi)
 64e:	89 ca                	mov    %ecx,%edx
 650:	89 fb                	mov    %edi,%ebx
 652:	89 5d 08             	mov    %ebx,0x8(%ebp)
 655:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 658:	90                   	nop
 659:	5b                   	pop    %ebx
 65a:	5f                   	pop    %edi
 65b:	5d                   	pop    %ebp
 65c:	c3                   	ret    

0000065d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 65d:	55                   	push   %ebp
 65e:	89 e5                	mov    %esp,%ebp
 660:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 663:	8b 45 08             	mov    0x8(%ebp),%eax
 666:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 669:	90                   	nop
 66a:	8b 55 0c             	mov    0xc(%ebp),%edx
 66d:	8d 42 01             	lea    0x1(%edx),%eax
 670:	89 45 0c             	mov    %eax,0xc(%ebp)
 673:	8b 45 08             	mov    0x8(%ebp),%eax
 676:	8d 48 01             	lea    0x1(%eax),%ecx
 679:	89 4d 08             	mov    %ecx,0x8(%ebp)
 67c:	0f b6 12             	movzbl (%edx),%edx
 67f:	88 10                	mov    %dl,(%eax)
 681:	0f b6 00             	movzbl (%eax),%eax
 684:	84 c0                	test   %al,%al
 686:	75 e2                	jne    66a <strcpy+0xd>
    ;
  return os;
 688:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 68b:	c9                   	leave  
 68c:	c3                   	ret    

0000068d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 68d:	55                   	push   %ebp
 68e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 690:	eb 08                	jmp    69a <strcmp+0xd>
    p++, q++;
 692:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 696:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 69a:	8b 45 08             	mov    0x8(%ebp),%eax
 69d:	0f b6 00             	movzbl (%eax),%eax
 6a0:	84 c0                	test   %al,%al
 6a2:	74 10                	je     6b4 <strcmp+0x27>
 6a4:	8b 45 08             	mov    0x8(%ebp),%eax
 6a7:	0f b6 10             	movzbl (%eax),%edx
 6aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ad:	0f b6 00             	movzbl (%eax),%eax
 6b0:	38 c2                	cmp    %al,%dl
 6b2:	74 de                	je     692 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 6b4:	8b 45 08             	mov    0x8(%ebp),%eax
 6b7:	0f b6 00             	movzbl (%eax),%eax
 6ba:	0f b6 d0             	movzbl %al,%edx
 6bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c0:	0f b6 00             	movzbl (%eax),%eax
 6c3:	0f b6 c8             	movzbl %al,%ecx
 6c6:	89 d0                	mov    %edx,%eax
 6c8:	29 c8                	sub    %ecx,%eax
}
 6ca:	5d                   	pop    %ebp
 6cb:	c3                   	ret    

000006cc <strlen>:

uint
strlen(char *s)
{
 6cc:	55                   	push   %ebp
 6cd:	89 e5                	mov    %esp,%ebp
 6cf:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 6d2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 6d9:	eb 04                	jmp    6df <strlen+0x13>
 6db:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 6df:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6e2:	8b 45 08             	mov    0x8(%ebp),%eax
 6e5:	01 d0                	add    %edx,%eax
 6e7:	0f b6 00             	movzbl (%eax),%eax
 6ea:	84 c0                	test   %al,%al
 6ec:	75 ed                	jne    6db <strlen+0xf>
    ;
  return n;
 6ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6f1:	c9                   	leave  
 6f2:	c3                   	ret    

000006f3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 6f3:	55                   	push   %ebp
 6f4:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 6f6:	8b 45 10             	mov    0x10(%ebp),%eax
 6f9:	50                   	push   %eax
 6fa:	ff 75 0c             	push   0xc(%ebp)
 6fd:	ff 75 08             	push   0x8(%ebp)
 700:	e8 32 ff ff ff       	call   637 <stosb>
 705:	83 c4 0c             	add    $0xc,%esp
  return dst;
 708:	8b 45 08             	mov    0x8(%ebp),%eax
}
 70b:	c9                   	leave  
 70c:	c3                   	ret    

0000070d <strchr>:

char*
strchr(const char *s, char c)
{
 70d:	55                   	push   %ebp
 70e:	89 e5                	mov    %esp,%ebp
 710:	83 ec 04             	sub    $0x4,%esp
 713:	8b 45 0c             	mov    0xc(%ebp),%eax
 716:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 719:	eb 14                	jmp    72f <strchr+0x22>
    if(*s == c)
 71b:	8b 45 08             	mov    0x8(%ebp),%eax
 71e:	0f b6 00             	movzbl (%eax),%eax
 721:	38 45 fc             	cmp    %al,-0x4(%ebp)
 724:	75 05                	jne    72b <strchr+0x1e>
      return (char*)s;
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	eb 13                	jmp    73e <strchr+0x31>
  for(; *s; s++)
 72b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 72f:	8b 45 08             	mov    0x8(%ebp),%eax
 732:	0f b6 00             	movzbl (%eax),%eax
 735:	84 c0                	test   %al,%al
 737:	75 e2                	jne    71b <strchr+0xe>
  return 0;
 739:	b8 00 00 00 00       	mov    $0x0,%eax
}
 73e:	c9                   	leave  
 73f:	c3                   	ret    

00000740 <gets>:

char*
gets(char *buf, int max)
{
 740:	55                   	push   %ebp
 741:	89 e5                	mov    %esp,%ebp
 743:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 746:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 74d:	eb 42                	jmp    791 <gets+0x51>
    cc = read(0, &c, 1);
 74f:	83 ec 04             	sub    $0x4,%esp
 752:	6a 01                	push   $0x1
 754:	8d 45 ef             	lea    -0x11(%ebp),%eax
 757:	50                   	push   %eax
 758:	6a 00                	push   $0x0
 75a:	e8 47 01 00 00       	call   8a6 <read>
 75f:	83 c4 10             	add    $0x10,%esp
 762:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 765:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 769:	7e 33                	jle    79e <gets+0x5e>
      break;
    buf[i++] = c;
 76b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76e:	8d 50 01             	lea    0x1(%eax),%edx
 771:	89 55 f4             	mov    %edx,-0xc(%ebp)
 774:	89 c2                	mov    %eax,%edx
 776:	8b 45 08             	mov    0x8(%ebp),%eax
 779:	01 c2                	add    %eax,%edx
 77b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 77f:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 781:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 785:	3c 0a                	cmp    $0xa,%al
 787:	74 16                	je     79f <gets+0x5f>
 789:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 78d:	3c 0d                	cmp    $0xd,%al
 78f:	74 0e                	je     79f <gets+0x5f>
  for(i=0; i+1 < max; ){
 791:	8b 45 f4             	mov    -0xc(%ebp),%eax
 794:	83 c0 01             	add    $0x1,%eax
 797:	39 45 0c             	cmp    %eax,0xc(%ebp)
 79a:	7f b3                	jg     74f <gets+0xf>
 79c:	eb 01                	jmp    79f <gets+0x5f>
      break;
 79e:	90                   	nop
      break;
  }
  buf[i] = '\0';
 79f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 7a2:	8b 45 08             	mov    0x8(%ebp),%eax
 7a5:	01 d0                	add    %edx,%eax
 7a7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 7aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7ad:	c9                   	leave  
 7ae:	c3                   	ret    

000007af <stat>:

int
stat(char *n, struct stat *st)
{
 7af:	55                   	push   %ebp
 7b0:	89 e5                	mov    %esp,%ebp
 7b2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7b5:	83 ec 08             	sub    $0x8,%esp
 7b8:	6a 00                	push   $0x0
 7ba:	ff 75 08             	push   0x8(%ebp)
 7bd:	e8 0c 01 00 00       	call   8ce <open>
 7c2:	83 c4 10             	add    $0x10,%esp
 7c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 7c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7cc:	79 07                	jns    7d5 <stat+0x26>
    return -1;
 7ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 7d3:	eb 25                	jmp    7fa <stat+0x4b>
  r = fstat(fd, st);
 7d5:	83 ec 08             	sub    $0x8,%esp
 7d8:	ff 75 0c             	push   0xc(%ebp)
 7db:	ff 75 f4             	push   -0xc(%ebp)
 7de:	e8 03 01 00 00       	call   8e6 <fstat>
 7e3:	83 c4 10             	add    $0x10,%esp
 7e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 7e9:	83 ec 0c             	sub    $0xc,%esp
 7ec:	ff 75 f4             	push   -0xc(%ebp)
 7ef:	e8 c2 00 00 00       	call   8b6 <close>
 7f4:	83 c4 10             	add    $0x10,%esp
  return r;
 7f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 7fa:	c9                   	leave  
 7fb:	c3                   	ret    

000007fc <atoi>:

int
atoi(const char *s)
{
 7fc:	55                   	push   %ebp
 7fd:	89 e5                	mov    %esp,%ebp
 7ff:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 802:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 809:	eb 25                	jmp    830 <atoi+0x34>
    n = n*10 + *s++ - '0';
 80b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 80e:	89 d0                	mov    %edx,%eax
 810:	c1 e0 02             	shl    $0x2,%eax
 813:	01 d0                	add    %edx,%eax
 815:	01 c0                	add    %eax,%eax
 817:	89 c1                	mov    %eax,%ecx
 819:	8b 45 08             	mov    0x8(%ebp),%eax
 81c:	8d 50 01             	lea    0x1(%eax),%edx
 81f:	89 55 08             	mov    %edx,0x8(%ebp)
 822:	0f b6 00             	movzbl (%eax),%eax
 825:	0f be c0             	movsbl %al,%eax
 828:	01 c8                	add    %ecx,%eax
 82a:	83 e8 30             	sub    $0x30,%eax
 82d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 830:	8b 45 08             	mov    0x8(%ebp),%eax
 833:	0f b6 00             	movzbl (%eax),%eax
 836:	3c 2f                	cmp    $0x2f,%al
 838:	7e 0a                	jle    844 <atoi+0x48>
 83a:	8b 45 08             	mov    0x8(%ebp),%eax
 83d:	0f b6 00             	movzbl (%eax),%eax
 840:	3c 39                	cmp    $0x39,%al
 842:	7e c7                	jle    80b <atoi+0xf>
  return n;
 844:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 847:	c9                   	leave  
 848:	c3                   	ret    

00000849 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 849:	55                   	push   %ebp
 84a:	89 e5                	mov    %esp,%ebp
 84c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 84f:	8b 45 08             	mov    0x8(%ebp),%eax
 852:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 855:	8b 45 0c             	mov    0xc(%ebp),%eax
 858:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 85b:	eb 17                	jmp    874 <memmove+0x2b>
    *dst++ = *src++;
 85d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 860:	8d 42 01             	lea    0x1(%edx),%eax
 863:	89 45 f8             	mov    %eax,-0x8(%ebp)
 866:	8b 45 fc             	mov    -0x4(%ebp),%eax
 869:	8d 48 01             	lea    0x1(%eax),%ecx
 86c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 86f:	0f b6 12             	movzbl (%edx),%edx
 872:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 874:	8b 45 10             	mov    0x10(%ebp),%eax
 877:	8d 50 ff             	lea    -0x1(%eax),%edx
 87a:	89 55 10             	mov    %edx,0x10(%ebp)
 87d:	85 c0                	test   %eax,%eax
 87f:	7f dc                	jg     85d <memmove+0x14>
  return vdst;
 881:	8b 45 08             	mov    0x8(%ebp),%eax
}
 884:	c9                   	leave  
 885:	c3                   	ret    

00000886 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 886:	b8 01 00 00 00       	mov    $0x1,%eax
 88b:	cd 40                	int    $0x40
 88d:	c3                   	ret    

0000088e <exit>:
SYSCALL(exit)
 88e:	b8 02 00 00 00       	mov    $0x2,%eax
 893:	cd 40                	int    $0x40
 895:	c3                   	ret    

00000896 <wait>:
SYSCALL(wait)
 896:	b8 03 00 00 00       	mov    $0x3,%eax
 89b:	cd 40                	int    $0x40
 89d:	c3                   	ret    

0000089e <pipe>:
SYSCALL(pipe)
 89e:	b8 04 00 00 00       	mov    $0x4,%eax
 8a3:	cd 40                	int    $0x40
 8a5:	c3                   	ret    

000008a6 <read>:
SYSCALL(read)
 8a6:	b8 05 00 00 00       	mov    $0x5,%eax
 8ab:	cd 40                	int    $0x40
 8ad:	c3                   	ret    

000008ae <write>:
SYSCALL(write)
 8ae:	b8 10 00 00 00       	mov    $0x10,%eax
 8b3:	cd 40                	int    $0x40
 8b5:	c3                   	ret    

000008b6 <close>:
SYSCALL(close)
 8b6:	b8 15 00 00 00       	mov    $0x15,%eax
 8bb:	cd 40                	int    $0x40
 8bd:	c3                   	ret    

000008be <kill>:
SYSCALL(kill)
 8be:	b8 06 00 00 00       	mov    $0x6,%eax
 8c3:	cd 40                	int    $0x40
 8c5:	c3                   	ret    

000008c6 <exec>:
SYSCALL(exec)
 8c6:	b8 07 00 00 00       	mov    $0x7,%eax
 8cb:	cd 40                	int    $0x40
 8cd:	c3                   	ret    

000008ce <open>:
SYSCALL(open)
 8ce:	b8 0f 00 00 00       	mov    $0xf,%eax
 8d3:	cd 40                	int    $0x40
 8d5:	c3                   	ret    

000008d6 <mknod>:
SYSCALL(mknod)
 8d6:	b8 11 00 00 00       	mov    $0x11,%eax
 8db:	cd 40                	int    $0x40
 8dd:	c3                   	ret    

000008de <unlink>:
SYSCALL(unlink)
 8de:	b8 12 00 00 00       	mov    $0x12,%eax
 8e3:	cd 40                	int    $0x40
 8e5:	c3                   	ret    

000008e6 <fstat>:
SYSCALL(fstat)
 8e6:	b8 08 00 00 00       	mov    $0x8,%eax
 8eb:	cd 40                	int    $0x40
 8ed:	c3                   	ret    

000008ee <link>:
SYSCALL(link)
 8ee:	b8 13 00 00 00       	mov    $0x13,%eax
 8f3:	cd 40                	int    $0x40
 8f5:	c3                   	ret    

000008f6 <mkdir>:
SYSCALL(mkdir)
 8f6:	b8 14 00 00 00       	mov    $0x14,%eax
 8fb:	cd 40                	int    $0x40
 8fd:	c3                   	ret    

000008fe <chdir>:
SYSCALL(chdir)
 8fe:	b8 09 00 00 00       	mov    $0x9,%eax
 903:	cd 40                	int    $0x40
 905:	c3                   	ret    

00000906 <dup>:
SYSCALL(dup)
 906:	b8 0a 00 00 00       	mov    $0xa,%eax
 90b:	cd 40                	int    $0x40
 90d:	c3                   	ret    

0000090e <getpid>:
SYSCALL(getpid)
 90e:	b8 0b 00 00 00       	mov    $0xb,%eax
 913:	cd 40                	int    $0x40
 915:	c3                   	ret    

00000916 <sbrk>:
SYSCALL(sbrk)
 916:	b8 0c 00 00 00       	mov    $0xc,%eax
 91b:	cd 40                	int    $0x40
 91d:	c3                   	ret    

0000091e <sleep>:
SYSCALL(sleep)
 91e:	b8 0d 00 00 00       	mov    $0xd,%eax
 923:	cd 40                	int    $0x40
 925:	c3                   	ret    

00000926 <uptime>:
SYSCALL(uptime)
 926:	b8 0e 00 00 00       	mov    $0xe,%eax
 92b:	cd 40                	int    $0x40
 92d:	c3                   	ret    

0000092e <uthread_init>:

SYSCALL(uthread_init)
 92e:	b8 16 00 00 00       	mov    $0x16,%eax
 933:	cd 40                	int    $0x40
 935:	c3                   	ret    

00000936 <check_thread>:
SYSCALL(check_thread)
 936:	b8 17 00 00 00       	mov    $0x17,%eax
 93b:	cd 40                	int    $0x40
 93d:	c3                   	ret    

0000093e <getpinfo>:

SYSCALL(getpinfo)
 93e:	b8 18 00 00 00       	mov    $0x18,%eax
 943:	cd 40                	int    $0x40
 945:	c3                   	ret    

00000946 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 946:	b8 19 00 00 00       	mov    $0x19,%eax
 94b:	cd 40                	int    $0x40
 94d:	c3                   	ret    

0000094e <yield>:
 94e:	b8 1a 00 00 00       	mov    $0x1a,%eax
 953:	cd 40                	int    $0x40
 955:	c3                   	ret    

00000956 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 956:	55                   	push   %ebp
 957:	89 e5                	mov    %esp,%ebp
 959:	83 ec 18             	sub    $0x18,%esp
 95c:	8b 45 0c             	mov    0xc(%ebp),%eax
 95f:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 962:	83 ec 04             	sub    $0x4,%esp
 965:	6a 01                	push   $0x1
 967:	8d 45 f4             	lea    -0xc(%ebp),%eax
 96a:	50                   	push   %eax
 96b:	ff 75 08             	push   0x8(%ebp)
 96e:	e8 3b ff ff ff       	call   8ae <write>
 973:	83 c4 10             	add    $0x10,%esp
}
 976:	90                   	nop
 977:	c9                   	leave  
 978:	c3                   	ret    

00000979 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 979:	55                   	push   %ebp
 97a:	89 e5                	mov    %esp,%ebp
 97c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 97f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 986:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 98a:	74 17                	je     9a3 <printint+0x2a>
 98c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 990:	79 11                	jns    9a3 <printint+0x2a>
    neg = 1;
 992:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 999:	8b 45 0c             	mov    0xc(%ebp),%eax
 99c:	f7 d8                	neg    %eax
 99e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 9a1:	eb 06                	jmp    9a9 <printint+0x30>
  } else {
    x = xx;
 9a3:	8b 45 0c             	mov    0xc(%ebp),%eax
 9a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 9a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 9b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 9b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9b6:	ba 00 00 00 00       	mov    $0x0,%edx
 9bb:	f7 f1                	div    %ecx
 9bd:	89 d1                	mov    %edx,%ecx
 9bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c2:	8d 50 01             	lea    0x1(%eax),%edx
 9c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 9c8:	0f b6 91 d8 12 00 00 	movzbl 0x12d8(%ecx),%edx
 9cf:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 9d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 9d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9d9:	ba 00 00 00 00       	mov    $0x0,%edx
 9de:	f7 f1                	div    %ecx
 9e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 9e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9e7:	75 c7                	jne    9b0 <printint+0x37>
  if(neg)
 9e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9ed:	74 2d                	je     a1c <printint+0xa3>
    buf[i++] = '-';
 9ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f2:	8d 50 01             	lea    0x1(%eax),%edx
 9f5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 9f8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 9fd:	eb 1d                	jmp    a1c <printint+0xa3>
    putc(fd, buf[i]);
 9ff:	8d 55 dc             	lea    -0x24(%ebp),%edx
 a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a05:	01 d0                	add    %edx,%eax
 a07:	0f b6 00             	movzbl (%eax),%eax
 a0a:	0f be c0             	movsbl %al,%eax
 a0d:	83 ec 08             	sub    $0x8,%esp
 a10:	50                   	push   %eax
 a11:	ff 75 08             	push   0x8(%ebp)
 a14:	e8 3d ff ff ff       	call   956 <putc>
 a19:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 a1c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 a20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a24:	79 d9                	jns    9ff <printint+0x86>
}
 a26:	90                   	nop
 a27:	90                   	nop
 a28:	c9                   	leave  
 a29:	c3                   	ret    

00000a2a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 a2a:	55                   	push   %ebp
 a2b:	89 e5                	mov    %esp,%ebp
 a2d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 a30:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 a37:	8d 45 0c             	lea    0xc(%ebp),%eax
 a3a:	83 c0 04             	add    $0x4,%eax
 a3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 a40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 a47:	e9 59 01 00 00       	jmp    ba5 <printf+0x17b>
    c = fmt[i] & 0xff;
 a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
 a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a52:	01 d0                	add    %edx,%eax
 a54:	0f b6 00             	movzbl (%eax),%eax
 a57:	0f be c0             	movsbl %al,%eax
 a5a:	25 ff 00 00 00       	and    $0xff,%eax
 a5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a62:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a66:	75 2c                	jne    a94 <printf+0x6a>
      if(c == '%'){
 a68:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a6c:	75 0c                	jne    a7a <printf+0x50>
        state = '%';
 a6e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a75:	e9 27 01 00 00       	jmp    ba1 <printf+0x177>
      } else {
        putc(fd, c);
 a7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a7d:	0f be c0             	movsbl %al,%eax
 a80:	83 ec 08             	sub    $0x8,%esp
 a83:	50                   	push   %eax
 a84:	ff 75 08             	push   0x8(%ebp)
 a87:	e8 ca fe ff ff       	call   956 <putc>
 a8c:	83 c4 10             	add    $0x10,%esp
 a8f:	e9 0d 01 00 00       	jmp    ba1 <printf+0x177>
      }
    } else if(state == '%'){
 a94:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a98:	0f 85 03 01 00 00    	jne    ba1 <printf+0x177>
      if(c == 'd'){
 a9e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 aa2:	75 1e                	jne    ac2 <printf+0x98>
        printint(fd, *ap, 10, 1);
 aa4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 aa7:	8b 00                	mov    (%eax),%eax
 aa9:	6a 01                	push   $0x1
 aab:	6a 0a                	push   $0xa
 aad:	50                   	push   %eax
 aae:	ff 75 08             	push   0x8(%ebp)
 ab1:	e8 c3 fe ff ff       	call   979 <printint>
 ab6:	83 c4 10             	add    $0x10,%esp
        ap++;
 ab9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 abd:	e9 d8 00 00 00       	jmp    b9a <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 ac2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 ac6:	74 06                	je     ace <printf+0xa4>
 ac8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 acc:	75 1e                	jne    aec <printf+0xc2>
        printint(fd, *ap, 16, 0);
 ace:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ad1:	8b 00                	mov    (%eax),%eax
 ad3:	6a 00                	push   $0x0
 ad5:	6a 10                	push   $0x10
 ad7:	50                   	push   %eax
 ad8:	ff 75 08             	push   0x8(%ebp)
 adb:	e8 99 fe ff ff       	call   979 <printint>
 ae0:	83 c4 10             	add    $0x10,%esp
        ap++;
 ae3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 ae7:	e9 ae 00 00 00       	jmp    b9a <printf+0x170>
      } else if(c == 's'){
 aec:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 af0:	75 43                	jne    b35 <printf+0x10b>
        s = (char*)*ap;
 af2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 af5:	8b 00                	mov    (%eax),%eax
 af7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 afa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 afe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b02:	75 25                	jne    b29 <printf+0xff>
          s = "(null)";
 b04:	c7 45 f4 ff 0f 00 00 	movl   $0xfff,-0xc(%ebp)
        while(*s != 0){
 b0b:	eb 1c                	jmp    b29 <printf+0xff>
          putc(fd, *s);
 b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b10:	0f b6 00             	movzbl (%eax),%eax
 b13:	0f be c0             	movsbl %al,%eax
 b16:	83 ec 08             	sub    $0x8,%esp
 b19:	50                   	push   %eax
 b1a:	ff 75 08             	push   0x8(%ebp)
 b1d:	e8 34 fe ff ff       	call   956 <putc>
 b22:	83 c4 10             	add    $0x10,%esp
          s++;
 b25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2c:	0f b6 00             	movzbl (%eax),%eax
 b2f:	84 c0                	test   %al,%al
 b31:	75 da                	jne    b0d <printf+0xe3>
 b33:	eb 65                	jmp    b9a <printf+0x170>
        }
      } else if(c == 'c'){
 b35:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 b39:	75 1d                	jne    b58 <printf+0x12e>
        putc(fd, *ap);
 b3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b3e:	8b 00                	mov    (%eax),%eax
 b40:	0f be c0             	movsbl %al,%eax
 b43:	83 ec 08             	sub    $0x8,%esp
 b46:	50                   	push   %eax
 b47:	ff 75 08             	push   0x8(%ebp)
 b4a:	e8 07 fe ff ff       	call   956 <putc>
 b4f:	83 c4 10             	add    $0x10,%esp
        ap++;
 b52:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b56:	eb 42                	jmp    b9a <printf+0x170>
      } else if(c == '%'){
 b58:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b5c:	75 17                	jne    b75 <printf+0x14b>
        putc(fd, c);
 b5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b61:	0f be c0             	movsbl %al,%eax
 b64:	83 ec 08             	sub    $0x8,%esp
 b67:	50                   	push   %eax
 b68:	ff 75 08             	push   0x8(%ebp)
 b6b:	e8 e6 fd ff ff       	call   956 <putc>
 b70:	83 c4 10             	add    $0x10,%esp
 b73:	eb 25                	jmp    b9a <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b75:	83 ec 08             	sub    $0x8,%esp
 b78:	6a 25                	push   $0x25
 b7a:	ff 75 08             	push   0x8(%ebp)
 b7d:	e8 d4 fd ff ff       	call   956 <putc>
 b82:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 b85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b88:	0f be c0             	movsbl %al,%eax
 b8b:	83 ec 08             	sub    $0x8,%esp
 b8e:	50                   	push   %eax
 b8f:	ff 75 08             	push   0x8(%ebp)
 b92:	e8 bf fd ff ff       	call   956 <putc>
 b97:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 b9a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 ba1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
 ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bab:	01 d0                	add    %edx,%eax
 bad:	0f b6 00             	movzbl (%eax),%eax
 bb0:	84 c0                	test   %al,%al
 bb2:	0f 85 94 fe ff ff    	jne    a4c <printf+0x22>
    }
  }
}
 bb8:	90                   	nop
 bb9:	90                   	nop
 bba:	c9                   	leave  
 bbb:	c3                   	ret    

00000bbc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bbc:	55                   	push   %ebp
 bbd:	89 e5                	mov    %esp,%ebp
 bbf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bc2:	8b 45 08             	mov    0x8(%ebp),%eax
 bc5:	83 e8 08             	sub    $0x8,%eax
 bc8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bcb:	a1 f4 12 00 00       	mov    0x12f4,%eax
 bd0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bd3:	eb 24                	jmp    bf9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd8:	8b 00                	mov    (%eax),%eax
 bda:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 bdd:	72 12                	jb     bf1 <free+0x35>
 bdf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 be2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 be5:	77 24                	ja     c0b <free+0x4f>
 be7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bea:	8b 00                	mov    (%eax),%eax
 bec:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 bef:	72 1a                	jb     c0b <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf4:	8b 00                	mov    (%eax),%eax
 bf6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bf9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bfc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bff:	76 d4                	jbe    bd5 <free+0x19>
 c01:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c04:	8b 00                	mov    (%eax),%eax
 c06:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 c09:	73 ca                	jae    bd5 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 c0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c0e:	8b 40 04             	mov    0x4(%eax),%eax
 c11:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c18:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c1b:	01 c2                	add    %eax,%edx
 c1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c20:	8b 00                	mov    (%eax),%eax
 c22:	39 c2                	cmp    %eax,%edx
 c24:	75 24                	jne    c4a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 c26:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c29:	8b 50 04             	mov    0x4(%eax),%edx
 c2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c2f:	8b 00                	mov    (%eax),%eax
 c31:	8b 40 04             	mov    0x4(%eax),%eax
 c34:	01 c2                	add    %eax,%edx
 c36:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c39:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c3f:	8b 00                	mov    (%eax),%eax
 c41:	8b 10                	mov    (%eax),%edx
 c43:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c46:	89 10                	mov    %edx,(%eax)
 c48:	eb 0a                	jmp    c54 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 c4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c4d:	8b 10                	mov    (%eax),%edx
 c4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c52:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 c54:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c57:	8b 40 04             	mov    0x4(%eax),%eax
 c5a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c61:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c64:	01 d0                	add    %edx,%eax
 c66:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 c69:	75 20                	jne    c8b <free+0xcf>
    p->s.size += bp->s.size;
 c6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c6e:	8b 50 04             	mov    0x4(%eax),%edx
 c71:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c74:	8b 40 04             	mov    0x4(%eax),%eax
 c77:	01 c2                	add    %eax,%edx
 c79:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c7c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c82:	8b 10                	mov    (%eax),%edx
 c84:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c87:	89 10                	mov    %edx,(%eax)
 c89:	eb 08                	jmp    c93 <free+0xd7>
  } else
    p->s.ptr = bp;
 c8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c8e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 c91:	89 10                	mov    %edx,(%eax)
  freep = p;
 c93:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c96:	a3 f4 12 00 00       	mov    %eax,0x12f4
}
 c9b:	90                   	nop
 c9c:	c9                   	leave  
 c9d:	c3                   	ret    

00000c9e <morecore>:

static Header*
morecore(uint nu)
{
 c9e:	55                   	push   %ebp
 c9f:	89 e5                	mov    %esp,%ebp
 ca1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 ca4:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 cab:	77 07                	ja     cb4 <morecore+0x16>
    nu = 4096;
 cad:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 cb4:	8b 45 08             	mov    0x8(%ebp),%eax
 cb7:	c1 e0 03             	shl    $0x3,%eax
 cba:	83 ec 0c             	sub    $0xc,%esp
 cbd:	50                   	push   %eax
 cbe:	e8 53 fc ff ff       	call   916 <sbrk>
 cc3:	83 c4 10             	add    $0x10,%esp
 cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 cc9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ccd:	75 07                	jne    cd6 <morecore+0x38>
    return 0;
 ccf:	b8 00 00 00 00       	mov    $0x0,%eax
 cd4:	eb 26                	jmp    cfc <morecore+0x5e>
  hp = (Header*)p;
 cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 cdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cdf:	8b 55 08             	mov    0x8(%ebp),%edx
 ce2:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ce8:	83 c0 08             	add    $0x8,%eax
 ceb:	83 ec 0c             	sub    $0xc,%esp
 cee:	50                   	push   %eax
 cef:	e8 c8 fe ff ff       	call   bbc <free>
 cf4:	83 c4 10             	add    $0x10,%esp
  return freep;
 cf7:	a1 f4 12 00 00       	mov    0x12f4,%eax
}
 cfc:	c9                   	leave  
 cfd:	c3                   	ret    

00000cfe <malloc>:

void*
malloc(uint nbytes)
{
 cfe:	55                   	push   %ebp
 cff:	89 e5                	mov    %esp,%ebp
 d01:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d04:	8b 45 08             	mov    0x8(%ebp),%eax
 d07:	83 c0 07             	add    $0x7,%eax
 d0a:	c1 e8 03             	shr    $0x3,%eax
 d0d:	83 c0 01             	add    $0x1,%eax
 d10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 d13:	a1 f4 12 00 00       	mov    0x12f4,%eax
 d18:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 d1f:	75 23                	jne    d44 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 d21:	c7 45 f0 ec 12 00 00 	movl   $0x12ec,-0x10(%ebp)
 d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d2b:	a3 f4 12 00 00       	mov    %eax,0x12f4
 d30:	a1 f4 12 00 00       	mov    0x12f4,%eax
 d35:	a3 ec 12 00 00       	mov    %eax,0x12ec
    base.s.size = 0;
 d3a:	c7 05 f0 12 00 00 00 	movl   $0x0,0x12f0
 d41:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d47:	8b 00                	mov    (%eax),%eax
 d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d4f:	8b 40 04             	mov    0x4(%eax),%eax
 d52:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 d55:	77 4d                	ja     da4 <malloc+0xa6>
      if(p->s.size == nunits)
 d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d5a:	8b 40 04             	mov    0x4(%eax),%eax
 d5d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 d60:	75 0c                	jne    d6e <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d65:	8b 10                	mov    (%eax),%edx
 d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d6a:	89 10                	mov    %edx,(%eax)
 d6c:	eb 26                	jmp    d94 <malloc+0x96>
      else {
        p->s.size -= nunits;
 d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d71:	8b 40 04             	mov    0x4(%eax),%eax
 d74:	2b 45 ec             	sub    -0x14(%ebp),%eax
 d77:	89 c2                	mov    %eax,%edx
 d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d7c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d82:	8b 40 04             	mov    0x4(%eax),%eax
 d85:	c1 e0 03             	shl    $0x3,%eax
 d88:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d8e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 d91:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d97:	a3 f4 12 00 00       	mov    %eax,0x12f4
      return (void*)(p + 1);
 d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d9f:	83 c0 08             	add    $0x8,%eax
 da2:	eb 3b                	jmp    ddf <malloc+0xe1>
    }
    if(p == freep)
 da4:	a1 f4 12 00 00       	mov    0x12f4,%eax
 da9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 dac:	75 1e                	jne    dcc <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 dae:	83 ec 0c             	sub    $0xc,%esp
 db1:	ff 75 ec             	push   -0x14(%ebp)
 db4:	e8 e5 fe ff ff       	call   c9e <morecore>
 db9:	83 c4 10             	add    $0x10,%esp
 dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 dbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 dc3:	75 07                	jne    dcc <malloc+0xce>
        return 0;
 dc5:	b8 00 00 00 00       	mov    $0x0,%eax
 dca:	eb 13                	jmp    ddf <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dd5:	8b 00                	mov    (%eax),%eax
 dd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 dda:	e9 6d ff ff ff       	jmp    d4c <malloc+0x4e>
  }
}
 ddf:	c9                   	leave  
 de0:	c3                   	ret    
