	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	pushal

   movl current_thread, %eax
   movl %esp, (%eax)

   movl next_thread, %eax      # eax = next_thread  현재 실행 중인 스레드 구조체의 주소를 eax에 저장
    movl (%eax), %esp           # esp = next_thread->sp 현재 실행 중인 스레드의 현

    movl next_thread, %eax
    movl %eax, current_thread   # current_thread = next_thread

    popal

   movl $0, next_thread

	ret    /* return to ra */
