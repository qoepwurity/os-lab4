
_testmlfq2:     file format elf32-i386


Disassembly of section .text:

00000000 <spin>:
#include "pstat.h"

#define NUM_CHILDREN 3
int setSchedPolicy(int policy);

void spin(int count) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 10             	sub    $0x10,%esp
  int i, x = 0;
   7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for (i = 0; i < count; i++)
   e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  15:	eb 2e                	jmp    45 <spin+0x45>
    x += i % 10;
  17:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  1a:	ba 67 66 66 66       	mov    $0x66666667,%edx
  1f:	89 c8                	mov    %ecx,%eax
  21:	f7 ea                	imul   %edx
  23:	89 d0                	mov    %edx,%eax
  25:	c1 f8 02             	sar    $0x2,%eax
  28:	89 cb                	mov    %ecx,%ebx
  2a:	c1 fb 1f             	sar    $0x1f,%ebx
  2d:	29 d8                	sub    %ebx,%eax
  2f:	89 c2                	mov    %eax,%edx
  31:	89 d0                	mov    %edx,%eax
  33:	c1 e0 02             	shl    $0x2,%eax
  36:	01 d0                	add    %edx,%eax
  38:	01 c0                	add    %eax,%eax
  3a:	29 c1                	sub    %eax,%ecx
  3c:	89 ca                	mov    %ecx,%edx
  3e:	01 55 f4             	add    %edx,-0xc(%ebp)
  for (i = 0; i < count; i++)
  41:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  45:	8b 45 f8             	mov    -0x8(%ebp),%eax
  48:	3b 45 08             	cmp    0x8(%ebp),%eax
  4b:	7c ca                	jl     17 <spin+0x17>
}
  4d:	90                   	nop
  4e:	90                   	nop
  4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  52:	c9                   	leave  
  53:	c3                   	ret    

00000054 <main>:

int
main(int argc, char *argv[])
{
  54:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  58:	83 e4 f0             	and    $0xfffffff0,%esp
  5b:	ff 71 fc             	push   -0x4(%ecx)
  5e:	55                   	push   %ebp
  5f:	89 e5                	mov    %esp,%ebp
  61:	51                   	push   %ecx
  62:	81 ec 14 0c 00 00    	sub    $0xc14,%esp
  struct pstat st;

  // MLFQ w/o tracking 모드로 설정
  if (setSchedPolicy(2) < 0) {
  68:	83 ec 0c             	sub    $0xc,%esp
  6b:	6a 02                	push   $0x2
  6d:	e8 43 04 00 00       	call   4b5 <setSchedPolicy>
  72:	83 c4 10             	add    $0x10,%esp
  75:	85 c0                	test   %eax,%eax
  77:	79 17                	jns    90 <main+0x3c>
    printf(1, "Failed to set sched policy\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 58 09 00 00       	push   $0x958
  81:	6a 01                	push   $0x1
  83:	e8 19 05 00 00       	call   5a1 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 6d 03 00 00       	call   3fd <exit>
  }

  int i;
  for (i = 0; i < NUM_CHILDREN; i++) {
  90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  97:	eb 22                	jmp    bb <main+0x67>
    if (fork() == 0) {
  99:	e8 57 03 00 00       	call   3f5 <fork>
  9e:	85 c0                	test   %eax,%eax
  a0:	75 15                	jne    b7 <main+0x63>
      // 자식: CPU 소모 작업 반복
      spin(1 << 25);  // 충분히 긴 루프
  a2:	83 ec 0c             	sub    $0xc,%esp
  a5:	68 00 00 00 02       	push   $0x2000000
  aa:	e8 51 ff ff ff       	call   0 <spin>
  af:	83 c4 10             	add    $0x10,%esp
      exit();
  b2:	e8 46 03 00 00       	call   3fd <exit>
  for (i = 0; i < NUM_CHILDREN; i++) {
  b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  bb:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  bf:	7e d8                	jle    99 <main+0x45>
    }
  }

  // 부모: 모든 자식 기다림
  for (i = 0; i < NUM_CHILDREN; i++) {
  c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  c8:	eb 09                	jmp    d3 <main+0x7f>
    wait();
  ca:	e8 36 03 00 00       	call   405 <wait>
  for (i = 0; i < NUM_CHILDREN; i++) {
  cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  d3:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  d7:	7e f1                	jle    ca <main+0x76>
  }

  // 정보 수집 및 출력
  if (getpinfo(&st) < 0) {
  d9:	83 ec 0c             	sub    $0xc,%esp
  dc:	8d 85 f0 f3 ff ff    	lea    -0xc10(%ebp),%eax
  e2:	50                   	push   %eax
  e3:	e8 c5 03 00 00       	call   4ad <getpinfo>
  e8:	83 c4 10             	add    $0x10,%esp
  eb:	85 c0                	test   %eax,%eax
  ed:	79 17                	jns    106 <main+0xb2>
    printf(1, "Failed to get pinfo\n");
  ef:	83 ec 08             	sub    $0x8,%esp
  f2:	68 74 09 00 00       	push   $0x974
  f7:	6a 01                	push   $0x1
  f9:	e8 a3 04 00 00       	call   5a1 <printf>
  fe:	83 c4 10             	add    $0x10,%esp
    exit();
 101:	e8 f7 02 00 00       	call   3fd <exit>
  }

  for (i = 0; i < NPROC; i++) {
 106:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 10d:	e9 85 00 00 00       	jmp    197 <main+0x143>
    if (st.inuse[i]) {
 112:	8b 45 f4             	mov    -0xc(%ebp),%eax
 115:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
 11c:	85 c0                	test   %eax,%eax
 11e:	74 73                	je     193 <main+0x13f>
      printf(1, "PID %d: ", st.pid[i]);
 120:	8b 45 f4             	mov    -0xc(%ebp),%eax
 123:	83 c0 40             	add    $0x40,%eax
 126:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
 12d:	83 ec 04             	sub    $0x4,%esp
 130:	50                   	push   %eax
 131:	68 89 09 00 00       	push   $0x989
 136:	6a 01                	push   $0x1
 138:	e8 64 04 00 00       	call   5a1 <printf>
 13d:	83 c4 10             	add    $0x10,%esp
      for (int l = 3; l >= 0; l--) {
 140:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
 147:	eb 32                	jmp    17b <main+0x127>
        printf(1, "L%d: %d ", l, st.ticks[i][l]);
 149:	8b 45 f4             	mov    -0xc(%ebp),%eax
 14c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 153:	8b 45 f0             	mov    -0x10(%ebp),%eax
 156:	01 d0                	add    %edx,%eax
 158:	05 00 01 00 00       	add    $0x100,%eax
 15d:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
 164:	50                   	push   %eax
 165:	ff 75 f0             	push   -0x10(%ebp)
 168:	68 92 09 00 00       	push   $0x992
 16d:	6a 01                	push   $0x1
 16f:	e8 2d 04 00 00       	call   5a1 <printf>
 174:	83 c4 10             	add    $0x10,%esp
      for (int l = 3; l >= 0; l--) {
 177:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
 17b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 17f:	79 c8                	jns    149 <main+0xf5>
      }
      printf(1, "\n");
 181:	83 ec 08             	sub    $0x8,%esp
 184:	68 9b 09 00 00       	push   $0x99b
 189:	6a 01                	push   $0x1
 18b:	e8 11 04 00 00       	call   5a1 <printf>
 190:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < NPROC; i++) {
 193:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 197:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 19b:	0f 8e 71 ff ff ff    	jle    112 <main+0xbe>
    }
  }

  exit();
 1a1:	e8 57 02 00 00       	call   3fd <exit>

000001a6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1a6:	55                   	push   %ebp
 1a7:	89 e5                	mov    %esp,%ebp
 1a9:	57                   	push   %edi
 1aa:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1ae:	8b 55 10             	mov    0x10(%ebp),%edx
 1b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b4:	89 cb                	mov    %ecx,%ebx
 1b6:	89 df                	mov    %ebx,%edi
 1b8:	89 d1                	mov    %edx,%ecx
 1ba:	fc                   	cld    
 1bb:	f3 aa                	rep stos %al,%es:(%edi)
 1bd:	89 ca                	mov    %ecx,%edx
 1bf:	89 fb                	mov    %edi,%ebx
 1c1:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1c4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1c7:	90                   	nop
 1c8:	5b                   	pop    %ebx
 1c9:	5f                   	pop    %edi
 1ca:	5d                   	pop    %ebp
 1cb:	c3                   	ret    

000001cc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1cc:	55                   	push   %ebp
 1cd:	89 e5                	mov    %esp,%ebp
 1cf:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1d2:	8b 45 08             	mov    0x8(%ebp),%eax
 1d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1d8:	90                   	nop
 1d9:	8b 55 0c             	mov    0xc(%ebp),%edx
 1dc:	8d 42 01             	lea    0x1(%edx),%eax
 1df:	89 45 0c             	mov    %eax,0xc(%ebp)
 1e2:	8b 45 08             	mov    0x8(%ebp),%eax
 1e5:	8d 48 01             	lea    0x1(%eax),%ecx
 1e8:	89 4d 08             	mov    %ecx,0x8(%ebp)
 1eb:	0f b6 12             	movzbl (%edx),%edx
 1ee:	88 10                	mov    %dl,(%eax)
 1f0:	0f b6 00             	movzbl (%eax),%eax
 1f3:	84 c0                	test   %al,%al
 1f5:	75 e2                	jne    1d9 <strcpy+0xd>
    ;
  return os;
 1f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1fa:	c9                   	leave  
 1fb:	c3                   	ret    

000001fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1ff:	eb 08                	jmp    209 <strcmp+0xd>
    p++, q++;
 201:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 205:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 209:	8b 45 08             	mov    0x8(%ebp),%eax
 20c:	0f b6 00             	movzbl (%eax),%eax
 20f:	84 c0                	test   %al,%al
 211:	74 10                	je     223 <strcmp+0x27>
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	0f b6 10             	movzbl (%eax),%edx
 219:	8b 45 0c             	mov    0xc(%ebp),%eax
 21c:	0f b6 00             	movzbl (%eax),%eax
 21f:	38 c2                	cmp    %al,%dl
 221:	74 de                	je     201 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	0f b6 00             	movzbl (%eax),%eax
 229:	0f b6 d0             	movzbl %al,%edx
 22c:	8b 45 0c             	mov    0xc(%ebp),%eax
 22f:	0f b6 00             	movzbl (%eax),%eax
 232:	0f b6 c8             	movzbl %al,%ecx
 235:	89 d0                	mov    %edx,%eax
 237:	29 c8                	sub    %ecx,%eax
}
 239:	5d                   	pop    %ebp
 23a:	c3                   	ret    

0000023b <strlen>:

uint
strlen(char *s)
{
 23b:	55                   	push   %ebp
 23c:	89 e5                	mov    %esp,%ebp
 23e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 241:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 248:	eb 04                	jmp    24e <strlen+0x13>
 24a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 24e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 251:	8b 45 08             	mov    0x8(%ebp),%eax
 254:	01 d0                	add    %edx,%eax
 256:	0f b6 00             	movzbl (%eax),%eax
 259:	84 c0                	test   %al,%al
 25b:	75 ed                	jne    24a <strlen+0xf>
    ;
  return n;
 25d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 260:	c9                   	leave  
 261:	c3                   	ret    

00000262 <memset>:

void*
memset(void *dst, int c, uint n)
{
 262:	55                   	push   %ebp
 263:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 265:	8b 45 10             	mov    0x10(%ebp),%eax
 268:	50                   	push   %eax
 269:	ff 75 0c             	push   0xc(%ebp)
 26c:	ff 75 08             	push   0x8(%ebp)
 26f:	e8 32 ff ff ff       	call   1a6 <stosb>
 274:	83 c4 0c             	add    $0xc,%esp
  return dst;
 277:	8b 45 08             	mov    0x8(%ebp),%eax
}
 27a:	c9                   	leave  
 27b:	c3                   	ret    

0000027c <strchr>:

char*
strchr(const char *s, char c)
{
 27c:	55                   	push   %ebp
 27d:	89 e5                	mov    %esp,%ebp
 27f:	83 ec 04             	sub    $0x4,%esp
 282:	8b 45 0c             	mov    0xc(%ebp),%eax
 285:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 288:	eb 14                	jmp    29e <strchr+0x22>
    if(*s == c)
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	0f b6 00             	movzbl (%eax),%eax
 290:	38 45 fc             	cmp    %al,-0x4(%ebp)
 293:	75 05                	jne    29a <strchr+0x1e>
      return (char*)s;
 295:	8b 45 08             	mov    0x8(%ebp),%eax
 298:	eb 13                	jmp    2ad <strchr+0x31>
  for(; *s; s++)
 29a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
 2a1:	0f b6 00             	movzbl (%eax),%eax
 2a4:	84 c0                	test   %al,%al
 2a6:	75 e2                	jne    28a <strchr+0xe>
  return 0;
 2a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2ad:	c9                   	leave  
 2ae:	c3                   	ret    

000002af <gets>:

char*
gets(char *buf, int max)
{
 2af:	55                   	push   %ebp
 2b0:	89 e5                	mov    %esp,%ebp
 2b2:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2bc:	eb 42                	jmp    300 <gets+0x51>
    cc = read(0, &c, 1);
 2be:	83 ec 04             	sub    $0x4,%esp
 2c1:	6a 01                	push   $0x1
 2c3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2c6:	50                   	push   %eax
 2c7:	6a 00                	push   $0x0
 2c9:	e8 47 01 00 00       	call   415 <read>
 2ce:	83 c4 10             	add    $0x10,%esp
 2d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2d8:	7e 33                	jle    30d <gets+0x5e>
      break;
    buf[i++] = c;
 2da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2dd:	8d 50 01             	lea    0x1(%eax),%edx
 2e0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2e3:	89 c2                	mov    %eax,%edx
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	01 c2                	add    %eax,%edx
 2ea:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2ee:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2f0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2f4:	3c 0a                	cmp    $0xa,%al
 2f6:	74 16                	je     30e <gets+0x5f>
 2f8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2fc:	3c 0d                	cmp    $0xd,%al
 2fe:	74 0e                	je     30e <gets+0x5f>
  for(i=0; i+1 < max; ){
 300:	8b 45 f4             	mov    -0xc(%ebp),%eax
 303:	83 c0 01             	add    $0x1,%eax
 306:	39 45 0c             	cmp    %eax,0xc(%ebp)
 309:	7f b3                	jg     2be <gets+0xf>
 30b:	eb 01                	jmp    30e <gets+0x5f>
      break;
 30d:	90                   	nop
      break;
  }
  buf[i] = '\0';
 30e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 311:	8b 45 08             	mov    0x8(%ebp),%eax
 314:	01 d0                	add    %edx,%eax
 316:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 319:	8b 45 08             	mov    0x8(%ebp),%eax
}
 31c:	c9                   	leave  
 31d:	c3                   	ret    

0000031e <stat>:

int
stat(char *n, struct stat *st)
{
 31e:	55                   	push   %ebp
 31f:	89 e5                	mov    %esp,%ebp
 321:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 324:	83 ec 08             	sub    $0x8,%esp
 327:	6a 00                	push   $0x0
 329:	ff 75 08             	push   0x8(%ebp)
 32c:	e8 0c 01 00 00       	call   43d <open>
 331:	83 c4 10             	add    $0x10,%esp
 334:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 337:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 33b:	79 07                	jns    344 <stat+0x26>
    return -1;
 33d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 342:	eb 25                	jmp    369 <stat+0x4b>
  r = fstat(fd, st);
 344:	83 ec 08             	sub    $0x8,%esp
 347:	ff 75 0c             	push   0xc(%ebp)
 34a:	ff 75 f4             	push   -0xc(%ebp)
 34d:	e8 03 01 00 00       	call   455 <fstat>
 352:	83 c4 10             	add    $0x10,%esp
 355:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 358:	83 ec 0c             	sub    $0xc,%esp
 35b:	ff 75 f4             	push   -0xc(%ebp)
 35e:	e8 c2 00 00 00       	call   425 <close>
 363:	83 c4 10             	add    $0x10,%esp
  return r;
 366:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 369:	c9                   	leave  
 36a:	c3                   	ret    

0000036b <atoi>:

int
atoi(const char *s)
{
 36b:	55                   	push   %ebp
 36c:	89 e5                	mov    %esp,%ebp
 36e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 371:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 378:	eb 25                	jmp    39f <atoi+0x34>
    n = n*10 + *s++ - '0';
 37a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 37d:	89 d0                	mov    %edx,%eax
 37f:	c1 e0 02             	shl    $0x2,%eax
 382:	01 d0                	add    %edx,%eax
 384:	01 c0                	add    %eax,%eax
 386:	89 c1                	mov    %eax,%ecx
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	8d 50 01             	lea    0x1(%eax),%edx
 38e:	89 55 08             	mov    %edx,0x8(%ebp)
 391:	0f b6 00             	movzbl (%eax),%eax
 394:	0f be c0             	movsbl %al,%eax
 397:	01 c8                	add    %ecx,%eax
 399:	83 e8 30             	sub    $0x30,%eax
 39c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	0f b6 00             	movzbl (%eax),%eax
 3a5:	3c 2f                	cmp    $0x2f,%al
 3a7:	7e 0a                	jle    3b3 <atoi+0x48>
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	0f b6 00             	movzbl (%eax),%eax
 3af:	3c 39                	cmp    $0x39,%al
 3b1:	7e c7                	jle    37a <atoi+0xf>
  return n;
 3b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b6:	c9                   	leave  
 3b7:	c3                   	ret    

000003b8 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3b8:	55                   	push   %ebp
 3b9:	89 e5                	mov    %esp,%ebp
 3bb:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 3be:	8b 45 08             	mov    0x8(%ebp),%eax
 3c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3ca:	eb 17                	jmp    3e3 <memmove+0x2b>
    *dst++ = *src++;
 3cc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3cf:	8d 42 01             	lea    0x1(%edx),%eax
 3d2:	89 45 f8             	mov    %eax,-0x8(%ebp)
 3d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3d8:	8d 48 01             	lea    0x1(%eax),%ecx
 3db:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 3de:	0f b6 12             	movzbl (%edx),%edx
 3e1:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 3e3:	8b 45 10             	mov    0x10(%ebp),%eax
 3e6:	8d 50 ff             	lea    -0x1(%eax),%edx
 3e9:	89 55 10             	mov    %edx,0x10(%ebp)
 3ec:	85 c0                	test   %eax,%eax
 3ee:	7f dc                	jg     3cc <memmove+0x14>
  return vdst;
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f3:	c9                   	leave  
 3f4:	c3                   	ret    

000003f5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3f5:	b8 01 00 00 00       	mov    $0x1,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <exit>:
SYSCALL(exit)
 3fd:	b8 02 00 00 00       	mov    $0x2,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <wait>:
SYSCALL(wait)
 405:	b8 03 00 00 00       	mov    $0x3,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <pipe>:
SYSCALL(pipe)
 40d:	b8 04 00 00 00       	mov    $0x4,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <read>:
SYSCALL(read)
 415:	b8 05 00 00 00       	mov    $0x5,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <write>:
SYSCALL(write)
 41d:	b8 10 00 00 00       	mov    $0x10,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <close>:
SYSCALL(close)
 425:	b8 15 00 00 00       	mov    $0x15,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <kill>:
SYSCALL(kill)
 42d:	b8 06 00 00 00       	mov    $0x6,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <exec>:
SYSCALL(exec)
 435:	b8 07 00 00 00       	mov    $0x7,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <open>:
SYSCALL(open)
 43d:	b8 0f 00 00 00       	mov    $0xf,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <mknod>:
SYSCALL(mknod)
 445:	b8 11 00 00 00       	mov    $0x11,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <unlink>:
SYSCALL(unlink)
 44d:	b8 12 00 00 00       	mov    $0x12,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <fstat>:
SYSCALL(fstat)
 455:	b8 08 00 00 00       	mov    $0x8,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <link>:
SYSCALL(link)
 45d:	b8 13 00 00 00       	mov    $0x13,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <mkdir>:
SYSCALL(mkdir)
 465:	b8 14 00 00 00       	mov    $0x14,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <chdir>:
SYSCALL(chdir)
 46d:	b8 09 00 00 00       	mov    $0x9,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret    

00000475 <dup>:
SYSCALL(dup)
 475:	b8 0a 00 00 00       	mov    $0xa,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret    

0000047d <getpid>:
SYSCALL(getpid)
 47d:	b8 0b 00 00 00       	mov    $0xb,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret    

00000485 <sbrk>:
SYSCALL(sbrk)
 485:	b8 0c 00 00 00       	mov    $0xc,%eax
 48a:	cd 40                	int    $0x40
 48c:	c3                   	ret    

0000048d <sleep>:
SYSCALL(sleep)
 48d:	b8 0d 00 00 00       	mov    $0xd,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret    

00000495 <uptime>:
SYSCALL(uptime)
 495:	b8 0e 00 00 00       	mov    $0xe,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <uthread_init>:

SYSCALL(uthread_init)
 49d:	b8 16 00 00 00       	mov    $0x16,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <check_thread>:
SYSCALL(check_thread)
 4a5:	b8 17 00 00 00       	mov    $0x17,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <getpinfo>:

SYSCALL(getpinfo)
 4ad:	b8 18 00 00 00       	mov    $0x18,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 4b5:	b8 19 00 00 00       	mov    $0x19,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <yield>:
SYSCALL(yield)
 4bd:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <printpt>:

 4c5:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4cd:	55                   	push   %ebp
 4ce:	89 e5                	mov    %esp,%ebp
 4d0:	83 ec 18             	sub    $0x18,%esp
 4d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d6:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4d9:	83 ec 04             	sub    $0x4,%esp
 4dc:	6a 01                	push   $0x1
 4de:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4e1:	50                   	push   %eax
 4e2:	ff 75 08             	push   0x8(%ebp)
 4e5:	e8 33 ff ff ff       	call   41d <write>
 4ea:	83 c4 10             	add    $0x10,%esp
}
 4ed:	90                   	nop
 4ee:	c9                   	leave  
 4ef:	c3                   	ret    

000004f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f0:	55                   	push   %ebp
 4f1:	89 e5                	mov    %esp,%ebp
 4f3:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4fd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 501:	74 17                	je     51a <printint+0x2a>
 503:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 507:	79 11                	jns    51a <printint+0x2a>
    neg = 1;
 509:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 510:	8b 45 0c             	mov    0xc(%ebp),%eax
 513:	f7 d8                	neg    %eax
 515:	89 45 ec             	mov    %eax,-0x14(%ebp)
 518:	eb 06                	jmp    520 <printint+0x30>
  } else {
    x = xx;
 51a:	8b 45 0c             	mov    0xc(%ebp),%eax
 51d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 520:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 527:	8b 4d 10             	mov    0x10(%ebp),%ecx
 52a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 52d:	ba 00 00 00 00       	mov    $0x0,%edx
 532:	f7 f1                	div    %ecx
 534:	89 d1                	mov    %edx,%ecx
 536:	8b 45 f4             	mov    -0xc(%ebp),%eax
 539:	8d 50 01             	lea    0x1(%eax),%edx
 53c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 53f:	0f b6 91 0c 0c 00 00 	movzbl 0xc0c(%ecx),%edx
 546:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 54a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 54d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 550:	ba 00 00 00 00       	mov    $0x0,%edx
 555:	f7 f1                	div    %ecx
 557:	89 45 ec             	mov    %eax,-0x14(%ebp)
 55a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 55e:	75 c7                	jne    527 <printint+0x37>
  if(neg)
 560:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 564:	74 2d                	je     593 <printint+0xa3>
    buf[i++] = '-';
 566:	8b 45 f4             	mov    -0xc(%ebp),%eax
 569:	8d 50 01             	lea    0x1(%eax),%edx
 56c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 56f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 574:	eb 1d                	jmp    593 <printint+0xa3>
    putc(fd, buf[i]);
 576:	8d 55 dc             	lea    -0x24(%ebp),%edx
 579:	8b 45 f4             	mov    -0xc(%ebp),%eax
 57c:	01 d0                	add    %edx,%eax
 57e:	0f b6 00             	movzbl (%eax),%eax
 581:	0f be c0             	movsbl %al,%eax
 584:	83 ec 08             	sub    $0x8,%esp
 587:	50                   	push   %eax
 588:	ff 75 08             	push   0x8(%ebp)
 58b:	e8 3d ff ff ff       	call   4cd <putc>
 590:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 593:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 597:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 59b:	79 d9                	jns    576 <printint+0x86>
}
 59d:	90                   	nop
 59e:	90                   	nop
 59f:	c9                   	leave  
 5a0:	c3                   	ret    

000005a1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5a1:	55                   	push   %ebp
 5a2:	89 e5                	mov    %esp,%ebp
 5a4:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5a7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5ae:	8d 45 0c             	lea    0xc(%ebp),%eax
 5b1:	83 c0 04             	add    $0x4,%eax
 5b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5b7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5be:	e9 59 01 00 00       	jmp    71c <printf+0x17b>
    c = fmt[i] & 0xff;
 5c3:	8b 55 0c             	mov    0xc(%ebp),%edx
 5c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5c9:	01 d0                	add    %edx,%eax
 5cb:	0f b6 00             	movzbl (%eax),%eax
 5ce:	0f be c0             	movsbl %al,%eax
 5d1:	25 ff 00 00 00       	and    $0xff,%eax
 5d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5dd:	75 2c                	jne    60b <printf+0x6a>
      if(c == '%'){
 5df:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5e3:	75 0c                	jne    5f1 <printf+0x50>
        state = '%';
 5e5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5ec:	e9 27 01 00 00       	jmp    718 <printf+0x177>
      } else {
        putc(fd, c);
 5f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5f4:	0f be c0             	movsbl %al,%eax
 5f7:	83 ec 08             	sub    $0x8,%esp
 5fa:	50                   	push   %eax
 5fb:	ff 75 08             	push   0x8(%ebp)
 5fe:	e8 ca fe ff ff       	call   4cd <putc>
 603:	83 c4 10             	add    $0x10,%esp
 606:	e9 0d 01 00 00       	jmp    718 <printf+0x177>
      }
    } else if(state == '%'){
 60b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 60f:	0f 85 03 01 00 00    	jne    718 <printf+0x177>
      if(c == 'd'){
 615:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 619:	75 1e                	jne    639 <printf+0x98>
        printint(fd, *ap, 10, 1);
 61b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 61e:	8b 00                	mov    (%eax),%eax
 620:	6a 01                	push   $0x1
 622:	6a 0a                	push   $0xa
 624:	50                   	push   %eax
 625:	ff 75 08             	push   0x8(%ebp)
 628:	e8 c3 fe ff ff       	call   4f0 <printint>
 62d:	83 c4 10             	add    $0x10,%esp
        ap++;
 630:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 634:	e9 d8 00 00 00       	jmp    711 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 639:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 63d:	74 06                	je     645 <printf+0xa4>
 63f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 643:	75 1e                	jne    663 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 645:	8b 45 e8             	mov    -0x18(%ebp),%eax
 648:	8b 00                	mov    (%eax),%eax
 64a:	6a 00                	push   $0x0
 64c:	6a 10                	push   $0x10
 64e:	50                   	push   %eax
 64f:	ff 75 08             	push   0x8(%ebp)
 652:	e8 99 fe ff ff       	call   4f0 <printint>
 657:	83 c4 10             	add    $0x10,%esp
        ap++;
 65a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 65e:	e9 ae 00 00 00       	jmp    711 <printf+0x170>
      } else if(c == 's'){
 663:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 667:	75 43                	jne    6ac <printf+0x10b>
        s = (char*)*ap;
 669:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 671:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 675:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 679:	75 25                	jne    6a0 <printf+0xff>
          s = "(null)";
 67b:	c7 45 f4 9d 09 00 00 	movl   $0x99d,-0xc(%ebp)
        while(*s != 0){
 682:	eb 1c                	jmp    6a0 <printf+0xff>
          putc(fd, *s);
 684:	8b 45 f4             	mov    -0xc(%ebp),%eax
 687:	0f b6 00             	movzbl (%eax),%eax
 68a:	0f be c0             	movsbl %al,%eax
 68d:	83 ec 08             	sub    $0x8,%esp
 690:	50                   	push   %eax
 691:	ff 75 08             	push   0x8(%ebp)
 694:	e8 34 fe ff ff       	call   4cd <putc>
 699:	83 c4 10             	add    $0x10,%esp
          s++;
 69c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 6a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a3:	0f b6 00             	movzbl (%eax),%eax
 6a6:	84 c0                	test   %al,%al
 6a8:	75 da                	jne    684 <printf+0xe3>
 6aa:	eb 65                	jmp    711 <printf+0x170>
        }
      } else if(c == 'c'){
 6ac:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6b0:	75 1d                	jne    6cf <printf+0x12e>
        putc(fd, *ap);
 6b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b5:	8b 00                	mov    (%eax),%eax
 6b7:	0f be c0             	movsbl %al,%eax
 6ba:	83 ec 08             	sub    $0x8,%esp
 6bd:	50                   	push   %eax
 6be:	ff 75 08             	push   0x8(%ebp)
 6c1:	e8 07 fe ff ff       	call   4cd <putc>
 6c6:	83 c4 10             	add    $0x10,%esp
        ap++;
 6c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6cd:	eb 42                	jmp    711 <printf+0x170>
      } else if(c == '%'){
 6cf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d3:	75 17                	jne    6ec <printf+0x14b>
        putc(fd, c);
 6d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d8:	0f be c0             	movsbl %al,%eax
 6db:	83 ec 08             	sub    $0x8,%esp
 6de:	50                   	push   %eax
 6df:	ff 75 08             	push   0x8(%ebp)
 6e2:	e8 e6 fd ff ff       	call   4cd <putc>
 6e7:	83 c4 10             	add    $0x10,%esp
 6ea:	eb 25                	jmp    711 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ec:	83 ec 08             	sub    $0x8,%esp
 6ef:	6a 25                	push   $0x25
 6f1:	ff 75 08             	push   0x8(%ebp)
 6f4:	e8 d4 fd ff ff       	call   4cd <putc>
 6f9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ff:	0f be c0             	movsbl %al,%eax
 702:	83 ec 08             	sub    $0x8,%esp
 705:	50                   	push   %eax
 706:	ff 75 08             	push   0x8(%ebp)
 709:	e8 bf fd ff ff       	call   4cd <putc>
 70e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 711:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 718:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 71c:	8b 55 0c             	mov    0xc(%ebp),%edx
 71f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 722:	01 d0                	add    %edx,%eax
 724:	0f b6 00             	movzbl (%eax),%eax
 727:	84 c0                	test   %al,%al
 729:	0f 85 94 fe ff ff    	jne    5c3 <printf+0x22>
    }
  }
}
 72f:	90                   	nop
 730:	90                   	nop
 731:	c9                   	leave  
 732:	c3                   	ret    

00000733 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 733:	55                   	push   %ebp
 734:	89 e5                	mov    %esp,%ebp
 736:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 739:	8b 45 08             	mov    0x8(%ebp),%eax
 73c:	83 e8 08             	sub    $0x8,%eax
 73f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 742:	a1 28 0c 00 00       	mov    0xc28,%eax
 747:	89 45 fc             	mov    %eax,-0x4(%ebp)
 74a:	eb 24                	jmp    770 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	8b 00                	mov    (%eax),%eax
 751:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 754:	72 12                	jb     768 <free+0x35>
 756:	8b 45 f8             	mov    -0x8(%ebp),%eax
 759:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 75c:	77 24                	ja     782 <free+0x4f>
 75e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 761:	8b 00                	mov    (%eax),%eax
 763:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 766:	72 1a                	jb     782 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 768:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76b:	8b 00                	mov    (%eax),%eax
 76d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 770:	8b 45 f8             	mov    -0x8(%ebp),%eax
 773:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 776:	76 d4                	jbe    74c <free+0x19>
 778:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77b:	8b 00                	mov    (%eax),%eax
 77d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 780:	73 ca                	jae    74c <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 782:	8b 45 f8             	mov    -0x8(%ebp),%eax
 785:	8b 40 04             	mov    0x4(%eax),%eax
 788:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 78f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 792:	01 c2                	add    %eax,%edx
 794:	8b 45 fc             	mov    -0x4(%ebp),%eax
 797:	8b 00                	mov    (%eax),%eax
 799:	39 c2                	cmp    %eax,%edx
 79b:	75 24                	jne    7c1 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 79d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a0:	8b 50 04             	mov    0x4(%eax),%edx
 7a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a6:	8b 00                	mov    (%eax),%eax
 7a8:	8b 40 04             	mov    0x4(%eax),%eax
 7ab:	01 c2                	add    %eax,%edx
 7ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b0:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b6:	8b 00                	mov    (%eax),%eax
 7b8:	8b 10                	mov    (%eax),%edx
 7ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bd:	89 10                	mov    %edx,(%eax)
 7bf:	eb 0a                	jmp    7cb <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c4:	8b 10                	mov    (%eax),%edx
 7c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c9:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ce:	8b 40 04             	mov    0x4(%eax),%eax
 7d1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	01 d0                	add    %edx,%eax
 7dd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7e0:	75 20                	jne    802 <free+0xcf>
    p->s.size += bp->s.size;
 7e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e5:	8b 50 04             	mov    0x4(%eax),%edx
 7e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7eb:	8b 40 04             	mov    0x4(%eax),%eax
 7ee:	01 c2                	add    %eax,%edx
 7f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f9:	8b 10                	mov    (%eax),%edx
 7fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fe:	89 10                	mov    %edx,(%eax)
 800:	eb 08                	jmp    80a <free+0xd7>
  } else
    p->s.ptr = bp;
 802:	8b 45 fc             	mov    -0x4(%ebp),%eax
 805:	8b 55 f8             	mov    -0x8(%ebp),%edx
 808:	89 10                	mov    %edx,(%eax)
  freep = p;
 80a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80d:	a3 28 0c 00 00       	mov    %eax,0xc28
}
 812:	90                   	nop
 813:	c9                   	leave  
 814:	c3                   	ret    

00000815 <morecore>:

static Header*
morecore(uint nu)
{
 815:	55                   	push   %ebp
 816:	89 e5                	mov    %esp,%ebp
 818:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 81b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 822:	77 07                	ja     82b <morecore+0x16>
    nu = 4096;
 824:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 82b:	8b 45 08             	mov    0x8(%ebp),%eax
 82e:	c1 e0 03             	shl    $0x3,%eax
 831:	83 ec 0c             	sub    $0xc,%esp
 834:	50                   	push   %eax
 835:	e8 4b fc ff ff       	call   485 <sbrk>
 83a:	83 c4 10             	add    $0x10,%esp
 83d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 840:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 844:	75 07                	jne    84d <morecore+0x38>
    return 0;
 846:	b8 00 00 00 00       	mov    $0x0,%eax
 84b:	eb 26                	jmp    873 <morecore+0x5e>
  hp = (Header*)p;
 84d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 850:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 853:	8b 45 f0             	mov    -0x10(%ebp),%eax
 856:	8b 55 08             	mov    0x8(%ebp),%edx
 859:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 85c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85f:	83 c0 08             	add    $0x8,%eax
 862:	83 ec 0c             	sub    $0xc,%esp
 865:	50                   	push   %eax
 866:	e8 c8 fe ff ff       	call   733 <free>
 86b:	83 c4 10             	add    $0x10,%esp
  return freep;
 86e:	a1 28 0c 00 00       	mov    0xc28,%eax
}
 873:	c9                   	leave  
 874:	c3                   	ret    

00000875 <malloc>:

void*
malloc(uint nbytes)
{
 875:	55                   	push   %ebp
 876:	89 e5                	mov    %esp,%ebp
 878:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 87b:	8b 45 08             	mov    0x8(%ebp),%eax
 87e:	83 c0 07             	add    $0x7,%eax
 881:	c1 e8 03             	shr    $0x3,%eax
 884:	83 c0 01             	add    $0x1,%eax
 887:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 88a:	a1 28 0c 00 00       	mov    0xc28,%eax
 88f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 892:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 896:	75 23                	jne    8bb <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 898:	c7 45 f0 20 0c 00 00 	movl   $0xc20,-0x10(%ebp)
 89f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a2:	a3 28 0c 00 00       	mov    %eax,0xc28
 8a7:	a1 28 0c 00 00       	mov    0xc28,%eax
 8ac:	a3 20 0c 00 00       	mov    %eax,0xc20
    base.s.size = 0;
 8b1:	c7 05 24 0c 00 00 00 	movl   $0x0,0xc24
 8b8:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8be:	8b 00                	mov    (%eax),%eax
 8c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c6:	8b 40 04             	mov    0x4(%eax),%eax
 8c9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8cc:	77 4d                	ja     91b <malloc+0xa6>
      if(p->s.size == nunits)
 8ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d1:	8b 40 04             	mov    0x4(%eax),%eax
 8d4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8d7:	75 0c                	jne    8e5 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dc:	8b 10                	mov    (%eax),%edx
 8de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e1:	89 10                	mov    %edx,(%eax)
 8e3:	eb 26                	jmp    90b <malloc+0x96>
      else {
        p->s.size -= nunits;
 8e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e8:	8b 40 04             	mov    0x4(%eax),%eax
 8eb:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8ee:	89 c2                	mov    %eax,%edx
 8f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f9:	8b 40 04             	mov    0x4(%eax),%eax
 8fc:	c1 e0 03             	shl    $0x3,%eax
 8ff:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 902:	8b 45 f4             	mov    -0xc(%ebp),%eax
 905:	8b 55 ec             	mov    -0x14(%ebp),%edx
 908:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 90b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90e:	a3 28 0c 00 00       	mov    %eax,0xc28
      return (void*)(p + 1);
 913:	8b 45 f4             	mov    -0xc(%ebp),%eax
 916:	83 c0 08             	add    $0x8,%eax
 919:	eb 3b                	jmp    956 <malloc+0xe1>
    }
    if(p == freep)
 91b:	a1 28 0c 00 00       	mov    0xc28,%eax
 920:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 923:	75 1e                	jne    943 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 925:	83 ec 0c             	sub    $0xc,%esp
 928:	ff 75 ec             	push   -0x14(%ebp)
 92b:	e8 e5 fe ff ff       	call   815 <morecore>
 930:	83 c4 10             	add    $0x10,%esp
 933:	89 45 f4             	mov    %eax,-0xc(%ebp)
 936:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 93a:	75 07                	jne    943 <malloc+0xce>
        return 0;
 93c:	b8 00 00 00 00       	mov    $0x0,%eax
 941:	eb 13                	jmp    956 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 943:	8b 45 f4             	mov    -0xc(%ebp),%eax
 946:	89 45 f0             	mov    %eax,-0x10(%ebp)
 949:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94c:	8b 00                	mov    (%eax),%eax
 94e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 951:	e9 6d ff ff ff       	jmp    8c3 <malloc+0x4e>
  }
}
 956:	c9                   	leave  
 957:	c3                   	ret    
