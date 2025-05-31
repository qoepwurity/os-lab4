
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
  if(fork() > 0)
  11:	e8 65 02 00 00       	call   27b <fork>
  16:	85 c0                	test   %eax,%eax
  18:	7e 0d                	jle    27 <main+0x27>
    sleep(5);  // Let child exit before parent.
  1a:	83 ec 0c             	sub    $0xc,%esp
  1d:	6a 05                	push   $0x5
  1f:	e8 ef 02 00 00       	call   313 <sleep>
  24:	83 c4 10             	add    $0x10,%esp
  exit();
  27:	e8 57 02 00 00       	call   283 <exit>

0000002c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  2c:	55                   	push   %ebp
  2d:	89 e5                	mov    %esp,%ebp
  2f:	57                   	push   %edi
  30:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  34:	8b 55 10             	mov    0x10(%ebp),%edx
  37:	8b 45 0c             	mov    0xc(%ebp),%eax
  3a:	89 cb                	mov    %ecx,%ebx
  3c:	89 df                	mov    %ebx,%edi
  3e:	89 d1                	mov    %edx,%ecx
  40:	fc                   	cld    
  41:	f3 aa                	rep stos %al,%es:(%edi)
  43:	89 ca                	mov    %ecx,%edx
  45:	89 fb                	mov    %edi,%ebx
  47:	89 5d 08             	mov    %ebx,0x8(%ebp)
  4a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  4d:	90                   	nop
  4e:	5b                   	pop    %ebx
  4f:	5f                   	pop    %edi
  50:	5d                   	pop    %ebp
  51:	c3                   	ret    

00000052 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  52:	55                   	push   %ebp
  53:	89 e5                	mov    %esp,%ebp
  55:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  58:	8b 45 08             	mov    0x8(%ebp),%eax
  5b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  5e:	90                   	nop
  5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  62:	8d 42 01             	lea    0x1(%edx),%eax
  65:	89 45 0c             	mov    %eax,0xc(%ebp)
  68:	8b 45 08             	mov    0x8(%ebp),%eax
  6b:	8d 48 01             	lea    0x1(%eax),%ecx
  6e:	89 4d 08             	mov    %ecx,0x8(%ebp)
  71:	0f b6 12             	movzbl (%edx),%edx
  74:	88 10                	mov    %dl,(%eax)
  76:	0f b6 00             	movzbl (%eax),%eax
  79:	84 c0                	test   %al,%al
  7b:	75 e2                	jne    5f <strcpy+0xd>
    ;
  return os;
  7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80:	c9                   	leave  
  81:	c3                   	ret    

00000082 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  82:	55                   	push   %ebp
  83:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  85:	eb 08                	jmp    8f <strcmp+0xd>
    p++, q++;
  87:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  8f:	8b 45 08             	mov    0x8(%ebp),%eax
  92:	0f b6 00             	movzbl (%eax),%eax
  95:	84 c0                	test   %al,%al
  97:	74 10                	je     a9 <strcmp+0x27>
  99:	8b 45 08             	mov    0x8(%ebp),%eax
  9c:	0f b6 10             	movzbl (%eax),%edx
  9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  a2:	0f b6 00             	movzbl (%eax),%eax
  a5:	38 c2                	cmp    %al,%dl
  a7:	74 de                	je     87 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  a9:	8b 45 08             	mov    0x8(%ebp),%eax
  ac:	0f b6 00             	movzbl (%eax),%eax
  af:	0f b6 d0             	movzbl %al,%edx
  b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  b5:	0f b6 00             	movzbl (%eax),%eax
  b8:	0f b6 c8             	movzbl %al,%ecx
  bb:	89 d0                	mov    %edx,%eax
  bd:	29 c8                	sub    %ecx,%eax
}
  bf:	5d                   	pop    %ebp
  c0:	c3                   	ret    

000000c1 <strlen>:

uint
strlen(char *s)
{
  c1:	55                   	push   %ebp
  c2:	89 e5                	mov    %esp,%ebp
  c4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  ce:	eb 04                	jmp    d4 <strlen+0x13>
  d0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  d7:	8b 45 08             	mov    0x8(%ebp),%eax
  da:	01 d0                	add    %edx,%eax
  dc:	0f b6 00             	movzbl (%eax),%eax
  df:	84 c0                	test   %al,%al
  e1:	75 ed                	jne    d0 <strlen+0xf>
    ;
  return n;
  e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e6:	c9                   	leave  
  e7:	c3                   	ret    

000000e8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e8:	55                   	push   %ebp
  e9:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
  eb:	8b 45 10             	mov    0x10(%ebp),%eax
  ee:	50                   	push   %eax
  ef:	ff 75 0c             	push   0xc(%ebp)
  f2:	ff 75 08             	push   0x8(%ebp)
  f5:	e8 32 ff ff ff       	call   2c <stosb>
  fa:	83 c4 0c             	add    $0xc,%esp
  return dst;
  fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
 100:	c9                   	leave  
 101:	c3                   	ret    

00000102 <strchr>:

char*
strchr(const char *s, char c)
{
 102:	55                   	push   %ebp
 103:	89 e5                	mov    %esp,%ebp
 105:	83 ec 04             	sub    $0x4,%esp
 108:	8b 45 0c             	mov    0xc(%ebp),%eax
 10b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 10e:	eb 14                	jmp    124 <strchr+0x22>
    if(*s == c)
 110:	8b 45 08             	mov    0x8(%ebp),%eax
 113:	0f b6 00             	movzbl (%eax),%eax
 116:	38 45 fc             	cmp    %al,-0x4(%ebp)
 119:	75 05                	jne    120 <strchr+0x1e>
      return (char*)s;
 11b:	8b 45 08             	mov    0x8(%ebp),%eax
 11e:	eb 13                	jmp    133 <strchr+0x31>
  for(; *s; s++)
 120:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 124:	8b 45 08             	mov    0x8(%ebp),%eax
 127:	0f b6 00             	movzbl (%eax),%eax
 12a:	84 c0                	test   %al,%al
 12c:	75 e2                	jne    110 <strchr+0xe>
  return 0;
 12e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 133:	c9                   	leave  
 134:	c3                   	ret    

00000135 <gets>:

char*
gets(char *buf, int max)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 142:	eb 42                	jmp    186 <gets+0x51>
    cc = read(0, &c, 1);
 144:	83 ec 04             	sub    $0x4,%esp
 147:	6a 01                	push   $0x1
 149:	8d 45 ef             	lea    -0x11(%ebp),%eax
 14c:	50                   	push   %eax
 14d:	6a 00                	push   $0x0
 14f:	e8 47 01 00 00       	call   29b <read>
 154:	83 c4 10             	add    $0x10,%esp
 157:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 15a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 15e:	7e 33                	jle    193 <gets+0x5e>
      break;
    buf[i++] = c;
 160:	8b 45 f4             	mov    -0xc(%ebp),%eax
 163:	8d 50 01             	lea    0x1(%eax),%edx
 166:	89 55 f4             	mov    %edx,-0xc(%ebp)
 169:	89 c2                	mov    %eax,%edx
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	01 c2                	add    %eax,%edx
 170:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 174:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 176:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 17a:	3c 0a                	cmp    $0xa,%al
 17c:	74 16                	je     194 <gets+0x5f>
 17e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 182:	3c 0d                	cmp    $0xd,%al
 184:	74 0e                	je     194 <gets+0x5f>
  for(i=0; i+1 < max; ){
 186:	8b 45 f4             	mov    -0xc(%ebp),%eax
 189:	83 c0 01             	add    $0x1,%eax
 18c:	39 45 0c             	cmp    %eax,0xc(%ebp)
 18f:	7f b3                	jg     144 <gets+0xf>
 191:	eb 01                	jmp    194 <gets+0x5f>
      break;
 193:	90                   	nop
      break;
  }
  buf[i] = '\0';
 194:	8b 55 f4             	mov    -0xc(%ebp),%edx
 197:	8b 45 08             	mov    0x8(%ebp),%eax
 19a:	01 d0                	add    %edx,%eax
 19c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 19f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a2:	c9                   	leave  
 1a3:	c3                   	ret    

000001a4 <stat>:

int
stat(char *n, struct stat *st)
{
 1a4:	55                   	push   %ebp
 1a5:	89 e5                	mov    %esp,%ebp
 1a7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1aa:	83 ec 08             	sub    $0x8,%esp
 1ad:	6a 00                	push   $0x0
 1af:	ff 75 08             	push   0x8(%ebp)
 1b2:	e8 0c 01 00 00       	call   2c3 <open>
 1b7:	83 c4 10             	add    $0x10,%esp
 1ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c1:	79 07                	jns    1ca <stat+0x26>
    return -1;
 1c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c8:	eb 25                	jmp    1ef <stat+0x4b>
  r = fstat(fd, st);
 1ca:	83 ec 08             	sub    $0x8,%esp
 1cd:	ff 75 0c             	push   0xc(%ebp)
 1d0:	ff 75 f4             	push   -0xc(%ebp)
 1d3:	e8 03 01 00 00       	call   2db <fstat>
 1d8:	83 c4 10             	add    $0x10,%esp
 1db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1de:	83 ec 0c             	sub    $0xc,%esp
 1e1:	ff 75 f4             	push   -0xc(%ebp)
 1e4:	e8 c2 00 00 00       	call   2ab <close>
 1e9:	83 c4 10             	add    $0x10,%esp
  return r;
 1ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1ef:	c9                   	leave  
 1f0:	c3                   	ret    

000001f1 <atoi>:

int
atoi(const char *s)
{
 1f1:	55                   	push   %ebp
 1f2:	89 e5                	mov    %esp,%ebp
 1f4:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1fe:	eb 25                	jmp    225 <atoi+0x34>
    n = n*10 + *s++ - '0';
 200:	8b 55 fc             	mov    -0x4(%ebp),%edx
 203:	89 d0                	mov    %edx,%eax
 205:	c1 e0 02             	shl    $0x2,%eax
 208:	01 d0                	add    %edx,%eax
 20a:	01 c0                	add    %eax,%eax
 20c:	89 c1                	mov    %eax,%ecx
 20e:	8b 45 08             	mov    0x8(%ebp),%eax
 211:	8d 50 01             	lea    0x1(%eax),%edx
 214:	89 55 08             	mov    %edx,0x8(%ebp)
 217:	0f b6 00             	movzbl (%eax),%eax
 21a:	0f be c0             	movsbl %al,%eax
 21d:	01 c8                	add    %ecx,%eax
 21f:	83 e8 30             	sub    $0x30,%eax
 222:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 225:	8b 45 08             	mov    0x8(%ebp),%eax
 228:	0f b6 00             	movzbl (%eax),%eax
 22b:	3c 2f                	cmp    $0x2f,%al
 22d:	7e 0a                	jle    239 <atoi+0x48>
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	0f b6 00             	movzbl (%eax),%eax
 235:	3c 39                	cmp    $0x39,%al
 237:	7e c7                	jle    200 <atoi+0xf>
  return n;
 239:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 23c:	c9                   	leave  
 23d:	c3                   	ret    

0000023e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 23e:	55                   	push   %ebp
 23f:	89 e5                	mov    %esp,%ebp
 241:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 244:	8b 45 08             	mov    0x8(%ebp),%eax
 247:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 24a:	8b 45 0c             	mov    0xc(%ebp),%eax
 24d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 250:	eb 17                	jmp    269 <memmove+0x2b>
    *dst++ = *src++;
 252:	8b 55 f8             	mov    -0x8(%ebp),%edx
 255:	8d 42 01             	lea    0x1(%edx),%eax
 258:	89 45 f8             	mov    %eax,-0x8(%ebp)
 25b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 25e:	8d 48 01             	lea    0x1(%eax),%ecx
 261:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 264:	0f b6 12             	movzbl (%edx),%edx
 267:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 269:	8b 45 10             	mov    0x10(%ebp),%eax
 26c:	8d 50 ff             	lea    -0x1(%eax),%edx
 26f:	89 55 10             	mov    %edx,0x10(%ebp)
 272:	85 c0                	test   %eax,%eax
 274:	7f dc                	jg     252 <memmove+0x14>
  return vdst;
 276:	8b 45 08             	mov    0x8(%ebp),%eax
}
 279:	c9                   	leave  
 27a:	c3                   	ret    

0000027b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 27b:	b8 01 00 00 00       	mov    $0x1,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <exit>:
SYSCALL(exit)
 283:	b8 02 00 00 00       	mov    $0x2,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <wait>:
SYSCALL(wait)
 28b:	b8 03 00 00 00       	mov    $0x3,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <pipe>:
SYSCALL(pipe)
 293:	b8 04 00 00 00       	mov    $0x4,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <read>:
SYSCALL(read)
 29b:	b8 05 00 00 00       	mov    $0x5,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <write>:
SYSCALL(write)
 2a3:	b8 10 00 00 00       	mov    $0x10,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <close>:
SYSCALL(close)
 2ab:	b8 15 00 00 00       	mov    $0x15,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <kill>:
SYSCALL(kill)
 2b3:	b8 06 00 00 00       	mov    $0x6,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <exec>:
SYSCALL(exec)
 2bb:	b8 07 00 00 00       	mov    $0x7,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <open>:
SYSCALL(open)
 2c3:	b8 0f 00 00 00       	mov    $0xf,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <mknod>:
SYSCALL(mknod)
 2cb:	b8 11 00 00 00       	mov    $0x11,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <unlink>:
SYSCALL(unlink)
 2d3:	b8 12 00 00 00       	mov    $0x12,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <fstat>:
SYSCALL(fstat)
 2db:	b8 08 00 00 00       	mov    $0x8,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <link>:
SYSCALL(link)
 2e3:	b8 13 00 00 00       	mov    $0x13,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <mkdir>:
SYSCALL(mkdir)
 2eb:	b8 14 00 00 00       	mov    $0x14,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <chdir>:
SYSCALL(chdir)
 2f3:	b8 09 00 00 00       	mov    $0x9,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <dup>:
SYSCALL(dup)
 2fb:	b8 0a 00 00 00       	mov    $0xa,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <getpid>:
SYSCALL(getpid)
 303:	b8 0b 00 00 00       	mov    $0xb,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <sbrk>:
SYSCALL(sbrk)
 30b:	b8 0c 00 00 00       	mov    $0xc,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <sleep>:
SYSCALL(sleep)
 313:	b8 0d 00 00 00       	mov    $0xd,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <uptime>:
SYSCALL(uptime)
 31b:	b8 0e 00 00 00       	mov    $0xe,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <uthread_init>:

SYSCALL(uthread_init)
 323:	b8 16 00 00 00       	mov    $0x16,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <check_thread>:
SYSCALL(check_thread)
 32b:	b8 17 00 00 00       	mov    $0x17,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <getpinfo>:

SYSCALL(getpinfo)
 333:	b8 18 00 00 00       	mov    $0x18,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 33b:	b8 19 00 00 00       	mov    $0x19,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <yield>:
SYSCALL(yield)
 343:	b8 1a 00 00 00       	mov    $0x1a,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <printpt>:

 34b:	b8 1b 00 00 00       	mov    $0x1b,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 353:	55                   	push   %ebp
 354:	89 e5                	mov    %esp,%ebp
 356:	83 ec 18             	sub    $0x18,%esp
 359:	8b 45 0c             	mov    0xc(%ebp),%eax
 35c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 35f:	83 ec 04             	sub    $0x4,%esp
 362:	6a 01                	push   $0x1
 364:	8d 45 f4             	lea    -0xc(%ebp),%eax
 367:	50                   	push   %eax
 368:	ff 75 08             	push   0x8(%ebp)
 36b:	e8 33 ff ff ff       	call   2a3 <write>
 370:	83 c4 10             	add    $0x10,%esp
}
 373:	90                   	nop
 374:	c9                   	leave  
 375:	c3                   	ret    

00000376 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 376:	55                   	push   %ebp
 377:	89 e5                	mov    %esp,%ebp
 379:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 37c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 383:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 387:	74 17                	je     3a0 <printint+0x2a>
 389:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 38d:	79 11                	jns    3a0 <printint+0x2a>
    neg = 1;
 38f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 396:	8b 45 0c             	mov    0xc(%ebp),%eax
 399:	f7 d8                	neg    %eax
 39b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 39e:	eb 06                	jmp    3a6 <printint+0x30>
  } else {
    x = xx;
 3a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3b3:	ba 00 00 00 00       	mov    $0x0,%edx
 3b8:	f7 f1                	div    %ecx
 3ba:	89 d1                	mov    %edx,%ecx
 3bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3bf:	8d 50 01             	lea    0x1(%eax),%edx
 3c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3c5:	0f b6 91 2c 0a 00 00 	movzbl 0xa2c(%ecx),%edx
 3cc:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3d6:	ba 00 00 00 00       	mov    $0x0,%edx
 3db:	f7 f1                	div    %ecx
 3dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3e4:	75 c7                	jne    3ad <printint+0x37>
  if(neg)
 3e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3ea:	74 2d                	je     419 <printint+0xa3>
    buf[i++] = '-';
 3ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ef:	8d 50 01             	lea    0x1(%eax),%edx
 3f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3f5:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3fa:	eb 1d                	jmp    419 <printint+0xa3>
    putc(fd, buf[i]);
 3fc:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 402:	01 d0                	add    %edx,%eax
 404:	0f b6 00             	movzbl (%eax),%eax
 407:	0f be c0             	movsbl %al,%eax
 40a:	83 ec 08             	sub    $0x8,%esp
 40d:	50                   	push   %eax
 40e:	ff 75 08             	push   0x8(%ebp)
 411:	e8 3d ff ff ff       	call   353 <putc>
 416:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 419:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 41d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 421:	79 d9                	jns    3fc <printint+0x86>
}
 423:	90                   	nop
 424:	90                   	nop
 425:	c9                   	leave  
 426:	c3                   	ret    

00000427 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 427:	55                   	push   %ebp
 428:	89 e5                	mov    %esp,%ebp
 42a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 42d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 434:	8d 45 0c             	lea    0xc(%ebp),%eax
 437:	83 c0 04             	add    $0x4,%eax
 43a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 43d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 444:	e9 59 01 00 00       	jmp    5a2 <printf+0x17b>
    c = fmt[i] & 0xff;
 449:	8b 55 0c             	mov    0xc(%ebp),%edx
 44c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 44f:	01 d0                	add    %edx,%eax
 451:	0f b6 00             	movzbl (%eax),%eax
 454:	0f be c0             	movsbl %al,%eax
 457:	25 ff 00 00 00       	and    $0xff,%eax
 45c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 45f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 463:	75 2c                	jne    491 <printf+0x6a>
      if(c == '%'){
 465:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 469:	75 0c                	jne    477 <printf+0x50>
        state = '%';
 46b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 472:	e9 27 01 00 00       	jmp    59e <printf+0x177>
      } else {
        putc(fd, c);
 477:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 47a:	0f be c0             	movsbl %al,%eax
 47d:	83 ec 08             	sub    $0x8,%esp
 480:	50                   	push   %eax
 481:	ff 75 08             	push   0x8(%ebp)
 484:	e8 ca fe ff ff       	call   353 <putc>
 489:	83 c4 10             	add    $0x10,%esp
 48c:	e9 0d 01 00 00       	jmp    59e <printf+0x177>
      }
    } else if(state == '%'){
 491:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 495:	0f 85 03 01 00 00    	jne    59e <printf+0x177>
      if(c == 'd'){
 49b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 49f:	75 1e                	jne    4bf <printf+0x98>
        printint(fd, *ap, 10, 1);
 4a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4a4:	8b 00                	mov    (%eax),%eax
 4a6:	6a 01                	push   $0x1
 4a8:	6a 0a                	push   $0xa
 4aa:	50                   	push   %eax
 4ab:	ff 75 08             	push   0x8(%ebp)
 4ae:	e8 c3 fe ff ff       	call   376 <printint>
 4b3:	83 c4 10             	add    $0x10,%esp
        ap++;
 4b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ba:	e9 d8 00 00 00       	jmp    597 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4bf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4c3:	74 06                	je     4cb <printf+0xa4>
 4c5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4c9:	75 1e                	jne    4e9 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ce:	8b 00                	mov    (%eax),%eax
 4d0:	6a 00                	push   $0x0
 4d2:	6a 10                	push   $0x10
 4d4:	50                   	push   %eax
 4d5:	ff 75 08             	push   0x8(%ebp)
 4d8:	e8 99 fe ff ff       	call   376 <printint>
 4dd:	83 c4 10             	add    $0x10,%esp
        ap++;
 4e0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4e4:	e9 ae 00 00 00       	jmp    597 <printf+0x170>
      } else if(c == 's'){
 4e9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4ed:	75 43                	jne    532 <printf+0x10b>
        s = (char*)*ap;
 4ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f2:	8b 00                	mov    (%eax),%eax
 4f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4f7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ff:	75 25                	jne    526 <printf+0xff>
          s = "(null)";
 501:	c7 45 f4 de 07 00 00 	movl   $0x7de,-0xc(%ebp)
        while(*s != 0){
 508:	eb 1c                	jmp    526 <printf+0xff>
          putc(fd, *s);
 50a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50d:	0f b6 00             	movzbl (%eax),%eax
 510:	0f be c0             	movsbl %al,%eax
 513:	83 ec 08             	sub    $0x8,%esp
 516:	50                   	push   %eax
 517:	ff 75 08             	push   0x8(%ebp)
 51a:	e8 34 fe ff ff       	call   353 <putc>
 51f:	83 c4 10             	add    $0x10,%esp
          s++;
 522:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 526:	8b 45 f4             	mov    -0xc(%ebp),%eax
 529:	0f b6 00             	movzbl (%eax),%eax
 52c:	84 c0                	test   %al,%al
 52e:	75 da                	jne    50a <printf+0xe3>
 530:	eb 65                	jmp    597 <printf+0x170>
        }
      } else if(c == 'c'){
 532:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 536:	75 1d                	jne    555 <printf+0x12e>
        putc(fd, *ap);
 538:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53b:	8b 00                	mov    (%eax),%eax
 53d:	0f be c0             	movsbl %al,%eax
 540:	83 ec 08             	sub    $0x8,%esp
 543:	50                   	push   %eax
 544:	ff 75 08             	push   0x8(%ebp)
 547:	e8 07 fe ff ff       	call   353 <putc>
 54c:	83 c4 10             	add    $0x10,%esp
        ap++;
 54f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 553:	eb 42                	jmp    597 <printf+0x170>
      } else if(c == '%'){
 555:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 559:	75 17                	jne    572 <printf+0x14b>
        putc(fd, c);
 55b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55e:	0f be c0             	movsbl %al,%eax
 561:	83 ec 08             	sub    $0x8,%esp
 564:	50                   	push   %eax
 565:	ff 75 08             	push   0x8(%ebp)
 568:	e8 e6 fd ff ff       	call   353 <putc>
 56d:	83 c4 10             	add    $0x10,%esp
 570:	eb 25                	jmp    597 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 572:	83 ec 08             	sub    $0x8,%esp
 575:	6a 25                	push   $0x25
 577:	ff 75 08             	push   0x8(%ebp)
 57a:	e8 d4 fd ff ff       	call   353 <putc>
 57f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 585:	0f be c0             	movsbl %al,%eax
 588:	83 ec 08             	sub    $0x8,%esp
 58b:	50                   	push   %eax
 58c:	ff 75 08             	push   0x8(%ebp)
 58f:	e8 bf fd ff ff       	call   353 <putc>
 594:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 597:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 59e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5a8:	01 d0                	add    %edx,%eax
 5aa:	0f b6 00             	movzbl (%eax),%eax
 5ad:	84 c0                	test   %al,%al
 5af:	0f 85 94 fe ff ff    	jne    449 <printf+0x22>
    }
  }
}
 5b5:	90                   	nop
 5b6:	90                   	nop
 5b7:	c9                   	leave  
 5b8:	c3                   	ret    

000005b9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5b9:	55                   	push   %ebp
 5ba:	89 e5                	mov    %esp,%ebp
 5bc:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5bf:	8b 45 08             	mov    0x8(%ebp),%eax
 5c2:	83 e8 08             	sub    $0x8,%eax
 5c5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5c8:	a1 48 0a 00 00       	mov    0xa48,%eax
 5cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5d0:	eb 24                	jmp    5f6 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d5:	8b 00                	mov    (%eax),%eax
 5d7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5da:	72 12                	jb     5ee <free+0x35>
 5dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5df:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5e2:	77 24                	ja     608 <free+0x4f>
 5e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e7:	8b 00                	mov    (%eax),%eax
 5e9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5ec:	72 1a                	jb     608 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f1:	8b 00                	mov    (%eax),%eax
 5f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5fc:	76 d4                	jbe    5d2 <free+0x19>
 5fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 601:	8b 00                	mov    (%eax),%eax
 603:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 606:	73 ca                	jae    5d2 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 608:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60b:	8b 40 04             	mov    0x4(%eax),%eax
 60e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 615:	8b 45 f8             	mov    -0x8(%ebp),%eax
 618:	01 c2                	add    %eax,%edx
 61a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61d:	8b 00                	mov    (%eax),%eax
 61f:	39 c2                	cmp    %eax,%edx
 621:	75 24                	jne    647 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 623:	8b 45 f8             	mov    -0x8(%ebp),%eax
 626:	8b 50 04             	mov    0x4(%eax),%edx
 629:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	8b 40 04             	mov    0x4(%eax),%eax
 631:	01 c2                	add    %eax,%edx
 633:	8b 45 f8             	mov    -0x8(%ebp),%eax
 636:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 639:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63c:	8b 00                	mov    (%eax),%eax
 63e:	8b 10                	mov    (%eax),%edx
 640:	8b 45 f8             	mov    -0x8(%ebp),%eax
 643:	89 10                	mov    %edx,(%eax)
 645:	eb 0a                	jmp    651 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 647:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64a:	8b 10                	mov    (%eax),%edx
 64c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 651:	8b 45 fc             	mov    -0x4(%ebp),%eax
 654:	8b 40 04             	mov    0x4(%eax),%eax
 657:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 65e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 661:	01 d0                	add    %edx,%eax
 663:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 666:	75 20                	jne    688 <free+0xcf>
    p->s.size += bp->s.size;
 668:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66b:	8b 50 04             	mov    0x4(%eax),%edx
 66e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 671:	8b 40 04             	mov    0x4(%eax),%eax
 674:	01 c2                	add    %eax,%edx
 676:	8b 45 fc             	mov    -0x4(%ebp),%eax
 679:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 67c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67f:	8b 10                	mov    (%eax),%edx
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	89 10                	mov    %edx,(%eax)
 686:	eb 08                	jmp    690 <free+0xd7>
  } else
    p->s.ptr = bp;
 688:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 68e:	89 10                	mov    %edx,(%eax)
  freep = p;
 690:	8b 45 fc             	mov    -0x4(%ebp),%eax
 693:	a3 48 0a 00 00       	mov    %eax,0xa48
}
 698:	90                   	nop
 699:	c9                   	leave  
 69a:	c3                   	ret    

0000069b <morecore>:

static Header*
morecore(uint nu)
{
 69b:	55                   	push   %ebp
 69c:	89 e5                	mov    %esp,%ebp
 69e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6a1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6a8:	77 07                	ja     6b1 <morecore+0x16>
    nu = 4096;
 6aa:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6b1:	8b 45 08             	mov    0x8(%ebp),%eax
 6b4:	c1 e0 03             	shl    $0x3,%eax
 6b7:	83 ec 0c             	sub    $0xc,%esp
 6ba:	50                   	push   %eax
 6bb:	e8 4b fc ff ff       	call   30b <sbrk>
 6c0:	83 c4 10             	add    $0x10,%esp
 6c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6c6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ca:	75 07                	jne    6d3 <morecore+0x38>
    return 0;
 6cc:	b8 00 00 00 00       	mov    $0x0,%eax
 6d1:	eb 26                	jmp    6f9 <morecore+0x5e>
  hp = (Header*)p;
 6d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6dc:	8b 55 08             	mov    0x8(%ebp),%edx
 6df:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e5:	83 c0 08             	add    $0x8,%eax
 6e8:	83 ec 0c             	sub    $0xc,%esp
 6eb:	50                   	push   %eax
 6ec:	e8 c8 fe ff ff       	call   5b9 <free>
 6f1:	83 c4 10             	add    $0x10,%esp
  return freep;
 6f4:	a1 48 0a 00 00       	mov    0xa48,%eax
}
 6f9:	c9                   	leave  
 6fa:	c3                   	ret    

000006fb <malloc>:

void*
malloc(uint nbytes)
{
 6fb:	55                   	push   %ebp
 6fc:	89 e5                	mov    %esp,%ebp
 6fe:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 701:	8b 45 08             	mov    0x8(%ebp),%eax
 704:	83 c0 07             	add    $0x7,%eax
 707:	c1 e8 03             	shr    $0x3,%eax
 70a:	83 c0 01             	add    $0x1,%eax
 70d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 710:	a1 48 0a 00 00       	mov    0xa48,%eax
 715:	89 45 f0             	mov    %eax,-0x10(%ebp)
 718:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 71c:	75 23                	jne    741 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 71e:	c7 45 f0 40 0a 00 00 	movl   $0xa40,-0x10(%ebp)
 725:	8b 45 f0             	mov    -0x10(%ebp),%eax
 728:	a3 48 0a 00 00       	mov    %eax,0xa48
 72d:	a1 48 0a 00 00       	mov    0xa48,%eax
 732:	a3 40 0a 00 00       	mov    %eax,0xa40
    base.s.size = 0;
 737:	c7 05 44 0a 00 00 00 	movl   $0x0,0xa44
 73e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 741:	8b 45 f0             	mov    -0x10(%ebp),%eax
 744:	8b 00                	mov    (%eax),%eax
 746:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 749:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74c:	8b 40 04             	mov    0x4(%eax),%eax
 74f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 752:	77 4d                	ja     7a1 <malloc+0xa6>
      if(p->s.size == nunits)
 754:	8b 45 f4             	mov    -0xc(%ebp),%eax
 757:	8b 40 04             	mov    0x4(%eax),%eax
 75a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 75d:	75 0c                	jne    76b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 75f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 762:	8b 10                	mov    (%eax),%edx
 764:	8b 45 f0             	mov    -0x10(%ebp),%eax
 767:	89 10                	mov    %edx,(%eax)
 769:	eb 26                	jmp    791 <malloc+0x96>
      else {
        p->s.size -= nunits;
 76b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76e:	8b 40 04             	mov    0x4(%eax),%eax
 771:	2b 45 ec             	sub    -0x14(%ebp),%eax
 774:	89 c2                	mov    %eax,%edx
 776:	8b 45 f4             	mov    -0xc(%ebp),%eax
 779:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 77c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77f:	8b 40 04             	mov    0x4(%eax),%eax
 782:	c1 e0 03             	shl    $0x3,%eax
 785:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 788:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 78e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 791:	8b 45 f0             	mov    -0x10(%ebp),%eax
 794:	a3 48 0a 00 00       	mov    %eax,0xa48
      return (void*)(p + 1);
 799:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79c:	83 c0 08             	add    $0x8,%eax
 79f:	eb 3b                	jmp    7dc <malloc+0xe1>
    }
    if(p == freep)
 7a1:	a1 48 0a 00 00       	mov    0xa48,%eax
 7a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7a9:	75 1e                	jne    7c9 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7ab:	83 ec 0c             	sub    $0xc,%esp
 7ae:	ff 75 ec             	push   -0x14(%ebp)
 7b1:	e8 e5 fe ff ff       	call   69b <morecore>
 7b6:	83 c4 10             	add    $0x10,%esp
 7b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c0:	75 07                	jne    7c9 <malloc+0xce>
        return 0;
 7c2:	b8 00 00 00 00       	mov    $0x0,%eax
 7c7:	eb 13                	jmp    7dc <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d2:	8b 00                	mov    (%eax),%eax
 7d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7d7:	e9 6d ff ff ff       	jmp    749 <malloc+0x4e>
  }
}
 7dc:	c9                   	leave  
 7dd:	c3                   	ret    
