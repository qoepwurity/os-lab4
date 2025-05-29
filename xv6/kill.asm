
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
  14:	83 3b 01             	cmpl   $0x1,(%ebx)
  17:	7f 17                	jg     30 <main+0x30>
    printf(2, "usage: kill pid...\n");
  19:	83 ec 08             	sub    $0x8,%esp
  1c:	68 24 08 00 00       	push   $0x824
  21:	6a 02                	push   $0x2
  23:	e8 45 04 00 00       	call   46d <printf>
  28:	83 c4 10             	add    $0x10,%esp
    exit();
  2b:	e8 99 02 00 00       	call   2c9 <exit>
  }
  for(i=1; i<argc; i++)
  30:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  37:	eb 2d                	jmp    66 <main+0x66>
    kill(atoi(argv[i]));
  39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  43:	8b 43 04             	mov    0x4(%ebx),%eax
  46:	01 d0                	add    %edx,%eax
  48:	8b 00                	mov    (%eax),%eax
  4a:	83 ec 0c             	sub    $0xc,%esp
  4d:	50                   	push   %eax
  4e:	e8 e4 01 00 00       	call   237 <atoi>
  53:	83 c4 10             	add    $0x10,%esp
  56:	83 ec 0c             	sub    $0xc,%esp
  59:	50                   	push   %eax
  5a:	e8 9a 02 00 00       	call   2f9 <kill>
  5f:	83 c4 10             	add    $0x10,%esp
  for(i=1; i<argc; i++)
  62:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  69:	3b 03                	cmp    (%ebx),%eax
  6b:	7c cc                	jl     39 <main+0x39>
  exit();
  6d:	e8 57 02 00 00       	call   2c9 <exit>

00000072 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  72:	55                   	push   %ebp
  73:	89 e5                	mov    %esp,%ebp
  75:	57                   	push   %edi
  76:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7a:	8b 55 10             	mov    0x10(%ebp),%edx
  7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  80:	89 cb                	mov    %ecx,%ebx
  82:	89 df                	mov    %ebx,%edi
  84:	89 d1                	mov    %edx,%ecx
  86:	fc                   	cld    
  87:	f3 aa                	rep stos %al,%es:(%edi)
  89:	89 ca                	mov    %ecx,%edx
  8b:	89 fb                	mov    %edi,%ebx
  8d:	89 5d 08             	mov    %ebx,0x8(%ebp)
  90:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  93:	90                   	nop
  94:	5b                   	pop    %ebx
  95:	5f                   	pop    %edi
  96:	5d                   	pop    %ebp
  97:	c3                   	ret    

00000098 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  98:	55                   	push   %ebp
  99:	89 e5                	mov    %esp,%ebp
  9b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  9e:	8b 45 08             	mov    0x8(%ebp),%eax
  a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  a4:	90                   	nop
  a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  a8:	8d 42 01             	lea    0x1(%edx),%eax
  ab:	89 45 0c             	mov    %eax,0xc(%ebp)
  ae:	8b 45 08             	mov    0x8(%ebp),%eax
  b1:	8d 48 01             	lea    0x1(%eax),%ecx
  b4:	89 4d 08             	mov    %ecx,0x8(%ebp)
  b7:	0f b6 12             	movzbl (%edx),%edx
  ba:	88 10                	mov    %dl,(%eax)
  bc:	0f b6 00             	movzbl (%eax),%eax
  bf:	84 c0                	test   %al,%al
  c1:	75 e2                	jne    a5 <strcpy+0xd>
    ;
  return os;
  c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c6:	c9                   	leave  
  c7:	c3                   	ret    

000000c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c8:	55                   	push   %ebp
  c9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  cb:	eb 08                	jmp    d5 <strcmp+0xd>
    p++, q++;
  cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  d5:	8b 45 08             	mov    0x8(%ebp),%eax
  d8:	0f b6 00             	movzbl (%eax),%eax
  db:	84 c0                	test   %al,%al
  dd:	74 10                	je     ef <strcmp+0x27>
  df:	8b 45 08             	mov    0x8(%ebp),%eax
  e2:	0f b6 10             	movzbl (%eax),%edx
  e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  e8:	0f b6 00             	movzbl (%eax),%eax
  eb:	38 c2                	cmp    %al,%dl
  ed:	74 de                	je     cd <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  ef:	8b 45 08             	mov    0x8(%ebp),%eax
  f2:	0f b6 00             	movzbl (%eax),%eax
  f5:	0f b6 d0             	movzbl %al,%edx
  f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	0f b6 c8             	movzbl %al,%ecx
 101:	89 d0                	mov    %edx,%eax
 103:	29 c8                	sub    %ecx,%eax
}
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    

00000107 <strlen>:

uint
strlen(char *s)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 10d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 114:	eb 04                	jmp    11a <strlen+0x13>
 116:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 11a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	01 d0                	add    %edx,%eax
 122:	0f b6 00             	movzbl (%eax),%eax
 125:	84 c0                	test   %al,%al
 127:	75 ed                	jne    116 <strlen+0xf>
    ;
  return n;
 129:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12c:	c9                   	leave  
 12d:	c3                   	ret    

0000012e <memset>:

void*
memset(void *dst, int c, uint n)
{
 12e:	55                   	push   %ebp
 12f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 131:	8b 45 10             	mov    0x10(%ebp),%eax
 134:	50                   	push   %eax
 135:	ff 75 0c             	push   0xc(%ebp)
 138:	ff 75 08             	push   0x8(%ebp)
 13b:	e8 32 ff ff ff       	call   72 <stosb>
 140:	83 c4 0c             	add    $0xc,%esp
  return dst;
 143:	8b 45 08             	mov    0x8(%ebp),%eax
}
 146:	c9                   	leave  
 147:	c3                   	ret    

00000148 <strchr>:

char*
strchr(const char *s, char c)
{
 148:	55                   	push   %ebp
 149:	89 e5                	mov    %esp,%ebp
 14b:	83 ec 04             	sub    $0x4,%esp
 14e:	8b 45 0c             	mov    0xc(%ebp),%eax
 151:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 154:	eb 14                	jmp    16a <strchr+0x22>
    if(*s == c)
 156:	8b 45 08             	mov    0x8(%ebp),%eax
 159:	0f b6 00             	movzbl (%eax),%eax
 15c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 15f:	75 05                	jne    166 <strchr+0x1e>
      return (char*)s;
 161:	8b 45 08             	mov    0x8(%ebp),%eax
 164:	eb 13                	jmp    179 <strchr+0x31>
  for(; *s; s++)
 166:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
 16d:	0f b6 00             	movzbl (%eax),%eax
 170:	84 c0                	test   %al,%al
 172:	75 e2                	jne    156 <strchr+0xe>
  return 0;
 174:	b8 00 00 00 00       	mov    $0x0,%eax
}
 179:	c9                   	leave  
 17a:	c3                   	ret    

0000017b <gets>:

char*
gets(char *buf, int max)
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
 17e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 181:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 188:	eb 42                	jmp    1cc <gets+0x51>
    cc = read(0, &c, 1);
 18a:	83 ec 04             	sub    $0x4,%esp
 18d:	6a 01                	push   $0x1
 18f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 192:	50                   	push   %eax
 193:	6a 00                	push   $0x0
 195:	e8 47 01 00 00       	call   2e1 <read>
 19a:	83 c4 10             	add    $0x10,%esp
 19d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a4:	7e 33                	jle    1d9 <gets+0x5e>
      break;
    buf[i++] = c;
 1a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a9:	8d 50 01             	lea    0x1(%eax),%edx
 1ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1af:	89 c2                	mov    %eax,%edx
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	01 c2                	add    %eax,%edx
 1b6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ba:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1bc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c0:	3c 0a                	cmp    $0xa,%al
 1c2:	74 16                	je     1da <gets+0x5f>
 1c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c8:	3c 0d                	cmp    $0xd,%al
 1ca:	74 0e                	je     1da <gets+0x5f>
  for(i=0; i+1 < max; ){
 1cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cf:	83 c0 01             	add    $0x1,%eax
 1d2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1d5:	7f b3                	jg     18a <gets+0xf>
 1d7:	eb 01                	jmp    1da <gets+0x5f>
      break;
 1d9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1da:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1dd:	8b 45 08             	mov    0x8(%ebp),%eax
 1e0:	01 d0                	add    %edx,%eax
 1e2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e8:	c9                   	leave  
 1e9:	c3                   	ret    

000001ea <stat>:

int
stat(char *n, struct stat *st)
{
 1ea:	55                   	push   %ebp
 1eb:	89 e5                	mov    %esp,%ebp
 1ed:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f0:	83 ec 08             	sub    $0x8,%esp
 1f3:	6a 00                	push   $0x0
 1f5:	ff 75 08             	push   0x8(%ebp)
 1f8:	e8 0c 01 00 00       	call   309 <open>
 1fd:	83 c4 10             	add    $0x10,%esp
 200:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 203:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 207:	79 07                	jns    210 <stat+0x26>
    return -1;
 209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 20e:	eb 25                	jmp    235 <stat+0x4b>
  r = fstat(fd, st);
 210:	83 ec 08             	sub    $0x8,%esp
 213:	ff 75 0c             	push   0xc(%ebp)
 216:	ff 75 f4             	push   -0xc(%ebp)
 219:	e8 03 01 00 00       	call   321 <fstat>
 21e:	83 c4 10             	add    $0x10,%esp
 221:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 224:	83 ec 0c             	sub    $0xc,%esp
 227:	ff 75 f4             	push   -0xc(%ebp)
 22a:	e8 c2 00 00 00       	call   2f1 <close>
 22f:	83 c4 10             	add    $0x10,%esp
  return r;
 232:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 235:	c9                   	leave  
 236:	c3                   	ret    

00000237 <atoi>:

int
atoi(const char *s)
{
 237:	55                   	push   %ebp
 238:	89 e5                	mov    %esp,%ebp
 23a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 23d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 244:	eb 25                	jmp    26b <atoi+0x34>
    n = n*10 + *s++ - '0';
 246:	8b 55 fc             	mov    -0x4(%ebp),%edx
 249:	89 d0                	mov    %edx,%eax
 24b:	c1 e0 02             	shl    $0x2,%eax
 24e:	01 d0                	add    %edx,%eax
 250:	01 c0                	add    %eax,%eax
 252:	89 c1                	mov    %eax,%ecx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	8d 50 01             	lea    0x1(%eax),%edx
 25a:	89 55 08             	mov    %edx,0x8(%ebp)
 25d:	0f b6 00             	movzbl (%eax),%eax
 260:	0f be c0             	movsbl %al,%eax
 263:	01 c8                	add    %ecx,%eax
 265:	83 e8 30             	sub    $0x30,%eax
 268:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	0f b6 00             	movzbl (%eax),%eax
 271:	3c 2f                	cmp    $0x2f,%al
 273:	7e 0a                	jle    27f <atoi+0x48>
 275:	8b 45 08             	mov    0x8(%ebp),%eax
 278:	0f b6 00             	movzbl (%eax),%eax
 27b:	3c 39                	cmp    $0x39,%al
 27d:	7e c7                	jle    246 <atoi+0xf>
  return n;
 27f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 282:	c9                   	leave  
 283:	c3                   	ret    

00000284 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 284:	55                   	push   %ebp
 285:	89 e5                	mov    %esp,%ebp
 287:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 290:	8b 45 0c             	mov    0xc(%ebp),%eax
 293:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 296:	eb 17                	jmp    2af <memmove+0x2b>
    *dst++ = *src++;
 298:	8b 55 f8             	mov    -0x8(%ebp),%edx
 29b:	8d 42 01             	lea    0x1(%edx),%eax
 29e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a4:	8d 48 01             	lea    0x1(%eax),%ecx
 2a7:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2aa:	0f b6 12             	movzbl (%edx),%edx
 2ad:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2af:	8b 45 10             	mov    0x10(%ebp),%eax
 2b2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2b5:	89 55 10             	mov    %edx,0x10(%ebp)
 2b8:	85 c0                	test   %eax,%eax
 2ba:	7f dc                	jg     298 <memmove+0x14>
  return vdst;
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bf:	c9                   	leave  
 2c0:	c3                   	ret    

000002c1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c1:	b8 01 00 00 00       	mov    $0x1,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret    

000002c9 <exit>:
SYSCALL(exit)
 2c9:	b8 02 00 00 00       	mov    $0x2,%eax
 2ce:	cd 40                	int    $0x40
 2d0:	c3                   	ret    

000002d1 <wait>:
SYSCALL(wait)
 2d1:	b8 03 00 00 00       	mov    $0x3,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret    

000002d9 <pipe>:
SYSCALL(pipe)
 2d9:	b8 04 00 00 00       	mov    $0x4,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <read>:
SYSCALL(read)
 2e1:	b8 05 00 00 00       	mov    $0x5,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <write>:
SYSCALL(write)
 2e9:	b8 10 00 00 00       	mov    $0x10,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <close>:
SYSCALL(close)
 2f1:	b8 15 00 00 00       	mov    $0x15,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <kill>:
SYSCALL(kill)
 2f9:	b8 06 00 00 00       	mov    $0x6,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <exec>:
SYSCALL(exec)
 301:	b8 07 00 00 00       	mov    $0x7,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <open>:
SYSCALL(open)
 309:	b8 0f 00 00 00       	mov    $0xf,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <mknod>:
SYSCALL(mknod)
 311:	b8 11 00 00 00       	mov    $0x11,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <unlink>:
SYSCALL(unlink)
 319:	b8 12 00 00 00       	mov    $0x12,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <fstat>:
SYSCALL(fstat)
 321:	b8 08 00 00 00       	mov    $0x8,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <link>:
SYSCALL(link)
 329:	b8 13 00 00 00       	mov    $0x13,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <mkdir>:
SYSCALL(mkdir)
 331:	b8 14 00 00 00       	mov    $0x14,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <chdir>:
SYSCALL(chdir)
 339:	b8 09 00 00 00       	mov    $0x9,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <dup>:
SYSCALL(dup)
 341:	b8 0a 00 00 00       	mov    $0xa,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <getpid>:
SYSCALL(getpid)
 349:	b8 0b 00 00 00       	mov    $0xb,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <sbrk>:
SYSCALL(sbrk)
 351:	b8 0c 00 00 00       	mov    $0xc,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <sleep>:
SYSCALL(sleep)
 359:	b8 0d 00 00 00       	mov    $0xd,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <uptime>:
SYSCALL(uptime)
 361:	b8 0e 00 00 00       	mov    $0xe,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <uthread_init>:

SYSCALL(uthread_init)
 369:	b8 16 00 00 00       	mov    $0x16,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <check_thread>:
SYSCALL(check_thread)
 371:	b8 17 00 00 00       	mov    $0x17,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <getpinfo>:

SYSCALL(getpinfo)
 379:	b8 18 00 00 00       	mov    $0x18,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 381:	b8 19 00 00 00       	mov    $0x19,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <yield>:
SYSCALL(yield)
 389:	b8 1a 00 00 00       	mov    $0x1a,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <printpt>:

 391:	b8 1b 00 00 00       	mov    $0x1b,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret    

00000399 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 399:	55                   	push   %ebp
 39a:	89 e5                	mov    %esp,%ebp
 39c:	83 ec 18             	sub    $0x18,%esp
 39f:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a2:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3a5:	83 ec 04             	sub    $0x4,%esp
 3a8:	6a 01                	push   $0x1
 3aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3ad:	50                   	push   %eax
 3ae:	ff 75 08             	push   0x8(%ebp)
 3b1:	e8 33 ff ff ff       	call   2e9 <write>
 3b6:	83 c4 10             	add    $0x10,%esp
}
 3b9:	90                   	nop
 3ba:	c9                   	leave  
 3bb:	c3                   	ret    

000003bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3bc:	55                   	push   %ebp
 3bd:	89 e5                	mov    %esp,%ebp
 3bf:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3c9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3cd:	74 17                	je     3e6 <printint+0x2a>
 3cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3d3:	79 11                	jns    3e6 <printint+0x2a>
    neg = 1;
 3d5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	f7 d8                	neg    %eax
 3e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e4:	eb 06                	jmp    3ec <printint+0x30>
  } else {
    x = xx;
 3e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f9:	ba 00 00 00 00       	mov    $0x0,%edx
 3fe:	f7 f1                	div    %ecx
 400:	89 d1                	mov    %edx,%ecx
 402:	8b 45 f4             	mov    -0xc(%ebp),%eax
 405:	8d 50 01             	lea    0x1(%eax),%edx
 408:	89 55 f4             	mov    %edx,-0xc(%ebp)
 40b:	0f b6 91 88 0a 00 00 	movzbl 0xa88(%ecx),%edx
 412:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 416:	8b 4d 10             	mov    0x10(%ebp),%ecx
 419:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41c:	ba 00 00 00 00       	mov    $0x0,%edx
 421:	f7 f1                	div    %ecx
 423:	89 45 ec             	mov    %eax,-0x14(%ebp)
 426:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 42a:	75 c7                	jne    3f3 <printint+0x37>
  if(neg)
 42c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 430:	74 2d                	je     45f <printint+0xa3>
    buf[i++] = '-';
 432:	8b 45 f4             	mov    -0xc(%ebp),%eax
 435:	8d 50 01             	lea    0x1(%eax),%edx
 438:	89 55 f4             	mov    %edx,-0xc(%ebp)
 43b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 440:	eb 1d                	jmp    45f <printint+0xa3>
    putc(fd, buf[i]);
 442:	8d 55 dc             	lea    -0x24(%ebp),%edx
 445:	8b 45 f4             	mov    -0xc(%ebp),%eax
 448:	01 d0                	add    %edx,%eax
 44a:	0f b6 00             	movzbl (%eax),%eax
 44d:	0f be c0             	movsbl %al,%eax
 450:	83 ec 08             	sub    $0x8,%esp
 453:	50                   	push   %eax
 454:	ff 75 08             	push   0x8(%ebp)
 457:	e8 3d ff ff ff       	call   399 <putc>
 45c:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 45f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 463:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 467:	79 d9                	jns    442 <printint+0x86>
}
 469:	90                   	nop
 46a:	90                   	nop
 46b:	c9                   	leave  
 46c:	c3                   	ret    

0000046d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 46d:	55                   	push   %ebp
 46e:	89 e5                	mov    %esp,%ebp
 470:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 473:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 47a:	8d 45 0c             	lea    0xc(%ebp),%eax
 47d:	83 c0 04             	add    $0x4,%eax
 480:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 483:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 48a:	e9 59 01 00 00       	jmp    5e8 <printf+0x17b>
    c = fmt[i] & 0xff;
 48f:	8b 55 0c             	mov    0xc(%ebp),%edx
 492:	8b 45 f0             	mov    -0x10(%ebp),%eax
 495:	01 d0                	add    %edx,%eax
 497:	0f b6 00             	movzbl (%eax),%eax
 49a:	0f be c0             	movsbl %al,%eax
 49d:	25 ff 00 00 00       	and    $0xff,%eax
 4a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a9:	75 2c                	jne    4d7 <printf+0x6a>
      if(c == '%'){
 4ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4af:	75 0c                	jne    4bd <printf+0x50>
        state = '%';
 4b1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4b8:	e9 27 01 00 00       	jmp    5e4 <printf+0x177>
      } else {
        putc(fd, c);
 4bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c0:	0f be c0             	movsbl %al,%eax
 4c3:	83 ec 08             	sub    $0x8,%esp
 4c6:	50                   	push   %eax
 4c7:	ff 75 08             	push   0x8(%ebp)
 4ca:	e8 ca fe ff ff       	call   399 <putc>
 4cf:	83 c4 10             	add    $0x10,%esp
 4d2:	e9 0d 01 00 00       	jmp    5e4 <printf+0x177>
      }
    } else if(state == '%'){
 4d7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4db:	0f 85 03 01 00 00    	jne    5e4 <printf+0x177>
      if(c == 'd'){
 4e1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4e5:	75 1e                	jne    505 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ea:	8b 00                	mov    (%eax),%eax
 4ec:	6a 01                	push   $0x1
 4ee:	6a 0a                	push   $0xa
 4f0:	50                   	push   %eax
 4f1:	ff 75 08             	push   0x8(%ebp)
 4f4:	e8 c3 fe ff ff       	call   3bc <printint>
 4f9:	83 c4 10             	add    $0x10,%esp
        ap++;
 4fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 500:	e9 d8 00 00 00       	jmp    5dd <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 505:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 509:	74 06                	je     511 <printf+0xa4>
 50b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 50f:	75 1e                	jne    52f <printf+0xc2>
        printint(fd, *ap, 16, 0);
 511:	8b 45 e8             	mov    -0x18(%ebp),%eax
 514:	8b 00                	mov    (%eax),%eax
 516:	6a 00                	push   $0x0
 518:	6a 10                	push   $0x10
 51a:	50                   	push   %eax
 51b:	ff 75 08             	push   0x8(%ebp)
 51e:	e8 99 fe ff ff       	call   3bc <printint>
 523:	83 c4 10             	add    $0x10,%esp
        ap++;
 526:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52a:	e9 ae 00 00 00       	jmp    5dd <printf+0x170>
      } else if(c == 's'){
 52f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 533:	75 43                	jne    578 <printf+0x10b>
        s = (char*)*ap;
 535:	8b 45 e8             	mov    -0x18(%ebp),%eax
 538:	8b 00                	mov    (%eax),%eax
 53a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 53d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 541:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 545:	75 25                	jne    56c <printf+0xff>
          s = "(null)";
 547:	c7 45 f4 38 08 00 00 	movl   $0x838,-0xc(%ebp)
        while(*s != 0){
 54e:	eb 1c                	jmp    56c <printf+0xff>
          putc(fd, *s);
 550:	8b 45 f4             	mov    -0xc(%ebp),%eax
 553:	0f b6 00             	movzbl (%eax),%eax
 556:	0f be c0             	movsbl %al,%eax
 559:	83 ec 08             	sub    $0x8,%esp
 55c:	50                   	push   %eax
 55d:	ff 75 08             	push   0x8(%ebp)
 560:	e8 34 fe ff ff       	call   399 <putc>
 565:	83 c4 10             	add    $0x10,%esp
          s++;
 568:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56f:	0f b6 00             	movzbl (%eax),%eax
 572:	84 c0                	test   %al,%al
 574:	75 da                	jne    550 <printf+0xe3>
 576:	eb 65                	jmp    5dd <printf+0x170>
        }
      } else if(c == 'c'){
 578:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 57c:	75 1d                	jne    59b <printf+0x12e>
        putc(fd, *ap);
 57e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 581:	8b 00                	mov    (%eax),%eax
 583:	0f be c0             	movsbl %al,%eax
 586:	83 ec 08             	sub    $0x8,%esp
 589:	50                   	push   %eax
 58a:	ff 75 08             	push   0x8(%ebp)
 58d:	e8 07 fe ff ff       	call   399 <putc>
 592:	83 c4 10             	add    $0x10,%esp
        ap++;
 595:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 599:	eb 42                	jmp    5dd <printf+0x170>
      } else if(c == '%'){
 59b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 59f:	75 17                	jne    5b8 <printf+0x14b>
        putc(fd, c);
 5a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a4:	0f be c0             	movsbl %al,%eax
 5a7:	83 ec 08             	sub    $0x8,%esp
 5aa:	50                   	push   %eax
 5ab:	ff 75 08             	push   0x8(%ebp)
 5ae:	e8 e6 fd ff ff       	call   399 <putc>
 5b3:	83 c4 10             	add    $0x10,%esp
 5b6:	eb 25                	jmp    5dd <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b8:	83 ec 08             	sub    $0x8,%esp
 5bb:	6a 25                	push   $0x25
 5bd:	ff 75 08             	push   0x8(%ebp)
 5c0:	e8 d4 fd ff ff       	call   399 <putc>
 5c5:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5cb:	0f be c0             	movsbl %al,%eax
 5ce:	83 ec 08             	sub    $0x8,%esp
 5d1:	50                   	push   %eax
 5d2:	ff 75 08             	push   0x8(%ebp)
 5d5:	e8 bf fd ff ff       	call   399 <putc>
 5da:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5e4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5e8:	8b 55 0c             	mov    0xc(%ebp),%edx
 5eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ee:	01 d0                	add    %edx,%eax
 5f0:	0f b6 00             	movzbl (%eax),%eax
 5f3:	84 c0                	test   %al,%al
 5f5:	0f 85 94 fe ff ff    	jne    48f <printf+0x22>
    }
  }
}
 5fb:	90                   	nop
 5fc:	90                   	nop
 5fd:	c9                   	leave  
 5fe:	c3                   	ret    

000005ff <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5ff:	55                   	push   %ebp
 600:	89 e5                	mov    %esp,%ebp
 602:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 605:	8b 45 08             	mov    0x8(%ebp),%eax
 608:	83 e8 08             	sub    $0x8,%eax
 60b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60e:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 613:	89 45 fc             	mov    %eax,-0x4(%ebp)
 616:	eb 24                	jmp    63c <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 618:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61b:	8b 00                	mov    (%eax),%eax
 61d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 620:	72 12                	jb     634 <free+0x35>
 622:	8b 45 f8             	mov    -0x8(%ebp),%eax
 625:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 628:	77 24                	ja     64e <free+0x4f>
 62a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62d:	8b 00                	mov    (%eax),%eax
 62f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 632:	72 1a                	jb     64e <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 634:	8b 45 fc             	mov    -0x4(%ebp),%eax
 637:	8b 00                	mov    (%eax),%eax
 639:	89 45 fc             	mov    %eax,-0x4(%ebp)
 63c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 642:	76 d4                	jbe    618 <free+0x19>
 644:	8b 45 fc             	mov    -0x4(%ebp),%eax
 647:	8b 00                	mov    (%eax),%eax
 649:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 64c:	73 ca                	jae    618 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 64e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 651:	8b 40 04             	mov    0x4(%eax),%eax
 654:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 65b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65e:	01 c2                	add    %eax,%edx
 660:	8b 45 fc             	mov    -0x4(%ebp),%eax
 663:	8b 00                	mov    (%eax),%eax
 665:	39 c2                	cmp    %eax,%edx
 667:	75 24                	jne    68d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 669:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66c:	8b 50 04             	mov    0x4(%eax),%edx
 66f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 672:	8b 00                	mov    (%eax),%eax
 674:	8b 40 04             	mov    0x4(%eax),%eax
 677:	01 c2                	add    %eax,%edx
 679:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 67f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 682:	8b 00                	mov    (%eax),%eax
 684:	8b 10                	mov    (%eax),%edx
 686:	8b 45 f8             	mov    -0x8(%ebp),%eax
 689:	89 10                	mov    %edx,(%eax)
 68b:	eb 0a                	jmp    697 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 68d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 690:	8b 10                	mov    (%eax),%edx
 692:	8b 45 f8             	mov    -0x8(%ebp),%eax
 695:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	8b 40 04             	mov    0x4(%eax),%eax
 69d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a7:	01 d0                	add    %edx,%eax
 6a9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6ac:	75 20                	jne    6ce <free+0xcf>
    p->s.size += bp->s.size;
 6ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b1:	8b 50 04             	mov    0x4(%eax),%edx
 6b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b7:	8b 40 04             	mov    0x4(%eax),%eax
 6ba:	01 c2                	add    %eax,%edx
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c5:	8b 10                	mov    (%eax),%edx
 6c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ca:	89 10                	mov    %edx,(%eax)
 6cc:	eb 08                	jmp    6d6 <free+0xd7>
  } else
    p->s.ptr = bp;
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6d4:	89 10                	mov    %edx,(%eax)
  freep = p;
 6d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d9:	a3 a4 0a 00 00       	mov    %eax,0xaa4
}
 6de:	90                   	nop
 6df:	c9                   	leave  
 6e0:	c3                   	ret    

000006e1 <morecore>:

static Header*
morecore(uint nu)
{
 6e1:	55                   	push   %ebp
 6e2:	89 e5                	mov    %esp,%ebp
 6e4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6e7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6ee:	77 07                	ja     6f7 <morecore+0x16>
    nu = 4096;
 6f0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6f7:	8b 45 08             	mov    0x8(%ebp),%eax
 6fa:	c1 e0 03             	shl    $0x3,%eax
 6fd:	83 ec 0c             	sub    $0xc,%esp
 700:	50                   	push   %eax
 701:	e8 4b fc ff ff       	call   351 <sbrk>
 706:	83 c4 10             	add    $0x10,%esp
 709:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 70c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 710:	75 07                	jne    719 <morecore+0x38>
    return 0;
 712:	b8 00 00 00 00       	mov    $0x0,%eax
 717:	eb 26                	jmp    73f <morecore+0x5e>
  hp = (Header*)p;
 719:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 71f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 722:	8b 55 08             	mov    0x8(%ebp),%edx
 725:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 728:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72b:	83 c0 08             	add    $0x8,%eax
 72e:	83 ec 0c             	sub    $0xc,%esp
 731:	50                   	push   %eax
 732:	e8 c8 fe ff ff       	call   5ff <free>
 737:	83 c4 10             	add    $0x10,%esp
  return freep;
 73a:	a1 a4 0a 00 00       	mov    0xaa4,%eax
}
 73f:	c9                   	leave  
 740:	c3                   	ret    

00000741 <malloc>:

void*
malloc(uint nbytes)
{
 741:	55                   	push   %ebp
 742:	89 e5                	mov    %esp,%ebp
 744:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 747:	8b 45 08             	mov    0x8(%ebp),%eax
 74a:	83 c0 07             	add    $0x7,%eax
 74d:	c1 e8 03             	shr    $0x3,%eax
 750:	83 c0 01             	add    $0x1,%eax
 753:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 756:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 75b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 75e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 762:	75 23                	jne    787 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 764:	c7 45 f0 9c 0a 00 00 	movl   $0xa9c,-0x10(%ebp)
 76b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76e:	a3 a4 0a 00 00       	mov    %eax,0xaa4
 773:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 778:	a3 9c 0a 00 00       	mov    %eax,0xa9c
    base.s.size = 0;
 77d:	c7 05 a0 0a 00 00 00 	movl   $0x0,0xaa0
 784:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 787:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78a:	8b 00                	mov    (%eax),%eax
 78c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 792:	8b 40 04             	mov    0x4(%eax),%eax
 795:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 798:	77 4d                	ja     7e7 <malloc+0xa6>
      if(p->s.size == nunits)
 79a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79d:	8b 40 04             	mov    0x4(%eax),%eax
 7a0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7a3:	75 0c                	jne    7b1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a8:	8b 10                	mov    (%eax),%edx
 7aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ad:	89 10                	mov    %edx,(%eax)
 7af:	eb 26                	jmp    7d7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	8b 40 04             	mov    0x4(%eax),%eax
 7b7:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7ba:	89 c2                	mov    %eax,%edx
 7bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bf:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c5:	8b 40 04             	mov    0x4(%eax),%eax
 7c8:	c1 e0 03             	shl    $0x3,%eax
 7cb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7d4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7da:	a3 a4 0a 00 00       	mov    %eax,0xaa4
      return (void*)(p + 1);
 7df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e2:	83 c0 08             	add    $0x8,%eax
 7e5:	eb 3b                	jmp    822 <malloc+0xe1>
    }
    if(p == freep)
 7e7:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 7ec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7ef:	75 1e                	jne    80f <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7f1:	83 ec 0c             	sub    $0xc,%esp
 7f4:	ff 75 ec             	push   -0x14(%ebp)
 7f7:	e8 e5 fe ff ff       	call   6e1 <morecore>
 7fc:	83 c4 10             	add    $0x10,%esp
 7ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
 802:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 806:	75 07                	jne    80f <malloc+0xce>
        return 0;
 808:	b8 00 00 00 00       	mov    $0x0,%eax
 80d:	eb 13                	jmp    822 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 812:	89 45 f0             	mov    %eax,-0x10(%ebp)
 815:	8b 45 f4             	mov    -0xc(%ebp),%eax
 818:	8b 00                	mov    (%eax),%eax
 81a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 81d:	e9 6d ff ff ff       	jmp    78f <malloc+0x4e>
  }
}
 822:	c9                   	leave  
 823:	c3                   	ret    
