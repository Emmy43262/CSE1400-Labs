.text

class: .asciz "Hello class!\n"
template: .asciz "%ld\n"
formstr: .asciz "%ld"
names: .asciz "Emmy Rotariu 6177522, Andrei Man 6168183, power.s\n"

.global main

# ************************************************************
# Description: calculates the powers of non-negative bases   *
# and exponents	     										 *
#															 *
# Arguments:                                                 *
#   base: exponential base                					 *
#   exp: the exponent                                  		 *
#															 *
# Returns: 													 *
# 	'base' raised to the power of 'exp' 					 *
# ************************************************************
power2:
	pushq %rbp				
	movq %rsp, %rbp

	movq $1, %rax 			# load 1 into the output


	loop:
		cmpq $0, %rsi		# check if the number was raised to the correct power
		jle end				# if so, break the loop

		dec %rsi			# decrease the register counting how many times to loop are left
		mul %rdi			# multiplying %rax with the base

		jmp loop

	end:
	movq %rbp, %rsp
	popq %rbp
	ret

# The same as power from above but uses a faster algorithm
pow:
	pushq %rbp
	movq %rsp, %rbp

	movq $1, %rcx			# the current bit
	movq %rdi, %r11			# the current power of %rdi
	movq $1, %r8			# the answer

	loop_2:
		cmpq $0, %rsi
		jle end_2

		movq %rcx, %rdx 	# copy the current bit to check if it's in exponent
		andq %rsi, %rdx		# %rdx is 0 if the bit in %rcx is not in the exponent
		
		cmpq $0, %rdx		
 		je afterAddToAnswer			# if it is equal to 0, jump to after the addition
		
		movq %r8, %rax		# move the answer in rax
		mul %r11			# multiply rax with the current bit
		movq %rax, %r8		# move back the new answer
		sub %rcx, %rsi		# remove the current bit from the exponent

		afterAddToAnswer:
		movq %r11, %rax		# multiply the current power by itself
		mul %r11			
		movq %rax, %r11

		shl $1, %rcx		# move the current bit to the left

		jmp loop_2			# continue the while
	end_2:
	movq %r8, %rax			# load the return value in rax
	movq %rbp, %rsp
	popq %rbp
	ret

factorial:
    pushq   %rbp
    movq    %rsp, %rbp

    cmp     $0, %rdi            # check if the basecase is valid
    jne     normal              # if we're not at the base case, jump

    movq    $1, %rax           # set 1 as the output as the base

    movq    %rbp, %rsp         # epilogue
    popq    %rbp
    ret

    normal:
        subq    $8, %rsp   
        pushq   %rdi
        
        dec     %rdi                # call factorial(n-1)
        call    factorial
        
        popq    %r8
        addq    $8, %rsp
        
        mul     %r8               # multiply factorial(n-1) with n

        movq    %rbp, %rsp          # epilogue
        popq    %rbp
        ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	subq $16, %rsp			# make space on stack for input (make sure it's 16 bytes aligned)
	movq $0, %rax
	movq $formstr, %rdi
	leaq -16(%rbp), %rsi	# make the memory location
	call scanf

	movq -16(%rbp), %rdi	# get n from stack
	call factorial

	movq %rax, %rsi			# load output from function in rsi
	movq $template, %rdi
	movq $0, %rax
	call printf

	mov 	%rbp, %rsp
	pop 	%rbp
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program


