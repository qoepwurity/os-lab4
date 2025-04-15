.text
.extern current_thread
.extern next_thread

.globl thread_switch
thread_switch:
    pushal

    movl current_thread, %eax
    movl %esp, (%eax)

    movl next_thread, %eax
    movl (%eax), %esp

    movl %eax, current_thread

    popal

    movl $0, next_thread

    ret