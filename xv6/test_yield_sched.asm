
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
  63:	68 d4 09 00 00       	push   $0x9d4
  68:	6a 01                	push   $0x1
  6a:	e8 ad 05 00 00       	call   61c <printf>
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
  86:	68 f4 09 00 00       	push   $0x9f4
  8b:	6a 01                	push   $0x1
  8d:	e8 8a 05 00 00       	call   61c <printf>
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
  f7:	68 15 0a 00 00       	push   $0xa15
  fc:	6a 01                	push   $0x1
  fe:	e8 19 05 00 00       	call   61c <printf>
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
 145:	68 26 0a 00 00       	push   $0xa26
 14a:	6a 01                	push   $0x1
 14c:	e8 cb 04 00 00       	call   61c <printf>
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
 1a6:	68 3c 0a 00 00       	push   $0xa3c
 1ab:	6a 01                	push   $0x1
 1ad:	e8 6a 04 00 00       	call   61c <printf>
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
 207:	68 52 0a 00 00       	push   $0xa52
 20c:	6a 01                	push   $0x1
 20e:	e8 09 04 00 00       	call   61c <printf>
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
 540:	b8 1a 00 00 00       	mov    $0x1a,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 548:	55                   	push   %ebp
 549:	89 e5                	mov    %esp,%ebp
 54b:	83 ec 18             	sub    $0x18,%esp
 54e:	8b 45 0c             	mov    0xc(%ebp),%eax
 551:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 554:	83 ec 04             	sub    $0x4,%esp
 557:	6a 01                	push   $0x1
 559:	8d 45 f4             	lea    -0xc(%ebp),%eax
 55c:	50                   	push   %eax
 55d:	ff 75 08             	push   0x8(%ebp)
 560:	e8 3b ff ff ff       	call   4a0 <write>
 565:	83 c4 10             	add    $0x10,%esp
}
 568:	90                   	nop
 569:	c9                   	leave  
 56a:	c3                   	ret    

0000056b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 56b:	55                   	push   %ebp
 56c:	89 e5                	mov    %esp,%ebp
 56e:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 571:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 578:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 57c:	74 17                	je     595 <printint+0x2a>
 57e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 582:	79 11                	jns    595 <printint+0x2a>
    neg = 1;
 584:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 58b:	8b 45 0c             	mov    0xc(%ebp),%eax
 58e:	f7 d8                	neg    %eax
 590:	89 45 ec             	mov    %eax,-0x14(%ebp)
 593:	eb 06                	jmp    59b <printint+0x30>
  } else {
    x = xx;
 595:	8b 45 0c             	mov    0xc(%ebp),%eax
 598:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 59b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5a8:	ba 00 00 00 00       	mov    $0x0,%edx
 5ad:	f7 f1                	div    %ecx
 5af:	89 d1                	mov    %edx,%ecx
 5b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b4:	8d 50 01             	lea    0x1(%eax),%edx
 5b7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5ba:	0f b6 91 dc 0c 00 00 	movzbl 0xcdc(%ecx),%edx
 5c1:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5cb:	ba 00 00 00 00       	mov    $0x0,%edx
 5d0:	f7 f1                	div    %ecx
 5d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d9:	75 c7                	jne    5a2 <printint+0x37>
  if(neg)
 5db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5df:	74 2d                	je     60e <printint+0xa3>
    buf[i++] = '-';
 5e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e4:	8d 50 01             	lea    0x1(%eax),%edx
 5e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5ea:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5ef:	eb 1d                	jmp    60e <printint+0xa3>
    putc(fd, buf[i]);
 5f1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f7:	01 d0                	add    %edx,%eax
 5f9:	0f b6 00             	movzbl (%eax),%eax
 5fc:	0f be c0             	movsbl %al,%eax
 5ff:	83 ec 08             	sub    $0x8,%esp
 602:	50                   	push   %eax
 603:	ff 75 08             	push   0x8(%ebp)
 606:	e8 3d ff ff ff       	call   548 <putc>
 60b:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 60e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 612:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 616:	79 d9                	jns    5f1 <printint+0x86>
}
 618:	90                   	nop
 619:	90                   	nop
 61a:	c9                   	leave  
 61b:	c3                   	ret    

0000061c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 61c:	55                   	push   %ebp
 61d:	89 e5                	mov    %esp,%ebp
 61f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 622:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 629:	8d 45 0c             	lea    0xc(%ebp),%eax
 62c:	83 c0 04             	add    $0x4,%eax
 62f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 632:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 639:	e9 59 01 00 00       	jmp    797 <printf+0x17b>
    c = fmt[i] & 0xff;
 63e:	8b 55 0c             	mov    0xc(%ebp),%edx
 641:	8b 45 f0             	mov    -0x10(%ebp),%eax
 644:	01 d0                	add    %edx,%eax
 646:	0f b6 00             	movzbl (%eax),%eax
 649:	0f be c0             	movsbl %al,%eax
 64c:	25 ff 00 00 00       	and    $0xff,%eax
 651:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 654:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 658:	75 2c                	jne    686 <printf+0x6a>
      if(c == '%'){
 65a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65e:	75 0c                	jne    66c <printf+0x50>
        state = '%';
 660:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 667:	e9 27 01 00 00       	jmp    793 <printf+0x177>
      } else {
        putc(fd, c);
 66c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66f:	0f be c0             	movsbl %al,%eax
 672:	83 ec 08             	sub    $0x8,%esp
 675:	50                   	push   %eax
 676:	ff 75 08             	push   0x8(%ebp)
 679:	e8 ca fe ff ff       	call   548 <putc>
 67e:	83 c4 10             	add    $0x10,%esp
 681:	e9 0d 01 00 00       	jmp    793 <printf+0x177>
      }
    } else if(state == '%'){
 686:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 68a:	0f 85 03 01 00 00    	jne    793 <printf+0x177>
      if(c == 'd'){
 690:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 694:	75 1e                	jne    6b4 <printf+0x98>
        printint(fd, *ap, 10, 1);
 696:	8b 45 e8             	mov    -0x18(%ebp),%eax
 699:	8b 00                	mov    (%eax),%eax
 69b:	6a 01                	push   $0x1
 69d:	6a 0a                	push   $0xa
 69f:	50                   	push   %eax
 6a0:	ff 75 08             	push   0x8(%ebp)
 6a3:	e8 c3 fe ff ff       	call   56b <printint>
 6a8:	83 c4 10             	add    $0x10,%esp
        ap++;
 6ab:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6af:	e9 d8 00 00 00       	jmp    78c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6b4:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6b8:	74 06                	je     6c0 <printf+0xa4>
 6ba:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6be:	75 1e                	jne    6de <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c3:	8b 00                	mov    (%eax),%eax
 6c5:	6a 00                	push   $0x0
 6c7:	6a 10                	push   $0x10
 6c9:	50                   	push   %eax
 6ca:	ff 75 08             	push   0x8(%ebp)
 6cd:	e8 99 fe ff ff       	call   56b <printint>
 6d2:	83 c4 10             	add    $0x10,%esp
        ap++;
 6d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d9:	e9 ae 00 00 00       	jmp    78c <printf+0x170>
      } else if(c == 's'){
 6de:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e2:	75 43                	jne    727 <printf+0x10b>
        s = (char*)*ap;
 6e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e7:	8b 00                	mov    (%eax),%eax
 6e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ec:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f4:	75 25                	jne    71b <printf+0xff>
          s = "(null)";
 6f6:	c7 45 f4 6d 0a 00 00 	movl   $0xa6d,-0xc(%ebp)
        while(*s != 0){
 6fd:	eb 1c                	jmp    71b <printf+0xff>
          putc(fd, *s);
 6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 702:	0f b6 00             	movzbl (%eax),%eax
 705:	0f be c0             	movsbl %al,%eax
 708:	83 ec 08             	sub    $0x8,%esp
 70b:	50                   	push   %eax
 70c:	ff 75 08             	push   0x8(%ebp)
 70f:	e8 34 fe ff ff       	call   548 <putc>
 714:	83 c4 10             	add    $0x10,%esp
          s++;
 717:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 71b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71e:	0f b6 00             	movzbl (%eax),%eax
 721:	84 c0                	test   %al,%al
 723:	75 da                	jne    6ff <printf+0xe3>
 725:	eb 65                	jmp    78c <printf+0x170>
        }
      } else if(c == 'c'){
 727:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 72b:	75 1d                	jne    74a <printf+0x12e>
        putc(fd, *ap);
 72d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	0f be c0             	movsbl %al,%eax
 735:	83 ec 08             	sub    $0x8,%esp
 738:	50                   	push   %eax
 739:	ff 75 08             	push   0x8(%ebp)
 73c:	e8 07 fe ff ff       	call   548 <putc>
 741:	83 c4 10             	add    $0x10,%esp
        ap++;
 744:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 748:	eb 42                	jmp    78c <printf+0x170>
      } else if(c == '%'){
 74a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74e:	75 17                	jne    767 <printf+0x14b>
        putc(fd, c);
 750:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 753:	0f be c0             	movsbl %al,%eax
 756:	83 ec 08             	sub    $0x8,%esp
 759:	50                   	push   %eax
 75a:	ff 75 08             	push   0x8(%ebp)
 75d:	e8 e6 fd ff ff       	call   548 <putc>
 762:	83 c4 10             	add    $0x10,%esp
 765:	eb 25                	jmp    78c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 767:	83 ec 08             	sub    $0x8,%esp
 76a:	6a 25                	push   $0x25
 76c:	ff 75 08             	push   0x8(%ebp)
 76f:	e8 d4 fd ff ff       	call   548 <putc>
 774:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77a:	0f be c0             	movsbl %al,%eax
 77d:	83 ec 08             	sub    $0x8,%esp
 780:	50                   	push   %eax
 781:	ff 75 08             	push   0x8(%ebp)
 784:	e8 bf fd ff ff       	call   548 <putc>
 789:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 78c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 793:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 797:	8b 55 0c             	mov    0xc(%ebp),%edx
 79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79d:	01 d0                	add    %edx,%eax
 79f:	0f b6 00             	movzbl (%eax),%eax
 7a2:	84 c0                	test   %al,%al
 7a4:	0f 85 94 fe ff ff    	jne    63e <printf+0x22>
    }
  }
}
 7aa:	90                   	nop
 7ab:	90                   	nop
 7ac:	c9                   	leave  
 7ad:	c3                   	ret    

000007ae <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ae:	55                   	push   %ebp
 7af:	89 e5                	mov    %esp,%ebp
 7b1:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b4:	8b 45 08             	mov    0x8(%ebp),%eax
 7b7:	83 e8 08             	sub    $0x8,%eax
 7ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bd:	a1 f8 0c 00 00       	mov    0xcf8,%eax
 7c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c5:	eb 24                	jmp    7eb <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ca:	8b 00                	mov    (%eax),%eax
 7cc:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7cf:	72 12                	jb     7e3 <free+0x35>
 7d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d7:	77 24                	ja     7fd <free+0x4f>
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7e1:	72 1a                	jb     7fd <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e6:	8b 00                	mov    (%eax),%eax
 7e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f1:	76 d4                	jbe    7c7 <free+0x19>
 7f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f6:	8b 00                	mov    (%eax),%eax
 7f8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7fb:	73 ca                	jae    7c7 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 800:	8b 40 04             	mov    0x4(%eax),%eax
 803:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 80a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80d:	01 c2                	add    %eax,%edx
 80f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 812:	8b 00                	mov    (%eax),%eax
 814:	39 c2                	cmp    %eax,%edx
 816:	75 24                	jne    83c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 818:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81b:	8b 50 04             	mov    0x4(%eax),%edx
 81e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 821:	8b 00                	mov    (%eax),%eax
 823:	8b 40 04             	mov    0x4(%eax),%eax
 826:	01 c2                	add    %eax,%edx
 828:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 82e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 831:	8b 00                	mov    (%eax),%eax
 833:	8b 10                	mov    (%eax),%edx
 835:	8b 45 f8             	mov    -0x8(%ebp),%eax
 838:	89 10                	mov    %edx,(%eax)
 83a:	eb 0a                	jmp    846 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 83c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83f:	8b 10                	mov    (%eax),%edx
 841:	8b 45 f8             	mov    -0x8(%ebp),%eax
 844:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 40 04             	mov    0x4(%eax),%eax
 84c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 853:	8b 45 fc             	mov    -0x4(%ebp),%eax
 856:	01 d0                	add    %edx,%eax
 858:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 85b:	75 20                	jne    87d <free+0xcf>
    p->s.size += bp->s.size;
 85d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 860:	8b 50 04             	mov    0x4(%eax),%edx
 863:	8b 45 f8             	mov    -0x8(%ebp),%eax
 866:	8b 40 04             	mov    0x4(%eax),%eax
 869:	01 c2                	add    %eax,%edx
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 871:	8b 45 f8             	mov    -0x8(%ebp),%eax
 874:	8b 10                	mov    (%eax),%edx
 876:	8b 45 fc             	mov    -0x4(%ebp),%eax
 879:	89 10                	mov    %edx,(%eax)
 87b:	eb 08                	jmp    885 <free+0xd7>
  } else
    p->s.ptr = bp;
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	8b 55 f8             	mov    -0x8(%ebp),%edx
 883:	89 10                	mov    %edx,(%eax)
  freep = p;
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	a3 f8 0c 00 00       	mov    %eax,0xcf8
}
 88d:	90                   	nop
 88e:	c9                   	leave  
 88f:	c3                   	ret    

00000890 <morecore>:

static Header*
morecore(uint nu)
{
 890:	55                   	push   %ebp
 891:	89 e5                	mov    %esp,%ebp
 893:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 896:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 89d:	77 07                	ja     8a6 <morecore+0x16>
    nu = 4096;
 89f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a6:	8b 45 08             	mov    0x8(%ebp),%eax
 8a9:	c1 e0 03             	shl    $0x3,%eax
 8ac:	83 ec 0c             	sub    $0xc,%esp
 8af:	50                   	push   %eax
 8b0:	e8 53 fc ff ff       	call   508 <sbrk>
 8b5:	83 c4 10             	add    $0x10,%esp
 8b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8bb:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8bf:	75 07                	jne    8c8 <morecore+0x38>
    return 0;
 8c1:	b8 00 00 00 00       	mov    $0x0,%eax
 8c6:	eb 26                	jmp    8ee <morecore+0x5e>
  hp = (Header*)p;
 8c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d1:	8b 55 08             	mov    0x8(%ebp),%edx
 8d4:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8da:	83 c0 08             	add    $0x8,%eax
 8dd:	83 ec 0c             	sub    $0xc,%esp
 8e0:	50                   	push   %eax
 8e1:	e8 c8 fe ff ff       	call   7ae <free>
 8e6:	83 c4 10             	add    $0x10,%esp
  return freep;
 8e9:	a1 f8 0c 00 00       	mov    0xcf8,%eax
}
 8ee:	c9                   	leave  
 8ef:	c3                   	ret    

000008f0 <malloc>:

void*
malloc(uint nbytes)
{
 8f0:	55                   	push   %ebp
 8f1:	89 e5                	mov    %esp,%ebp
 8f3:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f6:	8b 45 08             	mov    0x8(%ebp),%eax
 8f9:	83 c0 07             	add    $0x7,%eax
 8fc:	c1 e8 03             	shr    $0x3,%eax
 8ff:	83 c0 01             	add    $0x1,%eax
 902:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 905:	a1 f8 0c 00 00       	mov    0xcf8,%eax
 90a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 911:	75 23                	jne    936 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 913:	c7 45 f0 f0 0c 00 00 	movl   $0xcf0,-0x10(%ebp)
 91a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91d:	a3 f8 0c 00 00       	mov    %eax,0xcf8
 922:	a1 f8 0c 00 00       	mov    0xcf8,%eax
 927:	a3 f0 0c 00 00       	mov    %eax,0xcf0
    base.s.size = 0;
 92c:	c7 05 f4 0c 00 00 00 	movl   $0x0,0xcf4
 933:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 936:	8b 45 f0             	mov    -0x10(%ebp),%eax
 939:	8b 00                	mov    (%eax),%eax
 93b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 941:	8b 40 04             	mov    0x4(%eax),%eax
 944:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 947:	77 4d                	ja     996 <malloc+0xa6>
      if(p->s.size == nunits)
 949:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94c:	8b 40 04             	mov    0x4(%eax),%eax
 94f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 952:	75 0c                	jne    960 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 954:	8b 45 f4             	mov    -0xc(%ebp),%eax
 957:	8b 10                	mov    (%eax),%edx
 959:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95c:	89 10                	mov    %edx,(%eax)
 95e:	eb 26                	jmp    986 <malloc+0x96>
      else {
        p->s.size -= nunits;
 960:	8b 45 f4             	mov    -0xc(%ebp),%eax
 963:	8b 40 04             	mov    0x4(%eax),%eax
 966:	2b 45 ec             	sub    -0x14(%ebp),%eax
 969:	89 c2                	mov    %eax,%edx
 96b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 971:	8b 45 f4             	mov    -0xc(%ebp),%eax
 974:	8b 40 04             	mov    0x4(%eax),%eax
 977:	c1 e0 03             	shl    $0x3,%eax
 97a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 980:	8b 55 ec             	mov    -0x14(%ebp),%edx
 983:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 986:	8b 45 f0             	mov    -0x10(%ebp),%eax
 989:	a3 f8 0c 00 00       	mov    %eax,0xcf8
      return (void*)(p + 1);
 98e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 991:	83 c0 08             	add    $0x8,%eax
 994:	eb 3b                	jmp    9d1 <malloc+0xe1>
    }
    if(p == freep)
 996:	a1 f8 0c 00 00       	mov    0xcf8,%eax
 99b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99e:	75 1e                	jne    9be <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9a0:	83 ec 0c             	sub    $0xc,%esp
 9a3:	ff 75 ec             	push   -0x14(%ebp)
 9a6:	e8 e5 fe ff ff       	call   890 <morecore>
 9ab:	83 c4 10             	add    $0x10,%esp
 9ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b5:	75 07                	jne    9be <malloc+0xce>
        return 0;
 9b7:	b8 00 00 00 00       	mov    $0x0,%eax
 9bc:	eb 13                	jmp    9d1 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c7:	8b 00                	mov    (%eax),%eax
 9c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9cc:	e9 6d ff ff ff       	jmp    93e <malloc+0x4e>
  }
}
 9d1:	c9                   	leave  
 9d2:	c3                   	ret    
