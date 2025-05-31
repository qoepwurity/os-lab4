
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int n, m;
  char *p, *q;

  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
   d:	e9 ae 00 00 00       	jmp    c0 <grep+0xc0>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    buf[m] = '\0';
  18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1b:	05 00 0e 00 00       	add    $0xe00,%eax
  20:	c6 00 00             	movb   $0x0,(%eax)
    p = buf;
  23:	c7 45 f0 00 0e 00 00 	movl   $0xe00,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  2a:	eb 44                	jmp    70 <grep+0x70>
      *q = 0;
  2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  2f:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  32:	83 ec 08             	sub    $0x8,%esp
  35:	ff 75 f0             	push   -0x10(%ebp)
  38:	ff 75 08             	push   0x8(%ebp)
  3b:	e8 91 01 00 00       	call   1d1 <match>
  40:	83 c4 10             	add    $0x10,%esp
  43:	85 c0                	test   %eax,%eax
  45:	74 20                	je     67 <grep+0x67>
        *q = '\n';
  47:	8b 45 e8             	mov    -0x18(%ebp),%eax
  4a:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  50:	83 c0 01             	add    $0x1,%eax
  53:	2b 45 f0             	sub    -0x10(%ebp),%eax
  56:	83 ec 04             	sub    $0x4,%esp
  59:	50                   	push   %eax
  5a:	ff 75 f0             	push   -0x10(%ebp)
  5d:	6a 01                	push   $0x1
  5f:	e8 40 05 00 00       	call   5a4 <write>
  64:	83 c4 10             	add    $0x10,%esp
      }
      p = q+1;
  67:	8b 45 e8             	mov    -0x18(%ebp),%eax
  6a:	83 c0 01             	add    $0x1,%eax
  6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  70:	83 ec 08             	sub    $0x8,%esp
  73:	6a 0a                	push   $0xa
  75:	ff 75 f0             	push   -0x10(%ebp)
  78:	e8 86 03 00 00       	call   403 <strchr>
  7d:	83 c4 10             	add    $0x10,%esp
  80:	89 45 e8             	mov    %eax,-0x18(%ebp)
  83:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  87:	75 a3                	jne    2c <grep+0x2c>
    }
    if(p == buf)
  89:	81 7d f0 00 0e 00 00 	cmpl   $0xe00,-0x10(%ebp)
  90:	75 07                	jne    99 <grep+0x99>
      m = 0;
  92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  9d:	7e 21                	jle    c0 <grep+0xc0>
      m -= p - buf;
  9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  a2:	2d 00 0e 00 00       	sub    $0xe00,%eax
  a7:	29 45 f4             	sub    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  aa:	83 ec 04             	sub    $0x4,%esp
  ad:	ff 75 f4             	push   -0xc(%ebp)
  b0:	ff 75 f0             	push   -0x10(%ebp)
  b3:	68 00 0e 00 00       	push   $0xe00
  b8:	e8 82 04 00 00       	call   53f <memmove>
  bd:	83 c4 10             	add    $0x10,%esp
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
  c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  c3:	b8 ff 03 00 00       	mov    $0x3ff,%eax
  c8:	29 d0                	sub    %edx,%eax
  ca:	89 c2                	mov    %eax,%edx
  cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  cf:	05 00 0e 00 00       	add    $0xe00,%eax
  d4:	83 ec 04             	sub    $0x4,%esp
  d7:	52                   	push   %edx
  d8:	50                   	push   %eax
  d9:	ff 75 0c             	push   0xc(%ebp)
  dc:	e8 bb 04 00 00       	call   59c <read>
  e1:	83 c4 10             	add    $0x10,%esp
  e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  eb:	0f 8f 21 ff ff ff    	jg     12 <grep+0x12>
    }
  }
}
  f1:	90                   	nop
  f2:	90                   	nop
  f3:	c9                   	leave  
  f4:	c3                   	ret    

000000f5 <main>:

int
main(int argc, char *argv[])
{
  f5:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  f9:	83 e4 f0             	and    $0xfffffff0,%esp
  fc:	ff 71 fc             	push   -0x4(%ecx)
  ff:	55                   	push   %ebp
 100:	89 e5                	mov    %esp,%ebp
 102:	53                   	push   %ebx
 103:	51                   	push   %ecx
 104:	83 ec 10             	sub    $0x10,%esp
 107:	89 cb                	mov    %ecx,%ebx
  int fd, i;
  char *pattern;

  if(argc <= 1){
 109:	83 3b 01             	cmpl   $0x1,(%ebx)
 10c:	7f 17                	jg     125 <main+0x30>
    printf(2, "usage: grep pattern [file ...]\n");
 10e:	83 ec 08             	sub    $0x8,%esp
 111:	68 e0 0a 00 00       	push   $0xae0
 116:	6a 02                	push   $0x2
 118:	e8 0b 06 00 00       	call   728 <printf>
 11d:	83 c4 10             	add    $0x10,%esp
    exit();
 120:	e8 5f 04 00 00       	call   584 <exit>
  }
  pattern = argv[1];
 125:	8b 43 04             	mov    0x4(%ebx),%eax
 128:	8b 40 04             	mov    0x4(%eax),%eax
 12b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(argc <= 2){
 12e:	83 3b 02             	cmpl   $0x2,(%ebx)
 131:	7f 15                	jg     148 <main+0x53>
    grep(pattern, 0);
 133:	83 ec 08             	sub    $0x8,%esp
 136:	6a 00                	push   $0x0
 138:	ff 75 f0             	push   -0x10(%ebp)
 13b:	e8 c0 fe ff ff       	call   0 <grep>
 140:	83 c4 10             	add    $0x10,%esp
    exit();
 143:	e8 3c 04 00 00       	call   584 <exit>
  }

  for(i = 2; i < argc; i++){
 148:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
 14f:	eb 74                	jmp    1c5 <main+0xd0>
    if((fd = open(argv[i], 0)) < 0){
 151:	8b 45 f4             	mov    -0xc(%ebp),%eax
 154:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 15b:	8b 43 04             	mov    0x4(%ebx),%eax
 15e:	01 d0                	add    %edx,%eax
 160:	8b 00                	mov    (%eax),%eax
 162:	83 ec 08             	sub    $0x8,%esp
 165:	6a 00                	push   $0x0
 167:	50                   	push   %eax
 168:	e8 57 04 00 00       	call   5c4 <open>
 16d:	83 c4 10             	add    $0x10,%esp
 170:	89 45 ec             	mov    %eax,-0x14(%ebp)
 173:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 177:	79 29                	jns    1a2 <main+0xad>
      printf(1, "grep: cannot open %s\n", argv[i]);
 179:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 183:	8b 43 04             	mov    0x4(%ebx),%eax
 186:	01 d0                	add    %edx,%eax
 188:	8b 00                	mov    (%eax),%eax
 18a:	83 ec 04             	sub    $0x4,%esp
 18d:	50                   	push   %eax
 18e:	68 00 0b 00 00       	push   $0xb00
 193:	6a 01                	push   $0x1
 195:	e8 8e 05 00 00       	call   728 <printf>
 19a:	83 c4 10             	add    $0x10,%esp
      exit();
 19d:	e8 e2 03 00 00       	call   584 <exit>
    }
    grep(pattern, fd);
 1a2:	83 ec 08             	sub    $0x8,%esp
 1a5:	ff 75 ec             	push   -0x14(%ebp)
 1a8:	ff 75 f0             	push   -0x10(%ebp)
 1ab:	e8 50 fe ff ff       	call   0 <grep>
 1b0:	83 c4 10             	add    $0x10,%esp
    close(fd);
 1b3:	83 ec 0c             	sub    $0xc,%esp
 1b6:	ff 75 ec             	push   -0x14(%ebp)
 1b9:	e8 ee 03 00 00       	call   5ac <close>
 1be:	83 c4 10             	add    $0x10,%esp
  for(i = 2; i < argc; i++){
 1c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c8:	3b 03                	cmp    (%ebx),%eax
 1ca:	7c 85                	jl     151 <main+0x5c>
  }
  exit();
 1cc:	e8 b3 03 00 00       	call   584 <exit>

000001d1 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 1d1:	55                   	push   %ebp
 1d2:	89 e5                	mov    %esp,%ebp
 1d4:	83 ec 08             	sub    $0x8,%esp
  if(re[0] == '^')
 1d7:	8b 45 08             	mov    0x8(%ebp),%eax
 1da:	0f b6 00             	movzbl (%eax),%eax
 1dd:	3c 5e                	cmp    $0x5e,%al
 1df:	75 17                	jne    1f8 <match+0x27>
    return matchhere(re+1, text);
 1e1:	8b 45 08             	mov    0x8(%ebp),%eax
 1e4:	83 c0 01             	add    $0x1,%eax
 1e7:	83 ec 08             	sub    $0x8,%esp
 1ea:	ff 75 0c             	push   0xc(%ebp)
 1ed:	50                   	push   %eax
 1ee:	e8 38 00 00 00       	call   22b <matchhere>
 1f3:	83 c4 10             	add    $0x10,%esp
 1f6:	eb 31                	jmp    229 <match+0x58>
  do{  // must look at empty string
    if(matchhere(re, text))
 1f8:	83 ec 08             	sub    $0x8,%esp
 1fb:	ff 75 0c             	push   0xc(%ebp)
 1fe:	ff 75 08             	push   0x8(%ebp)
 201:	e8 25 00 00 00       	call   22b <matchhere>
 206:	83 c4 10             	add    $0x10,%esp
 209:	85 c0                	test   %eax,%eax
 20b:	74 07                	je     214 <match+0x43>
      return 1;
 20d:	b8 01 00 00 00       	mov    $0x1,%eax
 212:	eb 15                	jmp    229 <match+0x58>
  }while(*text++ != '\0');
 214:	8b 45 0c             	mov    0xc(%ebp),%eax
 217:	8d 50 01             	lea    0x1(%eax),%edx
 21a:	89 55 0c             	mov    %edx,0xc(%ebp)
 21d:	0f b6 00             	movzbl (%eax),%eax
 220:	84 c0                	test   %al,%al
 222:	75 d4                	jne    1f8 <match+0x27>
  return 0;
 224:	b8 00 00 00 00       	mov    $0x0,%eax
}
 229:	c9                   	leave  
 22a:	c3                   	ret    

0000022b <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 22b:	55                   	push   %ebp
 22c:	89 e5                	mov    %esp,%ebp
 22e:	83 ec 08             	sub    $0x8,%esp
  if(re[0] == '\0')
 231:	8b 45 08             	mov    0x8(%ebp),%eax
 234:	0f b6 00             	movzbl (%eax),%eax
 237:	84 c0                	test   %al,%al
 239:	75 0a                	jne    245 <matchhere+0x1a>
    return 1;
 23b:	b8 01 00 00 00       	mov    $0x1,%eax
 240:	e9 99 00 00 00       	jmp    2de <matchhere+0xb3>
  if(re[1] == '*')
 245:	8b 45 08             	mov    0x8(%ebp),%eax
 248:	83 c0 01             	add    $0x1,%eax
 24b:	0f b6 00             	movzbl (%eax),%eax
 24e:	3c 2a                	cmp    $0x2a,%al
 250:	75 21                	jne    273 <matchhere+0x48>
    return matchstar(re[0], re+2, text);
 252:	8b 45 08             	mov    0x8(%ebp),%eax
 255:	8d 50 02             	lea    0x2(%eax),%edx
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	0f b6 00             	movzbl (%eax),%eax
 25e:	0f be c0             	movsbl %al,%eax
 261:	83 ec 04             	sub    $0x4,%esp
 264:	ff 75 0c             	push   0xc(%ebp)
 267:	52                   	push   %edx
 268:	50                   	push   %eax
 269:	e8 72 00 00 00       	call   2e0 <matchstar>
 26e:	83 c4 10             	add    $0x10,%esp
 271:	eb 6b                	jmp    2de <matchhere+0xb3>
  if(re[0] == '$' && re[1] == '\0')
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	0f b6 00             	movzbl (%eax),%eax
 279:	3c 24                	cmp    $0x24,%al
 27b:	75 1d                	jne    29a <matchhere+0x6f>
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	83 c0 01             	add    $0x1,%eax
 283:	0f b6 00             	movzbl (%eax),%eax
 286:	84 c0                	test   %al,%al
 288:	75 10                	jne    29a <matchhere+0x6f>
    return *text == '\0';
 28a:	8b 45 0c             	mov    0xc(%ebp),%eax
 28d:	0f b6 00             	movzbl (%eax),%eax
 290:	84 c0                	test   %al,%al
 292:	0f 94 c0             	sete   %al
 295:	0f b6 c0             	movzbl %al,%eax
 298:	eb 44                	jmp    2de <matchhere+0xb3>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 29a:	8b 45 0c             	mov    0xc(%ebp),%eax
 29d:	0f b6 00             	movzbl (%eax),%eax
 2a0:	84 c0                	test   %al,%al
 2a2:	74 35                	je     2d9 <matchhere+0xae>
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
 2a7:	0f b6 00             	movzbl (%eax),%eax
 2aa:	3c 2e                	cmp    $0x2e,%al
 2ac:	74 10                	je     2be <matchhere+0x93>
 2ae:	8b 45 08             	mov    0x8(%ebp),%eax
 2b1:	0f b6 10             	movzbl (%eax),%edx
 2b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b7:	0f b6 00             	movzbl (%eax),%eax
 2ba:	38 c2                	cmp    %al,%dl
 2bc:	75 1b                	jne    2d9 <matchhere+0xae>
    return matchhere(re+1, text+1);
 2be:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c1:	8d 50 01             	lea    0x1(%eax),%edx
 2c4:	8b 45 08             	mov    0x8(%ebp),%eax
 2c7:	83 c0 01             	add    $0x1,%eax
 2ca:	83 ec 08             	sub    $0x8,%esp
 2cd:	52                   	push   %edx
 2ce:	50                   	push   %eax
 2cf:	e8 57 ff ff ff       	call   22b <matchhere>
 2d4:	83 c4 10             	add    $0x10,%esp
 2d7:	eb 05                	jmp    2de <matchhere+0xb3>
  return 0;
 2d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2de:	c9                   	leave  
 2df:	c3                   	ret    

000002e0 <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 2e0:	55                   	push   %ebp
 2e1:	89 e5                	mov    %esp,%ebp
 2e3:	83 ec 08             	sub    $0x8,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 2e6:	83 ec 08             	sub    $0x8,%esp
 2e9:	ff 75 10             	push   0x10(%ebp)
 2ec:	ff 75 0c             	push   0xc(%ebp)
 2ef:	e8 37 ff ff ff       	call   22b <matchhere>
 2f4:	83 c4 10             	add    $0x10,%esp
 2f7:	85 c0                	test   %eax,%eax
 2f9:	74 07                	je     302 <matchstar+0x22>
      return 1;
 2fb:	b8 01 00 00 00       	mov    $0x1,%eax
 300:	eb 29                	jmp    32b <matchstar+0x4b>
  }while(*text!='\0' && (*text++==c || c=='.'));
 302:	8b 45 10             	mov    0x10(%ebp),%eax
 305:	0f b6 00             	movzbl (%eax),%eax
 308:	84 c0                	test   %al,%al
 30a:	74 1a                	je     326 <matchstar+0x46>
 30c:	8b 45 10             	mov    0x10(%ebp),%eax
 30f:	8d 50 01             	lea    0x1(%eax),%edx
 312:	89 55 10             	mov    %edx,0x10(%ebp)
 315:	0f b6 00             	movzbl (%eax),%eax
 318:	0f be c0             	movsbl %al,%eax
 31b:	39 45 08             	cmp    %eax,0x8(%ebp)
 31e:	74 c6                	je     2e6 <matchstar+0x6>
 320:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 324:	74 c0                	je     2e6 <matchstar+0x6>
  return 0;
 326:	b8 00 00 00 00       	mov    $0x0,%eax
}
 32b:	c9                   	leave  
 32c:	c3                   	ret    

0000032d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 32d:	55                   	push   %ebp
 32e:	89 e5                	mov    %esp,%ebp
 330:	57                   	push   %edi
 331:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 332:	8b 4d 08             	mov    0x8(%ebp),%ecx
 335:	8b 55 10             	mov    0x10(%ebp),%edx
 338:	8b 45 0c             	mov    0xc(%ebp),%eax
 33b:	89 cb                	mov    %ecx,%ebx
 33d:	89 df                	mov    %ebx,%edi
 33f:	89 d1                	mov    %edx,%ecx
 341:	fc                   	cld    
 342:	f3 aa                	rep stos %al,%es:(%edi)
 344:	89 ca                	mov    %ecx,%edx
 346:	89 fb                	mov    %edi,%ebx
 348:	89 5d 08             	mov    %ebx,0x8(%ebp)
 34b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 34e:	90                   	nop
 34f:	5b                   	pop    %ebx
 350:	5f                   	pop    %edi
 351:	5d                   	pop    %ebp
 352:	c3                   	ret    

00000353 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 353:	55                   	push   %ebp
 354:	89 e5                	mov    %esp,%ebp
 356:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 359:	8b 45 08             	mov    0x8(%ebp),%eax
 35c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 35f:	90                   	nop
 360:	8b 55 0c             	mov    0xc(%ebp),%edx
 363:	8d 42 01             	lea    0x1(%edx),%eax
 366:	89 45 0c             	mov    %eax,0xc(%ebp)
 369:	8b 45 08             	mov    0x8(%ebp),%eax
 36c:	8d 48 01             	lea    0x1(%eax),%ecx
 36f:	89 4d 08             	mov    %ecx,0x8(%ebp)
 372:	0f b6 12             	movzbl (%edx),%edx
 375:	88 10                	mov    %dl,(%eax)
 377:	0f b6 00             	movzbl (%eax),%eax
 37a:	84 c0                	test   %al,%al
 37c:	75 e2                	jne    360 <strcpy+0xd>
    ;
  return os;
 37e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 381:	c9                   	leave  
 382:	c3                   	ret    

00000383 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 386:	eb 08                	jmp    390 <strcmp+0xd>
    p++, q++;
 388:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 38c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 390:	8b 45 08             	mov    0x8(%ebp),%eax
 393:	0f b6 00             	movzbl (%eax),%eax
 396:	84 c0                	test   %al,%al
 398:	74 10                	je     3aa <strcmp+0x27>
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	0f b6 10             	movzbl (%eax),%edx
 3a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a3:	0f b6 00             	movzbl (%eax),%eax
 3a6:	38 c2                	cmp    %al,%dl
 3a8:	74 de                	je     388 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3aa:	8b 45 08             	mov    0x8(%ebp),%eax
 3ad:	0f b6 00             	movzbl (%eax),%eax
 3b0:	0f b6 d0             	movzbl %al,%edx
 3b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b6:	0f b6 00             	movzbl (%eax),%eax
 3b9:	0f b6 c8             	movzbl %al,%ecx
 3bc:	89 d0                	mov    %edx,%eax
 3be:	29 c8                	sub    %ecx,%eax
}
 3c0:	5d                   	pop    %ebp
 3c1:	c3                   	ret    

000003c2 <strlen>:

uint
strlen(char *s)
{
 3c2:	55                   	push   %ebp
 3c3:	89 e5                	mov    %esp,%ebp
 3c5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3c8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3cf:	eb 04                	jmp    3d5 <strlen+0x13>
 3d1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	01 d0                	add    %edx,%eax
 3dd:	0f b6 00             	movzbl (%eax),%eax
 3e0:	84 c0                	test   %al,%al
 3e2:	75 ed                	jne    3d1 <strlen+0xf>
    ;
  return n;
 3e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3e7:	c9                   	leave  
 3e8:	c3                   	ret    

000003e9 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3e9:	55                   	push   %ebp
 3ea:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3ec:	8b 45 10             	mov    0x10(%ebp),%eax
 3ef:	50                   	push   %eax
 3f0:	ff 75 0c             	push   0xc(%ebp)
 3f3:	ff 75 08             	push   0x8(%ebp)
 3f6:	e8 32 ff ff ff       	call   32d <stosb>
 3fb:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3fe:	8b 45 08             	mov    0x8(%ebp),%eax
}
 401:	c9                   	leave  
 402:	c3                   	ret    

00000403 <strchr>:

char*
strchr(const char *s, char c)
{
 403:	55                   	push   %ebp
 404:	89 e5                	mov    %esp,%ebp
 406:	83 ec 04             	sub    $0x4,%esp
 409:	8b 45 0c             	mov    0xc(%ebp),%eax
 40c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 40f:	eb 14                	jmp    425 <strchr+0x22>
    if(*s == c)
 411:	8b 45 08             	mov    0x8(%ebp),%eax
 414:	0f b6 00             	movzbl (%eax),%eax
 417:	38 45 fc             	cmp    %al,-0x4(%ebp)
 41a:	75 05                	jne    421 <strchr+0x1e>
      return (char*)s;
 41c:	8b 45 08             	mov    0x8(%ebp),%eax
 41f:	eb 13                	jmp    434 <strchr+0x31>
  for(; *s; s++)
 421:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 425:	8b 45 08             	mov    0x8(%ebp),%eax
 428:	0f b6 00             	movzbl (%eax),%eax
 42b:	84 c0                	test   %al,%al
 42d:	75 e2                	jne    411 <strchr+0xe>
  return 0;
 42f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 434:	c9                   	leave  
 435:	c3                   	ret    

00000436 <gets>:

char*
gets(char *buf, int max)
{
 436:	55                   	push   %ebp
 437:	89 e5                	mov    %esp,%ebp
 439:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 43c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 443:	eb 42                	jmp    487 <gets+0x51>
    cc = read(0, &c, 1);
 445:	83 ec 04             	sub    $0x4,%esp
 448:	6a 01                	push   $0x1
 44a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 44d:	50                   	push   %eax
 44e:	6a 00                	push   $0x0
 450:	e8 47 01 00 00       	call   59c <read>
 455:	83 c4 10             	add    $0x10,%esp
 458:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 45b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 45f:	7e 33                	jle    494 <gets+0x5e>
      break;
    buf[i++] = c;
 461:	8b 45 f4             	mov    -0xc(%ebp),%eax
 464:	8d 50 01             	lea    0x1(%eax),%edx
 467:	89 55 f4             	mov    %edx,-0xc(%ebp)
 46a:	89 c2                	mov    %eax,%edx
 46c:	8b 45 08             	mov    0x8(%ebp),%eax
 46f:	01 c2                	add    %eax,%edx
 471:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 475:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 477:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 47b:	3c 0a                	cmp    $0xa,%al
 47d:	74 16                	je     495 <gets+0x5f>
 47f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 483:	3c 0d                	cmp    $0xd,%al
 485:	74 0e                	je     495 <gets+0x5f>
  for(i=0; i+1 < max; ){
 487:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48a:	83 c0 01             	add    $0x1,%eax
 48d:	39 45 0c             	cmp    %eax,0xc(%ebp)
 490:	7f b3                	jg     445 <gets+0xf>
 492:	eb 01                	jmp    495 <gets+0x5f>
      break;
 494:	90                   	nop
      break;
  }
  buf[i] = '\0';
 495:	8b 55 f4             	mov    -0xc(%ebp),%edx
 498:	8b 45 08             	mov    0x8(%ebp),%eax
 49b:	01 d0                	add    %edx,%eax
 49d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4a3:	c9                   	leave  
 4a4:	c3                   	ret    

000004a5 <stat>:

int
stat(char *n, struct stat *st)
{
 4a5:	55                   	push   %ebp
 4a6:	89 e5                	mov    %esp,%ebp
 4a8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4ab:	83 ec 08             	sub    $0x8,%esp
 4ae:	6a 00                	push   $0x0
 4b0:	ff 75 08             	push   0x8(%ebp)
 4b3:	e8 0c 01 00 00       	call   5c4 <open>
 4b8:	83 c4 10             	add    $0x10,%esp
 4bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4c2:	79 07                	jns    4cb <stat+0x26>
    return -1;
 4c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4c9:	eb 25                	jmp    4f0 <stat+0x4b>
  r = fstat(fd, st);
 4cb:	83 ec 08             	sub    $0x8,%esp
 4ce:	ff 75 0c             	push   0xc(%ebp)
 4d1:	ff 75 f4             	push   -0xc(%ebp)
 4d4:	e8 03 01 00 00       	call   5dc <fstat>
 4d9:	83 c4 10             	add    $0x10,%esp
 4dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4df:	83 ec 0c             	sub    $0xc,%esp
 4e2:	ff 75 f4             	push   -0xc(%ebp)
 4e5:	e8 c2 00 00 00       	call   5ac <close>
 4ea:	83 c4 10             	add    $0x10,%esp
  return r;
 4ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4f0:	c9                   	leave  
 4f1:	c3                   	ret    

000004f2 <atoi>:

int
atoi(const char *s)
{
 4f2:	55                   	push   %ebp
 4f3:	89 e5                	mov    %esp,%ebp
 4f5:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4ff:	eb 25                	jmp    526 <atoi+0x34>
    n = n*10 + *s++ - '0';
 501:	8b 55 fc             	mov    -0x4(%ebp),%edx
 504:	89 d0                	mov    %edx,%eax
 506:	c1 e0 02             	shl    $0x2,%eax
 509:	01 d0                	add    %edx,%eax
 50b:	01 c0                	add    %eax,%eax
 50d:	89 c1                	mov    %eax,%ecx
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
 512:	8d 50 01             	lea    0x1(%eax),%edx
 515:	89 55 08             	mov    %edx,0x8(%ebp)
 518:	0f b6 00             	movzbl (%eax),%eax
 51b:	0f be c0             	movsbl %al,%eax
 51e:	01 c8                	add    %ecx,%eax
 520:	83 e8 30             	sub    $0x30,%eax
 523:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 526:	8b 45 08             	mov    0x8(%ebp),%eax
 529:	0f b6 00             	movzbl (%eax),%eax
 52c:	3c 2f                	cmp    $0x2f,%al
 52e:	7e 0a                	jle    53a <atoi+0x48>
 530:	8b 45 08             	mov    0x8(%ebp),%eax
 533:	0f b6 00             	movzbl (%eax),%eax
 536:	3c 39                	cmp    $0x39,%al
 538:	7e c7                	jle    501 <atoi+0xf>
  return n;
 53a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 53d:	c9                   	leave  
 53e:	c3                   	ret    

0000053f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 53f:	55                   	push   %ebp
 540:	89 e5                	mov    %esp,%ebp
 542:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 545:	8b 45 08             	mov    0x8(%ebp),%eax
 548:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 54b:	8b 45 0c             	mov    0xc(%ebp),%eax
 54e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 551:	eb 17                	jmp    56a <memmove+0x2b>
    *dst++ = *src++;
 553:	8b 55 f8             	mov    -0x8(%ebp),%edx
 556:	8d 42 01             	lea    0x1(%edx),%eax
 559:	89 45 f8             	mov    %eax,-0x8(%ebp)
 55c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 55f:	8d 48 01             	lea    0x1(%eax),%ecx
 562:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 565:	0f b6 12             	movzbl (%edx),%edx
 568:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 56a:	8b 45 10             	mov    0x10(%ebp),%eax
 56d:	8d 50 ff             	lea    -0x1(%eax),%edx
 570:	89 55 10             	mov    %edx,0x10(%ebp)
 573:	85 c0                	test   %eax,%eax
 575:	7f dc                	jg     553 <memmove+0x14>
  return vdst;
 577:	8b 45 08             	mov    0x8(%ebp),%eax
}
 57a:	c9                   	leave  
 57b:	c3                   	ret    

0000057c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 57c:	b8 01 00 00 00       	mov    $0x1,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <exit>:
SYSCALL(exit)
 584:	b8 02 00 00 00       	mov    $0x2,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <wait>:
SYSCALL(wait)
 58c:	b8 03 00 00 00       	mov    $0x3,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <pipe>:
SYSCALL(pipe)
 594:	b8 04 00 00 00       	mov    $0x4,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <read>:
SYSCALL(read)
 59c:	b8 05 00 00 00       	mov    $0x5,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <write>:
SYSCALL(write)
 5a4:	b8 10 00 00 00       	mov    $0x10,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <close>:
SYSCALL(close)
 5ac:	b8 15 00 00 00       	mov    $0x15,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <kill>:
SYSCALL(kill)
 5b4:	b8 06 00 00 00       	mov    $0x6,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <exec>:
SYSCALL(exec)
 5bc:	b8 07 00 00 00       	mov    $0x7,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <open>:
SYSCALL(open)
 5c4:	b8 0f 00 00 00       	mov    $0xf,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <mknod>:
SYSCALL(mknod)
 5cc:	b8 11 00 00 00       	mov    $0x11,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <unlink>:
SYSCALL(unlink)
 5d4:	b8 12 00 00 00       	mov    $0x12,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <fstat>:
SYSCALL(fstat)
 5dc:	b8 08 00 00 00       	mov    $0x8,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <link>:
SYSCALL(link)
 5e4:	b8 13 00 00 00       	mov    $0x13,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <mkdir>:
SYSCALL(mkdir)
 5ec:	b8 14 00 00 00       	mov    $0x14,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <chdir>:
SYSCALL(chdir)
 5f4:	b8 09 00 00 00       	mov    $0x9,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <dup>:
SYSCALL(dup)
 5fc:	b8 0a 00 00 00       	mov    $0xa,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <getpid>:
SYSCALL(getpid)
 604:	b8 0b 00 00 00       	mov    $0xb,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <sbrk>:
SYSCALL(sbrk)
 60c:	b8 0c 00 00 00       	mov    $0xc,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <sleep>:
SYSCALL(sleep)
 614:	b8 0d 00 00 00       	mov    $0xd,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <uptime>:
SYSCALL(uptime)
 61c:	b8 0e 00 00 00       	mov    $0xe,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <uthread_init>:

SYSCALL(uthread_init)
 624:	b8 16 00 00 00       	mov    $0x16,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <check_thread>:
SYSCALL(check_thread)
 62c:	b8 17 00 00 00       	mov    $0x17,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <getpinfo>:

SYSCALL(getpinfo)
 634:	b8 18 00 00 00       	mov    $0x18,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 63c:	b8 19 00 00 00       	mov    $0x19,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <yield>:
SYSCALL(yield)
 644:	b8 1a 00 00 00       	mov    $0x1a,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <printpt>:

 64c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 654:	55                   	push   %ebp
 655:	89 e5                	mov    %esp,%ebp
 657:	83 ec 18             	sub    $0x18,%esp
 65a:	8b 45 0c             	mov    0xc(%ebp),%eax
 65d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 660:	83 ec 04             	sub    $0x4,%esp
 663:	6a 01                	push   $0x1
 665:	8d 45 f4             	lea    -0xc(%ebp),%eax
 668:	50                   	push   %eax
 669:	ff 75 08             	push   0x8(%ebp)
 66c:	e8 33 ff ff ff       	call   5a4 <write>
 671:	83 c4 10             	add    $0x10,%esp
}
 674:	90                   	nop
 675:	c9                   	leave  
 676:	c3                   	ret    

00000677 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 677:	55                   	push   %ebp
 678:	89 e5                	mov    %esp,%ebp
 67a:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 67d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 684:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 688:	74 17                	je     6a1 <printint+0x2a>
 68a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 68e:	79 11                	jns    6a1 <printint+0x2a>
    neg = 1;
 690:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 697:	8b 45 0c             	mov    0xc(%ebp),%eax
 69a:	f7 d8                	neg    %eax
 69c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 69f:	eb 06                	jmp    6a7 <printint+0x30>
  } else {
    x = xx;
 6a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b4:	ba 00 00 00 00       	mov    $0x0,%edx
 6b9:	f7 f1                	div    %ecx
 6bb:	89 d1                	mov    %edx,%ecx
 6bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c0:	8d 50 01             	lea    0x1(%eax),%edx
 6c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6c6:	0f b6 91 e8 0d 00 00 	movzbl 0xde8(%ecx),%edx
 6cd:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d7:	ba 00 00 00 00       	mov    $0x0,%edx
 6dc:	f7 f1                	div    %ecx
 6de:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6e1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e5:	75 c7                	jne    6ae <printint+0x37>
  if(neg)
 6e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6eb:	74 2d                	je     71a <printint+0xa3>
    buf[i++] = '-';
 6ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f0:	8d 50 01             	lea    0x1(%eax),%edx
 6f3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6f6:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6fb:	eb 1d                	jmp    71a <printint+0xa3>
    putc(fd, buf[i]);
 6fd:	8d 55 dc             	lea    -0x24(%ebp),%edx
 700:	8b 45 f4             	mov    -0xc(%ebp),%eax
 703:	01 d0                	add    %edx,%eax
 705:	0f b6 00             	movzbl (%eax),%eax
 708:	0f be c0             	movsbl %al,%eax
 70b:	83 ec 08             	sub    $0x8,%esp
 70e:	50                   	push   %eax
 70f:	ff 75 08             	push   0x8(%ebp)
 712:	e8 3d ff ff ff       	call   654 <putc>
 717:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 71a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 71e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 722:	79 d9                	jns    6fd <printint+0x86>
}
 724:	90                   	nop
 725:	90                   	nop
 726:	c9                   	leave  
 727:	c3                   	ret    

00000728 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 728:	55                   	push   %ebp
 729:	89 e5                	mov    %esp,%ebp
 72b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 72e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 735:	8d 45 0c             	lea    0xc(%ebp),%eax
 738:	83 c0 04             	add    $0x4,%eax
 73b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 73e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 745:	e9 59 01 00 00       	jmp    8a3 <printf+0x17b>
    c = fmt[i] & 0xff;
 74a:	8b 55 0c             	mov    0xc(%ebp),%edx
 74d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 750:	01 d0                	add    %edx,%eax
 752:	0f b6 00             	movzbl (%eax),%eax
 755:	0f be c0             	movsbl %al,%eax
 758:	25 ff 00 00 00       	and    $0xff,%eax
 75d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 760:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 764:	75 2c                	jne    792 <printf+0x6a>
      if(c == '%'){
 766:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 76a:	75 0c                	jne    778 <printf+0x50>
        state = '%';
 76c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 773:	e9 27 01 00 00       	jmp    89f <printf+0x177>
      } else {
        putc(fd, c);
 778:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77b:	0f be c0             	movsbl %al,%eax
 77e:	83 ec 08             	sub    $0x8,%esp
 781:	50                   	push   %eax
 782:	ff 75 08             	push   0x8(%ebp)
 785:	e8 ca fe ff ff       	call   654 <putc>
 78a:	83 c4 10             	add    $0x10,%esp
 78d:	e9 0d 01 00 00       	jmp    89f <printf+0x177>
      }
    } else if(state == '%'){
 792:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 796:	0f 85 03 01 00 00    	jne    89f <printf+0x177>
      if(c == 'd'){
 79c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7a0:	75 1e                	jne    7c0 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a5:	8b 00                	mov    (%eax),%eax
 7a7:	6a 01                	push   $0x1
 7a9:	6a 0a                	push   $0xa
 7ab:	50                   	push   %eax
 7ac:	ff 75 08             	push   0x8(%ebp)
 7af:	e8 c3 fe ff ff       	call   677 <printint>
 7b4:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7bb:	e9 d8 00 00 00       	jmp    898 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7c0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7c4:	74 06                	je     7cc <printf+0xa4>
 7c6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7ca:	75 1e                	jne    7ea <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cf:	8b 00                	mov    (%eax),%eax
 7d1:	6a 00                	push   $0x0
 7d3:	6a 10                	push   $0x10
 7d5:	50                   	push   %eax
 7d6:	ff 75 08             	push   0x8(%ebp)
 7d9:	e8 99 fe ff ff       	call   677 <printint>
 7de:	83 c4 10             	add    $0x10,%esp
        ap++;
 7e1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e5:	e9 ae 00 00 00       	jmp    898 <printf+0x170>
      } else if(c == 's'){
 7ea:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7ee:	75 43                	jne    833 <printf+0x10b>
        s = (char*)*ap;
 7f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f3:	8b 00                	mov    (%eax),%eax
 7f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7f8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 800:	75 25                	jne    827 <printf+0xff>
          s = "(null)";
 802:	c7 45 f4 16 0b 00 00 	movl   $0xb16,-0xc(%ebp)
        while(*s != 0){
 809:	eb 1c                	jmp    827 <printf+0xff>
          putc(fd, *s);
 80b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80e:	0f b6 00             	movzbl (%eax),%eax
 811:	0f be c0             	movsbl %al,%eax
 814:	83 ec 08             	sub    $0x8,%esp
 817:	50                   	push   %eax
 818:	ff 75 08             	push   0x8(%ebp)
 81b:	e8 34 fe ff ff       	call   654 <putc>
 820:	83 c4 10             	add    $0x10,%esp
          s++;
 823:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 827:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82a:	0f b6 00             	movzbl (%eax),%eax
 82d:	84 c0                	test   %al,%al
 82f:	75 da                	jne    80b <printf+0xe3>
 831:	eb 65                	jmp    898 <printf+0x170>
        }
      } else if(c == 'c'){
 833:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 837:	75 1d                	jne    856 <printf+0x12e>
        putc(fd, *ap);
 839:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83c:	8b 00                	mov    (%eax),%eax
 83e:	0f be c0             	movsbl %al,%eax
 841:	83 ec 08             	sub    $0x8,%esp
 844:	50                   	push   %eax
 845:	ff 75 08             	push   0x8(%ebp)
 848:	e8 07 fe ff ff       	call   654 <putc>
 84d:	83 c4 10             	add    $0x10,%esp
        ap++;
 850:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 854:	eb 42                	jmp    898 <printf+0x170>
      } else if(c == '%'){
 856:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 85a:	75 17                	jne    873 <printf+0x14b>
        putc(fd, c);
 85c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 85f:	0f be c0             	movsbl %al,%eax
 862:	83 ec 08             	sub    $0x8,%esp
 865:	50                   	push   %eax
 866:	ff 75 08             	push   0x8(%ebp)
 869:	e8 e6 fd ff ff       	call   654 <putc>
 86e:	83 c4 10             	add    $0x10,%esp
 871:	eb 25                	jmp    898 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 873:	83 ec 08             	sub    $0x8,%esp
 876:	6a 25                	push   $0x25
 878:	ff 75 08             	push   0x8(%ebp)
 87b:	e8 d4 fd ff ff       	call   654 <putc>
 880:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 883:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 886:	0f be c0             	movsbl %al,%eax
 889:	83 ec 08             	sub    $0x8,%esp
 88c:	50                   	push   %eax
 88d:	ff 75 08             	push   0x8(%ebp)
 890:	e8 bf fd ff ff       	call   654 <putc>
 895:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 898:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 89f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8a3:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a9:	01 d0                	add    %edx,%eax
 8ab:	0f b6 00             	movzbl (%eax),%eax
 8ae:	84 c0                	test   %al,%al
 8b0:	0f 85 94 fe ff ff    	jne    74a <printf+0x22>
    }
  }
}
 8b6:	90                   	nop
 8b7:	90                   	nop
 8b8:	c9                   	leave  
 8b9:	c3                   	ret    

000008ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ba:	55                   	push   %ebp
 8bb:	89 e5                	mov    %esp,%ebp
 8bd:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8c0:	8b 45 08             	mov    0x8(%ebp),%eax
 8c3:	83 e8 08             	sub    $0x8,%eax
 8c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c9:	a1 08 12 00 00       	mov    0x1208,%eax
 8ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8d1:	eb 24                	jmp    8f7 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d6:	8b 00                	mov    (%eax),%eax
 8d8:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8db:	72 12                	jb     8ef <free+0x35>
 8dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e3:	77 24                	ja     909 <free+0x4f>
 8e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e8:	8b 00                	mov    (%eax),%eax
 8ea:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8ed:	72 1a                	jb     909 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f2:	8b 00                	mov    (%eax),%eax
 8f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8fd:	76 d4                	jbe    8d3 <free+0x19>
 8ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 902:	8b 00                	mov    (%eax),%eax
 904:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 907:	73 ca                	jae    8d3 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 909:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90c:	8b 40 04             	mov    0x4(%eax),%eax
 90f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 916:	8b 45 f8             	mov    -0x8(%ebp),%eax
 919:	01 c2                	add    %eax,%edx
 91b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91e:	8b 00                	mov    (%eax),%eax
 920:	39 c2                	cmp    %eax,%edx
 922:	75 24                	jne    948 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 924:	8b 45 f8             	mov    -0x8(%ebp),%eax
 927:	8b 50 04             	mov    0x4(%eax),%edx
 92a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92d:	8b 00                	mov    (%eax),%eax
 92f:	8b 40 04             	mov    0x4(%eax),%eax
 932:	01 c2                	add    %eax,%edx
 934:	8b 45 f8             	mov    -0x8(%ebp),%eax
 937:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 93a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93d:	8b 00                	mov    (%eax),%eax
 93f:	8b 10                	mov    (%eax),%edx
 941:	8b 45 f8             	mov    -0x8(%ebp),%eax
 944:	89 10                	mov    %edx,(%eax)
 946:	eb 0a                	jmp    952 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 948:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94b:	8b 10                	mov    (%eax),%edx
 94d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 950:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 952:	8b 45 fc             	mov    -0x4(%ebp),%eax
 955:	8b 40 04             	mov    0x4(%eax),%eax
 958:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 95f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 962:	01 d0                	add    %edx,%eax
 964:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 967:	75 20                	jne    989 <free+0xcf>
    p->s.size += bp->s.size;
 969:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96c:	8b 50 04             	mov    0x4(%eax),%edx
 96f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 972:	8b 40 04             	mov    0x4(%eax),%eax
 975:	01 c2                	add    %eax,%edx
 977:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 97d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 980:	8b 10                	mov    (%eax),%edx
 982:	8b 45 fc             	mov    -0x4(%ebp),%eax
 985:	89 10                	mov    %edx,(%eax)
 987:	eb 08                	jmp    991 <free+0xd7>
  } else
    p->s.ptr = bp;
 989:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 98f:	89 10                	mov    %edx,(%eax)
  freep = p;
 991:	8b 45 fc             	mov    -0x4(%ebp),%eax
 994:	a3 08 12 00 00       	mov    %eax,0x1208
}
 999:	90                   	nop
 99a:	c9                   	leave  
 99b:	c3                   	ret    

0000099c <morecore>:

static Header*
morecore(uint nu)
{
 99c:	55                   	push   %ebp
 99d:	89 e5                	mov    %esp,%ebp
 99f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9a2:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9a9:	77 07                	ja     9b2 <morecore+0x16>
    nu = 4096;
 9ab:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9b2:	8b 45 08             	mov    0x8(%ebp),%eax
 9b5:	c1 e0 03             	shl    $0x3,%eax
 9b8:	83 ec 0c             	sub    $0xc,%esp
 9bb:	50                   	push   %eax
 9bc:	e8 4b fc ff ff       	call   60c <sbrk>
 9c1:	83 c4 10             	add    $0x10,%esp
 9c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9c7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9cb:	75 07                	jne    9d4 <morecore+0x38>
    return 0;
 9cd:	b8 00 00 00 00       	mov    $0x0,%eax
 9d2:	eb 26                	jmp    9fa <morecore+0x5e>
  hp = (Header*)p;
 9d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9dd:	8b 55 08             	mov    0x8(%ebp),%edx
 9e0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e6:	83 c0 08             	add    $0x8,%eax
 9e9:	83 ec 0c             	sub    $0xc,%esp
 9ec:	50                   	push   %eax
 9ed:	e8 c8 fe ff ff       	call   8ba <free>
 9f2:	83 c4 10             	add    $0x10,%esp
  return freep;
 9f5:	a1 08 12 00 00       	mov    0x1208,%eax
}
 9fa:	c9                   	leave  
 9fb:	c3                   	ret    

000009fc <malloc>:

void*
malloc(uint nbytes)
{
 9fc:	55                   	push   %ebp
 9fd:	89 e5                	mov    %esp,%ebp
 9ff:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a02:	8b 45 08             	mov    0x8(%ebp),%eax
 a05:	83 c0 07             	add    $0x7,%eax
 a08:	c1 e8 03             	shr    $0x3,%eax
 a0b:	83 c0 01             	add    $0x1,%eax
 a0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a11:	a1 08 12 00 00       	mov    0x1208,%eax
 a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a1d:	75 23                	jne    a42 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a1f:	c7 45 f0 00 12 00 00 	movl   $0x1200,-0x10(%ebp)
 a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a29:	a3 08 12 00 00       	mov    %eax,0x1208
 a2e:	a1 08 12 00 00       	mov    0x1208,%eax
 a33:	a3 00 12 00 00       	mov    %eax,0x1200
    base.s.size = 0;
 a38:	c7 05 04 12 00 00 00 	movl   $0x0,0x1204
 a3f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a45:	8b 00                	mov    (%eax),%eax
 a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4d:	8b 40 04             	mov    0x4(%eax),%eax
 a50:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a53:	77 4d                	ja     aa2 <malloc+0xa6>
      if(p->s.size == nunits)
 a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a58:	8b 40 04             	mov    0x4(%eax),%eax
 a5b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a5e:	75 0c                	jne    a6c <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a63:	8b 10                	mov    (%eax),%edx
 a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a68:	89 10                	mov    %edx,(%eax)
 a6a:	eb 26                	jmp    a92 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6f:	8b 40 04             	mov    0x4(%eax),%eax
 a72:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a75:	89 c2                	mov    %eax,%edx
 a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a80:	8b 40 04             	mov    0x4(%eax),%eax
 a83:	c1 e0 03             	shl    $0x3,%eax
 a86:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a8f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a95:	a3 08 12 00 00       	mov    %eax,0x1208
      return (void*)(p + 1);
 a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9d:	83 c0 08             	add    $0x8,%eax
 aa0:	eb 3b                	jmp    add <malloc+0xe1>
    }
    if(p == freep)
 aa2:	a1 08 12 00 00       	mov    0x1208,%eax
 aa7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 aaa:	75 1e                	jne    aca <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 aac:	83 ec 0c             	sub    $0xc,%esp
 aaf:	ff 75 ec             	push   -0x14(%ebp)
 ab2:	e8 e5 fe ff ff       	call   99c <morecore>
 ab7:	83 c4 10             	add    $0x10,%esp
 aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
 abd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ac1:	75 07                	jne    aca <malloc+0xce>
        return 0;
 ac3:	b8 00 00 00 00       	mov    $0x0,%eax
 ac8:	eb 13                	jmp    add <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad3:	8b 00                	mov    (%eax),%eax
 ad5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ad8:	e9 6d ff ff ff       	jmp    a4a <malloc+0x4e>
  }
}
 add:	c9                   	leave  
 ade:	c3                   	ret    
