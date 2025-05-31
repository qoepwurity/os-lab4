
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	89 cb                	mov    %ecx,%ebx
  if(argc != 3){
  11:	83 3b 03             	cmpl   $0x3,(%ebx)
  14:	74 17                	je     2d <main+0x2d>
    printf(2, "Usage: ln old new\n");
  16:	83 ec 08             	sub    $0x8,%esp
  19:	68 26 08 00 00       	push   $0x826
  1e:	6a 02                	push   $0x2
  20:	e8 4a 04 00 00       	call   46f <printf>
  25:	83 c4 10             	add    $0x10,%esp
    exit();
  28:	e8 9e 02 00 00       	call   2cb <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2d:	8b 43 04             	mov    0x4(%ebx),%eax
  30:	83 c0 08             	add    $0x8,%eax
  33:	8b 10                	mov    (%eax),%edx
  35:	8b 43 04             	mov    0x4(%ebx),%eax
  38:	83 c0 04             	add    $0x4,%eax
  3b:	8b 00                	mov    (%eax),%eax
  3d:	83 ec 08             	sub    $0x8,%esp
  40:	52                   	push   %edx
  41:	50                   	push   %eax
  42:	e8 e4 02 00 00       	call   32b <link>
  47:	83 c4 10             	add    $0x10,%esp
  4a:	85 c0                	test   %eax,%eax
  4c:	79 21                	jns    6f <main+0x6f>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  4e:	8b 43 04             	mov    0x4(%ebx),%eax
  51:	83 c0 08             	add    $0x8,%eax
  54:	8b 10                	mov    (%eax),%edx
  56:	8b 43 04             	mov    0x4(%ebx),%eax
  59:	83 c0 04             	add    $0x4,%eax
  5c:	8b 00                	mov    (%eax),%eax
  5e:	52                   	push   %edx
  5f:	50                   	push   %eax
  60:	68 39 08 00 00       	push   $0x839
  65:	6a 02                	push   $0x2
  67:	e8 03 04 00 00       	call   46f <printf>
  6c:	83 c4 10             	add    $0x10,%esp
  exit();
  6f:	e8 57 02 00 00       	call   2cb <exit>

00000074 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  74:	55                   	push   %ebp
  75:	89 e5                	mov    %esp,%ebp
  77:	57                   	push   %edi
  78:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7c:	8b 55 10             	mov    0x10(%ebp),%edx
  7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  82:	89 cb                	mov    %ecx,%ebx
  84:	89 df                	mov    %ebx,%edi
  86:	89 d1                	mov    %edx,%ecx
  88:	fc                   	cld    
  89:	f3 aa                	rep stos %al,%es:(%edi)
  8b:	89 ca                	mov    %ecx,%edx
  8d:	89 fb                	mov    %edi,%ebx
  8f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  92:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  95:	90                   	nop
  96:	5b                   	pop    %ebx
  97:	5f                   	pop    %edi
  98:	5d                   	pop    %ebp
  99:	c3                   	ret    

0000009a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  9a:	55                   	push   %ebp
  9b:	89 e5                	mov    %esp,%ebp
  9d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a0:	8b 45 08             	mov    0x8(%ebp),%eax
  a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  a6:	90                   	nop
  a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  aa:	8d 42 01             	lea    0x1(%edx),%eax
  ad:	89 45 0c             	mov    %eax,0xc(%ebp)
  b0:	8b 45 08             	mov    0x8(%ebp),%eax
  b3:	8d 48 01             	lea    0x1(%eax),%ecx
  b6:	89 4d 08             	mov    %ecx,0x8(%ebp)
  b9:	0f b6 12             	movzbl (%edx),%edx
  bc:	88 10                	mov    %dl,(%eax)
  be:	0f b6 00             	movzbl (%eax),%eax
  c1:	84 c0                	test   %al,%al
  c3:	75 e2                	jne    a7 <strcpy+0xd>
    ;
  return os;
  c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c8:	c9                   	leave  
  c9:	c3                   	ret    

000000ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ca:	55                   	push   %ebp
  cb:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  cd:	eb 08                	jmp    d7 <strcmp+0xd>
    p++, q++;
  cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  d7:	8b 45 08             	mov    0x8(%ebp),%eax
  da:	0f b6 00             	movzbl (%eax),%eax
  dd:	84 c0                	test   %al,%al
  df:	74 10                	je     f1 <strcmp+0x27>
  e1:	8b 45 08             	mov    0x8(%ebp),%eax
  e4:	0f b6 10             	movzbl (%eax),%edx
  e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  ea:	0f b6 00             	movzbl (%eax),%eax
  ed:	38 c2                	cmp    %al,%dl
  ef:	74 de                	je     cf <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  f1:	8b 45 08             	mov    0x8(%ebp),%eax
  f4:	0f b6 00             	movzbl (%eax),%eax
  f7:	0f b6 d0             	movzbl %al,%edx
  fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  fd:	0f b6 00             	movzbl (%eax),%eax
 100:	0f b6 c8             	movzbl %al,%ecx
 103:	89 d0                	mov    %edx,%eax
 105:	29 c8                	sub    %ecx,%eax
}
 107:	5d                   	pop    %ebp
 108:	c3                   	ret    

00000109 <strlen>:

uint
strlen(char *s)
{
 109:	55                   	push   %ebp
 10a:	89 e5                	mov    %esp,%ebp
 10c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 10f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 116:	eb 04                	jmp    11c <strlen+0x13>
 118:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 11c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 11f:	8b 45 08             	mov    0x8(%ebp),%eax
 122:	01 d0                	add    %edx,%eax
 124:	0f b6 00             	movzbl (%eax),%eax
 127:	84 c0                	test   %al,%al
 129:	75 ed                	jne    118 <strlen+0xf>
    ;
  return n;
 12b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12e:	c9                   	leave  
 12f:	c3                   	ret    

00000130 <memset>:

void*
memset(void *dst, int c, uint n)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 133:	8b 45 10             	mov    0x10(%ebp),%eax
 136:	50                   	push   %eax
 137:	ff 75 0c             	push   0xc(%ebp)
 13a:	ff 75 08             	push   0x8(%ebp)
 13d:	e8 32 ff ff ff       	call   74 <stosb>
 142:	83 c4 0c             	add    $0xc,%esp
  return dst;
 145:	8b 45 08             	mov    0x8(%ebp),%eax
}
 148:	c9                   	leave  
 149:	c3                   	ret    

0000014a <strchr>:

char*
strchr(const char *s, char c)
{
 14a:	55                   	push   %ebp
 14b:	89 e5                	mov    %esp,%ebp
 14d:	83 ec 04             	sub    $0x4,%esp
 150:	8b 45 0c             	mov    0xc(%ebp),%eax
 153:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 156:	eb 14                	jmp    16c <strchr+0x22>
    if(*s == c)
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	0f b6 00             	movzbl (%eax),%eax
 15e:	38 45 fc             	cmp    %al,-0x4(%ebp)
 161:	75 05                	jne    168 <strchr+0x1e>
      return (char*)s;
 163:	8b 45 08             	mov    0x8(%ebp),%eax
 166:	eb 13                	jmp    17b <strchr+0x31>
  for(; *s; s++)
 168:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	0f b6 00             	movzbl (%eax),%eax
 172:	84 c0                	test   %al,%al
 174:	75 e2                	jne    158 <strchr+0xe>
  return 0;
 176:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17b:	c9                   	leave  
 17c:	c3                   	ret    

0000017d <gets>:

char*
gets(char *buf, int max)
{
 17d:	55                   	push   %ebp
 17e:	89 e5                	mov    %esp,%ebp
 180:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 183:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 18a:	eb 42                	jmp    1ce <gets+0x51>
    cc = read(0, &c, 1);
 18c:	83 ec 04             	sub    $0x4,%esp
 18f:	6a 01                	push   $0x1
 191:	8d 45 ef             	lea    -0x11(%ebp),%eax
 194:	50                   	push   %eax
 195:	6a 00                	push   $0x0
 197:	e8 47 01 00 00       	call   2e3 <read>
 19c:	83 c4 10             	add    $0x10,%esp
 19f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a6:	7e 33                	jle    1db <gets+0x5e>
      break;
    buf[i++] = c;
 1a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ab:	8d 50 01             	lea    0x1(%eax),%edx
 1ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1b1:	89 c2                	mov    %eax,%edx
 1b3:	8b 45 08             	mov    0x8(%ebp),%eax
 1b6:	01 c2                	add    %eax,%edx
 1b8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1bc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1be:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c2:	3c 0a                	cmp    $0xa,%al
 1c4:	74 16                	je     1dc <gets+0x5f>
 1c6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ca:	3c 0d                	cmp    $0xd,%al
 1cc:	74 0e                	je     1dc <gets+0x5f>
  for(i=0; i+1 < max; ){
 1ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d1:	83 c0 01             	add    $0x1,%eax
 1d4:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1d7:	7f b3                	jg     18c <gets+0xf>
 1d9:	eb 01                	jmp    1dc <gets+0x5f>
      break;
 1db:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	01 d0                	add    %edx,%eax
 1e4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ea:	c9                   	leave  
 1eb:	c3                   	ret    

000001ec <stat>:

int
stat(char *n, struct stat *st)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f2:	83 ec 08             	sub    $0x8,%esp
 1f5:	6a 00                	push   $0x0
 1f7:	ff 75 08             	push   0x8(%ebp)
 1fa:	e8 0c 01 00 00       	call   30b <open>
 1ff:	83 c4 10             	add    $0x10,%esp
 202:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 209:	79 07                	jns    212 <stat+0x26>
    return -1;
 20b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 210:	eb 25                	jmp    237 <stat+0x4b>
  r = fstat(fd, st);
 212:	83 ec 08             	sub    $0x8,%esp
 215:	ff 75 0c             	push   0xc(%ebp)
 218:	ff 75 f4             	push   -0xc(%ebp)
 21b:	e8 03 01 00 00       	call   323 <fstat>
 220:	83 c4 10             	add    $0x10,%esp
 223:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 226:	83 ec 0c             	sub    $0xc,%esp
 229:	ff 75 f4             	push   -0xc(%ebp)
 22c:	e8 c2 00 00 00       	call   2f3 <close>
 231:	83 c4 10             	add    $0x10,%esp
  return r;
 234:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 237:	c9                   	leave  
 238:	c3                   	ret    

00000239 <atoi>:

int
atoi(const char *s)
{
 239:	55                   	push   %ebp
 23a:	89 e5                	mov    %esp,%ebp
 23c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 23f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 246:	eb 25                	jmp    26d <atoi+0x34>
    n = n*10 + *s++ - '0';
 248:	8b 55 fc             	mov    -0x4(%ebp),%edx
 24b:	89 d0                	mov    %edx,%eax
 24d:	c1 e0 02             	shl    $0x2,%eax
 250:	01 d0                	add    %edx,%eax
 252:	01 c0                	add    %eax,%eax
 254:	89 c1                	mov    %eax,%ecx
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	8d 50 01             	lea    0x1(%eax),%edx
 25c:	89 55 08             	mov    %edx,0x8(%ebp)
 25f:	0f b6 00             	movzbl (%eax),%eax
 262:	0f be c0             	movsbl %al,%eax
 265:	01 c8                	add    %ecx,%eax
 267:	83 e8 30             	sub    $0x30,%eax
 26a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	0f b6 00             	movzbl (%eax),%eax
 273:	3c 2f                	cmp    $0x2f,%al
 275:	7e 0a                	jle    281 <atoi+0x48>
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	0f b6 00             	movzbl (%eax),%eax
 27d:	3c 39                	cmp    $0x39,%al
 27f:	7e c7                	jle    248 <atoi+0xf>
  return n;
 281:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 284:	c9                   	leave  
 285:	c3                   	ret    

00000286 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 286:	55                   	push   %ebp
 287:	89 e5                	mov    %esp,%ebp
 289:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 292:	8b 45 0c             	mov    0xc(%ebp),%eax
 295:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 298:	eb 17                	jmp    2b1 <memmove+0x2b>
    *dst++ = *src++;
 29a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 29d:	8d 42 01             	lea    0x1(%edx),%eax
 2a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a6:	8d 48 01             	lea    0x1(%eax),%ecx
 2a9:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2ac:	0f b6 12             	movzbl (%edx),%edx
 2af:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2b1:	8b 45 10             	mov    0x10(%ebp),%eax
 2b4:	8d 50 ff             	lea    -0x1(%eax),%edx
 2b7:	89 55 10             	mov    %edx,0x10(%ebp)
 2ba:	85 c0                	test   %eax,%eax
 2bc:	7f dc                	jg     29a <memmove+0x14>
  return vdst;
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c1:	c9                   	leave  
 2c2:	c3                   	ret    

000002c3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c3:	b8 01 00 00 00       	mov    $0x1,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <exit>:
SYSCALL(exit)
 2cb:	b8 02 00 00 00       	mov    $0x2,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <wait>:
SYSCALL(wait)
 2d3:	b8 03 00 00 00       	mov    $0x3,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <pipe>:
SYSCALL(pipe)
 2db:	b8 04 00 00 00       	mov    $0x4,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <read>:
SYSCALL(read)
 2e3:	b8 05 00 00 00       	mov    $0x5,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <write>:
SYSCALL(write)
 2eb:	b8 10 00 00 00       	mov    $0x10,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <close>:
SYSCALL(close)
 2f3:	b8 15 00 00 00       	mov    $0x15,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <kill>:
SYSCALL(kill)
 2fb:	b8 06 00 00 00       	mov    $0x6,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <exec>:
SYSCALL(exec)
 303:	b8 07 00 00 00       	mov    $0x7,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <open>:
SYSCALL(open)
 30b:	b8 0f 00 00 00       	mov    $0xf,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <mknod>:
SYSCALL(mknod)
 313:	b8 11 00 00 00       	mov    $0x11,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <unlink>:
SYSCALL(unlink)
 31b:	b8 12 00 00 00       	mov    $0x12,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <fstat>:
SYSCALL(fstat)
 323:	b8 08 00 00 00       	mov    $0x8,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <link>:
SYSCALL(link)
 32b:	b8 13 00 00 00       	mov    $0x13,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <mkdir>:
SYSCALL(mkdir)
 333:	b8 14 00 00 00       	mov    $0x14,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <chdir>:
SYSCALL(chdir)
 33b:	b8 09 00 00 00       	mov    $0x9,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <dup>:
SYSCALL(dup)
 343:	b8 0a 00 00 00       	mov    $0xa,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <getpid>:
SYSCALL(getpid)
 34b:	b8 0b 00 00 00       	mov    $0xb,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <sbrk>:
SYSCALL(sbrk)
 353:	b8 0c 00 00 00       	mov    $0xc,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <sleep>:
SYSCALL(sleep)
 35b:	b8 0d 00 00 00       	mov    $0xd,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <uptime>:
SYSCALL(uptime)
 363:	b8 0e 00 00 00       	mov    $0xe,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <uthread_init>:

SYSCALL(uthread_init)
 36b:	b8 16 00 00 00       	mov    $0x16,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <check_thread>:
SYSCALL(check_thread)
 373:	b8 17 00 00 00       	mov    $0x17,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <getpinfo>:

SYSCALL(getpinfo)
 37b:	b8 18 00 00 00       	mov    $0x18,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 383:	b8 19 00 00 00       	mov    $0x19,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <yield>:
SYSCALL(yield)
 38b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <printpt>:

 393:	b8 1b 00 00 00       	mov    $0x1b,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret    

0000039b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 39b:	55                   	push   %ebp
 39c:	89 e5                	mov    %esp,%ebp
 39e:	83 ec 18             	sub    $0x18,%esp
 3a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a4:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3a7:	83 ec 04             	sub    $0x4,%esp
 3aa:	6a 01                	push   $0x1
 3ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3af:	50                   	push   %eax
 3b0:	ff 75 08             	push   0x8(%ebp)
 3b3:	e8 33 ff ff ff       	call   2eb <write>
 3b8:	83 c4 10             	add    $0x10,%esp
}
 3bb:	90                   	nop
 3bc:	c9                   	leave  
 3bd:	c3                   	ret    

000003be <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3be:	55                   	push   %ebp
 3bf:	89 e5                	mov    %esp,%ebp
 3c1:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3cb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3cf:	74 17                	je     3e8 <printint+0x2a>
 3d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3d5:	79 11                	jns    3e8 <printint+0x2a>
    neg = 1;
 3d7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3de:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e1:	f7 d8                	neg    %eax
 3e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e6:	eb 06                	jmp    3ee <printint+0x30>
  } else {
    x = xx;
 3e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3fb:	ba 00 00 00 00       	mov    $0x0,%edx
 400:	f7 f1                	div    %ecx
 402:	89 d1                	mov    %edx,%ecx
 404:	8b 45 f4             	mov    -0xc(%ebp),%eax
 407:	8d 50 01             	lea    0x1(%eax),%edx
 40a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 40d:	0f b6 91 9c 0a 00 00 	movzbl 0xa9c(%ecx),%edx
 414:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 418:	8b 4d 10             	mov    0x10(%ebp),%ecx
 41b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41e:	ba 00 00 00 00       	mov    $0x0,%edx
 423:	f7 f1                	div    %ecx
 425:	89 45 ec             	mov    %eax,-0x14(%ebp)
 428:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 42c:	75 c7                	jne    3f5 <printint+0x37>
  if(neg)
 42e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 432:	74 2d                	je     461 <printint+0xa3>
    buf[i++] = '-';
 434:	8b 45 f4             	mov    -0xc(%ebp),%eax
 437:	8d 50 01             	lea    0x1(%eax),%edx
 43a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 43d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 442:	eb 1d                	jmp    461 <printint+0xa3>
    putc(fd, buf[i]);
 444:	8d 55 dc             	lea    -0x24(%ebp),%edx
 447:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44a:	01 d0                	add    %edx,%eax
 44c:	0f b6 00             	movzbl (%eax),%eax
 44f:	0f be c0             	movsbl %al,%eax
 452:	83 ec 08             	sub    $0x8,%esp
 455:	50                   	push   %eax
 456:	ff 75 08             	push   0x8(%ebp)
 459:	e8 3d ff ff ff       	call   39b <putc>
 45e:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 461:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 465:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 469:	79 d9                	jns    444 <printint+0x86>
}
 46b:	90                   	nop
 46c:	90                   	nop
 46d:	c9                   	leave  
 46e:	c3                   	ret    

0000046f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 46f:	55                   	push   %ebp
 470:	89 e5                	mov    %esp,%ebp
 472:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 475:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 47c:	8d 45 0c             	lea    0xc(%ebp),%eax
 47f:	83 c0 04             	add    $0x4,%eax
 482:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 485:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 48c:	e9 59 01 00 00       	jmp    5ea <printf+0x17b>
    c = fmt[i] & 0xff;
 491:	8b 55 0c             	mov    0xc(%ebp),%edx
 494:	8b 45 f0             	mov    -0x10(%ebp),%eax
 497:	01 d0                	add    %edx,%eax
 499:	0f b6 00             	movzbl (%eax),%eax
 49c:	0f be c0             	movsbl %al,%eax
 49f:	25 ff 00 00 00       	and    $0xff,%eax
 4a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ab:	75 2c                	jne    4d9 <printf+0x6a>
      if(c == '%'){
 4ad:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4b1:	75 0c                	jne    4bf <printf+0x50>
        state = '%';
 4b3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4ba:	e9 27 01 00 00       	jmp    5e6 <printf+0x177>
      } else {
        putc(fd, c);
 4bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c2:	0f be c0             	movsbl %al,%eax
 4c5:	83 ec 08             	sub    $0x8,%esp
 4c8:	50                   	push   %eax
 4c9:	ff 75 08             	push   0x8(%ebp)
 4cc:	e8 ca fe ff ff       	call   39b <putc>
 4d1:	83 c4 10             	add    $0x10,%esp
 4d4:	e9 0d 01 00 00       	jmp    5e6 <printf+0x177>
      }
    } else if(state == '%'){
 4d9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4dd:	0f 85 03 01 00 00    	jne    5e6 <printf+0x177>
      if(c == 'd'){
 4e3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4e7:	75 1e                	jne    507 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ec:	8b 00                	mov    (%eax),%eax
 4ee:	6a 01                	push   $0x1
 4f0:	6a 0a                	push   $0xa
 4f2:	50                   	push   %eax
 4f3:	ff 75 08             	push   0x8(%ebp)
 4f6:	e8 c3 fe ff ff       	call   3be <printint>
 4fb:	83 c4 10             	add    $0x10,%esp
        ap++;
 4fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 502:	e9 d8 00 00 00       	jmp    5df <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 507:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 50b:	74 06                	je     513 <printf+0xa4>
 50d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 511:	75 1e                	jne    531 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 513:	8b 45 e8             	mov    -0x18(%ebp),%eax
 516:	8b 00                	mov    (%eax),%eax
 518:	6a 00                	push   $0x0
 51a:	6a 10                	push   $0x10
 51c:	50                   	push   %eax
 51d:	ff 75 08             	push   0x8(%ebp)
 520:	e8 99 fe ff ff       	call   3be <printint>
 525:	83 c4 10             	add    $0x10,%esp
        ap++;
 528:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52c:	e9 ae 00 00 00       	jmp    5df <printf+0x170>
      } else if(c == 's'){
 531:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 535:	75 43                	jne    57a <printf+0x10b>
        s = (char*)*ap;
 537:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53a:	8b 00                	mov    (%eax),%eax
 53c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 53f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 543:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 547:	75 25                	jne    56e <printf+0xff>
          s = "(null)";
 549:	c7 45 f4 4d 08 00 00 	movl   $0x84d,-0xc(%ebp)
        while(*s != 0){
 550:	eb 1c                	jmp    56e <printf+0xff>
          putc(fd, *s);
 552:	8b 45 f4             	mov    -0xc(%ebp),%eax
 555:	0f b6 00             	movzbl (%eax),%eax
 558:	0f be c0             	movsbl %al,%eax
 55b:	83 ec 08             	sub    $0x8,%esp
 55e:	50                   	push   %eax
 55f:	ff 75 08             	push   0x8(%ebp)
 562:	e8 34 fe ff ff       	call   39b <putc>
 567:	83 c4 10             	add    $0x10,%esp
          s++;
 56a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 56e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 571:	0f b6 00             	movzbl (%eax),%eax
 574:	84 c0                	test   %al,%al
 576:	75 da                	jne    552 <printf+0xe3>
 578:	eb 65                	jmp    5df <printf+0x170>
        }
      } else if(c == 'c'){
 57a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 57e:	75 1d                	jne    59d <printf+0x12e>
        putc(fd, *ap);
 580:	8b 45 e8             	mov    -0x18(%ebp),%eax
 583:	8b 00                	mov    (%eax),%eax
 585:	0f be c0             	movsbl %al,%eax
 588:	83 ec 08             	sub    $0x8,%esp
 58b:	50                   	push   %eax
 58c:	ff 75 08             	push   0x8(%ebp)
 58f:	e8 07 fe ff ff       	call   39b <putc>
 594:	83 c4 10             	add    $0x10,%esp
        ap++;
 597:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 59b:	eb 42                	jmp    5df <printf+0x170>
      } else if(c == '%'){
 59d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5a1:	75 17                	jne    5ba <printf+0x14b>
        putc(fd, c);
 5a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a6:	0f be c0             	movsbl %al,%eax
 5a9:	83 ec 08             	sub    $0x8,%esp
 5ac:	50                   	push   %eax
 5ad:	ff 75 08             	push   0x8(%ebp)
 5b0:	e8 e6 fd ff ff       	call   39b <putc>
 5b5:	83 c4 10             	add    $0x10,%esp
 5b8:	eb 25                	jmp    5df <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ba:	83 ec 08             	sub    $0x8,%esp
 5bd:	6a 25                	push   $0x25
 5bf:	ff 75 08             	push   0x8(%ebp)
 5c2:	e8 d4 fd ff ff       	call   39b <putc>
 5c7:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5cd:	0f be c0             	movsbl %al,%eax
 5d0:	83 ec 08             	sub    $0x8,%esp
 5d3:	50                   	push   %eax
 5d4:	ff 75 08             	push   0x8(%ebp)
 5d7:	e8 bf fd ff ff       	call   39b <putc>
 5dc:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5e6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ea:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f0:	01 d0                	add    %edx,%eax
 5f2:	0f b6 00             	movzbl (%eax),%eax
 5f5:	84 c0                	test   %al,%al
 5f7:	0f 85 94 fe ff ff    	jne    491 <printf+0x22>
    }
  }
}
 5fd:	90                   	nop
 5fe:	90                   	nop
 5ff:	c9                   	leave  
 600:	c3                   	ret    

00000601 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 601:	55                   	push   %ebp
 602:	89 e5                	mov    %esp,%ebp
 604:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 607:	8b 45 08             	mov    0x8(%ebp),%eax
 60a:	83 e8 08             	sub    $0x8,%eax
 60d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 610:	a1 b8 0a 00 00       	mov    0xab8,%eax
 615:	89 45 fc             	mov    %eax,-0x4(%ebp)
 618:	eb 24                	jmp    63e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 61a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61d:	8b 00                	mov    (%eax),%eax
 61f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 622:	72 12                	jb     636 <free+0x35>
 624:	8b 45 f8             	mov    -0x8(%ebp),%eax
 627:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 62a:	77 24                	ja     650 <free+0x4f>
 62c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62f:	8b 00                	mov    (%eax),%eax
 631:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 634:	72 1a                	jb     650 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 636:	8b 45 fc             	mov    -0x4(%ebp),%eax
 639:	8b 00                	mov    (%eax),%eax
 63b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 63e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 641:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 644:	76 d4                	jbe    61a <free+0x19>
 646:	8b 45 fc             	mov    -0x4(%ebp),%eax
 649:	8b 00                	mov    (%eax),%eax
 64b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 64e:	73 ca                	jae    61a <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 650:	8b 45 f8             	mov    -0x8(%ebp),%eax
 653:	8b 40 04             	mov    0x4(%eax),%eax
 656:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 65d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 660:	01 c2                	add    %eax,%edx
 662:	8b 45 fc             	mov    -0x4(%ebp),%eax
 665:	8b 00                	mov    (%eax),%eax
 667:	39 c2                	cmp    %eax,%edx
 669:	75 24                	jne    68f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 66b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66e:	8b 50 04             	mov    0x4(%eax),%edx
 671:	8b 45 fc             	mov    -0x4(%ebp),%eax
 674:	8b 00                	mov    (%eax),%eax
 676:	8b 40 04             	mov    0x4(%eax),%eax
 679:	01 c2                	add    %eax,%edx
 67b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	8b 00                	mov    (%eax),%eax
 686:	8b 10                	mov    (%eax),%edx
 688:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68b:	89 10                	mov    %edx,(%eax)
 68d:	eb 0a                	jmp    699 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 692:	8b 10                	mov    (%eax),%edx
 694:	8b 45 f8             	mov    -0x8(%ebp),%eax
 697:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	8b 40 04             	mov    0x4(%eax),%eax
 69f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a9:	01 d0                	add    %edx,%eax
 6ab:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6ae:	75 20                	jne    6d0 <free+0xcf>
    p->s.size += bp->s.size;
 6b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b3:	8b 50 04             	mov    0x4(%eax),%edx
 6b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b9:	8b 40 04             	mov    0x4(%eax),%eax
 6bc:	01 c2                	add    %eax,%edx
 6be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c7:	8b 10                	mov    (%eax),%edx
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	89 10                	mov    %edx,(%eax)
 6ce:	eb 08                	jmp    6d8 <free+0xd7>
  } else
    p->s.ptr = bp;
 6d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6d6:	89 10                	mov    %edx,(%eax)
  freep = p;
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	a3 b8 0a 00 00       	mov    %eax,0xab8
}
 6e0:	90                   	nop
 6e1:	c9                   	leave  
 6e2:	c3                   	ret    

000006e3 <morecore>:

static Header*
morecore(uint nu)
{
 6e3:	55                   	push   %ebp
 6e4:	89 e5                	mov    %esp,%ebp
 6e6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6e9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6f0:	77 07                	ja     6f9 <morecore+0x16>
    nu = 4096;
 6f2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6f9:	8b 45 08             	mov    0x8(%ebp),%eax
 6fc:	c1 e0 03             	shl    $0x3,%eax
 6ff:	83 ec 0c             	sub    $0xc,%esp
 702:	50                   	push   %eax
 703:	e8 4b fc ff ff       	call   353 <sbrk>
 708:	83 c4 10             	add    $0x10,%esp
 70b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 70e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 712:	75 07                	jne    71b <morecore+0x38>
    return 0;
 714:	b8 00 00 00 00       	mov    $0x0,%eax
 719:	eb 26                	jmp    741 <morecore+0x5e>
  hp = (Header*)p;
 71b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 721:	8b 45 f0             	mov    -0x10(%ebp),%eax
 724:	8b 55 08             	mov    0x8(%ebp),%edx
 727:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 72a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72d:	83 c0 08             	add    $0x8,%eax
 730:	83 ec 0c             	sub    $0xc,%esp
 733:	50                   	push   %eax
 734:	e8 c8 fe ff ff       	call   601 <free>
 739:	83 c4 10             	add    $0x10,%esp
  return freep;
 73c:	a1 b8 0a 00 00       	mov    0xab8,%eax
}
 741:	c9                   	leave  
 742:	c3                   	ret    

00000743 <malloc>:

void*
malloc(uint nbytes)
{
 743:	55                   	push   %ebp
 744:	89 e5                	mov    %esp,%ebp
 746:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 749:	8b 45 08             	mov    0x8(%ebp),%eax
 74c:	83 c0 07             	add    $0x7,%eax
 74f:	c1 e8 03             	shr    $0x3,%eax
 752:	83 c0 01             	add    $0x1,%eax
 755:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 758:	a1 b8 0a 00 00       	mov    0xab8,%eax
 75d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 760:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 764:	75 23                	jne    789 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 766:	c7 45 f0 b0 0a 00 00 	movl   $0xab0,-0x10(%ebp)
 76d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 770:	a3 b8 0a 00 00       	mov    %eax,0xab8
 775:	a1 b8 0a 00 00       	mov    0xab8,%eax
 77a:	a3 b0 0a 00 00       	mov    %eax,0xab0
    base.s.size = 0;
 77f:	c7 05 b4 0a 00 00 00 	movl   $0x0,0xab4
 786:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 789:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78c:	8b 00                	mov    (%eax),%eax
 78e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 791:	8b 45 f4             	mov    -0xc(%ebp),%eax
 794:	8b 40 04             	mov    0x4(%eax),%eax
 797:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 79a:	77 4d                	ja     7e9 <malloc+0xa6>
      if(p->s.size == nunits)
 79c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79f:	8b 40 04             	mov    0x4(%eax),%eax
 7a2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7a5:	75 0c                	jne    7b3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	8b 10                	mov    (%eax),%edx
 7ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7af:	89 10                	mov    %edx,(%eax)
 7b1:	eb 26                	jmp    7d9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b6:	8b 40 04             	mov    0x4(%eax),%eax
 7b9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7bc:	89 c2                	mov    %eax,%edx
 7be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	8b 40 04             	mov    0x4(%eax),%eax
 7ca:	c1 e0 03             	shl    $0x3,%eax
 7cd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7d6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	a3 b8 0a 00 00       	mov    %eax,0xab8
      return (void*)(p + 1);
 7e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e4:	83 c0 08             	add    $0x8,%eax
 7e7:	eb 3b                	jmp    824 <malloc+0xe1>
    }
    if(p == freep)
 7e9:	a1 b8 0a 00 00       	mov    0xab8,%eax
 7ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7f1:	75 1e                	jne    811 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7f3:	83 ec 0c             	sub    $0xc,%esp
 7f6:	ff 75 ec             	push   -0x14(%ebp)
 7f9:	e8 e5 fe ff ff       	call   6e3 <morecore>
 7fe:	83 c4 10             	add    $0x10,%esp
 801:	89 45 f4             	mov    %eax,-0xc(%ebp)
 804:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 808:	75 07                	jne    811 <malloc+0xce>
        return 0;
 80a:	b8 00 00 00 00       	mov    $0x0,%eax
 80f:	eb 13                	jmp    824 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 811:	8b 45 f4             	mov    -0xc(%ebp),%eax
 814:	89 45 f0             	mov    %eax,-0x10(%ebp)
 817:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81a:	8b 00                	mov    (%eax),%eax
 81c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 81f:	e9 6d ff ff ff       	jmp    791 <malloc+0x4e>
  }
}
 824:	c9                   	leave  
 825:	c3                   	ret    
