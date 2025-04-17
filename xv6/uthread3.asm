
_uthread3:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
thread_p  next_thread;      //다음으로 실행할 스레드
extern void thread_switch(void);

static void 
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  thread_p t;   //thread_t 구조체의 포인터

  /* Find another runnable thread. */
  next_thread = 0;  // null로 초기화
   6:	c7 05 24 11 00 00 00 	movl   $0x0,0x1124
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 40 11 00 00 	movl   $0x1140,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    //모든 스레드 배열을 돌아다니면서
    //실행대기중이고 현재 스레드가 아닌 스레드를 찾아 next_thread에 할당
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 20 11 00 00       	mov    0x1120,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;  
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 24 11 00 00       	mov    %eax,0x1124
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 0c 20 00 00 	addl   $0x200c,-0xc(%ebp)
  42:	b8 b8 51 01 00       	mov    $0x151b8,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  // 스레드 배열 안에는 실행 가능한게 없고 현재 스레드가 runnable 상태면 
  // 현재 스레드를 계속 실행
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 b8 51 01 00       	mov    $0x151b8,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 20 11 00 00       	mov    0x1120,%eax
  5b:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 20 11 00 00       	mov    0x1120,%eax
  6b:	a3 24 11 00 00       	mov    %eax,0x1124
  }

  //그냥 실행가능한 스레드가 없는 경우. next_thread가 초기화 그대로인 상태.
  if (next_thread == 0) {
  70:	a1 24 11 00 00       	mov    0x1124,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 6c 0c 00 00       	push   $0xc6c
  81:	6a 02                	push   $0x2
  83:	e8 2c 08 00 00       	call   8b4 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 a0 06 00 00       	call   730 <exit>
  }
  /*end of finding another runnable thread */

  //다른 스레드로 전환해야 하는 경우.
  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 20 11 00 00    	mov    0x1120,%edx
  96:	a1 24 11 00 00       	mov    0x1124,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 25                	je     c4 <thread_schedule+0xc4>
    next_thread->state = RUNNING;
  9f:	a1 24 11 00 00       	mov    0x1124,%eax
  a4:	c7 80 08 20 00 00 01 	movl   $0x1,0x2008(%eax)
  ab:	00 00 00 
    current_thread->state = RUNNABLE;
  ae:	a1 20 11 00 00       	mov    0x1120,%eax
  b3:	c7 80 08 20 00 00 02 	movl   $0x2,0x2008(%eax)
  ba:	00 00 00 
    thread_switch();
  bd:	e8 f2 03 00 00       	call   4b4 <thread_switch>
  } else
    next_thread = 0;
}
  c2:	eb 0a                	jmp    ce <thread_schedule+0xce>
    next_thread = 0;
  c4:	c7 05 24 11 00 00 00 	movl   $0x0,0x1124
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
  d4:	83 ec 08             	sub    $0x8,%esp
  uthread_init((int)thread_schedule);
  d7:	b8 00 00 00 00       	mov    $0x0,%eax
  dc:	83 ec 0c             	sub    $0xc,%esp
  df:	50                   	push   %eax
  e0:	e8 eb 06 00 00       	call   7d0 <uthread_init>
  e5:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  e8:	c7 05 20 11 00 00 40 	movl   $0x1140,0x1120
  ef:	11 00 00 
  current_thread->state = RUNNING;
  f2:	a1 20 11 00 00       	mov    0x1120,%eax
  f7:	c7 80 08 20 00 00 01 	movl   $0x1,0x2008(%eax)
  fe:	00 00 00 
  current_thread->tid=0;
 101:	a1 20 11 00 00       	mov    0x1120,%eax
 106:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 10c:	90                   	nop
 10d:	c9                   	leave  
 10e:	c3                   	ret    

0000010f <thread_create>:

int
thread_create(void (*func)())
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {  //모든 스레드를 돌면서~
 115:	c7 45 f4 40 11 00 00 	movl   $0x1140,-0xc(%ebp)
 11c:	eb 14                	jmp    132 <thread_create+0x23>
    if (t->state == FREE) break;    //상태가 free면. 즉 스레드 만들 수 있는 게 있다.
 11e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 121:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 127:	85 c0                	test   %eax,%eax
 129:	74 13                	je     13e <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {  //모든 스레드를 돌면서~
 12b:	81 45 f4 0c 20 00 00 	addl   $0x200c,-0xc(%ebp)
 132:	b8 b8 51 01 00       	mov    $0x151b8,%eax
 137:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 13a:	72 e2                	jb     11e <thread_create+0xf>
 13c:	eb 01                	jmp    13f <thread_create+0x30>
    if (t->state == FREE) break;    //상태가 free면. 즉 스레드 만들 수 있는 게 있다.
 13e:	90                   	nop
  }

  //added from thread1
  if (t == all_thread + MAX_THREAD) {
 13f:	b8 b8 51 01 00       	mov    $0x151b8,%eax
 144:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 147:	75 19                	jne    162 <thread_create+0x53>
    printf(1, "thread_create: no available slot\n");
 149:	83 ec 08             	sub    $0x8,%esp
 14c:	68 94 0c 00 00       	push   $0xc94
 151:	6a 01                	push   $0x1
 153:	e8 5c 07 00 00       	call   8b4 <printf>
 158:	83 c4 10             	add    $0x10,%esp
    return -1;
 15b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 160:	eb 75                	jmp    1d7 <thread_create+0xc8>
  }

  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 162:	8b 45 f4             	mov    -0xc(%ebp),%eax
 165:	83 c0 08             	add    $0x8,%eax
 168:	05 00 20 00 00       	add    $0x2000,%eax
 16d:	89 c2                	mov    %eax,%edx
 16f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 172:	89 50 04             	mov    %edx,0x4(%eax)
  t->sp -= 4;                              // 리턴 주소를 위한 공간
 175:	8b 45 f4             	mov    -0xc(%ebp),%eax
 178:	8b 40 04             	mov    0x4(%eax),%eax
 17b:	8d 50 fc             	lea    -0x4(%eax),%edx
 17e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 181:	89 50 04             	mov    %edx,0x4(%eax)
  
  /* set tid */
  t->tid = t - all_thread; // 배열에서 인덱스로 tid 설정  
 184:	8b 45 f4             	mov    -0xc(%ebp),%eax
 187:	2d 40 11 00 00       	sub    $0x1140,%eax
 18c:	c1 f8 02             	sar    $0x2,%eax
 18f:	69 c0 ab e2 f8 12    	imul   $0x12f8e2ab,%eax,%eax
 195:	89 c2                	mov    %eax,%edx
 197:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19a:	89 10                	mov    %edx,(%eax)


  //
  *((int *)(t->sp)) = (int)func;           // push return address on stack
 19c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19f:	8b 40 04             	mov    0x4(%eax),%eax
 1a2:	89 c2                	mov    %eax,%edx
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
 1a7:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 1a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ac:	8b 40 04             	mov    0x4(%eax),%eax
 1af:	8d 50 e0             	lea    -0x20(%eax),%edx
 1b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b5:	89 50 04             	mov    %edx,0x4(%eax)
  t->state = RUNNABLE;
 1b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bb:	c7 80 08 20 00 00 02 	movl   $0x2,0x2008(%eax)
 1c2:	00 00 00 
  check_thread(+1);  //added from thread1
 1c5:	83 ec 0c             	sub    $0xc,%esp
 1c8:	6a 01                	push   $0x1
 1ca:	e8 09 06 00 00       	call   7d8 <check_thread>
 1cf:	83 c4 10             	add    $0x10,%esp

  return t->tid;
 1d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d5:	8b 00                	mov    (%eax),%eax
}
 1d7:	c9                   	leave  
 1d8:	c3                   	ret    

000001d9 <thread_suspend>:


static void 
thread_suspend(int tid)
{
 1d9:	55                   	push   %ebp
 1da:	89 e5                	mov    %esp,%ebp
 1dc:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  // 주어진 tid에 해당하는 스레드를 찾기.
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 1df:	c7 45 f4 40 11 00 00 	movl   $0x1140,-0xc(%ebp)
 1e6:	eb 11                	jmp    1f9 <thread_suspend+0x20>
    if (t->tid == tid) {
 1e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1eb:	8b 00                	mov    (%eax),%eax
 1ed:	39 45 08             	cmp    %eax,0x8(%ebp)
 1f0:	74 13                	je     205 <thread_suspend+0x2c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 1f2:	81 45 f4 0c 20 00 00 	addl   $0x200c,-0xc(%ebp)
 1f9:	b8 b8 51 01 00       	mov    $0x151b8,%eax
 1fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 201:	72 e5                	jb     1e8 <thread_suspend+0xf>
 203:	eb 01                	jmp    206 <thread_suspend+0x2d>
      break;
 205:	90                   	nop
    }
  }
  
  // 만약 tid에 해당하는 스레드가 존재하지 않으면 종료
  if (t >= all_thread + MAX_THREAD) {
 206:	b8 b8 51 01 00       	mov    $0x151b8,%eax
 20b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 20e:	72 17                	jb     227 <thread_suspend+0x4e>
    printf(2, "thread_suspend: thread with tid %d not found\n", tid);
 210:	83 ec 04             	sub    $0x4,%esp
 213:	ff 75 08             	push   0x8(%ebp)
 216:	68 b8 0c 00 00       	push   $0xcb8
 21b:	6a 02                	push   $0x2
 21d:	e8 92 06 00 00       	call   8b4 <printf>
 222:	83 c4 10             	add    $0x10,%esp
    return;
 225:	eb 56                	jmp    27d <thread_suspend+0xa4>
  }

  // 이미 멈춰있는 스레드는 다시 멈출 수 없도록 처리
  if (t->state == WAIT) {
 227:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22a:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 230:	83 f8 03             	cmp    $0x3,%eax
 233:	75 17                	jne    24c <thread_suspend+0x73>
    printf(2, "thread_suspend: thread with tid %d is already suspended\n", tid);
 235:	83 ec 04             	sub    $0x4,%esp
 238:	ff 75 08             	push   0x8(%ebp)
 23b:	68 e8 0c 00 00       	push   $0xce8
 240:	6a 02                	push   $0x2
 242:	e8 6d 06 00 00       	call   8b4 <printf>
 247:	83 c4 10             	add    $0x10,%esp
    return;
 24a:	eb 31                	jmp    27d <thread_suspend+0xa4>
  }

  // 스레드 상태를 WAIT로 설정하여 멈추기
  t->state = WAIT;
 24c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24f:	c7 80 08 20 00 00 03 	movl   $0x3,0x2008(%eax)
 256:	00 00 00 

  // 현재 스레드가 멈추는 경우, 스케줄러에 의해 다른 스레드가 실행되도록 한다.
  if (t == current_thread) {
 259:	a1 20 11 00 00       	mov    0x1120,%eax
 25e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 261:	75 05                	jne    268 <thread_suspend+0x8f>
    thread_schedule();
 263:	e8 98 fd ff ff       	call   0 <thread_schedule>
  }

  printf(1, "thread %d suspended\n", tid);
 268:	83 ec 04             	sub    $0x4,%esp
 26b:	ff 75 08             	push   0x8(%ebp)
 26e:	68 21 0d 00 00       	push   $0xd21
 273:	6a 01                	push   $0x1
 275:	e8 3a 06 00 00       	call   8b4 <printf>
 27a:	83 c4 10             	add    $0x10,%esp
}
 27d:	c9                   	leave  
 27e:	c3                   	ret    

0000027f <thread_resume>:

static void 
thread_resume(int tid)
{
 27f:	55                   	push   %ebp
 280:	89 e5                	mov    %esp,%ebp
 282:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  // 주어진 tid에 해당하는 스레드를 찾습니다.
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 285:	c7 45 f4 40 11 00 00 	movl   $0x1140,-0xc(%ebp)
 28c:	eb 11                	jmp    29f <thread_resume+0x20>
    if (t->tid == tid) {
 28e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 291:	8b 00                	mov    (%eax),%eax
 293:	39 45 08             	cmp    %eax,0x8(%ebp)
 296:	74 13                	je     2ab <thread_resume+0x2c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 298:	81 45 f4 0c 20 00 00 	addl   $0x200c,-0xc(%ebp)
 29f:	b8 b8 51 01 00       	mov    $0x151b8,%eax
 2a4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 2a7:	72 e5                	jb     28e <thread_resume+0xf>
 2a9:	eb 01                	jmp    2ac <thread_resume+0x2d>
      break;
 2ab:	90                   	nop
    }
  }

  // 만약 tid에 해당하는 스레드가 존재하지 않으면 에러 처리
  if (t >= all_thread + MAX_THREAD) {
 2ac:	b8 b8 51 01 00       	mov    $0x151b8,%eax
 2b1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 2b4:	72 17                	jb     2cd <thread_resume+0x4e>
    printf(2, "thread_resume: thread with tid %d not found\n", tid);
 2b6:	83 ec 04             	sub    $0x4,%esp
 2b9:	ff 75 08             	push   0x8(%ebp)
 2bc:	68 38 0d 00 00       	push   $0xd38
 2c1:	6a 02                	push   $0x2
 2c3:	e8 ec 05 00 00       	call   8b4 <printf>
 2c8:	83 c4 10             	add    $0x10,%esp
    return;
 2cb:	eb 47                	jmp    314 <thread_resume+0x95>
  }

  // 이미 실행 중인 스레드는 재개할 필요 없음
  if (t->state == RUNNING) {
 2cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d0:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 2d6:	83 f8 01             	cmp    $0x1,%eax
 2d9:	75 17                	jne    2f2 <thread_resume+0x73>
    printf(2, "thread_resume: thread with tid %d is already running\n", tid);
 2db:	83 ec 04             	sub    $0x4,%esp
 2de:	ff 75 08             	push   0x8(%ebp)
 2e1:	68 68 0d 00 00       	push   $0xd68
 2e6:	6a 02                	push   $0x2
 2e8:	e8 c7 05 00 00       	call   8b4 <printf>
 2ed:	83 c4 10             	add    $0x10,%esp
    return;
 2f0:	eb 22                	jmp    314 <thread_resume+0x95>
  }

  // 스레드 상태를 RUNNABLE로 설정하여 재개 가능하도록 설정
  t->state = RUNNABLE;
 2f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f5:	c7 80 08 20 00 00 02 	movl   $0x2,0x2008(%eax)
 2fc:	00 00 00 

  printf(1, "thread %d resumed\n", tid);
 2ff:	83 ec 04             	sub    $0x4,%esp
 302:	ff 75 08             	push   0x8(%ebp)
 305:	68 9e 0d 00 00       	push   $0xd9e
 30a:	6a 01                	push   $0x1
 30c:	e8 a3 05 00 00       	call   8b4 <printf>
 311:	83 c4 10             	add    $0x10,%esp
}
 314:	c9                   	leave  
 315:	c3                   	ret    

00000316 <mythread>:

/*스레드가 실행할 코드*/
static void 
mythread(void)
{
 316:	55                   	push   %ebp
 317:	89 e5                	mov    %esp,%ebp
 319:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 31c:	83 ec 08             	sub    $0x8,%esp
 31f:	68 b1 0d 00 00       	push   $0xdb1
 324:	6a 01                	push   $0x1
 326:	e8 89 05 00 00       	call   8b4 <printf>
 32b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 32e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 335:	eb 1e                	jmp    355 <mythread+0x3f>
    printf(1, "my thread %d\n", current_thread->tid);   //현재 스레드의 id
 337:	a1 20 11 00 00       	mov    0x1120,%eax
 33c:	8b 00                	mov    (%eax),%eax
 33e:	83 ec 04             	sub    $0x4,%esp
 341:	50                   	push   %eax
 342:	68 c4 0d 00 00       	push   $0xdc4
 347:	6a 01                	push   $0x1
 349:	e8 66 05 00 00       	call   8b4 <printf>
 34e:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 351:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 355:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 359:	7e dc                	jle    337 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 35b:	83 ec 08             	sub    $0x8,%esp
 35e:	68 d2 0d 00 00       	push   $0xdd2
 363:	6a 01                	push   $0x1
 365:	e8 4a 05 00 00       	call   8b4 <printf>
 36a:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 36d:	a1 20 11 00 00       	mov    0x1120,%eax
 372:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 379:	00 00 00 

  //uthread1에 있던 거 추가
  check_thread(-1);
 37c:	83 ec 0c             	sub    $0xc,%esp
 37f:	6a ff                	push   $0xffffffff
 381:	e8 52 04 00 00       	call   7d8 <check_thread>
 386:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 389:	e8 72 fc ff ff       	call   0 <thread_schedule>
}
 38e:	90                   	nop
 38f:	c9                   	leave  
 390:	c3                   	ret    

00000391 <main>:


int 
main(int argc, char *argv[]) 
{
 391:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 395:	83 e4 f0             	and    $0xfffffff0,%esp
 398:	ff 71 fc             	push   -0x4(%ecx)
 39b:	55                   	push   %ebp
 39c:	89 e5                	mov    %esp,%ebp
 39e:	51                   	push   %ecx
 39f:	83 ec 14             	sub    $0x14,%esp
  int tid1, tid2,tid3;
  printf(1, "main start~~!!\n");
 3a2:	83 ec 08             	sub    $0x8,%esp
 3a5:	68 e3 0d 00 00       	push   $0xde3
 3aa:	6a 01                	push   $0x1
 3ac:	e8 03 05 00 00       	call   8b4 <printf>
 3b1:	83 c4 10             	add    $0x10,%esp
  thread_init();
 3b4:	e8 18 fd ff ff       	call   d1 <thread_init>
  tid1=thread_create((void (*)())mythread);
 3b9:	83 ec 0c             	sub    $0xc,%esp
 3bc:	68 16 03 00 00       	push   $0x316
 3c1:	e8 49 fd ff ff       	call   10f <thread_create>
 3c6:	83 c4 10             	add    $0x10,%esp
 3c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  tid2=thread_create((void (*)())mythread);
 3cc:	83 ec 0c             	sub    $0xc,%esp
 3cf:	68 16 03 00 00       	push   $0x316
 3d4:	e8 36 fd ff ff       	call   10f <thread_create>
 3d9:	83 c4 10             	add    $0x10,%esp
 3dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  tid3=thread_create((void (*)())mythread);
 3df:	83 ec 0c             	sub    $0xc,%esp
 3e2:	68 16 03 00 00       	push   $0x316
 3e7:	e8 23 fd ff ff       	call   10f <thread_create>
 3ec:	83 c4 10             	add    $0x10,%esp
 3ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  sleep(100); /* you can adjust the sleep time */
 3f2:	83 ec 0c             	sub    $0xc,%esp
 3f5:	6a 64                	push   $0x64
 3f7:	e8 c4 03 00 00       	call   7c0 <sleep>
 3fc:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid1);
 3ff:	83 ec 0c             	sub    $0xc,%esp
 402:	ff 75 f4             	push   -0xc(%ebp)
 405:	e8 cf fd ff ff       	call   1d9 <thread_suspend>
 40a:	83 c4 10             	add    $0x10,%esp
  sleep(100);
 40d:	83 ec 0c             	sub    $0xc,%esp
 410:	6a 64                	push   $0x64
 412:	e8 a9 03 00 00       	call   7c0 <sleep>
 417:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid2);
 41a:	83 ec 0c             	sub    $0xc,%esp
 41d:	ff 75 f0             	push   -0x10(%ebp)
 420:	e8 b4 fd ff ff       	call   1d9 <thread_suspend>
 425:	83 c4 10             	add    $0x10,%esp
  sleep(100);
 428:	83 ec 0c             	sub    $0xc,%esp
 42b:	6a 64                	push   $0x64
 42d:	e8 8e 03 00 00       	call   7c0 <sleep>
 432:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid3);
 435:	83 ec 0c             	sub    $0xc,%esp
 438:	ff 75 ec             	push   -0x14(%ebp)
 43b:	e8 99 fd ff ff       	call   1d9 <thread_suspend>
 440:	83 c4 10             	add    $0x10,%esp
  sleep(100);
 443:	83 ec 0c             	sub    $0xc,%esp
 446:	6a 64                	push   $0x64
 448:	e8 73 03 00 00       	call   7c0 <sleep>
 44d:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid1);
 450:	83 ec 0c             	sub    $0xc,%esp
 453:	ff 75 f4             	push   -0xc(%ebp)
 456:	e8 7e fd ff ff       	call   1d9 <thread_suspend>
 45b:	83 c4 10             	add    $0x10,%esp
  thread_resume(tid1);
 45e:	83 ec 0c             	sub    $0xc,%esp
 461:	ff 75 f4             	push   -0xc(%ebp)
 464:	e8 16 fe ff ff       	call   27f <thread_resume>
 469:	83 c4 10             	add    $0x10,%esp
  sleep(100);
 46c:	83 ec 0c             	sub    $0xc,%esp
 46f:	6a 64                	push   $0x64
 471:	e8 4a 03 00 00       	call   7c0 <sleep>
 476:	83 c4 10             	add    $0x10,%esp
  thread_resume(tid2);
 479:	83 ec 0c             	sub    $0xc,%esp
 47c:	ff 75 f0             	push   -0x10(%ebp)
 47f:	e8 fb fd ff ff       	call   27f <thread_resume>
 484:	83 c4 10             	add    $0x10,%esp
  sleep(100);
 487:	83 ec 0c             	sub    $0xc,%esp
 48a:	6a 64                	push   $0x64
 48c:	e8 2f 03 00 00       	call   7c0 <sleep>
 491:	83 c4 10             	add    $0x10,%esp
  thread_resume(tid3);
 494:	83 ec 0c             	sub    $0xc,%esp
 497:	ff 75 ec             	push   -0x14(%ebp)
 49a:	e8 e0 fd ff ff       	call   27f <thread_resume>
 49f:	83 c4 10             	add    $0x10,%esp
  sleep(100);
 4a2:	83 ec 0c             	sub    $0xc,%esp
 4a5:	6a 64                	push   $0x64
 4a7:	e8 14 03 00 00       	call   7c0 <sleep>
 4ac:	83 c4 10             	add    $0x10,%esp
  exit();
 4af:	e8 7c 02 00 00       	call   730 <exit>

000004b4 <thread_switch>:
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	pushal
 4b4:	60                   	pusha  

   movl current_thread, %eax
 4b5:	a1 20 11 00 00       	mov    0x1120,%eax
   movl %esp, (%eax)
 4ba:	89 20                	mov    %esp,(%eax)

   movl next_thread, %eax      # eax = next_thread  현재 실행 중인 스레드 구조체의 주소를 eax에 저장
 4bc:	a1 24 11 00 00       	mov    0x1124,%eax
    movl (%eax), %esp           # esp = next_thread->sp 현재 실행 중인 스레드의 현
 4c1:	8b 20                	mov    (%eax),%esp

    movl next_thread, %eax
 4c3:	a1 24 11 00 00       	mov    0x1124,%eax
    movl %eax, current_thread   # current_thread = next_thread
 4c8:	a3 20 11 00 00       	mov    %eax,0x1120

    popal
 4cd:	61                   	popa   

   movl $0, next_thread
 4ce:	c7 05 24 11 00 00 00 	movl   $0x0,0x1124
 4d5:	00 00 00 

	ret    /* return to ra */
 4d8:	c3                   	ret    

000004d9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4d9:	55                   	push   %ebp
 4da:	89 e5                	mov    %esp,%ebp
 4dc:	57                   	push   %edi
 4dd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4de:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4e1:	8b 55 10             	mov    0x10(%ebp),%edx
 4e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e7:	89 cb                	mov    %ecx,%ebx
 4e9:	89 df                	mov    %ebx,%edi
 4eb:	89 d1                	mov    %edx,%ecx
 4ed:	fc                   	cld    
 4ee:	f3 aa                	rep stos %al,%es:(%edi)
 4f0:	89 ca                	mov    %ecx,%edx
 4f2:	89 fb                	mov    %edi,%ebx
 4f4:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4f7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4fa:	90                   	nop
 4fb:	5b                   	pop    %ebx
 4fc:	5f                   	pop    %edi
 4fd:	5d                   	pop    %ebp
 4fe:	c3                   	ret    

000004ff <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 4ff:	55                   	push   %ebp
 500:	89 e5                	mov    %esp,%ebp
 502:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 505:	8b 45 08             	mov    0x8(%ebp),%eax
 508:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 50b:	90                   	nop
 50c:	8b 55 0c             	mov    0xc(%ebp),%edx
 50f:	8d 42 01             	lea    0x1(%edx),%eax
 512:	89 45 0c             	mov    %eax,0xc(%ebp)
 515:	8b 45 08             	mov    0x8(%ebp),%eax
 518:	8d 48 01             	lea    0x1(%eax),%ecx
 51b:	89 4d 08             	mov    %ecx,0x8(%ebp)
 51e:	0f b6 12             	movzbl (%edx),%edx
 521:	88 10                	mov    %dl,(%eax)
 523:	0f b6 00             	movzbl (%eax),%eax
 526:	84 c0                	test   %al,%al
 528:	75 e2                	jne    50c <strcpy+0xd>
    ;
  return os;
 52a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 52d:	c9                   	leave  
 52e:	c3                   	ret    

0000052f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 52f:	55                   	push   %ebp
 530:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 532:	eb 08                	jmp    53c <strcmp+0xd>
    p++, q++;
 534:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 538:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 53c:	8b 45 08             	mov    0x8(%ebp),%eax
 53f:	0f b6 00             	movzbl (%eax),%eax
 542:	84 c0                	test   %al,%al
 544:	74 10                	je     556 <strcmp+0x27>
 546:	8b 45 08             	mov    0x8(%ebp),%eax
 549:	0f b6 10             	movzbl (%eax),%edx
 54c:	8b 45 0c             	mov    0xc(%ebp),%eax
 54f:	0f b6 00             	movzbl (%eax),%eax
 552:	38 c2                	cmp    %al,%dl
 554:	74 de                	je     534 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 556:	8b 45 08             	mov    0x8(%ebp),%eax
 559:	0f b6 00             	movzbl (%eax),%eax
 55c:	0f b6 d0             	movzbl %al,%edx
 55f:	8b 45 0c             	mov    0xc(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	0f b6 c8             	movzbl %al,%ecx
 568:	89 d0                	mov    %edx,%eax
 56a:	29 c8                	sub    %ecx,%eax
}
 56c:	5d                   	pop    %ebp
 56d:	c3                   	ret    

0000056e <strlen>:

uint
strlen(char *s)
{
 56e:	55                   	push   %ebp
 56f:	89 e5                	mov    %esp,%ebp
 571:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 574:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 57b:	eb 04                	jmp    581 <strlen+0x13>
 57d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 581:	8b 55 fc             	mov    -0x4(%ebp),%edx
 584:	8b 45 08             	mov    0x8(%ebp),%eax
 587:	01 d0                	add    %edx,%eax
 589:	0f b6 00             	movzbl (%eax),%eax
 58c:	84 c0                	test   %al,%al
 58e:	75 ed                	jne    57d <strlen+0xf>
    ;
  return n;
 590:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 593:	c9                   	leave  
 594:	c3                   	ret    

00000595 <memset>:

void*
memset(void *dst, int c, uint n)
{
 595:	55                   	push   %ebp
 596:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 598:	8b 45 10             	mov    0x10(%ebp),%eax
 59b:	50                   	push   %eax
 59c:	ff 75 0c             	push   0xc(%ebp)
 59f:	ff 75 08             	push   0x8(%ebp)
 5a2:	e8 32 ff ff ff       	call   4d9 <stosb>
 5a7:	83 c4 0c             	add    $0xc,%esp
  return dst;
 5aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5ad:	c9                   	leave  
 5ae:	c3                   	ret    

000005af <strchr>:

char*
strchr(const char *s, char c)
{
 5af:	55                   	push   %ebp
 5b0:	89 e5                	mov    %esp,%ebp
 5b2:	83 ec 04             	sub    $0x4,%esp
 5b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 5bb:	eb 14                	jmp    5d1 <strchr+0x22>
    if(*s == c)
 5bd:	8b 45 08             	mov    0x8(%ebp),%eax
 5c0:	0f b6 00             	movzbl (%eax),%eax
 5c3:	38 45 fc             	cmp    %al,-0x4(%ebp)
 5c6:	75 05                	jne    5cd <strchr+0x1e>
      return (char*)s;
 5c8:	8b 45 08             	mov    0x8(%ebp),%eax
 5cb:	eb 13                	jmp    5e0 <strchr+0x31>
  for(; *s; s++)
 5cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5d1:	8b 45 08             	mov    0x8(%ebp),%eax
 5d4:	0f b6 00             	movzbl (%eax),%eax
 5d7:	84 c0                	test   %al,%al
 5d9:	75 e2                	jne    5bd <strchr+0xe>
  return 0;
 5db:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5e0:	c9                   	leave  
 5e1:	c3                   	ret    

000005e2 <gets>:

char*
gets(char *buf, int max)
{
 5e2:	55                   	push   %ebp
 5e3:	89 e5                	mov    %esp,%ebp
 5e5:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5ef:	eb 42                	jmp    633 <gets+0x51>
    cc = read(0, &c, 1);
 5f1:	83 ec 04             	sub    $0x4,%esp
 5f4:	6a 01                	push   $0x1
 5f6:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5f9:	50                   	push   %eax
 5fa:	6a 00                	push   $0x0
 5fc:	e8 47 01 00 00       	call   748 <read>
 601:	83 c4 10             	add    $0x10,%esp
 604:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 607:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 60b:	7e 33                	jle    640 <gets+0x5e>
      break;
    buf[i++] = c;
 60d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 610:	8d 50 01             	lea    0x1(%eax),%edx
 613:	89 55 f4             	mov    %edx,-0xc(%ebp)
 616:	89 c2                	mov    %eax,%edx
 618:	8b 45 08             	mov    0x8(%ebp),%eax
 61b:	01 c2                	add    %eax,%edx
 61d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 621:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 623:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 627:	3c 0a                	cmp    $0xa,%al
 629:	74 16                	je     641 <gets+0x5f>
 62b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 62f:	3c 0d                	cmp    $0xd,%al
 631:	74 0e                	je     641 <gets+0x5f>
  for(i=0; i+1 < max; ){
 633:	8b 45 f4             	mov    -0xc(%ebp),%eax
 636:	83 c0 01             	add    $0x1,%eax
 639:	39 45 0c             	cmp    %eax,0xc(%ebp)
 63c:	7f b3                	jg     5f1 <gets+0xf>
 63e:	eb 01                	jmp    641 <gets+0x5f>
      break;
 640:	90                   	nop
      break;
  }
  buf[i] = '\0';
 641:	8b 55 f4             	mov    -0xc(%ebp),%edx
 644:	8b 45 08             	mov    0x8(%ebp),%eax
 647:	01 d0                	add    %edx,%eax
 649:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 64c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 64f:	c9                   	leave  
 650:	c3                   	ret    

00000651 <stat>:

int
stat(char *n, struct stat *st)
{
 651:	55                   	push   %ebp
 652:	89 e5                	mov    %esp,%ebp
 654:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 657:	83 ec 08             	sub    $0x8,%esp
 65a:	6a 00                	push   $0x0
 65c:	ff 75 08             	push   0x8(%ebp)
 65f:	e8 0c 01 00 00       	call   770 <open>
 664:	83 c4 10             	add    $0x10,%esp
 667:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 66a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 66e:	79 07                	jns    677 <stat+0x26>
    return -1;
 670:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 675:	eb 25                	jmp    69c <stat+0x4b>
  r = fstat(fd, st);
 677:	83 ec 08             	sub    $0x8,%esp
 67a:	ff 75 0c             	push   0xc(%ebp)
 67d:	ff 75 f4             	push   -0xc(%ebp)
 680:	e8 03 01 00 00       	call   788 <fstat>
 685:	83 c4 10             	add    $0x10,%esp
 688:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 68b:	83 ec 0c             	sub    $0xc,%esp
 68e:	ff 75 f4             	push   -0xc(%ebp)
 691:	e8 c2 00 00 00       	call   758 <close>
 696:	83 c4 10             	add    $0x10,%esp
  return r;
 699:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 69c:	c9                   	leave  
 69d:	c3                   	ret    

0000069e <atoi>:

int
atoi(const char *s)
{
 69e:	55                   	push   %ebp
 69f:	89 e5                	mov    %esp,%ebp
 6a1:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 6a4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6ab:	eb 25                	jmp    6d2 <atoi+0x34>
    n = n*10 + *s++ - '0';
 6ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6b0:	89 d0                	mov    %edx,%eax
 6b2:	c1 e0 02             	shl    $0x2,%eax
 6b5:	01 d0                	add    %edx,%eax
 6b7:	01 c0                	add    %eax,%eax
 6b9:	89 c1                	mov    %eax,%ecx
 6bb:	8b 45 08             	mov    0x8(%ebp),%eax
 6be:	8d 50 01             	lea    0x1(%eax),%edx
 6c1:	89 55 08             	mov    %edx,0x8(%ebp)
 6c4:	0f b6 00             	movzbl (%eax),%eax
 6c7:	0f be c0             	movsbl %al,%eax
 6ca:	01 c8                	add    %ecx,%eax
 6cc:	83 e8 30             	sub    $0x30,%eax
 6cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6d2:	8b 45 08             	mov    0x8(%ebp),%eax
 6d5:	0f b6 00             	movzbl (%eax),%eax
 6d8:	3c 2f                	cmp    $0x2f,%al
 6da:	7e 0a                	jle    6e6 <atoi+0x48>
 6dc:	8b 45 08             	mov    0x8(%ebp),%eax
 6df:	0f b6 00             	movzbl (%eax),%eax
 6e2:	3c 39                	cmp    $0x39,%al
 6e4:	7e c7                	jle    6ad <atoi+0xf>
  return n;
 6e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6e9:	c9                   	leave  
 6ea:	c3                   	ret    

000006eb <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 6eb:	55                   	push   %ebp
 6ec:	89 e5                	mov    %esp,%ebp
 6ee:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 6f1:	8b 45 08             	mov    0x8(%ebp),%eax
 6f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6f7:	8b 45 0c             	mov    0xc(%ebp),%eax
 6fa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6fd:	eb 17                	jmp    716 <memmove+0x2b>
    *dst++ = *src++;
 6ff:	8b 55 f8             	mov    -0x8(%ebp),%edx
 702:	8d 42 01             	lea    0x1(%edx),%eax
 705:	89 45 f8             	mov    %eax,-0x8(%ebp)
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	8d 48 01             	lea    0x1(%eax),%ecx
 70e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 711:	0f b6 12             	movzbl (%edx),%edx
 714:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 716:	8b 45 10             	mov    0x10(%ebp),%eax
 719:	8d 50 ff             	lea    -0x1(%eax),%edx
 71c:	89 55 10             	mov    %edx,0x10(%ebp)
 71f:	85 c0                	test   %eax,%eax
 721:	7f dc                	jg     6ff <memmove+0x14>
  return vdst;
 723:	8b 45 08             	mov    0x8(%ebp),%eax
}
 726:	c9                   	leave  
 727:	c3                   	ret    

00000728 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 728:	b8 01 00 00 00       	mov    $0x1,%eax
 72d:	cd 40                	int    $0x40
 72f:	c3                   	ret    

00000730 <exit>:
SYSCALL(exit)
 730:	b8 02 00 00 00       	mov    $0x2,%eax
 735:	cd 40                	int    $0x40
 737:	c3                   	ret    

00000738 <wait>:
SYSCALL(wait)
 738:	b8 03 00 00 00       	mov    $0x3,%eax
 73d:	cd 40                	int    $0x40
 73f:	c3                   	ret    

00000740 <pipe>:
SYSCALL(pipe)
 740:	b8 04 00 00 00       	mov    $0x4,%eax
 745:	cd 40                	int    $0x40
 747:	c3                   	ret    

00000748 <read>:
SYSCALL(read)
 748:	b8 05 00 00 00       	mov    $0x5,%eax
 74d:	cd 40                	int    $0x40
 74f:	c3                   	ret    

00000750 <write>:
SYSCALL(write)
 750:	b8 10 00 00 00       	mov    $0x10,%eax
 755:	cd 40                	int    $0x40
 757:	c3                   	ret    

00000758 <close>:
SYSCALL(close)
 758:	b8 15 00 00 00       	mov    $0x15,%eax
 75d:	cd 40                	int    $0x40
 75f:	c3                   	ret    

00000760 <kill>:
SYSCALL(kill)
 760:	b8 06 00 00 00       	mov    $0x6,%eax
 765:	cd 40                	int    $0x40
 767:	c3                   	ret    

00000768 <exec>:
SYSCALL(exec)
 768:	b8 07 00 00 00       	mov    $0x7,%eax
 76d:	cd 40                	int    $0x40
 76f:	c3                   	ret    

00000770 <open>:
SYSCALL(open)
 770:	b8 0f 00 00 00       	mov    $0xf,%eax
 775:	cd 40                	int    $0x40
 777:	c3                   	ret    

00000778 <mknod>:
SYSCALL(mknod)
 778:	b8 11 00 00 00       	mov    $0x11,%eax
 77d:	cd 40                	int    $0x40
 77f:	c3                   	ret    

00000780 <unlink>:
SYSCALL(unlink)
 780:	b8 12 00 00 00       	mov    $0x12,%eax
 785:	cd 40                	int    $0x40
 787:	c3                   	ret    

00000788 <fstat>:
SYSCALL(fstat)
 788:	b8 08 00 00 00       	mov    $0x8,%eax
 78d:	cd 40                	int    $0x40
 78f:	c3                   	ret    

00000790 <link>:
SYSCALL(link)
 790:	b8 13 00 00 00       	mov    $0x13,%eax
 795:	cd 40                	int    $0x40
 797:	c3                   	ret    

00000798 <mkdir>:
SYSCALL(mkdir)
 798:	b8 14 00 00 00       	mov    $0x14,%eax
 79d:	cd 40                	int    $0x40
 79f:	c3                   	ret    

000007a0 <chdir>:
SYSCALL(chdir)
 7a0:	b8 09 00 00 00       	mov    $0x9,%eax
 7a5:	cd 40                	int    $0x40
 7a7:	c3                   	ret    

000007a8 <dup>:
SYSCALL(dup)
 7a8:	b8 0a 00 00 00       	mov    $0xa,%eax
 7ad:	cd 40                	int    $0x40
 7af:	c3                   	ret    

000007b0 <getpid>:
SYSCALL(getpid)
 7b0:	b8 0b 00 00 00       	mov    $0xb,%eax
 7b5:	cd 40                	int    $0x40
 7b7:	c3                   	ret    

000007b8 <sbrk>:
SYSCALL(sbrk)
 7b8:	b8 0c 00 00 00       	mov    $0xc,%eax
 7bd:	cd 40                	int    $0x40
 7bf:	c3                   	ret    

000007c0 <sleep>:
SYSCALL(sleep)
 7c0:	b8 0d 00 00 00       	mov    $0xd,%eax
 7c5:	cd 40                	int    $0x40
 7c7:	c3                   	ret    

000007c8 <uptime>:
SYSCALL(uptime)
 7c8:	b8 0e 00 00 00       	mov    $0xe,%eax
 7cd:	cd 40                	int    $0x40
 7cf:	c3                   	ret    

000007d0 <uthread_init>:

SYSCALL(uthread_init)
 7d0:	b8 16 00 00 00       	mov    $0x16,%eax
 7d5:	cd 40                	int    $0x40
 7d7:	c3                   	ret    

000007d8 <check_thread>:
 7d8:	b8 17 00 00 00       	mov    $0x17,%eax
 7dd:	cd 40                	int    $0x40
 7df:	c3                   	ret    

000007e0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 7e0:	55                   	push   %ebp
 7e1:	89 e5                	mov    %esp,%ebp
 7e3:	83 ec 18             	sub    $0x18,%esp
 7e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 7e9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 7ec:	83 ec 04             	sub    $0x4,%esp
 7ef:	6a 01                	push   $0x1
 7f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
 7f4:	50                   	push   %eax
 7f5:	ff 75 08             	push   0x8(%ebp)
 7f8:	e8 53 ff ff ff       	call   750 <write>
 7fd:	83 c4 10             	add    $0x10,%esp
}
 800:	90                   	nop
 801:	c9                   	leave  
 802:	c3                   	ret    

00000803 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 803:	55                   	push   %ebp
 804:	89 e5                	mov    %esp,%ebp
 806:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 809:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 810:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 814:	74 17                	je     82d <printint+0x2a>
 816:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 81a:	79 11                	jns    82d <printint+0x2a>
    neg = 1;
 81c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 823:	8b 45 0c             	mov    0xc(%ebp),%eax
 826:	f7 d8                	neg    %eax
 828:	89 45 ec             	mov    %eax,-0x14(%ebp)
 82b:	eb 06                	jmp    833 <printint+0x30>
  } else {
    x = xx;
 82d:	8b 45 0c             	mov    0xc(%ebp),%eax
 830:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 833:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 83a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 83d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 840:	ba 00 00 00 00       	mov    $0x0,%edx
 845:	f7 f1                	div    %ecx
 847:	89 d1                	mov    %edx,%ecx
 849:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84c:	8d 50 01             	lea    0x1(%eax),%edx
 84f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 852:	0f b6 91 00 11 00 00 	movzbl 0x1100(%ecx),%edx
 859:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 85d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 860:	8b 45 ec             	mov    -0x14(%ebp),%eax
 863:	ba 00 00 00 00       	mov    $0x0,%edx
 868:	f7 f1                	div    %ecx
 86a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 86d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 871:	75 c7                	jne    83a <printint+0x37>
  if(neg)
 873:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 877:	74 2d                	je     8a6 <printint+0xa3>
    buf[i++] = '-';
 879:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87c:	8d 50 01             	lea    0x1(%eax),%edx
 87f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 882:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 887:	eb 1d                	jmp    8a6 <printint+0xa3>
    putc(fd, buf[i]);
 889:	8d 55 dc             	lea    -0x24(%ebp),%edx
 88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88f:	01 d0                	add    %edx,%eax
 891:	0f b6 00             	movzbl (%eax),%eax
 894:	0f be c0             	movsbl %al,%eax
 897:	83 ec 08             	sub    $0x8,%esp
 89a:	50                   	push   %eax
 89b:	ff 75 08             	push   0x8(%ebp)
 89e:	e8 3d ff ff ff       	call   7e0 <putc>
 8a3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 8a6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ae:	79 d9                	jns    889 <printint+0x86>
}
 8b0:	90                   	nop
 8b1:	90                   	nop
 8b2:	c9                   	leave  
 8b3:	c3                   	ret    

000008b4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 8b4:	55                   	push   %ebp
 8b5:	89 e5                	mov    %esp,%ebp
 8b7:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 8ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 8c1:	8d 45 0c             	lea    0xc(%ebp),%eax
 8c4:	83 c0 04             	add    $0x4,%eax
 8c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 8ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8d1:	e9 59 01 00 00       	jmp    a2f <printf+0x17b>
    c = fmt[i] & 0xff;
 8d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 8d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8dc:	01 d0                	add    %edx,%eax
 8de:	0f b6 00             	movzbl (%eax),%eax
 8e1:	0f be c0             	movsbl %al,%eax
 8e4:	25 ff 00 00 00       	and    $0xff,%eax
 8e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 8ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8f0:	75 2c                	jne    91e <printf+0x6a>
      if(c == '%'){
 8f2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8f6:	75 0c                	jne    904 <printf+0x50>
        state = '%';
 8f8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8ff:	e9 27 01 00 00       	jmp    a2b <printf+0x177>
      } else {
        putc(fd, c);
 904:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 907:	0f be c0             	movsbl %al,%eax
 90a:	83 ec 08             	sub    $0x8,%esp
 90d:	50                   	push   %eax
 90e:	ff 75 08             	push   0x8(%ebp)
 911:	e8 ca fe ff ff       	call   7e0 <putc>
 916:	83 c4 10             	add    $0x10,%esp
 919:	e9 0d 01 00 00       	jmp    a2b <printf+0x177>
      }
    } else if(state == '%'){
 91e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 922:	0f 85 03 01 00 00    	jne    a2b <printf+0x177>
      if(c == 'd'){
 928:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 92c:	75 1e                	jne    94c <printf+0x98>
        printint(fd, *ap, 10, 1);
 92e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 931:	8b 00                	mov    (%eax),%eax
 933:	6a 01                	push   $0x1
 935:	6a 0a                	push   $0xa
 937:	50                   	push   %eax
 938:	ff 75 08             	push   0x8(%ebp)
 93b:	e8 c3 fe ff ff       	call   803 <printint>
 940:	83 c4 10             	add    $0x10,%esp
        ap++;
 943:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 947:	e9 d8 00 00 00       	jmp    a24 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 94c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 950:	74 06                	je     958 <printf+0xa4>
 952:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 956:	75 1e                	jne    976 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 958:	8b 45 e8             	mov    -0x18(%ebp),%eax
 95b:	8b 00                	mov    (%eax),%eax
 95d:	6a 00                	push   $0x0
 95f:	6a 10                	push   $0x10
 961:	50                   	push   %eax
 962:	ff 75 08             	push   0x8(%ebp)
 965:	e8 99 fe ff ff       	call   803 <printint>
 96a:	83 c4 10             	add    $0x10,%esp
        ap++;
 96d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 971:	e9 ae 00 00 00       	jmp    a24 <printf+0x170>
      } else if(c == 's'){
 976:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 97a:	75 43                	jne    9bf <printf+0x10b>
        s = (char*)*ap;
 97c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 97f:	8b 00                	mov    (%eax),%eax
 981:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 984:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 988:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 98c:	75 25                	jne    9b3 <printf+0xff>
          s = "(null)";
 98e:	c7 45 f4 f3 0d 00 00 	movl   $0xdf3,-0xc(%ebp)
        while(*s != 0){
 995:	eb 1c                	jmp    9b3 <printf+0xff>
          putc(fd, *s);
 997:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99a:	0f b6 00             	movzbl (%eax),%eax
 99d:	0f be c0             	movsbl %al,%eax
 9a0:	83 ec 08             	sub    $0x8,%esp
 9a3:	50                   	push   %eax
 9a4:	ff 75 08             	push   0x8(%ebp)
 9a7:	e8 34 fe ff ff       	call   7e0 <putc>
 9ac:	83 c4 10             	add    $0x10,%esp
          s++;
 9af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 9b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b6:	0f b6 00             	movzbl (%eax),%eax
 9b9:	84 c0                	test   %al,%al
 9bb:	75 da                	jne    997 <printf+0xe3>
 9bd:	eb 65                	jmp    a24 <printf+0x170>
        }
      } else if(c == 'c'){
 9bf:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 9c3:	75 1d                	jne    9e2 <printf+0x12e>
        putc(fd, *ap);
 9c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c8:	8b 00                	mov    (%eax),%eax
 9ca:	0f be c0             	movsbl %al,%eax
 9cd:	83 ec 08             	sub    $0x8,%esp
 9d0:	50                   	push   %eax
 9d1:	ff 75 08             	push   0x8(%ebp)
 9d4:	e8 07 fe ff ff       	call   7e0 <putc>
 9d9:	83 c4 10             	add    $0x10,%esp
        ap++;
 9dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9e0:	eb 42                	jmp    a24 <printf+0x170>
      } else if(c == '%'){
 9e2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9e6:	75 17                	jne    9ff <printf+0x14b>
        putc(fd, c);
 9e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9eb:	0f be c0             	movsbl %al,%eax
 9ee:	83 ec 08             	sub    $0x8,%esp
 9f1:	50                   	push   %eax
 9f2:	ff 75 08             	push   0x8(%ebp)
 9f5:	e8 e6 fd ff ff       	call   7e0 <putc>
 9fa:	83 c4 10             	add    $0x10,%esp
 9fd:	eb 25                	jmp    a24 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9ff:	83 ec 08             	sub    $0x8,%esp
 a02:	6a 25                	push   $0x25
 a04:	ff 75 08             	push   0x8(%ebp)
 a07:	e8 d4 fd ff ff       	call   7e0 <putc>
 a0c:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a12:	0f be c0             	movsbl %al,%eax
 a15:	83 ec 08             	sub    $0x8,%esp
 a18:	50                   	push   %eax
 a19:	ff 75 08             	push   0x8(%ebp)
 a1c:	e8 bf fd ff ff       	call   7e0 <putc>
 a21:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 a24:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a2b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
 a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a35:	01 d0                	add    %edx,%eax
 a37:	0f b6 00             	movzbl (%eax),%eax
 a3a:	84 c0                	test   %al,%al
 a3c:	0f 85 94 fe ff ff    	jne    8d6 <printf+0x22>
    }
  }
}
 a42:	90                   	nop
 a43:	90                   	nop
 a44:	c9                   	leave  
 a45:	c3                   	ret    

00000a46 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a46:	55                   	push   %ebp
 a47:	89 e5                	mov    %esp,%ebp
 a49:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a4c:	8b 45 08             	mov    0x8(%ebp),%eax
 a4f:	83 e8 08             	sub    $0x8,%eax
 a52:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a55:	a1 c0 51 01 00       	mov    0x151c0,%eax
 a5a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a5d:	eb 24                	jmp    a83 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a62:	8b 00                	mov    (%eax),%eax
 a64:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 a67:	72 12                	jb     a7b <free+0x35>
 a69:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a6c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a6f:	77 24                	ja     a95 <free+0x4f>
 a71:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a74:	8b 00                	mov    (%eax),%eax
 a76:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a79:	72 1a                	jb     a95 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a7e:	8b 00                	mov    (%eax),%eax
 a80:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a83:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a86:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a89:	76 d4                	jbe    a5f <free+0x19>
 a8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a8e:	8b 00                	mov    (%eax),%eax
 a90:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a93:	73 ca                	jae    a5f <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a95:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a98:	8b 40 04             	mov    0x4(%eax),%eax
 a9b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 aa2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aa5:	01 c2                	add    %eax,%edx
 aa7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aaa:	8b 00                	mov    (%eax),%eax
 aac:	39 c2                	cmp    %eax,%edx
 aae:	75 24                	jne    ad4 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 ab0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab3:	8b 50 04             	mov    0x4(%eax),%edx
 ab6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab9:	8b 00                	mov    (%eax),%eax
 abb:	8b 40 04             	mov    0x4(%eax),%eax
 abe:	01 c2                	add    %eax,%edx
 ac0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ac3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 ac6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac9:	8b 00                	mov    (%eax),%eax
 acb:	8b 10                	mov    (%eax),%edx
 acd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad0:	89 10                	mov    %edx,(%eax)
 ad2:	eb 0a                	jmp    ade <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 ad4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad7:	8b 10                	mov    (%eax),%edx
 ad9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 adc:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 ade:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae1:	8b 40 04             	mov    0x4(%eax),%eax
 ae4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 aeb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aee:	01 d0                	add    %edx,%eax
 af0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 af3:	75 20                	jne    b15 <free+0xcf>
    p->s.size += bp->s.size;
 af5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af8:	8b 50 04             	mov    0x4(%eax),%edx
 afb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afe:	8b 40 04             	mov    0x4(%eax),%eax
 b01:	01 c2                	add    %eax,%edx
 b03:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b06:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b09:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b0c:	8b 10                	mov    (%eax),%edx
 b0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b11:	89 10                	mov    %edx,(%eax)
 b13:	eb 08                	jmp    b1d <free+0xd7>
  } else
    p->s.ptr = bp;
 b15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b18:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b1b:	89 10                	mov    %edx,(%eax)
  freep = p;
 b1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b20:	a3 c0 51 01 00       	mov    %eax,0x151c0
}
 b25:	90                   	nop
 b26:	c9                   	leave  
 b27:	c3                   	ret    

00000b28 <morecore>:

static Header*
morecore(uint nu)
{
 b28:	55                   	push   %ebp
 b29:	89 e5                	mov    %esp,%ebp
 b2b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b2e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b35:	77 07                	ja     b3e <morecore+0x16>
    nu = 4096;
 b37:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b3e:	8b 45 08             	mov    0x8(%ebp),%eax
 b41:	c1 e0 03             	shl    $0x3,%eax
 b44:	83 ec 0c             	sub    $0xc,%esp
 b47:	50                   	push   %eax
 b48:	e8 6b fc ff ff       	call   7b8 <sbrk>
 b4d:	83 c4 10             	add    $0x10,%esp
 b50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b53:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b57:	75 07                	jne    b60 <morecore+0x38>
    return 0;
 b59:	b8 00 00 00 00       	mov    $0x0,%eax
 b5e:	eb 26                	jmp    b86 <morecore+0x5e>
  hp = (Header*)p;
 b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b69:	8b 55 08             	mov    0x8(%ebp),%edx
 b6c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b72:	83 c0 08             	add    $0x8,%eax
 b75:	83 ec 0c             	sub    $0xc,%esp
 b78:	50                   	push   %eax
 b79:	e8 c8 fe ff ff       	call   a46 <free>
 b7e:	83 c4 10             	add    $0x10,%esp
  return freep;
 b81:	a1 c0 51 01 00       	mov    0x151c0,%eax
}
 b86:	c9                   	leave  
 b87:	c3                   	ret    

00000b88 <malloc>:

void*
malloc(uint nbytes)
{
 b88:	55                   	push   %ebp
 b89:	89 e5                	mov    %esp,%ebp
 b8b:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b8e:	8b 45 08             	mov    0x8(%ebp),%eax
 b91:	83 c0 07             	add    $0x7,%eax
 b94:	c1 e8 03             	shr    $0x3,%eax
 b97:	83 c0 01             	add    $0x1,%eax
 b9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b9d:	a1 c0 51 01 00       	mov    0x151c0,%eax
 ba2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ba5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ba9:	75 23                	jne    bce <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 bab:	c7 45 f0 b8 51 01 00 	movl   $0x151b8,-0x10(%ebp)
 bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bb5:	a3 c0 51 01 00       	mov    %eax,0x151c0
 bba:	a1 c0 51 01 00       	mov    0x151c0,%eax
 bbf:	a3 b8 51 01 00       	mov    %eax,0x151b8
    base.s.size = 0;
 bc4:	c7 05 bc 51 01 00 00 	movl   $0x0,0x151bc
 bcb:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bd1:	8b 00                	mov    (%eax),%eax
 bd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd9:	8b 40 04             	mov    0x4(%eax),%eax
 bdc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 bdf:	77 4d                	ja     c2e <malloc+0xa6>
      if(p->s.size == nunits)
 be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be4:	8b 40 04             	mov    0x4(%eax),%eax
 be7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 bea:	75 0c                	jne    bf8 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bef:	8b 10                	mov    (%eax),%edx
 bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf4:	89 10                	mov    %edx,(%eax)
 bf6:	eb 26                	jmp    c1e <malloc+0x96>
      else {
        p->s.size -= nunits;
 bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bfb:	8b 40 04             	mov    0x4(%eax),%eax
 bfe:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c01:	89 c2                	mov    %eax,%edx
 c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c06:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c0c:	8b 40 04             	mov    0x4(%eax),%eax
 c0f:	c1 e0 03             	shl    $0x3,%eax
 c12:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c18:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c1b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c21:	a3 c0 51 01 00       	mov    %eax,0x151c0
      return (void*)(p + 1);
 c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c29:	83 c0 08             	add    $0x8,%eax
 c2c:	eb 3b                	jmp    c69 <malloc+0xe1>
    }
    if(p == freep)
 c2e:	a1 c0 51 01 00       	mov    0x151c0,%eax
 c33:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c36:	75 1e                	jne    c56 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 c38:	83 ec 0c             	sub    $0xc,%esp
 c3b:	ff 75 ec             	push   -0x14(%ebp)
 c3e:	e8 e5 fe ff ff       	call   b28 <morecore>
 c43:	83 c4 10             	add    $0x10,%esp
 c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c4d:	75 07                	jne    c56 <malloc+0xce>
        return 0;
 c4f:	b8 00 00 00 00       	mov    $0x0,%eax
 c54:	eb 13                	jmp    c69 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c59:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5f:	8b 00                	mov    (%eax),%eax
 c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c64:	e9 6d ff ff ff       	jmp    bd6 <malloc+0x4e>
  }
}
 c69:	c9                   	leave  
 c6a:	c3                   	ret    
