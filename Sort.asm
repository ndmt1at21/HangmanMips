.include "CommonFunc.asm"
#%array: label
#size : size of arr
#return : return $v0 :address of array
.macro sort(%array,%size)
pushStack($t0)
pushStack($t1)
pushStack($t2)
pushStack($t3)
pushStack($t4)
pushStack($t5)
pushStack($t6)
pushStack($t7)
pushStack($s0)

li $t0,%size

sll $t0,$t0,2

li $t4,500

reinitialize123:
	move $t1, $zero			# Hold pos of input[x]
	move $t2, $zero
	addi $t2, $t2, 4		# Hold pos of input[x + 1]
	move $s0, $zero
	addi $s0, $s0, 1		# Condition check: if($t7 == 1); branch to swap values
sort123:
	beq $t3, $t4, Print123	        # if(loopCounter == 500), branch to Print
	beq $t2, $t0, reinitialize123	# if ($t2 == end of array); branch to reinitialize registers
	
	
	lw $t5,%array($t1)	        # Load value in input array at addr $t1 into $t5
	lw $t6,%array($t2)		# Load value in input array at addr one further ($t2) into $t6
	
	addi $t3, $t3, 1		# Increments loop counter
	
	slt $t7, $t5, $t6		# Set less than if $t5 is less than $t6, $t7 would get 1
	beq $t7, $s0,swapvalues123          # if($t7 == 1); swap the values of the two array pos
	# If the condition is false           
	addi $t1, $t1, 4		# Moves to next 4 bytes (x)
	addi $t2, $t2, 4
	j sort123				# Go back to sort
	
swapvalues123:
	# Swaps values
	
	sw $t5, %array($t2)		# Puts value in $t5 at next pos in array
	sw $t6, %array($t1)		# Puts value in $t6 at prior pos in array
	
	
	addi $t1, $t1, 4		# Moves to next 4 bytes (x)
	addi $t2, $t2, 4		# Moves to next 4 bytes (x + 1)

	j sort123			# Go back to sort	
	
Print123:
la $v0,%array
#printArrInt($v0,%size)	

popStack($s0)
popStack($t7)
popStack($t6)
popStack($t5)
popStack($t4)
popStack($t3)
popStack($t2)
popStack($t1)
popStack($t0)
.end_macro

#.data
#a:.word 32,45,54,32,54,21,24,65,100,54,32,67,10,91,,25,43,21,65,78,65,23
#.text 
#sort(a,21)





