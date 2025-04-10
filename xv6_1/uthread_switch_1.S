.globl thread_switch
.type thread_switch, @function
thread_switch:
    # Save caller-saved registers (if needed), but we skip this
    # Save callee-saved registers
    pushl %ebp
    pushl %ebx
    pushl %esi
    pushl %edi

    # Save current_thread's stack pointer
    movl current_thread, %eax
    movl %esp, (%eax)

    # Load next_thread's stack pointer
    movl next_thread, %eax
    movl (%eax), %esp

    # Update current_thread
    movl %eax, current_thread

    # Restore callee-saved registers
    popl %edi
    popl %esi
    popl %ebx
    popl %ebp

    ret
