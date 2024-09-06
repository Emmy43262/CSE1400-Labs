.text

class: .asciz "Hello class!\n"
template: .asciz "%ld\n"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************
decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	# your code goes here

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

power:    #rdi is base, rsi is exponent
	pushq %rbp
	movq %rsp, %rbp

	movq $1, %rax 			# load 1 into the output

	loop:
		cmpq $0, %rsi
		jle end

		dec %rsi			# decrease the register counting the exponent
		mul %rdi			# multiplying %rax with the base

		jmp loop

	end:
	movq %rbp, %rsp
	popq %rbp
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

							#call	decode			# call decode
	movq $2, %rdi
	movq $6, %rsi
	call power

	movq %rax, %rsi
	movq $template, %rdi
	movq $0, %rax
	call printf

	mov 	%rbp, %rsp
	pop 	%rbp
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program


