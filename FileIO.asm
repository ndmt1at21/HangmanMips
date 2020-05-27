.include "CommonFunc.asm"

#Get string in buffer when reach first delim store in dstStr
# wordPos: pos of the Word in dictionary
# delim: end of string
# dstStr: store substring
# path: file path
# return in %dstStr
# load from buffer
.macro getline(%wordPos, %dstStr, %delim, %path)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($t4)
	pushStack($s7)
	pushStack($a0)	
	pushStack($a1)	
	pushStack($a2)
	
        move $t4, %dstStr
	
	#Open file
	li $v0, 13
	la $a0, %path
	li $a1, 0
	li $a2, 0
	syscall
	
	move $s7, $v0 #save file descriptor
	
	#Reading file
	li $v0, 14
	move $a0, $s7
	la $a1, buffer
	la $a2, 2048
	syscall
		
	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s7      # file descriptor to close
	syscall            # close file
	
	la $t0, buffer
	move $t1, %wordPos 	# Word position
	li $t2, 0	# Check whether we encounter random int or not
	la $a0, 0x00
	
	loop:  
		lb $t3, ($t0)		# Load first char in buffer to $t3
		beq $t3, $a0, Error	# Can not find word
		beqz $t1, getWord	# first word
		beq $t3, %delim, count	# if we encounters delim while reading characters, count it to $t2
		beq $t1, $t2, getWord	# if we find that word, go to getWord
		addi $t0, $t0, 1	# else increment the address unless it find the word
		j loop
	count:
		addi $t2, $t2, 1
		addi $t0, $t0, 1
		j loop
		
	getWord:
		
		LoopGetWord:
			lb $t3, ($t0)
			beq $t3, %delim, getWordExit
			beqz $t3, getWordExit
			sb $t3, ($t4)
			addi $t0, $t0, 1
			addi $t4, $t4, 1
			j LoopGetWord 
	getWordExit:
		li $t3, 0x00
		sb $t3, ($t4)
		li $v0, 0
		j end
		
	Error:
		li $v0, -1
		li $t3, 0x00
		sb $t3, ($t4)
	
	end:
	
	popStack($a2)	
	popStack($a1)	
	popStack($a0)
	popStack($s7)		
	popStack($t4)
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro


# Save a character to file
# char: register or const char save to file
# flag: 
# 0: trunc, 1: app
.macro saveChar(%char, %flag)
	pushStack($s7)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)	
	pushStack($t4)
	pushStack($a0)	
	pushStack($a1)	
	pushStack($a2)	
	
	li $t0, 1
	
	la $t1, %flag
	
	add $t3, $zero, %char
	la $t4, storeSaveChar
	sb $t3, ($t4)
	
	beqz $t1, trunc
	beq $t1, $t0, app
	
	trunc:
		#Open file
		li $v0, 13
		la $a0, fileOut
		li $a1, 1
		li $a2, 0
		syscall
		move $s7, $v0 #save file descriptor
		
		# Write to file
		li $v0, 15
		move $a0, $s7
		move $a1, $t4
		li $a2, 1
		syscall
		
		j exit
	
	app:
		#Open file
		li $v0, 13
		la $a0, fileOut
		li $a1, 9
		li $a2, 0
		syscall
		move $s7, $v0 #save file descriptor
		
		# Append to file
		li $v0, 15
		move $a0, $s7
		move $a1, $t4
		li $a2, 1
		syscall
	exit:

	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s7      # file descriptor to close
	syscall            # close file
	
	popStack($a2)	
	popStack($a1)	
	popStack($a0)	
	popStack($t4)	
	popStack($t3)
	popStack($t2)	
	popStack($t1)
	popStack($t0)
	popStack($s7)
.end_macro

# Save a string to file
# string: register contains string save to file
# flag: 
# 0: trunc, 1: app
.macro saveString(%string, %flag)
	pushStack($s7)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($t4)
	pushStack($t5)	
	pushStack($a0)	
	pushStack($a1)	
	pushStack($a2)	
	
	li $t0, 1
	
	la $t1, %flag
	
	li $t2, 0x00
	add $t3, $zero, %string
	
	beqz $t1, trunc
	beq $t1, $t0, app
	
	trunc:
		la $t4, storeSaveChar	
		
		#Open file
		li $v0, 13
		la $a0, fileOut
		li $a1, 1
		li $a2, 0
		syscall
		move $s7, $v0 #save file descriptor
		
		loopTrunc:
			# Write to file
			lb $t5, ($t3)
			sb $t5, ($t4)
			beq $t5, $t2, loopTruncExit
			
			li $v0, 15
			move $a0, $s7
			move $a1, $t4
			li $a2, 1
			syscall	
			
			addi $t3, $t3, 1
			j loopTrunc
		loopTruncExit:
		
		j exit
	app:
		loopApp:
			lb $t4, ($t3)
			beq $t4, $t2, loopAppExit
			saveChar($t4, 1)
			add $t3, $t3, 1
			j loopApp
		loopAppExit:
	exit:

	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s7      # file descriptor to close
	syscall            # close file
	
	popStack($a2)	
	popStack($a1)	
	popStack($a0)	
	popStack($t5)	
	popStack($t4)	
	popStack($t3)
	popStack($t2)	
	popStack($t1)
	popStack($t0)
	popStack($s7)
.end_macro

############################################################
.data
	fileOut: .asciiz "C:/Users/Administrator/Desktop/nguoichoi.txt"
	buffer: .space 2048
	storeSaveChar: .byte