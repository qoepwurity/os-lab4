
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
extern int thread_inc(void);
extern int thread_dec(void);

void 
thread_init(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  uthread_init((int)thread_schedule);
   6:	b8 33 00 00 00       	mov    $0x33,%eax
   b:	83 ec 0c             	sub    $0xc,%esp
   e:	50                   	push   %eax
   f:	e8 81 05 00 00       	call   595 <uthread_init>
  14:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  17:	c7 05 a0 0d 00 00 c0 	movl   $0xdc0,0xda0
  1e:	0d 00 00 
  current_thread->state = RUNNING;
  21:	a1 a0 0d 00 00       	mov    0xda0,%eax
  26:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  2d:	00 00 00 
}
  30:	90                   	nop
  31:	c9                   	leave  
  32:	c3                   	ret    

00000033 <thread_schedule>:

void 
thread_schedule(void)
{
  33:	55                   	push   %ebp
  34:	89 e5                	mov    %esp,%ebp
  36:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
  39:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
  40:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  43:	c7 45 f4 c0 0d 00 00 	movl   $0xdc0,-0xc(%ebp)
  4a:	eb 29                	jmp    75 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4f:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  55:	83 f8 02             	cmp    $0x2,%eax
  58:	75 14                	jne    6e <thread_schedule+0x3b>
  5a:	a1 a0 0d 00 00       	mov    0xda0,%eax
  5f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  62:	74 0a                	je     6e <thread_schedule+0x3b>
      next_thread = t;
  64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  67:	a3 a4 0d 00 00       	mov    %eax,0xda4
      break;
  6c:	eb 11                	jmp    7f <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  6e:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  75:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  7a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  7d:	72 cd                	jb     4c <thread_schedule+0x19>
    }
  }
  
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  7f:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  84:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  87:	72 1a                	jb     a3 <thread_schedule+0x70>
  89:	a1 a0 0d 00 00       	mov    0xda0,%eax
  8e:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  94:	83 f8 02             	cmp    $0x2,%eax
  97:	75 0a                	jne    a3 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  99:	a1 a0 0d 00 00       	mov    0xda0,%eax
  9e:	a3 a4 0d 00 00       	mov    %eax,0xda4
  }

  if (next_thread == 0) {
  a3:	a1 a4 0d 00 00       	mov    0xda4,%eax
  a8:	85 c0                	test   %eax,%eax
  aa:	75 17                	jne    c3 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  ac:	83 ec 08             	sub    $0x8,%esp
  af:	68 38 0a 00 00       	push   $0xa38
  b4:	6a 02                	push   $0x2
  b6:	e8 c6 05 00 00       	call   681 <printf>
  bb:	83 c4 10             	add    $0x10,%esp
    exit();
  be:	e8 32 04 00 00       	call   4f5 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  c3:	8b 15 a0 0d 00 00    	mov    0xda0,%edx
  c9:	a1 a4 0d 00 00       	mov    0xda4,%eax
  ce:	39 c2                	cmp    %eax,%edx
  d0:	74 41                	je     113 <thread_schedule+0xe0>
    next_thread->state = RUNNING;
  d2:	a1 a4 0d 00 00       	mov    0xda4,%eax
  d7:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  de:	00 00 00 
    if(current_thread != &all_thread[0]&&current_thread->state==RUNNING){
  e1:	a1 a0 0d 00 00       	mov    0xda0,%eax
  e6:	3d c0 0d 00 00       	cmp    $0xdc0,%eax
  eb:	74 1f                	je     10c <thread_schedule+0xd9>
  ed:	a1 a0 0d 00 00       	mov    0xda0,%eax
  f2:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  f8:	83 f8 01             	cmp    $0x1,%eax
  fb:	75 0f                	jne    10c <thread_schedule+0xd9>
      current_thread->state=RUNNABLE;
  fd:	a1 a0 0d 00 00       	mov    0xda0,%eax
 102:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 109:	00 00 00 
    }  
    thread_switch();
 10c:	e8 5c 01 00 00       	call   26d <thread_switch>
  } else
    next_thread = 0;
}
 111:	eb 0a                	jmp    11d <thread_schedule+0xea>
    next_thread = 0;
 113:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
 11a:	00 00 00 
}
 11d:	90                   	nop
 11e:	c9                   	leave  
 11f:	c3                   	ret    

00000120 <thread_create>:

void 
thread_create(void (*func)())
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 126:	c7 45 f4 c0 0d 00 00 	movl   $0xdc0,-0xc(%ebp)
 12d:	eb 14                	jmp    143 <thread_create+0x23>
    if (t->state == FREE) break;
 12f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 132:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 138:	85 c0                	test   %eax,%eax
 13a:	74 13                	je     14f <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 13c:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 143:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
 148:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 14b:	72 e2                	jb     12f <thread_create+0xf>
 14d:	eb 01                	jmp    150 <thread_create+0x30>
    if (t->state == FREE) break;
 14f:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 150:	8b 45 f4             	mov    -0xc(%ebp),%eax
 153:	83 c0 04             	add    $0x4,%eax
 156:	05 00 20 00 00       	add    $0x2000,%eax
 15b:	89 c2                	mov    %eax,%edx
 15d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 160:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 162:	8b 45 f4             	mov    -0xc(%ebp),%eax
 165:	8b 00                	mov    (%eax),%eax
 167:	8d 50 fc             	lea    -0x4(%eax),%edx
 16a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16d:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 16f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 172:	8b 00                	mov    (%eax),%eax
 174:	89 c2                	mov    %eax,%edx
 176:	8b 45 08             	mov    0x8(%ebp),%eax
 179:	89 02                	mov    %eax,(%edx)
  t->sp -= 28;                             // space for registers that thread_switch expects
 17b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17e:	8b 00                	mov    (%eax),%eax
 180:	8d 50 e4             	lea    -0x1c(%eax),%edx
 183:	8b 45 f4             	mov    -0xc(%ebp),%eax
 186:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;  
 188:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18b:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 192:	00 00 00 
  thread_inc();
 195:	e8 03 04 00 00       	call   59d <thread_inc>
  printf(1, "*sp = 0x%x\n", * (int *) (t->sp));
 19a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19d:	8b 00                	mov    (%eax),%eax
 19f:	8b 00                	mov    (%eax),%eax
 1a1:	83 ec 04             	sub    $0x4,%esp
 1a4:	50                   	push   %eax
 1a5:	68 5e 0a 00 00       	push   $0xa5e
 1aa:	6a 01                	push   $0x1
 1ac:	e8 d0 04 00 00       	call   681 <printf>
 1b1:	83 c4 10             	add    $0x10,%esp
}
 1b4:	90                   	nop
 1b5:	c9                   	leave  
 1b6:	c3                   	ret    

000001b7 <mythread>:

static void 
mythread(void)
{
 1b7:	55                   	push   %ebp
 1b8:	89 e5                	mov    %esp,%ebp
 1ba:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1bd:	83 ec 08             	sub    $0x8,%esp
 1c0:	68 6a 0a 00 00       	push   $0xa6a
 1c5:	6a 01                	push   $0x1
 1c7:	e8 b5 04 00 00       	call   681 <printf>
 1cc:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1d6:	eb 1c                	jmp    1f4 <mythread+0x3d>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 1d8:	a1 a0 0d 00 00       	mov    0xda0,%eax
 1dd:	83 ec 04             	sub    $0x4,%esp
 1e0:	50                   	push   %eax
 1e1:	68 7d 0a 00 00       	push   $0xa7d
 1e6:	6a 01                	push   $0x1
 1e8:	e8 94 04 00 00       	call   681 <printf>
 1ed:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1f4:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1f8:	7e de                	jle    1d8 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 1fa:	83 ec 08             	sub    $0x8,%esp
 1fd:	68 8d 0a 00 00       	push   $0xa8d
 202:	6a 01                	push   $0x1
 204:	e8 78 04 00 00       	call   681 <printf>
 209:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 20c:	a1 a0 0d 00 00       	mov    0xda0,%eax
 211:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 218:	00 00 00 
  thread_dec();
 21b:	e8 85 03 00 00       	call   5a5 <thread_dec>
  thread_schedule();
 220:	e8 0e fe ff ff       	call   33 <thread_schedule>

00000225 <main>:
}


int 
main(int argc, char *argv[]) 
{
 225:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 229:	83 e4 f0             	and    $0xfffffff0,%esp
 22c:	ff 71 fc             	push   -0x4(%ecx)
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	51                   	push   %ecx
 233:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 236:	e8 c5 fd ff ff       	call   0 <thread_init>
  thread_create(mythread);
 23b:	83 ec 0c             	sub    $0xc,%esp
 23e:	68 b7 01 00 00       	push   $0x1b7
 243:	e8 d8 fe ff ff       	call   120 <thread_create>
 248:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 24b:	83 ec 0c             	sub    $0xc,%esp
 24e:	68 b7 01 00 00       	push   $0x1b7
 253:	e8 c8 fe ff ff       	call   120 <thread_create>
 258:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 25b:	e8 d3 fd ff ff       	call   33 <thread_schedule>
  return 0;
 260:	b8 00 00 00 00       	mov    $0x0,%eax
}
 265:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 268:	c9                   	leave  
 269:	8d 61 fc             	lea    -0x4(%ecx),%esp
 26c:	c3                   	ret    

0000026d <thread_switch>:
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	push %eax
 26d:	50                   	push   %eax
	push %ebx
 26e:	53                   	push   %ebx
	push %ecx
 26f:	51                   	push   %ecx
	push %edx
 270:	52                   	push   %edx
	push %ebp
 271:	55                   	push   %ebp
    push %esi
 272:	56                   	push   %esi
    push %edi
 273:	57                   	push   %edi

	movl current_thread, %eax
 274:	a1 a0 0d 00 00       	mov    0xda0,%eax
	movl %esp, (%eax)
 279:	89 20                	mov    %esp,(%eax)

	movl next_thread, %eax      # eax = next_thread  현재 실행 중인 스레드 구조체의 주소를 eax에 저장
 27b:	a1 a4 0d 00 00       	mov    0xda4,%eax
    movl (%eax), %esp           # esp = next_thread->sp 현재 실행 중인 스레드의 현
 280:	8b 20                	mov    (%eax),%esp

    movl next_thread, %eax
 282:	a1 a4 0d 00 00       	mov    0xda4,%eax
    movl %eax, current_thread   # current_thread = next_thread
 287:	a3 a0 0d 00 00       	mov    %eax,0xda0

    pop %edi
 28c:	5f                   	pop    %edi
    pop %esi
 28d:	5e                   	pop    %esi
    pop %ebp 
 28e:	5d                   	pop    %ebp
    pop %ebx
 28f:	5b                   	pop    %ebx
    pop %edx
 290:	5a                   	pop    %edx
    pop %ecx
 291:	59                   	pop    %ecx
    pop %eax
 292:	58                   	pop    %eax

	movl $0, next_thread 
 293:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
 29a:	00 00 00 
	
	ret    /* return to ra */
 29d:	c3                   	ret    

0000029e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 29e:	55                   	push   %ebp
 29f:	89 e5                	mov    %esp,%ebp
 2a1:	57                   	push   %edi
 2a2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2a6:	8b 55 10             	mov    0x10(%ebp),%edx
 2a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ac:	89 cb                	mov    %ecx,%ebx
 2ae:	89 df                	mov    %ebx,%edi
 2b0:	89 d1                	mov    %edx,%ecx
 2b2:	fc                   	cld    
 2b3:	f3 aa                	rep stos %al,%es:(%edi)
 2b5:	89 ca                	mov    %ecx,%edx
 2b7:	89 fb                	mov    %edi,%ebx
 2b9:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2bc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2bf:	90                   	nop
 2c0:	5b                   	pop    %ebx
 2c1:	5f                   	pop    %edi
 2c2:	5d                   	pop    %ebp
 2c3:	c3                   	ret    

000002c4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2c4:	55                   	push   %ebp
 2c5:	89 e5                	mov    %esp,%ebp
 2c7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2ca:	8b 45 08             	mov    0x8(%ebp),%eax
 2cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2d0:	90                   	nop
 2d1:	8b 55 0c             	mov    0xc(%ebp),%edx
 2d4:	8d 42 01             	lea    0x1(%edx),%eax
 2d7:	89 45 0c             	mov    %eax,0xc(%ebp)
 2da:	8b 45 08             	mov    0x8(%ebp),%eax
 2dd:	8d 48 01             	lea    0x1(%eax),%ecx
 2e0:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2e3:	0f b6 12             	movzbl (%edx),%edx
 2e6:	88 10                	mov    %dl,(%eax)
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	84 c0                	test   %al,%al
 2ed:	75 e2                	jne    2d1 <strcpy+0xd>
    ;
  return os;
 2ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2f2:	c9                   	leave  
 2f3:	c3                   	ret    

000002f4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f4:	55                   	push   %ebp
 2f5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2f7:	eb 08                	jmp    301 <strcmp+0xd>
    p++, q++;
 2f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2fd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 301:	8b 45 08             	mov    0x8(%ebp),%eax
 304:	0f b6 00             	movzbl (%eax),%eax
 307:	84 c0                	test   %al,%al
 309:	74 10                	je     31b <strcmp+0x27>
 30b:	8b 45 08             	mov    0x8(%ebp),%eax
 30e:	0f b6 10             	movzbl (%eax),%edx
 311:	8b 45 0c             	mov    0xc(%ebp),%eax
 314:	0f b6 00             	movzbl (%eax),%eax
 317:	38 c2                	cmp    %al,%dl
 319:	74 de                	je     2f9 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	0f b6 00             	movzbl (%eax),%eax
 321:	0f b6 d0             	movzbl %al,%edx
 324:	8b 45 0c             	mov    0xc(%ebp),%eax
 327:	0f b6 00             	movzbl (%eax),%eax
 32a:	0f b6 c8             	movzbl %al,%ecx
 32d:	89 d0                	mov    %edx,%eax
 32f:	29 c8                	sub    %ecx,%eax
}
 331:	5d                   	pop    %ebp
 332:	c3                   	ret    

00000333 <strlen>:

uint
strlen(char *s)
{
 333:	55                   	push   %ebp
 334:	89 e5                	mov    %esp,%ebp
 336:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 339:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 340:	eb 04                	jmp    346 <strlen+0x13>
 342:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 346:	8b 55 fc             	mov    -0x4(%ebp),%edx
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	01 d0                	add    %edx,%eax
 34e:	0f b6 00             	movzbl (%eax),%eax
 351:	84 c0                	test   %al,%al
 353:	75 ed                	jne    342 <strlen+0xf>
    ;
  return n;
 355:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 358:	c9                   	leave  
 359:	c3                   	ret    

0000035a <memset>:

void*
memset(void *dst, int c, uint n)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 35d:	8b 45 10             	mov    0x10(%ebp),%eax
 360:	50                   	push   %eax
 361:	ff 75 0c             	push   0xc(%ebp)
 364:	ff 75 08             	push   0x8(%ebp)
 367:	e8 32 ff ff ff       	call   29e <stosb>
 36c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 36f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 372:	c9                   	leave  
 373:	c3                   	ret    

00000374 <strchr>:

char*
strchr(const char *s, char c)
{
 374:	55                   	push   %ebp
 375:	89 e5                	mov    %esp,%ebp
 377:	83 ec 04             	sub    $0x4,%esp
 37a:	8b 45 0c             	mov    0xc(%ebp),%eax
 37d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 380:	eb 14                	jmp    396 <strchr+0x22>
    if(*s == c)
 382:	8b 45 08             	mov    0x8(%ebp),%eax
 385:	0f b6 00             	movzbl (%eax),%eax
 388:	38 45 fc             	cmp    %al,-0x4(%ebp)
 38b:	75 05                	jne    392 <strchr+0x1e>
      return (char*)s;
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	eb 13                	jmp    3a5 <strchr+0x31>
  for(; *s; s++)
 392:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 396:	8b 45 08             	mov    0x8(%ebp),%eax
 399:	0f b6 00             	movzbl (%eax),%eax
 39c:	84 c0                	test   %al,%al
 39e:	75 e2                	jne    382 <strchr+0xe>
  return 0;
 3a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <gets>:

char*
gets(char *buf, int max)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
 3aa:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3b4:	eb 42                	jmp    3f8 <gets+0x51>
    cc = read(0, &c, 1);
 3b6:	83 ec 04             	sub    $0x4,%esp
 3b9:	6a 01                	push   $0x1
 3bb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3be:	50                   	push   %eax
 3bf:	6a 00                	push   $0x0
 3c1:	e8 47 01 00 00       	call   50d <read>
 3c6:	83 c4 10             	add    $0x10,%esp
 3c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3d0:	7e 33                	jle    405 <gets+0x5e>
      break;
    buf[i++] = c;
 3d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d5:	8d 50 01             	lea    0x1(%eax),%edx
 3d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3db:	89 c2                	mov    %eax,%edx
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
 3e0:	01 c2                	add    %eax,%edx
 3e2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3e6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3e8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3ec:	3c 0a                	cmp    $0xa,%al
 3ee:	74 16                	je     406 <gets+0x5f>
 3f0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f4:	3c 0d                	cmp    $0xd,%al
 3f6:	74 0e                	je     406 <gets+0x5f>
  for(i=0; i+1 < max; ){
 3f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fb:	83 c0 01             	add    $0x1,%eax
 3fe:	39 45 0c             	cmp    %eax,0xc(%ebp)
 401:	7f b3                	jg     3b6 <gets+0xf>
 403:	eb 01                	jmp    406 <gets+0x5f>
      break;
 405:	90                   	nop
      break;
  }
  buf[i] = '\0';
 406:	8b 55 f4             	mov    -0xc(%ebp),%edx
 409:	8b 45 08             	mov    0x8(%ebp),%eax
 40c:	01 d0                	add    %edx,%eax
 40e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 411:	8b 45 08             	mov    0x8(%ebp),%eax
}
 414:	c9                   	leave  
 415:	c3                   	ret    

00000416 <stat>:

int
stat(char *n, struct stat *st)
{
 416:	55                   	push   %ebp
 417:	89 e5                	mov    %esp,%ebp
 419:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 41c:	83 ec 08             	sub    $0x8,%esp
 41f:	6a 00                	push   $0x0
 421:	ff 75 08             	push   0x8(%ebp)
 424:	e8 0c 01 00 00       	call   535 <open>
 429:	83 c4 10             	add    $0x10,%esp
 42c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 42f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 433:	79 07                	jns    43c <stat+0x26>
    return -1;
 435:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 43a:	eb 25                	jmp    461 <stat+0x4b>
  r = fstat(fd, st);
 43c:	83 ec 08             	sub    $0x8,%esp
 43f:	ff 75 0c             	push   0xc(%ebp)
 442:	ff 75 f4             	push   -0xc(%ebp)
 445:	e8 03 01 00 00       	call   54d <fstat>
 44a:	83 c4 10             	add    $0x10,%esp
 44d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 450:	83 ec 0c             	sub    $0xc,%esp
 453:	ff 75 f4             	push   -0xc(%ebp)
 456:	e8 c2 00 00 00       	call   51d <close>
 45b:	83 c4 10             	add    $0x10,%esp
  return r;
 45e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 461:	c9                   	leave  
 462:	c3                   	ret    

00000463 <atoi>:

int
atoi(const char *s)
{
 463:	55                   	push   %ebp
 464:	89 e5                	mov    %esp,%ebp
 466:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 469:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 470:	eb 25                	jmp    497 <atoi+0x34>
    n = n*10 + *s++ - '0';
 472:	8b 55 fc             	mov    -0x4(%ebp),%edx
 475:	89 d0                	mov    %edx,%eax
 477:	c1 e0 02             	shl    $0x2,%eax
 47a:	01 d0                	add    %edx,%eax
 47c:	01 c0                	add    %eax,%eax
 47e:	89 c1                	mov    %eax,%ecx
 480:	8b 45 08             	mov    0x8(%ebp),%eax
 483:	8d 50 01             	lea    0x1(%eax),%edx
 486:	89 55 08             	mov    %edx,0x8(%ebp)
 489:	0f b6 00             	movzbl (%eax),%eax
 48c:	0f be c0             	movsbl %al,%eax
 48f:	01 c8                	add    %ecx,%eax
 491:	83 e8 30             	sub    $0x30,%eax
 494:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 497:	8b 45 08             	mov    0x8(%ebp),%eax
 49a:	0f b6 00             	movzbl (%eax),%eax
 49d:	3c 2f                	cmp    $0x2f,%al
 49f:	7e 0a                	jle    4ab <atoi+0x48>
 4a1:	8b 45 08             	mov    0x8(%ebp),%eax
 4a4:	0f b6 00             	movzbl (%eax),%eax
 4a7:	3c 39                	cmp    $0x39,%al
 4a9:	7e c7                	jle    472 <atoi+0xf>
  return n;
 4ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4ae:	c9                   	leave  
 4af:	c3                   	ret    

000004b0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4b6:	8b 45 08             	mov    0x8(%ebp),%eax
 4b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 4bf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4c2:	eb 17                	jmp    4db <memmove+0x2b>
    *dst++ = *src++;
 4c4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4c7:	8d 42 01             	lea    0x1(%edx),%eax
 4ca:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4d0:	8d 48 01             	lea    0x1(%eax),%ecx
 4d3:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4d6:	0f b6 12             	movzbl (%edx),%edx
 4d9:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4db:	8b 45 10             	mov    0x10(%ebp),%eax
 4de:	8d 50 ff             	lea    -0x1(%eax),%edx
 4e1:	89 55 10             	mov    %edx,0x10(%ebp)
 4e4:	85 c0                	test   %eax,%eax
 4e6:	7f dc                	jg     4c4 <memmove+0x14>
  return vdst;
 4e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4eb:	c9                   	leave  
 4ec:	c3                   	ret    

000004ed <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4ed:	b8 01 00 00 00       	mov    $0x1,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret    

000004f5 <exit>:
SYSCALL(exit)
 4f5:	b8 02 00 00 00       	mov    $0x2,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret    

000004fd <wait>:
SYSCALL(wait)
 4fd:	b8 03 00 00 00       	mov    $0x3,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret    

00000505 <pipe>:
SYSCALL(pipe)
 505:	b8 04 00 00 00       	mov    $0x4,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret    

0000050d <read>:
SYSCALL(read)
 50d:	b8 05 00 00 00       	mov    $0x5,%eax
 512:	cd 40                	int    $0x40
 514:	c3                   	ret    

00000515 <write>:
SYSCALL(write)
 515:	b8 10 00 00 00       	mov    $0x10,%eax
 51a:	cd 40                	int    $0x40
 51c:	c3                   	ret    

0000051d <close>:
SYSCALL(close)
 51d:	b8 15 00 00 00       	mov    $0x15,%eax
 522:	cd 40                	int    $0x40
 524:	c3                   	ret    

00000525 <kill>:
SYSCALL(kill)
 525:	b8 06 00 00 00       	mov    $0x6,%eax
 52a:	cd 40                	int    $0x40
 52c:	c3                   	ret    

0000052d <exec>:
SYSCALL(exec)
 52d:	b8 07 00 00 00       	mov    $0x7,%eax
 532:	cd 40                	int    $0x40
 534:	c3                   	ret    

00000535 <open>:
SYSCALL(open)
 535:	b8 0f 00 00 00       	mov    $0xf,%eax
 53a:	cd 40                	int    $0x40
 53c:	c3                   	ret    

0000053d <mknod>:
SYSCALL(mknod)
 53d:	b8 11 00 00 00       	mov    $0x11,%eax
 542:	cd 40                	int    $0x40
 544:	c3                   	ret    

00000545 <unlink>:
SYSCALL(unlink)
 545:	b8 12 00 00 00       	mov    $0x12,%eax
 54a:	cd 40                	int    $0x40
 54c:	c3                   	ret    

0000054d <fstat>:
SYSCALL(fstat)
 54d:	b8 08 00 00 00       	mov    $0x8,%eax
 552:	cd 40                	int    $0x40
 554:	c3                   	ret    

00000555 <link>:
SYSCALL(link)
 555:	b8 13 00 00 00       	mov    $0x13,%eax
 55a:	cd 40                	int    $0x40
 55c:	c3                   	ret    

0000055d <mkdir>:
SYSCALL(mkdir)
 55d:	b8 14 00 00 00       	mov    $0x14,%eax
 562:	cd 40                	int    $0x40
 564:	c3                   	ret    

00000565 <chdir>:
SYSCALL(chdir)
 565:	b8 09 00 00 00       	mov    $0x9,%eax
 56a:	cd 40                	int    $0x40
 56c:	c3                   	ret    

0000056d <dup>:
SYSCALL(dup)
 56d:	b8 0a 00 00 00       	mov    $0xa,%eax
 572:	cd 40                	int    $0x40
 574:	c3                   	ret    

00000575 <getpid>:
SYSCALL(getpid)
 575:	b8 0b 00 00 00       	mov    $0xb,%eax
 57a:	cd 40                	int    $0x40
 57c:	c3                   	ret    

0000057d <sbrk>:
SYSCALL(sbrk)
 57d:	b8 0c 00 00 00       	mov    $0xc,%eax
 582:	cd 40                	int    $0x40
 584:	c3                   	ret    

00000585 <sleep>:
SYSCALL(sleep)
 585:	b8 0d 00 00 00       	mov    $0xd,%eax
 58a:	cd 40                	int    $0x40
 58c:	c3                   	ret    

0000058d <uptime>:
SYSCALL(uptime)
 58d:	b8 0e 00 00 00       	mov    $0xe,%eax
 592:	cd 40                	int    $0x40
 594:	c3                   	ret    

00000595 <uthread_init>:
SYSCALL(uthread_init)
 595:	b8 16 00 00 00       	mov    $0x16,%eax
 59a:	cd 40                	int    $0x40
 59c:	c3                   	ret    

0000059d <thread_inc>:
SYSCALL(thread_inc)
 59d:	b8 17 00 00 00       	mov    $0x17,%eax
 5a2:	cd 40                	int    $0x40
 5a4:	c3                   	ret    

000005a5 <thread_dec>:
SYSCALL(thread_dec)
 5a5:	b8 18 00 00 00       	mov    $0x18,%eax
 5aa:	cd 40                	int    $0x40
 5ac:	c3                   	ret    

000005ad <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5ad:	55                   	push   %ebp
 5ae:	89 e5                	mov    %esp,%ebp
 5b0:	83 ec 18             	sub    $0x18,%esp
 5b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b6:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5b9:	83 ec 04             	sub    $0x4,%esp
 5bc:	6a 01                	push   $0x1
 5be:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5c1:	50                   	push   %eax
 5c2:	ff 75 08             	push   0x8(%ebp)
 5c5:	e8 4b ff ff ff       	call   515 <write>
 5ca:	83 c4 10             	add    $0x10,%esp
}
 5cd:	90                   	nop
 5ce:	c9                   	leave  
 5cf:	c3                   	ret    

000005d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5d0:	55                   	push   %ebp
 5d1:	89 e5                	mov    %esp,%ebp
 5d3:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5d6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5dd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5e1:	74 17                	je     5fa <printint+0x2a>
 5e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5e7:	79 11                	jns    5fa <printint+0x2a>
    neg = 1;
 5e9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f3:	f7 d8                	neg    %eax
 5f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f8:	eb 06                	jmp    600 <printint+0x30>
  } else {
    x = xx;
 5fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 5fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 600:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 607:	8b 4d 10             	mov    0x10(%ebp),%ecx
 60a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 60d:	ba 00 00 00 00       	mov    $0x0,%edx
 612:	f7 f1                	div    %ecx
 614:	89 d1                	mov    %edx,%ecx
 616:	8b 45 f4             	mov    -0xc(%ebp),%eax
 619:	8d 50 01             	lea    0x1(%eax),%edx
 61c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 61f:	0f b6 91 70 0d 00 00 	movzbl 0xd70(%ecx),%edx
 626:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 62a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 62d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 630:	ba 00 00 00 00       	mov    $0x0,%edx
 635:	f7 f1                	div    %ecx
 637:	89 45 ec             	mov    %eax,-0x14(%ebp)
 63a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63e:	75 c7                	jne    607 <printint+0x37>
  if(neg)
 640:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 644:	74 2d                	je     673 <printint+0xa3>
    buf[i++] = '-';
 646:	8b 45 f4             	mov    -0xc(%ebp),%eax
 649:	8d 50 01             	lea    0x1(%eax),%edx
 64c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 64f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 654:	eb 1d                	jmp    673 <printint+0xa3>
    putc(fd, buf[i]);
 656:	8d 55 dc             	lea    -0x24(%ebp),%edx
 659:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65c:	01 d0                	add    %edx,%eax
 65e:	0f b6 00             	movzbl (%eax),%eax
 661:	0f be c0             	movsbl %al,%eax
 664:	83 ec 08             	sub    $0x8,%esp
 667:	50                   	push   %eax
 668:	ff 75 08             	push   0x8(%ebp)
 66b:	e8 3d ff ff ff       	call   5ad <putc>
 670:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 673:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 677:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 67b:	79 d9                	jns    656 <printint+0x86>
}
 67d:	90                   	nop
 67e:	90                   	nop
 67f:	c9                   	leave  
 680:	c3                   	ret    

00000681 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 681:	55                   	push   %ebp
 682:	89 e5                	mov    %esp,%ebp
 684:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 687:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 68e:	8d 45 0c             	lea    0xc(%ebp),%eax
 691:	83 c0 04             	add    $0x4,%eax
 694:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 697:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 69e:	e9 59 01 00 00       	jmp    7fc <printf+0x17b>
    c = fmt[i] & 0xff;
 6a3:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a9:	01 d0                	add    %edx,%eax
 6ab:	0f b6 00             	movzbl (%eax),%eax
 6ae:	0f be c0             	movsbl %al,%eax
 6b1:	25 ff 00 00 00       	and    $0xff,%eax
 6b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6bd:	75 2c                	jne    6eb <printf+0x6a>
      if(c == '%'){
 6bf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6c3:	75 0c                	jne    6d1 <printf+0x50>
        state = '%';
 6c5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6cc:	e9 27 01 00 00       	jmp    7f8 <printf+0x177>
      } else {
        putc(fd, c);
 6d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d4:	0f be c0             	movsbl %al,%eax
 6d7:	83 ec 08             	sub    $0x8,%esp
 6da:	50                   	push   %eax
 6db:	ff 75 08             	push   0x8(%ebp)
 6de:	e8 ca fe ff ff       	call   5ad <putc>
 6e3:	83 c4 10             	add    $0x10,%esp
 6e6:	e9 0d 01 00 00       	jmp    7f8 <printf+0x177>
      }
    } else if(state == '%'){
 6eb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ef:	0f 85 03 01 00 00    	jne    7f8 <printf+0x177>
      if(c == 'd'){
 6f5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6f9:	75 1e                	jne    719 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6fe:	8b 00                	mov    (%eax),%eax
 700:	6a 01                	push   $0x1
 702:	6a 0a                	push   $0xa
 704:	50                   	push   %eax
 705:	ff 75 08             	push   0x8(%ebp)
 708:	e8 c3 fe ff ff       	call   5d0 <printint>
 70d:	83 c4 10             	add    $0x10,%esp
        ap++;
 710:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 714:	e9 d8 00 00 00       	jmp    7f1 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 719:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 71d:	74 06                	je     725 <printf+0xa4>
 71f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 723:	75 1e                	jne    743 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 725:	8b 45 e8             	mov    -0x18(%ebp),%eax
 728:	8b 00                	mov    (%eax),%eax
 72a:	6a 00                	push   $0x0
 72c:	6a 10                	push   $0x10
 72e:	50                   	push   %eax
 72f:	ff 75 08             	push   0x8(%ebp)
 732:	e8 99 fe ff ff       	call   5d0 <printint>
 737:	83 c4 10             	add    $0x10,%esp
        ap++;
 73a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 73e:	e9 ae 00 00 00       	jmp    7f1 <printf+0x170>
      } else if(c == 's'){
 743:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 747:	75 43                	jne    78c <printf+0x10b>
        s = (char*)*ap;
 749:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74c:	8b 00                	mov    (%eax),%eax
 74e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 751:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 755:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 759:	75 25                	jne    780 <printf+0xff>
          s = "(null)";
 75b:	c7 45 f4 9e 0a 00 00 	movl   $0xa9e,-0xc(%ebp)
        while(*s != 0){
 762:	eb 1c                	jmp    780 <printf+0xff>
          putc(fd, *s);
 764:	8b 45 f4             	mov    -0xc(%ebp),%eax
 767:	0f b6 00             	movzbl (%eax),%eax
 76a:	0f be c0             	movsbl %al,%eax
 76d:	83 ec 08             	sub    $0x8,%esp
 770:	50                   	push   %eax
 771:	ff 75 08             	push   0x8(%ebp)
 774:	e8 34 fe ff ff       	call   5ad <putc>
 779:	83 c4 10             	add    $0x10,%esp
          s++;
 77c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 780:	8b 45 f4             	mov    -0xc(%ebp),%eax
 783:	0f b6 00             	movzbl (%eax),%eax
 786:	84 c0                	test   %al,%al
 788:	75 da                	jne    764 <printf+0xe3>
 78a:	eb 65                	jmp    7f1 <printf+0x170>
        }
      } else if(c == 'c'){
 78c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 790:	75 1d                	jne    7af <printf+0x12e>
        putc(fd, *ap);
 792:	8b 45 e8             	mov    -0x18(%ebp),%eax
 795:	8b 00                	mov    (%eax),%eax
 797:	0f be c0             	movsbl %al,%eax
 79a:	83 ec 08             	sub    $0x8,%esp
 79d:	50                   	push   %eax
 79e:	ff 75 08             	push   0x8(%ebp)
 7a1:	e8 07 fe ff ff       	call   5ad <putc>
 7a6:	83 c4 10             	add    $0x10,%esp
        ap++;
 7a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ad:	eb 42                	jmp    7f1 <printf+0x170>
      } else if(c == '%'){
 7af:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7b3:	75 17                	jne    7cc <printf+0x14b>
        putc(fd, c);
 7b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b8:	0f be c0             	movsbl %al,%eax
 7bb:	83 ec 08             	sub    $0x8,%esp
 7be:	50                   	push   %eax
 7bf:	ff 75 08             	push   0x8(%ebp)
 7c2:	e8 e6 fd ff ff       	call   5ad <putc>
 7c7:	83 c4 10             	add    $0x10,%esp
 7ca:	eb 25                	jmp    7f1 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7cc:	83 ec 08             	sub    $0x8,%esp
 7cf:	6a 25                	push   $0x25
 7d1:	ff 75 08             	push   0x8(%ebp)
 7d4:	e8 d4 fd ff ff       	call   5ad <putc>
 7d9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7df:	0f be c0             	movsbl %al,%eax
 7e2:	83 ec 08             	sub    $0x8,%esp
 7e5:	50                   	push   %eax
 7e6:	ff 75 08             	push   0x8(%ebp)
 7e9:	e8 bf fd ff ff       	call   5ad <putc>
 7ee:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7f8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7fc:	8b 55 0c             	mov    0xc(%ebp),%edx
 7ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 802:	01 d0                	add    %edx,%eax
 804:	0f b6 00             	movzbl (%eax),%eax
 807:	84 c0                	test   %al,%al
 809:	0f 85 94 fe ff ff    	jne    6a3 <printf+0x22>
    }
  }
}
 80f:	90                   	nop
 810:	90                   	nop
 811:	c9                   	leave  
 812:	c3                   	ret    

00000813 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 813:	55                   	push   %ebp
 814:	89 e5                	mov    %esp,%ebp
 816:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 819:	8b 45 08             	mov    0x8(%ebp),%eax
 81c:	83 e8 08             	sub    $0x8,%eax
 81f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 822:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 827:	89 45 fc             	mov    %eax,-0x4(%ebp)
 82a:	eb 24                	jmp    850 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	8b 00                	mov    (%eax),%eax
 831:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 834:	72 12                	jb     848 <free+0x35>
 836:	8b 45 f8             	mov    -0x8(%ebp),%eax
 839:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83c:	77 24                	ja     862 <free+0x4f>
 83e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 841:	8b 00                	mov    (%eax),%eax
 843:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 846:	72 1a                	jb     862 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 848:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84b:	8b 00                	mov    (%eax),%eax
 84d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 850:	8b 45 f8             	mov    -0x8(%ebp),%eax
 853:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 856:	76 d4                	jbe    82c <free+0x19>
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	8b 00                	mov    (%eax),%eax
 85d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 860:	73 ca                	jae    82c <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 862:	8b 45 f8             	mov    -0x8(%ebp),%eax
 865:	8b 40 04             	mov    0x4(%eax),%eax
 868:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	01 c2                	add    %eax,%edx
 874:	8b 45 fc             	mov    -0x4(%ebp),%eax
 877:	8b 00                	mov    (%eax),%eax
 879:	39 c2                	cmp    %eax,%edx
 87b:	75 24                	jne    8a1 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 87d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 880:	8b 50 04             	mov    0x4(%eax),%edx
 883:	8b 45 fc             	mov    -0x4(%ebp),%eax
 886:	8b 00                	mov    (%eax),%eax
 888:	8b 40 04             	mov    0x4(%eax),%eax
 88b:	01 c2                	add    %eax,%edx
 88d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 890:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 893:	8b 45 fc             	mov    -0x4(%ebp),%eax
 896:	8b 00                	mov    (%eax),%eax
 898:	8b 10                	mov    (%eax),%edx
 89a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89d:	89 10                	mov    %edx,(%eax)
 89f:	eb 0a                	jmp    8ab <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	8b 10                	mov    (%eax),%edx
 8a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a9:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	8b 40 04             	mov    0x4(%eax),%eax
 8b1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bb:	01 d0                	add    %edx,%eax
 8bd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8c0:	75 20                	jne    8e2 <free+0xcf>
    p->s.size += bp->s.size;
 8c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c5:	8b 50 04             	mov    0x4(%eax),%edx
 8c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cb:	8b 40 04             	mov    0x4(%eax),%eax
 8ce:	01 c2                	add    %eax,%edx
 8d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d9:	8b 10                	mov    (%eax),%edx
 8db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8de:	89 10                	mov    %edx,(%eax)
 8e0:	eb 08                	jmp    8ea <free+0xd7>
  } else
    p->s.ptr = bp;
 8e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8e8:	89 10                	mov    %edx,(%eax)
  freep = p;
 8ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ed:	a3 e8 8d 00 00       	mov    %eax,0x8de8
}
 8f2:	90                   	nop
 8f3:	c9                   	leave  
 8f4:	c3                   	ret    

000008f5 <morecore>:

static Header*
morecore(uint nu)
{
 8f5:	55                   	push   %ebp
 8f6:	89 e5                	mov    %esp,%ebp
 8f8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8fb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 902:	77 07                	ja     90b <morecore+0x16>
    nu = 4096;
 904:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 90b:	8b 45 08             	mov    0x8(%ebp),%eax
 90e:	c1 e0 03             	shl    $0x3,%eax
 911:	83 ec 0c             	sub    $0xc,%esp
 914:	50                   	push   %eax
 915:	e8 63 fc ff ff       	call   57d <sbrk>
 91a:	83 c4 10             	add    $0x10,%esp
 91d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 920:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 924:	75 07                	jne    92d <morecore+0x38>
    return 0;
 926:	b8 00 00 00 00       	mov    $0x0,%eax
 92b:	eb 26                	jmp    953 <morecore+0x5e>
  hp = (Header*)p;
 92d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 930:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 933:	8b 45 f0             	mov    -0x10(%ebp),%eax
 936:	8b 55 08             	mov    0x8(%ebp),%edx
 939:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 93c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93f:	83 c0 08             	add    $0x8,%eax
 942:	83 ec 0c             	sub    $0xc,%esp
 945:	50                   	push   %eax
 946:	e8 c8 fe ff ff       	call   813 <free>
 94b:	83 c4 10             	add    $0x10,%esp
  return freep;
 94e:	a1 e8 8d 00 00       	mov    0x8de8,%eax
}
 953:	c9                   	leave  
 954:	c3                   	ret    

00000955 <malloc>:

void*
malloc(uint nbytes)
{
 955:	55                   	push   %ebp
 956:	89 e5                	mov    %esp,%ebp
 958:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95b:	8b 45 08             	mov    0x8(%ebp),%eax
 95e:	83 c0 07             	add    $0x7,%eax
 961:	c1 e8 03             	shr    $0x3,%eax
 964:	83 c0 01             	add    $0x1,%eax
 967:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 96a:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 96f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 972:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 976:	75 23                	jne    99b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 978:	c7 45 f0 e0 8d 00 00 	movl   $0x8de0,-0x10(%ebp)
 97f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 982:	a3 e8 8d 00 00       	mov    %eax,0x8de8
 987:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 98c:	a3 e0 8d 00 00       	mov    %eax,0x8de0
    base.s.size = 0;
 991:	c7 05 e4 8d 00 00 00 	movl   $0x0,0x8de4
 998:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99e:	8b 00                	mov    (%eax),%eax
 9a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a6:	8b 40 04             	mov    0x4(%eax),%eax
 9a9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9ac:	77 4d                	ja     9fb <malloc+0xa6>
      if(p->s.size == nunits)
 9ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b1:	8b 40 04             	mov    0x4(%eax),%eax
 9b4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9b7:	75 0c                	jne    9c5 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bc:	8b 10                	mov    (%eax),%edx
 9be:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c1:	89 10                	mov    %edx,(%eax)
 9c3:	eb 26                	jmp    9eb <malloc+0x96>
      else {
        p->s.size -= nunits;
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	8b 40 04             	mov    0x4(%eax),%eax
 9cb:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9ce:	89 c2                	mov    %eax,%edx
 9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d9:	8b 40 04             	mov    0x4(%eax),%eax
 9dc:	c1 e0 03             	shl    $0x3,%eax
 9df:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9e8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ee:	a3 e8 8d 00 00       	mov    %eax,0x8de8
      return (void*)(p + 1);
 9f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f6:	83 c0 08             	add    $0x8,%eax
 9f9:	eb 3b                	jmp    a36 <malloc+0xe1>
    }
    if(p == freep)
 9fb:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 a00:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a03:	75 1e                	jne    a23 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a05:	83 ec 0c             	sub    $0xc,%esp
 a08:	ff 75 ec             	push   -0x14(%ebp)
 a0b:	e8 e5 fe ff ff       	call   8f5 <morecore>
 a10:	83 c4 10             	add    $0x10,%esp
 a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a1a:	75 07                	jne    a23 <malloc+0xce>
        return 0;
 a1c:	b8 00 00 00 00       	mov    $0x0,%eax
 a21:	eb 13                	jmp    a36 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2c:	8b 00                	mov    (%eax),%eax
 a2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a31:	e9 6d ff ff ff       	jmp    9a3 <malloc+0x4e>
  }
}
 a36:	c9                   	leave  
 a37:	c3                   	ret    
