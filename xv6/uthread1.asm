
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
extern void thread_switch(void);
extern void thread_schedule(void);

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
   f:	e8 8b 05 00 00       	call   59f <uthread_init>
  14:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  17:	c7 05 c0 0d 00 00 e0 	movl   $0xde0,0xdc0
  1e:	0d 00 00 
  current_thread->state = RUNNING;
  21:	a1 c0 0d 00 00       	mov    0xdc0,%eax
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
  39:	c7 05 c4 0d 00 00 00 	movl   $0x0,0xdc4
  40:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  43:	c7 45 f4 e0 0d 00 00 	movl   $0xde0,-0xc(%ebp)
  4a:	eb 29                	jmp    75 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4f:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  55:	83 f8 02             	cmp    $0x2,%eax
  58:	75 14                	jne    6e <thread_schedule+0x3b>
  5a:	a1 c0 0d 00 00       	mov    0xdc0,%eax
  5f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  62:	74 0a                	je     6e <thread_schedule+0x3b>
      next_thread = t;
  64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  67:	a3 c4 0d 00 00       	mov    %eax,0xdc4
      break;
  6c:	eb 11                	jmp    7f <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  6e:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  75:	b8 00 8e 00 00       	mov    $0x8e00,%eax
  7a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  7d:	72 cd                	jb     4c <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  7f:	b8 00 8e 00 00       	mov    $0x8e00,%eax
  84:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  87:	72 1a                	jb     a3 <thread_schedule+0x70>
  89:	a1 c0 0d 00 00       	mov    0xdc0,%eax
  8e:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  94:	83 f8 02             	cmp    $0x2,%eax
  97:	75 0a                	jne    a3 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  99:	a1 c0 0d 00 00       	mov    0xdc0,%eax
  9e:	a3 c4 0d 00 00       	mov    %eax,0xdc4
  }

  if (next_thread == 0) {
  a3:	a1 c4 0d 00 00       	mov    0xdc4,%eax
  a8:	85 c0                	test   %eax,%eax
  aa:	75 17                	jne    c3 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  ac:	83 ec 08             	sub    $0x8,%esp
  af:	68 54 0a 00 00       	push   $0xa54
  b4:	6a 02                	push   $0x2
  b6:	e8 e0 05 00 00       	call   69b <printf>
  bb:	83 c4 10             	add    $0x10,%esp
    exit();
  be:	e8 3c 04 00 00       	call   4ff <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  c3:	8b 15 c0 0d 00 00    	mov    0xdc0,%edx
  c9:	a1 c4 0d 00 00       	mov    0xdc4,%eax
  ce:	39 c2                	cmp    %eax,%edx
  d0:	74 41                	je     113 <thread_schedule+0xe0>
    next_thread->state = RUNNING;
  d2:	a1 c4 0d 00 00       	mov    0xdc4,%eax
  d7:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  de:	00 00 00 
    if (current_thread != &all_thread[0]) {
  e1:	a1 c0 0d 00 00       	mov    0xdc0,%eax
  e6:	3d e0 0d 00 00       	cmp    $0xde0,%eax
  eb:	74 1f                	je     10c <thread_schedule+0xd9>
      if (current_thread->state == RUNNING) {
  ed:	a1 c0 0d 00 00       	mov    0xdc0,%eax
  f2:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  f8:	83 f8 01             	cmp    $0x1,%eax
  fb:	75 0f                	jne    10c <thread_schedule+0xd9>
        current_thread->state = RUNNABLE;
  fd:	a1 c0 0d 00 00       	mov    0xdc0,%eax
 102:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 109:	00 00 00 
      }
    }
    thread_switch();
 10c:	e8 72 01 00 00       	call   283 <thread_switch>
  } else
    next_thread = 0;
}
 111:	eb 0a                	jmp    11d <thread_schedule+0xea>
    next_thread = 0;
 113:	c7 05 c4 0d 00 00 00 	movl   $0x0,0xdc4
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
 126:	c7 45 f4 e0 0d 00 00 	movl   $0xde0,-0xc(%ebp)
 12d:	eb 14                	jmp    143 <thread_create+0x23>
    if (t->state == FREE) break;
 12f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 132:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 138:	85 c0                	test   %eax,%eax
 13a:	74 13                	je     14f <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 13c:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 143:	b8 00 8e 00 00       	mov    $0x8e00,%eax
 148:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 14b:	72 e2                	jb     12f <thread_create+0xf>
 14d:	eb 01                	jmp    150 <thread_create+0x30>
    if (t->state == FREE) break;
 14f:	90                   	nop
  }

  if (t == all_thread + MAX_THREAD) {
 150:	b8 00 8e 00 00       	mov    $0x8e00,%eax
 155:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 158:	75 14                	jne    16e <thread_create+0x4e>
    printf(1, "thread_create: no available slot\n");
 15a:	83 ec 08             	sub    $0x8,%esp
 15d:	68 7c 0a 00 00       	push   $0xa7c
 162:	6a 01                	push   $0x1
 164:	e8 32 05 00 00       	call   69b <printf>
 169:	83 c4 10             	add    $0x10,%esp
    return;
 16c:	eb 52                	jmp    1c0 <thread_create+0xa0>
  }
    t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 16e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 171:	83 c0 04             	add    $0x4,%eax
 174:	05 00 20 00 00       	add    $0x2000,%eax
 179:	89 c2                	mov    %eax,%edx
 17b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17e:	89 10                	mov    %edx,(%eax)
    t->sp -= 4;                              // space for return address
 180:	8b 45 f4             	mov    -0xc(%ebp),%eax
 183:	8b 00                	mov    (%eax),%eax
 185:	8d 50 fc             	lea    -0x4(%eax),%edx
 188:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18b:	89 10                	mov    %edx,(%eax)
    * (int *) (t->sp) = (int)func;
 18d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 190:	8b 00                	mov    (%eax),%eax
 192:	89 c2                	mov    %eax,%edx
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	89 02                	mov    %eax,(%edx)
    t->sp -= 32;                             // space for registers that thread_switch expects
 199:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19c:	8b 00                	mov    (%eax),%eax
 19e:	8d 50 e0             	lea    -0x20(%eax),%edx
 1a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a4:	89 10                	mov    %edx,(%eax)
    t->state = RUNNABLE;  
 1a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a9:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1b0:	00 00 00 
    check_thread(+1);
 1b3:	83 ec 0c             	sub    $0xc,%esp
 1b6:	6a 01                	push   $0x1
 1b8:	e8 ea 03 00 00       	call   5a7 <check_thread>
 1bd:	83 c4 10             	add    $0x10,%esp
}
 1c0:	c9                   	leave  
 1c1:	c3                   	ret    

000001c2 <mythread>:

void 
mythread(void)
{
 1c2:	55                   	push   %ebp
 1c3:	89 e5                	mov    %esp,%ebp
 1c5:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1c8:	83 ec 08             	sub    $0x8,%esp
 1cb:	68 9e 0a 00 00       	push   $0xa9e
 1d0:	6a 01                	push   $0x1
 1d2:	e8 c4 04 00 00       	call   69b <printf>
 1d7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1e1:	eb 1c                	jmp    1ff <mythread+0x3d>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 1e3:	a1 c0 0d 00 00       	mov    0xdc0,%eax
 1e8:	83 ec 04             	sub    $0x4,%esp
 1eb:	50                   	push   %eax
 1ec:	68 b1 0a 00 00       	push   $0xab1
 1f1:	6a 01                	push   $0x1
 1f3:	e8 a3 04 00 00       	call   69b <printf>
 1f8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1ff:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 203:	7e de                	jle    1e3 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 205:	83 ec 08             	sub    $0x8,%esp
 208:	68 c1 0a 00 00       	push   $0xac1
 20d:	6a 01                	push   $0x1
 20f:	e8 87 04 00 00       	call   69b <printf>
 214:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 217:	a1 c0 0d 00 00       	mov    0xdc0,%eax
 21c:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 223:	00 00 00 

  check_thread(-1);
 226:	83 ec 0c             	sub    $0xc,%esp
 229:	6a ff                	push   $0xffffffff
 22b:	e8 77 03 00 00       	call   5a7 <check_thread>
 230:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 233:	e8 fb fd ff ff       	call   33 <thread_schedule>
}
 238:	90                   	nop
 239:	c9                   	leave  
 23a:	c3                   	ret    

0000023b <main>:

int 
main(int argc, char *argv[]) 
{
 23b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 23f:	83 e4 f0             	and    $0xfffffff0,%esp
 242:	ff 71 fc             	push   -0x4(%ecx)
 245:	55                   	push   %ebp
 246:	89 e5                	mov    %esp,%ebp
 248:	51                   	push   %ecx
 249:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 24c:	e8 af fd ff ff       	call   0 <thread_init>
  thread_create((void (*)())mythread);
 251:	83 ec 0c             	sub    $0xc,%esp
 254:	68 c2 01 00 00       	push   $0x1c2
 259:	e8 c2 fe ff ff       	call   120 <thread_create>
 25e:	83 c4 10             	add    $0x10,%esp
  thread_create((void (*)())mythread);
 261:	83 ec 0c             	sub    $0xc,%esp
 264:	68 c2 01 00 00       	push   $0x1c2
 269:	e8 b2 fe ff ff       	call   120 <thread_create>
 26e:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 271:	e8 bd fd ff ff       	call   33 <thread_schedule>
  return 0;
 276:	b8 00 00 00 00       	mov    $0x0,%eax
 27b:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 27e:	c9                   	leave  
 27f:	8d 61 fc             	lea    -0x4(%ecx),%esp
 282:	c3                   	ret    

00000283 <thread_switch>:
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	pushal
 283:	60                   	pusha  

   movl current_thread, %eax
 284:	a1 c0 0d 00 00       	mov    0xdc0,%eax
   movl %esp, (%eax)
 289:	89 20                	mov    %esp,(%eax)

   movl next_thread, %eax      # eax = next_thread  현재 실행 중인 스레드 구조체의 주소를 eax에 저장
 28b:	a1 c4 0d 00 00       	mov    0xdc4,%eax
    movl (%eax), %esp           # esp = next_thread->sp 현재 실행 중인 스레드의 현
 290:	8b 20                	mov    (%eax),%esp

    movl next_thread, %eax
 292:	a1 c4 0d 00 00       	mov    0xdc4,%eax
    movl %eax, current_thread   # current_thread = next_thread
 297:	a3 c0 0d 00 00       	mov    %eax,0xdc0

    popal
 29c:	61                   	popa   

   movl $0, next_thread
 29d:	c7 05 c4 0d 00 00 00 	movl   $0x0,0xdc4
 2a4:	00 00 00 

	ret    /* return to ra */
 2a7:	c3                   	ret    

000002a8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	57                   	push   %edi
 2ac:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2b0:	8b 55 10             	mov    0x10(%ebp),%edx
 2b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b6:	89 cb                	mov    %ecx,%ebx
 2b8:	89 df                	mov    %ebx,%edi
 2ba:	89 d1                	mov    %edx,%ecx
 2bc:	fc                   	cld    
 2bd:	f3 aa                	rep stos %al,%es:(%edi)
 2bf:	89 ca                	mov    %ecx,%edx
 2c1:	89 fb                	mov    %edi,%ebx
 2c3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2c6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2c9:	90                   	nop
 2ca:	5b                   	pop    %ebx
 2cb:	5f                   	pop    %edi
 2cc:	5d                   	pop    %ebp
 2cd:	c3                   	ret    

000002ce <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2ce:	55                   	push   %ebp
 2cf:	89 e5                	mov    %esp,%ebp
 2d1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
 2d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2da:	90                   	nop
 2db:	8b 55 0c             	mov    0xc(%ebp),%edx
 2de:	8d 42 01             	lea    0x1(%edx),%eax
 2e1:	89 45 0c             	mov    %eax,0xc(%ebp)
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	8d 48 01             	lea    0x1(%eax),%ecx
 2ea:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2ed:	0f b6 12             	movzbl (%edx),%edx
 2f0:	88 10                	mov    %dl,(%eax)
 2f2:	0f b6 00             	movzbl (%eax),%eax
 2f5:	84 c0                	test   %al,%al
 2f7:	75 e2                	jne    2db <strcpy+0xd>
    ;
  return os;
 2f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2fc:	c9                   	leave  
 2fd:	c3                   	ret    

000002fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2fe:	55                   	push   %ebp
 2ff:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 301:	eb 08                	jmp    30b <strcmp+0xd>
    p++, q++;
 303:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 307:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 30b:	8b 45 08             	mov    0x8(%ebp),%eax
 30e:	0f b6 00             	movzbl (%eax),%eax
 311:	84 c0                	test   %al,%al
 313:	74 10                	je     325 <strcmp+0x27>
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	0f b6 10             	movzbl (%eax),%edx
 31b:	8b 45 0c             	mov    0xc(%ebp),%eax
 31e:	0f b6 00             	movzbl (%eax),%eax
 321:	38 c2                	cmp    %al,%dl
 323:	74 de                	je     303 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 325:	8b 45 08             	mov    0x8(%ebp),%eax
 328:	0f b6 00             	movzbl (%eax),%eax
 32b:	0f b6 d0             	movzbl %al,%edx
 32e:	8b 45 0c             	mov    0xc(%ebp),%eax
 331:	0f b6 00             	movzbl (%eax),%eax
 334:	0f b6 c8             	movzbl %al,%ecx
 337:	89 d0                	mov    %edx,%eax
 339:	29 c8                	sub    %ecx,%eax
}
 33b:	5d                   	pop    %ebp
 33c:	c3                   	ret    

0000033d <strlen>:

uint
strlen(char *s)
{
 33d:	55                   	push   %ebp
 33e:	89 e5                	mov    %esp,%ebp
 340:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 343:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 34a:	eb 04                	jmp    350 <strlen+0x13>
 34c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 350:	8b 55 fc             	mov    -0x4(%ebp),%edx
 353:	8b 45 08             	mov    0x8(%ebp),%eax
 356:	01 d0                	add    %edx,%eax
 358:	0f b6 00             	movzbl (%eax),%eax
 35b:	84 c0                	test   %al,%al
 35d:	75 ed                	jne    34c <strlen+0xf>
    ;
  return n;
 35f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 362:	c9                   	leave  
 363:	c3                   	ret    

00000364 <memset>:

void*
memset(void *dst, int c, uint n)
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 367:	8b 45 10             	mov    0x10(%ebp),%eax
 36a:	50                   	push   %eax
 36b:	ff 75 0c             	push   0xc(%ebp)
 36e:	ff 75 08             	push   0x8(%ebp)
 371:	e8 32 ff ff ff       	call   2a8 <stosb>
 376:	83 c4 0c             	add    $0xc,%esp
  return dst;
 379:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37c:	c9                   	leave  
 37d:	c3                   	ret    

0000037e <strchr>:

char*
strchr(const char *s, char c)
{
 37e:	55                   	push   %ebp
 37f:	89 e5                	mov    %esp,%ebp
 381:	83 ec 04             	sub    $0x4,%esp
 384:	8b 45 0c             	mov    0xc(%ebp),%eax
 387:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 38a:	eb 14                	jmp    3a0 <strchr+0x22>
    if(*s == c)
 38c:	8b 45 08             	mov    0x8(%ebp),%eax
 38f:	0f b6 00             	movzbl (%eax),%eax
 392:	38 45 fc             	cmp    %al,-0x4(%ebp)
 395:	75 05                	jne    39c <strchr+0x1e>
      return (char*)s;
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	eb 13                	jmp    3af <strchr+0x31>
  for(; *s; s++)
 39c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a0:	8b 45 08             	mov    0x8(%ebp),%eax
 3a3:	0f b6 00             	movzbl (%eax),%eax
 3a6:	84 c0                	test   %al,%al
 3a8:	75 e2                	jne    38c <strchr+0xe>
  return 0;
 3aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3af:	c9                   	leave  
 3b0:	c3                   	ret    

000003b1 <gets>:

char*
gets(char *buf, int max)
{
 3b1:	55                   	push   %ebp
 3b2:	89 e5                	mov    %esp,%ebp
 3b4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3be:	eb 42                	jmp    402 <gets+0x51>
    cc = read(0, &c, 1);
 3c0:	83 ec 04             	sub    $0x4,%esp
 3c3:	6a 01                	push   $0x1
 3c5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3c8:	50                   	push   %eax
 3c9:	6a 00                	push   $0x0
 3cb:	e8 47 01 00 00       	call   517 <read>
 3d0:	83 c4 10             	add    $0x10,%esp
 3d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3da:	7e 33                	jle    40f <gets+0x5e>
      break;
    buf[i++] = c;
 3dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3df:	8d 50 01             	lea    0x1(%eax),%edx
 3e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3e5:	89 c2                	mov    %eax,%edx
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	01 c2                	add    %eax,%edx
 3ec:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3f2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f6:	3c 0a                	cmp    $0xa,%al
 3f8:	74 16                	je     410 <gets+0x5f>
 3fa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3fe:	3c 0d                	cmp    $0xd,%al
 400:	74 0e                	je     410 <gets+0x5f>
  for(i=0; i+1 < max; ){
 402:	8b 45 f4             	mov    -0xc(%ebp),%eax
 405:	83 c0 01             	add    $0x1,%eax
 408:	39 45 0c             	cmp    %eax,0xc(%ebp)
 40b:	7f b3                	jg     3c0 <gets+0xf>
 40d:	eb 01                	jmp    410 <gets+0x5f>
      break;
 40f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 410:	8b 55 f4             	mov    -0xc(%ebp),%edx
 413:	8b 45 08             	mov    0x8(%ebp),%eax
 416:	01 d0                	add    %edx,%eax
 418:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 41b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41e:	c9                   	leave  
 41f:	c3                   	ret    

00000420 <stat>:

int
stat(char *n, struct stat *st)
{
 420:	55                   	push   %ebp
 421:	89 e5                	mov    %esp,%ebp
 423:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 426:	83 ec 08             	sub    $0x8,%esp
 429:	6a 00                	push   $0x0
 42b:	ff 75 08             	push   0x8(%ebp)
 42e:	e8 0c 01 00 00       	call   53f <open>
 433:	83 c4 10             	add    $0x10,%esp
 436:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 439:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 43d:	79 07                	jns    446 <stat+0x26>
    return -1;
 43f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 444:	eb 25                	jmp    46b <stat+0x4b>
  r = fstat(fd, st);
 446:	83 ec 08             	sub    $0x8,%esp
 449:	ff 75 0c             	push   0xc(%ebp)
 44c:	ff 75 f4             	push   -0xc(%ebp)
 44f:	e8 03 01 00 00       	call   557 <fstat>
 454:	83 c4 10             	add    $0x10,%esp
 457:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 45a:	83 ec 0c             	sub    $0xc,%esp
 45d:	ff 75 f4             	push   -0xc(%ebp)
 460:	e8 c2 00 00 00       	call   527 <close>
 465:	83 c4 10             	add    $0x10,%esp
  return r;
 468:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 46b:	c9                   	leave  
 46c:	c3                   	ret    

0000046d <atoi>:

int
atoi(const char *s)
{
 46d:	55                   	push   %ebp
 46e:	89 e5                	mov    %esp,%ebp
 470:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 473:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 47a:	eb 25                	jmp    4a1 <atoi+0x34>
    n = n*10 + *s++ - '0';
 47c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 47f:	89 d0                	mov    %edx,%eax
 481:	c1 e0 02             	shl    $0x2,%eax
 484:	01 d0                	add    %edx,%eax
 486:	01 c0                	add    %eax,%eax
 488:	89 c1                	mov    %eax,%ecx
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
 48d:	8d 50 01             	lea    0x1(%eax),%edx
 490:	89 55 08             	mov    %edx,0x8(%ebp)
 493:	0f b6 00             	movzbl (%eax),%eax
 496:	0f be c0             	movsbl %al,%eax
 499:	01 c8                	add    %ecx,%eax
 49b:	83 e8 30             	sub    $0x30,%eax
 49e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4a1:	8b 45 08             	mov    0x8(%ebp),%eax
 4a4:	0f b6 00             	movzbl (%eax),%eax
 4a7:	3c 2f                	cmp    $0x2f,%al
 4a9:	7e 0a                	jle    4b5 <atoi+0x48>
 4ab:	8b 45 08             	mov    0x8(%ebp),%eax
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	3c 39                	cmp    $0x39,%al
 4b3:	7e c7                	jle    47c <atoi+0xf>
  return n;
 4b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b8:	c9                   	leave  
 4b9:	c3                   	ret    

000004ba <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4ba:	55                   	push   %ebp
 4bb:	89 e5                	mov    %esp,%ebp
 4bd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4c0:	8b 45 08             	mov    0x8(%ebp),%eax
 4c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4cc:	eb 17                	jmp    4e5 <memmove+0x2b>
    *dst++ = *src++;
 4ce:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4d1:	8d 42 01             	lea    0x1(%edx),%eax
 4d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4da:	8d 48 01             	lea    0x1(%eax),%ecx
 4dd:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4e0:	0f b6 12             	movzbl (%edx),%edx
 4e3:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4e5:	8b 45 10             	mov    0x10(%ebp),%eax
 4e8:	8d 50 ff             	lea    -0x1(%eax),%edx
 4eb:	89 55 10             	mov    %edx,0x10(%ebp)
 4ee:	85 c0                	test   %eax,%eax
 4f0:	7f dc                	jg     4ce <memmove+0x14>
  return vdst;
 4f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f5:	c9                   	leave  
 4f6:	c3                   	ret    

000004f7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4f7:	b8 01 00 00 00       	mov    $0x1,%eax
 4fc:	cd 40                	int    $0x40
 4fe:	c3                   	ret    

000004ff <exit>:
SYSCALL(exit)
 4ff:	b8 02 00 00 00       	mov    $0x2,%eax
 504:	cd 40                	int    $0x40
 506:	c3                   	ret    

00000507 <wait>:
SYSCALL(wait)
 507:	b8 03 00 00 00       	mov    $0x3,%eax
 50c:	cd 40                	int    $0x40
 50e:	c3                   	ret    

0000050f <pipe>:
SYSCALL(pipe)
 50f:	b8 04 00 00 00       	mov    $0x4,%eax
 514:	cd 40                	int    $0x40
 516:	c3                   	ret    

00000517 <read>:
SYSCALL(read)
 517:	b8 05 00 00 00       	mov    $0x5,%eax
 51c:	cd 40                	int    $0x40
 51e:	c3                   	ret    

0000051f <write>:
SYSCALL(write)
 51f:	b8 10 00 00 00       	mov    $0x10,%eax
 524:	cd 40                	int    $0x40
 526:	c3                   	ret    

00000527 <close>:
SYSCALL(close)
 527:	b8 15 00 00 00       	mov    $0x15,%eax
 52c:	cd 40                	int    $0x40
 52e:	c3                   	ret    

0000052f <kill>:
SYSCALL(kill)
 52f:	b8 06 00 00 00       	mov    $0x6,%eax
 534:	cd 40                	int    $0x40
 536:	c3                   	ret    

00000537 <exec>:
SYSCALL(exec)
 537:	b8 07 00 00 00       	mov    $0x7,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	ret    

0000053f <open>:
SYSCALL(open)
 53f:	b8 0f 00 00 00       	mov    $0xf,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	ret    

00000547 <mknod>:
SYSCALL(mknod)
 547:	b8 11 00 00 00       	mov    $0x11,%eax
 54c:	cd 40                	int    $0x40
 54e:	c3                   	ret    

0000054f <unlink>:
SYSCALL(unlink)
 54f:	b8 12 00 00 00       	mov    $0x12,%eax
 554:	cd 40                	int    $0x40
 556:	c3                   	ret    

00000557 <fstat>:
SYSCALL(fstat)
 557:	b8 08 00 00 00       	mov    $0x8,%eax
 55c:	cd 40                	int    $0x40
 55e:	c3                   	ret    

0000055f <link>:
SYSCALL(link)
 55f:	b8 13 00 00 00       	mov    $0x13,%eax
 564:	cd 40                	int    $0x40
 566:	c3                   	ret    

00000567 <mkdir>:
SYSCALL(mkdir)
 567:	b8 14 00 00 00       	mov    $0x14,%eax
 56c:	cd 40                	int    $0x40
 56e:	c3                   	ret    

0000056f <chdir>:
SYSCALL(chdir)
 56f:	b8 09 00 00 00       	mov    $0x9,%eax
 574:	cd 40                	int    $0x40
 576:	c3                   	ret    

00000577 <dup>:
SYSCALL(dup)
 577:	b8 0a 00 00 00       	mov    $0xa,%eax
 57c:	cd 40                	int    $0x40
 57e:	c3                   	ret    

0000057f <getpid>:
SYSCALL(getpid)
 57f:	b8 0b 00 00 00       	mov    $0xb,%eax
 584:	cd 40                	int    $0x40
 586:	c3                   	ret    

00000587 <sbrk>:
SYSCALL(sbrk)
 587:	b8 0c 00 00 00       	mov    $0xc,%eax
 58c:	cd 40                	int    $0x40
 58e:	c3                   	ret    

0000058f <sleep>:
SYSCALL(sleep)
 58f:	b8 0d 00 00 00       	mov    $0xd,%eax
 594:	cd 40                	int    $0x40
 596:	c3                   	ret    

00000597 <uptime>:
SYSCALL(uptime)
 597:	b8 0e 00 00 00       	mov    $0xe,%eax
 59c:	cd 40                	int    $0x40
 59e:	c3                   	ret    

0000059f <uthread_init>:

SYSCALL(uthread_init)
 59f:	b8 16 00 00 00       	mov    $0x16,%eax
 5a4:	cd 40                	int    $0x40
 5a6:	c3                   	ret    

000005a7 <check_thread>:
SYSCALL(check_thread)
 5a7:	b8 17 00 00 00       	mov    $0x17,%eax
 5ac:	cd 40                	int    $0x40
 5ae:	c3                   	ret    

000005af <getpinfo>:

SYSCALL(getpinfo)
 5af:	b8 18 00 00 00       	mov    $0x18,%eax
 5b4:	cd 40                	int    $0x40
 5b6:	c3                   	ret    

000005b7 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 5b7:	b8 19 00 00 00       	mov    $0x19,%eax
 5bc:	cd 40                	int    $0x40
 5be:	c3                   	ret    

000005bf <yield>:
 5bf:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5c4:	cd 40                	int    $0x40
 5c6:	c3                   	ret    

000005c7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5c7:	55                   	push   %ebp
 5c8:	89 e5                	mov    %esp,%ebp
 5ca:	83 ec 18             	sub    $0x18,%esp
 5cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5d3:	83 ec 04             	sub    $0x4,%esp
 5d6:	6a 01                	push   $0x1
 5d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5db:	50                   	push   %eax
 5dc:	ff 75 08             	push   0x8(%ebp)
 5df:	e8 3b ff ff ff       	call   51f <write>
 5e4:	83 c4 10             	add    $0x10,%esp
}
 5e7:	90                   	nop
 5e8:	c9                   	leave  
 5e9:	c3                   	ret    

000005ea <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5ea:	55                   	push   %ebp
 5eb:	89 e5                	mov    %esp,%ebp
 5ed:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5f0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5f7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5fb:	74 17                	je     614 <printint+0x2a>
 5fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 601:	79 11                	jns    614 <printint+0x2a>
    neg = 1;
 603:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 60a:	8b 45 0c             	mov    0xc(%ebp),%eax
 60d:	f7 d8                	neg    %eax
 60f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 612:	eb 06                	jmp    61a <printint+0x30>
  } else {
    x = xx;
 614:	8b 45 0c             	mov    0xc(%ebp),%eax
 617:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 61a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 621:	8b 4d 10             	mov    0x10(%ebp),%ecx
 624:	8b 45 ec             	mov    -0x14(%ebp),%eax
 627:	ba 00 00 00 00       	mov    $0x0,%edx
 62c:	f7 f1                	div    %ecx
 62e:	89 d1                	mov    %edx,%ecx
 630:	8b 45 f4             	mov    -0xc(%ebp),%eax
 633:	8d 50 01             	lea    0x1(%eax),%edx
 636:	89 55 f4             	mov    %edx,-0xc(%ebp)
 639:	0f b6 91 a8 0d 00 00 	movzbl 0xda8(%ecx),%edx
 640:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 644:	8b 4d 10             	mov    0x10(%ebp),%ecx
 647:	8b 45 ec             	mov    -0x14(%ebp),%eax
 64a:	ba 00 00 00 00       	mov    $0x0,%edx
 64f:	f7 f1                	div    %ecx
 651:	89 45 ec             	mov    %eax,-0x14(%ebp)
 654:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 658:	75 c7                	jne    621 <printint+0x37>
  if(neg)
 65a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 65e:	74 2d                	je     68d <printint+0xa3>
    buf[i++] = '-';
 660:	8b 45 f4             	mov    -0xc(%ebp),%eax
 663:	8d 50 01             	lea    0x1(%eax),%edx
 666:	89 55 f4             	mov    %edx,-0xc(%ebp)
 669:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 66e:	eb 1d                	jmp    68d <printint+0xa3>
    putc(fd, buf[i]);
 670:	8d 55 dc             	lea    -0x24(%ebp),%edx
 673:	8b 45 f4             	mov    -0xc(%ebp),%eax
 676:	01 d0                	add    %edx,%eax
 678:	0f b6 00             	movzbl (%eax),%eax
 67b:	0f be c0             	movsbl %al,%eax
 67e:	83 ec 08             	sub    $0x8,%esp
 681:	50                   	push   %eax
 682:	ff 75 08             	push   0x8(%ebp)
 685:	e8 3d ff ff ff       	call   5c7 <putc>
 68a:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 68d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 691:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 695:	79 d9                	jns    670 <printint+0x86>
}
 697:	90                   	nop
 698:	90                   	nop
 699:	c9                   	leave  
 69a:	c3                   	ret    

0000069b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 69b:	55                   	push   %ebp
 69c:	89 e5                	mov    %esp,%ebp
 69e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6a1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6a8:	8d 45 0c             	lea    0xc(%ebp),%eax
 6ab:	83 c0 04             	add    $0x4,%eax
 6ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6b8:	e9 59 01 00 00       	jmp    816 <printf+0x17b>
    c = fmt[i] & 0xff;
 6bd:	8b 55 0c             	mov    0xc(%ebp),%edx
 6c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c3:	01 d0                	add    %edx,%eax
 6c5:	0f b6 00             	movzbl (%eax),%eax
 6c8:	0f be c0             	movsbl %al,%eax
 6cb:	25 ff 00 00 00       	and    $0xff,%eax
 6d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6d7:	75 2c                	jne    705 <printf+0x6a>
      if(c == '%'){
 6d9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6dd:	75 0c                	jne    6eb <printf+0x50>
        state = '%';
 6df:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6e6:	e9 27 01 00 00       	jmp    812 <printf+0x177>
      } else {
        putc(fd, c);
 6eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ee:	0f be c0             	movsbl %al,%eax
 6f1:	83 ec 08             	sub    $0x8,%esp
 6f4:	50                   	push   %eax
 6f5:	ff 75 08             	push   0x8(%ebp)
 6f8:	e8 ca fe ff ff       	call   5c7 <putc>
 6fd:	83 c4 10             	add    $0x10,%esp
 700:	e9 0d 01 00 00       	jmp    812 <printf+0x177>
      }
    } else if(state == '%'){
 705:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 709:	0f 85 03 01 00 00    	jne    812 <printf+0x177>
      if(c == 'd'){
 70f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 713:	75 1e                	jne    733 <printf+0x98>
        printint(fd, *ap, 10, 1);
 715:	8b 45 e8             	mov    -0x18(%ebp),%eax
 718:	8b 00                	mov    (%eax),%eax
 71a:	6a 01                	push   $0x1
 71c:	6a 0a                	push   $0xa
 71e:	50                   	push   %eax
 71f:	ff 75 08             	push   0x8(%ebp)
 722:	e8 c3 fe ff ff       	call   5ea <printint>
 727:	83 c4 10             	add    $0x10,%esp
        ap++;
 72a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72e:	e9 d8 00 00 00       	jmp    80b <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 733:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 737:	74 06                	je     73f <printf+0xa4>
 739:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 73d:	75 1e                	jne    75d <printf+0xc2>
        printint(fd, *ap, 16, 0);
 73f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 742:	8b 00                	mov    (%eax),%eax
 744:	6a 00                	push   $0x0
 746:	6a 10                	push   $0x10
 748:	50                   	push   %eax
 749:	ff 75 08             	push   0x8(%ebp)
 74c:	e8 99 fe ff ff       	call   5ea <printint>
 751:	83 c4 10             	add    $0x10,%esp
        ap++;
 754:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 758:	e9 ae 00 00 00       	jmp    80b <printf+0x170>
      } else if(c == 's'){
 75d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 761:	75 43                	jne    7a6 <printf+0x10b>
        s = (char*)*ap;
 763:	8b 45 e8             	mov    -0x18(%ebp),%eax
 766:	8b 00                	mov    (%eax),%eax
 768:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 76b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 76f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 773:	75 25                	jne    79a <printf+0xff>
          s = "(null)";
 775:	c7 45 f4 d2 0a 00 00 	movl   $0xad2,-0xc(%ebp)
        while(*s != 0){
 77c:	eb 1c                	jmp    79a <printf+0xff>
          putc(fd, *s);
 77e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 781:	0f b6 00             	movzbl (%eax),%eax
 784:	0f be c0             	movsbl %al,%eax
 787:	83 ec 08             	sub    $0x8,%esp
 78a:	50                   	push   %eax
 78b:	ff 75 08             	push   0x8(%ebp)
 78e:	e8 34 fe ff ff       	call   5c7 <putc>
 793:	83 c4 10             	add    $0x10,%esp
          s++;
 796:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 79a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79d:	0f b6 00             	movzbl (%eax),%eax
 7a0:	84 c0                	test   %al,%al
 7a2:	75 da                	jne    77e <printf+0xe3>
 7a4:	eb 65                	jmp    80b <printf+0x170>
        }
      } else if(c == 'c'){
 7a6:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7aa:	75 1d                	jne    7c9 <printf+0x12e>
        putc(fd, *ap);
 7ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7af:	8b 00                	mov    (%eax),%eax
 7b1:	0f be c0             	movsbl %al,%eax
 7b4:	83 ec 08             	sub    $0x8,%esp
 7b7:	50                   	push   %eax
 7b8:	ff 75 08             	push   0x8(%ebp)
 7bb:	e8 07 fe ff ff       	call   5c7 <putc>
 7c0:	83 c4 10             	add    $0x10,%esp
        ap++;
 7c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c7:	eb 42                	jmp    80b <printf+0x170>
      } else if(c == '%'){
 7c9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7cd:	75 17                	jne    7e6 <printf+0x14b>
        putc(fd, c);
 7cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d2:	0f be c0             	movsbl %al,%eax
 7d5:	83 ec 08             	sub    $0x8,%esp
 7d8:	50                   	push   %eax
 7d9:	ff 75 08             	push   0x8(%ebp)
 7dc:	e8 e6 fd ff ff       	call   5c7 <putc>
 7e1:	83 c4 10             	add    $0x10,%esp
 7e4:	eb 25                	jmp    80b <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7e6:	83 ec 08             	sub    $0x8,%esp
 7e9:	6a 25                	push   $0x25
 7eb:	ff 75 08             	push   0x8(%ebp)
 7ee:	e8 d4 fd ff ff       	call   5c7 <putc>
 7f3:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7f9:	0f be c0             	movsbl %al,%eax
 7fc:	83 ec 08             	sub    $0x8,%esp
 7ff:	50                   	push   %eax
 800:	ff 75 08             	push   0x8(%ebp)
 803:	e8 bf fd ff ff       	call   5c7 <putc>
 808:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 80b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 812:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 816:	8b 55 0c             	mov    0xc(%ebp),%edx
 819:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81c:	01 d0                	add    %edx,%eax
 81e:	0f b6 00             	movzbl (%eax),%eax
 821:	84 c0                	test   %al,%al
 823:	0f 85 94 fe ff ff    	jne    6bd <printf+0x22>
    }
  }
}
 829:	90                   	nop
 82a:	90                   	nop
 82b:	c9                   	leave  
 82c:	c3                   	ret    

0000082d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82d:	55                   	push   %ebp
 82e:	89 e5                	mov    %esp,%ebp
 830:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 833:	8b 45 08             	mov    0x8(%ebp),%eax
 836:	83 e8 08             	sub    $0x8,%eax
 839:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83c:	a1 08 8e 00 00       	mov    0x8e08,%eax
 841:	89 45 fc             	mov    %eax,-0x4(%ebp)
 844:	eb 24                	jmp    86a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 00                	mov    (%eax),%eax
 84b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 84e:	72 12                	jb     862 <free+0x35>
 850:	8b 45 f8             	mov    -0x8(%ebp),%eax
 853:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 856:	77 24                	ja     87c <free+0x4f>
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	8b 00                	mov    (%eax),%eax
 85d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 860:	72 1a                	jb     87c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 862:	8b 45 fc             	mov    -0x4(%ebp),%eax
 865:	8b 00                	mov    (%eax),%eax
 867:	89 45 fc             	mov    %eax,-0x4(%ebp)
 86a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 870:	76 d4                	jbe    846 <free+0x19>
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	8b 00                	mov    (%eax),%eax
 877:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 87a:	73 ca                	jae    846 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 87c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87f:	8b 40 04             	mov    0x4(%eax),%eax
 882:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 889:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88c:	01 c2                	add    %eax,%edx
 88e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 891:	8b 00                	mov    (%eax),%eax
 893:	39 c2                	cmp    %eax,%edx
 895:	75 24                	jne    8bb <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 897:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89a:	8b 50 04             	mov    0x4(%eax),%edx
 89d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a0:	8b 00                	mov    (%eax),%eax
 8a2:	8b 40 04             	mov    0x4(%eax),%eax
 8a5:	01 c2                	add    %eax,%edx
 8a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8aa:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b0:	8b 00                	mov    (%eax),%eax
 8b2:	8b 10                	mov    (%eax),%edx
 8b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b7:	89 10                	mov    %edx,(%eax)
 8b9:	eb 0a                	jmp    8c5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8be:	8b 10                	mov    (%eax),%edx
 8c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	8b 40 04             	mov    0x4(%eax),%eax
 8cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d5:	01 d0                	add    %edx,%eax
 8d7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8da:	75 20                	jne    8fc <free+0xcf>
    p->s.size += bp->s.size;
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	8b 50 04             	mov    0x4(%eax),%edx
 8e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e5:	8b 40 04             	mov    0x4(%eax),%eax
 8e8:	01 c2                	add    %eax,%edx
 8ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ed:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f3:	8b 10                	mov    (%eax),%edx
 8f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f8:	89 10                	mov    %edx,(%eax)
 8fa:	eb 08                	jmp    904 <free+0xd7>
  } else
    p->s.ptr = bp;
 8fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ff:	8b 55 f8             	mov    -0x8(%ebp),%edx
 902:	89 10                	mov    %edx,(%eax)
  freep = p;
 904:	8b 45 fc             	mov    -0x4(%ebp),%eax
 907:	a3 08 8e 00 00       	mov    %eax,0x8e08
}
 90c:	90                   	nop
 90d:	c9                   	leave  
 90e:	c3                   	ret    

0000090f <morecore>:

static Header*
morecore(uint nu)
{
 90f:	55                   	push   %ebp
 910:	89 e5                	mov    %esp,%ebp
 912:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 915:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 91c:	77 07                	ja     925 <morecore+0x16>
    nu = 4096;
 91e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 925:	8b 45 08             	mov    0x8(%ebp),%eax
 928:	c1 e0 03             	shl    $0x3,%eax
 92b:	83 ec 0c             	sub    $0xc,%esp
 92e:	50                   	push   %eax
 92f:	e8 53 fc ff ff       	call   587 <sbrk>
 934:	83 c4 10             	add    $0x10,%esp
 937:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 93a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 93e:	75 07                	jne    947 <morecore+0x38>
    return 0;
 940:	b8 00 00 00 00       	mov    $0x0,%eax
 945:	eb 26                	jmp    96d <morecore+0x5e>
  hp = (Header*)p;
 947:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 94d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 950:	8b 55 08             	mov    0x8(%ebp),%edx
 953:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 956:	8b 45 f0             	mov    -0x10(%ebp),%eax
 959:	83 c0 08             	add    $0x8,%eax
 95c:	83 ec 0c             	sub    $0xc,%esp
 95f:	50                   	push   %eax
 960:	e8 c8 fe ff ff       	call   82d <free>
 965:	83 c4 10             	add    $0x10,%esp
  return freep;
 968:	a1 08 8e 00 00       	mov    0x8e08,%eax
}
 96d:	c9                   	leave  
 96e:	c3                   	ret    

0000096f <malloc>:

void*
malloc(uint nbytes)
{
 96f:	55                   	push   %ebp
 970:	89 e5                	mov    %esp,%ebp
 972:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 975:	8b 45 08             	mov    0x8(%ebp),%eax
 978:	83 c0 07             	add    $0x7,%eax
 97b:	c1 e8 03             	shr    $0x3,%eax
 97e:	83 c0 01             	add    $0x1,%eax
 981:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 984:	a1 08 8e 00 00       	mov    0x8e08,%eax
 989:	89 45 f0             	mov    %eax,-0x10(%ebp)
 98c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 990:	75 23                	jne    9b5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 992:	c7 45 f0 00 8e 00 00 	movl   $0x8e00,-0x10(%ebp)
 999:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99c:	a3 08 8e 00 00       	mov    %eax,0x8e08
 9a1:	a1 08 8e 00 00       	mov    0x8e08,%eax
 9a6:	a3 00 8e 00 00       	mov    %eax,0x8e00
    base.s.size = 0;
 9ab:	c7 05 04 8e 00 00 00 	movl   $0x0,0x8e04
 9b2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b8:	8b 00                	mov    (%eax),%eax
 9ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c0:	8b 40 04             	mov    0x4(%eax),%eax
 9c3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9c6:	77 4d                	ja     a15 <malloc+0xa6>
      if(p->s.size == nunits)
 9c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cb:	8b 40 04             	mov    0x4(%eax),%eax
 9ce:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9d1:	75 0c                	jne    9df <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d6:	8b 10                	mov    (%eax),%edx
 9d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9db:	89 10                	mov    %edx,(%eax)
 9dd:	eb 26                	jmp    a05 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e2:	8b 40 04             	mov    0x4(%eax),%eax
 9e5:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9e8:	89 c2                	mov    %eax,%edx
 9ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ed:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f3:	8b 40 04             	mov    0x4(%eax),%eax
 9f6:	c1 e0 03             	shl    $0x3,%eax
 9f9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a02:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a08:	a3 08 8e 00 00       	mov    %eax,0x8e08
      return (void*)(p + 1);
 a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a10:	83 c0 08             	add    $0x8,%eax
 a13:	eb 3b                	jmp    a50 <malloc+0xe1>
    }
    if(p == freep)
 a15:	a1 08 8e 00 00       	mov    0x8e08,%eax
 a1a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a1d:	75 1e                	jne    a3d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a1f:	83 ec 0c             	sub    $0xc,%esp
 a22:	ff 75 ec             	push   -0x14(%ebp)
 a25:	e8 e5 fe ff ff       	call   90f <morecore>
 a2a:	83 c4 10             	add    $0x10,%esp
 a2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a34:	75 07                	jne    a3d <malloc+0xce>
        return 0;
 a36:	b8 00 00 00 00       	mov    $0x0,%eax
 a3b:	eb 13                	jmp    a50 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a40:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a46:	8b 00                	mov    (%eax),%eax
 a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a4b:	e9 6d ff ff ff       	jmp    9bd <malloc+0x4e>
  }
}
 a50:	c9                   	leave  
 a51:	c3                   	ret    
