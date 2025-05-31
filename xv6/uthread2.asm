
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
   6:	c7 05 c4 10 00 00 00 	movl   $0x0,0x10c4
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 e0 10 00 00 	movl   $0x10e0,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 c0 10 00 00       	mov    0x10c0,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 c4 10 00 00       	mov    %eax,0x10c4
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
  42:	b8 80 51 01 00       	mov    $0x15180,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 80 51 01 00       	mov    $0x15180,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 c0 10 00 00       	mov    0x10c0,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 c0 10 00 00       	mov    0x10c0,%eax
  6b:	a3 c4 10 00 00       	mov    %eax,0x10c4
  }

  if (next_thread == 0) {
  70:	a1 c4 10 00 00       	mov    0x10c4,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 33                	jne    ac <thread_schedule+0xac>
    // printf(2, "thread_schedule: no runnable threads\n");
    // exit();
    if(current_thread->state==RUNNING){         // child가 하나만 남았을 때
  79:	a1 c0 10 00 00       	mov    0x10c0,%eax
  7e:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  84:	83 f8 01             	cmp    $0x1,%eax
  87:	75 0c                	jne    95 <thread_schedule+0x95>
        next_thread = current_thread;
  89:	a1 c0 10 00 00       	mov    0x10c0,%eax
  8e:	a3 c4 10 00 00       	mov    %eax,0x10c4
  93:	eb 17                	jmp    ac <thread_schedule+0xac>
      } else {  
      printf(2, "thread_schedule: no runnable threads\n");
  95:	83 ec 08             	sub    $0x8,%esp
  98:	68 d8 0c 00 00       	push   $0xcd8
  9d:	6a 02                	push   $0x2
  9f:	e8 7d 08 00 00       	call   921 <printf>
  a4:	83 c4 10             	add    $0x10,%esp
      exit();
  a7:	e8 d1 06 00 00       	call   77d <exit>
      }
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  ac:	8b 15 c0 10 00 00    	mov    0x10c0,%edx
  b2:	a1 c4 10 00 00       	mov    0x10c4,%eax
  b7:	39 c2                	cmp    %eax,%edx
  b9:	74 41                	je     fc <thread_schedule+0xfc>
    next_thread->state = RUNNING;
  bb:	a1 c4 10 00 00       	mov    0x10c4,%eax
  c0:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  c7:	00 00 00 
    if (current_thread != &all_thread[0]) {
  ca:	a1 c0 10 00 00       	mov    0x10c0,%eax
  cf:	3d e0 10 00 00       	cmp    $0x10e0,%eax
  d4:	74 1f                	je     f5 <thread_schedule+0xf5>
      if (current_thread->state == RUNNING) {
  d6:	a1 c0 10 00 00       	mov    0x10c0,%eax
  db:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  e1:	83 f8 01             	cmp    $0x1,%eax
  e4:	75 0f                	jne    f5 <thread_schedule+0xf5>
        current_thread->state = RUNNABLE;
  e6:	a1 c0 10 00 00       	mov    0x10c0,%eax
  eb:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  f2:	00 00 00 
      }
    }
    thread_switch();
  f5:	e8 07 04 00 00       	call   501 <thread_switch>
  } else
    next_thread = 0;
}
  fa:	eb 0a                	jmp    106 <thread_schedule+0x106>
    next_thread = 0;
  fc:	c7 05 c4 10 00 00 00 	movl   $0x0,0x10c4
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
 118:	e8 00 07 00 00       	call   81d <uthread_init>
 11d:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
 120:	c7 05 c0 10 00 00 e0 	movl   $0x10e0,0x10c0
 127:	10 00 00 
  current_thread->state = RUNNING;
 12a:	a1 c0 10 00 00       	mov    0x10c0,%eax
 12f:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 136:	00 00 00 
  current_thread->tid=0;
 139:	a1 c0 10 00 00       	mov    0x10c0,%eax
 13e:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 145:	00 00 00 
  current_thread->ptid=0;
 148:	a1 c0 10 00 00       	mov    0x10c0,%eax
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
 15d:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 160:	c7 45 f4 e0 10 00 00 	movl   $0x10e0,-0xc(%ebp)
 167:	eb 14                	jmp    17d <thread_create+0x23>
    if (t->state == FREE) break;
 169:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 172:	85 c0                	test   %eax,%eax
 174:	74 13                	je     189 <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 176:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
 17d:	b8 80 51 01 00       	mov    $0x15180,%eax
 182:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 185:	72 e2                	jb     169 <thread_create+0xf>
 187:	eb 01                	jmp    18a <thread_create+0x30>
    if (t->state == FREE) break;
 189:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 18a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18d:	83 c0 04             	add    $0x4,%eax
 190:	05 00 20 00 00       	add    $0x2000,%eax
 195:	89 c2                	mov    %eax,%edx
 197:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19a:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 19c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19f:	8b 00                	mov    (%eax),%eax
 1a1:	8d 50 fc             	lea    -0x4(%eax),%edx
 1a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a7:	89 10                	mov    %edx,(%eax)
  
  
  t->tid = t - all_thread;
 1a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ac:	2d e0 10 00 00       	sub    $0x10e0,%eax
 1b1:	c1 f8 04             	sar    $0x4,%eax
 1b4:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 1ba:	89 c2                	mov    %eax,%edx
 1bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bf:	89 90 08 20 00 00    	mov    %edx,0x2008(%eax)
  t->ptid = current_thread->tid;
 1c5:	a1 c0 10 00 00       	mov    0x10c0,%eax
 1ca:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
 1d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d3:	89 90 0c 20 00 00    	mov    %edx,0x200c(%eax)
  
  * (int *) (t->sp) = (int)func;           // push return address on stack
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	8b 00                	mov    (%eax),%eax
 1de:	89 c2                	mov    %eax,%edx
 1e0:	8b 45 08             	mov    0x8(%ebp),%eax
 1e3:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 1e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e8:	8b 00                	mov    (%eax),%eax
 1ea:	8d 50 e0             	lea    -0x20(%eax),%edx
 1ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f0:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 1f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f5:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1fc:	00 00 00 
  check_thread(+1);
 1ff:	83 ec 0c             	sub    $0xc,%esp
 202:	6a 01                	push   $0x1
 204:	e8 1c 06 00 00       	call   825 <check_thread>
 209:	83 c4 10             	add    $0x10,%esp
}
 20c:	90                   	nop
 20d:	c9                   	leave  
 20e:	c3                   	ret    

0000020f <thread_join_all>:

static void 
thread_join_all(void)
{
 20f:	55                   	push   %ebp
 210:	89 e5                	mov    %esp,%ebp
 212:	83 ec 18             	sub    $0x18,%esp
 while (1) {
    int found = 0;
 215:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (int i = 0; i < MAX_THREAD; i++) {
 21c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 223:	eb 43                	jmp    268 <thread_join_all+0x59>
      thread_p t = &all_thread[i];
 225:	8b 45 f0             	mov    -0x10(%ebp),%eax
 228:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 22e:	05 e0 10 00 00       	add    $0x10e0,%eax
 233:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if (t->state != FREE && t->ptid == current_thread->tid) {
 236:	8b 45 ec             	mov    -0x14(%ebp),%eax
 239:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 23f:	85 c0                	test   %eax,%eax
 241:	74 21                	je     264 <thread_join_all+0x55>
 243:	8b 45 ec             	mov    -0x14(%ebp),%eax
 246:	8b 90 0c 20 00 00    	mov    0x200c(%eax),%edx
 24c:	a1 c0 10 00 00       	mov    0x10c0,%eax
 251:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 257:	39 c2                	cmp    %eax,%edx
 259:	75 09                	jne    264 <thread_join_all+0x55>
        found = 1;
 25b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        break;
 262:	eb 0a                	jmp    26e <thread_join_all+0x5f>
    for (int i = 0; i < MAX_THREAD; i++) {
 264:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 268:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 26c:	7e b7                	jle    225 <thread_join_all+0x16>
      }
    }

    if (!found)
 26e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 272:	74 16                	je     28a <thread_join_all+0x7b>
      break;

    current_thread->state = WAIT;
 274:	a1 c0 10 00 00       	mov    0x10c0,%eax
 279:	c7 80 04 20 00 00 03 	movl   $0x3,0x2004(%eax)
 280:	00 00 00 
    thread_schedule();
 283:	e8 78 fd ff ff       	call   0 <thread_schedule>
 while (1) {
 288:	eb 8b                	jmp    215 <thread_join_all+0x6>
      break;
 28a:	90                   	nop
  }
}
 28b:	90                   	nop
 28c:	c9                   	leave  
 28d:	c3                   	ret    

0000028e <wake_pthread>:

static void
wake_pthread(void)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
 291:	83 ec 10             	sub    $0x10,%esp
  int ptid = current_thread->ptid;
 294:	a1 c0 10 00 00       	mov    0x10c0,%eax
 299:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 29f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int child_alive = 0;
 2a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

  // 자식 스레드가 남아 있는지 확인
  for (int i = 0; i < MAX_THREAD; i++) {
 2a9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
 2b0:	eb 55                	jmp    307 <wake_pthread+0x79>
    if (all_thread[i].ptid == ptid &&
 2b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2b5:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 2bb:	05 ec 30 00 00       	add    $0x30ec,%eax
 2c0:	8b 00                	mov    (%eax),%eax
 2c2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
 2c5:	75 3c                	jne    303 <wake_pthread+0x75>
        all_thread[i].tid != current_thread->tid && // 자기 자신 제외
 2c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2ca:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 2d0:	05 e8 30 00 00       	add    $0x30e8,%eax
 2d5:	8b 10                	mov    (%eax),%edx
 2d7:	a1 c0 10 00 00       	mov    0x10c0,%eax
 2dc:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
    if (all_thread[i].ptid == ptid &&
 2e2:	39 c2                	cmp    %eax,%edx
 2e4:	74 1d                	je     303 <wake_pthread+0x75>
        all_thread[i].state != FREE) {
 2e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2e9:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 2ef:	05 e4 30 00 00       	add    $0x30e4,%eax
 2f4:	8b 00                	mov    (%eax),%eax
        all_thread[i].tid != current_thread->tid && // 자기 자신 제외
 2f6:	85 c0                	test   %eax,%eax
 2f8:	74 09                	je     303 <wake_pthread+0x75>
      child_alive = 1;
 2fa:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
      break;
 301:	eb 0a                	jmp    30d <wake_pthread+0x7f>
  for (int i = 0; i < MAX_THREAD; i++) {
 303:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 307:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
 30b:	7e a5                	jle    2b2 <wake_pthread+0x24>
    }
  }

  // 자식이 모두 종료되었으면, 부모 스레드 깨우기
  if (!child_alive) {
 30d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
 311:	75 54                	jne    367 <wake_pthread+0xd9>
    for (int i = 0; i < MAX_THREAD; i++) {
 313:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 31a:	eb 45                	jmp    361 <wake_pthread+0xd3>
      if (all_thread[i].tid == ptid &&
 31c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31f:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 325:	05 e8 30 00 00       	add    $0x30e8,%eax
 32a:	8b 00                	mov    (%eax),%eax
 32c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
 32f:	75 2c                	jne    35d <wake_pthread+0xcf>
          all_thread[i].state == WAIT) {
 331:	8b 45 f4             	mov    -0xc(%ebp),%eax
 334:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 33a:	05 e4 30 00 00       	add    $0x30e4,%eax
 33f:	8b 00                	mov    (%eax),%eax
      if (all_thread[i].tid == ptid &&
 341:	83 f8 03             	cmp    $0x3,%eax
 344:	75 17                	jne    35d <wake_pthread+0xcf>
        all_thread[i].state = RUNNABLE;
 346:	8b 45 f4             	mov    -0xc(%ebp),%eax
 349:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 34f:	05 e4 30 00 00       	add    $0x30e4,%eax
 354:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
        break;
 35a:	90                   	nop
      }
    }
  }
}
 35b:	eb 0a                	jmp    367 <wake_pthread+0xd9>
    for (int i = 0; i < MAX_THREAD; i++) {
 35d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 361:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 365:	7e b5                	jle    31c <wake_pthread+0x8e>
}
 367:	90                   	nop
 368:	c9                   	leave  
 369:	c3                   	ret    

0000036a <child_thread>:


static void 
child_thread(void)
{
 36a:	55                   	push   %ebp
 36b:	89 e5                	mov    %esp,%ebp
 36d:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "child thread running\n");
 370:	83 ec 08             	sub    $0x8,%esp
 373:	68 fe 0c 00 00       	push   $0xcfe
 378:	6a 01                	push   $0x1
 37a:	e8 a2 05 00 00       	call   921 <printf>
 37f:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 389:	eb 1c                	jmp    3a7 <child_thread+0x3d>
    printf(1, "child thread 0x%x\n", (int) current_thread);
 38b:	a1 c0 10 00 00       	mov    0x10c0,%eax
 390:	83 ec 04             	sub    $0x4,%esp
 393:	50                   	push   %eax
 394:	68 14 0d 00 00       	push   $0xd14
 399:	6a 01                	push   $0x1
 39b:	e8 81 05 00 00       	call   921 <printf>
 3a0:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 3a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3a7:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 3ab:	7e de                	jle    38b <child_thread+0x21>
  }
  printf(1, "child thread: exit\n");
 3ad:	83 ec 08             	sub    $0x8,%esp
 3b0:	68 27 0d 00 00       	push   $0xd27
 3b5:	6a 01                	push   $0x1
 3b7:	e8 65 05 00 00       	call   921 <printf>
 3bc:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < MAX_THREAD; i++) {
 3bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 3c6:	eb 4a                	jmp    412 <child_thread+0xa8>
    thread_p p = &all_thread[i];
 3c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 3cb:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 3d1:	05 e0 10 00 00       	add    $0x10e0,%eax
 3d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (p->tid == current_thread->ptid && p->state == WAIT) {
 3d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3dc:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
 3e2:	a1 c0 10 00 00       	mov    0x10c0,%eax
 3e7:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 3ed:	39 c2                	cmp    %eax,%edx
 3ef:	75 1d                	jne    40e <child_thread+0xa4>
 3f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f4:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 3fa:	83 f8 03             	cmp    $0x3,%eax
 3fd:	75 0f                	jne    40e <child_thread+0xa4>
      p->state = RUNNABLE;
 3ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
 402:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 409:	00 00 00 
      break;
 40c:	eb 0a                	jmp    418 <child_thread+0xae>
  for (int i = 0; i < MAX_THREAD; i++) {
 40e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 412:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 416:	7e b0                	jle    3c8 <child_thread+0x5e>
    }
  }

  current_thread->state = FREE;
 418:	a1 c0 10 00 00       	mov    0x10c0,%eax
 41d:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 424:	00 00 00 

  check_thread(-1);
 427:	83 ec 0c             	sub    $0xc,%esp
 42a:	6a ff                	push   $0xffffffff
 42c:	e8 f4 03 00 00       	call   825 <check_thread>
 431:	83 c4 10             	add    $0x10,%esp
  wake_pthread();
 434:	e8 55 fe ff ff       	call   28e <wake_pthread>
  thread_schedule();
 439:	e8 c2 fb ff ff       	call   0 <thread_schedule>
}
 43e:	90                   	nop
 43f:	c9                   	leave  
 440:	c3                   	ret    

00000441 <mythread>:

void 
mythread(void)
{
 441:	55                   	push   %ebp
 442:	89 e5                	mov    %esp,%ebp
 444:	83 ec 18             	sub    $0x18,%esp
  printf(1,"thread start\n");
 447:	83 ec 08             	sub    $0x8,%esp
 44a:	68 3b 0d 00 00       	push   $0xd3b
 44f:	6a 01                	push   $0x1
 451:	e8 cb 04 00 00       	call   921 <printf>
 456:	83 c4 10             	add    $0x10,%esp
  int i;
  printf(1, "my thread running\n");
 459:	83 ec 08             	sub    $0x8,%esp
 45c:	68 49 0d 00 00       	push   $0xd49
 461:	6a 01                	push   $0x1
 463:	e8 b9 04 00 00       	call   921 <printf>
 468:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 46b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 472:	eb 14                	jmp    488 <mythread+0x47>
    thread_create(child_thread);
 474:	83 ec 0c             	sub    $0xc,%esp
 477:	68 6a 03 00 00       	push   $0x36a
 47c:	e8 d9 fc ff ff       	call   15a <thread_create>
 481:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 484:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 488:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 48c:	7e e6                	jle    474 <mythread+0x33>
  }
  thread_join_all();
 48e:	e8 7c fd ff ff       	call   20f <thread_join_all>
  printf(1, "my thread: exit\n");
 493:	83 ec 08             	sub    $0x8,%esp
 496:	68 5c 0d 00 00       	push   $0xd5c
 49b:	6a 01                	push   $0x1
 49d:	e8 7f 04 00 00       	call   921 <printf>
 4a2:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 4a5:	a1 c0 10 00 00       	mov    0x10c0,%eax
 4aa:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 4b1:	00 00 00 

  check_thread(-1);
 4b4:	83 ec 0c             	sub    $0xc,%esp
 4b7:	6a ff                	push   $0xffffffff
 4b9:	e8 67 03 00 00       	call   825 <check_thread>
 4be:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 4c1:	e8 3a fb ff ff       	call   0 <thread_schedule>
}
 4c6:	90                   	nop
 4c7:	c9                   	leave  
 4c8:	c3                   	ret    

000004c9 <main>:

int 
main(int argc, char *argv[]) 
{
 4c9:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 4cd:	83 e4 f0             	and    $0xfffffff0,%esp
 4d0:	ff 71 fc             	push   -0x4(%ecx)
 4d3:	55                   	push   %ebp
 4d4:	89 e5                	mov    %esp,%ebp
 4d6:	51                   	push   %ecx
 4d7:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 4da:	e8 2a fc ff ff       	call   109 <thread_init>
  thread_create(mythread);
 4df:	83 ec 0c             	sub    $0xc,%esp
 4e2:	68 41 04 00 00       	push   $0x441
 4e7:	e8 6e fc ff ff       	call   15a <thread_create>
 4ec:	83 c4 10             	add    $0x10,%esp
  thread_join_all();
 4ef:	e8 1b fd ff ff       	call   20f <thread_join_all>
  return 0;
 4f4:	b8 00 00 00 00       	mov    $0x0,%eax
 4f9:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 4fc:	c9                   	leave  
 4fd:	8d 61 fc             	lea    -0x4(%ecx),%esp
 500:	c3                   	ret    

00000501 <thread_switch>:
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	pushal
 501:	60                   	pusha  

   movl current_thread, %eax
 502:	a1 c0 10 00 00       	mov    0x10c0,%eax
   movl %esp, (%eax)
 507:	89 20                	mov    %esp,(%eax)

   movl next_thread, %eax      # eax = next_thread  현재 실행 중인 스레드 구조체의 주소를 eax에 저장
 509:	a1 c4 10 00 00       	mov    0x10c4,%eax
    movl (%eax), %esp           # esp = next_thread->sp 현재 실행 중인 스레드의 현
 50e:	8b 20                	mov    (%eax),%esp

    movl next_thread, %eax
 510:	a1 c4 10 00 00       	mov    0x10c4,%eax
    movl %eax, current_thread   # current_thread = next_thread
 515:	a3 c0 10 00 00       	mov    %eax,0x10c0

    popal
 51a:	61                   	popa   

   movl $0, next_thread
 51b:	c7 05 c4 10 00 00 00 	movl   $0x0,0x10c4
 522:	00 00 00 

	ret    /* return to ra */
 525:	c3                   	ret    

00000526 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 526:	55                   	push   %ebp
 527:	89 e5                	mov    %esp,%ebp
 529:	57                   	push   %edi
 52a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 52b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 52e:	8b 55 10             	mov    0x10(%ebp),%edx
 531:	8b 45 0c             	mov    0xc(%ebp),%eax
 534:	89 cb                	mov    %ecx,%ebx
 536:	89 df                	mov    %ebx,%edi
 538:	89 d1                	mov    %edx,%ecx
 53a:	fc                   	cld    
 53b:	f3 aa                	rep stos %al,%es:(%edi)
 53d:	89 ca                	mov    %ecx,%edx
 53f:	89 fb                	mov    %edi,%ebx
 541:	89 5d 08             	mov    %ebx,0x8(%ebp)
 544:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 547:	90                   	nop
 548:	5b                   	pop    %ebx
 549:	5f                   	pop    %edi
 54a:	5d                   	pop    %ebp
 54b:	c3                   	ret    

0000054c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 54c:	55                   	push   %ebp
 54d:	89 e5                	mov    %esp,%ebp
 54f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 552:	8b 45 08             	mov    0x8(%ebp),%eax
 555:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 558:	90                   	nop
 559:	8b 55 0c             	mov    0xc(%ebp),%edx
 55c:	8d 42 01             	lea    0x1(%edx),%eax
 55f:	89 45 0c             	mov    %eax,0xc(%ebp)
 562:	8b 45 08             	mov    0x8(%ebp),%eax
 565:	8d 48 01             	lea    0x1(%eax),%ecx
 568:	89 4d 08             	mov    %ecx,0x8(%ebp)
 56b:	0f b6 12             	movzbl (%edx),%edx
 56e:	88 10                	mov    %dl,(%eax)
 570:	0f b6 00             	movzbl (%eax),%eax
 573:	84 c0                	test   %al,%al
 575:	75 e2                	jne    559 <strcpy+0xd>
    ;
  return os;
 577:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 57a:	c9                   	leave  
 57b:	c3                   	ret    

0000057c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 57c:	55                   	push   %ebp
 57d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 57f:	eb 08                	jmp    589 <strcmp+0xd>
    p++, q++;
 581:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 585:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 589:	8b 45 08             	mov    0x8(%ebp),%eax
 58c:	0f b6 00             	movzbl (%eax),%eax
 58f:	84 c0                	test   %al,%al
 591:	74 10                	je     5a3 <strcmp+0x27>
 593:	8b 45 08             	mov    0x8(%ebp),%eax
 596:	0f b6 10             	movzbl (%eax),%edx
 599:	8b 45 0c             	mov    0xc(%ebp),%eax
 59c:	0f b6 00             	movzbl (%eax),%eax
 59f:	38 c2                	cmp    %al,%dl
 5a1:	74 de                	je     581 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 5a3:	8b 45 08             	mov    0x8(%ebp),%eax
 5a6:	0f b6 00             	movzbl (%eax),%eax
 5a9:	0f b6 d0             	movzbl %al,%edx
 5ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 5af:	0f b6 00             	movzbl (%eax),%eax
 5b2:	0f b6 c8             	movzbl %al,%ecx
 5b5:	89 d0                	mov    %edx,%eax
 5b7:	29 c8                	sub    %ecx,%eax
}
 5b9:	5d                   	pop    %ebp
 5ba:	c3                   	ret    

000005bb <strlen>:

uint
strlen(char *s)
{
 5bb:	55                   	push   %ebp
 5bc:	89 e5                	mov    %esp,%ebp
 5be:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 5c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 5c8:	eb 04                	jmp    5ce <strlen+0x13>
 5ca:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 5ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5d1:	8b 45 08             	mov    0x8(%ebp),%eax
 5d4:	01 d0                	add    %edx,%eax
 5d6:	0f b6 00             	movzbl (%eax),%eax
 5d9:	84 c0                	test   %al,%al
 5db:	75 ed                	jne    5ca <strlen+0xf>
    ;
  return n;
 5dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5e0:	c9                   	leave  
 5e1:	c3                   	ret    

000005e2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 5e2:	55                   	push   %ebp
 5e3:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 5e5:	8b 45 10             	mov    0x10(%ebp),%eax
 5e8:	50                   	push   %eax
 5e9:	ff 75 0c             	push   0xc(%ebp)
 5ec:	ff 75 08             	push   0x8(%ebp)
 5ef:	e8 32 ff ff ff       	call   526 <stosb>
 5f4:	83 c4 0c             	add    $0xc,%esp
  return dst;
 5f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5fa:	c9                   	leave  
 5fb:	c3                   	ret    

000005fc <strchr>:

char*
strchr(const char *s, char c)
{
 5fc:	55                   	push   %ebp
 5fd:	89 e5                	mov    %esp,%ebp
 5ff:	83 ec 04             	sub    $0x4,%esp
 602:	8b 45 0c             	mov    0xc(%ebp),%eax
 605:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 608:	eb 14                	jmp    61e <strchr+0x22>
    if(*s == c)
 60a:	8b 45 08             	mov    0x8(%ebp),%eax
 60d:	0f b6 00             	movzbl (%eax),%eax
 610:	38 45 fc             	cmp    %al,-0x4(%ebp)
 613:	75 05                	jne    61a <strchr+0x1e>
      return (char*)s;
 615:	8b 45 08             	mov    0x8(%ebp),%eax
 618:	eb 13                	jmp    62d <strchr+0x31>
  for(; *s; s++)
 61a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 61e:	8b 45 08             	mov    0x8(%ebp),%eax
 621:	0f b6 00             	movzbl (%eax),%eax
 624:	84 c0                	test   %al,%al
 626:	75 e2                	jne    60a <strchr+0xe>
  return 0;
 628:	b8 00 00 00 00       	mov    $0x0,%eax
}
 62d:	c9                   	leave  
 62e:	c3                   	ret    

0000062f <gets>:

char*
gets(char *buf, int max)
{
 62f:	55                   	push   %ebp
 630:	89 e5                	mov    %esp,%ebp
 632:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 63c:	eb 42                	jmp    680 <gets+0x51>
    cc = read(0, &c, 1);
 63e:	83 ec 04             	sub    $0x4,%esp
 641:	6a 01                	push   $0x1
 643:	8d 45 ef             	lea    -0x11(%ebp),%eax
 646:	50                   	push   %eax
 647:	6a 00                	push   $0x0
 649:	e8 47 01 00 00       	call   795 <read>
 64e:	83 c4 10             	add    $0x10,%esp
 651:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 654:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 658:	7e 33                	jle    68d <gets+0x5e>
      break;
    buf[i++] = c;
 65a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65d:	8d 50 01             	lea    0x1(%eax),%edx
 660:	89 55 f4             	mov    %edx,-0xc(%ebp)
 663:	89 c2                	mov    %eax,%edx
 665:	8b 45 08             	mov    0x8(%ebp),%eax
 668:	01 c2                	add    %eax,%edx
 66a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 66e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 670:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 674:	3c 0a                	cmp    $0xa,%al
 676:	74 16                	je     68e <gets+0x5f>
 678:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 67c:	3c 0d                	cmp    $0xd,%al
 67e:	74 0e                	je     68e <gets+0x5f>
  for(i=0; i+1 < max; ){
 680:	8b 45 f4             	mov    -0xc(%ebp),%eax
 683:	83 c0 01             	add    $0x1,%eax
 686:	39 45 0c             	cmp    %eax,0xc(%ebp)
 689:	7f b3                	jg     63e <gets+0xf>
 68b:	eb 01                	jmp    68e <gets+0x5f>
      break;
 68d:	90                   	nop
      break;
  }
  buf[i] = '\0';
 68e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 691:	8b 45 08             	mov    0x8(%ebp),%eax
 694:	01 d0                	add    %edx,%eax
 696:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 699:	8b 45 08             	mov    0x8(%ebp),%eax
}
 69c:	c9                   	leave  
 69d:	c3                   	ret    

0000069e <stat>:

int
stat(char *n, struct stat *st)
{
 69e:	55                   	push   %ebp
 69f:	89 e5                	mov    %esp,%ebp
 6a1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6a4:	83 ec 08             	sub    $0x8,%esp
 6a7:	6a 00                	push   $0x0
 6a9:	ff 75 08             	push   0x8(%ebp)
 6ac:	e8 0c 01 00 00       	call   7bd <open>
 6b1:	83 c4 10             	add    $0x10,%esp
 6b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 6b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6bb:	79 07                	jns    6c4 <stat+0x26>
    return -1;
 6bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 6c2:	eb 25                	jmp    6e9 <stat+0x4b>
  r = fstat(fd, st);
 6c4:	83 ec 08             	sub    $0x8,%esp
 6c7:	ff 75 0c             	push   0xc(%ebp)
 6ca:	ff 75 f4             	push   -0xc(%ebp)
 6cd:	e8 03 01 00 00       	call   7d5 <fstat>
 6d2:	83 c4 10             	add    $0x10,%esp
 6d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 6d8:	83 ec 0c             	sub    $0xc,%esp
 6db:	ff 75 f4             	push   -0xc(%ebp)
 6de:	e8 c2 00 00 00       	call   7a5 <close>
 6e3:	83 c4 10             	add    $0x10,%esp
  return r;
 6e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 6e9:	c9                   	leave  
 6ea:	c3                   	ret    

000006eb <atoi>:

int
atoi(const char *s)
{
 6eb:	55                   	push   %ebp
 6ec:	89 e5                	mov    %esp,%ebp
 6ee:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 6f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6f8:	eb 25                	jmp    71f <atoi+0x34>
    n = n*10 + *s++ - '0';
 6fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6fd:	89 d0                	mov    %edx,%eax
 6ff:	c1 e0 02             	shl    $0x2,%eax
 702:	01 d0                	add    %edx,%eax
 704:	01 c0                	add    %eax,%eax
 706:	89 c1                	mov    %eax,%ecx
 708:	8b 45 08             	mov    0x8(%ebp),%eax
 70b:	8d 50 01             	lea    0x1(%eax),%edx
 70e:	89 55 08             	mov    %edx,0x8(%ebp)
 711:	0f b6 00             	movzbl (%eax),%eax
 714:	0f be c0             	movsbl %al,%eax
 717:	01 c8                	add    %ecx,%eax
 719:	83 e8 30             	sub    $0x30,%eax
 71c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 71f:	8b 45 08             	mov    0x8(%ebp),%eax
 722:	0f b6 00             	movzbl (%eax),%eax
 725:	3c 2f                	cmp    $0x2f,%al
 727:	7e 0a                	jle    733 <atoi+0x48>
 729:	8b 45 08             	mov    0x8(%ebp),%eax
 72c:	0f b6 00             	movzbl (%eax),%eax
 72f:	3c 39                	cmp    $0x39,%al
 731:	7e c7                	jle    6fa <atoi+0xf>
  return n;
 733:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 736:	c9                   	leave  
 737:	c3                   	ret    

00000738 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 738:	55                   	push   %ebp
 739:	89 e5                	mov    %esp,%ebp
 73b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 73e:	8b 45 08             	mov    0x8(%ebp),%eax
 741:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 744:	8b 45 0c             	mov    0xc(%ebp),%eax
 747:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 74a:	eb 17                	jmp    763 <memmove+0x2b>
    *dst++ = *src++;
 74c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 74f:	8d 42 01             	lea    0x1(%edx),%eax
 752:	89 45 f8             	mov    %eax,-0x8(%ebp)
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	8d 48 01             	lea    0x1(%eax),%ecx
 75b:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 75e:	0f b6 12             	movzbl (%edx),%edx
 761:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 763:	8b 45 10             	mov    0x10(%ebp),%eax
 766:	8d 50 ff             	lea    -0x1(%eax),%edx
 769:	89 55 10             	mov    %edx,0x10(%ebp)
 76c:	85 c0                	test   %eax,%eax
 76e:	7f dc                	jg     74c <memmove+0x14>
  return vdst;
 770:	8b 45 08             	mov    0x8(%ebp),%eax
}
 773:	c9                   	leave  
 774:	c3                   	ret    

00000775 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 775:	b8 01 00 00 00       	mov    $0x1,%eax
 77a:	cd 40                	int    $0x40
 77c:	c3                   	ret    

0000077d <exit>:
SYSCALL(exit)
 77d:	b8 02 00 00 00       	mov    $0x2,%eax
 782:	cd 40                	int    $0x40
 784:	c3                   	ret    

00000785 <wait>:
SYSCALL(wait)
 785:	b8 03 00 00 00       	mov    $0x3,%eax
 78a:	cd 40                	int    $0x40
 78c:	c3                   	ret    

0000078d <pipe>:
SYSCALL(pipe)
 78d:	b8 04 00 00 00       	mov    $0x4,%eax
 792:	cd 40                	int    $0x40
 794:	c3                   	ret    

00000795 <read>:
SYSCALL(read)
 795:	b8 05 00 00 00       	mov    $0x5,%eax
 79a:	cd 40                	int    $0x40
 79c:	c3                   	ret    

0000079d <write>:
SYSCALL(write)
 79d:	b8 10 00 00 00       	mov    $0x10,%eax
 7a2:	cd 40                	int    $0x40
 7a4:	c3                   	ret    

000007a5 <close>:
SYSCALL(close)
 7a5:	b8 15 00 00 00       	mov    $0x15,%eax
 7aa:	cd 40                	int    $0x40
 7ac:	c3                   	ret    

000007ad <kill>:
SYSCALL(kill)
 7ad:	b8 06 00 00 00       	mov    $0x6,%eax
 7b2:	cd 40                	int    $0x40
 7b4:	c3                   	ret    

000007b5 <exec>:
SYSCALL(exec)
 7b5:	b8 07 00 00 00       	mov    $0x7,%eax
 7ba:	cd 40                	int    $0x40
 7bc:	c3                   	ret    

000007bd <open>:
SYSCALL(open)
 7bd:	b8 0f 00 00 00       	mov    $0xf,%eax
 7c2:	cd 40                	int    $0x40
 7c4:	c3                   	ret    

000007c5 <mknod>:
SYSCALL(mknod)
 7c5:	b8 11 00 00 00       	mov    $0x11,%eax
 7ca:	cd 40                	int    $0x40
 7cc:	c3                   	ret    

000007cd <unlink>:
SYSCALL(unlink)
 7cd:	b8 12 00 00 00       	mov    $0x12,%eax
 7d2:	cd 40                	int    $0x40
 7d4:	c3                   	ret    

000007d5 <fstat>:
SYSCALL(fstat)
 7d5:	b8 08 00 00 00       	mov    $0x8,%eax
 7da:	cd 40                	int    $0x40
 7dc:	c3                   	ret    

000007dd <link>:
SYSCALL(link)
 7dd:	b8 13 00 00 00       	mov    $0x13,%eax
 7e2:	cd 40                	int    $0x40
 7e4:	c3                   	ret    

000007e5 <mkdir>:
SYSCALL(mkdir)
 7e5:	b8 14 00 00 00       	mov    $0x14,%eax
 7ea:	cd 40                	int    $0x40
 7ec:	c3                   	ret    

000007ed <chdir>:
SYSCALL(chdir)
 7ed:	b8 09 00 00 00       	mov    $0x9,%eax
 7f2:	cd 40                	int    $0x40
 7f4:	c3                   	ret    

000007f5 <dup>:
SYSCALL(dup)
 7f5:	b8 0a 00 00 00       	mov    $0xa,%eax
 7fa:	cd 40                	int    $0x40
 7fc:	c3                   	ret    

000007fd <getpid>:
SYSCALL(getpid)
 7fd:	b8 0b 00 00 00       	mov    $0xb,%eax
 802:	cd 40                	int    $0x40
 804:	c3                   	ret    

00000805 <sbrk>:
SYSCALL(sbrk)
 805:	b8 0c 00 00 00       	mov    $0xc,%eax
 80a:	cd 40                	int    $0x40
 80c:	c3                   	ret    

0000080d <sleep>:
SYSCALL(sleep)
 80d:	b8 0d 00 00 00       	mov    $0xd,%eax
 812:	cd 40                	int    $0x40
 814:	c3                   	ret    

00000815 <uptime>:
SYSCALL(uptime)
 815:	b8 0e 00 00 00       	mov    $0xe,%eax
 81a:	cd 40                	int    $0x40
 81c:	c3                   	ret    

0000081d <uthread_init>:

SYSCALL(uthread_init)
 81d:	b8 16 00 00 00       	mov    $0x16,%eax
 822:	cd 40                	int    $0x40
 824:	c3                   	ret    

00000825 <check_thread>:
SYSCALL(check_thread)
 825:	b8 17 00 00 00       	mov    $0x17,%eax
 82a:	cd 40                	int    $0x40
 82c:	c3                   	ret    

0000082d <getpinfo>:

SYSCALL(getpinfo)
 82d:	b8 18 00 00 00       	mov    $0x18,%eax
 832:	cd 40                	int    $0x40
 834:	c3                   	ret    

00000835 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 835:	b8 19 00 00 00       	mov    $0x19,%eax
 83a:	cd 40                	int    $0x40
 83c:	c3                   	ret    

0000083d <yield>:
SYSCALL(yield)
 83d:	b8 1a 00 00 00       	mov    $0x1a,%eax
 842:	cd 40                	int    $0x40
 844:	c3                   	ret    

00000845 <printpt>:

 845:	b8 1b 00 00 00       	mov    $0x1b,%eax
 84a:	cd 40                	int    $0x40
 84c:	c3                   	ret    

0000084d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 84d:	55                   	push   %ebp
 84e:	89 e5                	mov    %esp,%ebp
 850:	83 ec 18             	sub    $0x18,%esp
 853:	8b 45 0c             	mov    0xc(%ebp),%eax
 856:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 859:	83 ec 04             	sub    $0x4,%esp
 85c:	6a 01                	push   $0x1
 85e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 861:	50                   	push   %eax
 862:	ff 75 08             	push   0x8(%ebp)
 865:	e8 33 ff ff ff       	call   79d <write>
 86a:	83 c4 10             	add    $0x10,%esp
}
 86d:	90                   	nop
 86e:	c9                   	leave  
 86f:	c3                   	ret    

00000870 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 870:	55                   	push   %ebp
 871:	89 e5                	mov    %esp,%ebp
 873:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 876:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 87d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 881:	74 17                	je     89a <printint+0x2a>
 883:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 887:	79 11                	jns    89a <printint+0x2a>
    neg = 1;
 889:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 890:	8b 45 0c             	mov    0xc(%ebp),%eax
 893:	f7 d8                	neg    %eax
 895:	89 45 ec             	mov    %eax,-0x14(%ebp)
 898:	eb 06                	jmp    8a0 <printint+0x30>
  } else {
    x = xx;
 89a:	8b 45 0c             	mov    0xc(%ebp),%eax
 89d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 8a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 8a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8ad:	ba 00 00 00 00       	mov    $0x0,%edx
 8b2:	f7 f1                	div    %ecx
 8b4:	89 d1                	mov    %edx,%ecx
 8b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b9:	8d 50 01             	lea    0x1(%eax),%edx
 8bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8bf:	0f b6 91 a0 10 00 00 	movzbl 0x10a0(%ecx),%edx
 8c6:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 8ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8d0:	ba 00 00 00 00       	mov    $0x0,%edx
 8d5:	f7 f1                	div    %ecx
 8d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8da:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8de:	75 c7                	jne    8a7 <printint+0x37>
  if(neg)
 8e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e4:	74 2d                	je     913 <printint+0xa3>
    buf[i++] = '-';
 8e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e9:	8d 50 01             	lea    0x1(%eax),%edx
 8ec:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8ef:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8f4:	eb 1d                	jmp    913 <printint+0xa3>
    putc(fd, buf[i]);
 8f6:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fc:	01 d0                	add    %edx,%eax
 8fe:	0f b6 00             	movzbl (%eax),%eax
 901:	0f be c0             	movsbl %al,%eax
 904:	83 ec 08             	sub    $0x8,%esp
 907:	50                   	push   %eax
 908:	ff 75 08             	push   0x8(%ebp)
 90b:	e8 3d ff ff ff       	call   84d <putc>
 910:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 913:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 917:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 91b:	79 d9                	jns    8f6 <printint+0x86>
}
 91d:	90                   	nop
 91e:	90                   	nop
 91f:	c9                   	leave  
 920:	c3                   	ret    

00000921 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 921:	55                   	push   %ebp
 922:	89 e5                	mov    %esp,%ebp
 924:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 927:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 92e:	8d 45 0c             	lea    0xc(%ebp),%eax
 931:	83 c0 04             	add    $0x4,%eax
 934:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 937:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 93e:	e9 59 01 00 00       	jmp    a9c <printf+0x17b>
    c = fmt[i] & 0xff;
 943:	8b 55 0c             	mov    0xc(%ebp),%edx
 946:	8b 45 f0             	mov    -0x10(%ebp),%eax
 949:	01 d0                	add    %edx,%eax
 94b:	0f b6 00             	movzbl (%eax),%eax
 94e:	0f be c0             	movsbl %al,%eax
 951:	25 ff 00 00 00       	and    $0xff,%eax
 956:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 959:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 95d:	75 2c                	jne    98b <printf+0x6a>
      if(c == '%'){
 95f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 963:	75 0c                	jne    971 <printf+0x50>
        state = '%';
 965:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 96c:	e9 27 01 00 00       	jmp    a98 <printf+0x177>
      } else {
        putc(fd, c);
 971:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 974:	0f be c0             	movsbl %al,%eax
 977:	83 ec 08             	sub    $0x8,%esp
 97a:	50                   	push   %eax
 97b:	ff 75 08             	push   0x8(%ebp)
 97e:	e8 ca fe ff ff       	call   84d <putc>
 983:	83 c4 10             	add    $0x10,%esp
 986:	e9 0d 01 00 00       	jmp    a98 <printf+0x177>
      }
    } else if(state == '%'){
 98b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 98f:	0f 85 03 01 00 00    	jne    a98 <printf+0x177>
      if(c == 'd'){
 995:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 999:	75 1e                	jne    9b9 <printf+0x98>
        printint(fd, *ap, 10, 1);
 99b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 99e:	8b 00                	mov    (%eax),%eax
 9a0:	6a 01                	push   $0x1
 9a2:	6a 0a                	push   $0xa
 9a4:	50                   	push   %eax
 9a5:	ff 75 08             	push   0x8(%ebp)
 9a8:	e8 c3 fe ff ff       	call   870 <printint>
 9ad:	83 c4 10             	add    $0x10,%esp
        ap++;
 9b0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9b4:	e9 d8 00 00 00       	jmp    a91 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 9b9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9bd:	74 06                	je     9c5 <printf+0xa4>
 9bf:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9c3:	75 1e                	jne    9e3 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 9c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c8:	8b 00                	mov    (%eax),%eax
 9ca:	6a 00                	push   $0x0
 9cc:	6a 10                	push   $0x10
 9ce:	50                   	push   %eax
 9cf:	ff 75 08             	push   0x8(%ebp)
 9d2:	e8 99 fe ff ff       	call   870 <printint>
 9d7:	83 c4 10             	add    $0x10,%esp
        ap++;
 9da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9de:	e9 ae 00 00 00       	jmp    a91 <printf+0x170>
      } else if(c == 's'){
 9e3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9e7:	75 43                	jne    a2c <printf+0x10b>
        s = (char*)*ap;
 9e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9ec:	8b 00                	mov    (%eax),%eax
 9ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9f9:	75 25                	jne    a20 <printf+0xff>
          s = "(null)";
 9fb:	c7 45 f4 6d 0d 00 00 	movl   $0xd6d,-0xc(%ebp)
        while(*s != 0){
 a02:	eb 1c                	jmp    a20 <printf+0xff>
          putc(fd, *s);
 a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a07:	0f b6 00             	movzbl (%eax),%eax
 a0a:	0f be c0             	movsbl %al,%eax
 a0d:	83 ec 08             	sub    $0x8,%esp
 a10:	50                   	push   %eax
 a11:	ff 75 08             	push   0x8(%ebp)
 a14:	e8 34 fe ff ff       	call   84d <putc>
 a19:	83 c4 10             	add    $0x10,%esp
          s++;
 a1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a23:	0f b6 00             	movzbl (%eax),%eax
 a26:	84 c0                	test   %al,%al
 a28:	75 da                	jne    a04 <printf+0xe3>
 a2a:	eb 65                	jmp    a91 <printf+0x170>
        }
      } else if(c == 'c'){
 a2c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a30:	75 1d                	jne    a4f <printf+0x12e>
        putc(fd, *ap);
 a32:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a35:	8b 00                	mov    (%eax),%eax
 a37:	0f be c0             	movsbl %al,%eax
 a3a:	83 ec 08             	sub    $0x8,%esp
 a3d:	50                   	push   %eax
 a3e:	ff 75 08             	push   0x8(%ebp)
 a41:	e8 07 fe ff ff       	call   84d <putc>
 a46:	83 c4 10             	add    $0x10,%esp
        ap++;
 a49:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a4d:	eb 42                	jmp    a91 <printf+0x170>
      } else if(c == '%'){
 a4f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a53:	75 17                	jne    a6c <printf+0x14b>
        putc(fd, c);
 a55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a58:	0f be c0             	movsbl %al,%eax
 a5b:	83 ec 08             	sub    $0x8,%esp
 a5e:	50                   	push   %eax
 a5f:	ff 75 08             	push   0x8(%ebp)
 a62:	e8 e6 fd ff ff       	call   84d <putc>
 a67:	83 c4 10             	add    $0x10,%esp
 a6a:	eb 25                	jmp    a91 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a6c:	83 ec 08             	sub    $0x8,%esp
 a6f:	6a 25                	push   $0x25
 a71:	ff 75 08             	push   0x8(%ebp)
 a74:	e8 d4 fd ff ff       	call   84d <putc>
 a79:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a7f:	0f be c0             	movsbl %al,%eax
 a82:	83 ec 08             	sub    $0x8,%esp
 a85:	50                   	push   %eax
 a86:	ff 75 08             	push   0x8(%ebp)
 a89:	e8 bf fd ff ff       	call   84d <putc>
 a8e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 a91:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a98:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
 a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa2:	01 d0                	add    %edx,%eax
 aa4:	0f b6 00             	movzbl (%eax),%eax
 aa7:	84 c0                	test   %al,%al
 aa9:	0f 85 94 fe ff ff    	jne    943 <printf+0x22>
    }
  }
}
 aaf:	90                   	nop
 ab0:	90                   	nop
 ab1:	c9                   	leave  
 ab2:	c3                   	ret    

00000ab3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ab3:	55                   	push   %ebp
 ab4:	89 e5                	mov    %esp,%ebp
 ab6:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ab9:	8b 45 08             	mov    0x8(%ebp),%eax
 abc:	83 e8 08             	sub    $0x8,%eax
 abf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ac2:	a1 88 51 01 00       	mov    0x15188,%eax
 ac7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 aca:	eb 24                	jmp    af0 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 acc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 acf:	8b 00                	mov    (%eax),%eax
 ad1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 ad4:	72 12                	jb     ae8 <free+0x35>
 ad6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 adc:	77 24                	ja     b02 <free+0x4f>
 ade:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae1:	8b 00                	mov    (%eax),%eax
 ae3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ae6:	72 1a                	jb     b02 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ae8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aeb:	8b 00                	mov    (%eax),%eax
 aed:	89 45 fc             	mov    %eax,-0x4(%ebp)
 af0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 af3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 af6:	76 d4                	jbe    acc <free+0x19>
 af8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 afb:	8b 00                	mov    (%eax),%eax
 afd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b00:	73 ca                	jae    acc <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b02:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b05:	8b 40 04             	mov    0x4(%eax),%eax
 b08:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b12:	01 c2                	add    %eax,%edx
 b14:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b17:	8b 00                	mov    (%eax),%eax
 b19:	39 c2                	cmp    %eax,%edx
 b1b:	75 24                	jne    b41 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b20:	8b 50 04             	mov    0x4(%eax),%edx
 b23:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b26:	8b 00                	mov    (%eax),%eax
 b28:	8b 40 04             	mov    0x4(%eax),%eax
 b2b:	01 c2                	add    %eax,%edx
 b2d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b30:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b33:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b36:	8b 00                	mov    (%eax),%eax
 b38:	8b 10                	mov    (%eax),%edx
 b3a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b3d:	89 10                	mov    %edx,(%eax)
 b3f:	eb 0a                	jmp    b4b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b41:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b44:	8b 10                	mov    (%eax),%edx
 b46:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b49:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4e:	8b 40 04             	mov    0x4(%eax),%eax
 b51:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b58:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5b:	01 d0                	add    %edx,%eax
 b5d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b60:	75 20                	jne    b82 <free+0xcf>
    p->s.size += bp->s.size;
 b62:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b65:	8b 50 04             	mov    0x4(%eax),%edx
 b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b6b:	8b 40 04             	mov    0x4(%eax),%eax
 b6e:	01 c2                	add    %eax,%edx
 b70:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b73:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b76:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b79:	8b 10                	mov    (%eax),%edx
 b7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7e:	89 10                	mov    %edx,(%eax)
 b80:	eb 08                	jmp    b8a <free+0xd7>
  } else
    p->s.ptr = bp;
 b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b85:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b88:	89 10                	mov    %edx,(%eax)
  freep = p;
 b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b8d:	a3 88 51 01 00       	mov    %eax,0x15188
}
 b92:	90                   	nop
 b93:	c9                   	leave  
 b94:	c3                   	ret    

00000b95 <morecore>:

static Header*
morecore(uint nu)
{
 b95:	55                   	push   %ebp
 b96:	89 e5                	mov    %esp,%ebp
 b98:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b9b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 ba2:	77 07                	ja     bab <morecore+0x16>
    nu = 4096;
 ba4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bab:	8b 45 08             	mov    0x8(%ebp),%eax
 bae:	c1 e0 03             	shl    $0x3,%eax
 bb1:	83 ec 0c             	sub    $0xc,%esp
 bb4:	50                   	push   %eax
 bb5:	e8 4b fc ff ff       	call   805 <sbrk>
 bba:	83 c4 10             	add    $0x10,%esp
 bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bc0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bc4:	75 07                	jne    bcd <morecore+0x38>
    return 0;
 bc6:	b8 00 00 00 00       	mov    $0x0,%eax
 bcb:	eb 26                	jmp    bf3 <morecore+0x5e>
  hp = (Header*)p;
 bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bd6:	8b 55 08             	mov    0x8(%ebp),%edx
 bd9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bdf:	83 c0 08             	add    $0x8,%eax
 be2:	83 ec 0c             	sub    $0xc,%esp
 be5:	50                   	push   %eax
 be6:	e8 c8 fe ff ff       	call   ab3 <free>
 beb:	83 c4 10             	add    $0x10,%esp
  return freep;
 bee:	a1 88 51 01 00       	mov    0x15188,%eax
}
 bf3:	c9                   	leave  
 bf4:	c3                   	ret    

00000bf5 <malloc>:

void*
malloc(uint nbytes)
{
 bf5:	55                   	push   %ebp
 bf6:	89 e5                	mov    %esp,%ebp
 bf8:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bfb:	8b 45 08             	mov    0x8(%ebp),%eax
 bfe:	83 c0 07             	add    $0x7,%eax
 c01:	c1 e8 03             	shr    $0x3,%eax
 c04:	83 c0 01             	add    $0x1,%eax
 c07:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c0a:	a1 88 51 01 00       	mov    0x15188,%eax
 c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c16:	75 23                	jne    c3b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c18:	c7 45 f0 80 51 01 00 	movl   $0x15180,-0x10(%ebp)
 c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c22:	a3 88 51 01 00       	mov    %eax,0x15188
 c27:	a1 88 51 01 00       	mov    0x15188,%eax
 c2c:	a3 80 51 01 00       	mov    %eax,0x15180
    base.s.size = 0;
 c31:	c7 05 84 51 01 00 00 	movl   $0x0,0x15184
 c38:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c3e:	8b 00                	mov    (%eax),%eax
 c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c46:	8b 40 04             	mov    0x4(%eax),%eax
 c49:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c4c:	77 4d                	ja     c9b <malloc+0xa6>
      if(p->s.size == nunits)
 c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c51:	8b 40 04             	mov    0x4(%eax),%eax
 c54:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c57:	75 0c                	jne    c65 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5c:	8b 10                	mov    (%eax),%edx
 c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c61:	89 10                	mov    %edx,(%eax)
 c63:	eb 26                	jmp    c8b <malloc+0x96>
      else {
        p->s.size -= nunits;
 c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c68:	8b 40 04             	mov    0x4(%eax),%eax
 c6b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c6e:	89 c2                	mov    %eax,%edx
 c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c73:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c79:	8b 40 04             	mov    0x4(%eax),%eax
 c7c:	c1 e0 03             	shl    $0x3,%eax
 c7f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c85:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c88:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c8e:	a3 88 51 01 00       	mov    %eax,0x15188
      return (void*)(p + 1);
 c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c96:	83 c0 08             	add    $0x8,%eax
 c99:	eb 3b                	jmp    cd6 <malloc+0xe1>
    }
    if(p == freep)
 c9b:	a1 88 51 01 00       	mov    0x15188,%eax
 ca0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ca3:	75 1e                	jne    cc3 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ca5:	83 ec 0c             	sub    $0xc,%esp
 ca8:	ff 75 ec             	push   -0x14(%ebp)
 cab:	e8 e5 fe ff ff       	call   b95 <morecore>
 cb0:	83 c4 10             	add    $0x10,%esp
 cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 cb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cba:	75 07                	jne    cc3 <malloc+0xce>
        return 0;
 cbc:	b8 00 00 00 00       	mov    $0x0,%eax
 cc1:	eb 13                	jmp    cd6 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ccc:	8b 00                	mov    (%eax),%eax
 cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cd1:	e9 6d ff ff ff       	jmp    c43 <malloc+0x4e>
  }
}
 cd6:	c9                   	leave  
 cd7:	c3                   	ret    
