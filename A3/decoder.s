.text

.include "helloWorld.s"

.global main

test: .asciz "%ld\n"
charT: .asciz "%c"

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

    subq    $16, %rsp
    movq    $0,  -8(%rbp)   # current offset from start
    movq    %rdi, -16(%rbp) # address of start
    
    startLoop:
        movq    -16(%rbp), %rdi 
        addq    -8(%rbp), %rdi

        call getCount
        pushq   %rax
        call getChar
        pushq   %rax

        popq    %rdi
        popq    %rsi

        call printChars
        
        movq    -16(%rbp), %rdi 
        addq    -8(%rbp), %rdi
        call getNextLine
        mul     $8
        movq    %rax, -8(%rbp)

        cmp     $0, -8(%rbp)
        je final
        jmp startLoop

        #pushq      
    
    #addq $0, %rdi

    #call getChar
    #movq %rax, %rsi

    #movq    $test, %rdi
    #movq    $0, %rax
    #call printf
    final:
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

getCount:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    movq    (%rdi), %rax
    shlq    $48, %rax
    shrq    $48, %rax
    shrq    $8, %rax

    # epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

getChar:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    movq    (%rdi), %rax
    shlq    $56, %rax
    shrq    $56, %rax

    # epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

getNextLine:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    movq    (%rdi), %rax
    shlq    $16, %rax
    shrq    $16, %rax
    shrq    $16, %rax

    # epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

printChars:
    #rdi - ascii code for char, rsi - number of times
    # prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    subq    $8, %rsp
    pushq   %rsi
    movq    %rdi, %rbx

    printLoop:
        movq    $0, %rax
        movq    %rbx, %rsi
        movq    $charT, %rdi
        call printf

        popq    %rsi
        decq    %rsi
        pushq   %rsi

        cmpq    $0, %rsi
        je  end
        jmp printLoop

    end:
    # epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

