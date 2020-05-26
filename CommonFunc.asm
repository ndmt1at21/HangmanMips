######################################################
# ================ Macro for int ====================#
######################################################

# Macro: init arr integer, all element in arr = int
# %regStr: register contains address of array integer
# %value: value init
# %size: size of string
.macro initArrInt(%regArr, %value, %size)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	
	add	$t0, $zero, %size
	beq	$t0, $zero, EndInitArrInt
	
	li	$t0, 0
	add	$t1, $zero, %value
	move	$s0, %regArr
	
	LoopInitArrInt:
		# Save int
		sw	$t1, ($s0)
		
		# Increase count
		addi	$t0, $t0, 1
		
		# Increase address 
		addi	$s0, $s0, 4
		
		# Condition loop
		blt	$t0, %size, LoopInitArrInt
	
	EndInitArrInt:
	
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro


# Macro: set int at index in array
# %regArr: register contains address of arr
# %index: position in string
# $value: value 
.macro setIntArr(%regArr, %index, %value)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	
	# init register with value
	add	$t0, $zero, %value
	
	# Calculate index * 4
	add	$t1, $zero, %index
	li	$t2, 4
	mult	$t1, $t2
	mflo	$t1
	
	# Save 
	add	%regArr, %regArr, $t1
	sw	$t0, (%regArr)
	sub	%regArr, %regArr, $t1
	
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro


# Macro: get int at index in array int
# %regArr: register contains address of arr int
# %index: position in arr
# return in $v0: int at index in string
.macro getIntArr(%regArr, %index)
	pushStack($t0)
	pushStack($t1)
	
	# Calculate index * 4
	add	$t0, $zero, %index 
	li	$t1, 4
	mult	$t0, $t1
	mflo	$t0
	
	# Load
	add 	%regArr, %regArr, $t0
	lb 	$v0, (%regArr)
	sub	%regArr, %regArr, $t0
	
	popStack($t1)
	popStack($t0)
.end_macro



# Macro: convert int to string
# %regStr: register contains address buffer (string) hold output, last character = null
# %int: register contains integer
.macro toString(%regStr, %int)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	# init
	add	$t0, $zero, %int
	move 	$s0, %regStr
	li	$t1, 10
	abs	$t0, $t0
	
	LoopIntToString:
		# div 10
		div 	$t0, $t1
			
		# quotient
		mflo	$t0
			
		# remainder
		mfhi	$t2
		
		# save
		addi	$t2, $t2, 48
		sb	$t2, ($s0)
			
		# inc address
		addi	$s0, $s0, 1
		
		# condition loop
		bne	$t0, $zero, LoopIntToString
			
	# check negative
	add	$t0, $zero, %int
	blt 	$t0, $zero, AddMinusAfterString
	sb	$zero, ($s0) # add null
	j 	EndCheckNegative
	
	AddMinusAfterString:
		li	$t0, '-'
		sb	$t0, ($s0)
		addi	$s0, $s0, 1
	
	EndCheckNegative:
		
	# reverse
	strReverse(%regStr)
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro


######################################################
# ================ Macro for string =================#
######################################################

# Macro: init string, all element in string = char
# %regStr: register contains address of string to init
# %char: value init
# %len: length of string, one for terminate (null)
.macro initString(%regStr, %char, %len)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	add	$t0, $zero, %len
	beq	$t0, $zero, EndInitString
	
	li	$t2, 0
	add	$t1, $zero, %char
	move	$s0, %regStr
	
	LoopInitString:
		# Save char
		sb	$t1, ($s0)
		
		# Increase count
		addi	$t2, $t2, 1
		
		# Increase address 
		addi	$s0, $s0, 1
		
		# Condition loop
		blt	$t2, $t0, LoopInitString

	sb	$zero, ($s0)
	
	EndInitString:
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# Macro: string length
# %regStr: register contains address of string
# return in $v0: string length
.macro strlen(%regStr)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	
	# Init
	li	$t0, -1
	move	$s0, %regStr
	lb	$t1, ($s0)
	
	# Check length = 0
	li	$v0, 0	
	beq	$t1, 0, EndStrlen
	
	LoopStrlen:
		addi	$t0, $t0, 1
		lb 	$t1, ($s0)
		addi	$s0, $s0, 1
		
		bne	$t1, $zero, LoopStrlen
	move	$v0, $t0
	
	EndStrlen:
	
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro



# Macro: check str all alpha numberic
# %regStr: register contains address of string
# return in $v0: 1. all characters in the string are alphanumeric
#		  0. otherwise	
.macro isalnum(%regStr)
	pushStack($t0)
	pushStack($s0)
	
	# count loop
	li	$t0, 0
	move	$s0, %regStr
	
	LoopCheckAlnum:
		# condition break
		lb	$t0, ($s0)
		
		# check < '0'
		blt	$t0, 48, alnumFalse
		
		# check > '9' & < 'A'
		bgt	$t0, 57, CheckSmallerA
		j CheckNext1
		CheckSmallerA:
			blt	$t0, 65, alnumFalse
		
		CheckNext1:
		# check > 'Z' & < 'a'	
		bgt	$t0, 90, CheckSmallera
		j CheckNext2
		CheckSmallera:
			blt	$t0, 97, alnumFalse
			
		# check > 'z'
		CheckNext2:	
		bgt	$t0, 122, alnumFalse
			
		# inc address
		addi	$s0, $s0, 1
		lb	$t0, ($s0)
		
		# conditoon loop
		bne	$t0, $zero, LoopCheckAlnum
	
	alnumTrue:
		li	$v0, 1
		j EndCheckAlnum
	
	alnumFalse:
		li	$v0, 0
		j EndCheckAlnum
		
	EndCheckAlnum:
	
	popStack($s0)
	popStack($t0)
.end_macro

# Macro: compare string
# %regStr1: register contains address of string 1
# %regStr2: register contains address of string 2
# return in $v0: 0. not equal,    1. equal
# Note: 
.macro strcmp(%regStr1, %regStr2)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	pushStack($s1)
	
	# Init
	move	$s0, %regStr1
	move	$s1, %regStr2
	
	# Check length
	strlen($s0)
	move	$t0, $v0
	
	strlen($s1)
	move	$t1, $v0
	bne 	$t0, $t1, StrNotEqual

	LoopStrCmp:
		# Load
		lb	$t0, ($s0)
		lb	$t1, ($s1)
		
		# Inc address
		addi	$s0, $s0, 1
		addi 	$s1, $s1, 1
		
		# Condition break
		bne	$t0, $t1, StrNotEqual
		
		# Condition loop
		bne	$t0, $zero, LoopStrCmp
	
	StrEqual:	
		li	$v0, 1
		j EndStrCmp
		
	StrNotEqual:	
		li	$v0, 0
		j EndStrCmp
		
	EndStrCmp:
	
	popStack($s1)
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro


# Macro: string reverse
# $regStr: register contains string address
.macro strReverse(%regStr)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($s0)
	pushStack($s1)
	
	# init ptr begin, end
	move	$s0, %regStr
	move	$s1, %regStr
	
	# string len 
	strlen(%regStr)
	move	$t1, $v0
	
	# end address
	add	$s1, $s1, $t1
	addi	$s1, $s1, -1
	
	# number loop
	addi 	$t1, $t1, -1
	srl	$t1, $t1, 1

	# count loop
	li	$t0, -1
	
	LoopStrReverse:
		# load
		lb	$t2, ($s0)
		lb	$t3, ($s1)
		
		# swap
		swap($t2, $t3)
		
		# save
		sb	$t2, ($s0)
		sb	$t3, ($s1)
		
		# inc count
		addi	$t0, $t0, 1
		
		# inc, decrease address
		addi	$s0, $s0, 1
		addi 	$s1, $s1, -1
		
		# condition loop
		bne	$t0, $t1, LoopStrReverse
		
	popStack($s1)
	popStack($s0)
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# Macro: find first character appear in string (start from position input)
# %regStr: register contains address of string
# %char: character
# %posStart: postion start finding
# return in $v0: first position found, or -1 (if not found)
.macro strFind(%regStr, %posStart, %char)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	# Init
	add	$t0, $zero, %posStart
	add	$t1, $zero, %char
	move	$s0, %regStr
	add	$s0, $s0, %posStart
	
	addi	$t0, $t0, -1
	lb	$t2, ($s0)
		
	# Check null
	li	$v0, -1

	beq	$t2, $zero, EndStrFind
	LoopStrFind:
		# load char
		lb	$t2, ($s0)
		
		# inc count
		addi	$t0, $t0, 1
		
		# inc address
		addi 	$s0, $s0, 1
		
		# condition break
		beq	$t2, $t1, CharFound
	
		# condition loop
		bne	$t2, $zero, LoopStrFind
	
	beq	$t2, $zero, CharNotFound
	
	CharFound:
		move	$v0, $t0
		j EndStrFind
		
	CharNotFound:
		li	$v0, -1
		j EndStrFind
		
	EndStrFind:
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# Macro: copy string from posStart to posEnd in src string
# %dstStr: register contains address of destional string
# %srcStr: register contains address of source string
# %posStart: positon start copy
# %num: number character copy
.macro substr(%dstStr, %srcStr, %posStart, %num)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	pushStack($s1)
	
	# init
	move	$s0, %dstStr
	move	$s1, %srcStr
	add	$s1, $s1, %posStart
	li	$t0, 0
	
	# loop copy
	LoopSubstr:
		# save char
		lb	$t1, ($s1)
		sb	$t1, ($s0)
		
		# inc number char copied
		addi	$t0, $t0, 1
		
		# inc address
		addi	$s0, $s0, 1
		addi	$s1, $s1, 1
		
		# condition loop
		bne	$t0, %num, LoopSubstr
	
	# terminate
	sb	$zero, ($s0)	
	
	popStack($s1)
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro

######################################################
# ================ Macro for box ====================#
######################################################

# Macro: show message box
# %msgIn: register contains address message to show
# %typeMsg: const integer
#		0. Error icon
#		1. Infor icon
#		2. Warning icon
#		3. Question icon
.macro showMsgBox(%msgIn, %typeMsg)
	pushStack($a0)
	pushStack($a1)
	
	li	$v0, 55
	move	$a0, %msgIn
	add	$a1, $zero, %typeMsg
	syscall
	
	popStack($a1)
	popStack($a0)
.end_macro


# Macro: input message box
# %msgIn: register contains address message to show
# %msgOut: register contains address buffer
# %maxNum: maximum number of characters to read
# return in $v0: status value
#		0. OK, buffer has data
#		-2. Cancel
#		-3. OK, no change to buffer
#		-4. length iput > length buffer, assign terminate char (null) to end buffer
# Note: %msgIn = $a1, %msgOut = $a0 can make error
.macro inputMsgBox(%msgIn, %msgOut, %maxNum)
	pushStack($a0)
	pushStack($a1)
	pushStack($a2)
	
	li	$v0, 54
	move	$a0, %msgIn
	move	$a1, %msgOut
	add	$a2, $zero, %maxNum
	syscall
	move	$v0, $a1
		
	popStack($a2)
	popStack($a1)
	popStack($a0)
	
	pushStack($s0)
	pushStack($t0)
	
	move	$s0, %msgOut
	LoopCheckNewLine:
		# condition break
		lb	$t0, ($s0)
		beq	$t0, 10, EndCheckNewLine
		
		# add address
		addi	$s0, $s0, 1
		
		bne	$t0, $zero, LoopCheckNewLine
	
	EndCheckNewLine:
		sb	$zero, ($s0)
		
	popStack($t0)	
	popStack($s0)
	
.end_macro


# Macro: show confirm box
# %msgIn: register contains address message to show
# return in $v0: 0 Yes, 1 No, 2 Cancel 
.macro showConfirmBox(%msgIn)
	pushStack($a0)
	
	li	$v0, 50
	move	$a0, %msgIn
	syscall
	move 	$v0, $a0
	
	popStack($a0)
.end_macro


#############################################################
# =========== For print (show result in console) ===========#
#############################################################

# Macro: print char
# %char: register contains char (or const char) need printing 
.macro printChar(%char)
	pushStack($a0)
	
	li	$v0, 11
	add	$a0, $zero, %char
	syscall
	
	popStack($a0)
.end_macro


# Macro: print const string
# %string: const string need printing 
.macro printConstString(%string)
	.data
		str:	.asciiz		%string
	.text
		pushStack($a0)
	
		li	$v0, 4
		la	$a0, str
		syscall
	
		popStack($a0)
.end_macro


# Macro: print string
# %string: register contains address of string or arr char
.macro printString(%string)
	pushStack($a0)
	
	li	$v0, 4
	move	$a0, %string
	syscall
	
	popStack($a0)
.end_macro


# Macro: print int
# %int: register contains integer (or const int) need printing
# Note: warning if %int = $v0
.macro printInt(%int)
	pushStack($a0)
	
	li	$v0, 1
	add	$a0, $zero, %int
	syscall
	
	popStack($a0)
.end_macro


# Macro: print array integer
# %regArr: register contains address of array
# %size: size print
.macro printArrInt(%regArr, %size)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	
	# Check size
	add	$t0, $zero, %size
	beq	$t0, $zero, EndPrintArrInt
	
	# Init
	li	$t0, 0
	move	$s0, %regArr
	
	LoopPrintArrInt:
		# Load
		lw	$t1, ($s0)
		
		# Print
		printInt($t1)
		printChar(' ')
		
		# Inc count
		addi	$t0, $t0, 1
		
		# Inc address
		addi	$s0, $s0, 4
		
		# Condition loop
		blt	$t0, %size, LoopPrintArrInt
		
	EndPrintArrInt:
	
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro



###############################################
# ================ Stack =====================#
###############################################

# Macro: push content register to stack
# %regIn: register input
.macro pushStack(%regIn)
	addi	$sp, $sp, -4
	sw	%regIn, ($sp)
.end_macro


# Macro: pop stack to register
# %regOut: register ouput
.macro popStack(%regOut)
	lw	%regOut, ($sp)
	addi	$sp, $sp, 4
.end_macro

# Macro: swap content two register
# %a: register 1
# %b: register 2
.macro swap(%a, %b)
	pushStack($t0)
	move	$t0, %a
	move 	%a, %b
	move	%b, $t0
	popStack($t0)
.end_macro
