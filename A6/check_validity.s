.text

.include "basic.s"
charT: .asciz "%c"
valid: .asciz "valid"
invalid: .asciz "invalid"

.global main

# *******************************************************************************************
# Subroutine: check_validity                                                                *
# Description: checks the validity of a string of parentheses as defined in Assignment 6.   *
# Parameters:                                                                               *
#   first: the string that should be check_validity                                         *
#   return: the result of the check, either "valid" or "invalid"                            *
# *******************************************************************************************
check_validity:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    pushq   %r12            # the number of chars
    pushq   %r13            # the the stack size
    pushq   %rdi            # -24(%rbp) is the addres of the first char

    movq    %rdi, %r12      # make rdi the address of the current char
    movq    $0, %r13        # count how many open parentheses are on stack 

    loop_over_string:
    cmpb    $0, (%r12)      # check if null was reached
        je      final_check # if so, do the final check to see if there are open parentheses left
        
        cmpb    $40, (%r12) # case (
        je      do_open    
        
        cmpb    $91, (%r12) # case [
        je      do_open    
        
        cmpb    $123, (%r12)# case {
        je      do_open    
        
        cmpb    $60, (%r12) # case smaller
        je      do_open    
        
        cmpb    $41, (%r12) # case )
        je      do_closed
        
        cmpb    $93, (%r12) # case ]
        je      do_closed
        
        cmpb    $125, (%r12)# case }
        je      do_closed
    
        cmpb    $62, (%r12) # case >
        je      do_closed

        do_closed:          # in case the paranthesis is closed
            movb    (%r12), %al 
            popq    %rcx    # the last open paranthesis must be compatible with it
            subb    %cl, %al# if they are compatible, the diff between their ascii codes is either one or two

            cmpb    $2, %al # check the 2 correct cases
            je      not_invalid
            cmpb    $1, %al
            je      not_invalid
            movq    $invalid, %rax  # if the current paranthesis is incompatible with the last on stack, return 'invalid'
            jmp     end

            not_invalid:
                decq    %r13    # if the sequence is not invalid yet, remove one from the stack size

                jmp     continue_loop

        do_open:
            incq    %r13        # in case of an open paranthesis, add one to the stack size
            movq    $0, %rax    # add the ascii code of the paranthesis on stack
            movb    (%r12), %al
            pushq   %rax     
            jmp     continue_loop

        continue_loop:
            incq    %r12        # increment the current character's address
            jmp     loop_over_string

    final_check:
    cmpq    $0, %r13        # check if there are unclosed open paranthesis at the end
    je  is_valid            # if there are none, return 'valid'
    movq    $invalid, %rax  
    jmp     end

    is_valid:
        movq    $valid, %rax
        jmp     end
    
    end:
    movq    -8(%rbp), %r12      # restore calle saved registers
    movq    -16(%rbp), %r13

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		# first parameter: address of the message
	call	check_validity		# call check_validity

    movq    %rax, %rdi
    #movq    $charT, %rdi
    movq    $0, %rax
    call    printf

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

