
_uthread2:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
extern void thread_switch(void);
extern void thread_schedule(void);

void 
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
   6:	c7 05 24 11 00 00 00 	movl   $0x0,0x1124
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 40 11 00 00 	movl   $0x1140,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
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
  3b:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
  42:	b8 e0 51 01 00       	mov    $0x151e0,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 e0 51 01 00       	mov    $0x151e0,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 20 11 00 00       	mov    0x1120,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 20 11 00 00       	mov    0x1120,%eax
  6b:	a3 24 11 00 00       	mov    %eax,0x1124
  }

  if (next_thread == 0) {
  70:	a1 24 11 00 00       	mov    0x1124,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 33                	jne    ac <thread_schedule+0xac>
    // printf(2, "thread_schedule: no runnable threads\n");
    // exit();
    if(current_thread->state==RUNNING){         // child가 하나만 남았을 때
  79:	a1 20 11 00 00       	mov    0x1120,%eax
  7e:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  84:	83 f8 01             	cmp    $0x1,%eax
  87:	75 0c                	jne    95 <thread_schedule+0x95>
        next_thread = current_thread;
  89:	a1 20 11 00 00       	mov    0x1120,%eax
  8e:	a3 24 11 00 00       	mov    %eax,0x1124
  93:	eb 17                	jmp    ac <thread_schedule+0xac>
      } else {  
      printf(2, "thread_schedule: no runnable threads\n");
  95:	83 ec 08             	sub    $0x8,%esp
  98:	68 f0 0c 00 00       	push   $0xcf0
  9d:	6a 02                	push   $0x2
  9f:	e8 93 08 00 00       	call   937 <printf>
  a4:	83 c4 10             	add    $0x10,%esp
      exit();
  a7:	e8 07 07 00 00       	call   7b3 <exit>
      }
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  ac:	8b 15 20 11 00 00    	mov    0x1120,%edx
  b2:	a1 24 11 00 00       	mov    0x1124,%eax
  b7:	39 c2                	cmp    %eax,%edx
  b9:	74 41                	je     fc <thread_schedule+0xfc>
    next_thread->state = RUNNING;
  bb:	a1 24 11 00 00       	mov    0x1124,%eax
  c0:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  c7:	00 00 00 
    if (current_thread != &all_thread[0]) {
  ca:	a1 20 11 00 00       	mov    0x1120,%eax
  cf:	3d 40 11 00 00       	cmp    $0x1140,%eax
  d4:	74 1f                	je     f5 <thread_schedule+0xf5>
      if (current_thread->state == RUNNING) {
  d6:	a1 20 11 00 00       	mov    0x1120,%eax
  db:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  e1:	83 f8 01             	cmp    $0x1,%eax
  e4:	75 0f                	jne    f5 <thread_schedule+0xf5>
        current_thread->state = RUNNABLE;
  e6:	a1 20 11 00 00       	mov    0x1120,%eax
  eb:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  f2:	00 00 00 
      }
    }
    thread_switch();
  f5:	e8 3d 04 00 00       	call   537 <thread_switch>
  } else
    next_thread = 0;
}
  fa:	eb 0a                	jmp    106 <thread_schedule+0x106>
    next_thread = 0;
  fc:	c7 05 24 11 00 00 00 	movl   $0x0,0x1124
 103:	00 00 00 
}
 106:	90                   	nop
 107:	c9                   	leave  
 108:	c3                   	ret    

00000109 <thread_init>:

void 
thread_init(void)
{
 109:	55                   	push   %ebp
 10a:	89 e5                	mov    %esp,%ebp
 10c:	83 ec 08             	sub    $0x8,%esp
  uthread_init((int)thread_schedule);
 10f:	b8 00 00 00 00       	mov    $0x0,%eax
 114:	83 ec 0c             	sub    $0xc,%esp
 117:	50                   	push   %eax
 118:	e8 36 07 00 00       	call   853 <uthread_init>
 11d:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
 120:	c7 05 20 11 00 00 40 	movl   $0x1140,0x1120
 127:	11 00 00 
  current_thread->state = RUNNING;
 12a:	a1 20 11 00 00       	mov    0x1120,%eax
 12f:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 136:	00 00 00 
  current_thread->tid=0;
 139:	a1 20 11 00 00       	mov    0x1120,%eax
 13e:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 145:	00 00 00 
  current_thread->ptid=0;
 148:	a1 20 11 00 00       	mov    0x1120,%eax
 14d:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 154:	00 00 00 
}
 157:	90                   	nop
 158:	c9                   	leave  
 159:	c3                   	ret    

0000015a <thread_create>:

void 
thread_create(void (*func)())
{
 15a:	55                   	push   %ebp
 15b:	89 e5                	mov    %esp,%ebp
 15d:	53                   	push   %ebx
 15e:	83 ec 14             	sub    $0x14,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 161:	c7 45 f4 40 11 00 00 	movl   $0x1140,-0xc(%ebp)
 168:	eb 14                	jmp    17e <thread_create+0x24>
    if (t->state == FREE) break;
 16a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16d:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 173:	85 c0                	test   %eax,%eax
 175:	74 13                	je     18a <thread_create+0x30>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 177:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
 17e:	b8 e0 51 01 00       	mov    $0x151e0,%eax
 183:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 186:	72 e2                	jb     16a <thread_create+0x10>
 188:	eb 01                	jmp    18b <thread_create+0x31>
    if (t->state == FREE) break;
 18a:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 18b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18e:	83 c0 04             	add    $0x4,%eax
 191:	05 00 20 00 00       	add    $0x2000,%eax
 196:	89 c2                	mov    %eax,%edx
 198:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19b:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 19d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a0:	8b 00                	mov    (%eax),%eax
 1a2:	8d 50 fc             	lea    -0x4(%eax),%edx
 1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a8:	89 10                	mov    %edx,(%eax)
  /* 
    set tid and ptid 부모 스레드와 자식 스레드 명시
  */
  t->tid = t - all_thread;
 1aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ad:	2d 40 11 00 00       	sub    $0x1140,%eax
 1b2:	c1 f8 04             	sar    $0x4,%eax
 1b5:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 1bb:	89 c2                	mov    %eax,%edx
 1bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c0:	89 90 08 20 00 00    	mov    %edx,0x2008(%eax)
  t->ptid = current_thread->tid;
 1c6:	a1 20 11 00 00       	mov    0x1120,%eax
 1cb:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
 1d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d4:	89 90 0c 20 00 00    	mov    %edx,0x200c(%eax)
  
  * (int *) (t->sp) = (int)func;           // push return address on stack
 1da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dd:	8b 00                	mov    (%eax),%eax
 1df:	89 c2                	mov    %eax,%edx
 1e1:	8b 45 08             	mov    0x8(%ebp),%eax
 1e4:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 1e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e9:	8b 00                	mov    (%eax),%eax
 1eb:	8d 50 e0             	lea    -0x20(%eax),%edx
 1ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f1:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 1f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f6:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1fd:	00 00 00 
  check_counter(+1);
 200:	83 ec 0c             	sub    $0xc,%esp
 203:	6a 01                	push   $0x1
 205:	e8 51 06 00 00       	call   85b <check_counter>
 20a:	83 c4 10             	add    $0x10,%esp
  printf(1, "thread_create: tid=%d ptid=%d func=0x%x *ret=0x%x\n",
    t->tid, t->ptid, (int)func, *(int *)(t->sp));
 20d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 210:	8b 00                	mov    (%eax),%eax
  printf(1, "thread_create: tid=%d ptid=%d func=0x%x *ret=0x%x\n",
 212:	8b 18                	mov    (%eax),%ebx
 214:	8b 4d 08             	mov    0x8(%ebp),%ecx
 217:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21a:	8b 90 0c 20 00 00    	mov    0x200c(%eax),%edx
 220:	8b 45 f4             	mov    -0xc(%ebp),%eax
 223:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 229:	83 ec 08             	sub    $0x8,%esp
 22c:	53                   	push   %ebx
 22d:	51                   	push   %ecx
 22e:	52                   	push   %edx
 22f:	50                   	push   %eax
 230:	68 18 0d 00 00       	push   $0xd18
 235:	6a 01                	push   $0x1
 237:	e8 fb 06 00 00       	call   937 <printf>
 23c:	83 c4 20             	add    $0x20,%esp
}
 23f:	90                   	nop
 240:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 243:	c9                   	leave  
 244:	c3                   	ret    

00000245 <thread_join_all>:

static void 
thread_join_all(void)
{
 245:	55                   	push   %ebp
 246:	89 e5                	mov    %esp,%ebp
 248:	83 ec 18             	sub    $0x18,%esp
  /*
    it returns when all child threads have exited. 자식 스레드가 끝날 때까지 부모 스레드 대기
  */
 while (1) {
    int found = 0;
 24b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (int i = 0; i < MAX_THREAD; i++) {
 252:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 259:	eb 43                	jmp    29e <thread_join_all+0x59>
      thread_p t = &all_thread[i];
 25b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 25e:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 264:	05 40 11 00 00       	add    $0x1140,%eax
 269:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if (t->state != FREE && t->ptid == current_thread->tid) {
 26c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 26f:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 275:	85 c0                	test   %eax,%eax
 277:	74 21                	je     29a <thread_join_all+0x55>
 279:	8b 45 ec             	mov    -0x14(%ebp),%eax
 27c:	8b 90 0c 20 00 00    	mov    0x200c(%eax),%edx
 282:	a1 20 11 00 00       	mov    0x1120,%eax
 287:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 28d:	39 c2                	cmp    %eax,%edx
 28f:	75 09                	jne    29a <thread_join_all+0x55>
        found = 1;
 291:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        break;
 298:	eb 0a                	jmp    2a4 <thread_join_all+0x5f>
    for (int i = 0; i < MAX_THREAD; i++) {
 29a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 29e:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 2a2:	7e b7                	jle    25b <thread_join_all+0x16>
      }
    }

    if (!found)
 2a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a8:	74 16                	je     2c0 <thread_join_all+0x7b>
      break;

    current_thread->state = WAIT;
 2aa:	a1 20 11 00 00       	mov    0x1120,%eax
 2af:	c7 80 04 20 00 00 03 	movl   $0x3,0x2004(%eax)
 2b6:	00 00 00 
    thread_schedule();
 2b9:	e8 42 fd ff ff       	call   0 <thread_schedule>
 while (1) {
 2be:	eb 8b                	jmp    24b <thread_join_all+0x6>
      break;
 2c0:	90                   	nop
  }
}
 2c1:	90                   	nop
 2c2:	c9                   	leave  
 2c3:	c3                   	ret    

000002c4 <wake_pthread>:

static void
wake_pthread(void)
{
 2c4:	55                   	push   %ebp
 2c5:	89 e5                	mov    %esp,%ebp
 2c7:	83 ec 10             	sub    $0x10,%esp
  int ptid = current_thread->ptid;
 2ca:	a1 20 11 00 00       	mov    0x1120,%eax
 2cf:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 2d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int child_alive = 0;
 2d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

  // 자식 스레드가 남아 있는지 확인
  for (int i = 0; i < MAX_THREAD; i++) {
 2df:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
 2e6:	eb 55                	jmp    33d <wake_pthread+0x79>
    if (all_thread[i].ptid == ptid &&
 2e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2eb:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 2f1:	05 4c 31 00 00       	add    $0x314c,%eax
 2f6:	8b 00                	mov    (%eax),%eax
 2f8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
 2fb:	75 3c                	jne    339 <wake_pthread+0x75>
        all_thread[i].tid != current_thread->tid && // 자기 자신 제외
 2fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 300:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 306:	05 48 31 00 00       	add    $0x3148,%eax
 30b:	8b 10                	mov    (%eax),%edx
 30d:	a1 20 11 00 00       	mov    0x1120,%eax
 312:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
    if (all_thread[i].ptid == ptid &&
 318:	39 c2                	cmp    %eax,%edx
 31a:	74 1d                	je     339 <wake_pthread+0x75>
        all_thread[i].state != FREE) {
 31c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 31f:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 325:	05 44 31 00 00       	add    $0x3144,%eax
 32a:	8b 00                	mov    (%eax),%eax
        all_thread[i].tid != current_thread->tid && // 자기 자신 제외
 32c:	85 c0                	test   %eax,%eax
 32e:	74 09                	je     339 <wake_pthread+0x75>
      child_alive = 1;
 330:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
      break;
 337:	eb 0a                	jmp    343 <wake_pthread+0x7f>
  for (int i = 0; i < MAX_THREAD; i++) {
 339:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 33d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
 341:	7e a5                	jle    2e8 <wake_pthread+0x24>
    }
  }

  // 자식이 모두 종료되었으면, 부모 스레드 깨우기
  if (!child_alive) {
 343:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
 347:	75 54                	jne    39d <wake_pthread+0xd9>
    for (int i = 0; i < MAX_THREAD; i++) {
 349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 350:	eb 45                	jmp    397 <wake_pthread+0xd3>
      if (all_thread[i].tid == ptid &&
 352:	8b 45 f4             	mov    -0xc(%ebp),%eax
 355:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 35b:	05 48 31 00 00       	add    $0x3148,%eax
 360:	8b 00                	mov    (%eax),%eax
 362:	39 45 f0             	cmp    %eax,-0x10(%ebp)
 365:	75 2c                	jne    393 <wake_pthread+0xcf>
          all_thread[i].state == WAIT) {
 367:	8b 45 f4             	mov    -0xc(%ebp),%eax
 36a:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 370:	05 44 31 00 00       	add    $0x3144,%eax
 375:	8b 00                	mov    (%eax),%eax
      if (all_thread[i].tid == ptid &&
 377:	83 f8 03             	cmp    $0x3,%eax
 37a:	75 17                	jne    393 <wake_pthread+0xcf>
        all_thread[i].state = RUNNABLE;
 37c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37f:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 385:	05 44 31 00 00       	add    $0x3144,%eax
 38a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
        break;
 390:	90                   	nop
      }
    }
  }
}
 391:	eb 0a                	jmp    39d <wake_pthread+0xd9>
    for (int i = 0; i < MAX_THREAD; i++) {
 393:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 397:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 39b:	7e b5                	jle    352 <wake_pthread+0x8e>
}
 39d:	90                   	nop
 39e:	c9                   	leave  
 39f:	c3                   	ret    

000003a0 <child_thread>:


static void 
child_thread(void)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "child thread running\n");
 3a6:	83 ec 08             	sub    $0x8,%esp
 3a9:	68 4b 0d 00 00       	push   $0xd4b
 3ae:	6a 01                	push   $0x1
 3b0:	e8 82 05 00 00       	call   937 <printf>
 3b5:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 3b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3bf:	eb 1c                	jmp    3dd <child_thread+0x3d>
    printf(1, "child thread 0x%x\n", (int) current_thread);
 3c1:	a1 20 11 00 00       	mov    0x1120,%eax
 3c6:	83 ec 04             	sub    $0x4,%esp
 3c9:	50                   	push   %eax
 3ca:	68 61 0d 00 00       	push   $0xd61
 3cf:	6a 01                	push   $0x1
 3d1:	e8 61 05 00 00       	call   937 <printf>
 3d6:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 3d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3dd:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 3e1:	7e de                	jle    3c1 <child_thread+0x21>
  }
  printf(1, "child thread: exit\n");
 3e3:	83 ec 08             	sub    $0x8,%esp
 3e6:	68 74 0d 00 00       	push   $0xd74
 3eb:	6a 01                	push   $0x1
 3ed:	e8 45 05 00 00       	call   937 <printf>
 3f2:	83 c4 10             	add    $0x10,%esp
  //current_thread->state = FREE;

  for (int i = 0; i < MAX_THREAD; i++) {
 3f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 3fc:	eb 4a                	jmp    448 <child_thread+0xa8>
    thread_p p = &all_thread[i];
 3fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 401:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 407:	05 40 11 00 00       	add    $0x1140,%eax
 40c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (p->tid == current_thread->ptid && p->state == WAIT) {
 40f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 412:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
 418:	a1 20 11 00 00       	mov    0x1120,%eax
 41d:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 423:	39 c2                	cmp    %eax,%edx
 425:	75 1d                	jne    444 <child_thread+0xa4>
 427:	8b 45 ec             	mov    -0x14(%ebp),%eax
 42a:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 430:	83 f8 03             	cmp    $0x3,%eax
 433:	75 0f                	jne    444 <child_thread+0xa4>
      p->state = RUNNABLE;
 435:	8b 45 ec             	mov    -0x14(%ebp),%eax
 438:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 43f:	00 00 00 
      break;
 442:	eb 0a                	jmp    44e <child_thread+0xae>
  for (int i = 0; i < MAX_THREAD; i++) {
 444:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 448:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 44c:	7e b0                	jle    3fe <child_thread+0x5e>
    }
  }

  current_thread->state = FREE;
 44e:	a1 20 11 00 00       	mov    0x1120,%eax
 453:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 45a:	00 00 00 

  check_counter(-1);
 45d:	83 ec 0c             	sub    $0xc,%esp
 460:	6a ff                	push   $0xffffffff
 462:	e8 f4 03 00 00       	call   85b <check_counter>
 467:	83 c4 10             	add    $0x10,%esp
  wake_pthread();
 46a:	e8 55 fe ff ff       	call   2c4 <wake_pthread>
  thread_schedule();
 46f:	e8 8c fb ff ff       	call   0 <thread_schedule>
}
 474:	90                   	nop
 475:	c9                   	leave  
 476:	c3                   	ret    

00000477 <mythread>:

void 
mythread(void)
{
 477:	55                   	push   %ebp
 478:	89 e5                	mov    %esp,%ebp
 47a:	83 ec 18             	sub    $0x18,%esp
  printf(1,"thread start\n");
 47d:	83 ec 08             	sub    $0x8,%esp
 480:	68 88 0d 00 00       	push   $0xd88
 485:	6a 01                	push   $0x1
 487:	e8 ab 04 00 00       	call   937 <printf>
 48c:	83 c4 10             	add    $0x10,%esp
  int i;
  printf(1, "my thread running\n");
 48f:	83 ec 08             	sub    $0x8,%esp
 492:	68 96 0d 00 00       	push   $0xd96
 497:	6a 01                	push   $0x1
 499:	e8 99 04 00 00       	call   937 <printf>
 49e:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 4a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4a8:	eb 14                	jmp    4be <mythread+0x47>
    thread_create(child_thread);
 4aa:	83 ec 0c             	sub    $0xc,%esp
 4ad:	68 a0 03 00 00       	push   $0x3a0
 4b2:	e8 a3 fc ff ff       	call   15a <thread_create>
 4b7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 4ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 4be:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 4c2:	7e e6                	jle    4aa <mythread+0x33>
  }
  thread_join_all();
 4c4:	e8 7c fd ff ff       	call   245 <thread_join_all>
  printf(1, "my thread: exit\n");
 4c9:	83 ec 08             	sub    $0x8,%esp
 4cc:	68 a9 0d 00 00       	push   $0xda9
 4d1:	6a 01                	push   $0x1
 4d3:	e8 5f 04 00 00       	call   937 <printf>
 4d8:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 4db:	a1 20 11 00 00       	mov    0x1120,%eax
 4e0:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 4e7:	00 00 00 

  check_counter(-1);
 4ea:	83 ec 0c             	sub    $0xc,%esp
 4ed:	6a ff                	push   $0xffffffff
 4ef:	e8 67 03 00 00       	call   85b <check_counter>
 4f4:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 4f7:	e8 04 fb ff ff       	call   0 <thread_schedule>
}
 4fc:	90                   	nop
 4fd:	c9                   	leave  
 4fe:	c3                   	ret    

000004ff <main>:

int 
main(int argc, char *argv[]) 
{
 4ff:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 503:	83 e4 f0             	and    $0xfffffff0,%esp
 506:	ff 71 fc             	push   -0x4(%ecx)
 509:	55                   	push   %ebp
 50a:	89 e5                	mov    %esp,%ebp
 50c:	51                   	push   %ecx
 50d:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 510:	e8 f4 fb ff ff       	call   109 <thread_init>
  thread_create(mythread);
 515:	83 ec 0c             	sub    $0xc,%esp
 518:	68 77 04 00 00       	push   $0x477
 51d:	e8 38 fc ff ff       	call   15a <thread_create>
 522:	83 c4 10             	add    $0x10,%esp
  thread_join_all();
 525:	e8 1b fd ff ff       	call   245 <thread_join_all>
  return 0;
 52a:	b8 00 00 00 00       	mov    $0x0,%eax
 52f:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 532:	c9                   	leave  
 533:	8d 61 fc             	lea    -0x4(%ecx),%esp
 536:	c3                   	ret    

00000537 <thread_switch>:
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	pushal
 537:	60                   	pusha  

   movl current_thread, %eax
 538:	a1 20 11 00 00       	mov    0x1120,%eax
   movl %esp, (%eax)
 53d:	89 20                	mov    %esp,(%eax)

   movl next_thread, %eax      # eax = next_thread  현재 실행 중인 스레드 구조체의 주소를 eax에 저장
 53f:	a1 24 11 00 00       	mov    0x1124,%eax
    movl (%eax), %esp           # esp = next_thread->sp 현재 실행 중인 스레드의 현
 544:	8b 20                	mov    (%eax),%esp

    movl next_thread, %eax
 546:	a1 24 11 00 00       	mov    0x1124,%eax
    movl %eax, current_thread   # current_thread = next_thread
 54b:	a3 20 11 00 00       	mov    %eax,0x1120

    popal
 550:	61                   	popa   

   movl $0, next_thread
 551:	c7 05 24 11 00 00 00 	movl   $0x0,0x1124
 558:	00 00 00 

	ret    /* return to ra */
 55b:	c3                   	ret    

0000055c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 55c:	55                   	push   %ebp
 55d:	89 e5                	mov    %esp,%ebp
 55f:	57                   	push   %edi
 560:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 561:	8b 4d 08             	mov    0x8(%ebp),%ecx
 564:	8b 55 10             	mov    0x10(%ebp),%edx
 567:	8b 45 0c             	mov    0xc(%ebp),%eax
 56a:	89 cb                	mov    %ecx,%ebx
 56c:	89 df                	mov    %ebx,%edi
 56e:	89 d1                	mov    %edx,%ecx
 570:	fc                   	cld    
 571:	f3 aa                	rep stos %al,%es:(%edi)
 573:	89 ca                	mov    %ecx,%edx
 575:	89 fb                	mov    %edi,%ebx
 577:	89 5d 08             	mov    %ebx,0x8(%ebp)
 57a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 57d:	90                   	nop
 57e:	5b                   	pop    %ebx
 57f:	5f                   	pop    %edi
 580:	5d                   	pop    %ebp
 581:	c3                   	ret    

00000582 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 582:	55                   	push   %ebp
 583:	89 e5                	mov    %esp,%ebp
 585:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 588:	8b 45 08             	mov    0x8(%ebp),%eax
 58b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 58e:	90                   	nop
 58f:	8b 55 0c             	mov    0xc(%ebp),%edx
 592:	8d 42 01             	lea    0x1(%edx),%eax
 595:	89 45 0c             	mov    %eax,0xc(%ebp)
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	8d 48 01             	lea    0x1(%eax),%ecx
 59e:	89 4d 08             	mov    %ecx,0x8(%ebp)
 5a1:	0f b6 12             	movzbl (%edx),%edx
 5a4:	88 10                	mov    %dl,(%eax)
 5a6:	0f b6 00             	movzbl (%eax),%eax
 5a9:	84 c0                	test   %al,%al
 5ab:	75 e2                	jne    58f <strcpy+0xd>
    ;
  return os;
 5ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5b0:	c9                   	leave  
 5b1:	c3                   	ret    

000005b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5b2:	55                   	push   %ebp
 5b3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 5b5:	eb 08                	jmp    5bf <strcmp+0xd>
    p++, q++;
 5b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5bb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 5bf:	8b 45 08             	mov    0x8(%ebp),%eax
 5c2:	0f b6 00             	movzbl (%eax),%eax
 5c5:	84 c0                	test   %al,%al
 5c7:	74 10                	je     5d9 <strcmp+0x27>
 5c9:	8b 45 08             	mov    0x8(%ebp),%eax
 5cc:	0f b6 10             	movzbl (%eax),%edx
 5cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d2:	0f b6 00             	movzbl (%eax),%eax
 5d5:	38 c2                	cmp    %al,%dl
 5d7:	74 de                	je     5b7 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 5d9:	8b 45 08             	mov    0x8(%ebp),%eax
 5dc:	0f b6 00             	movzbl (%eax),%eax
 5df:	0f b6 d0             	movzbl %al,%edx
 5e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e5:	0f b6 00             	movzbl (%eax),%eax
 5e8:	0f b6 c8             	movzbl %al,%ecx
 5eb:	89 d0                	mov    %edx,%eax
 5ed:	29 c8                	sub    %ecx,%eax
}
 5ef:	5d                   	pop    %ebp
 5f0:	c3                   	ret    

000005f1 <strlen>:

uint
strlen(char *s)
{
 5f1:	55                   	push   %ebp
 5f2:	89 e5                	mov    %esp,%ebp
 5f4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 5f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 5fe:	eb 04                	jmp    604 <strlen+0x13>
 600:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 604:	8b 55 fc             	mov    -0x4(%ebp),%edx
 607:	8b 45 08             	mov    0x8(%ebp),%eax
 60a:	01 d0                	add    %edx,%eax
 60c:	0f b6 00             	movzbl (%eax),%eax
 60f:	84 c0                	test   %al,%al
 611:	75 ed                	jne    600 <strlen+0xf>
    ;
  return n;
 613:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 616:	c9                   	leave  
 617:	c3                   	ret    

00000618 <memset>:

void*
memset(void *dst, int c, uint n)
{
 618:	55                   	push   %ebp
 619:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 61b:	8b 45 10             	mov    0x10(%ebp),%eax
 61e:	50                   	push   %eax
 61f:	ff 75 0c             	push   0xc(%ebp)
 622:	ff 75 08             	push   0x8(%ebp)
 625:	e8 32 ff ff ff       	call   55c <stosb>
 62a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 62d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 630:	c9                   	leave  
 631:	c3                   	ret    

00000632 <strchr>:

char*
strchr(const char *s, char c)
{
 632:	55                   	push   %ebp
 633:	89 e5                	mov    %esp,%ebp
 635:	83 ec 04             	sub    $0x4,%esp
 638:	8b 45 0c             	mov    0xc(%ebp),%eax
 63b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 63e:	eb 14                	jmp    654 <strchr+0x22>
    if(*s == c)
 640:	8b 45 08             	mov    0x8(%ebp),%eax
 643:	0f b6 00             	movzbl (%eax),%eax
 646:	38 45 fc             	cmp    %al,-0x4(%ebp)
 649:	75 05                	jne    650 <strchr+0x1e>
      return (char*)s;
 64b:	8b 45 08             	mov    0x8(%ebp),%eax
 64e:	eb 13                	jmp    663 <strchr+0x31>
  for(; *s; s++)
 650:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 654:	8b 45 08             	mov    0x8(%ebp),%eax
 657:	0f b6 00             	movzbl (%eax),%eax
 65a:	84 c0                	test   %al,%al
 65c:	75 e2                	jne    640 <strchr+0xe>
  return 0;
 65e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 663:	c9                   	leave  
 664:	c3                   	ret    

00000665 <gets>:

char*
gets(char *buf, int max)
{
 665:	55                   	push   %ebp
 666:	89 e5                	mov    %esp,%ebp
 668:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 66b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 672:	eb 42                	jmp    6b6 <gets+0x51>
    cc = read(0, &c, 1);
 674:	83 ec 04             	sub    $0x4,%esp
 677:	6a 01                	push   $0x1
 679:	8d 45 ef             	lea    -0x11(%ebp),%eax
 67c:	50                   	push   %eax
 67d:	6a 00                	push   $0x0
 67f:	e8 47 01 00 00       	call   7cb <read>
 684:	83 c4 10             	add    $0x10,%esp
 687:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 68a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 68e:	7e 33                	jle    6c3 <gets+0x5e>
      break;
    buf[i++] = c;
 690:	8b 45 f4             	mov    -0xc(%ebp),%eax
 693:	8d 50 01             	lea    0x1(%eax),%edx
 696:	89 55 f4             	mov    %edx,-0xc(%ebp)
 699:	89 c2                	mov    %eax,%edx
 69b:	8b 45 08             	mov    0x8(%ebp),%eax
 69e:	01 c2                	add    %eax,%edx
 6a0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6a4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 6a6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6aa:	3c 0a                	cmp    $0xa,%al
 6ac:	74 16                	je     6c4 <gets+0x5f>
 6ae:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6b2:	3c 0d                	cmp    $0xd,%al
 6b4:	74 0e                	je     6c4 <gets+0x5f>
  for(i=0; i+1 < max; ){
 6b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b9:	83 c0 01             	add    $0x1,%eax
 6bc:	39 45 0c             	cmp    %eax,0xc(%ebp)
 6bf:	7f b3                	jg     674 <gets+0xf>
 6c1:	eb 01                	jmp    6c4 <gets+0x5f>
      break;
 6c3:	90                   	nop
      break;
  }
  buf[i] = '\0';
 6c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	01 d0                	add    %edx,%eax
 6cc:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 6cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6d2:	c9                   	leave  
 6d3:	c3                   	ret    

000006d4 <stat>:

int
stat(char *n, struct stat *st)
{
 6d4:	55                   	push   %ebp
 6d5:	89 e5                	mov    %esp,%ebp
 6d7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6da:	83 ec 08             	sub    $0x8,%esp
 6dd:	6a 00                	push   $0x0
 6df:	ff 75 08             	push   0x8(%ebp)
 6e2:	e8 0c 01 00 00       	call   7f3 <open>
 6e7:	83 c4 10             	add    $0x10,%esp
 6ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 6ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f1:	79 07                	jns    6fa <stat+0x26>
    return -1;
 6f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 6f8:	eb 25                	jmp    71f <stat+0x4b>
  r = fstat(fd, st);
 6fa:	83 ec 08             	sub    $0x8,%esp
 6fd:	ff 75 0c             	push   0xc(%ebp)
 700:	ff 75 f4             	push   -0xc(%ebp)
 703:	e8 03 01 00 00       	call   80b <fstat>
 708:	83 c4 10             	add    $0x10,%esp
 70b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 70e:	83 ec 0c             	sub    $0xc,%esp
 711:	ff 75 f4             	push   -0xc(%ebp)
 714:	e8 c2 00 00 00       	call   7db <close>
 719:	83 c4 10             	add    $0x10,%esp
  return r;
 71c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 71f:	c9                   	leave  
 720:	c3                   	ret    

00000721 <atoi>:

int
atoi(const char *s)
{
 721:	55                   	push   %ebp
 722:	89 e5                	mov    %esp,%ebp
 724:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 727:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 72e:	eb 25                	jmp    755 <atoi+0x34>
    n = n*10 + *s++ - '0';
 730:	8b 55 fc             	mov    -0x4(%ebp),%edx
 733:	89 d0                	mov    %edx,%eax
 735:	c1 e0 02             	shl    $0x2,%eax
 738:	01 d0                	add    %edx,%eax
 73a:	01 c0                	add    %eax,%eax
 73c:	89 c1                	mov    %eax,%ecx
 73e:	8b 45 08             	mov    0x8(%ebp),%eax
 741:	8d 50 01             	lea    0x1(%eax),%edx
 744:	89 55 08             	mov    %edx,0x8(%ebp)
 747:	0f b6 00             	movzbl (%eax),%eax
 74a:	0f be c0             	movsbl %al,%eax
 74d:	01 c8                	add    %ecx,%eax
 74f:	83 e8 30             	sub    $0x30,%eax
 752:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 755:	8b 45 08             	mov    0x8(%ebp),%eax
 758:	0f b6 00             	movzbl (%eax),%eax
 75b:	3c 2f                	cmp    $0x2f,%al
 75d:	7e 0a                	jle    769 <atoi+0x48>
 75f:	8b 45 08             	mov    0x8(%ebp),%eax
 762:	0f b6 00             	movzbl (%eax),%eax
 765:	3c 39                	cmp    $0x39,%al
 767:	7e c7                	jle    730 <atoi+0xf>
  return n;
 769:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 76c:	c9                   	leave  
 76d:	c3                   	ret    

0000076e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 76e:	55                   	push   %ebp
 76f:	89 e5                	mov    %esp,%ebp
 771:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 774:	8b 45 08             	mov    0x8(%ebp),%eax
 777:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 77a:	8b 45 0c             	mov    0xc(%ebp),%eax
 77d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 780:	eb 17                	jmp    799 <memmove+0x2b>
    *dst++ = *src++;
 782:	8b 55 f8             	mov    -0x8(%ebp),%edx
 785:	8d 42 01             	lea    0x1(%edx),%eax
 788:	89 45 f8             	mov    %eax,-0x8(%ebp)
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	8d 48 01             	lea    0x1(%eax),%ecx
 791:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 794:	0f b6 12             	movzbl (%edx),%edx
 797:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 799:	8b 45 10             	mov    0x10(%ebp),%eax
 79c:	8d 50 ff             	lea    -0x1(%eax),%edx
 79f:	89 55 10             	mov    %edx,0x10(%ebp)
 7a2:	85 c0                	test   %eax,%eax
 7a4:	7f dc                	jg     782 <memmove+0x14>
  return vdst;
 7a6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7a9:	c9                   	leave  
 7aa:	c3                   	ret    

000007ab <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 7ab:	b8 01 00 00 00       	mov    $0x1,%eax
 7b0:	cd 40                	int    $0x40
 7b2:	c3                   	ret    

000007b3 <exit>:
SYSCALL(exit)
 7b3:	b8 02 00 00 00       	mov    $0x2,%eax
 7b8:	cd 40                	int    $0x40
 7ba:	c3                   	ret    

000007bb <wait>:
SYSCALL(wait)
 7bb:	b8 03 00 00 00       	mov    $0x3,%eax
 7c0:	cd 40                	int    $0x40
 7c2:	c3                   	ret    

000007c3 <pipe>:
SYSCALL(pipe)
 7c3:	b8 04 00 00 00       	mov    $0x4,%eax
 7c8:	cd 40                	int    $0x40
 7ca:	c3                   	ret    

000007cb <read>:
SYSCALL(read)
 7cb:	b8 05 00 00 00       	mov    $0x5,%eax
 7d0:	cd 40                	int    $0x40
 7d2:	c3                   	ret    

000007d3 <write>:
SYSCALL(write)
 7d3:	b8 10 00 00 00       	mov    $0x10,%eax
 7d8:	cd 40                	int    $0x40
 7da:	c3                   	ret    

000007db <close>:
SYSCALL(close)
 7db:	b8 15 00 00 00       	mov    $0x15,%eax
 7e0:	cd 40                	int    $0x40
 7e2:	c3                   	ret    

000007e3 <kill>:
SYSCALL(kill)
 7e3:	b8 06 00 00 00       	mov    $0x6,%eax
 7e8:	cd 40                	int    $0x40
 7ea:	c3                   	ret    

000007eb <exec>:
SYSCALL(exec)
 7eb:	b8 07 00 00 00       	mov    $0x7,%eax
 7f0:	cd 40                	int    $0x40
 7f2:	c3                   	ret    

000007f3 <open>:
SYSCALL(open)
 7f3:	b8 0f 00 00 00       	mov    $0xf,%eax
 7f8:	cd 40                	int    $0x40
 7fa:	c3                   	ret    

000007fb <mknod>:
SYSCALL(mknod)
 7fb:	b8 11 00 00 00       	mov    $0x11,%eax
 800:	cd 40                	int    $0x40
 802:	c3                   	ret    

00000803 <unlink>:
SYSCALL(unlink)
 803:	b8 12 00 00 00       	mov    $0x12,%eax
 808:	cd 40                	int    $0x40
 80a:	c3                   	ret    

0000080b <fstat>:
SYSCALL(fstat)
 80b:	b8 08 00 00 00       	mov    $0x8,%eax
 810:	cd 40                	int    $0x40
 812:	c3                   	ret    

00000813 <link>:
SYSCALL(link)
 813:	b8 13 00 00 00       	mov    $0x13,%eax
 818:	cd 40                	int    $0x40
 81a:	c3                   	ret    

0000081b <mkdir>:
SYSCALL(mkdir)
 81b:	b8 14 00 00 00       	mov    $0x14,%eax
 820:	cd 40                	int    $0x40
 822:	c3                   	ret    

00000823 <chdir>:
SYSCALL(chdir)
 823:	b8 09 00 00 00       	mov    $0x9,%eax
 828:	cd 40                	int    $0x40
 82a:	c3                   	ret    

0000082b <dup>:
SYSCALL(dup)
 82b:	b8 0a 00 00 00       	mov    $0xa,%eax
 830:	cd 40                	int    $0x40
 832:	c3                   	ret    

00000833 <getpid>:
SYSCALL(getpid)
 833:	b8 0b 00 00 00       	mov    $0xb,%eax
 838:	cd 40                	int    $0x40
 83a:	c3                   	ret    

0000083b <sbrk>:
SYSCALL(sbrk)
 83b:	b8 0c 00 00 00       	mov    $0xc,%eax
 840:	cd 40                	int    $0x40
 842:	c3                   	ret    

00000843 <sleep>:
SYSCALL(sleep)
 843:	b8 0d 00 00 00       	mov    $0xd,%eax
 848:	cd 40                	int    $0x40
 84a:	c3                   	ret    

0000084b <uptime>:
SYSCALL(uptime)
 84b:	b8 0e 00 00 00       	mov    $0xe,%eax
 850:	cd 40                	int    $0x40
 852:	c3                   	ret    

00000853 <uthread_init>:

SYSCALL(uthread_init)
 853:	b8 16 00 00 00       	mov    $0x16,%eax
 858:	cd 40                	int    $0x40
 85a:	c3                   	ret    

0000085b <check_counter>:
 85b:	b8 17 00 00 00       	mov    $0x17,%eax
 860:	cd 40                	int    $0x40
 862:	c3                   	ret    

00000863 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 863:	55                   	push   %ebp
 864:	89 e5                	mov    %esp,%ebp
 866:	83 ec 18             	sub    $0x18,%esp
 869:	8b 45 0c             	mov    0xc(%ebp),%eax
 86c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 86f:	83 ec 04             	sub    $0x4,%esp
 872:	6a 01                	push   $0x1
 874:	8d 45 f4             	lea    -0xc(%ebp),%eax
 877:	50                   	push   %eax
 878:	ff 75 08             	push   0x8(%ebp)
 87b:	e8 53 ff ff ff       	call   7d3 <write>
 880:	83 c4 10             	add    $0x10,%esp
}
 883:	90                   	nop
 884:	c9                   	leave  
 885:	c3                   	ret    

00000886 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 886:	55                   	push   %ebp
 887:	89 e5                	mov    %esp,%ebp
 889:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 88c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 893:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 897:	74 17                	je     8b0 <printint+0x2a>
 899:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 89d:	79 11                	jns    8b0 <printint+0x2a>
    neg = 1;
 89f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 8a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 8a9:	f7 d8                	neg    %eax
 8ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8ae:	eb 06                	jmp    8b6 <printint+0x30>
  } else {
    x = xx;
 8b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 8b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 8b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 8bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c3:	ba 00 00 00 00       	mov    $0x0,%edx
 8c8:	f7 f1                	div    %ecx
 8ca:	89 d1                	mov    %edx,%ecx
 8cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cf:	8d 50 01             	lea    0x1(%eax),%edx
 8d2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8d5:	0f b6 91 f4 10 00 00 	movzbl 0x10f4(%ecx),%edx
 8dc:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 8e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8e6:	ba 00 00 00 00       	mov    $0x0,%edx
 8eb:	f7 f1                	div    %ecx
 8ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8f4:	75 c7                	jne    8bd <printint+0x37>
  if(neg)
 8f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8fa:	74 2d                	je     929 <printint+0xa3>
    buf[i++] = '-';
 8fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ff:	8d 50 01             	lea    0x1(%eax),%edx
 902:	89 55 f4             	mov    %edx,-0xc(%ebp)
 905:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 90a:	eb 1d                	jmp    929 <printint+0xa3>
    putc(fd, buf[i]);
 90c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	01 d0                	add    %edx,%eax
 914:	0f b6 00             	movzbl (%eax),%eax
 917:	0f be c0             	movsbl %al,%eax
 91a:	83 ec 08             	sub    $0x8,%esp
 91d:	50                   	push   %eax
 91e:	ff 75 08             	push   0x8(%ebp)
 921:	e8 3d ff ff ff       	call   863 <putc>
 926:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 929:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 92d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 931:	79 d9                	jns    90c <printint+0x86>
}
 933:	90                   	nop
 934:	90                   	nop
 935:	c9                   	leave  
 936:	c3                   	ret    

00000937 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 937:	55                   	push   %ebp
 938:	89 e5                	mov    %esp,%ebp
 93a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 93d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 944:	8d 45 0c             	lea    0xc(%ebp),%eax
 947:	83 c0 04             	add    $0x4,%eax
 94a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 94d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 954:	e9 59 01 00 00       	jmp    ab2 <printf+0x17b>
    c = fmt[i] & 0xff;
 959:	8b 55 0c             	mov    0xc(%ebp),%edx
 95c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95f:	01 d0                	add    %edx,%eax
 961:	0f b6 00             	movzbl (%eax),%eax
 964:	0f be c0             	movsbl %al,%eax
 967:	25 ff 00 00 00       	and    $0xff,%eax
 96c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 96f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 973:	75 2c                	jne    9a1 <printf+0x6a>
      if(c == '%'){
 975:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 979:	75 0c                	jne    987 <printf+0x50>
        state = '%';
 97b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 982:	e9 27 01 00 00       	jmp    aae <printf+0x177>
      } else {
        putc(fd, c);
 987:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 98a:	0f be c0             	movsbl %al,%eax
 98d:	83 ec 08             	sub    $0x8,%esp
 990:	50                   	push   %eax
 991:	ff 75 08             	push   0x8(%ebp)
 994:	e8 ca fe ff ff       	call   863 <putc>
 999:	83 c4 10             	add    $0x10,%esp
 99c:	e9 0d 01 00 00       	jmp    aae <printf+0x177>
      }
    } else if(state == '%'){
 9a1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 9a5:	0f 85 03 01 00 00    	jne    aae <printf+0x177>
      if(c == 'd'){
 9ab:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 9af:	75 1e                	jne    9cf <printf+0x98>
        printint(fd, *ap, 10, 1);
 9b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9b4:	8b 00                	mov    (%eax),%eax
 9b6:	6a 01                	push   $0x1
 9b8:	6a 0a                	push   $0xa
 9ba:	50                   	push   %eax
 9bb:	ff 75 08             	push   0x8(%ebp)
 9be:	e8 c3 fe ff ff       	call   886 <printint>
 9c3:	83 c4 10             	add    $0x10,%esp
        ap++;
 9c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9ca:	e9 d8 00 00 00       	jmp    aa7 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 9cf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9d3:	74 06                	je     9db <printf+0xa4>
 9d5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9d9:	75 1e                	jne    9f9 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 9db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9de:	8b 00                	mov    (%eax),%eax
 9e0:	6a 00                	push   $0x0
 9e2:	6a 10                	push   $0x10
 9e4:	50                   	push   %eax
 9e5:	ff 75 08             	push   0x8(%ebp)
 9e8:	e8 99 fe ff ff       	call   886 <printint>
 9ed:	83 c4 10             	add    $0x10,%esp
        ap++;
 9f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9f4:	e9 ae 00 00 00       	jmp    aa7 <printf+0x170>
      } else if(c == 's'){
 9f9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9fd:	75 43                	jne    a42 <printf+0x10b>
        s = (char*)*ap;
 9ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a02:	8b 00                	mov    (%eax),%eax
 a04:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a07:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a0f:	75 25                	jne    a36 <printf+0xff>
          s = "(null)";
 a11:	c7 45 f4 ba 0d 00 00 	movl   $0xdba,-0xc(%ebp)
        while(*s != 0){
 a18:	eb 1c                	jmp    a36 <printf+0xff>
          putc(fd, *s);
 a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1d:	0f b6 00             	movzbl (%eax),%eax
 a20:	0f be c0             	movsbl %al,%eax
 a23:	83 ec 08             	sub    $0x8,%esp
 a26:	50                   	push   %eax
 a27:	ff 75 08             	push   0x8(%ebp)
 a2a:	e8 34 fe ff ff       	call   863 <putc>
 a2f:	83 c4 10             	add    $0x10,%esp
          s++;
 a32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a39:	0f b6 00             	movzbl (%eax),%eax
 a3c:	84 c0                	test   %al,%al
 a3e:	75 da                	jne    a1a <printf+0xe3>
 a40:	eb 65                	jmp    aa7 <printf+0x170>
        }
      } else if(c == 'c'){
 a42:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a46:	75 1d                	jne    a65 <printf+0x12e>
        putc(fd, *ap);
 a48:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a4b:	8b 00                	mov    (%eax),%eax
 a4d:	0f be c0             	movsbl %al,%eax
 a50:	83 ec 08             	sub    $0x8,%esp
 a53:	50                   	push   %eax
 a54:	ff 75 08             	push   0x8(%ebp)
 a57:	e8 07 fe ff ff       	call   863 <putc>
 a5c:	83 c4 10             	add    $0x10,%esp
        ap++;
 a5f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a63:	eb 42                	jmp    aa7 <printf+0x170>
      } else if(c == '%'){
 a65:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a69:	75 17                	jne    a82 <printf+0x14b>
        putc(fd, c);
 a6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a6e:	0f be c0             	movsbl %al,%eax
 a71:	83 ec 08             	sub    $0x8,%esp
 a74:	50                   	push   %eax
 a75:	ff 75 08             	push   0x8(%ebp)
 a78:	e8 e6 fd ff ff       	call   863 <putc>
 a7d:	83 c4 10             	add    $0x10,%esp
 a80:	eb 25                	jmp    aa7 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a82:	83 ec 08             	sub    $0x8,%esp
 a85:	6a 25                	push   $0x25
 a87:	ff 75 08             	push   0x8(%ebp)
 a8a:	e8 d4 fd ff ff       	call   863 <putc>
 a8f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a95:	0f be c0             	movsbl %al,%eax
 a98:	83 ec 08             	sub    $0x8,%esp
 a9b:	50                   	push   %eax
 a9c:	ff 75 08             	push   0x8(%ebp)
 a9f:	e8 bf fd ff ff       	call   863 <putc>
 aa4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 aa7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 aae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
 ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab8:	01 d0                	add    %edx,%eax
 aba:	0f b6 00             	movzbl (%eax),%eax
 abd:	84 c0                	test   %al,%al
 abf:	0f 85 94 fe ff ff    	jne    959 <printf+0x22>
    }
  }
}
 ac5:	90                   	nop
 ac6:	90                   	nop
 ac7:	c9                   	leave  
 ac8:	c3                   	ret    

00000ac9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ac9:	55                   	push   %ebp
 aca:	89 e5                	mov    %esp,%ebp
 acc:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 acf:	8b 45 08             	mov    0x8(%ebp),%eax
 ad2:	83 e8 08             	sub    $0x8,%eax
 ad5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ad8:	a1 e8 51 01 00       	mov    0x151e8,%eax
 add:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ae0:	eb 24                	jmp    b06 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ae2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae5:	8b 00                	mov    (%eax),%eax
 ae7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 aea:	72 12                	jb     afe <free+0x35>
 aec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aef:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 af2:	77 24                	ja     b18 <free+0x4f>
 af4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af7:	8b 00                	mov    (%eax),%eax
 af9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 afc:	72 1a                	jb     b18 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 afe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b01:	8b 00                	mov    (%eax),%eax
 b03:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b06:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b09:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 b0c:	76 d4                	jbe    ae2 <free+0x19>
 b0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b11:	8b 00                	mov    (%eax),%eax
 b13:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b16:	73 ca                	jae    ae2 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b18:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b1b:	8b 40 04             	mov    0x4(%eax),%eax
 b1e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b25:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b28:	01 c2                	add    %eax,%edx
 b2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b2d:	8b 00                	mov    (%eax),%eax
 b2f:	39 c2                	cmp    %eax,%edx
 b31:	75 24                	jne    b57 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b33:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b36:	8b 50 04             	mov    0x4(%eax),%edx
 b39:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3c:	8b 00                	mov    (%eax),%eax
 b3e:	8b 40 04             	mov    0x4(%eax),%eax
 b41:	01 c2                	add    %eax,%edx
 b43:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b46:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b49:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4c:	8b 00                	mov    (%eax),%eax
 b4e:	8b 10                	mov    (%eax),%edx
 b50:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b53:	89 10                	mov    %edx,(%eax)
 b55:	eb 0a                	jmp    b61 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b57:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5a:	8b 10                	mov    (%eax),%edx
 b5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b5f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b61:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b64:	8b 40 04             	mov    0x4(%eax),%eax
 b67:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b71:	01 d0                	add    %edx,%eax
 b73:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b76:	75 20                	jne    b98 <free+0xcf>
    p->s.size += bp->s.size;
 b78:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7b:	8b 50 04             	mov    0x4(%eax),%edx
 b7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b81:	8b 40 04             	mov    0x4(%eax),%eax
 b84:	01 c2                	add    %eax,%edx
 b86:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b89:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b8f:	8b 10                	mov    (%eax),%edx
 b91:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b94:	89 10                	mov    %edx,(%eax)
 b96:	eb 08                	jmp    ba0 <free+0xd7>
  } else
    p->s.ptr = bp;
 b98:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b9b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b9e:	89 10                	mov    %edx,(%eax)
  freep = p;
 ba0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba3:	a3 e8 51 01 00       	mov    %eax,0x151e8
}
 ba8:	90                   	nop
 ba9:	c9                   	leave  
 baa:	c3                   	ret    

00000bab <morecore>:

static Header*
morecore(uint nu)
{
 bab:	55                   	push   %ebp
 bac:	89 e5                	mov    %esp,%ebp
 bae:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 bb1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 bb8:	77 07                	ja     bc1 <morecore+0x16>
    nu = 4096;
 bba:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bc1:	8b 45 08             	mov    0x8(%ebp),%eax
 bc4:	c1 e0 03             	shl    $0x3,%eax
 bc7:	83 ec 0c             	sub    $0xc,%esp
 bca:	50                   	push   %eax
 bcb:	e8 6b fc ff ff       	call   83b <sbrk>
 bd0:	83 c4 10             	add    $0x10,%esp
 bd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bd6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bda:	75 07                	jne    be3 <morecore+0x38>
    return 0;
 bdc:	b8 00 00 00 00       	mov    $0x0,%eax
 be1:	eb 26                	jmp    c09 <morecore+0x5e>
  hp = (Header*)p;
 be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bec:	8b 55 08             	mov    0x8(%ebp),%edx
 bef:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf5:	83 c0 08             	add    $0x8,%eax
 bf8:	83 ec 0c             	sub    $0xc,%esp
 bfb:	50                   	push   %eax
 bfc:	e8 c8 fe ff ff       	call   ac9 <free>
 c01:	83 c4 10             	add    $0x10,%esp
  return freep;
 c04:	a1 e8 51 01 00       	mov    0x151e8,%eax
}
 c09:	c9                   	leave  
 c0a:	c3                   	ret    

00000c0b <malloc>:

void*
malloc(uint nbytes)
{
 c0b:	55                   	push   %ebp
 c0c:	89 e5                	mov    %esp,%ebp
 c0e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c11:	8b 45 08             	mov    0x8(%ebp),%eax
 c14:	83 c0 07             	add    $0x7,%eax
 c17:	c1 e8 03             	shr    $0x3,%eax
 c1a:	83 c0 01             	add    $0x1,%eax
 c1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c20:	a1 e8 51 01 00       	mov    0x151e8,%eax
 c25:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c2c:	75 23                	jne    c51 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c2e:	c7 45 f0 e0 51 01 00 	movl   $0x151e0,-0x10(%ebp)
 c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c38:	a3 e8 51 01 00       	mov    %eax,0x151e8
 c3d:	a1 e8 51 01 00       	mov    0x151e8,%eax
 c42:	a3 e0 51 01 00       	mov    %eax,0x151e0
    base.s.size = 0;
 c47:	c7 05 e4 51 01 00 00 	movl   $0x0,0x151e4
 c4e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c54:	8b 00                	mov    (%eax),%eax
 c56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5c:	8b 40 04             	mov    0x4(%eax),%eax
 c5f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c62:	77 4d                	ja     cb1 <malloc+0xa6>
      if(p->s.size == nunits)
 c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c67:	8b 40 04             	mov    0x4(%eax),%eax
 c6a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c6d:	75 0c                	jne    c7b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c72:	8b 10                	mov    (%eax),%edx
 c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c77:	89 10                	mov    %edx,(%eax)
 c79:	eb 26                	jmp    ca1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c7e:	8b 40 04             	mov    0x4(%eax),%eax
 c81:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c84:	89 c2                	mov    %eax,%edx
 c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c89:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8f:	8b 40 04             	mov    0x4(%eax),%eax
 c92:	c1 e0 03             	shl    $0x3,%eax
 c95:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c9b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c9e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ca1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ca4:	a3 e8 51 01 00       	mov    %eax,0x151e8
      return (void*)(p + 1);
 ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cac:	83 c0 08             	add    $0x8,%eax
 caf:	eb 3b                	jmp    cec <malloc+0xe1>
    }
    if(p == freep)
 cb1:	a1 e8 51 01 00       	mov    0x151e8,%eax
 cb6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 cb9:	75 1e                	jne    cd9 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 cbb:	83 ec 0c             	sub    $0xc,%esp
 cbe:	ff 75 ec             	push   -0x14(%ebp)
 cc1:	e8 e5 fe ff ff       	call   bab <morecore>
 cc6:	83 c4 10             	add    $0x10,%esp
 cc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ccc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cd0:	75 07                	jne    cd9 <malloc+0xce>
        return 0;
 cd2:	b8 00 00 00 00       	mov    $0x0,%eax
 cd7:	eb 13                	jmp    cec <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ce2:	8b 00                	mov    (%eax),%eax
 ce4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ce7:	e9 6d ff ff ff       	jmp    c59 <malloc+0x4e>
  }
}
 cec:	c9                   	leave  
 ced:	c3                   	ret    
