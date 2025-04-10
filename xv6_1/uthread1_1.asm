
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
thread_p  next_thread;
extern void thread_switch(void);

static void 
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
   6:	c7 05 04 0e 00 00 00 	movl   $0x0,0xe04
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 20 0e 00 00 	movl   $0xe20,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 00 0e 00 00       	mov    0xe00,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 04 0e 00 00       	mov    %eax,0xe04
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  42:	b8 40 8e 00 00       	mov    $0x8e40,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 40 8e 00 00       	mov    $0x8e40,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 00 0e 00 00       	mov    0xe00,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 00 0e 00 00       	mov    0xe00,%eax
  6b:	a3 04 0e 00 00       	mov    %eax,0xe04
  }

  if (next_thread == 0) {
  70:	a1 04 0e 00 00       	mov    0xe04,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 50 0a 00 00       	push   $0xa50
  81:	6a 02                	push   $0x2
  83:	e8 10 06 00 00       	call   698 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 8c 04 00 00       	call   51c <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 00 0e 00 00    	mov    0xe00,%edx
  96:	a1 04 0e 00 00       	mov    0xe04,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 25                	je     c4 <thread_schedule+0xc4>
    next_thread->state = RUNNING;
  9f:	a1 04 0e 00 00       	mov    0xe04,%eax
  a4:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ab:	00 00 00 
    current_thread->state = RUNNABLE;
  ae:	a1 00 0e 00 00       	mov    0xe00,%eax
  b3:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  ba:	00 00 00 
    thread_switch();
  bd:	e8 e7 01 00 00       	call   2a9 <thread_switch>
  } else
    next_thread = 0;
}
  c2:	eb 0a                	jmp    ce <thread_schedule+0xce>
    next_thread = 0;
  c4:	c7 05 04 0e 00 00 00 	movl   $0x0,0xe04
  cb:	00 00 00 
}
  ce:	90                   	nop
  cf:	c9                   	leave  
  d0:	c3                   	ret    

000000d1 <thread_init>:

void 
thread_init(void)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[thread_init()] thread_schedule ptr: 0x%x\n", (unsigned int)thread_schedule);
  d7:	b8 00 00 00 00       	mov    $0x0,%eax
  dc:	83 ec 04             	sub    $0x4,%esp
  df:	50                   	push   %eax
  e0:	68 78 0a 00 00       	push   $0xa78
  e5:	6a 01                	push   $0x1
  e7:	e8 ac 05 00 00       	call   698 <printf>
  ec:	83 c4 10             	add    $0x10,%esp
  uthread_init(thread_schedule);
  ef:	83 ec 0c             	sub    $0xc,%esp
  f2:	68 00 00 00 00       	push   $0x0
  f7:	e8 c0 04 00 00       	call   5bc <uthread_init>
  fc:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  for (int i = 0; i < MAX_THREAD; i++) {
  ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 106:	eb 18                	jmp    120 <thread_init+0x4f>
    all_thread[i].state = FREE;
 108:	8b 45 f4             	mov    -0xc(%ebp),%eax
 10b:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 111:	05 24 2e 00 00       	add    $0x2e24,%eax
 116:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for (int i = 0; i < MAX_THREAD; i++) {
 11c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 120:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
 124:	7e e2                	jle    108 <thread_init+0x37>
  }

  //uthread_init(/*(int)*/thread_schedule);  // 주소 전달
  current_thread = &all_thread[0];
 126:	c7 05 00 0e 00 00 20 	movl   $0xe20,0xe00
 12d:	0e 00 00 
  current_thread->state = RUNNING;
 130:	a1 00 0e 00 00       	mov    0xe00,%eax
 135:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 13c:	00 00 00 
}
 13f:	90                   	nop
 140:	c9                   	leave  
 141:	c3                   	ret    

00000142 <thread_create>:

void 
thread_create(void (*func)())
{
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
 145:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 148:	c7 45 f4 20 0e 00 00 	movl   $0xe20,-0xc(%ebp)
 14f:	eb 73                	jmp    1c4 <thread_create+0x82>
    if (t->state == FREE){
 151:	8b 45 f4             	mov    -0xc(%ebp),%eax
 154:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 15a:	85 c0                	test   %eax,%eax
 15c:	75 5f                	jne    1bd <thread_create+0x7b>
      t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 15e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 161:	83 c0 04             	add    $0x4,%eax
 164:	05 00 20 00 00       	add    $0x2000,%eax
 169:	89 c2                	mov    %eax,%edx
 16b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16e:	89 10                	mov    %edx,(%eax)
      t->sp -= 4;                              // space for return address
 170:	8b 45 f4             	mov    -0xc(%ebp),%eax
 173:	8b 00                	mov    (%eax),%eax
 175:	8d 50 fc             	lea    -0x4(%eax),%edx
 178:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17b:	89 10                	mov    %edx,(%eax)
      * (int *) (t->sp) = (int)func;           // push return address on stack
 17d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 180:	8b 00                	mov    (%eax),%eax
 182:	89 c2                	mov    %eax,%edx
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	89 02                	mov    %eax,(%edx)
      t->sp -= 32;                             // space for registers that thread_switch expects
 189:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18c:	8b 00                	mov    (%eax),%eax
 18e:	8d 50 e0             	lea    -0x20(%eax),%edx
 191:	8b 45 f4             	mov    -0xc(%ebp),%eax
 194:	89 10                	mov    %edx,(%eax)
      t->state = RUNNABLE;
 196:	8b 45 f4             	mov    -0xc(%ebp),%eax
 199:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1a0:	00 00 00 

      printf(1, "created thread at 0x%x, sp = 0x%x\n", t, t->sp);
 1a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a6:	8b 00                	mov    (%eax),%eax
 1a8:	50                   	push   %eax
 1a9:	ff 75 f4             	push   -0xc(%ebp)
 1ac:	68 a4 0a 00 00       	push   $0xaa4
 1b1:	6a 01                	push   $0x1
 1b3:	e8 e0 04 00 00       	call   698 <printf>
 1b8:	83 c4 10             	add    $0x10,%esp
      return;
 1bb:	eb 23                	jmp    1e0 <thread_create+0x9e>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 1bd:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 1c4:	b8 40 8e 00 00       	mov    $0x8e40,%eax
 1c9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 1cc:	72 83                	jb     151 <thread_create+0xf>
    }
  }
  printf(1, "thread_create: no FREE slot\n");
 1ce:	83 ec 08             	sub    $0x8,%esp
 1d1:	68 c7 0a 00 00       	push   $0xac7
 1d6:	6a 01                	push   $0x1
 1d8:	e8 bb 04 00 00       	call   698 <printf>
 1dd:	83 c4 10             	add    $0x10,%esp
}
 1e0:	c9                   	leave  
 1e1:	c3                   	ret    

000001e2 <mythread>:

static void 
mythread(void)
{
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
 1e5:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1e8:	83 ec 08             	sub    $0x8,%esp
 1eb:	68 e4 0a 00 00       	push   $0xae4
 1f0:	6a 01                	push   $0x1
 1f2:	e8 a1 04 00 00       	call   698 <printf>
 1f7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 201:	eb 1c                	jmp    21f <mythread+0x3d>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 203:	a1 00 0e 00 00       	mov    0xe00,%eax
 208:	83 ec 04             	sub    $0x4,%esp
 20b:	50                   	push   %eax
 20c:	68 f7 0a 00 00       	push   $0xaf7
 211:	6a 01                	push   $0x1
 213:	e8 80 04 00 00       	call   698 <printf>
 218:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 21b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 21f:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 223:	7e de                	jle    203 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 225:	83 ec 08             	sub    $0x8,%esp
 228:	68 07 0b 00 00       	push   $0xb07
 22d:	6a 01                	push   $0x1
 22f:	e8 64 04 00 00       	call   698 <printf>
 234:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 237:	a1 00 0e 00 00       	mov    0xe00,%eax
 23c:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 243:	00 00 00 
}
 246:	90                   	nop
 247:	c9                   	leave  
 248:	c3                   	ret    

00000249 <main>:


int 
main(int argc, char *argv[]) 
{
 249:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 24d:	83 e4 f0             	and    $0xfffffff0,%esp
 250:	ff 71 fc             	push   -0x4(%ecx)
 253:	55                   	push   %ebp
 254:	89 e5                	mov    %esp,%ebp
 256:	51                   	push   %ecx
 257:	83 ec 04             	sub    $0x4,%esp
  printf(1, "[thread_init()] thread_schedule ptr: 0x%x\n", (unsigned int)thread_schedule);
 25a:	b8 00 00 00 00       	mov    $0x0,%eax
 25f:	83 ec 04             	sub    $0x4,%esp
 262:	50                   	push   %eax
 263:	68 78 0a 00 00       	push   $0xa78
 268:	6a 01                	push   $0x1
 26a:	e8 29 04 00 00       	call   698 <printf>
 26f:	83 c4 10             	add    $0x10,%esp
  thread_init();
 272:	e8 5a fe ff ff       	call   d1 <thread_init>
  thread_create(mythread);
 277:	83 ec 0c             	sub    $0xc,%esp
 27a:	68 e2 01 00 00       	push   $0x1e2
 27f:	e8 be fe ff ff       	call   142 <thread_create>
 284:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 287:	83 ec 0c             	sub    $0xc,%esp
 28a:	68 e2 01 00 00       	push   $0x1e2
 28f:	e8 ae fe ff ff       	call   142 <thread_create>
 294:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 297:	e8 64 fd ff ff       	call   0 <thread_schedule>
  return 0;
 29c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2a1:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2a4:	c9                   	leave  
 2a5:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2a8:	c3                   	ret    

000002a9 <thread_switch>:
.globl thread_switch
.type thread_switch, @function
thread_switch:
    # Save caller-saved registers (if needed), but we skip this
    # Save callee-saved registers
    pushl %ebp
 2a9:	55                   	push   %ebp
    pushl %ebx
 2aa:	53                   	push   %ebx
    pushl %esi
 2ab:	56                   	push   %esi
    pushl %edi
 2ac:	57                   	push   %edi

    # Save current_thread's stack pointer
    movl current_thread, %eax
 2ad:	a1 00 0e 00 00       	mov    0xe00,%eax
    movl %esp, (%eax)
 2b2:	89 20                	mov    %esp,(%eax)

    # Load next_thread's stack pointer
    movl next_thread, %eax
 2b4:	a1 04 0e 00 00       	mov    0xe04,%eax
    movl (%eax), %esp
 2b9:	8b 20                	mov    (%eax),%esp

    # Update current_thread
    movl %eax, current_thread
 2bb:	a3 00 0e 00 00       	mov    %eax,0xe00

    # Restore callee-saved registers
    popl %edi
 2c0:	5f                   	pop    %edi
    popl %esi
 2c1:	5e                   	pop    %esi
    popl %ebx
 2c2:	5b                   	pop    %ebx
    popl %ebp
 2c3:	5d                   	pop    %ebp

    ret
 2c4:	c3                   	ret    

000002c5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2c5:	55                   	push   %ebp
 2c6:	89 e5                	mov    %esp,%ebp
 2c8:	57                   	push   %edi
 2c9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2cd:	8b 55 10             	mov    0x10(%ebp),%edx
 2d0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d3:	89 cb                	mov    %ecx,%ebx
 2d5:	89 df                	mov    %ebx,%edi
 2d7:	89 d1                	mov    %edx,%ecx
 2d9:	fc                   	cld    
 2da:	f3 aa                	rep stos %al,%es:(%edi)
 2dc:	89 ca                	mov    %ecx,%edx
 2de:	89 fb                	mov    %edi,%ebx
 2e0:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2e3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2e6:	90                   	nop
 2e7:	5b                   	pop    %ebx
 2e8:	5f                   	pop    %edi
 2e9:	5d                   	pop    %ebp
 2ea:	c3                   	ret    

000002eb <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2eb:	55                   	push   %ebp
 2ec:	89 e5                	mov    %esp,%ebp
 2ee:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2f1:	8b 45 08             	mov    0x8(%ebp),%eax
 2f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2f7:	90                   	nop
 2f8:	8b 55 0c             	mov    0xc(%ebp),%edx
 2fb:	8d 42 01             	lea    0x1(%edx),%eax
 2fe:	89 45 0c             	mov    %eax,0xc(%ebp)
 301:	8b 45 08             	mov    0x8(%ebp),%eax
 304:	8d 48 01             	lea    0x1(%eax),%ecx
 307:	89 4d 08             	mov    %ecx,0x8(%ebp)
 30a:	0f b6 12             	movzbl (%edx),%edx
 30d:	88 10                	mov    %dl,(%eax)
 30f:	0f b6 00             	movzbl (%eax),%eax
 312:	84 c0                	test   %al,%al
 314:	75 e2                	jne    2f8 <strcpy+0xd>
    ;
  return os;
 316:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 319:	c9                   	leave  
 31a:	c3                   	ret    

0000031b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 31b:	55                   	push   %ebp
 31c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 31e:	eb 08                	jmp    328 <strcmp+0xd>
    p++, q++;
 320:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 324:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	0f b6 00             	movzbl (%eax),%eax
 32e:	84 c0                	test   %al,%al
 330:	74 10                	je     342 <strcmp+0x27>
 332:	8b 45 08             	mov    0x8(%ebp),%eax
 335:	0f b6 10             	movzbl (%eax),%edx
 338:	8b 45 0c             	mov    0xc(%ebp),%eax
 33b:	0f b6 00             	movzbl (%eax),%eax
 33e:	38 c2                	cmp    %al,%dl
 340:	74 de                	je     320 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 342:	8b 45 08             	mov    0x8(%ebp),%eax
 345:	0f b6 00             	movzbl (%eax),%eax
 348:	0f b6 d0             	movzbl %al,%edx
 34b:	8b 45 0c             	mov    0xc(%ebp),%eax
 34e:	0f b6 00             	movzbl (%eax),%eax
 351:	0f b6 c8             	movzbl %al,%ecx
 354:	89 d0                	mov    %edx,%eax
 356:	29 c8                	sub    %ecx,%eax
}
 358:	5d                   	pop    %ebp
 359:	c3                   	ret    

0000035a <strlen>:

uint
strlen(char *s)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 360:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 367:	eb 04                	jmp    36d <strlen+0x13>
 369:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 36d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 370:	8b 45 08             	mov    0x8(%ebp),%eax
 373:	01 d0                	add    %edx,%eax
 375:	0f b6 00             	movzbl (%eax),%eax
 378:	84 c0                	test   %al,%al
 37a:	75 ed                	jne    369 <strlen+0xf>
    ;
  return n;
 37c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 37f:	c9                   	leave  
 380:	c3                   	ret    

00000381 <memset>:

void*
memset(void *dst, int c, uint n)
{
 381:	55                   	push   %ebp
 382:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 384:	8b 45 10             	mov    0x10(%ebp),%eax
 387:	50                   	push   %eax
 388:	ff 75 0c             	push   0xc(%ebp)
 38b:	ff 75 08             	push   0x8(%ebp)
 38e:	e8 32 ff ff ff       	call   2c5 <stosb>
 393:	83 c4 0c             	add    $0xc,%esp
  return dst;
 396:	8b 45 08             	mov    0x8(%ebp),%eax
}
 399:	c9                   	leave  
 39a:	c3                   	ret    

0000039b <strchr>:

char*
strchr(const char *s, char c)
{
 39b:	55                   	push   %ebp
 39c:	89 e5                	mov    %esp,%ebp
 39e:	83 ec 04             	sub    $0x4,%esp
 3a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a4:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3a7:	eb 14                	jmp    3bd <strchr+0x22>
    if(*s == c)
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	0f b6 00             	movzbl (%eax),%eax
 3af:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3b2:	75 05                	jne    3b9 <strchr+0x1e>
      return (char*)s;
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	eb 13                	jmp    3cc <strchr+0x31>
  for(; *s; s++)
 3b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	0f b6 00             	movzbl (%eax),%eax
 3c3:	84 c0                	test   %al,%al
 3c5:	75 e2                	jne    3a9 <strchr+0xe>
  return 0;
 3c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3cc:	c9                   	leave  
 3cd:	c3                   	ret    

000003ce <gets>:

char*
gets(char *buf, int max)
{
 3ce:	55                   	push   %ebp
 3cf:	89 e5                	mov    %esp,%ebp
 3d1:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3db:	eb 42                	jmp    41f <gets+0x51>
    cc = read(0, &c, 1);
 3dd:	83 ec 04             	sub    $0x4,%esp
 3e0:	6a 01                	push   $0x1
 3e2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3e5:	50                   	push   %eax
 3e6:	6a 00                	push   $0x0
 3e8:	e8 47 01 00 00       	call   534 <read>
 3ed:	83 c4 10             	add    $0x10,%esp
 3f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f7:	7e 33                	jle    42c <gets+0x5e>
      break;
    buf[i++] = c;
 3f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fc:	8d 50 01             	lea    0x1(%eax),%edx
 3ff:	89 55 f4             	mov    %edx,-0xc(%ebp)
 402:	89 c2                	mov    %eax,%edx
 404:	8b 45 08             	mov    0x8(%ebp),%eax
 407:	01 c2                	add    %eax,%edx
 409:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 40d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 40f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 413:	3c 0a                	cmp    $0xa,%al
 415:	74 16                	je     42d <gets+0x5f>
 417:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 41b:	3c 0d                	cmp    $0xd,%al
 41d:	74 0e                	je     42d <gets+0x5f>
  for(i=0; i+1 < max; ){
 41f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 422:	83 c0 01             	add    $0x1,%eax
 425:	39 45 0c             	cmp    %eax,0xc(%ebp)
 428:	7f b3                	jg     3dd <gets+0xf>
 42a:	eb 01                	jmp    42d <gets+0x5f>
      break;
 42c:	90                   	nop
      break;
  }
  buf[i] = '\0';
 42d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 430:	8b 45 08             	mov    0x8(%ebp),%eax
 433:	01 d0                	add    %edx,%eax
 435:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 438:	8b 45 08             	mov    0x8(%ebp),%eax
}
 43b:	c9                   	leave  
 43c:	c3                   	ret    

0000043d <stat>:

int
stat(char *n, struct stat *st)
{
 43d:	55                   	push   %ebp
 43e:	89 e5                	mov    %esp,%ebp
 440:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 443:	83 ec 08             	sub    $0x8,%esp
 446:	6a 00                	push   $0x0
 448:	ff 75 08             	push   0x8(%ebp)
 44b:	e8 0c 01 00 00       	call   55c <open>
 450:	83 c4 10             	add    $0x10,%esp
 453:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 456:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 45a:	79 07                	jns    463 <stat+0x26>
    return -1;
 45c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 461:	eb 25                	jmp    488 <stat+0x4b>
  r = fstat(fd, st);
 463:	83 ec 08             	sub    $0x8,%esp
 466:	ff 75 0c             	push   0xc(%ebp)
 469:	ff 75 f4             	push   -0xc(%ebp)
 46c:	e8 03 01 00 00       	call   574 <fstat>
 471:	83 c4 10             	add    $0x10,%esp
 474:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 477:	83 ec 0c             	sub    $0xc,%esp
 47a:	ff 75 f4             	push   -0xc(%ebp)
 47d:	e8 c2 00 00 00       	call   544 <close>
 482:	83 c4 10             	add    $0x10,%esp
  return r;
 485:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 488:	c9                   	leave  
 489:	c3                   	ret    

0000048a <atoi>:

int
atoi(const char *s)
{
 48a:	55                   	push   %ebp
 48b:	89 e5                	mov    %esp,%ebp
 48d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 490:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 497:	eb 25                	jmp    4be <atoi+0x34>
    n = n*10 + *s++ - '0';
 499:	8b 55 fc             	mov    -0x4(%ebp),%edx
 49c:	89 d0                	mov    %edx,%eax
 49e:	c1 e0 02             	shl    $0x2,%eax
 4a1:	01 d0                	add    %edx,%eax
 4a3:	01 c0                	add    %eax,%eax
 4a5:	89 c1                	mov    %eax,%ecx
 4a7:	8b 45 08             	mov    0x8(%ebp),%eax
 4aa:	8d 50 01             	lea    0x1(%eax),%edx
 4ad:	89 55 08             	mov    %edx,0x8(%ebp)
 4b0:	0f b6 00             	movzbl (%eax),%eax
 4b3:	0f be c0             	movsbl %al,%eax
 4b6:	01 c8                	add    %ecx,%eax
 4b8:	83 e8 30             	sub    $0x30,%eax
 4bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4be:	8b 45 08             	mov    0x8(%ebp),%eax
 4c1:	0f b6 00             	movzbl (%eax),%eax
 4c4:	3c 2f                	cmp    $0x2f,%al
 4c6:	7e 0a                	jle    4d2 <atoi+0x48>
 4c8:	8b 45 08             	mov    0x8(%ebp),%eax
 4cb:	0f b6 00             	movzbl (%eax),%eax
 4ce:	3c 39                	cmp    $0x39,%al
 4d0:	7e c7                	jle    499 <atoi+0xf>
  return n;
 4d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4d5:	c9                   	leave  
 4d6:	c3                   	ret    

000004d7 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4d7:	55                   	push   %ebp
 4d8:	89 e5                	mov    %esp,%ebp
 4da:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4dd:	8b 45 08             	mov    0x8(%ebp),%eax
 4e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4e3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4e9:	eb 17                	jmp    502 <memmove+0x2b>
    *dst++ = *src++;
 4eb:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4ee:	8d 42 01             	lea    0x1(%edx),%eax
 4f1:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4f7:	8d 48 01             	lea    0x1(%eax),%ecx
 4fa:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4fd:	0f b6 12             	movzbl (%edx),%edx
 500:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 502:	8b 45 10             	mov    0x10(%ebp),%eax
 505:	8d 50 ff             	lea    -0x1(%eax),%edx
 508:	89 55 10             	mov    %edx,0x10(%ebp)
 50b:	85 c0                	test   %eax,%eax
 50d:	7f dc                	jg     4eb <memmove+0x14>
  return vdst;
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 512:	c9                   	leave  
 513:	c3                   	ret    

00000514 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 514:	b8 01 00 00 00       	mov    $0x1,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <exit>:
SYSCALL(exit)
 51c:	b8 02 00 00 00       	mov    $0x2,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <wait>:
SYSCALL(wait)
 524:	b8 03 00 00 00       	mov    $0x3,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <pipe>:
SYSCALL(pipe)
 52c:	b8 04 00 00 00       	mov    $0x4,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <read>:
SYSCALL(read)
 534:	b8 05 00 00 00       	mov    $0x5,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <write>:
SYSCALL(write)
 53c:	b8 10 00 00 00       	mov    $0x10,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <close>:
SYSCALL(close)
 544:	b8 15 00 00 00       	mov    $0x15,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <kill>:
SYSCALL(kill)
 54c:	b8 06 00 00 00       	mov    $0x6,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <exec>:
SYSCALL(exec)
 554:	b8 07 00 00 00       	mov    $0x7,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <open>:
SYSCALL(open)
 55c:	b8 0f 00 00 00       	mov    $0xf,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <mknod>:
SYSCALL(mknod)
 564:	b8 11 00 00 00       	mov    $0x11,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <unlink>:
SYSCALL(unlink)
 56c:	b8 12 00 00 00       	mov    $0x12,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <fstat>:
SYSCALL(fstat)
 574:	b8 08 00 00 00       	mov    $0x8,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <link>:
SYSCALL(link)
 57c:	b8 13 00 00 00       	mov    $0x13,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <mkdir>:
SYSCALL(mkdir)
 584:	b8 14 00 00 00       	mov    $0x14,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <chdir>:
SYSCALL(chdir)
 58c:	b8 09 00 00 00       	mov    $0x9,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <dup>:
SYSCALL(dup)
 594:	b8 0a 00 00 00       	mov    $0xa,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <getpid>:
SYSCALL(getpid)
 59c:	b8 0b 00 00 00       	mov    $0xb,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <sbrk>:
SYSCALL(sbrk)
 5a4:	b8 0c 00 00 00       	mov    $0xc,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <sleep>:
SYSCALL(sleep)
 5ac:	b8 0d 00 00 00       	mov    $0xd,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <uptime>:
SYSCALL(uptime)
 5b4:	b8 0e 00 00 00       	mov    $0xe,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <uthread_init>:
 5bc:	b8 16 00 00 00       	mov    $0x16,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5c4:	55                   	push   %ebp
 5c5:	89 e5                	mov    %esp,%ebp
 5c7:	83 ec 18             	sub    $0x18,%esp
 5ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 5cd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5d0:	83 ec 04             	sub    $0x4,%esp
 5d3:	6a 01                	push   $0x1
 5d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5d8:	50                   	push   %eax
 5d9:	ff 75 08             	push   0x8(%ebp)
 5dc:	e8 5b ff ff ff       	call   53c <write>
 5e1:	83 c4 10             	add    $0x10,%esp
}
 5e4:	90                   	nop
 5e5:	c9                   	leave  
 5e6:	c3                   	ret    

000005e7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5e7:	55                   	push   %ebp
 5e8:	89 e5                	mov    %esp,%ebp
 5ea:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5f4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5f8:	74 17                	je     611 <printint+0x2a>
 5fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5fe:	79 11                	jns    611 <printint+0x2a>
    neg = 1;
 600:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 607:	8b 45 0c             	mov    0xc(%ebp),%eax
 60a:	f7 d8                	neg    %eax
 60c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 60f:	eb 06                	jmp    617 <printint+0x30>
  } else {
    x = xx;
 611:	8b 45 0c             	mov    0xc(%ebp),%eax
 614:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 617:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 61e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 621:	8b 45 ec             	mov    -0x14(%ebp),%eax
 624:	ba 00 00 00 00       	mov    $0x0,%edx
 629:	f7 f1                	div    %ecx
 62b:	89 d1                	mov    %edx,%ecx
 62d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 630:	8d 50 01             	lea    0x1(%eax),%edx
 633:	89 55 f4             	mov    %edx,-0xc(%ebp)
 636:	0f b6 91 ec 0d 00 00 	movzbl 0xdec(%ecx),%edx
 63d:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 641:	8b 4d 10             	mov    0x10(%ebp),%ecx
 644:	8b 45 ec             	mov    -0x14(%ebp),%eax
 647:	ba 00 00 00 00       	mov    $0x0,%edx
 64c:	f7 f1                	div    %ecx
 64e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 651:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 655:	75 c7                	jne    61e <printint+0x37>
  if(neg)
 657:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 65b:	74 2d                	je     68a <printint+0xa3>
    buf[i++] = '-';
 65d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 660:	8d 50 01             	lea    0x1(%eax),%edx
 663:	89 55 f4             	mov    %edx,-0xc(%ebp)
 666:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 66b:	eb 1d                	jmp    68a <printint+0xa3>
    putc(fd, buf[i]);
 66d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 670:	8b 45 f4             	mov    -0xc(%ebp),%eax
 673:	01 d0                	add    %edx,%eax
 675:	0f b6 00             	movzbl (%eax),%eax
 678:	0f be c0             	movsbl %al,%eax
 67b:	83 ec 08             	sub    $0x8,%esp
 67e:	50                   	push   %eax
 67f:	ff 75 08             	push   0x8(%ebp)
 682:	e8 3d ff ff ff       	call   5c4 <putc>
 687:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 68a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 68e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 692:	79 d9                	jns    66d <printint+0x86>
}
 694:	90                   	nop
 695:	90                   	nop
 696:	c9                   	leave  
 697:	c3                   	ret    

00000698 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 698:	55                   	push   %ebp
 699:	89 e5                	mov    %esp,%ebp
 69b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 69e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6a5:	8d 45 0c             	lea    0xc(%ebp),%eax
 6a8:	83 c0 04             	add    $0x4,%eax
 6ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6ae:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6b5:	e9 59 01 00 00       	jmp    813 <printf+0x17b>
    c = fmt[i] & 0xff;
 6ba:	8b 55 0c             	mov    0xc(%ebp),%edx
 6bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c0:	01 d0                	add    %edx,%eax
 6c2:	0f b6 00             	movzbl (%eax),%eax
 6c5:	0f be c0             	movsbl %al,%eax
 6c8:	25 ff 00 00 00       	and    $0xff,%eax
 6cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6d0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6d4:	75 2c                	jne    702 <printf+0x6a>
      if(c == '%'){
 6d6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6da:	75 0c                	jne    6e8 <printf+0x50>
        state = '%';
 6dc:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6e3:	e9 27 01 00 00       	jmp    80f <printf+0x177>
      } else {
        putc(fd, c);
 6e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6eb:	0f be c0             	movsbl %al,%eax
 6ee:	83 ec 08             	sub    $0x8,%esp
 6f1:	50                   	push   %eax
 6f2:	ff 75 08             	push   0x8(%ebp)
 6f5:	e8 ca fe ff ff       	call   5c4 <putc>
 6fa:	83 c4 10             	add    $0x10,%esp
 6fd:	e9 0d 01 00 00       	jmp    80f <printf+0x177>
      }
    } else if(state == '%'){
 702:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 706:	0f 85 03 01 00 00    	jne    80f <printf+0x177>
      if(c == 'd'){
 70c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 710:	75 1e                	jne    730 <printf+0x98>
        printint(fd, *ap, 10, 1);
 712:	8b 45 e8             	mov    -0x18(%ebp),%eax
 715:	8b 00                	mov    (%eax),%eax
 717:	6a 01                	push   $0x1
 719:	6a 0a                	push   $0xa
 71b:	50                   	push   %eax
 71c:	ff 75 08             	push   0x8(%ebp)
 71f:	e8 c3 fe ff ff       	call   5e7 <printint>
 724:	83 c4 10             	add    $0x10,%esp
        ap++;
 727:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72b:	e9 d8 00 00 00       	jmp    808 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 730:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 734:	74 06                	je     73c <printf+0xa4>
 736:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 73a:	75 1e                	jne    75a <printf+0xc2>
        printint(fd, *ap, 16, 0);
 73c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 73f:	8b 00                	mov    (%eax),%eax
 741:	6a 00                	push   $0x0
 743:	6a 10                	push   $0x10
 745:	50                   	push   %eax
 746:	ff 75 08             	push   0x8(%ebp)
 749:	e8 99 fe ff ff       	call   5e7 <printint>
 74e:	83 c4 10             	add    $0x10,%esp
        ap++;
 751:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 755:	e9 ae 00 00 00       	jmp    808 <printf+0x170>
      } else if(c == 's'){
 75a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 75e:	75 43                	jne    7a3 <printf+0x10b>
        s = (char*)*ap;
 760:	8b 45 e8             	mov    -0x18(%ebp),%eax
 763:	8b 00                	mov    (%eax),%eax
 765:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 768:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 76c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 770:	75 25                	jne    797 <printf+0xff>
          s = "(null)";
 772:	c7 45 f4 18 0b 00 00 	movl   $0xb18,-0xc(%ebp)
        while(*s != 0){
 779:	eb 1c                	jmp    797 <printf+0xff>
          putc(fd, *s);
 77b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77e:	0f b6 00             	movzbl (%eax),%eax
 781:	0f be c0             	movsbl %al,%eax
 784:	83 ec 08             	sub    $0x8,%esp
 787:	50                   	push   %eax
 788:	ff 75 08             	push   0x8(%ebp)
 78b:	e8 34 fe ff ff       	call   5c4 <putc>
 790:	83 c4 10             	add    $0x10,%esp
          s++;
 793:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 797:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79a:	0f b6 00             	movzbl (%eax),%eax
 79d:	84 c0                	test   %al,%al
 79f:	75 da                	jne    77b <printf+0xe3>
 7a1:	eb 65                	jmp    808 <printf+0x170>
        }
      } else if(c == 'c'){
 7a3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7a7:	75 1d                	jne    7c6 <printf+0x12e>
        putc(fd, *ap);
 7a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	0f be c0             	movsbl %al,%eax
 7b1:	83 ec 08             	sub    $0x8,%esp
 7b4:	50                   	push   %eax
 7b5:	ff 75 08             	push   0x8(%ebp)
 7b8:	e8 07 fe ff ff       	call   5c4 <putc>
 7bd:	83 c4 10             	add    $0x10,%esp
        ap++;
 7c0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c4:	eb 42                	jmp    808 <printf+0x170>
      } else if(c == '%'){
 7c6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ca:	75 17                	jne    7e3 <printf+0x14b>
        putc(fd, c);
 7cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7cf:	0f be c0             	movsbl %al,%eax
 7d2:	83 ec 08             	sub    $0x8,%esp
 7d5:	50                   	push   %eax
 7d6:	ff 75 08             	push   0x8(%ebp)
 7d9:	e8 e6 fd ff ff       	call   5c4 <putc>
 7de:	83 c4 10             	add    $0x10,%esp
 7e1:	eb 25                	jmp    808 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7e3:	83 ec 08             	sub    $0x8,%esp
 7e6:	6a 25                	push   $0x25
 7e8:	ff 75 08             	push   0x8(%ebp)
 7eb:	e8 d4 fd ff ff       	call   5c4 <putc>
 7f0:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7f6:	0f be c0             	movsbl %al,%eax
 7f9:	83 ec 08             	sub    $0x8,%esp
 7fc:	50                   	push   %eax
 7fd:	ff 75 08             	push   0x8(%ebp)
 800:	e8 bf fd ff ff       	call   5c4 <putc>
 805:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 808:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 80f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 813:	8b 55 0c             	mov    0xc(%ebp),%edx
 816:	8b 45 f0             	mov    -0x10(%ebp),%eax
 819:	01 d0                	add    %edx,%eax
 81b:	0f b6 00             	movzbl (%eax),%eax
 81e:	84 c0                	test   %al,%al
 820:	0f 85 94 fe ff ff    	jne    6ba <printf+0x22>
    }
  }
}
 826:	90                   	nop
 827:	90                   	nop
 828:	c9                   	leave  
 829:	c3                   	ret    

0000082a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82a:	55                   	push   %ebp
 82b:	89 e5                	mov    %esp,%ebp
 82d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 830:	8b 45 08             	mov    0x8(%ebp),%eax
 833:	83 e8 08             	sub    $0x8,%eax
 836:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 839:	a1 48 8e 00 00       	mov    0x8e48,%eax
 83e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 841:	eb 24                	jmp    867 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 843:	8b 45 fc             	mov    -0x4(%ebp),%eax
 846:	8b 00                	mov    (%eax),%eax
 848:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 84b:	72 12                	jb     85f <free+0x35>
 84d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 850:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 853:	77 24                	ja     879 <free+0x4f>
 855:	8b 45 fc             	mov    -0x4(%ebp),%eax
 858:	8b 00                	mov    (%eax),%eax
 85a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 85d:	72 1a                	jb     879 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 862:	8b 00                	mov    (%eax),%eax
 864:	89 45 fc             	mov    %eax,-0x4(%ebp)
 867:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 86d:	76 d4                	jbe    843 <free+0x19>
 86f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 872:	8b 00                	mov    (%eax),%eax
 874:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 877:	73 ca                	jae    843 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 879:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87c:	8b 40 04             	mov    0x4(%eax),%eax
 87f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 886:	8b 45 f8             	mov    -0x8(%ebp),%eax
 889:	01 c2                	add    %eax,%edx
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	8b 00                	mov    (%eax),%eax
 890:	39 c2                	cmp    %eax,%edx
 892:	75 24                	jne    8b8 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 894:	8b 45 f8             	mov    -0x8(%ebp),%eax
 897:	8b 50 04             	mov    0x4(%eax),%edx
 89a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89d:	8b 00                	mov    (%eax),%eax
 89f:	8b 40 04             	mov    0x4(%eax),%eax
 8a2:	01 c2                	add    %eax,%edx
 8a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a7:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ad:	8b 00                	mov    (%eax),%eax
 8af:	8b 10                	mov    (%eax),%edx
 8b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b4:	89 10                	mov    %edx,(%eax)
 8b6:	eb 0a                	jmp    8c2 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bb:	8b 10                	mov    (%eax),%edx
 8bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c5:	8b 40 04             	mov    0x4(%eax),%eax
 8c8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d2:	01 d0                	add    %edx,%eax
 8d4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8d7:	75 20                	jne    8f9 <free+0xcf>
    p->s.size += bp->s.size;
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	8b 50 04             	mov    0x4(%eax),%edx
 8df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e2:	8b 40 04             	mov    0x4(%eax),%eax
 8e5:	01 c2                	add    %eax,%edx
 8e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ea:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f0:	8b 10                	mov    (%eax),%edx
 8f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f5:	89 10                	mov    %edx,(%eax)
 8f7:	eb 08                	jmp    901 <free+0xd7>
  } else
    p->s.ptr = bp;
 8f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8ff:	89 10                	mov    %edx,(%eax)
  freep = p;
 901:	8b 45 fc             	mov    -0x4(%ebp),%eax
 904:	a3 48 8e 00 00       	mov    %eax,0x8e48
}
 909:	90                   	nop
 90a:	c9                   	leave  
 90b:	c3                   	ret    

0000090c <morecore>:

static Header*
morecore(uint nu)
{
 90c:	55                   	push   %ebp
 90d:	89 e5                	mov    %esp,%ebp
 90f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 912:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 919:	77 07                	ja     922 <morecore+0x16>
    nu = 4096;
 91b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 922:	8b 45 08             	mov    0x8(%ebp),%eax
 925:	c1 e0 03             	shl    $0x3,%eax
 928:	83 ec 0c             	sub    $0xc,%esp
 92b:	50                   	push   %eax
 92c:	e8 73 fc ff ff       	call   5a4 <sbrk>
 931:	83 c4 10             	add    $0x10,%esp
 934:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 937:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 93b:	75 07                	jne    944 <morecore+0x38>
    return 0;
 93d:	b8 00 00 00 00       	mov    $0x0,%eax
 942:	eb 26                	jmp    96a <morecore+0x5e>
  hp = (Header*)p;
 944:	8b 45 f4             	mov    -0xc(%ebp),%eax
 947:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 94a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94d:	8b 55 08             	mov    0x8(%ebp),%edx
 950:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 953:	8b 45 f0             	mov    -0x10(%ebp),%eax
 956:	83 c0 08             	add    $0x8,%eax
 959:	83 ec 0c             	sub    $0xc,%esp
 95c:	50                   	push   %eax
 95d:	e8 c8 fe ff ff       	call   82a <free>
 962:	83 c4 10             	add    $0x10,%esp
  return freep;
 965:	a1 48 8e 00 00       	mov    0x8e48,%eax
}
 96a:	c9                   	leave  
 96b:	c3                   	ret    

0000096c <malloc>:

void*
malloc(uint nbytes)
{
 96c:	55                   	push   %ebp
 96d:	89 e5                	mov    %esp,%ebp
 96f:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 972:	8b 45 08             	mov    0x8(%ebp),%eax
 975:	83 c0 07             	add    $0x7,%eax
 978:	c1 e8 03             	shr    $0x3,%eax
 97b:	83 c0 01             	add    $0x1,%eax
 97e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 981:	a1 48 8e 00 00       	mov    0x8e48,%eax
 986:	89 45 f0             	mov    %eax,-0x10(%ebp)
 989:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 98d:	75 23                	jne    9b2 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 98f:	c7 45 f0 40 8e 00 00 	movl   $0x8e40,-0x10(%ebp)
 996:	8b 45 f0             	mov    -0x10(%ebp),%eax
 999:	a3 48 8e 00 00       	mov    %eax,0x8e48
 99e:	a1 48 8e 00 00       	mov    0x8e48,%eax
 9a3:	a3 40 8e 00 00       	mov    %eax,0x8e40
    base.s.size = 0;
 9a8:	c7 05 44 8e 00 00 00 	movl   $0x0,0x8e44
 9af:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b5:	8b 00                	mov    (%eax),%eax
 9b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bd:	8b 40 04             	mov    0x4(%eax),%eax
 9c0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9c3:	77 4d                	ja     a12 <malloc+0xa6>
      if(p->s.size == nunits)
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	8b 40 04             	mov    0x4(%eax),%eax
 9cb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9ce:	75 0c                	jne    9dc <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d3:	8b 10                	mov    (%eax),%edx
 9d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d8:	89 10                	mov    %edx,(%eax)
 9da:	eb 26                	jmp    a02 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9df:	8b 40 04             	mov    0x4(%eax),%eax
 9e2:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9e5:	89 c2                	mov    %eax,%edx
 9e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ea:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f0:	8b 40 04             	mov    0x4(%eax),%eax
 9f3:	c1 e0 03             	shl    $0x3,%eax
 9f6:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9ff:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a05:	a3 48 8e 00 00       	mov    %eax,0x8e48
      return (void*)(p + 1);
 a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0d:	83 c0 08             	add    $0x8,%eax
 a10:	eb 3b                	jmp    a4d <malloc+0xe1>
    }
    if(p == freep)
 a12:	a1 48 8e 00 00       	mov    0x8e48,%eax
 a17:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a1a:	75 1e                	jne    a3a <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a1c:	83 ec 0c             	sub    $0xc,%esp
 a1f:	ff 75 ec             	push   -0x14(%ebp)
 a22:	e8 e5 fe ff ff       	call   90c <morecore>
 a27:	83 c4 10             	add    $0x10,%esp
 a2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a31:	75 07                	jne    a3a <malloc+0xce>
        return 0;
 a33:	b8 00 00 00 00       	mov    $0x0,%eax
 a38:	eb 13                	jmp    a4d <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a43:	8b 00                	mov    (%eax),%eax
 a45:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a48:	e9 6d ff ff ff       	jmp    9ba <malloc+0x4e>
  }
}
 a4d:	c9                   	leave  
 a4e:	c3                   	ret    
