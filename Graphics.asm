.include "CommonFunc"

# Width: 512 pixels
# Heigth: 512 pixels
# Unit width: 4 pixels
# Unit height: 4 pixels
# Base address: 0x100080000 ($gp)
# Real width: 512 / 4 = 128
# Real hight: 512 / 4 = 128
# %color: RGB 

.macro drawPixel(%x, %y, %color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	
	# (y * realWidth + x) * 4 byte (1 pixel = 4 bytes)
	add	$t0, $zero, %x
	add	$t1, $zero, %y
	
	# y * realWidth
	li	$t2, 128
	mult	$t1, $t2
	mflo	$t1
	
	# result + x
	add	$t1, $t1, $t0
	
	# position in $gp
	li	$t2, 4
	mult	$t1, $t2
	mflo	$t1
	
	# save color
	add	$t2, $zero, %color
	add	$gp, $gp, $t1
	sw	$t2, ($gp)
	sub	$gp, $gp, $t1
	
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro


.macro drawHorizontalLine(%xStart, %y, %xEnd, %color)
	pushStack($t0)
	pushStack($t1)
	
	# init
	add	$t0, $zero, %xStart
	
	LoopDrawHorizontalLine:
		# draw pixel
		drawPixel($t0, %y, %color)
		
		# increase x
		addi	$t0, $t0, 1
		
		# condition loop
		blt	$t0, %xEnd, LoopDrawHorizontalLine
	
	popStack($t1)
	popStack($t0)
.end_macro
