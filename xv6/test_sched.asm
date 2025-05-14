
_test_sched:     file format elf32-i386


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

00000034 <main>:

int main(int argc, char *argv[]) {
  34:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  38:	83 e4 f0             	and    $0xfffffff0,%esp
  3b:	ff 71 fc             	push   -0x4(%ecx)
  3e:	55                   	push   %ebp
  3f:	89 e5                	mov    %esp,%ebp
  41:	53                   	push   %ebx
  42:	51                   	push   %ecx
  43:	81 ec 10 0c 00 00    	sub    $0xc10,%esp
  struct pstat ps;
  int pid;

  // 1. 스케줄링 정책을 MLFQ로 설정
  if (setSchedPolicy(1) < 0) {
  49:	83 ec 0c             	sub    $0xc,%esp
  4c:	6a 01                	push   $0x1
  4e:	e8 a0 04 00 00       	call   4f3 <setSchedPolicy>
  53:	83 c4 10             	add    $0x10,%esp
  56:	85 c0                	test   %eax,%eax
  58:	79 17                	jns    71 <main+0x3d>
    printf(1, "Failed to set scheduling policy\n");
  5a:	83 ec 08             	sub    $0x8,%esp
  5d:	68 90 09 00 00       	push   $0x990
  62:	6a 01                	push   $0x1
  64:	e8 6e 05 00 00       	call   5d7 <printf>
  69:	83 c4 10             	add    $0x10,%esp
    exit();
  6c:	e8 ca 03 00 00       	call   43b <exit>
  }

  // 2. 자식 프로세스 생성
  pid = fork();
  71:	e8 bd 03 00 00       	call   433 <fork>
  76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (pid == 0) {
  79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  7d:	75 15                	jne    94 <main+0x60>
    // child
    workload(4000000);  // CPU 점유
  7f:	83 ec 0c             	sub    $0xc,%esp
  82:	68 00 09 3d 00       	push   $0x3d0900
  87:	e8 74 ff ff ff       	call   0 <workload>
  8c:	83 c4 10             	add    $0x10,%esp
    exit();
  8f:	e8 a7 03 00 00       	call   43b <exit>
  } else {
    wait();  // 부모는 대기
  94:	e8 aa 03 00 00       	call   443 <wait>
  }

  // 3. getpinfo 호출
  if (getpinfo(&ps) < 0) {
  99:	83 ec 0c             	sub    $0xc,%esp
  9c:	8d 85 f0 f3 ff ff    	lea    -0xc10(%ebp),%eax
  a2:	50                   	push   %eax
  a3:	e8 43 04 00 00       	call   4eb <getpinfo>
  a8:	83 c4 10             	add    $0x10,%esp
  ab:	85 c0                	test   %eax,%eax
  ad:	79 17                	jns    c6 <main+0x92>
    printf(1, "getpinfo failed\n");
  af:	83 ec 08             	sub    $0x8,%esp
  b2:	68 b1 09 00 00       	push   $0x9b1
  b7:	6a 01                	push   $0x1
  b9:	e8 19 05 00 00       	call   5d7 <printf>
  be:	83 c4 10             	add    $0x10,%esp
    exit();
  c1:	e8 75 03 00 00       	call   43b <exit>
  }

  // 4. 결과 출력
  int i;
  for (i = 0; i < NPROC; i++) {
  c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  cd:	e9 03 01 00 00       	jmp    1d5 <main+0x1a1>
    if (ps.inuse[i]) {
  d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d5:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  dc:	85 c0                	test   %eax,%eax
  de:	0f 84 ed 00 00 00    	je     1d1 <main+0x19d>
      printf(1, "pid %d | priority %d\n", ps.pid[i], ps.priority[i]);
  e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  e7:	83 e8 80             	sub    $0xffffff80,%eax
  ea:	8b 94 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%edx
  f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f4:	83 c0 40             	add    $0x40,%eax
  f7:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  fe:	52                   	push   %edx
  ff:	50                   	push   %eax
 100:	68 c2 09 00 00       	push   $0x9c2
 105:	6a 01                	push   $0x1
 107:	e8 cb 04 00 00       	call   5d7 <printf>
 10c:	83 c4 10             	add    $0x10,%esp
      printf(1, "ticks: [%d %d %d %d]\n",
 10f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 112:	c1 e0 04             	shl    $0x4,%eax
 115:	8d 40 f8             	lea    -0x8(%eax),%eax
 118:	01 e8                	add    %ebp,%eax
 11a:	2d fc 07 00 00       	sub    $0x7fc,%eax
 11f:	8b 18                	mov    (%eax),%ebx
 121:	8b 45 f4             	mov    -0xc(%ebp),%eax
 124:	c1 e0 04             	shl    $0x4,%eax
 127:	8d 40 f8             	lea    -0x8(%eax),%eax
 12a:	01 e8                	add    %ebp,%eax
 12c:	2d 00 08 00 00       	sub    $0x800,%eax
 131:	8b 08                	mov    (%eax),%ecx
 133:	8b 45 f4             	mov    -0xc(%ebp),%eax
 136:	c1 e0 04             	shl    $0x4,%eax
 139:	8d 40 f8             	lea    -0x8(%eax),%eax
 13c:	01 e8                	add    %ebp,%eax
 13e:	2d 04 08 00 00       	sub    $0x804,%eax
 143:	8b 10                	mov    (%eax),%edx
 145:	8b 45 f4             	mov    -0xc(%ebp),%eax
 148:	83 c0 40             	add    $0x40,%eax
 14b:	c1 e0 04             	shl    $0x4,%eax
 14e:	8d 40 f8             	lea    -0x8(%eax),%eax
 151:	01 e8                	add    %ebp,%eax
 153:	2d 08 0c 00 00       	sub    $0xc08,%eax
 158:	8b 00                	mov    (%eax),%eax
 15a:	83 ec 08             	sub    $0x8,%esp
 15d:	53                   	push   %ebx
 15e:	51                   	push   %ecx
 15f:	52                   	push   %edx
 160:	50                   	push   %eax
 161:	68 d8 09 00 00       	push   $0x9d8
 166:	6a 01                	push   $0x1
 168:	e8 6a 04 00 00       	call   5d7 <printf>
 16d:	83 c4 20             	add    $0x20,%esp
        ps.ticks[i][0], ps.ticks[i][1], ps.ticks[i][2], ps.ticks[i][3]);
      printf(1, "wait_ticks: [%d %d %d %d]\n",
 170:	8b 45 f4             	mov    -0xc(%ebp),%eax
 173:	c1 e0 04             	shl    $0x4,%eax
 176:	8d 40 f8             	lea    -0x8(%eax),%eax
 179:	01 e8                	add    %ebp,%eax
 17b:	2d fc 03 00 00       	sub    $0x3fc,%eax
 180:	8b 18                	mov    (%eax),%ebx
 182:	8b 45 f4             	mov    -0xc(%ebp),%eax
 185:	c1 e0 04             	shl    $0x4,%eax
 188:	8d 40 f8             	lea    -0x8(%eax),%eax
 18b:	01 e8                	add    %ebp,%eax
 18d:	2d 00 04 00 00       	sub    $0x400,%eax
 192:	8b 08                	mov    (%eax),%ecx
 194:	8b 45 f4             	mov    -0xc(%ebp),%eax
 197:	c1 e0 04             	shl    $0x4,%eax
 19a:	8d 40 f8             	lea    -0x8(%eax),%eax
 19d:	01 e8                	add    %ebp,%eax
 19f:	2d 04 04 00 00       	sub    $0x404,%eax
 1a4:	8b 10                	mov    (%eax),%edx
 1a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a9:	83 e8 80             	sub    $0xffffff80,%eax
 1ac:	c1 e0 04             	shl    $0x4,%eax
 1af:	8d 40 f8             	lea    -0x8(%eax),%eax
 1b2:	01 e8                	add    %ebp,%eax
 1b4:	2d 08 0c 00 00       	sub    $0xc08,%eax
 1b9:	8b 00                	mov    (%eax),%eax
 1bb:	83 ec 08             	sub    $0x8,%esp
 1be:	53                   	push   %ebx
 1bf:	51                   	push   %ecx
 1c0:	52                   	push   %edx
 1c1:	50                   	push   %eax
 1c2:	68 ee 09 00 00       	push   $0x9ee
 1c7:	6a 01                	push   $0x1
 1c9:	e8 09 04 00 00       	call   5d7 <printf>
 1ce:	83 c4 20             	add    $0x20,%esp
  for (i = 0; i < NPROC; i++) {
 1d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1d5:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 1d9:	0f 8e f3 fe ff ff    	jle    d2 <main+0x9e>
        ps.wait_ticks[i][0], ps.wait_ticks[i][1], ps.wait_ticks[i][2], ps.wait_ticks[i][3]);
    }
  }

  exit();
 1df:	e8 57 02 00 00       	call   43b <exit>

000001e4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1e4:	55                   	push   %ebp
 1e5:	89 e5                	mov    %esp,%ebp
 1e7:	57                   	push   %edi
 1e8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1ec:	8b 55 10             	mov    0x10(%ebp),%edx
 1ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f2:	89 cb                	mov    %ecx,%ebx
 1f4:	89 df                	mov    %ebx,%edi
 1f6:	89 d1                	mov    %edx,%ecx
 1f8:	fc                   	cld    
 1f9:	f3 aa                	rep stos %al,%es:(%edi)
 1fb:	89 ca                	mov    %ecx,%edx
 1fd:	89 fb                	mov    %edi,%ebx
 1ff:	89 5d 08             	mov    %ebx,0x8(%ebp)
 202:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 205:	90                   	nop
 206:	5b                   	pop    %ebx
 207:	5f                   	pop    %edi
 208:	5d                   	pop    %ebp
 209:	c3                   	ret    

0000020a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 20a:	55                   	push   %ebp
 20b:	89 e5                	mov    %esp,%ebp
 20d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 216:	90                   	nop
 217:	8b 55 0c             	mov    0xc(%ebp),%edx
 21a:	8d 42 01             	lea    0x1(%edx),%eax
 21d:	89 45 0c             	mov    %eax,0xc(%ebp)
 220:	8b 45 08             	mov    0x8(%ebp),%eax
 223:	8d 48 01             	lea    0x1(%eax),%ecx
 226:	89 4d 08             	mov    %ecx,0x8(%ebp)
 229:	0f b6 12             	movzbl (%edx),%edx
 22c:	88 10                	mov    %dl,(%eax)
 22e:	0f b6 00             	movzbl (%eax),%eax
 231:	84 c0                	test   %al,%al
 233:	75 e2                	jne    217 <strcpy+0xd>
    ;
  return os;
 235:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 238:	c9                   	leave  
 239:	c3                   	ret    

0000023a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 23a:	55                   	push   %ebp
 23b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 23d:	eb 08                	jmp    247 <strcmp+0xd>
    p++, q++;
 23f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 243:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 247:	8b 45 08             	mov    0x8(%ebp),%eax
 24a:	0f b6 00             	movzbl (%eax),%eax
 24d:	84 c0                	test   %al,%al
 24f:	74 10                	je     261 <strcmp+0x27>
 251:	8b 45 08             	mov    0x8(%ebp),%eax
 254:	0f b6 10             	movzbl (%eax),%edx
 257:	8b 45 0c             	mov    0xc(%ebp),%eax
 25a:	0f b6 00             	movzbl (%eax),%eax
 25d:	38 c2                	cmp    %al,%dl
 25f:	74 de                	je     23f <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	0f b6 00             	movzbl (%eax),%eax
 267:	0f b6 d0             	movzbl %al,%edx
 26a:	8b 45 0c             	mov    0xc(%ebp),%eax
 26d:	0f b6 00             	movzbl (%eax),%eax
 270:	0f b6 c8             	movzbl %al,%ecx
 273:	89 d0                	mov    %edx,%eax
 275:	29 c8                	sub    %ecx,%eax
}
 277:	5d                   	pop    %ebp
 278:	c3                   	ret    

00000279 <strlen>:

uint
strlen(char *s)
{
 279:	55                   	push   %ebp
 27a:	89 e5                	mov    %esp,%ebp
 27c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 27f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 286:	eb 04                	jmp    28c <strlen+0x13>
 288:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 28c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	01 d0                	add    %edx,%eax
 294:	0f b6 00             	movzbl (%eax),%eax
 297:	84 c0                	test   %al,%al
 299:	75 ed                	jne    288 <strlen+0xf>
    ;
  return n;
 29b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29e:	c9                   	leave  
 29f:	c3                   	ret    

000002a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 2a3:	8b 45 10             	mov    0x10(%ebp),%eax
 2a6:	50                   	push   %eax
 2a7:	ff 75 0c             	push   0xc(%ebp)
 2aa:	ff 75 08             	push   0x8(%ebp)
 2ad:	e8 32 ff ff ff       	call   1e4 <stosb>
 2b2:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b8:	c9                   	leave  
 2b9:	c3                   	ret    

000002ba <strchr>:

char*
strchr(const char *s, char c)
{
 2ba:	55                   	push   %ebp
 2bb:	89 e5                	mov    %esp,%ebp
 2bd:	83 ec 04             	sub    $0x4,%esp
 2c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c3:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2c6:	eb 14                	jmp    2dc <strchr+0x22>
    if(*s == c)
 2c8:	8b 45 08             	mov    0x8(%ebp),%eax
 2cb:	0f b6 00             	movzbl (%eax),%eax
 2ce:	38 45 fc             	cmp    %al,-0x4(%ebp)
 2d1:	75 05                	jne    2d8 <strchr+0x1e>
      return (char*)s;
 2d3:	8b 45 08             	mov    0x8(%ebp),%eax
 2d6:	eb 13                	jmp    2eb <strchr+0x31>
  for(; *s; s++)
 2d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
 2df:	0f b6 00             	movzbl (%eax),%eax
 2e2:	84 c0                	test   %al,%al
 2e4:	75 e2                	jne    2c8 <strchr+0xe>
  return 0;
 2e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2eb:	c9                   	leave  
 2ec:	c3                   	ret    

000002ed <gets>:

char*
gets(char *buf, int max)
{
 2ed:	55                   	push   %ebp
 2ee:	89 e5                	mov    %esp,%ebp
 2f0:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2fa:	eb 42                	jmp    33e <gets+0x51>
    cc = read(0, &c, 1);
 2fc:	83 ec 04             	sub    $0x4,%esp
 2ff:	6a 01                	push   $0x1
 301:	8d 45 ef             	lea    -0x11(%ebp),%eax
 304:	50                   	push   %eax
 305:	6a 00                	push   $0x0
 307:	e8 47 01 00 00       	call   453 <read>
 30c:	83 c4 10             	add    $0x10,%esp
 30f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 312:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 316:	7e 33                	jle    34b <gets+0x5e>
      break;
    buf[i++] = c;
 318:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31b:	8d 50 01             	lea    0x1(%eax),%edx
 31e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 321:	89 c2                	mov    %eax,%edx
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	01 c2                	add    %eax,%edx
 328:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 32c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 32e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 332:	3c 0a                	cmp    $0xa,%al
 334:	74 16                	je     34c <gets+0x5f>
 336:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 33a:	3c 0d                	cmp    $0xd,%al
 33c:	74 0e                	je     34c <gets+0x5f>
  for(i=0; i+1 < max; ){
 33e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 341:	83 c0 01             	add    $0x1,%eax
 344:	39 45 0c             	cmp    %eax,0xc(%ebp)
 347:	7f b3                	jg     2fc <gets+0xf>
 349:	eb 01                	jmp    34c <gets+0x5f>
      break;
 34b:	90                   	nop
      break;
  }
  buf[i] = '\0';
 34c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	01 d0                	add    %edx,%eax
 354:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 357:	8b 45 08             	mov    0x8(%ebp),%eax
}
 35a:	c9                   	leave  
 35b:	c3                   	ret    

0000035c <stat>:

int
stat(char *n, struct stat *st)
{
 35c:	55                   	push   %ebp
 35d:	89 e5                	mov    %esp,%ebp
 35f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 362:	83 ec 08             	sub    $0x8,%esp
 365:	6a 00                	push   $0x0
 367:	ff 75 08             	push   0x8(%ebp)
 36a:	e8 0c 01 00 00       	call   47b <open>
 36f:	83 c4 10             	add    $0x10,%esp
 372:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 375:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 379:	79 07                	jns    382 <stat+0x26>
    return -1;
 37b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 380:	eb 25                	jmp    3a7 <stat+0x4b>
  r = fstat(fd, st);
 382:	83 ec 08             	sub    $0x8,%esp
 385:	ff 75 0c             	push   0xc(%ebp)
 388:	ff 75 f4             	push   -0xc(%ebp)
 38b:	e8 03 01 00 00       	call   493 <fstat>
 390:	83 c4 10             	add    $0x10,%esp
 393:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 396:	83 ec 0c             	sub    $0xc,%esp
 399:	ff 75 f4             	push   -0xc(%ebp)
 39c:	e8 c2 00 00 00       	call   463 <close>
 3a1:	83 c4 10             	add    $0x10,%esp
  return r;
 3a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3a7:	c9                   	leave  
 3a8:	c3                   	ret    

000003a9 <atoi>:

int
atoi(const char *s)
{
 3a9:	55                   	push   %ebp
 3aa:	89 e5                	mov    %esp,%ebp
 3ac:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3b6:	eb 25                	jmp    3dd <atoi+0x34>
    n = n*10 + *s++ - '0';
 3b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3bb:	89 d0                	mov    %edx,%eax
 3bd:	c1 e0 02             	shl    $0x2,%eax
 3c0:	01 d0                	add    %edx,%eax
 3c2:	01 c0                	add    %eax,%eax
 3c4:	89 c1                	mov    %eax,%ecx
 3c6:	8b 45 08             	mov    0x8(%ebp),%eax
 3c9:	8d 50 01             	lea    0x1(%eax),%edx
 3cc:	89 55 08             	mov    %edx,0x8(%ebp)
 3cf:	0f b6 00             	movzbl (%eax),%eax
 3d2:	0f be c0             	movsbl %al,%eax
 3d5:	01 c8                	add    %ecx,%eax
 3d7:	83 e8 30             	sub    $0x30,%eax
 3da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
 3e0:	0f b6 00             	movzbl (%eax),%eax
 3e3:	3c 2f                	cmp    $0x2f,%al
 3e5:	7e 0a                	jle    3f1 <atoi+0x48>
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	0f b6 00             	movzbl (%eax),%eax
 3ed:	3c 39                	cmp    $0x39,%al
 3ef:	7e c7                	jle    3b8 <atoi+0xf>
  return n;
 3f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f4:	c9                   	leave  
 3f5:	c3                   	ret    

000003f6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3f6:	55                   	push   %ebp
 3f7:	89 e5                	mov    %esp,%ebp
 3f9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 3fc:	8b 45 08             	mov    0x8(%ebp),%eax
 3ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 402:	8b 45 0c             	mov    0xc(%ebp),%eax
 405:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 408:	eb 17                	jmp    421 <memmove+0x2b>
    *dst++ = *src++;
 40a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 40d:	8d 42 01             	lea    0x1(%edx),%eax
 410:	89 45 f8             	mov    %eax,-0x8(%ebp)
 413:	8b 45 fc             	mov    -0x4(%ebp),%eax
 416:	8d 48 01             	lea    0x1(%eax),%ecx
 419:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 41c:	0f b6 12             	movzbl (%edx),%edx
 41f:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 421:	8b 45 10             	mov    0x10(%ebp),%eax
 424:	8d 50 ff             	lea    -0x1(%eax),%edx
 427:	89 55 10             	mov    %edx,0x10(%ebp)
 42a:	85 c0                	test   %eax,%eax
 42c:	7f dc                	jg     40a <memmove+0x14>
  return vdst;
 42e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 431:	c9                   	leave  
 432:	c3                   	ret    

00000433 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 433:	b8 01 00 00 00       	mov    $0x1,%eax
 438:	cd 40                	int    $0x40
 43a:	c3                   	ret    

0000043b <exit>:
SYSCALL(exit)
 43b:	b8 02 00 00 00       	mov    $0x2,%eax
 440:	cd 40                	int    $0x40
 442:	c3                   	ret    

00000443 <wait>:
SYSCALL(wait)
 443:	b8 03 00 00 00       	mov    $0x3,%eax
 448:	cd 40                	int    $0x40
 44a:	c3                   	ret    

0000044b <pipe>:
SYSCALL(pipe)
 44b:	b8 04 00 00 00       	mov    $0x4,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	ret    

00000453 <read>:
SYSCALL(read)
 453:	b8 05 00 00 00       	mov    $0x5,%eax
 458:	cd 40                	int    $0x40
 45a:	c3                   	ret    

0000045b <write>:
SYSCALL(write)
 45b:	b8 10 00 00 00       	mov    $0x10,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	ret    

00000463 <close>:
SYSCALL(close)
 463:	b8 15 00 00 00       	mov    $0x15,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret    

0000046b <kill>:
SYSCALL(kill)
 46b:	b8 06 00 00 00       	mov    $0x6,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret    

00000473 <exec>:
SYSCALL(exec)
 473:	b8 07 00 00 00       	mov    $0x7,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret    

0000047b <open>:
SYSCALL(open)
 47b:	b8 0f 00 00 00       	mov    $0xf,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	ret    

00000483 <mknod>:
SYSCALL(mknod)
 483:	b8 11 00 00 00       	mov    $0x11,%eax
 488:	cd 40                	int    $0x40
 48a:	c3                   	ret    

0000048b <unlink>:
SYSCALL(unlink)
 48b:	b8 12 00 00 00       	mov    $0x12,%eax
 490:	cd 40                	int    $0x40
 492:	c3                   	ret    

00000493 <fstat>:
SYSCALL(fstat)
 493:	b8 08 00 00 00       	mov    $0x8,%eax
 498:	cd 40                	int    $0x40
 49a:	c3                   	ret    

0000049b <link>:
SYSCALL(link)
 49b:	b8 13 00 00 00       	mov    $0x13,%eax
 4a0:	cd 40                	int    $0x40
 4a2:	c3                   	ret    

000004a3 <mkdir>:
SYSCALL(mkdir)
 4a3:	b8 14 00 00 00       	mov    $0x14,%eax
 4a8:	cd 40                	int    $0x40
 4aa:	c3                   	ret    

000004ab <chdir>:
SYSCALL(chdir)
 4ab:	b8 09 00 00 00       	mov    $0x9,%eax
 4b0:	cd 40                	int    $0x40
 4b2:	c3                   	ret    

000004b3 <dup>:
SYSCALL(dup)
 4b3:	b8 0a 00 00 00       	mov    $0xa,%eax
 4b8:	cd 40                	int    $0x40
 4ba:	c3                   	ret    

000004bb <getpid>:
SYSCALL(getpid)
 4bb:	b8 0b 00 00 00       	mov    $0xb,%eax
 4c0:	cd 40                	int    $0x40
 4c2:	c3                   	ret    

000004c3 <sbrk>:
SYSCALL(sbrk)
 4c3:	b8 0c 00 00 00       	mov    $0xc,%eax
 4c8:	cd 40                	int    $0x40
 4ca:	c3                   	ret    

000004cb <sleep>:
SYSCALL(sleep)
 4cb:	b8 0d 00 00 00       	mov    $0xd,%eax
 4d0:	cd 40                	int    $0x40
 4d2:	c3                   	ret    

000004d3 <uptime>:
SYSCALL(uptime)
 4d3:	b8 0e 00 00 00       	mov    $0xe,%eax
 4d8:	cd 40                	int    $0x40
 4da:	c3                   	ret    

000004db <uthread_init>:

SYSCALL(uthread_init)
 4db:	b8 16 00 00 00       	mov    $0x16,%eax
 4e0:	cd 40                	int    $0x40
 4e2:	c3                   	ret    

000004e3 <check_thread>:
SYSCALL(check_thread)
 4e3:	b8 17 00 00 00       	mov    $0x17,%eax
 4e8:	cd 40                	int    $0x40
 4ea:	c3                   	ret    

000004eb <getpinfo>:

SYSCALL(getpinfo)
 4eb:	b8 18 00 00 00       	mov    $0x18,%eax
 4f0:	cd 40                	int    $0x40
 4f2:	c3                   	ret    

000004f3 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 4f3:	b8 19 00 00 00       	mov    $0x19,%eax
 4f8:	cd 40                	int    $0x40
 4fa:	c3                   	ret    

000004fb <yield>:
 4fb:	b8 1a 00 00 00       	mov    $0x1a,%eax
 500:	cd 40                	int    $0x40
 502:	c3                   	ret    

00000503 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 503:	55                   	push   %ebp
 504:	89 e5                	mov    %esp,%ebp
 506:	83 ec 18             	sub    $0x18,%esp
 509:	8b 45 0c             	mov    0xc(%ebp),%eax
 50c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 50f:	83 ec 04             	sub    $0x4,%esp
 512:	6a 01                	push   $0x1
 514:	8d 45 f4             	lea    -0xc(%ebp),%eax
 517:	50                   	push   %eax
 518:	ff 75 08             	push   0x8(%ebp)
 51b:	e8 3b ff ff ff       	call   45b <write>
 520:	83 c4 10             	add    $0x10,%esp
}
 523:	90                   	nop
 524:	c9                   	leave  
 525:	c3                   	ret    

00000526 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 526:	55                   	push   %ebp
 527:	89 e5                	mov    %esp,%ebp
 529:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 52c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 533:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 537:	74 17                	je     550 <printint+0x2a>
 539:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 53d:	79 11                	jns    550 <printint+0x2a>
    neg = 1;
 53f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 546:	8b 45 0c             	mov    0xc(%ebp),%eax
 549:	f7 d8                	neg    %eax
 54b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 54e:	eb 06                	jmp    556 <printint+0x30>
  } else {
    x = xx;
 550:	8b 45 0c             	mov    0xc(%ebp),%eax
 553:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 556:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 55d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 560:	8b 45 ec             	mov    -0x14(%ebp),%eax
 563:	ba 00 00 00 00       	mov    $0x0,%edx
 568:	f7 f1                	div    %ecx
 56a:	89 d1                	mov    %edx,%ecx
 56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56f:	8d 50 01             	lea    0x1(%eax),%edx
 572:	89 55 f4             	mov    %edx,-0xc(%ebp)
 575:	0f b6 91 78 0c 00 00 	movzbl 0xc78(%ecx),%edx
 57c:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 580:	8b 4d 10             	mov    0x10(%ebp),%ecx
 583:	8b 45 ec             	mov    -0x14(%ebp),%eax
 586:	ba 00 00 00 00       	mov    $0x0,%edx
 58b:	f7 f1                	div    %ecx
 58d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 590:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 594:	75 c7                	jne    55d <printint+0x37>
  if(neg)
 596:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 59a:	74 2d                	je     5c9 <printint+0xa3>
    buf[i++] = '-';
 59c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59f:	8d 50 01             	lea    0x1(%eax),%edx
 5a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5a5:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5aa:	eb 1d                	jmp    5c9 <printint+0xa3>
    putc(fd, buf[i]);
 5ac:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b2:	01 d0                	add    %edx,%eax
 5b4:	0f b6 00             	movzbl (%eax),%eax
 5b7:	0f be c0             	movsbl %al,%eax
 5ba:	83 ec 08             	sub    $0x8,%esp
 5bd:	50                   	push   %eax
 5be:	ff 75 08             	push   0x8(%ebp)
 5c1:	e8 3d ff ff ff       	call   503 <putc>
 5c6:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 5c9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d1:	79 d9                	jns    5ac <printint+0x86>
}
 5d3:	90                   	nop
 5d4:	90                   	nop
 5d5:	c9                   	leave  
 5d6:	c3                   	ret    

000005d7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5d7:	55                   	push   %ebp
 5d8:	89 e5                	mov    %esp,%ebp
 5da:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5e4:	8d 45 0c             	lea    0xc(%ebp),%eax
 5e7:	83 c0 04             	add    $0x4,%eax
 5ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5f4:	e9 59 01 00 00       	jmp    752 <printf+0x17b>
    c = fmt[i] & 0xff;
 5f9:	8b 55 0c             	mov    0xc(%ebp),%edx
 5fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ff:	01 d0                	add    %edx,%eax
 601:	0f b6 00             	movzbl (%eax),%eax
 604:	0f be c0             	movsbl %al,%eax
 607:	25 ff 00 00 00       	and    $0xff,%eax
 60c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 60f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 613:	75 2c                	jne    641 <printf+0x6a>
      if(c == '%'){
 615:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 619:	75 0c                	jne    627 <printf+0x50>
        state = '%';
 61b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 622:	e9 27 01 00 00       	jmp    74e <printf+0x177>
      } else {
        putc(fd, c);
 627:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 62a:	0f be c0             	movsbl %al,%eax
 62d:	83 ec 08             	sub    $0x8,%esp
 630:	50                   	push   %eax
 631:	ff 75 08             	push   0x8(%ebp)
 634:	e8 ca fe ff ff       	call   503 <putc>
 639:	83 c4 10             	add    $0x10,%esp
 63c:	e9 0d 01 00 00       	jmp    74e <printf+0x177>
      }
    } else if(state == '%'){
 641:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 645:	0f 85 03 01 00 00    	jne    74e <printf+0x177>
      if(c == 'd'){
 64b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 64f:	75 1e                	jne    66f <printf+0x98>
        printint(fd, *ap, 10, 1);
 651:	8b 45 e8             	mov    -0x18(%ebp),%eax
 654:	8b 00                	mov    (%eax),%eax
 656:	6a 01                	push   $0x1
 658:	6a 0a                	push   $0xa
 65a:	50                   	push   %eax
 65b:	ff 75 08             	push   0x8(%ebp)
 65e:	e8 c3 fe ff ff       	call   526 <printint>
 663:	83 c4 10             	add    $0x10,%esp
        ap++;
 666:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 66a:	e9 d8 00 00 00       	jmp    747 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 66f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 673:	74 06                	je     67b <printf+0xa4>
 675:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 679:	75 1e                	jne    699 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 67b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67e:	8b 00                	mov    (%eax),%eax
 680:	6a 00                	push   $0x0
 682:	6a 10                	push   $0x10
 684:	50                   	push   %eax
 685:	ff 75 08             	push   0x8(%ebp)
 688:	e8 99 fe ff ff       	call   526 <printint>
 68d:	83 c4 10             	add    $0x10,%esp
        ap++;
 690:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 694:	e9 ae 00 00 00       	jmp    747 <printf+0x170>
      } else if(c == 's'){
 699:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 69d:	75 43                	jne    6e2 <printf+0x10b>
        s = (char*)*ap;
 69f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a2:	8b 00                	mov    (%eax),%eax
 6a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6a7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6af:	75 25                	jne    6d6 <printf+0xff>
          s = "(null)";
 6b1:	c7 45 f4 09 0a 00 00 	movl   $0xa09,-0xc(%ebp)
        while(*s != 0){
 6b8:	eb 1c                	jmp    6d6 <printf+0xff>
          putc(fd, *s);
 6ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bd:	0f b6 00             	movzbl (%eax),%eax
 6c0:	0f be c0             	movsbl %al,%eax
 6c3:	83 ec 08             	sub    $0x8,%esp
 6c6:	50                   	push   %eax
 6c7:	ff 75 08             	push   0x8(%ebp)
 6ca:	e8 34 fe ff ff       	call   503 <putc>
 6cf:	83 c4 10             	add    $0x10,%esp
          s++;
 6d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 6d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d9:	0f b6 00             	movzbl (%eax),%eax
 6dc:	84 c0                	test   %al,%al
 6de:	75 da                	jne    6ba <printf+0xe3>
 6e0:	eb 65                	jmp    747 <printf+0x170>
        }
      } else if(c == 'c'){
 6e2:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6e6:	75 1d                	jne    705 <printf+0x12e>
        putc(fd, *ap);
 6e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6eb:	8b 00                	mov    (%eax),%eax
 6ed:	0f be c0             	movsbl %al,%eax
 6f0:	83 ec 08             	sub    $0x8,%esp
 6f3:	50                   	push   %eax
 6f4:	ff 75 08             	push   0x8(%ebp)
 6f7:	e8 07 fe ff ff       	call   503 <putc>
 6fc:	83 c4 10             	add    $0x10,%esp
        ap++;
 6ff:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 703:	eb 42                	jmp    747 <printf+0x170>
      } else if(c == '%'){
 705:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 709:	75 17                	jne    722 <printf+0x14b>
        putc(fd, c);
 70b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70e:	0f be c0             	movsbl %al,%eax
 711:	83 ec 08             	sub    $0x8,%esp
 714:	50                   	push   %eax
 715:	ff 75 08             	push   0x8(%ebp)
 718:	e8 e6 fd ff ff       	call   503 <putc>
 71d:	83 c4 10             	add    $0x10,%esp
 720:	eb 25                	jmp    747 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 722:	83 ec 08             	sub    $0x8,%esp
 725:	6a 25                	push   $0x25
 727:	ff 75 08             	push   0x8(%ebp)
 72a:	e8 d4 fd ff ff       	call   503 <putc>
 72f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 735:	0f be c0             	movsbl %al,%eax
 738:	83 ec 08             	sub    $0x8,%esp
 73b:	50                   	push   %eax
 73c:	ff 75 08             	push   0x8(%ebp)
 73f:	e8 bf fd ff ff       	call   503 <putc>
 744:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 747:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 74e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 752:	8b 55 0c             	mov    0xc(%ebp),%edx
 755:	8b 45 f0             	mov    -0x10(%ebp),%eax
 758:	01 d0                	add    %edx,%eax
 75a:	0f b6 00             	movzbl (%eax),%eax
 75d:	84 c0                	test   %al,%al
 75f:	0f 85 94 fe ff ff    	jne    5f9 <printf+0x22>
    }
  }
}
 765:	90                   	nop
 766:	90                   	nop
 767:	c9                   	leave  
 768:	c3                   	ret    

00000769 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 769:	55                   	push   %ebp
 76a:	89 e5                	mov    %esp,%ebp
 76c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76f:	8b 45 08             	mov    0x8(%ebp),%eax
 772:	83 e8 08             	sub    $0x8,%eax
 775:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 778:	a1 94 0c 00 00       	mov    0xc94,%eax
 77d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 780:	eb 24                	jmp    7a6 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 782:	8b 45 fc             	mov    -0x4(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 78a:	72 12                	jb     79e <free+0x35>
 78c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 792:	77 24                	ja     7b8 <free+0x4f>
 794:	8b 45 fc             	mov    -0x4(%ebp),%eax
 797:	8b 00                	mov    (%eax),%eax
 799:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 79c:	72 1a                	jb     7b8 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a1:	8b 00                	mov    (%eax),%eax
 7a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ac:	76 d4                	jbe    782 <free+0x19>
 7ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b1:	8b 00                	mov    (%eax),%eax
 7b3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7b6:	73 ca                	jae    782 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bb:	8b 40 04             	mov    0x4(%eax),%eax
 7be:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c8:	01 c2                	add    %eax,%edx
 7ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cd:	8b 00                	mov    (%eax),%eax
 7cf:	39 c2                	cmp    %eax,%edx
 7d1:	75 24                	jne    7f7 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d6:	8b 50 04             	mov    0x4(%eax),%edx
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	8b 40 04             	mov    0x4(%eax),%eax
 7e1:	01 c2                	add    %eax,%edx
 7e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e6:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	8b 10                	mov    (%eax),%edx
 7f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f3:	89 10                	mov    %edx,(%eax)
 7f5:	eb 0a                	jmp    801 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fa:	8b 10                	mov    (%eax),%edx
 7fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ff:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 801:	8b 45 fc             	mov    -0x4(%ebp),%eax
 804:	8b 40 04             	mov    0x4(%eax),%eax
 807:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 80e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 811:	01 d0                	add    %edx,%eax
 813:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 816:	75 20                	jne    838 <free+0xcf>
    p->s.size += bp->s.size;
 818:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81b:	8b 50 04             	mov    0x4(%eax),%edx
 81e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 821:	8b 40 04             	mov    0x4(%eax),%eax
 824:	01 c2                	add    %eax,%edx
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 82c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82f:	8b 10                	mov    (%eax),%edx
 831:	8b 45 fc             	mov    -0x4(%ebp),%eax
 834:	89 10                	mov    %edx,(%eax)
 836:	eb 08                	jmp    840 <free+0xd7>
  } else
    p->s.ptr = bp;
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 83e:	89 10                	mov    %edx,(%eax)
  freep = p;
 840:	8b 45 fc             	mov    -0x4(%ebp),%eax
 843:	a3 94 0c 00 00       	mov    %eax,0xc94
}
 848:	90                   	nop
 849:	c9                   	leave  
 84a:	c3                   	ret    

0000084b <morecore>:

static Header*
morecore(uint nu)
{
 84b:	55                   	push   %ebp
 84c:	89 e5                	mov    %esp,%ebp
 84e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 851:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 858:	77 07                	ja     861 <morecore+0x16>
    nu = 4096;
 85a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 861:	8b 45 08             	mov    0x8(%ebp),%eax
 864:	c1 e0 03             	shl    $0x3,%eax
 867:	83 ec 0c             	sub    $0xc,%esp
 86a:	50                   	push   %eax
 86b:	e8 53 fc ff ff       	call   4c3 <sbrk>
 870:	83 c4 10             	add    $0x10,%esp
 873:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 876:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 87a:	75 07                	jne    883 <morecore+0x38>
    return 0;
 87c:	b8 00 00 00 00       	mov    $0x0,%eax
 881:	eb 26                	jmp    8a9 <morecore+0x5e>
  hp = (Header*)p;
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 889:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88c:	8b 55 08             	mov    0x8(%ebp),%edx
 88f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 892:	8b 45 f0             	mov    -0x10(%ebp),%eax
 895:	83 c0 08             	add    $0x8,%eax
 898:	83 ec 0c             	sub    $0xc,%esp
 89b:	50                   	push   %eax
 89c:	e8 c8 fe ff ff       	call   769 <free>
 8a1:	83 c4 10             	add    $0x10,%esp
  return freep;
 8a4:	a1 94 0c 00 00       	mov    0xc94,%eax
}
 8a9:	c9                   	leave  
 8aa:	c3                   	ret    

000008ab <malloc>:

void*
malloc(uint nbytes)
{
 8ab:	55                   	push   %ebp
 8ac:	89 e5                	mov    %esp,%ebp
 8ae:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b1:	8b 45 08             	mov    0x8(%ebp),%eax
 8b4:	83 c0 07             	add    $0x7,%eax
 8b7:	c1 e8 03             	shr    $0x3,%eax
 8ba:	83 c0 01             	add    $0x1,%eax
 8bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8c0:	a1 94 0c 00 00       	mov    0xc94,%eax
 8c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8cc:	75 23                	jne    8f1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8ce:	c7 45 f0 8c 0c 00 00 	movl   $0xc8c,-0x10(%ebp)
 8d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d8:	a3 94 0c 00 00       	mov    %eax,0xc94
 8dd:	a1 94 0c 00 00       	mov    0xc94,%eax
 8e2:	a3 8c 0c 00 00       	mov    %eax,0xc8c
    base.s.size = 0;
 8e7:	c7 05 90 0c 00 00 00 	movl   $0x0,0xc90
 8ee:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f4:	8b 00                	mov    (%eax),%eax
 8f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fc:	8b 40 04             	mov    0x4(%eax),%eax
 8ff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 902:	77 4d                	ja     951 <malloc+0xa6>
      if(p->s.size == nunits)
 904:	8b 45 f4             	mov    -0xc(%ebp),%eax
 907:	8b 40 04             	mov    0x4(%eax),%eax
 90a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 90d:	75 0c                	jne    91b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	8b 10                	mov    (%eax),%edx
 914:	8b 45 f0             	mov    -0x10(%ebp),%eax
 917:	89 10                	mov    %edx,(%eax)
 919:	eb 26                	jmp    941 <malloc+0x96>
      else {
        p->s.size -= nunits;
 91b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91e:	8b 40 04             	mov    0x4(%eax),%eax
 921:	2b 45 ec             	sub    -0x14(%ebp),%eax
 924:	89 c2                	mov    %eax,%edx
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 92c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92f:	8b 40 04             	mov    0x4(%eax),%eax
 932:	c1 e0 03             	shl    $0x3,%eax
 935:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 938:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 93e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 941:	8b 45 f0             	mov    -0x10(%ebp),%eax
 944:	a3 94 0c 00 00       	mov    %eax,0xc94
      return (void*)(p + 1);
 949:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94c:	83 c0 08             	add    $0x8,%eax
 94f:	eb 3b                	jmp    98c <malloc+0xe1>
    }
    if(p == freep)
 951:	a1 94 0c 00 00       	mov    0xc94,%eax
 956:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 959:	75 1e                	jne    979 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 95b:	83 ec 0c             	sub    $0xc,%esp
 95e:	ff 75 ec             	push   -0x14(%ebp)
 961:	e8 e5 fe ff ff       	call   84b <morecore>
 966:	83 c4 10             	add    $0x10,%esp
 969:	89 45 f4             	mov    %eax,-0xc(%ebp)
 96c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 970:	75 07                	jne    979 <malloc+0xce>
        return 0;
 972:	b8 00 00 00 00       	mov    $0x0,%eax
 977:	eb 13                	jmp    98c <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 979:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 97f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 982:	8b 00                	mov    (%eax),%eax
 984:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 987:	e9 6d ff ff ff       	jmp    8f9 <malloc+0x4e>
  }
}
 98c:	c9                   	leave  
 98d:	c3                   	ret    
