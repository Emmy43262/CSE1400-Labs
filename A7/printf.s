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
        pushq   -40(%rbp)       # this is where rsx is saved
        jmp     continue_printing_template

        check_rdx:
        cmpq    $2, %r13    
        jne     check_rcx       
        pushq   -48(%rbp)       # this is where rdx is saved
        jmp     continue_printing_template
        
        check_rcx:
        cmpq    $3, %r13 
        jne     check_r8 
        pushq   -56(%rbp)       # this is where rcx is saved
        jmp     continue_printing_template
        
        check_r8:
        cmpq    $4, %r13 
        jne     check_r9       
        pushq   -64(%rbp)       # this is where r8 is saved
        jmp     continue_printing_template
        
        check_r9:
        cmpq    $5, %r13        
        jne     check_on_stack       
        pushq   -72(%rbp)       # this is where r9 is saved
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
        popq    %rsi            # restore registers
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
        popq    %rcx            # restore rcx
        popq    %rdx            # restore rdx
        popq    %rax            # restore rax
        jmp     continue_looping_base_string

        do_number:
        #cmpq    $
        cmpb    $117, (%rax)    # check if an unsigned int should be printed ('u')
        je      print_the_nums

        check_signed:
        cmpb    $100, (%rax)    # checek if a signed number should be printed ('d')
        je      print_the_nums 
        pushq   %rsi            # save registers 
        pushq   %rdx
        pushq   %rax
        pushq   %rdi
        movq    $procent, %rsi  # print a '%'
        movq    $1, %rdx        # print the number of digits the number has
        movq    $1, %rax        # sys_write
        movq    $1, %rdi        # stdout  
        syscall
        popq    %rdi            # restore registers
        popq    %rax
        popq    %rdx
        popq    %rsi
        incq    %r12            # print the character after the '%' in case there is no valid template
        decq    %r13
        jmp     default_printing

        print_the_nums:
        popq    %rcx            # get the number in %rcx
        pushq   %rax            # save old rax
        movq    %rcx, %rax      # move the number to rax
        pushq   %rdi            # save old rdi

        cmpq    $0, %rax        # check if a negative number should be printed
        jge     continue_adding_to_buffer
        movq    8(%rsp), %rcx   # load the template into rcx
        cmpb    $117, (%rcx)    # in case a signed number has to be printed, print a '-'
        je      continue_adding_to_buffer
        pushq   %rax
        movq    $minus, %rsi
        movq    $1, %rdx        # print the number of digits the number has
        movq    $1, %rax        # sys_write
        movq    $1, %rdi        # stdout  
        pushq   %rcx  
        syscall
        popq    %rcx            # restore the registers
        popq    %rax
        movq    $-1, %rdi   
        mulq    %rdi            # multiply the number (stored in rax) by -1 to get the positive number to print

        continue_adding_to_buffer:
        movq    $0, %rdi        
        movq    $0, %rcx
        movq    $num_buf, %rcx  # save the buffer into rcx
        addq    $30, %rcx       # start putting digits into the buffer from the end
        
        movb    $0, (%rcx)      

        cmpq    $0, %rax        # check if 0 should be printed
        jne     get_unsigned_digits_on_stack
        movb    $48, (%rcx)          
        movq    $1, %rdi
        jmp     print_unsingned_int


        get_unsigned_digits_on_stack:       # move the digits of the number on the stack
            cmpq    $0, %rax                # check if all the digits were moved
            je      print_unsingned_int     # if so, print the number
            pushq   %rcx                    # save rcx
            movq    $10, %rcx               # move the divisor(10) into rcx
            movq    $0, %rdx                # set rdx to 0 to save the reminder of the division
            divq    %rcx                    # divide rax by 10
            popq    %rcx                    # restore rcx
            addq    $48, %rdx               # change it to char
            decq    %rcx                    # decrease the address in the buffer
            movb    %dl, (%rcx)             # move the current digit in the buffer
            incq    %rdi                    # increase the number of digits
            jmp     get_unsigned_digits_on_stack    # repeat for the next digit

        print_unsingned_int:
            pushq   %rdi            # save rdi
            movq    %rcx, %rsi      # get the address of the most significant digit from the buffer into rsi
            movq    %rdi, %rdx      # print the number of digits the number has
            movq    $1, %rax        # sys_write
            movq    $1, %rdi        # stdout   
            pushq   %rcx            # save rcx
            syscall
            popq    %rcx            # restore rcx
            popq    %rdi            # restore rdi

        after_remove_u_digits:
            popq    %rdi            # restore rdi
            popq    %rax            # restore rax

        jmp     continue_looping_base_string

        continue_looping_base_string:
        incq    %r12                # process the next character
        jmp     loop_over_string    # continue the loop

        procent_print_case:
            incq    %r12            # in case a "%%" apears, to solve edgecases such as "%%d"

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
    movq    -24(%rbp), %r12     # restore calle saved registers
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


