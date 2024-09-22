.text

.include "abc_sorted.s"

.global main

test: .asciz "%ld\n"
charT: .asciz "%c"

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 1 byte background color                                *
#   - 1 byte foreground color                                *
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
        call getForegroundColor # get the code of the foreground color
        pushq   %rax            # push the value on the stack
        pushq   $0              # keep the stack aligned to 16 bytes

        movq    -16(%rbp), %rdi # set the address of the current quad as the addres of the first quad
        addq    -8(%rbp), %rdi  # add the offset computed at the end of the last lopp iteration
        call getBackgroundColor # get the code of the background color
        popq    %r8
        pushq   %rax            # push the value on the stack

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

        popq    %rdi            # load the ascii code of the character in rdi
        popq    %rsi            # load the number of times the character should be printed in rdi
        popq    %rdx            # load the background color in rdx
        popq    %rcx            # load the foreground color in rcx

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

getBackgroundColor:
    # prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    movq    (%rdi), %rax    # get the value from the current memory address to %rax
    shrq    $56, %rax       # keep only the 1st byte

    # epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

getForegroundColor:
    # prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    movq    (%rdi), %rax    # get the value from the current memory address to %rax
    shlq    $8, %rax        # discard the 1st byte
    shrq    $8, %rax
    shrq    $48, %rax       # keep only the 2nd byte

    # epilogue
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

anziBackground: .asciz "\033[48;5;%ldm"
anziForeground: .asciz "\033[38;5;%ldm"
anziEffect: .asciz "\033[%ldm"

printChars:
    #rdi - ascii code for char, rsi - number of times, rcx - foreground color, rdx - background color
    # prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

    pushq   %rbx            # save rbx on stack
    pushq   %r12            # save r12 on stack        

    movq    %rdi, %rbx      # save the ascii code in rbx
    movq    %rsi, %r12      # save the num of reps in r12

    pushq   %rdx            # push background color on stack
    pushq   %rcx            # push foreground color on stack

    cmpq    %rcx, %rdx      # check if foreground and background are equal (if so, a effect has to be applied)
    jne     changeColors

        cmpq    $0, %rcx        # check if the text should be reset to default
        jne     stopBlinking    # if not, check the next effect
        movq    $0, %rsi        # if yes, load the effect code to rsi
        jmp     changeEffect    # the same until line 213

    stopBlinking:
        cmpq    $37, %rcx
        jne bold
        movq    $25, %rsi
        jmp     changeEffect

    bold:
        cmpq    $42, %rcx
        jne faint
        movq    $1, %rsi
        jmp     changeEffect

    faint:
        cmpq    $66, %rcx
        jne conceal
        movq    $2, %rsi
        jmp     changeEffect

    conceal:
        cmpq    $105, %rcx
        jne reveal
        movq    $8, %rsi
        jmp     changeEffect

    reveal:
        cmpq    $153, %rcx
        jne blink
        movq    $28, %rsi
        jmp     changeEffect
    
    blink:
        cmpq    $182, %rcx
        jne printLoop
        movq    $5, %rsi
        jmp     changeEffect

    changeEffect:
        movq    $0, %rax                
        movq    $anziEffect, %rdi       #print the ansi sequence for the effect that needs to be applied
        call    printf
        jmp     printLoop

    changeColors:
        movq    $0, %rax                   
        movq    $anziForeground, %rdi   
        movq    (%rsp), %rsi              # set the background color
        call    printf

        movq    $0, %rax
        movq    $anziBackground, %rdi   
        popq    %rsi                    # pop the alignment 0 from stack
        popq    %rsi                    # get the background color from the stack
        call    printf

    printLoop:

        movq    $0, %rax    
        movq    %rbx, %rsi      # move the ascii code to rsi
        movq    $charT, %rdi 
        call printf

        decq    %r12            # decrease nr of repetitions

        cmpq    $0, %r12        # check if the character was printed enough times
        je  end                 
        jmp printLoop           # if not, go back to start

    end:

    movq -8(%rbp), %rbx     # restore rbx
    movq -16(%rbp), %r12    # restore r12

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

