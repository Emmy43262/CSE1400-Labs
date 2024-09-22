.data
num_buf: .space 50  #32 bytes for the digits of the numbers
minus: .asciz "-"
procent: .asciz "%"
template: .asciz "%c %x %r %l %u"
ana: .asciz "Ana"
are: .asciz "are"
mere: .asciz "mere"
si: .asciz "si"
multe: .asciz "multe"
pere: .asciz "pere"
verzi: .asciz "verzi"
template_num: .asciz "%ld\n"

.text
.global main

my_printf:
    pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    pushq   %rdi            # -8(%rbp) is the address of the string
    pushq   $0
    
    pushq   %r12            # save calle? saved registers
    pushq   %r13

    
    pushq   %rsi            # -40
    pushq   %rdx            # -48
    pushq   %rcx            # -56
    pushq   %r8             # -72
    pushq   %r9             # -80
    pushq   $0

    call    getStringLength    # get the length of the string

    movq    $0, %r12        # iterator over the string
    movq    $0, %r13        # counter for templates
    
    popq    -16(%rbp)
    movq    %rax, -16(%rbp) # -16(%rbp) is the length of the string

    loop_over_string:
        incq    %r12
        cmpq    %r12, -16(%rbp) # see if the end of the string is reached
        jle     end_loop_over_string
        decq    %r12
        movq    -8(%rbp), %rax  # get the start of the string
        addq    %r12, %rax      # get address of the current character
        incq    %r12

        cmpb    $37, (%rax)     # check if the character is '%'
        jne default_printing
    
        incq    %rax

        cmpb    $37, (%rax)     # if the next character after '%' is also '%', print it normally
        je      procent_print_case

        incq    %r13            # increase the number of templates used

        cmpq    $1, %r13        # find out where the parameter for the current template is located
        jne     check_rdx       
        pushq   -40(%rbp)
        jmp     continue_printing_template

        check_rdx:
        cmpq    $2, %r13    
        jne     check_rcx       
        pushq   -48(%rbp)
        jmp     continue_printing_template
        
        check_rcx:
        cmpq    $3, %r13 
        jne     check_r8 
        pushq   -56(%rbp)     
        jmp     continue_printing_template
        
        check_r8:
        cmpq    $4, %r13 
        jne     check_r9       
        pushq   -64(%rbp)
        jmp     continue_printing_template
        
        check_r9:
        cmpq    $5, %r13 
        jne     check_on_stack       
        pushq   -72(%rbp)
        jmp     continue_printing_template
        
        check_on_stack:
                            # rbp + 8 + (r13-5)*8
        movq    %r13, %rcx  # since the paramter from rcx was already used, rcx can be used for the computation directly
        subq    $5, %rcx    # compute the formula above
        shlq    $3, %rcx
        addq    $8, %rcx
        addq    %rbp, %rcx
        pushq   (%rcx)      # save the result on stack

        continue_printing_template:
        cmpb    $115, (%rax)    # check is a string should be printed ('s')
        jne     do_number
        popq    %rdi            # get the address from the stack
        pushq   %rax            # save the old rax
        pushq   %rdi            # save the address on the stack
        pushq   %rcx
        pushq   %rsi
        pushq   $0
        call    getStringLength # get lenght into rax
        popq    %rsi
        popq    %rsi
        popq    %rcx

        popq    %rsi            # get the start address to rdi
        pushq   %rdx            # save rdx
        decq    %rax            # don't print the last character
        movq    %rax, %rdx      # print as many chars as the last function says
        movq    $1, %rax        # sys_write
        movq    $1, %rdi        # stdout
        pushq   %rcx
        syscall
        popq    %rcx
        popq    %rdx            # restore rdx
        popq    %rax            # restore rax
        jmp     continue_looping_base_string

        do_number:
        #cmpq    $
        cmpb    $117, (%rax)    # check if an unsigned int should be printed ('u')
        je      print_the_nums

        check_signed:
        cmpb    $100, (%rax)
        je      print_the_nums
        pushq   %rsi
        pushq   %rdx
        pushq   %rax
        pushq   %rdi
        movq    $procent, %rsi
        movq    $1, %rdx        # print the number of digits the number has
        movq    $1, %rax        # sys_write
        movq    $1, %rdi        # stdout  
        syscall
        popq    %rdi
        popq    %rax
        popq    %rdx
        popq    %rsi
        incq    %r12
        decq    %r13
        jmp     default_printing

        print_the_nums:
        popq    %rcx            # get the number in %rcx
        pushq   %rax            # save old rax
        movq    %rcx, %rax      # move the number to rax
        pushq   %rdi            # save old rdi

        cmpq    $0, %rax
        jge     continue_adding_to_buffer
        movq    8(%rsp), %rcx
        cmpb    $117, (%rcx)
        je      continue_adding_to_buffer
        pushq   %rax
        movq    $minus, %rsi
        movq    $1, %rdx        # print the number of digits the number has
        movq    $1, %rax        # sys_write
        movq    $1, %rdi        # stdout  
        pushq   %rcx  
        syscall
        popq    %rcx
        popq    %rax
        movq    $-1, %rdi
        mulq    %rdi

        continue_adding_to_buffer:
        movq    $0, %rdi
        movq    $0, %rcx
        movq    $num_buf, %rcx
        addq    $30, %rcx
        
        movb    $0, (%rcx)

        cmpq    $0, %rax        # check if 0 should be printed
        jne     get_unsigned_digits_on_stack
        movb    $48, (%rcx)          
        movq    $1, %rdi
        jmp     print_unsingned_int


        get_unsigned_digits_on_stack:   # move the digits of the number on the stack
            cmpq    $0, %rax                # check if all the digits were moved
            je      print_unsingned_int
            pushq   %rcx
            movq    $10, %rcx
            movq    $0, %rdx
            divq    %rcx                    # divide rax by 10
            popq    %rcx
            addq    $48, %rdx               # change it to char
            decq    %rcx
            movb    %dl, (%rcx)
            incq    %rdi                    # increase the number of digits
            jmp     get_unsigned_digits_on_stack

        print_unsingned_int:
            pushq   %rdi
            movq    %rcx, %rsi
            movq    %rdi, %rdx        # print the number of digits the number has
            movq    $1, %rax        # sys_write
            movq    $1, %rdi        # stdout   
            pushq   %rcx 
            syscall
            popq    %rcx
            popq    %rdi

        after_remove_u_digits:
            popq    %rdi
            popq    %rax

        jmp     continue_looping_base_string

        continue_looping_base_string:
        incq    %r12
        jmp     loop_over_string

        procent_print_case:
            incq    %r12

        default_printing:
            movq    %rax, %rsi  # the current character 
            movq    $1, %rax    # sys_write
            movq    $1, %rdi    # stdout    
            pushq   %rdx        # save rdx
            movq    $1, %rdx    # print only the current character
            pushq   %rcx
            syscall
            pushq   %rcx
            popq    %rdx        # restore rdx
            jmp loop_over_string

    end_loop_over_string:
    movq    -24(%rbp), %r12
    movq    -32(%rbp), %r13

    movq 	%rbp, %rsp
	pop 	%rbp
    ret

getStringLength:
    pushq   %rbp            # push the base pointer (and align the stack)
    movq    %rsp, %rbp      # copy stack pointer value to base pointer

    movq    $1, %rax
    
    get_len_loop:
        cmpb    $0, (%rdi)  # check if null is reached
        je      end_get_len_loop    # if it's reached, break the loop
        incq    %rdi                # move to the next character
        incq    %rax                # increase the current length
        jmp     get_len_loop        # continue the loop

    end_get_len_loop:
    mov 	%rbp, %rsp      # epilogue
	pop 	%rbp
    ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    movq    $template, %rdi
    movq    $42, %rsi
    movq    $0, %rdx
    movq    $mere, %rcx
    movq    $si, %r8
    movq    $-9223372036854775808, %r9
    pushq   $-2
    pushq   $-0
    call    my_printf
	
	mov 	%rbp, %rsp
	pop 	%rbp
	
    movq    $60, %rax       # sys_exit code
    movq    $0, %rdi        # exit with code 0
    syscall


