static void (*sched)();

void uthread_init(void (*s)()) {
  sched = s;
}

void yield() {
  if (sched)
    sched();
}