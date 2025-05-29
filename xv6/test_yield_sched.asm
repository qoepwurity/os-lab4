
_test_yield_sched:     file format elf32-i386


Disassembly of section .text:

00000000 <do_yield_work>:
#include "types.h"
#include "user.h"
#include "pstat.h"

void do_yield_work(int count)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int i, j = 0;
   6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for (i = 0; i < count; i++)
   d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  14:	eb 16                	jmp    2c <do_yield_work+0x2c>
  {
    j += i * j + 1;
  16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  19:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f0             	add    %eax,-0x10(%ebp)
    yield(); // 📌 매 루프마다 CPU 양보
  23:	e8 18 05 00 00       	call   540 <yield>
  for (i = 0; i < count; i++)
  28:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2f:	3b 45 08             	cmp    0x8(%ebp),%eax
  32:	7c e2                	jl     16 <do_yield_work+0x16>
  }
}
  34:	90                   	nop
  35:	90                   	nop
  36:	c9                   	leave  
  37:	c3                   	ret    

00000038 <main>:

int main(int argc, char *argv[])
{
  38:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  3c:	83 e4 f0             	and    $0xfffffff0,%esp
  3f:	ff 71 fc             	push   -0x4(%ecx)
  42:	55                   	push   %ebp
  43:	89 e5                	mov    %esp,%ebp
  45:	53                   	push   %ebx
  46:	51                   	push   %ecx
  47:	81 ec 10 0c 00 00    	sub    $0xc10,%esp
  struct pstat ps;
  int pid;

  int ret = setSchedPolicy(1);
  4d:	83 ec 0c             	sub    $0xc,%esp
  50:	6a 01                	push   $0x1
  52:	e8 e1 04 00 00       	call   538 <setSchedPolicy>
  57:	83 c4 10             	add    $0x10,%esp
  5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(1, "setSchedPolicy(1) returned: %d\n", ret);
  5d:	83 ec 04             	sub    $0x4,%esp
  60:	ff 75 f0             	push   -0x10(%ebp)
  63:	68 dc 09 00 00       	push   $0x9dc
  68:	6a 01                	push   $0x1
  6a:	e8 b5 05 00 00       	call   624 <printf>
  6f:	83 c4 10             	add    $0x10,%esp

  // 스케줄링 정책: MLFQ
  if (setSchedPolicy(1) < 0)
  72:	83 ec 0c             	sub    $0xc,%esp
  75:	6a 01                	push   $0x1
  77:	e8 bc 04 00 00       	call   538 <setSchedPolicy>
  7c:	83 c4 10             	add    $0x10,%esp
  7f:	85 c0                	test   %eax,%eax
  81:	79 17                	jns    9a <main+0x62>
  {
    printf(1, "Failed to set scheduling policy\n");
  83:	83 ec 08             	sub    $0x8,%esp
  86:	68 fc 09 00 00       	push   $0x9fc
  8b:	6a 01                	push   $0x1
  8d:	e8 92 05 00 00       	call   624 <printf>
  92:	83 c4 10             	add    $0x10,%esp
    exit();
  95:	e8 e6 03 00 00       	call   480 <exit>
  }

  pid = fork();
  9a:	e8 d9 03 00 00       	call   478 <fork>
  9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (pid == 0)
  a2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  a6:	75 12                	jne    ba <main+0x82>
  {
    // 자식 프로세스: 일부러 yield 반복
    do_yield_work(50);
  a8:	83 ec 0c             	sub    $0xc,%esp
  ab:	6a 32                	push   $0x32
  ad:	e8 4e ff ff ff       	call   0 <do_yield_work>
  b2:	83 c4 10             	add    $0x10,%esp
    exit();
  b5:	e8 c6 03 00 00       	call   480 <exit>
  }
  else
  {
    wait();     // 여전히 wait 하지만...
  ba:	e8 c9 03 00 00       	call   488 <wait>
    sleep(100); // 추가로 잠깐 더 대기하여 stats 반영되게 함
  bf:	83 ec 0c             	sub    $0xc,%esp
  c2:	6a 64                	push   $0x64
  c4:	e8 47 04 00 00       	call   510 <sleep>
  c9:	83 c4 10             	add    $0x10,%esp
    getpinfo(&ps);
  cc:	83 ec 0c             	sub    $0xc,%esp
  cf:	8d 85 ec f3 ff ff    	lea    -0xc14(%ebp),%eax
  d5:	50                   	push   %eax
  d6:	e8 55 04 00 00       	call   530 <getpinfo>
  db:	83 c4 10             	add    $0x10,%esp
  }

  // getpinfo 확인
  if (getpinfo(&ps) < 0)
  de:	83 ec 0c             	sub    $0xc,%esp
  e1:	8d 85 ec f3 ff ff    	lea    -0xc14(%ebp),%eax
  e7:	50                   	push   %eax
  e8:	e8 43 04 00 00       	call   530 <getpinfo>
  ed:	83 c4 10             	add    $0x10,%esp
  f0:	85 c0                	test   %eax,%eax
  f2:	79 17                	jns    10b <main+0xd3>
  {
    printf(1, "getpinfo failed\n");
  f4:	83 ec 08             	sub    $0x8,%esp
  f7:	68 1d 0a 00 00       	push   $0xa1d
  fc:	6a 01                	push   $0x1
  fe:	e8 21 05 00 00       	call   624 <printf>
 103:	83 c4 10             	add    $0x10,%esp
    exit();
 106:	e8 75 03 00 00       	call   480 <exit>
  }

  // 출력
  int i;
  for (i = 0; i < NPROC; i++)
 10b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 112:	e9 03 01 00 00       	jmp    21a <main+0x1e2>
  {
    if (ps.inuse[i])
 117:	8b 45 f4             	mov    -0xc(%ebp),%eax
 11a:	8b 84 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%eax
 121:	85 c0                	test   %eax,%eax
 123:	0f 84 ed 00 00 00    	je     216 <main+0x1de>
    {
      printf(1, "pid %d | priority %d\n", ps.pid[i], ps.priority[i]);
 129:	8b 45 f4             	mov    -0xc(%ebp),%eax
 12c:	83 e8 80             	sub    $0xffffff80,%eax
 12f:	8b 94 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%edx
 136:	8b 45 f4             	mov    -0xc(%ebp),%eax
 139:	83 c0 40             	add    $0x40,%eax
 13c:	8b 84 85 ec f3 ff ff 	mov    -0xc14(%ebp,%eax,4),%eax
 143:	52                   	push   %edx
 144:	50                   	push   %eax
 145:	68 2e 0a 00 00       	push   $0xa2e
 14a:	6a 01                	push   $0x1
 14c:	e8 d3 04 00 00       	call   624 <printf>
 151:	83 c4 10             	add    $0x10,%esp
      printf(1, "ticks: [%d %d %d %d]\n",
 154:	8b 45 f4             	mov    -0xc(%ebp),%eax
 157:	c1 e0 04             	shl    $0x4,%eax
 15a:	8d 40 f8             	lea    -0x8(%eax),%eax
 15d:	01 e8                	add    %ebp,%eax
 15f:	2d 00 08 00 00       	sub    $0x800,%eax
 164:	8b 18                	mov    (%eax),%ebx
 166:	8b 45 f4             	mov    -0xc(%ebp),%eax
 169:	c1 e0 04             	shl    $0x4,%eax
 16c:	8d 40 f8             	lea    -0x8(%eax),%eax
 16f:	01 e8                	add    %ebp,%eax
 171:	2d 04 08 00 00       	sub    $0x804,%eax
 176:	8b 08                	mov    (%eax),%ecx
 178:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17b:	c1 e0 04             	shl    $0x4,%eax
 17e:	8d 40 f8             	lea    -0x8(%eax),%eax
 181:	01 e8                	add    %ebp,%eax
 183:	2d 08 08 00 00       	sub    $0x808,%eax
 188:	8b 10                	mov    (%eax),%edx
 18a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18d:	83 c0 40             	add    $0x40,%eax
 190:	c1 e0 04             	shl    $0x4,%eax
 193:	8d 40 f8             	lea    -0x8(%eax),%eax
 196:	01 e8                	add    %ebp,%eax
 198:	2d 0c 0c 00 00       	sub    $0xc0c,%eax
 19d:	8b 00                	mov    (%eax),%eax
 19f:	83 ec 08             	sub    $0x8,%esp
 1a2:	53                   	push   %ebx
 1a3:	51                   	push   %ecx
 1a4:	52                   	push   %edx
 1a5:	50                   	push   %eax
 1a6:	68 44 0a 00 00       	push   $0xa44
 1ab:	6a 01                	push   $0x1
 1ad:	e8 72 04 00 00       	call   624 <printf>
 1b2:	83 c4 20             	add    $0x20,%esp
             ps.ticks[i][0], ps.ticks[i][1], ps.ticks[i][2], ps.ticks[i][3]);
      printf(1, "wait_ticks: [%d %d %d %d]\n",
 1b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b8:	c1 e0 04             	shl    $0x4,%eax
 1bb:	8d 40 f8             	lea    -0x8(%eax),%eax
 1be:	01 e8                	add    %ebp,%eax
 1c0:	2d 00 04 00 00       	sub    $0x400,%eax
 1c5:	8b 18                	mov    (%eax),%ebx
 1c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ca:	c1 e0 04             	shl    $0x4,%eax
 1cd:	8d 40 f8             	lea    -0x8(%eax),%eax
 1d0:	01 e8                	add    %ebp,%eax
 1d2:	2d 04 04 00 00       	sub    $0x404,%eax
 1d7:	8b 08                	mov    (%eax),%ecx
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	c1 e0 04             	shl    $0x4,%eax
 1df:	8d 40 f8             	lea    -0x8(%eax),%eax
 1e2:	01 e8                	add    %ebp,%eax
 1e4:	2d 08 04 00 00       	sub    $0x408,%eax
 1e9:	8b 10                	mov    (%eax),%edx
 1eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ee:	83 e8 80             	sub    $0xffffff80,%eax
 1f1:	c1 e0 04             	shl    $0x4,%eax
 1f4:	8d 40 f8             	lea    -0x8(%eax),%eax
 1f7:	01 e8                	add    %ebp,%eax
 1f9:	2d 0c 0c 00 00       	sub    $0xc0c,%eax
 1fe:	8b 00                	mov    (%eax),%eax
 200:	83 ec 08             	sub    $0x8,%esp
 203:	53                   	push   %ebx
 204:	51                   	push   %ecx
 205:	52                   	push   %edx
 206:	50                   	push   %eax
 207:	68 5a 0a 00 00       	push   $0xa5a
 20c:	6a 01                	push   $0x1
 20e:	e8 11 04 00 00       	call   624 <printf>
 213:	83 c4 20             	add    $0x20,%esp
  for (i = 0; i < NPROC; i++)
 216:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 21a:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 21e:	0f 8e f3 fe ff ff    	jle    117 <main+0xdf>
             ps.wait_ticks[i][0], ps.wait_ticks[i][1], ps.wait_ticks[i][2], ps.wait_ticks[i][3]);
    }
  }

  exit();
 224:	e8 57 02 00 00       	call   480 <exit>

00000229 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 229:	55                   	push   %ebp
 22a:	89 e5                	mov    %esp,%ebp
 22c:	57                   	push   %edi
 22d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 22e:	8b 4d 08             	mov    0x8(%ebp),%ecx
 231:	8b 55 10             	mov    0x10(%ebp),%edx
 234:	8b 45 0c             	mov    0xc(%ebp),%eax
 237:	89 cb                	mov    %ecx,%ebx
 239:	89 df                	mov    %ebx,%edi
 23b:	89 d1                	mov    %edx,%ecx
 23d:	fc                   	cld    
 23e:	f3 aa                	rep stos %al,%es:(%edi)
 240:	89 ca                	mov    %ecx,%edx
 242:	89 fb                	mov    %edi,%ebx
 244:	89 5d 08             	mov    %ebx,0x8(%ebp)
 247:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 24a:	90                   	nop
 24b:	5b                   	pop    %ebx
 24c:	5f                   	pop    %edi
 24d:	5d                   	pop    %ebp
 24e:	c3                   	ret    

0000024f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 24f:	55                   	push   %ebp
 250:	89 e5                	mov    %esp,%ebp
 252:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 255:	8b 45 08             	mov    0x8(%ebp),%eax
 258:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 25b:	90                   	nop
 25c:	8b 55 0c             	mov    0xc(%ebp),%edx
 25f:	8d 42 01             	lea    0x1(%edx),%eax
 262:	89 45 0c             	mov    %eax,0xc(%ebp)
 265:	8b 45 08             	mov    0x8(%ebp),%eax
 268:	8d 48 01             	lea    0x1(%eax),%ecx
 26b:	89 4d 08             	mov    %ecx,0x8(%ebp)
 26e:	0f b6 12             	movzbl (%edx),%edx
 271:	88 10                	mov    %dl,(%eax)
 273:	0f b6 00             	movzbl (%eax),%eax
 276:	84 c0                	test   %al,%al
 278:	75 e2                	jne    25c <strcpy+0xd>
    ;
  return os;
 27a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 27d:	c9                   	leave  
 27e:	c3                   	ret    

0000027f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 27f:	55                   	push   %ebp
 280:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 282:	eb 08                	jmp    28c <strcmp+0xd>
    p++, q++;
 284:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 288:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	0f b6 00             	movzbl (%eax),%eax
 292:	84 c0                	test   %al,%al
 294:	74 10                	je     2a6 <strcmp+0x27>
 296:	8b 45 08             	mov    0x8(%ebp),%eax
 299:	0f b6 10             	movzbl (%eax),%edx
 29c:	8b 45 0c             	mov    0xc(%ebp),%eax
 29f:	0f b6 00             	movzbl (%eax),%eax
 2a2:	38 c2                	cmp    %al,%dl
 2a4:	74 de                	je     284 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	0f b6 00             	movzbl (%eax),%eax
 2ac:	0f b6 d0             	movzbl %al,%edx
 2af:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b2:	0f b6 00             	movzbl (%eax),%eax
 2b5:	0f b6 c8             	movzbl %al,%ecx
 2b8:	89 d0                	mov    %edx,%eax
 2ba:	29 c8                	sub    %ecx,%eax
}
 2bc:	5d                   	pop    %ebp
 2bd:	c3                   	ret    

000002be <strlen>:

uint
strlen(char *s)
{
 2be:	55                   	push   %ebp
 2bf:	89 e5                	mov    %esp,%ebp
 2c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2cb:	eb 04                	jmp    2d1 <strlen+0x13>
 2cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
 2d7:	01 d0                	add    %edx,%eax
 2d9:	0f b6 00             	movzbl (%eax),%eax
 2dc:	84 c0                	test   %al,%al
 2de:	75 ed                	jne    2cd <strlen+0xf>
    ;
  return n;
 2e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2e3:	c9                   	leave  
 2e4:	c3                   	ret    

000002e5 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e5:	55                   	push   %ebp
 2e6:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 2e8:	8b 45 10             	mov    0x10(%ebp),%eax
 2eb:	50                   	push   %eax
 2ec:	ff 75 0c             	push   0xc(%ebp)
 2ef:	ff 75 08             	push   0x8(%ebp)
 2f2:	e8 32 ff ff ff       	call   229 <stosb>
 2f7:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2fd:	c9                   	leave  
 2fe:	c3                   	ret    

000002ff <strchr>:

char*
strchr(const char *s, char c)
{
 2ff:	55                   	push   %ebp
 300:	89 e5                	mov    %esp,%ebp
 302:	83 ec 04             	sub    $0x4,%esp
 305:	8b 45 0c             	mov    0xc(%ebp),%eax
 308:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 30b:	eb 14                	jmp    321 <strchr+0x22>
    if(*s == c)
 30d:	8b 45 08             	mov    0x8(%ebp),%eax
 310:	0f b6 00             	movzbl (%eax),%eax
 313:	38 45 fc             	cmp    %al,-0x4(%ebp)
 316:	75 05                	jne    31d <strchr+0x1e>
      return (char*)s;
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	eb 13                	jmp    330 <strchr+0x31>
  for(; *s; s++)
 31d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 321:	8b 45 08             	mov    0x8(%ebp),%eax
 324:	0f b6 00             	movzbl (%eax),%eax
 327:	84 c0                	test   %al,%al
 329:	75 e2                	jne    30d <strchr+0xe>
  return 0;
 32b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <gets>:

char*
gets(char *buf, int max)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 338:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 33f:	eb 42                	jmp    383 <gets+0x51>
    cc = read(0, &c, 1);
 341:	83 ec 04             	sub    $0x4,%esp
 344:	6a 01                	push   $0x1
 346:	8d 45 ef             	lea    -0x11(%ebp),%eax
 349:	50                   	push   %eax
 34a:	6a 00                	push   $0x0
 34c:	e8 47 01 00 00       	call   498 <read>
 351:	83 c4 10             	add    $0x10,%esp
 354:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 357:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 35b:	7e 33                	jle    390 <gets+0x5e>
      break;
    buf[i++] = c;
 35d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 360:	8d 50 01             	lea    0x1(%eax),%edx
 363:	89 55 f4             	mov    %edx,-0xc(%ebp)
 366:	89 c2                	mov    %eax,%edx
 368:	8b 45 08             	mov    0x8(%ebp),%eax
 36b:	01 c2                	add    %eax,%edx
 36d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 371:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 373:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 377:	3c 0a                	cmp    $0xa,%al
 379:	74 16                	je     391 <gets+0x5f>
 37b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 37f:	3c 0d                	cmp    $0xd,%al
 381:	74 0e                	je     391 <gets+0x5f>
  for(i=0; i+1 < max; ){
 383:	8b 45 f4             	mov    -0xc(%ebp),%eax
 386:	83 c0 01             	add    $0x1,%eax
 389:	39 45 0c             	cmp    %eax,0xc(%ebp)
 38c:	7f b3                	jg     341 <gets+0xf>
 38e:	eb 01                	jmp    391 <gets+0x5f>
      break;
 390:	90                   	nop
      break;
  }
  buf[i] = '\0';
 391:	8b 55 f4             	mov    -0xc(%ebp),%edx
 394:	8b 45 08             	mov    0x8(%ebp),%eax
 397:	01 d0                	add    %edx,%eax
 399:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 39f:	c9                   	leave  
 3a0:	c3                   	ret    

000003a1 <stat>:

int
stat(char *n, struct stat *st)
{
 3a1:	55                   	push   %ebp
 3a2:	89 e5                	mov    %esp,%ebp
 3a4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a7:	83 ec 08             	sub    $0x8,%esp
 3aa:	6a 00                	push   $0x0
 3ac:	ff 75 08             	push   0x8(%ebp)
 3af:	e8 0c 01 00 00       	call   4c0 <open>
 3b4:	83 c4 10             	add    $0x10,%esp
 3b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3be:	79 07                	jns    3c7 <stat+0x26>
    return -1;
 3c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3c5:	eb 25                	jmp    3ec <stat+0x4b>
  r = fstat(fd, st);
 3c7:	83 ec 08             	sub    $0x8,%esp
 3ca:	ff 75 0c             	push   0xc(%ebp)
 3cd:	ff 75 f4             	push   -0xc(%ebp)
 3d0:	e8 03 01 00 00       	call   4d8 <fstat>
 3d5:	83 c4 10             	add    $0x10,%esp
 3d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3db:	83 ec 0c             	sub    $0xc,%esp
 3de:	ff 75 f4             	push   -0xc(%ebp)
 3e1:	e8 c2 00 00 00       	call   4a8 <close>
 3e6:	83 c4 10             	add    $0x10,%esp
  return r;
 3e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3ec:	c9                   	leave  
 3ed:	c3                   	ret    

000003ee <atoi>:

int
atoi(const char *s)
{
 3ee:	55                   	push   %ebp
 3ef:	89 e5                	mov    %esp,%ebp
 3f1:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3fb:	eb 25                	jmp    422 <atoi+0x34>
    n = n*10 + *s++ - '0';
 3fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
 400:	89 d0                	mov    %edx,%eax
 402:	c1 e0 02             	shl    $0x2,%eax
 405:	01 d0                	add    %edx,%eax
 407:	01 c0                	add    %eax,%eax
 409:	89 c1                	mov    %eax,%ecx
 40b:	8b 45 08             	mov    0x8(%ebp),%eax
 40e:	8d 50 01             	lea    0x1(%eax),%edx
 411:	89 55 08             	mov    %edx,0x8(%ebp)
 414:	0f b6 00             	movzbl (%eax),%eax
 417:	0f be c0             	movsbl %al,%eax
 41a:	01 c8                	add    %ecx,%eax
 41c:	83 e8 30             	sub    $0x30,%eax
 41f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 422:	8b 45 08             	mov    0x8(%ebp),%eax
 425:	0f b6 00             	movzbl (%eax),%eax
 428:	3c 2f                	cmp    $0x2f,%al
 42a:	7e 0a                	jle    436 <atoi+0x48>
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
 42f:	0f b6 00             	movzbl (%eax),%eax
 432:	3c 39                	cmp    $0x39,%al
 434:	7e c7                	jle    3fd <atoi+0xf>
  return n;
 436:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 439:	c9                   	leave  
 43a:	c3                   	ret    

0000043b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 43b:	55                   	push   %ebp
 43c:	89 e5                	mov    %esp,%ebp
 43e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 441:	8b 45 08             	mov    0x8(%ebp),%eax
 444:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 447:	8b 45 0c             	mov    0xc(%ebp),%eax
 44a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 44d:	eb 17                	jmp    466 <memmove+0x2b>
    *dst++ = *src++;
 44f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 452:	8d 42 01             	lea    0x1(%edx),%eax
 455:	89 45 f8             	mov    %eax,-0x8(%ebp)
 458:	8b 45 fc             	mov    -0x4(%ebp),%eax
 45b:	8d 48 01             	lea    0x1(%eax),%ecx
 45e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 461:	0f b6 12             	movzbl (%edx),%edx
 464:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 466:	8b 45 10             	mov    0x10(%ebp),%eax
 469:	8d 50 ff             	lea    -0x1(%eax),%edx
 46c:	89 55 10             	mov    %edx,0x10(%ebp)
 46f:	85 c0                	test   %eax,%eax
 471:	7f dc                	jg     44f <memmove+0x14>
  return vdst;
 473:	8b 45 08             	mov    0x8(%ebp),%eax
}
 476:	c9                   	leave  
 477:	c3                   	ret    

00000478 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 478:	b8 01 00 00 00       	mov    $0x1,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <exit>:
SYSCALL(exit)
 480:	b8 02 00 00 00       	mov    $0x2,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <wait>:
SYSCALL(wait)
 488:	b8 03 00 00 00       	mov    $0x3,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <pipe>:
SYSCALL(pipe)
 490:	b8 04 00 00 00       	mov    $0x4,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <read>:
SYSCALL(read)
 498:	b8 05 00 00 00       	mov    $0x5,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <write>:
SYSCALL(write)
 4a0:	b8 10 00 00 00       	mov    $0x10,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <close>:
SYSCALL(close)
 4a8:	b8 15 00 00 00       	mov    $0x15,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <kill>:
SYSCALL(kill)
 4b0:	b8 06 00 00 00       	mov    $0x6,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <exec>:
SYSCALL(exec)
 4b8:	b8 07 00 00 00       	mov    $0x7,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <open>:
SYSCALL(open)
 4c0:	b8 0f 00 00 00       	mov    $0xf,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <mknod>:
SYSCALL(mknod)
 4c8:	b8 11 00 00 00       	mov    $0x11,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <unlink>:
SYSCALL(unlink)
 4d0:	b8 12 00 00 00       	mov    $0x12,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <fstat>:
SYSCALL(fstat)
 4d8:	b8 08 00 00 00       	mov    $0x8,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <link>:
SYSCALL(link)
 4e0:	b8 13 00 00 00       	mov    $0x13,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <mkdir>:
SYSCALL(mkdir)
 4e8:	b8 14 00 00 00       	mov    $0x14,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <chdir>:
SYSCALL(chdir)
 4f0:	b8 09 00 00 00       	mov    $0x9,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <dup>:
SYSCALL(dup)
 4f8:	b8 0a 00 00 00       	mov    $0xa,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <getpid>:
SYSCALL(getpid)
 500:	b8 0b 00 00 00       	mov    $0xb,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <sbrk>:
SYSCALL(sbrk)
 508:	b8 0c 00 00 00       	mov    $0xc,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <sleep>:
SYSCALL(sleep)
 510:	b8 0d 00 00 00       	mov    $0xd,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <uptime>:
SYSCALL(uptime)
 518:	b8 0e 00 00 00       	mov    $0xe,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <uthread_init>:

SYSCALL(uthread_init)
 520:	b8 16 00 00 00       	mov    $0x16,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <check_thread>:
SYSCALL(check_thread)
 528:	b8 17 00 00 00       	mov    $0x17,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <getpinfo>:

SYSCALL(getpinfo)
 530:	b8 18 00 00 00       	mov    $0x18,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 538:	b8 19 00 00 00       	mov    $0x19,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <yield>:
SYSCALL(yield)
 540:	b8 1a 00 00 00       	mov    $0x1a,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <printpt>:

 548:	b8 1b 00 00 00       	mov    $0x1b,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 550:	55                   	push   %ebp
 551:	89 e5                	mov    %esp,%ebp
 553:	83 ec 18             	sub    $0x18,%esp
 556:	8b 45 0c             	mov    0xc(%ebp),%eax
 559:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 55c:	83 ec 04             	sub    $0x4,%esp
 55f:	6a 01                	push   $0x1
 561:	8d 45 f4             	lea    -0xc(%ebp),%eax
 564:	50                   	push   %eax
 565:	ff 75 08             	push   0x8(%ebp)
 568:	e8 33 ff ff ff       	call   4a0 <write>
 56d:	83 c4 10             	add    $0x10,%esp
}
 570:	90                   	nop
 571:	c9                   	leave  
 572:	c3                   	ret    

00000573 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 573:	55                   	push   %ebp
 574:	89 e5                	mov    %esp,%ebp
 576:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 579:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 580:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 584:	74 17                	je     59d <printint+0x2a>
 586:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 58a:	79 11                	jns    59d <printint+0x2a>
    neg = 1;
 58c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 593:	8b 45 0c             	mov    0xc(%ebp),%eax
 596:	f7 d8                	neg    %eax
 598:	89 45 ec             	mov    %eax,-0x14(%ebp)
 59b:	eb 06                	jmp    5a3 <printint+0x30>
  } else {
    x = xx;
 59d:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b0:	ba 00 00 00 00       	mov    $0x0,%edx
 5b5:	f7 f1                	div    %ecx
 5b7:	89 d1                	mov    %edx,%ecx
 5b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5bc:	8d 50 01             	lea    0x1(%eax),%edx
 5bf:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5c2:	0f b6 91 e4 0c 00 00 	movzbl 0xce4(%ecx),%edx
 5c9:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d3:	ba 00 00 00 00       	mov    $0x0,%edx
 5d8:	f7 f1                	div    %ecx
 5da:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5e1:	75 c7                	jne    5aa <printint+0x37>
  if(neg)
 5e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5e7:	74 2d                	je     616 <printint+0xa3>
    buf[i++] = '-';
 5e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ec:	8d 50 01             	lea    0x1(%eax),%edx
 5ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5f2:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5f7:	eb 1d                	jmp    616 <printint+0xa3>
    putc(fd, buf[i]);
 5f9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ff:	01 d0                	add    %edx,%eax
 601:	0f b6 00             	movzbl (%eax),%eax
 604:	0f be c0             	movsbl %al,%eax
 607:	83 ec 08             	sub    $0x8,%esp
 60a:	50                   	push   %eax
 60b:	ff 75 08             	push   0x8(%ebp)
 60e:	e8 3d ff ff ff       	call   550 <putc>
 613:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 616:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 61a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 61e:	79 d9                	jns    5f9 <printint+0x86>
}
 620:	90                   	nop
 621:	90                   	nop
 622:	c9                   	leave  
 623:	c3                   	ret    

00000624 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
 627:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 62a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 631:	8d 45 0c             	lea    0xc(%ebp),%eax
 634:	83 c0 04             	add    $0x4,%eax
 637:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 63a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 641:	e9 59 01 00 00       	jmp    79f <printf+0x17b>
    c = fmt[i] & 0xff;
 646:	8b 55 0c             	mov    0xc(%ebp),%edx
 649:	8b 45 f0             	mov    -0x10(%ebp),%eax
 64c:	01 d0                	add    %edx,%eax
 64e:	0f b6 00             	movzbl (%eax),%eax
 651:	0f be c0             	movsbl %al,%eax
 654:	25 ff 00 00 00       	and    $0xff,%eax
 659:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 65c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 660:	75 2c                	jne    68e <printf+0x6a>
      if(c == '%'){
 662:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 666:	75 0c                	jne    674 <printf+0x50>
        state = '%';
 668:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 66f:	e9 27 01 00 00       	jmp    79b <printf+0x177>
      } else {
        putc(fd, c);
 674:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 677:	0f be c0             	movsbl %al,%eax
 67a:	83 ec 08             	sub    $0x8,%esp
 67d:	50                   	push   %eax
 67e:	ff 75 08             	push   0x8(%ebp)
 681:	e8 ca fe ff ff       	call   550 <putc>
 686:	83 c4 10             	add    $0x10,%esp
 689:	e9 0d 01 00 00       	jmp    79b <printf+0x177>
      }
    } else if(state == '%'){
 68e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 692:	0f 85 03 01 00 00    	jne    79b <printf+0x177>
      if(c == 'd'){
 698:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 69c:	75 1e                	jne    6bc <printf+0x98>
        printint(fd, *ap, 10, 1);
 69e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a1:	8b 00                	mov    (%eax),%eax
 6a3:	6a 01                	push   $0x1
 6a5:	6a 0a                	push   $0xa
 6a7:	50                   	push   %eax
 6a8:	ff 75 08             	push   0x8(%ebp)
 6ab:	e8 c3 fe ff ff       	call   573 <printint>
 6b0:	83 c4 10             	add    $0x10,%esp
        ap++;
 6b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b7:	e9 d8 00 00 00       	jmp    794 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6bc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6c0:	74 06                	je     6c8 <printf+0xa4>
 6c2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6c6:	75 1e                	jne    6e6 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6cb:	8b 00                	mov    (%eax),%eax
 6cd:	6a 00                	push   $0x0
 6cf:	6a 10                	push   $0x10
 6d1:	50                   	push   %eax
 6d2:	ff 75 08             	push   0x8(%ebp)
 6d5:	e8 99 fe ff ff       	call   573 <printint>
 6da:	83 c4 10             	add    $0x10,%esp
        ap++;
 6dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e1:	e9 ae 00 00 00       	jmp    794 <printf+0x170>
      } else if(c == 's'){
 6e6:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6ea:	75 43                	jne    72f <printf+0x10b>
        s = (char*)*ap;
 6ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ef:	8b 00                	mov    (%eax),%eax
 6f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fc:	75 25                	jne    723 <printf+0xff>
          s = "(null)";
 6fe:	c7 45 f4 75 0a 00 00 	movl   $0xa75,-0xc(%ebp)
        while(*s != 0){
 705:	eb 1c                	jmp    723 <printf+0xff>
          putc(fd, *s);
 707:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70a:	0f b6 00             	movzbl (%eax),%eax
 70d:	0f be c0             	movsbl %al,%eax
 710:	83 ec 08             	sub    $0x8,%esp
 713:	50                   	push   %eax
 714:	ff 75 08             	push   0x8(%ebp)
 717:	e8 34 fe ff ff       	call   550 <putc>
 71c:	83 c4 10             	add    $0x10,%esp
          s++;
 71f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 723:	8b 45 f4             	mov    -0xc(%ebp),%eax
 726:	0f b6 00             	movzbl (%eax),%eax
 729:	84 c0                	test   %al,%al
 72b:	75 da                	jne    707 <printf+0xe3>
 72d:	eb 65                	jmp    794 <printf+0x170>
        }
      } else if(c == 'c'){
 72f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 733:	75 1d                	jne    752 <printf+0x12e>
        putc(fd, *ap);
 735:	8b 45 e8             	mov    -0x18(%ebp),%eax
 738:	8b 00                	mov    (%eax),%eax
 73a:	0f be c0             	movsbl %al,%eax
 73d:	83 ec 08             	sub    $0x8,%esp
 740:	50                   	push   %eax
 741:	ff 75 08             	push   0x8(%ebp)
 744:	e8 07 fe ff ff       	call   550 <putc>
 749:	83 c4 10             	add    $0x10,%esp
        ap++;
 74c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 750:	eb 42                	jmp    794 <printf+0x170>
      } else if(c == '%'){
 752:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 756:	75 17                	jne    76f <printf+0x14b>
        putc(fd, c);
 758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 75b:	0f be c0             	movsbl %al,%eax
 75e:	83 ec 08             	sub    $0x8,%esp
 761:	50                   	push   %eax
 762:	ff 75 08             	push   0x8(%ebp)
 765:	e8 e6 fd ff ff       	call   550 <putc>
 76a:	83 c4 10             	add    $0x10,%esp
 76d:	eb 25                	jmp    794 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76f:	83 ec 08             	sub    $0x8,%esp
 772:	6a 25                	push   $0x25
 774:	ff 75 08             	push   0x8(%ebp)
 777:	e8 d4 fd ff ff       	call   550 <putc>
 77c:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 77f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 782:	0f be c0             	movsbl %al,%eax
 785:	83 ec 08             	sub    $0x8,%esp
 788:	50                   	push   %eax
 789:	ff 75 08             	push   0x8(%ebp)
 78c:	e8 bf fd ff ff       	call   550 <putc>
 791:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 794:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 79b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 79f:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a5:	01 d0                	add    %edx,%eax
 7a7:	0f b6 00             	movzbl (%eax),%eax
 7aa:	84 c0                	test   %al,%al
 7ac:	0f 85 94 fe ff ff    	jne    646 <printf+0x22>
    }
  }
}
 7b2:	90                   	nop
 7b3:	90                   	nop
 7b4:	c9                   	leave  
 7b5:	c3                   	ret    

000007b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b6:	55                   	push   %ebp
 7b7:	89 e5                	mov    %esp,%ebp
 7b9:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7bc:	8b 45 08             	mov    0x8(%ebp),%eax
 7bf:	83 e8 08             	sub    $0x8,%eax
 7c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c5:	a1 00 0d 00 00       	mov    0xd00,%eax
 7ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7cd:	eb 24                	jmp    7f3 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d2:	8b 00                	mov    (%eax),%eax
 7d4:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7d7:	72 12                	jb     7eb <free+0x35>
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7df:	77 24                	ja     805 <free+0x4f>
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7e9:	72 1a                	jb     805 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ee:	8b 00                	mov    (%eax),%eax
 7f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f9:	76 d4                	jbe    7cf <free+0x19>
 7fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fe:	8b 00                	mov    (%eax),%eax
 800:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 803:	73 ca                	jae    7cf <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 805:	8b 45 f8             	mov    -0x8(%ebp),%eax
 808:	8b 40 04             	mov    0x4(%eax),%eax
 80b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 812:	8b 45 f8             	mov    -0x8(%ebp),%eax
 815:	01 c2                	add    %eax,%edx
 817:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81a:	8b 00                	mov    (%eax),%eax
 81c:	39 c2                	cmp    %eax,%edx
 81e:	75 24                	jne    844 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 820:	8b 45 f8             	mov    -0x8(%ebp),%eax
 823:	8b 50 04             	mov    0x4(%eax),%edx
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	8b 00                	mov    (%eax),%eax
 82b:	8b 40 04             	mov    0x4(%eax),%eax
 82e:	01 c2                	add    %eax,%edx
 830:	8b 45 f8             	mov    -0x8(%ebp),%eax
 833:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 836:	8b 45 fc             	mov    -0x4(%ebp),%eax
 839:	8b 00                	mov    (%eax),%eax
 83b:	8b 10                	mov    (%eax),%edx
 83d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 840:	89 10                	mov    %edx,(%eax)
 842:	eb 0a                	jmp    84e <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 844:	8b 45 fc             	mov    -0x4(%ebp),%eax
 847:	8b 10                	mov    (%eax),%edx
 849:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 84e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 851:	8b 40 04             	mov    0x4(%eax),%eax
 854:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 85b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85e:	01 d0                	add    %edx,%eax
 860:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 863:	75 20                	jne    885 <free+0xcf>
    p->s.size += bp->s.size;
 865:	8b 45 fc             	mov    -0x4(%ebp),%eax
 868:	8b 50 04             	mov    0x4(%eax),%edx
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	8b 40 04             	mov    0x4(%eax),%eax
 871:	01 c2                	add    %eax,%edx
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 879:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87c:	8b 10                	mov    (%eax),%edx
 87e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 881:	89 10                	mov    %edx,(%eax)
 883:	eb 08                	jmp    88d <free+0xd7>
  } else
    p->s.ptr = bp;
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	8b 55 f8             	mov    -0x8(%ebp),%edx
 88b:	89 10                	mov    %edx,(%eax)
  freep = p;
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	a3 00 0d 00 00       	mov    %eax,0xd00
}
 895:	90                   	nop
 896:	c9                   	leave  
 897:	c3                   	ret    

00000898 <morecore>:

static Header*
morecore(uint nu)
{
 898:	55                   	push   %ebp
 899:	89 e5                	mov    %esp,%ebp
 89b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 89e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a5:	77 07                	ja     8ae <morecore+0x16>
    nu = 4096;
 8a7:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8ae:	8b 45 08             	mov    0x8(%ebp),%eax
 8b1:	c1 e0 03             	shl    $0x3,%eax
 8b4:	83 ec 0c             	sub    $0xc,%esp
 8b7:	50                   	push   %eax
 8b8:	e8 4b fc ff ff       	call   508 <sbrk>
 8bd:	83 c4 10             	add    $0x10,%esp
 8c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8c3:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c7:	75 07                	jne    8d0 <morecore+0x38>
    return 0;
 8c9:	b8 00 00 00 00       	mov    $0x0,%eax
 8ce:	eb 26                	jmp    8f6 <morecore+0x5e>
  hp = (Header*)p;
 8d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d9:	8b 55 08             	mov    0x8(%ebp),%edx
 8dc:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e2:	83 c0 08             	add    $0x8,%eax
 8e5:	83 ec 0c             	sub    $0xc,%esp
 8e8:	50                   	push   %eax
 8e9:	e8 c8 fe ff ff       	call   7b6 <free>
 8ee:	83 c4 10             	add    $0x10,%esp
  return freep;
 8f1:	a1 00 0d 00 00       	mov    0xd00,%eax
}
 8f6:	c9                   	leave  
 8f7:	c3                   	ret    

000008f8 <malloc>:

void*
malloc(uint nbytes)
{
 8f8:	55                   	push   %ebp
 8f9:	89 e5                	mov    %esp,%ebp
 8fb:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8fe:	8b 45 08             	mov    0x8(%ebp),%eax
 901:	83 c0 07             	add    $0x7,%eax
 904:	c1 e8 03             	shr    $0x3,%eax
 907:	83 c0 01             	add    $0x1,%eax
 90a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 90d:	a1 00 0d 00 00       	mov    0xd00,%eax
 912:	89 45 f0             	mov    %eax,-0x10(%ebp)
 915:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 919:	75 23                	jne    93e <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 91b:	c7 45 f0 f8 0c 00 00 	movl   $0xcf8,-0x10(%ebp)
 922:	8b 45 f0             	mov    -0x10(%ebp),%eax
 925:	a3 00 0d 00 00       	mov    %eax,0xd00
 92a:	a1 00 0d 00 00       	mov    0xd00,%eax
 92f:	a3 f8 0c 00 00       	mov    %eax,0xcf8
    base.s.size = 0;
 934:	c7 05 fc 0c 00 00 00 	movl   $0x0,0xcfc
 93b:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 941:	8b 00                	mov    (%eax),%eax
 943:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 946:	8b 45 f4             	mov    -0xc(%ebp),%eax
 949:	8b 40 04             	mov    0x4(%eax),%eax
 94c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 94f:	77 4d                	ja     99e <malloc+0xa6>
      if(p->s.size == nunits)
 951:	8b 45 f4             	mov    -0xc(%ebp),%eax
 954:	8b 40 04             	mov    0x4(%eax),%eax
 957:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 95a:	75 0c                	jne    968 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 95c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95f:	8b 10                	mov    (%eax),%edx
 961:	8b 45 f0             	mov    -0x10(%ebp),%eax
 964:	89 10                	mov    %edx,(%eax)
 966:	eb 26                	jmp    98e <malloc+0x96>
      else {
        p->s.size -= nunits;
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	8b 40 04             	mov    0x4(%eax),%eax
 96e:	2b 45 ec             	sub    -0x14(%ebp),%eax
 971:	89 c2                	mov    %eax,%edx
 973:	8b 45 f4             	mov    -0xc(%ebp),%eax
 976:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 979:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97c:	8b 40 04             	mov    0x4(%eax),%eax
 97f:	c1 e0 03             	shl    $0x3,%eax
 982:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 985:	8b 45 f4             	mov    -0xc(%ebp),%eax
 988:	8b 55 ec             	mov    -0x14(%ebp),%edx
 98b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 98e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 991:	a3 00 0d 00 00       	mov    %eax,0xd00
      return (void*)(p + 1);
 996:	8b 45 f4             	mov    -0xc(%ebp),%eax
 999:	83 c0 08             	add    $0x8,%eax
 99c:	eb 3b                	jmp    9d9 <malloc+0xe1>
    }
    if(p == freep)
 99e:	a1 00 0d 00 00       	mov    0xd00,%eax
 9a3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9a6:	75 1e                	jne    9c6 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9a8:	83 ec 0c             	sub    $0xc,%esp
 9ab:	ff 75 ec             	push   -0x14(%ebp)
 9ae:	e8 e5 fe ff ff       	call   898 <morecore>
 9b3:	83 c4 10             	add    $0x10,%esp
 9b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9bd:	75 07                	jne    9c6 <malloc+0xce>
        return 0;
 9bf:	b8 00 00 00 00       	mov    $0x0,%eax
 9c4:	eb 13                	jmp    9d9 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cf:	8b 00                	mov    (%eax),%eax
 9d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9d4:	e9 6d ff ff ff       	jmp    946 <malloc+0x4e>
  }
}
 9d9:	c9                   	leave  
 9da:	c3                   	ret    
