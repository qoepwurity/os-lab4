
_recurse:     file format elf32-i386


Disassembly of section .text:

00000000 <recurse>:
// Prevent this function from being optimized, which might give it closed form
#pragma GCC push_options
#pragma GCC optimize ("O0")

static int recurse(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  if(n == 0)
   6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   a:	75 07                	jne    13 <recurse+0x13>
    return 0;
   c:	b8 00 00 00 00       	mov    $0x0,%eax
  11:	eb 17                	jmp    2a <recurse+0x2a>
  return n + recurse(n - 1);
  13:	8b 45 08             	mov    0x8(%ebp),%eax
  16:	83 e8 01             	sub    $0x1,%eax
  19:	83 ec 0c             	sub    $0xc,%esp
  1c:	50                   	push   %eax
  1d:	e8 de ff ff ff       	call   0 <recurse>
  22:	83 c4 10             	add    $0x10,%esp
  25:	8b 55 08             	mov    0x8(%ebp),%edx
  28:	01 d0                	add    %edx,%eax
}
  2a:	c9                   	leave  
  2b:	c3                   	ret    

0000002c <main>:
#pragma GCC pop_options

int main(int argc, char *argv[])
{
  2c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  30:	83 e4 f0             	and    $0xfffffff0,%esp
  33:	ff 71 fc             	push   -0x4(%ecx)
  36:	55                   	push   %ebp
  37:	89 e5                	mov    %esp,%ebp
  39:	53                   	push   %ebx
  3a:	51                   	push   %ecx
  3b:	83 ec 10             	sub    $0x10,%esp
  3e:	89 cb                	mov    %ecx,%ebx
  int n, m;

  if(argc != 2){
  40:	83 3b 02             	cmpl   $0x2,(%ebx)
  43:	74 1d                	je     62 <main+0x36>
    printf(1, "Usage: %s levels\n", argv[0]);
  45:	8b 43 04             	mov    0x4(%ebx),%eax
  48:	8b 00                	mov    (%eax),%eax
  4a:	83 ec 04             	sub    $0x4,%esp
  4d:	50                   	push   %eax
  4e:	68 8d 08 00 00       	push   $0x88d
  53:	6a 01                	push   $0x1
  55:	e8 7c 04 00 00       	call   4d6 <printf>
  5a:	83 c4 10             	add    $0x10,%esp
    exit();
  5d:	e8 d0 02 00 00       	call   332 <exit>
  }
  printpt(getpid()); // Uncomment for the test.
  62:	e8 4b 03 00 00       	call   3b2 <getpid>
  67:	83 ec 0c             	sub    $0xc,%esp
  6a:	50                   	push   %eax
  6b:	e8 8a 03 00 00       	call   3fa <printpt>
  70:	83 c4 10             	add    $0x10,%esp
  n = atoi(argv[1]);
  73:	8b 43 04             	mov    0x4(%ebx),%eax
  76:	83 c0 04             	add    $0x4,%eax
  79:	8b 00                	mov    (%eax),%eax
  7b:	83 ec 0c             	sub    $0xc,%esp
  7e:	50                   	push   %eax
  7f:	e8 1c 02 00 00       	call   2a0 <atoi>
  84:	83 c4 10             	add    $0x10,%esp
  87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  printf(1, "Recursing %d levels\n", n);
  8a:	83 ec 04             	sub    $0x4,%esp
  8d:	ff 75 f4             	push   -0xc(%ebp)
  90:	68 9f 08 00 00       	push   $0x89f
  95:	6a 01                	push   $0x1
  97:	e8 3a 04 00 00       	call   4d6 <printf>
  9c:	83 c4 10             	add    $0x10,%esp
  m = recurse(n);
  9f:	83 ec 0c             	sub    $0xc,%esp
  a2:	ff 75 f4             	push   -0xc(%ebp)
  a5:	e8 56 ff ff ff       	call   0 <recurse>
  aa:	83 c4 10             	add    $0x10,%esp
  ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(1, "Yielded a value of %d\n", m);
  b0:	83 ec 04             	sub    $0x4,%esp
  b3:	ff 75 f0             	push   -0x10(%ebp)
  b6:	68 b4 08 00 00       	push   $0x8b4
  bb:	6a 01                	push   $0x1
  bd:	e8 14 04 00 00       	call   4d6 <printf>
  c2:	83 c4 10             	add    $0x10,%esp
  printpt(getpid()); // Uncomment for the test.
  c5:	e8 e8 02 00 00       	call   3b2 <getpid>
  ca:	83 ec 0c             	sub    $0xc,%esp
  cd:	50                   	push   %eax
  ce:	e8 27 03 00 00       	call   3fa <printpt>
  d3:	83 c4 10             	add    $0x10,%esp
  exit();
  d6:	e8 57 02 00 00       	call   332 <exit>

000000db <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  db:	55                   	push   %ebp
  dc:	89 e5                	mov    %esp,%ebp
  de:	57                   	push   %edi
  df:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  e3:	8b 55 10             	mov    0x10(%ebp),%edx
  e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  e9:	89 cb                	mov    %ecx,%ebx
  eb:	89 df                	mov    %ebx,%edi
  ed:	89 d1                	mov    %edx,%ecx
  ef:	fc                   	cld    
  f0:	f3 aa                	rep stos %al,%es:(%edi)
  f2:	89 ca                	mov    %ecx,%edx
  f4:	89 fb                	mov    %edi,%ebx
  f6:	89 5d 08             	mov    %ebx,0x8(%ebp)
  f9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  fc:	90                   	nop
  fd:	5b                   	pop    %ebx
  fe:	5f                   	pop    %edi
  ff:	5d                   	pop    %ebp
 100:	c3                   	ret    

00000101 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 101:	55                   	push   %ebp
 102:	89 e5                	mov    %esp,%ebp
 104:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 107:	8b 45 08             	mov    0x8(%ebp),%eax
 10a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 10d:	90                   	nop
 10e:	8b 55 0c             	mov    0xc(%ebp),%edx
 111:	8d 42 01             	lea    0x1(%edx),%eax
 114:	89 45 0c             	mov    %eax,0xc(%ebp)
 117:	8b 45 08             	mov    0x8(%ebp),%eax
 11a:	8d 48 01             	lea    0x1(%eax),%ecx
 11d:	89 4d 08             	mov    %ecx,0x8(%ebp)
 120:	0f b6 12             	movzbl (%edx),%edx
 123:	88 10                	mov    %dl,(%eax)
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	84 c0                	test   %al,%al
 12a:	75 e2                	jne    10e <strcpy+0xd>
    ;
  return os;
 12c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12f:	c9                   	leave  
 130:	c3                   	ret    

00000131 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 131:	55                   	push   %ebp
 132:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 134:	eb 08                	jmp    13e <strcmp+0xd>
    p++, q++;
 136:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 13a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 13e:	8b 45 08             	mov    0x8(%ebp),%eax
 141:	0f b6 00             	movzbl (%eax),%eax
 144:	84 c0                	test   %al,%al
 146:	74 10                	je     158 <strcmp+0x27>
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	0f b6 10             	movzbl (%eax),%edx
 14e:	8b 45 0c             	mov    0xc(%ebp),%eax
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	38 c2                	cmp    %al,%dl
 156:	74 de                	je     136 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	0f b6 00             	movzbl (%eax),%eax
 15e:	0f b6 d0             	movzbl %al,%edx
 161:	8b 45 0c             	mov    0xc(%ebp),%eax
 164:	0f b6 00             	movzbl (%eax),%eax
 167:	0f b6 c8             	movzbl %al,%ecx
 16a:	89 d0                	mov    %edx,%eax
 16c:	29 c8                	sub    %ecx,%eax
}
 16e:	5d                   	pop    %ebp
 16f:	c3                   	ret    

00000170 <strlen>:

uint
strlen(char *s)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 176:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 17d:	eb 04                	jmp    183 <strlen+0x13>
 17f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 183:	8b 55 fc             	mov    -0x4(%ebp),%edx
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	01 d0                	add    %edx,%eax
 18b:	0f b6 00             	movzbl (%eax),%eax
 18e:	84 c0                	test   %al,%al
 190:	75 ed                	jne    17f <strlen+0xf>
    ;
  return n;
 192:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 195:	c9                   	leave  
 196:	c3                   	ret    

00000197 <memset>:

void*
memset(void *dst, int c, uint n)
{
 197:	55                   	push   %ebp
 198:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 19a:	8b 45 10             	mov    0x10(%ebp),%eax
 19d:	50                   	push   %eax
 19e:	ff 75 0c             	push   0xc(%ebp)
 1a1:	ff 75 08             	push   0x8(%ebp)
 1a4:	e8 32 ff ff ff       	call   db <stosb>
 1a9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1af:	c9                   	leave  
 1b0:	c3                   	ret    

000001b1 <strchr>:

char*
strchr(const char *s, char c)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 04             	sub    $0x4,%esp
 1b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ba:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1bd:	eb 14                	jmp    1d3 <strchr+0x22>
    if(*s == c)
 1bf:	8b 45 08             	mov    0x8(%ebp),%eax
 1c2:	0f b6 00             	movzbl (%eax),%eax
 1c5:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1c8:	75 05                	jne    1cf <strchr+0x1e>
      return (char*)s;
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	eb 13                	jmp    1e2 <strchr+0x31>
  for(; *s; s++)
 1cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
 1d6:	0f b6 00             	movzbl (%eax),%eax
 1d9:	84 c0                	test   %al,%al
 1db:	75 e2                	jne    1bf <strchr+0xe>
  return 0;
 1dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1e2:	c9                   	leave  
 1e3:	c3                   	ret    

000001e4 <gets>:

char*
gets(char *buf, int max)
{
 1e4:	55                   	push   %ebp
 1e5:	89 e5                	mov    %esp,%ebp
 1e7:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1f1:	eb 42                	jmp    235 <gets+0x51>
    cc = read(0, &c, 1);
 1f3:	83 ec 04             	sub    $0x4,%esp
 1f6:	6a 01                	push   $0x1
 1f8:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1fb:	50                   	push   %eax
 1fc:	6a 00                	push   $0x0
 1fe:	e8 47 01 00 00       	call   34a <read>
 203:	83 c4 10             	add    $0x10,%esp
 206:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 209:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 20d:	7e 33                	jle    242 <gets+0x5e>
      break;
    buf[i++] = c;
 20f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 212:	8d 50 01             	lea    0x1(%eax),%edx
 215:	89 55 f4             	mov    %edx,-0xc(%ebp)
 218:	89 c2                	mov    %eax,%edx
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	01 c2                	add    %eax,%edx
 21f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 223:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 225:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 229:	3c 0a                	cmp    $0xa,%al
 22b:	74 16                	je     243 <gets+0x5f>
 22d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 231:	3c 0d                	cmp    $0xd,%al
 233:	74 0e                	je     243 <gets+0x5f>
  for(i=0; i+1 < max; ){
 235:	8b 45 f4             	mov    -0xc(%ebp),%eax
 238:	83 c0 01             	add    $0x1,%eax
 23b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 23e:	7f b3                	jg     1f3 <gets+0xf>
 240:	eb 01                	jmp    243 <gets+0x5f>
      break;
 242:	90                   	nop
      break;
  }
  buf[i] = '\0';
 243:	8b 55 f4             	mov    -0xc(%ebp),%edx
 246:	8b 45 08             	mov    0x8(%ebp),%eax
 249:	01 d0                	add    %edx,%eax
 24b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 251:	c9                   	leave  
 252:	c3                   	ret    

00000253 <stat>:

int
stat(char *n, struct stat *st)
{
 253:	55                   	push   %ebp
 254:	89 e5                	mov    %esp,%ebp
 256:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 259:	83 ec 08             	sub    $0x8,%esp
 25c:	6a 00                	push   $0x0
 25e:	ff 75 08             	push   0x8(%ebp)
 261:	e8 0c 01 00 00       	call   372 <open>
 266:	83 c4 10             	add    $0x10,%esp
 269:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 26c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 270:	79 07                	jns    279 <stat+0x26>
    return -1;
 272:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 277:	eb 25                	jmp    29e <stat+0x4b>
  r = fstat(fd, st);
 279:	83 ec 08             	sub    $0x8,%esp
 27c:	ff 75 0c             	push   0xc(%ebp)
 27f:	ff 75 f4             	push   -0xc(%ebp)
 282:	e8 03 01 00 00       	call   38a <fstat>
 287:	83 c4 10             	add    $0x10,%esp
 28a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 28d:	83 ec 0c             	sub    $0xc,%esp
 290:	ff 75 f4             	push   -0xc(%ebp)
 293:	e8 c2 00 00 00       	call   35a <close>
 298:	83 c4 10             	add    $0x10,%esp
  return r;
 29b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 29e:	c9                   	leave  
 29f:	c3                   	ret    

000002a0 <atoi>:

int
atoi(const char *s)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2ad:	eb 25                	jmp    2d4 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2af:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2b2:	89 d0                	mov    %edx,%eax
 2b4:	c1 e0 02             	shl    $0x2,%eax
 2b7:	01 d0                	add    %edx,%eax
 2b9:	01 c0                	add    %eax,%eax
 2bb:	89 c1                	mov    %eax,%ecx
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	8d 50 01             	lea    0x1(%eax),%edx
 2c3:	89 55 08             	mov    %edx,0x8(%ebp)
 2c6:	0f b6 00             	movzbl (%eax),%eax
 2c9:	0f be c0             	movsbl %al,%eax
 2cc:	01 c8                	add    %ecx,%eax
 2ce:	83 e8 30             	sub    $0x30,%eax
 2d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
 2d7:	0f b6 00             	movzbl (%eax),%eax
 2da:	3c 2f                	cmp    $0x2f,%al
 2dc:	7e 0a                	jle    2e8 <atoi+0x48>
 2de:	8b 45 08             	mov    0x8(%ebp),%eax
 2e1:	0f b6 00             	movzbl (%eax),%eax
 2e4:	3c 39                	cmp    $0x39,%al
 2e6:	7e c7                	jle    2af <atoi+0xf>
  return n;
 2e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2eb:	c9                   	leave  
 2ec:	c3                   	ret    

000002ed <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2ed:	55                   	push   %ebp
 2ee:	89 e5                	mov    %esp,%ebp
 2f0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2f3:	8b 45 08             	mov    0x8(%ebp),%eax
 2f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ff:	eb 17                	jmp    318 <memmove+0x2b>
    *dst++ = *src++;
 301:	8b 55 f8             	mov    -0x8(%ebp),%edx
 304:	8d 42 01             	lea    0x1(%edx),%eax
 307:	89 45 f8             	mov    %eax,-0x8(%ebp)
 30a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 30d:	8d 48 01             	lea    0x1(%eax),%ecx
 310:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 313:	0f b6 12             	movzbl (%edx),%edx
 316:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 318:	8b 45 10             	mov    0x10(%ebp),%eax
 31b:	8d 50 ff             	lea    -0x1(%eax),%edx
 31e:	89 55 10             	mov    %edx,0x10(%ebp)
 321:	85 c0                	test   %eax,%eax
 323:	7f dc                	jg     301 <memmove+0x14>
  return vdst;
 325:	8b 45 08             	mov    0x8(%ebp),%eax
}
 328:	c9                   	leave  
 329:	c3                   	ret    

0000032a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 32a:	b8 01 00 00 00       	mov    $0x1,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <exit>:
SYSCALL(exit)
 332:	b8 02 00 00 00       	mov    $0x2,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <wait>:
SYSCALL(wait)
 33a:	b8 03 00 00 00       	mov    $0x3,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <pipe>:
SYSCALL(pipe)
 342:	b8 04 00 00 00       	mov    $0x4,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <read>:
SYSCALL(read)
 34a:	b8 05 00 00 00       	mov    $0x5,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <write>:
SYSCALL(write)
 352:	b8 10 00 00 00       	mov    $0x10,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <close>:
SYSCALL(close)
 35a:	b8 15 00 00 00       	mov    $0x15,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <kill>:
SYSCALL(kill)
 362:	b8 06 00 00 00       	mov    $0x6,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <exec>:
SYSCALL(exec)
 36a:	b8 07 00 00 00       	mov    $0x7,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <open>:
SYSCALL(open)
 372:	b8 0f 00 00 00       	mov    $0xf,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <mknod>:
SYSCALL(mknod)
 37a:	b8 11 00 00 00       	mov    $0x11,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <unlink>:
SYSCALL(unlink)
 382:	b8 12 00 00 00       	mov    $0x12,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <fstat>:
SYSCALL(fstat)
 38a:	b8 08 00 00 00       	mov    $0x8,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <link>:
SYSCALL(link)
 392:	b8 13 00 00 00       	mov    $0x13,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <mkdir>:
SYSCALL(mkdir)
 39a:	b8 14 00 00 00       	mov    $0x14,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <chdir>:
SYSCALL(chdir)
 3a2:	b8 09 00 00 00       	mov    $0x9,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <dup>:
SYSCALL(dup)
 3aa:	b8 0a 00 00 00       	mov    $0xa,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <getpid>:
SYSCALL(getpid)
 3b2:	b8 0b 00 00 00       	mov    $0xb,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <sbrk>:
SYSCALL(sbrk)
 3ba:	b8 0c 00 00 00       	mov    $0xc,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <sleep>:
SYSCALL(sleep)
 3c2:	b8 0d 00 00 00       	mov    $0xd,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <uptime>:
SYSCALL(uptime)
 3ca:	b8 0e 00 00 00       	mov    $0xe,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <uthread_init>:

SYSCALL(uthread_init)
 3d2:	b8 16 00 00 00       	mov    $0x16,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <check_thread>:
SYSCALL(check_thread)
 3da:	b8 17 00 00 00       	mov    $0x17,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <getpinfo>:

SYSCALL(getpinfo)
 3e2:	b8 18 00 00 00       	mov    $0x18,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 3ea:	b8 19 00 00 00       	mov    $0x19,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <yield>:
SYSCALL(yield)
 3f2:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <printpt>:

 3fa:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 402:	55                   	push   %ebp
 403:	89 e5                	mov    %esp,%ebp
 405:	83 ec 18             	sub    $0x18,%esp
 408:	8b 45 0c             	mov    0xc(%ebp),%eax
 40b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 40e:	83 ec 04             	sub    $0x4,%esp
 411:	6a 01                	push   $0x1
 413:	8d 45 f4             	lea    -0xc(%ebp),%eax
 416:	50                   	push   %eax
 417:	ff 75 08             	push   0x8(%ebp)
 41a:	e8 33 ff ff ff       	call   352 <write>
 41f:	83 c4 10             	add    $0x10,%esp
}
 422:	90                   	nop
 423:	c9                   	leave  
 424:	c3                   	ret    

00000425 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 425:	55                   	push   %ebp
 426:	89 e5                	mov    %esp,%ebp
 428:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 42b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 432:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 436:	74 17                	je     44f <printint+0x2a>
 438:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 43c:	79 11                	jns    44f <printint+0x2a>
    neg = 1;
 43e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 445:	8b 45 0c             	mov    0xc(%ebp),%eax
 448:	f7 d8                	neg    %eax
 44a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 44d:	eb 06                	jmp    455 <printint+0x30>
  } else {
    x = xx;
 44f:	8b 45 0c             	mov    0xc(%ebp),%eax
 452:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 455:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 45c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 45f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 462:	ba 00 00 00 00       	mov    $0x0,%edx
 467:	f7 f1                	div    %ecx
 469:	89 d1                	mov    %edx,%ecx
 46b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46e:	8d 50 01             	lea    0x1(%eax),%edx
 471:	89 55 f4             	mov    %edx,-0xc(%ebp)
 474:	0f b6 91 3c 0b 00 00 	movzbl 0xb3c(%ecx),%edx
 47b:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 47f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 482:	8b 45 ec             	mov    -0x14(%ebp),%eax
 485:	ba 00 00 00 00       	mov    $0x0,%edx
 48a:	f7 f1                	div    %ecx
 48c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 48f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 493:	75 c7                	jne    45c <printint+0x37>
  if(neg)
 495:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 499:	74 2d                	je     4c8 <printint+0xa3>
    buf[i++] = '-';
 49b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49e:	8d 50 01             	lea    0x1(%eax),%edx
 4a1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4a4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4a9:	eb 1d                	jmp    4c8 <printint+0xa3>
    putc(fd, buf[i]);
 4ab:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b1:	01 d0                	add    %edx,%eax
 4b3:	0f b6 00             	movzbl (%eax),%eax
 4b6:	0f be c0             	movsbl %al,%eax
 4b9:	83 ec 08             	sub    $0x8,%esp
 4bc:	50                   	push   %eax
 4bd:	ff 75 08             	push   0x8(%ebp)
 4c0:	e8 3d ff ff ff       	call   402 <putc>
 4c5:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4c8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d0:	79 d9                	jns    4ab <printint+0x86>
}
 4d2:	90                   	nop
 4d3:	90                   	nop
 4d4:	c9                   	leave  
 4d5:	c3                   	ret    

000004d6 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4d6:	55                   	push   %ebp
 4d7:	89 e5                	mov    %esp,%ebp
 4d9:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4dc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4e3:	8d 45 0c             	lea    0xc(%ebp),%eax
 4e6:	83 c0 04             	add    $0x4,%eax
 4e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4f3:	e9 59 01 00 00       	jmp    651 <printf+0x17b>
    c = fmt[i] & 0xff;
 4f8:	8b 55 0c             	mov    0xc(%ebp),%edx
 4fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4fe:	01 d0                	add    %edx,%eax
 500:	0f b6 00             	movzbl (%eax),%eax
 503:	0f be c0             	movsbl %al,%eax
 506:	25 ff 00 00 00       	and    $0xff,%eax
 50b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 50e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 512:	75 2c                	jne    540 <printf+0x6a>
      if(c == '%'){
 514:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 518:	75 0c                	jne    526 <printf+0x50>
        state = '%';
 51a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 521:	e9 27 01 00 00       	jmp    64d <printf+0x177>
      } else {
        putc(fd, c);
 526:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 529:	0f be c0             	movsbl %al,%eax
 52c:	83 ec 08             	sub    $0x8,%esp
 52f:	50                   	push   %eax
 530:	ff 75 08             	push   0x8(%ebp)
 533:	e8 ca fe ff ff       	call   402 <putc>
 538:	83 c4 10             	add    $0x10,%esp
 53b:	e9 0d 01 00 00       	jmp    64d <printf+0x177>
      }
    } else if(state == '%'){
 540:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 544:	0f 85 03 01 00 00    	jne    64d <printf+0x177>
      if(c == 'd'){
 54a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 54e:	75 1e                	jne    56e <printf+0x98>
        printint(fd, *ap, 10, 1);
 550:	8b 45 e8             	mov    -0x18(%ebp),%eax
 553:	8b 00                	mov    (%eax),%eax
 555:	6a 01                	push   $0x1
 557:	6a 0a                	push   $0xa
 559:	50                   	push   %eax
 55a:	ff 75 08             	push   0x8(%ebp)
 55d:	e8 c3 fe ff ff       	call   425 <printint>
 562:	83 c4 10             	add    $0x10,%esp
        ap++;
 565:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 569:	e9 d8 00 00 00       	jmp    646 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 56e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 572:	74 06                	je     57a <printf+0xa4>
 574:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 578:	75 1e                	jne    598 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 57a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57d:	8b 00                	mov    (%eax),%eax
 57f:	6a 00                	push   $0x0
 581:	6a 10                	push   $0x10
 583:	50                   	push   %eax
 584:	ff 75 08             	push   0x8(%ebp)
 587:	e8 99 fe ff ff       	call   425 <printint>
 58c:	83 c4 10             	add    $0x10,%esp
        ap++;
 58f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 593:	e9 ae 00 00 00       	jmp    646 <printf+0x170>
      } else if(c == 's'){
 598:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 59c:	75 43                	jne    5e1 <printf+0x10b>
        s = (char*)*ap;
 59e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a1:	8b 00                	mov    (%eax),%eax
 5a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ae:	75 25                	jne    5d5 <printf+0xff>
          s = "(null)";
 5b0:	c7 45 f4 cb 08 00 00 	movl   $0x8cb,-0xc(%ebp)
        while(*s != 0){
 5b7:	eb 1c                	jmp    5d5 <printf+0xff>
          putc(fd, *s);
 5b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5bc:	0f b6 00             	movzbl (%eax),%eax
 5bf:	0f be c0             	movsbl %al,%eax
 5c2:	83 ec 08             	sub    $0x8,%esp
 5c5:	50                   	push   %eax
 5c6:	ff 75 08             	push   0x8(%ebp)
 5c9:	e8 34 fe ff ff       	call   402 <putc>
 5ce:	83 c4 10             	add    $0x10,%esp
          s++;
 5d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d8:	0f b6 00             	movzbl (%eax),%eax
 5db:	84 c0                	test   %al,%al
 5dd:	75 da                	jne    5b9 <printf+0xe3>
 5df:	eb 65                	jmp    646 <printf+0x170>
        }
      } else if(c == 'c'){
 5e1:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5e5:	75 1d                	jne    604 <printf+0x12e>
        putc(fd, *ap);
 5e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ea:	8b 00                	mov    (%eax),%eax
 5ec:	0f be c0             	movsbl %al,%eax
 5ef:	83 ec 08             	sub    $0x8,%esp
 5f2:	50                   	push   %eax
 5f3:	ff 75 08             	push   0x8(%ebp)
 5f6:	e8 07 fe ff ff       	call   402 <putc>
 5fb:	83 c4 10             	add    $0x10,%esp
        ap++;
 5fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 602:	eb 42                	jmp    646 <printf+0x170>
      } else if(c == '%'){
 604:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 608:	75 17                	jne    621 <printf+0x14b>
        putc(fd, c);
 60a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 60d:	0f be c0             	movsbl %al,%eax
 610:	83 ec 08             	sub    $0x8,%esp
 613:	50                   	push   %eax
 614:	ff 75 08             	push   0x8(%ebp)
 617:	e8 e6 fd ff ff       	call   402 <putc>
 61c:	83 c4 10             	add    $0x10,%esp
 61f:	eb 25                	jmp    646 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 621:	83 ec 08             	sub    $0x8,%esp
 624:	6a 25                	push   $0x25
 626:	ff 75 08             	push   0x8(%ebp)
 629:	e8 d4 fd ff ff       	call   402 <putc>
 62e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 631:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 634:	0f be c0             	movsbl %al,%eax
 637:	83 ec 08             	sub    $0x8,%esp
 63a:	50                   	push   %eax
 63b:	ff 75 08             	push   0x8(%ebp)
 63e:	e8 bf fd ff ff       	call   402 <putc>
 643:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 646:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 64d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 651:	8b 55 0c             	mov    0xc(%ebp),%edx
 654:	8b 45 f0             	mov    -0x10(%ebp),%eax
 657:	01 d0                	add    %edx,%eax
 659:	0f b6 00             	movzbl (%eax),%eax
 65c:	84 c0                	test   %al,%al
 65e:	0f 85 94 fe ff ff    	jne    4f8 <printf+0x22>
    }
  }
}
 664:	90                   	nop
 665:	90                   	nop
 666:	c9                   	leave  
 667:	c3                   	ret    

00000668 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 668:	55                   	push   %ebp
 669:	89 e5                	mov    %esp,%ebp
 66b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 66e:	8b 45 08             	mov    0x8(%ebp),%eax
 671:	83 e8 08             	sub    $0x8,%eax
 674:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 677:	a1 58 0b 00 00       	mov    0xb58,%eax
 67c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 67f:	eb 24                	jmp    6a5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	8b 00                	mov    (%eax),%eax
 686:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 689:	72 12                	jb     69d <free+0x35>
 68b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 691:	77 24                	ja     6b7 <free+0x4f>
 693:	8b 45 fc             	mov    -0x4(%ebp),%eax
 696:	8b 00                	mov    (%eax),%eax
 698:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 69b:	72 1a                	jb     6b7 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a0:	8b 00                	mov    (%eax),%eax
 6a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ab:	76 d4                	jbe    681 <free+0x19>
 6ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b0:	8b 00                	mov    (%eax),%eax
 6b2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6b5:	73 ca                	jae    681 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ba:	8b 40 04             	mov    0x4(%eax),%eax
 6bd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c7:	01 c2                	add    %eax,%edx
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 00                	mov    (%eax),%eax
 6ce:	39 c2                	cmp    %eax,%edx
 6d0:	75 24                	jne    6f6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d5:	8b 50 04             	mov    0x4(%eax),%edx
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	8b 00                	mov    (%eax),%eax
 6dd:	8b 40 04             	mov    0x4(%eax),%eax
 6e0:	01 c2                	add    %eax,%edx
 6e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6eb:	8b 00                	mov    (%eax),%eax
 6ed:	8b 10                	mov    (%eax),%edx
 6ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f2:	89 10                	mov    %edx,(%eax)
 6f4:	eb 0a                	jmp    700 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	8b 10                	mov    (%eax),%edx
 6fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fe:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 700:	8b 45 fc             	mov    -0x4(%ebp),%eax
 703:	8b 40 04             	mov    0x4(%eax),%eax
 706:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	01 d0                	add    %edx,%eax
 712:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 715:	75 20                	jne    737 <free+0xcf>
    p->s.size += bp->s.size;
 717:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71a:	8b 50 04             	mov    0x4(%eax),%edx
 71d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 720:	8b 40 04             	mov    0x4(%eax),%eax
 723:	01 c2                	add    %eax,%edx
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	8b 10                	mov    (%eax),%edx
 730:	8b 45 fc             	mov    -0x4(%ebp),%eax
 733:	89 10                	mov    %edx,(%eax)
 735:	eb 08                	jmp    73f <free+0xd7>
  } else
    p->s.ptr = bp;
 737:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 73d:	89 10                	mov    %edx,(%eax)
  freep = p;
 73f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 742:	a3 58 0b 00 00       	mov    %eax,0xb58
}
 747:	90                   	nop
 748:	c9                   	leave  
 749:	c3                   	ret    

0000074a <morecore>:

static Header*
morecore(uint nu)
{
 74a:	55                   	push   %ebp
 74b:	89 e5                	mov    %esp,%ebp
 74d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 750:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 757:	77 07                	ja     760 <morecore+0x16>
    nu = 4096;
 759:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 760:	8b 45 08             	mov    0x8(%ebp),%eax
 763:	c1 e0 03             	shl    $0x3,%eax
 766:	83 ec 0c             	sub    $0xc,%esp
 769:	50                   	push   %eax
 76a:	e8 4b fc ff ff       	call   3ba <sbrk>
 76f:	83 c4 10             	add    $0x10,%esp
 772:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 775:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 779:	75 07                	jne    782 <morecore+0x38>
    return 0;
 77b:	b8 00 00 00 00       	mov    $0x0,%eax
 780:	eb 26                	jmp    7a8 <morecore+0x5e>
  hp = (Header*)p;
 782:	8b 45 f4             	mov    -0xc(%ebp),%eax
 785:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 788:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78b:	8b 55 08             	mov    0x8(%ebp),%edx
 78e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 791:	8b 45 f0             	mov    -0x10(%ebp),%eax
 794:	83 c0 08             	add    $0x8,%eax
 797:	83 ec 0c             	sub    $0xc,%esp
 79a:	50                   	push   %eax
 79b:	e8 c8 fe ff ff       	call   668 <free>
 7a0:	83 c4 10             	add    $0x10,%esp
  return freep;
 7a3:	a1 58 0b 00 00       	mov    0xb58,%eax
}
 7a8:	c9                   	leave  
 7a9:	c3                   	ret    

000007aa <malloc>:

void*
malloc(uint nbytes)
{
 7aa:	55                   	push   %ebp
 7ab:	89 e5                	mov    %esp,%ebp
 7ad:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b0:	8b 45 08             	mov    0x8(%ebp),%eax
 7b3:	83 c0 07             	add    $0x7,%eax
 7b6:	c1 e8 03             	shr    $0x3,%eax
 7b9:	83 c0 01             	add    $0x1,%eax
 7bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7bf:	a1 58 0b 00 00       	mov    0xb58,%eax
 7c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7cb:	75 23                	jne    7f0 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7cd:	c7 45 f0 50 0b 00 00 	movl   $0xb50,-0x10(%ebp)
 7d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d7:	a3 58 0b 00 00       	mov    %eax,0xb58
 7dc:	a1 58 0b 00 00       	mov    0xb58,%eax
 7e1:	a3 50 0b 00 00       	mov    %eax,0xb50
    base.s.size = 0;
 7e6:	c7 05 54 0b 00 00 00 	movl   $0x0,0xb54
 7ed:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f3:	8b 00                	mov    (%eax),%eax
 7f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fb:	8b 40 04             	mov    0x4(%eax),%eax
 7fe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 801:	77 4d                	ja     850 <malloc+0xa6>
      if(p->s.size == nunits)
 803:	8b 45 f4             	mov    -0xc(%ebp),%eax
 806:	8b 40 04             	mov    0x4(%eax),%eax
 809:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 80c:	75 0c                	jne    81a <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 811:	8b 10                	mov    (%eax),%edx
 813:	8b 45 f0             	mov    -0x10(%ebp),%eax
 816:	89 10                	mov    %edx,(%eax)
 818:	eb 26                	jmp    840 <malloc+0x96>
      else {
        p->s.size -= nunits;
 81a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81d:	8b 40 04             	mov    0x4(%eax),%eax
 820:	2b 45 ec             	sub    -0x14(%ebp),%eax
 823:	89 c2                	mov    %eax,%edx
 825:	8b 45 f4             	mov    -0xc(%ebp),%eax
 828:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 82b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82e:	8b 40 04             	mov    0x4(%eax),%eax
 831:	c1 e0 03             	shl    $0x3,%eax
 834:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 837:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83a:	8b 55 ec             	mov    -0x14(%ebp),%edx
 83d:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 840:	8b 45 f0             	mov    -0x10(%ebp),%eax
 843:	a3 58 0b 00 00       	mov    %eax,0xb58
      return (void*)(p + 1);
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	83 c0 08             	add    $0x8,%eax
 84e:	eb 3b                	jmp    88b <malloc+0xe1>
    }
    if(p == freep)
 850:	a1 58 0b 00 00       	mov    0xb58,%eax
 855:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 858:	75 1e                	jne    878 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 85a:	83 ec 0c             	sub    $0xc,%esp
 85d:	ff 75 ec             	push   -0x14(%ebp)
 860:	e8 e5 fe ff ff       	call   74a <morecore>
 865:	83 c4 10             	add    $0x10,%esp
 868:	89 45 f4             	mov    %eax,-0xc(%ebp)
 86b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 86f:	75 07                	jne    878 <malloc+0xce>
        return 0;
 871:	b8 00 00 00 00       	mov    $0x0,%eax
 876:	eb 13                	jmp    88b <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 878:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 881:	8b 00                	mov    (%eax),%eax
 883:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 886:	e9 6d ff ff ff       	jmp    7f8 <malloc+0x4e>
  }
}
 88b:	c9                   	leave  
 88c:	c3                   	ret    
