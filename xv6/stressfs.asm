
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	81 ec 24 02 00 00    	sub    $0x224,%esp
  int fd, i;
  char path[] = "stressfs0";
  14:	c7 45 e6 73 74 72 65 	movl   $0x65727473,-0x1a(%ebp)
  1b:	c7 45 ea 73 73 66 73 	movl   $0x73667373,-0x16(%ebp)
  22:	66 c7 45 ee 30 00    	movw   $0x30,-0x12(%ebp)
  char data[512];

  printf(1, "stressfs starting\n");
  28:	83 ec 08             	sub    $0x8,%esp
  2b:	68 04 09 00 00       	push   $0x904
  30:	6a 01                	push   $0x1
  32:	e8 16 05 00 00       	call   54d <printf>
  37:	83 c4 10             	add    $0x10,%esp
  memset(data, 'a', sizeof(data));
  3a:	83 ec 04             	sub    $0x4,%esp
  3d:	68 00 02 00 00       	push   $0x200
  42:	6a 61                	push   $0x61
  44:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
  4a:	50                   	push   %eax
  4b:	e8 be 01 00 00       	call   20e <memset>
  50:	83 c4 10             	add    $0x10,%esp

  for(i = 0; i < 4; i++)
  53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  5a:	eb 0d                	jmp    69 <main+0x69>
    if(fork() > 0)
  5c:	e8 40 03 00 00       	call   3a1 <fork>
  61:	85 c0                	test   %eax,%eax
  63:	7f 0c                	jg     71 <main+0x71>
  for(i = 0; i < 4; i++)
  65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  69:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  6d:	7e ed                	jle    5c <main+0x5c>
  6f:	eb 01                	jmp    72 <main+0x72>
      break;
  71:	90                   	nop

  printf(1, "write %d\n", i);
  72:	83 ec 04             	sub    $0x4,%esp
  75:	ff 75 f4             	push   -0xc(%ebp)
  78:	68 17 09 00 00       	push   $0x917
  7d:	6a 01                	push   $0x1
  7f:	e8 c9 04 00 00       	call   54d <printf>
  84:	83 c4 10             	add    $0x10,%esp

  path[8] += i;
  87:	0f b6 45 ee          	movzbl -0x12(%ebp),%eax
  8b:	89 c2                	mov    %eax,%edx
  8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  90:	01 d0                	add    %edx,%eax
  92:	88 45 ee             	mov    %al,-0x12(%ebp)
  fd = open(path, O_CREATE | O_RDWR);
  95:	83 ec 08             	sub    $0x8,%esp
  98:	68 02 02 00 00       	push   $0x202
  9d:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  a0:	50                   	push   %eax
  a1:	e8 43 03 00 00       	call   3e9 <open>
  a6:	83 c4 10             	add    $0x10,%esp
  a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 20; i++)
  ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  b3:	eb 1e                	jmp    d3 <main+0xd3>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  b5:	83 ec 04             	sub    $0x4,%esp
  b8:	68 00 02 00 00       	push   $0x200
  bd:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
  c3:	50                   	push   %eax
  c4:	ff 75 f0             	push   -0x10(%ebp)
  c7:	e8 fd 02 00 00       	call   3c9 <write>
  cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 20; i++)
  cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  d3:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
  d7:	7e dc                	jle    b5 <main+0xb5>
  close(fd);
  d9:	83 ec 0c             	sub    $0xc,%esp
  dc:	ff 75 f0             	push   -0x10(%ebp)
  df:	e8 ed 02 00 00       	call   3d1 <close>
  e4:	83 c4 10             	add    $0x10,%esp

  printf(1, "read\n");
  e7:	83 ec 08             	sub    $0x8,%esp
  ea:	68 21 09 00 00       	push   $0x921
  ef:	6a 01                	push   $0x1
  f1:	e8 57 04 00 00       	call   54d <printf>
  f6:	83 c4 10             	add    $0x10,%esp

  fd = open(path, O_RDONLY);
  f9:	83 ec 08             	sub    $0x8,%esp
  fc:	6a 00                	push   $0x0
  fe:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 101:	50                   	push   %eax
 102:	e8 e2 02 00 00       	call   3e9 <open>
 107:	83 c4 10             	add    $0x10,%esp
 10a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (i = 0; i < 20; i++)
 10d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 114:	eb 1e                	jmp    134 <main+0x134>
    read(fd, data, sizeof(data));
 116:	83 ec 04             	sub    $0x4,%esp
 119:	68 00 02 00 00       	push   $0x200
 11e:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
 124:	50                   	push   %eax
 125:	ff 75 f0             	push   -0x10(%ebp)
 128:	e8 94 02 00 00       	call   3c1 <read>
 12d:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 20; i++)
 130:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 134:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
 138:	7e dc                	jle    116 <main+0x116>
  close(fd);
 13a:	83 ec 0c             	sub    $0xc,%esp
 13d:	ff 75 f0             	push   -0x10(%ebp)
 140:	e8 8c 02 00 00       	call   3d1 <close>
 145:	83 c4 10             	add    $0x10,%esp

  wait();
 148:	e8 64 02 00 00       	call   3b1 <wait>

  exit();
 14d:	e8 57 02 00 00       	call   3a9 <exit>

00000152 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 152:	55                   	push   %ebp
 153:	89 e5                	mov    %esp,%ebp
 155:	57                   	push   %edi
 156:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 157:	8b 4d 08             	mov    0x8(%ebp),%ecx
 15a:	8b 55 10             	mov    0x10(%ebp),%edx
 15d:	8b 45 0c             	mov    0xc(%ebp),%eax
 160:	89 cb                	mov    %ecx,%ebx
 162:	89 df                	mov    %ebx,%edi
 164:	89 d1                	mov    %edx,%ecx
 166:	fc                   	cld    
 167:	f3 aa                	rep stos %al,%es:(%edi)
 169:	89 ca                	mov    %ecx,%edx
 16b:	89 fb                	mov    %edi,%ebx
 16d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 170:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 173:	90                   	nop
 174:	5b                   	pop    %ebx
 175:	5f                   	pop    %edi
 176:	5d                   	pop    %ebp
 177:	c3                   	ret    

00000178 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 178:	55                   	push   %ebp
 179:	89 e5                	mov    %esp,%ebp
 17b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 17e:	8b 45 08             	mov    0x8(%ebp),%eax
 181:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 184:	90                   	nop
 185:	8b 55 0c             	mov    0xc(%ebp),%edx
 188:	8d 42 01             	lea    0x1(%edx),%eax
 18b:	89 45 0c             	mov    %eax,0xc(%ebp)
 18e:	8b 45 08             	mov    0x8(%ebp),%eax
 191:	8d 48 01             	lea    0x1(%eax),%ecx
 194:	89 4d 08             	mov    %ecx,0x8(%ebp)
 197:	0f b6 12             	movzbl (%edx),%edx
 19a:	88 10                	mov    %dl,(%eax)
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	84 c0                	test   %al,%al
 1a1:	75 e2                	jne    185 <strcpy+0xd>
    ;
  return os;
 1a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1a6:	c9                   	leave  
 1a7:	c3                   	ret    

000001a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1ab:	eb 08                	jmp    1b5 <strcmp+0xd>
    p++, q++;
 1ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1b5:	8b 45 08             	mov    0x8(%ebp),%eax
 1b8:	0f b6 00             	movzbl (%eax),%eax
 1bb:	84 c0                	test   %al,%al
 1bd:	74 10                	je     1cf <strcmp+0x27>
 1bf:	8b 45 08             	mov    0x8(%ebp),%eax
 1c2:	0f b6 10             	movzbl (%eax),%edx
 1c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c8:	0f b6 00             	movzbl (%eax),%eax
 1cb:	38 c2                	cmp    %al,%dl
 1cd:	74 de                	je     1ad <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	0f b6 00             	movzbl (%eax),%eax
 1d5:	0f b6 d0             	movzbl %al,%edx
 1d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1db:	0f b6 00             	movzbl (%eax),%eax
 1de:	0f b6 c8             	movzbl %al,%ecx
 1e1:	89 d0                	mov    %edx,%eax
 1e3:	29 c8                	sub    %ecx,%eax
}
 1e5:	5d                   	pop    %ebp
 1e6:	c3                   	ret    

000001e7 <strlen>:

uint
strlen(char *s)
{
 1e7:	55                   	push   %ebp
 1e8:	89 e5                	mov    %esp,%ebp
 1ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1f4:	eb 04                	jmp    1fa <strlen+0x13>
 1f6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	01 d0                	add    %edx,%eax
 202:	0f b6 00             	movzbl (%eax),%eax
 205:	84 c0                	test   %al,%al
 207:	75 ed                	jne    1f6 <strlen+0xf>
    ;
  return n;
 209:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 20c:	c9                   	leave  
 20d:	c3                   	ret    

0000020e <memset>:

void*
memset(void *dst, int c, uint n)
{
 20e:	55                   	push   %ebp
 20f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 211:	8b 45 10             	mov    0x10(%ebp),%eax
 214:	50                   	push   %eax
 215:	ff 75 0c             	push   0xc(%ebp)
 218:	ff 75 08             	push   0x8(%ebp)
 21b:	e8 32 ff ff ff       	call   152 <stosb>
 220:	83 c4 0c             	add    $0xc,%esp
  return dst;
 223:	8b 45 08             	mov    0x8(%ebp),%eax
}
 226:	c9                   	leave  
 227:	c3                   	ret    

00000228 <strchr>:

char*
strchr(const char *s, char c)
{
 228:	55                   	push   %ebp
 229:	89 e5                	mov    %esp,%ebp
 22b:	83 ec 04             	sub    $0x4,%esp
 22e:	8b 45 0c             	mov    0xc(%ebp),%eax
 231:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 234:	eb 14                	jmp    24a <strchr+0x22>
    if(*s == c)
 236:	8b 45 08             	mov    0x8(%ebp),%eax
 239:	0f b6 00             	movzbl (%eax),%eax
 23c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 23f:	75 05                	jne    246 <strchr+0x1e>
      return (char*)s;
 241:	8b 45 08             	mov    0x8(%ebp),%eax
 244:	eb 13                	jmp    259 <strchr+0x31>
  for(; *s; s++)
 246:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	0f b6 00             	movzbl (%eax),%eax
 250:	84 c0                	test   %al,%al
 252:	75 e2                	jne    236 <strchr+0xe>
  return 0;
 254:	b8 00 00 00 00       	mov    $0x0,%eax
}
 259:	c9                   	leave  
 25a:	c3                   	ret    

0000025b <gets>:

char*
gets(char *buf, int max)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 261:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 268:	eb 42                	jmp    2ac <gets+0x51>
    cc = read(0, &c, 1);
 26a:	83 ec 04             	sub    $0x4,%esp
 26d:	6a 01                	push   $0x1
 26f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 272:	50                   	push   %eax
 273:	6a 00                	push   $0x0
 275:	e8 47 01 00 00       	call   3c1 <read>
 27a:	83 c4 10             	add    $0x10,%esp
 27d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 280:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 284:	7e 33                	jle    2b9 <gets+0x5e>
      break;
    buf[i++] = c;
 286:	8b 45 f4             	mov    -0xc(%ebp),%eax
 289:	8d 50 01             	lea    0x1(%eax),%edx
 28c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 28f:	89 c2                	mov    %eax,%edx
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	01 c2                	add    %eax,%edx
 296:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 29a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 29c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a0:	3c 0a                	cmp    $0xa,%al
 2a2:	74 16                	je     2ba <gets+0x5f>
 2a4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a8:	3c 0d                	cmp    $0xd,%al
 2aa:	74 0e                	je     2ba <gets+0x5f>
  for(i=0; i+1 < max; ){
 2ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2af:	83 c0 01             	add    $0x1,%eax
 2b2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 2b5:	7f b3                	jg     26a <gets+0xf>
 2b7:	eb 01                	jmp    2ba <gets+0x5f>
      break;
 2b9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	01 d0                	add    %edx,%eax
 2c2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c8:	c9                   	leave  
 2c9:	c3                   	ret    

000002ca <stat>:

int
stat(char *n, struct stat *st)
{
 2ca:	55                   	push   %ebp
 2cb:	89 e5                	mov    %esp,%ebp
 2cd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d0:	83 ec 08             	sub    $0x8,%esp
 2d3:	6a 00                	push   $0x0
 2d5:	ff 75 08             	push   0x8(%ebp)
 2d8:	e8 0c 01 00 00       	call   3e9 <open>
 2dd:	83 c4 10             	add    $0x10,%esp
 2e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2e7:	79 07                	jns    2f0 <stat+0x26>
    return -1;
 2e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ee:	eb 25                	jmp    315 <stat+0x4b>
  r = fstat(fd, st);
 2f0:	83 ec 08             	sub    $0x8,%esp
 2f3:	ff 75 0c             	push   0xc(%ebp)
 2f6:	ff 75 f4             	push   -0xc(%ebp)
 2f9:	e8 03 01 00 00       	call   401 <fstat>
 2fe:	83 c4 10             	add    $0x10,%esp
 301:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 304:	83 ec 0c             	sub    $0xc,%esp
 307:	ff 75 f4             	push   -0xc(%ebp)
 30a:	e8 c2 00 00 00       	call   3d1 <close>
 30f:	83 c4 10             	add    $0x10,%esp
  return r;
 312:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 315:	c9                   	leave  
 316:	c3                   	ret    

00000317 <atoi>:

int
atoi(const char *s)
{
 317:	55                   	push   %ebp
 318:	89 e5                	mov    %esp,%ebp
 31a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 31d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 324:	eb 25                	jmp    34b <atoi+0x34>
    n = n*10 + *s++ - '0';
 326:	8b 55 fc             	mov    -0x4(%ebp),%edx
 329:	89 d0                	mov    %edx,%eax
 32b:	c1 e0 02             	shl    $0x2,%eax
 32e:	01 d0                	add    %edx,%eax
 330:	01 c0                	add    %eax,%eax
 332:	89 c1                	mov    %eax,%ecx
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	8d 50 01             	lea    0x1(%eax),%edx
 33a:	89 55 08             	mov    %edx,0x8(%ebp)
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	0f be c0             	movsbl %al,%eax
 343:	01 c8                	add    %ecx,%eax
 345:	83 e8 30             	sub    $0x30,%eax
 348:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	0f b6 00             	movzbl (%eax),%eax
 351:	3c 2f                	cmp    $0x2f,%al
 353:	7e 0a                	jle    35f <atoi+0x48>
 355:	8b 45 08             	mov    0x8(%ebp),%eax
 358:	0f b6 00             	movzbl (%eax),%eax
 35b:	3c 39                	cmp    $0x39,%al
 35d:	7e c7                	jle    326 <atoi+0xf>
  return n;
 35f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 362:	c9                   	leave  
 363:	c3                   	ret    

00000364 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
 367:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
 36d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 370:	8b 45 0c             	mov    0xc(%ebp),%eax
 373:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 376:	eb 17                	jmp    38f <memmove+0x2b>
    *dst++ = *src++;
 378:	8b 55 f8             	mov    -0x8(%ebp),%edx
 37b:	8d 42 01             	lea    0x1(%edx),%eax
 37e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 381:	8b 45 fc             	mov    -0x4(%ebp),%eax
 384:	8d 48 01             	lea    0x1(%eax),%ecx
 387:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 38a:	0f b6 12             	movzbl (%edx),%edx
 38d:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 38f:	8b 45 10             	mov    0x10(%ebp),%eax
 392:	8d 50 ff             	lea    -0x1(%eax),%edx
 395:	89 55 10             	mov    %edx,0x10(%ebp)
 398:	85 c0                	test   %eax,%eax
 39a:	7f dc                	jg     378 <memmove+0x14>
  return vdst;
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 39f:	c9                   	leave  
 3a0:	c3                   	ret    

000003a1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3a1:	b8 01 00 00 00       	mov    $0x1,%eax
 3a6:	cd 40                	int    $0x40
 3a8:	c3                   	ret    

000003a9 <exit>:
SYSCALL(exit)
 3a9:	b8 02 00 00 00       	mov    $0x2,%eax
 3ae:	cd 40                	int    $0x40
 3b0:	c3                   	ret    

000003b1 <wait>:
SYSCALL(wait)
 3b1:	b8 03 00 00 00       	mov    $0x3,%eax
 3b6:	cd 40                	int    $0x40
 3b8:	c3                   	ret    

000003b9 <pipe>:
SYSCALL(pipe)
 3b9:	b8 04 00 00 00       	mov    $0x4,%eax
 3be:	cd 40                	int    $0x40
 3c0:	c3                   	ret    

000003c1 <read>:
SYSCALL(read)
 3c1:	b8 05 00 00 00       	mov    $0x5,%eax
 3c6:	cd 40                	int    $0x40
 3c8:	c3                   	ret    

000003c9 <write>:
SYSCALL(write)
 3c9:	b8 10 00 00 00       	mov    $0x10,%eax
 3ce:	cd 40                	int    $0x40
 3d0:	c3                   	ret    

000003d1 <close>:
SYSCALL(close)
 3d1:	b8 15 00 00 00       	mov    $0x15,%eax
 3d6:	cd 40                	int    $0x40
 3d8:	c3                   	ret    

000003d9 <kill>:
SYSCALL(kill)
 3d9:	b8 06 00 00 00       	mov    $0x6,%eax
 3de:	cd 40                	int    $0x40
 3e0:	c3                   	ret    

000003e1 <exec>:
SYSCALL(exec)
 3e1:	b8 07 00 00 00       	mov    $0x7,%eax
 3e6:	cd 40                	int    $0x40
 3e8:	c3                   	ret    

000003e9 <open>:
SYSCALL(open)
 3e9:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ee:	cd 40                	int    $0x40
 3f0:	c3                   	ret    

000003f1 <mknod>:
SYSCALL(mknod)
 3f1:	b8 11 00 00 00       	mov    $0x11,%eax
 3f6:	cd 40                	int    $0x40
 3f8:	c3                   	ret    

000003f9 <unlink>:
SYSCALL(unlink)
 3f9:	b8 12 00 00 00       	mov    $0x12,%eax
 3fe:	cd 40                	int    $0x40
 400:	c3                   	ret    

00000401 <fstat>:
SYSCALL(fstat)
 401:	b8 08 00 00 00       	mov    $0x8,%eax
 406:	cd 40                	int    $0x40
 408:	c3                   	ret    

00000409 <link>:
SYSCALL(link)
 409:	b8 13 00 00 00       	mov    $0x13,%eax
 40e:	cd 40                	int    $0x40
 410:	c3                   	ret    

00000411 <mkdir>:
SYSCALL(mkdir)
 411:	b8 14 00 00 00       	mov    $0x14,%eax
 416:	cd 40                	int    $0x40
 418:	c3                   	ret    

00000419 <chdir>:
SYSCALL(chdir)
 419:	b8 09 00 00 00       	mov    $0x9,%eax
 41e:	cd 40                	int    $0x40
 420:	c3                   	ret    

00000421 <dup>:
SYSCALL(dup)
 421:	b8 0a 00 00 00       	mov    $0xa,%eax
 426:	cd 40                	int    $0x40
 428:	c3                   	ret    

00000429 <getpid>:
SYSCALL(getpid)
 429:	b8 0b 00 00 00       	mov    $0xb,%eax
 42e:	cd 40                	int    $0x40
 430:	c3                   	ret    

00000431 <sbrk>:
SYSCALL(sbrk)
 431:	b8 0c 00 00 00       	mov    $0xc,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	ret    

00000439 <sleep>:
SYSCALL(sleep)
 439:	b8 0d 00 00 00       	mov    $0xd,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	ret    

00000441 <uptime>:
SYSCALL(uptime)
 441:	b8 0e 00 00 00       	mov    $0xe,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	ret    

00000449 <uthread_init>:

SYSCALL(uthread_init)
 449:	b8 16 00 00 00       	mov    $0x16,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	ret    

00000451 <check_thread>:
SYSCALL(check_thread)
 451:	b8 17 00 00 00       	mov    $0x17,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	ret    

00000459 <getpinfo>:

SYSCALL(getpinfo)
 459:	b8 18 00 00 00       	mov    $0x18,%eax
 45e:	cd 40                	int    $0x40
 460:	c3                   	ret    

00000461 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 461:	b8 19 00 00 00       	mov    $0x19,%eax
 466:	cd 40                	int    $0x40
 468:	c3                   	ret    

00000469 <yield>:
SYSCALL(yield)
 469:	b8 1a 00 00 00       	mov    $0x1a,%eax
 46e:	cd 40                	int    $0x40
 470:	c3                   	ret    

00000471 <printpt>:

 471:	b8 1b 00 00 00       	mov    $0x1b,%eax
 476:	cd 40                	int    $0x40
 478:	c3                   	ret    

00000479 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 479:	55                   	push   %ebp
 47a:	89 e5                	mov    %esp,%ebp
 47c:	83 ec 18             	sub    $0x18,%esp
 47f:	8b 45 0c             	mov    0xc(%ebp),%eax
 482:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 485:	83 ec 04             	sub    $0x4,%esp
 488:	6a 01                	push   $0x1
 48a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 48d:	50                   	push   %eax
 48e:	ff 75 08             	push   0x8(%ebp)
 491:	e8 33 ff ff ff       	call   3c9 <write>
 496:	83 c4 10             	add    $0x10,%esp
}
 499:	90                   	nop
 49a:	c9                   	leave  
 49b:	c3                   	ret    

0000049c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 49c:	55                   	push   %ebp
 49d:	89 e5                	mov    %esp,%ebp
 49f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4a9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4ad:	74 17                	je     4c6 <printint+0x2a>
 4af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4b3:	79 11                	jns    4c6 <printint+0x2a>
    neg = 1;
 4b5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 4bf:	f7 d8                	neg    %eax
 4c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4c4:	eb 06                	jmp    4cc <printint+0x30>
  } else {
    x = xx;
 4c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d9:	ba 00 00 00 00       	mov    $0x0,%edx
 4de:	f7 f1                	div    %ecx
 4e0:	89 d1                	mov    %edx,%ecx
 4e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e5:	8d 50 01             	lea    0x1(%eax),%edx
 4e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4eb:	0f b6 91 74 0b 00 00 	movzbl 0xb74(%ecx),%edx
 4f2:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4fc:	ba 00 00 00 00       	mov    $0x0,%edx
 501:	f7 f1                	div    %ecx
 503:	89 45 ec             	mov    %eax,-0x14(%ebp)
 506:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 50a:	75 c7                	jne    4d3 <printint+0x37>
  if(neg)
 50c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 510:	74 2d                	je     53f <printint+0xa3>
    buf[i++] = '-';
 512:	8b 45 f4             	mov    -0xc(%ebp),%eax
 515:	8d 50 01             	lea    0x1(%eax),%edx
 518:	89 55 f4             	mov    %edx,-0xc(%ebp)
 51b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 520:	eb 1d                	jmp    53f <printint+0xa3>
    putc(fd, buf[i]);
 522:	8d 55 dc             	lea    -0x24(%ebp),%edx
 525:	8b 45 f4             	mov    -0xc(%ebp),%eax
 528:	01 d0                	add    %edx,%eax
 52a:	0f b6 00             	movzbl (%eax),%eax
 52d:	0f be c0             	movsbl %al,%eax
 530:	83 ec 08             	sub    $0x8,%esp
 533:	50                   	push   %eax
 534:	ff 75 08             	push   0x8(%ebp)
 537:	e8 3d ff ff ff       	call   479 <putc>
 53c:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 53f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 543:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 547:	79 d9                	jns    522 <printint+0x86>
}
 549:	90                   	nop
 54a:	90                   	nop
 54b:	c9                   	leave  
 54c:	c3                   	ret    

0000054d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 54d:	55                   	push   %ebp
 54e:	89 e5                	mov    %esp,%ebp
 550:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 553:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 55a:	8d 45 0c             	lea    0xc(%ebp),%eax
 55d:	83 c0 04             	add    $0x4,%eax
 560:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 563:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 56a:	e9 59 01 00 00       	jmp    6c8 <printf+0x17b>
    c = fmt[i] & 0xff;
 56f:	8b 55 0c             	mov    0xc(%ebp),%edx
 572:	8b 45 f0             	mov    -0x10(%ebp),%eax
 575:	01 d0                	add    %edx,%eax
 577:	0f b6 00             	movzbl (%eax),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	25 ff 00 00 00       	and    $0xff,%eax
 582:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 585:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 589:	75 2c                	jne    5b7 <printf+0x6a>
      if(c == '%'){
 58b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 58f:	75 0c                	jne    59d <printf+0x50>
        state = '%';
 591:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 598:	e9 27 01 00 00       	jmp    6c4 <printf+0x177>
      } else {
        putc(fd, c);
 59d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a0:	0f be c0             	movsbl %al,%eax
 5a3:	83 ec 08             	sub    $0x8,%esp
 5a6:	50                   	push   %eax
 5a7:	ff 75 08             	push   0x8(%ebp)
 5aa:	e8 ca fe ff ff       	call   479 <putc>
 5af:	83 c4 10             	add    $0x10,%esp
 5b2:	e9 0d 01 00 00       	jmp    6c4 <printf+0x177>
      }
    } else if(state == '%'){
 5b7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5bb:	0f 85 03 01 00 00    	jne    6c4 <printf+0x177>
      if(c == 'd'){
 5c1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5c5:	75 1e                	jne    5e5 <printf+0x98>
        printint(fd, *ap, 10, 1);
 5c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ca:	8b 00                	mov    (%eax),%eax
 5cc:	6a 01                	push   $0x1
 5ce:	6a 0a                	push   $0xa
 5d0:	50                   	push   %eax
 5d1:	ff 75 08             	push   0x8(%ebp)
 5d4:	e8 c3 fe ff ff       	call   49c <printint>
 5d9:	83 c4 10             	add    $0x10,%esp
        ap++;
 5dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e0:	e9 d8 00 00 00       	jmp    6bd <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5e5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5e9:	74 06                	je     5f1 <printf+0xa4>
 5eb:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5ef:	75 1e                	jne    60f <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f4:	8b 00                	mov    (%eax),%eax
 5f6:	6a 00                	push   $0x0
 5f8:	6a 10                	push   $0x10
 5fa:	50                   	push   %eax
 5fb:	ff 75 08             	push   0x8(%ebp)
 5fe:	e8 99 fe ff ff       	call   49c <printint>
 603:	83 c4 10             	add    $0x10,%esp
        ap++;
 606:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 60a:	e9 ae 00 00 00       	jmp    6bd <printf+0x170>
      } else if(c == 's'){
 60f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 613:	75 43                	jne    658 <printf+0x10b>
        s = (char*)*ap;
 615:	8b 45 e8             	mov    -0x18(%ebp),%eax
 618:	8b 00                	mov    (%eax),%eax
 61a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 61d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 621:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 625:	75 25                	jne    64c <printf+0xff>
          s = "(null)";
 627:	c7 45 f4 27 09 00 00 	movl   $0x927,-0xc(%ebp)
        while(*s != 0){
 62e:	eb 1c                	jmp    64c <printf+0xff>
          putc(fd, *s);
 630:	8b 45 f4             	mov    -0xc(%ebp),%eax
 633:	0f b6 00             	movzbl (%eax),%eax
 636:	0f be c0             	movsbl %al,%eax
 639:	83 ec 08             	sub    $0x8,%esp
 63c:	50                   	push   %eax
 63d:	ff 75 08             	push   0x8(%ebp)
 640:	e8 34 fe ff ff       	call   479 <putc>
 645:	83 c4 10             	add    $0x10,%esp
          s++;
 648:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 64c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64f:	0f b6 00             	movzbl (%eax),%eax
 652:	84 c0                	test   %al,%al
 654:	75 da                	jne    630 <printf+0xe3>
 656:	eb 65                	jmp    6bd <printf+0x170>
        }
      } else if(c == 'c'){
 658:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 65c:	75 1d                	jne    67b <printf+0x12e>
        putc(fd, *ap);
 65e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 661:	8b 00                	mov    (%eax),%eax
 663:	0f be c0             	movsbl %al,%eax
 666:	83 ec 08             	sub    $0x8,%esp
 669:	50                   	push   %eax
 66a:	ff 75 08             	push   0x8(%ebp)
 66d:	e8 07 fe ff ff       	call   479 <putc>
 672:	83 c4 10             	add    $0x10,%esp
        ap++;
 675:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 679:	eb 42                	jmp    6bd <printf+0x170>
      } else if(c == '%'){
 67b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 67f:	75 17                	jne    698 <printf+0x14b>
        putc(fd, c);
 681:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 684:	0f be c0             	movsbl %al,%eax
 687:	83 ec 08             	sub    $0x8,%esp
 68a:	50                   	push   %eax
 68b:	ff 75 08             	push   0x8(%ebp)
 68e:	e8 e6 fd ff ff       	call   479 <putc>
 693:	83 c4 10             	add    $0x10,%esp
 696:	eb 25                	jmp    6bd <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 698:	83 ec 08             	sub    $0x8,%esp
 69b:	6a 25                	push   $0x25
 69d:	ff 75 08             	push   0x8(%ebp)
 6a0:	e8 d4 fd ff ff       	call   479 <putc>
 6a5:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ab:	0f be c0             	movsbl %al,%eax
 6ae:	83 ec 08             	sub    $0x8,%esp
 6b1:	50                   	push   %eax
 6b2:	ff 75 08             	push   0x8(%ebp)
 6b5:	e8 bf fd ff ff       	call   479 <putc>
 6ba:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6bd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 6c4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6c8:	8b 55 0c             	mov    0xc(%ebp),%edx
 6cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ce:	01 d0                	add    %edx,%eax
 6d0:	0f b6 00             	movzbl (%eax),%eax
 6d3:	84 c0                	test   %al,%al
 6d5:	0f 85 94 fe ff ff    	jne    56f <printf+0x22>
    }
  }
}
 6db:	90                   	nop
 6dc:	90                   	nop
 6dd:	c9                   	leave  
 6de:	c3                   	ret    

000006df <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6df:	55                   	push   %ebp
 6e0:	89 e5                	mov    %esp,%ebp
 6e2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e5:	8b 45 08             	mov    0x8(%ebp),%eax
 6e8:	83 e8 08             	sub    $0x8,%eax
 6eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ee:	a1 90 0b 00 00       	mov    0xb90,%eax
 6f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f6:	eb 24                	jmp    71c <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fb:	8b 00                	mov    (%eax),%eax
 6fd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 700:	72 12                	jb     714 <free+0x35>
 702:	8b 45 f8             	mov    -0x8(%ebp),%eax
 705:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 708:	77 24                	ja     72e <free+0x4f>
 70a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70d:	8b 00                	mov    (%eax),%eax
 70f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 712:	72 1a                	jb     72e <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	8b 00                	mov    (%eax),%eax
 719:	89 45 fc             	mov    %eax,-0x4(%ebp)
 71c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 722:	76 d4                	jbe    6f8 <free+0x19>
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 72c:	73 ca                	jae    6f8 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 72e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 731:	8b 40 04             	mov    0x4(%eax),%eax
 734:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	01 c2                	add    %eax,%edx
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 00                	mov    (%eax),%eax
 745:	39 c2                	cmp    %eax,%edx
 747:	75 24                	jne    76d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 749:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74c:	8b 50 04             	mov    0x4(%eax),%edx
 74f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 752:	8b 00                	mov    (%eax),%eax
 754:	8b 40 04             	mov    0x4(%eax),%eax
 757:	01 c2                	add    %eax,%edx
 759:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 75f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 762:	8b 00                	mov    (%eax),%eax
 764:	8b 10                	mov    (%eax),%edx
 766:	8b 45 f8             	mov    -0x8(%ebp),%eax
 769:	89 10                	mov    %edx,(%eax)
 76b:	eb 0a                	jmp    777 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 76d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 770:	8b 10                	mov    (%eax),%edx
 772:	8b 45 f8             	mov    -0x8(%ebp),%eax
 775:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 40 04             	mov    0x4(%eax),%eax
 77d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 784:	8b 45 fc             	mov    -0x4(%ebp),%eax
 787:	01 d0                	add    %edx,%eax
 789:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 78c:	75 20                	jne    7ae <free+0xcf>
    p->s.size += bp->s.size;
 78e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 791:	8b 50 04             	mov    0x4(%eax),%edx
 794:	8b 45 f8             	mov    -0x8(%ebp),%eax
 797:	8b 40 04             	mov    0x4(%eax),%eax
 79a:	01 c2                	add    %eax,%edx
 79c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a5:	8b 10                	mov    (%eax),%edx
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	89 10                	mov    %edx,(%eax)
 7ac:	eb 08                	jmp    7b6 <free+0xd7>
  } else
    p->s.ptr = bp;
 7ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7b4:	89 10                	mov    %edx,(%eax)
  freep = p;
 7b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b9:	a3 90 0b 00 00       	mov    %eax,0xb90
}
 7be:	90                   	nop
 7bf:	c9                   	leave  
 7c0:	c3                   	ret    

000007c1 <morecore>:

static Header*
morecore(uint nu)
{
 7c1:	55                   	push   %ebp
 7c2:	89 e5                	mov    %esp,%ebp
 7c4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7c7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7ce:	77 07                	ja     7d7 <morecore+0x16>
    nu = 4096;
 7d0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7d7:	8b 45 08             	mov    0x8(%ebp),%eax
 7da:	c1 e0 03             	shl    $0x3,%eax
 7dd:	83 ec 0c             	sub    $0xc,%esp
 7e0:	50                   	push   %eax
 7e1:	e8 4b fc ff ff       	call   431 <sbrk>
 7e6:	83 c4 10             	add    $0x10,%esp
 7e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7ec:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7f0:	75 07                	jne    7f9 <morecore+0x38>
    return 0;
 7f2:	b8 00 00 00 00       	mov    $0x0,%eax
 7f7:	eb 26                	jmp    81f <morecore+0x5e>
  hp = (Header*)p;
 7f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 802:	8b 55 08             	mov    0x8(%ebp),%edx
 805:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 808:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80b:	83 c0 08             	add    $0x8,%eax
 80e:	83 ec 0c             	sub    $0xc,%esp
 811:	50                   	push   %eax
 812:	e8 c8 fe ff ff       	call   6df <free>
 817:	83 c4 10             	add    $0x10,%esp
  return freep;
 81a:	a1 90 0b 00 00       	mov    0xb90,%eax
}
 81f:	c9                   	leave  
 820:	c3                   	ret    

00000821 <malloc>:

void*
malloc(uint nbytes)
{
 821:	55                   	push   %ebp
 822:	89 e5                	mov    %esp,%ebp
 824:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 827:	8b 45 08             	mov    0x8(%ebp),%eax
 82a:	83 c0 07             	add    $0x7,%eax
 82d:	c1 e8 03             	shr    $0x3,%eax
 830:	83 c0 01             	add    $0x1,%eax
 833:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 836:	a1 90 0b 00 00       	mov    0xb90,%eax
 83b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 83e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 842:	75 23                	jne    867 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 844:	c7 45 f0 88 0b 00 00 	movl   $0xb88,-0x10(%ebp)
 84b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84e:	a3 90 0b 00 00       	mov    %eax,0xb90
 853:	a1 90 0b 00 00       	mov    0xb90,%eax
 858:	a3 88 0b 00 00       	mov    %eax,0xb88
    base.s.size = 0;
 85d:	c7 05 8c 0b 00 00 00 	movl   $0x0,0xb8c
 864:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 867:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86a:	8b 00                	mov    (%eax),%eax
 86c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	8b 40 04             	mov    0x4(%eax),%eax
 875:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 878:	77 4d                	ja     8c7 <malloc+0xa6>
      if(p->s.size == nunits)
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	8b 40 04             	mov    0x4(%eax),%eax
 880:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 883:	75 0c                	jne    891 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 885:	8b 45 f4             	mov    -0xc(%ebp),%eax
 888:	8b 10                	mov    (%eax),%edx
 88a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88d:	89 10                	mov    %edx,(%eax)
 88f:	eb 26                	jmp    8b7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	8b 40 04             	mov    0x4(%eax),%eax
 897:	2b 45 ec             	sub    -0x14(%ebp),%eax
 89a:	89 c2                	mov    %eax,%edx
 89c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a5:	8b 40 04             	mov    0x4(%eax),%eax
 8a8:	c1 e0 03             	shl    $0x3,%eax
 8ab:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8b4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ba:	a3 90 0b 00 00       	mov    %eax,0xb90
      return (void*)(p + 1);
 8bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c2:	83 c0 08             	add    $0x8,%eax
 8c5:	eb 3b                	jmp    902 <malloc+0xe1>
    }
    if(p == freep)
 8c7:	a1 90 0b 00 00       	mov    0xb90,%eax
 8cc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8cf:	75 1e                	jne    8ef <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8d1:	83 ec 0c             	sub    $0xc,%esp
 8d4:	ff 75 ec             	push   -0x14(%ebp)
 8d7:	e8 e5 fe ff ff       	call   7c1 <morecore>
 8dc:	83 c4 10             	add    $0x10,%esp
 8df:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e6:	75 07                	jne    8ef <malloc+0xce>
        return 0;
 8e8:	b8 00 00 00 00       	mov    $0x0,%eax
 8ed:	eb 13                	jmp    902 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f8:	8b 00                	mov    (%eax),%eax
 8fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8fd:	e9 6d ff ff ff       	jmp    86f <malloc+0x4e>
  }
}
 902:	c9                   	leave  
 903:	c3                   	ret    
