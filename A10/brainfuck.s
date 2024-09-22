.data
brain: .space 30010
printBuffer: .space 8
readBuffer: .space 16

printTemplate: .asciz "%c"
readTemplate: .asciz "%c"

# there are debug
instructionTemplate: .asciz "%ld instruction\n"
printNum: .asciz "address %d\n"
printAtAddress: .asciz "print at address %d\n"
printNumNoNl: .asciz "%d "
numberAtendLoop: .asciz "value at end loop\n"
caseInvalid: .asciz "invalid char\n"
caseRead: .asciz "Read %c from console\n"

.text
.global brainfuck



format_str: .asciz "We should be executing the following code:\n%s"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	pushq	%rdi
	pushq	%r12	# the instruction pointer -16(%rbp)
	pushq	%r13	# the memory pointer -24(%rbp)
	pushq	%r14	# used to count the square brackets

	leaq	printBuffer, %rax	# adds a null into the print buffer (not really necessary)
	incq	%rax
	movq	$0, (%rax)

	movq	%rdi, %r12	# load the current instruction
	movq	$0, %r13	# load the current memory address
	
	base_loop:
		cmpb	$0, (%r12)	# check if EOF is reached
		je		end			# if so, terminate the function

		#movq	$instructionTemplate, %rdi
		#movq	$0, %rsi
		#movb	(%r12), %sil	
		#movq	$0, %rax
		#call 	printf

		cmpb	$43, (%r12)		# + character
		jne		check_minus

		leaq	brain, %rax		# load the current memory address into rax
		addq	%r13, %rax

		movq	$0, %rcx		# load the current variable into cl
		movb	(%rax), %cl
		incb	%cl				# increment it
		mov		%cl, (%rax)		# move it back to it's address

		#movq	$printNumNoNl, %rdi		# debug printing
		#movq	$0, %rsi
		#movb	(%rax), %sil	
		#movq	$0, %rax
		#call 	printf

		#movq	$printNum, %rdi
		#movq	%r13, %rsi	
		#movq	$0, %rax
		#call 	printf


		incq	%r12			# move to next instruction
		jmp		base_loop

		check_minus:
			cmpb	$45, (%r12)		# - character
			jne		check_move_left

			leaq	brain, %rax		# load the current memory address into rax
			addq	%r13, %rax
			
			movq	$0, %rcx		# load the current variable into cl
			movb	(%rax), %cl
			decb	%cl				# decrement it
			movb	%cl, (%rax)		# move it back to it's address

			#movq	$printNumNoNl, %rdi		# debug printing
			#movq	$0, %rsi
			#movb	(%rax), %sil	
			#movq	$0, %rax
			#call 	printf

			#movq	$printNum, %rdi
			#movq	%r13, %rsi	
			#movq	$0, %rax
			#call 	printf

			incq	%r12			# move to next instruction
			jmp		base_loop

		check_move_left:
			cmpb	$60, (%r12)		# less than character
			jne 	check_move_right

			decq	%r13			# decreseae the address of the memory pointer
			incq	%r12			# move to next instruction

			#movq	$printNum, %rdi
			#movq	%r13, %rsi	
			#movq	$0, %rax
			#call 	printf

			cmpq	$0, %r13		# loop the pointer around the edge of the buffer
			jge		base_loop
			movq	$29999, %r13
			jmp		base_loop
		
		check_move_right:
			cmpb	$62, (%r12)		# more than character
			jne 	check_print_character

			incq	%r13			# increase the address of the memory pointer
			incq	%r12			# move to next instruction

			#movq	$printNum, %rdi
			#movq	%r13, %rsi	
			#movq	$0, %rax
			#call 	printf

			cmpq	$30000, %r13	# loop the pointer around the edge of the buffer
			jl		base_loop
			movq	$0, %r13
			jmp		base_loop

		check_print_character:
			cmpb	$46, (%r12)		# . character
			jne 	check_input_character

			leaq	brain, %rax		# get the current memory address
			addq	%r13, %rax

			movq	$0, %rdi		# get the actual variable into dil
			movb	(%rax), %dil	
			call 	putchar

			#movq	$printAtAddress, %rdi	# debug
			#movq	%r13, %rsi	
			#movq	$0, %rax
			#call 	printf

			incq	%r12			# move to the next instruction
			jmp		base_loop

		check_input_character:
			cmpb	$44, (%r12)		# , character
			jne 	check_start_loop

			call 	getchar
			movq	$0, %rcx				# move what's been read into cl
			movb	%al, %cl

			leaq	brain, %rax				# get the address of the current variable
			addq	%r13, %rax

			movb	%cl, (%rax)				# move the just read variable into it's actual address

			#movq	$caseRead, %rdi
			#movq	$0, %rsi
			#movb	%cl, %sil
			#movq	$0, %rax
			#call 	printf

			incq	%r12					# move on to the next instruction
			jmp		base_loop

		check_start_loop:
			cmpb	$91, (%r12)		# [ character
			jne		check_end_loop

			leaq	brain, %rax				# compute the current variable's address and load it into %cl
			addq	%r13, %rax
			movq	$0, %rcx
			movb	(%rax), %cl

			cmpb	$0, %cl					# if it's not 0, proceed with the loop
			jne		start_loop_jump_to_next

			incq	%r12					# if it's 0, find the corresponding ']'
			movq	$0, %r14				# %r14 counts the current loop depth
			
			loop_over_instructions_start_loop:	# looping over the insctions to find the end of the loop
				cmpb	$91, (%r12)			# if a '[' is found, the depth is increased
				jne		check_closing_bracket_start_loop
				incq	%r14
				incq	%r12				
				jmp		loop_over_instructions_start_loop	# the loop continues

				check_closing_bracket_start_loop:
					cmpb	$93, (%r12)		
					jne		start_loop_increase_and_continue

					cmpq	$0, %r14		# if a ']' is found and the current depth is 0, then the corresponding closing of the loop was found and the program can continue
					je		start_loop_jump_to_next
					decq	%r14			# if a ']' is found and the depth is not 0, it is decreased
					incq	%r12
					jmp		loop_over_instructions_start_loop	# the loop continues

				start_loop_increase_and_continue:
					incq	%r12			# continue looping in case no [] was found
					jmp		loop_over_instructions_start_loop


			start_loop_jump_to_next:	# move on to the next instruction
				incq	%r12
				jmp		base_loop

		check_end_loop:
			cmpb	$93, (%r12)		# ] character
			jne		invalid_charater

			#movq	$numberAtendLoop, %rdi
			#movq	$0, %rsi
			#movb	(%rax), %sil	
			#movq	$0, %rax
			#call 	printf

			leaq	brain, %rax		# the value of the current variable is loaded into cl
			addq	%r13, %rax
			movq	$0, %rcx
			movb	(%rax), %cl


			cmpb	$0, %cl
			je		end_loop_jump_to_next	# if the variable is equal to 0, the program continues

									# if it's not 0, the corresponing '[' is found and the program continues from there
			movq	$0, %r14		# set the depth to 0
			decq	%r12			# look one instruction to the left

			loop_over_instructions_end_loop:
				cmpb	$93, (%r12)		# if a ']' is found, the depth is increased
				jne		check_open_bracket_end_loop
				incq	%r14
				decq	%r12
				jmp		loop_over_instructions_end_loop

				check_open_bracket_end_loop:
					cmpb	$91, (%r12)	# if no [] is found, the loop continues one insction to the left
					jne		end_loop_decrease_and_continue

					cmpq	$0, %r14	# if a '[' is found and the depth is 0, then the program continues execution from this point
					je		end_loop_jump_to_next
					decq	%r14		# if the depth is not 0, then it is decreased
					decq	%r12
					jmp		loop_over_instructions_end_loop

				end_loop_decrease_and_continue:
					decq	%r12		# continue the loop (basecase)
					jmp 	loop_over_instructions_end_loop

			end_loop_jump_to_next:
				incq	%r12
				jmp		base_loop

		invalid_charater:

			#movq	$caseInvalid, %rdi
			#movq	$0, %rax
			#call 	printf

			incq	%r12	# in case the current character does not represent a valid command, it is ignored
			jmp		base_loop

	end:
		movq	-16(%rbp), %r12		# restore callee saved regs
		movq	-24(%rbp), %r13
		movq	-32(%rbp), %r14

		movq %rbp, %rsp
		popq %rbp
		ret
