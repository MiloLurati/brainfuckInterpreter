# brainfuck interpreter by Milo Lurati
.text
format_str: .asciz "We should be executing the following code:\n%s"
char: .asciz "%c"
read: .asciz "%lc"

.global brainfuck

brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rbx 				# move brainfuck command string adress to RBX
	xor %r13, %r13 					# 0 in bracket loop counter

	movq %rdi, %rsi
	movq $format_str, %rdi
	xor %rax, %rax
	call printf

	movq $1048576, %rdi
	movq $1, %rsi
	call calloc						# allocate memory of 1048576 cells of 1 byte, initialized to zero, with C function calloc()
	movq %rax, %r14					# store adress of allocated array in R14

	decq %rbx

	loop:
		incq %rbx
		movb (%rbx), %al			# move 1 byte char to AL for following comparisons

		cmpb $0, %al				# compare to to NUL
		je endBrainFuck

		cmpb $91, %al				# compare to [
		je openBracket

		cmpb $93, %al				# comapre to ]
		je closedBracket

		cmpb $43, %al				# compare to +
		je incByte

		cmpb $45, %al				# compare to -
		je decByte

		cmpb $62, %al				# compare to >
		je incPointer

		cmpb $60, %al				# compare to <
		je decPoniter

		cmpb $46, %al				# compare to .
		je output

		cmpb $44, %al				# compare to ,
		je input

		jmp loop
	
	incByte:						# increment array element at index R14
		incb (%r14)
		jmp loop
	
	decByte:						# decrement array element at index R14
		decb (%r14)
		jmp loop

	incPointer:						# increment index pointer of array
		incq %r14
		jmp loop
	
	decPoniter:						# decrement index pointer of array
		decq %r14
		jmp loop
	
	output:							# output to terminal array content at index R14
		movq $char, %rdi
		movq (%r14), %rsi
		xor %rax, %rax
		call printf
		jmp loop

	input:							# input from terminal and store it at index R14
		movq $read, %rdi
		movq %r14, %rsi
		xor %rax, %rax
		call scanf
		jmp loop

	openBracket:
		cmpb $0, (%r14)				# compare arraycontent at index R14 to zero
		je findEndBracket

		pushq %rbx 					# push on stack brainfuck command string pointer to stack for later use
		jmp loop
	
	closedBracket:
		cmpb $0, (%r14)
		je cB0
		popq %rbx					# pop from stack into RBX adress of maching opening bracket of brainfuck command string
		decq %rbx
		jmp loop
		cB0:
		popq %rax
		xor %rax, %rax
		jmp loop
	
	findEndBracket:
		incq %rbx
		movb (%rbx), %al			# move 1 byte char to AL for following comparisons

		cmpb $93, %al				# comapre to ]
		je countClosedBrackets

		cmpb $91, %al				# compare to [
		je countOpenBrackets

		jmp findEndBracket

	countOpenBrackets:				# increment bracket counter
		incq %r13
		jmp findEndBracket
	
	countClosedBrackets:
		cmpq $0, %r13				# compare bracket counter to zero
		je loop

		decq %r13					# decrement bracket counter
		jmp findEndBracket

endBrainFuck:						# end of brainfuck subroutine			
	movq %rbp, %rsp
	popq %rbp
	ret

