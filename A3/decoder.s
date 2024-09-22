.text

.include "abc_sorted.s"

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
        movq    -16(%rbp), %rdi # set the address of the current quad as the addres of the first quad
        addq    -8(%rbp), %rdi  # add the offset computed at the end of the last lopp iteration

        call getCount           # the function to get how many times a letter repeats
        pushq   %rax            # push the value on the stack
        pushq   $0
        
        movq    -16(%rbp), %rdi # set the address of the current quad as the addres of the first quad
        addq    -8(%rbp), %rdi  # add the offset computed at the end of the last lopp iteration
        
        call getChar            # the function to get the ascii code of the current character
        popq    %r8
        pushq   %rax            

        popq    %rdi            # load the two values in rdi and rsi to invoke the printChars method
        popq    %rsi

        call printChars
        
        movq    -16(%rbp), %rdi     # recompute the address of the current quad
        addq    -8(%rbp), %rdi      
        call getNextLine            # call the method that parses the line value of the next quad from the current quad
        shlq    $3, %rax            # multiply the new line index by 8 to get the actual memory offset
        movq    %rax, -8(%rbp)      # update the memory offset

        cmpq     $0, -8(%rbp)       # check if the new line is line 0
        je final                    # if so, exit the loop
        jmp startLoop

    final:
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

getCount:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    movq    (%rdi), %rax    # get the value from the current memory address to %rax
    shlq    $48, %rax       # discard the 48 leftmost bits
    shrq    $48, %rax
    shrq    $8, %rax        # keep only the 7th byte

    # epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

getChar:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    movq    (%rdi), %rax    # get the memory address to rax
    shlq    $56, %rax       # discard the 56 leftmost bits
    shrq    $56, %rax

    # epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

getNextLine:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    movq    (%rdi), %rax    # get the memory address to rax
    shlq    $16, %rax       # discard the 16 leftmost bits
    shrq    $16, %rax   
    shrq    $16, %rax       # discrad the 16 rightmost bits

    # epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

printChars:
    #rdi - ascii code for char, rsi - number of times
    # prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    pushq   %rbx
    pushq   %rbx        

    subq    $8, %rsp        # subtract 8 from rsp 
    pushq   %rsi    
    movq    %rdi, %rbx      # save the ascii code of the char in rbx

    printLoop:
        movq    $0, %rax    
        movq    %rbx, %rsi  # move the ascii code to rsi
        movq    $charT, %rdi 
        call printf

        popq    %rsi # decrease nr of repetitions
        decq    %rsi
        pushq   %rsi

        cmpq    $0, %rsi  
        je  end
        jmp printLoop

    end:

    movq -8(%rbp), %rbx

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

