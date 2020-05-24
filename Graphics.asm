.include "CommonFunc.asm"

# Width: 512 pixels
# Heigth: 512 pixels
# Unit width: 4 pixels
# Unit height: 4 pixels
# Base address: 0x100080000 ($gp)
# Real width: 512 / 4 = 128
# Real hight: 512 / 4 = 128
# %color: RGB 
# Note: use $t0 save y can make error
.macro drawPixel(%x, %y, %color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	printInt(%y)
	
	# (y * realWidth + x) * 4 byte (1 pixel = 4 bytes)
	add	$t0, $zero, %x
	printInt($t0)
	add	$t1, $zero, %y
	printInt(%x)
	printInt(%y)
	printChar(' ')
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

.macro drawVerticalLine(%x, %yStart, %yEnd, %color)
	pushStack($t0)
	pushStack($t1)
	
	# init
	add	$t1, $zero, %yStart
	
	LoopDVL:
		# draw pixel
		drawPixel(%x,$t1, %color)
		# increase y
		addi	$t1, $t1, 1
		# condition loop
		blt	$t1, %yEnd, LoopDVL
	popStack($t1)
	popStack($t0)
.end_macro

.macro drawRectangle(%x1, %y1, %x2, %y2, %color)
	drawHorizontalLine(%x1,%y1,%x2,%color)
	drawHorizontalLine(%x1,%y2,%x2,%color)
	drawVerticalLine(%x1, %y1, %y2, %color)
	drawVerticalLine(%x2, %y1, %y2, %color)
.end_macro

.macro drawCircle(%x,%y,%radius,%color)
	
	pushStack($s0)
	pushStack($s1)
	pushStack($s2)
	pushStack($s3)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($t4)
	pushStack($t5)
	pushStack($t6)
	pushStack($t7)
	pushStack($t8)
	pushStack($t9)
    
    	#Init
    	add $s0,$zero,%x
	add $s1,$zero,%y
	add $s3,$zero,%radius
	
 
   	move $t0, $s0            #x0
   	move $t1, $s1            #y0
   	move $t2, $s3            #radius
   	addi $t3, $t2, -1            #x
   	li   $t4, 0              #y
   	li   $t5, 1              #dx
   	li   $t6, 1              #dy
   	li   $t7, 0              #Err

   	#CALCULATE ERR (dx - (radius << 1))
   	sll  $t8, $t2, 1         #Bitshift radius left 1 
   	subu $t7, $t5, $t8           #Subtract dx - shifted radius 

   	#While(x >= y)
    	circleLoop:
    	blt  $t3, $t4, skipCircleLoop    #If x < y, skip circleLoop

    	#Draw Pixel (x0 + x, y0 + y)
    	addu $s0, $t0, $t3
    	addu $s1, $t1, $t4
    	drawPixel($s0,$s1,%color)

        #Draw Pixel (x0 + y, y0 + x)
        addu $s0, $t0, $t4
        addu $s1, $t1, $t3
       	drawPixel($s0,$s1,%color)            

        #Draw Pixel (x0 - y, y0 + x)
        subu $s0, $t0, $t4
        addu $s1, $t1, $t3
        drawPixel($s0,$s1,%color)           

        #Draw Pixel (x0 - x, y0 + y)
        subu $s0, $t0, $t3
        addu $s1, $t1, $t4
      	drawPixel($s0,$s1,%color)         

        #Draw Pixel (x0 - x, y0 - y)
        subu $s0, $t0, $t3
        subu $s1, $t1, $t4
      	drawPixel($s0,$s1,%color)           

        #Draw Pixel (x0 - y, y0 - x)
        subu $s0, $t0, $t4
        subu $s1, $t1, $t3
       	drawPixel($s0,$s1,%color)           

        #Draw Pixel (x0 + y, y0 - x)
        addu $s0, $t0, $t4
        subu $s1, $t1, $t3
      	drawPixel($s0,$s1,%color)           #Jump to drawDot

        #Draw Pixel (x0 + x, y0 - y)
        addu $s0, $t0, $t3
        subu $s1, $t1, $t4
       	drawPixel($s0,$s1,%color)           #Jump to drawDot

    	#If (err <= 0)
   	bgtz $t7, doElse
   	addi $t4, $t4, 1     #y++
   	addu $t7, $t7, $t6       #err += dy
    	addi $t6, $t6, 2     #dy += 2
    	j    circleContinue      #Skip else stmt

    	#Else If (err > 0)
    	doElse:
    	addi  $t3, $t3, -1        #x--
    	addi  $t5, $t5, 2     #dx += 2
    	sll   $t8, $t2, 1     #Bitshift radius left 1 
    	subu  $t9, $t5, $t8       #Subtract dx - shifted radius 
    	addu  $t7, $t7, $t9       #err += $t9

    	circleContinue:
    	#LOOP
    	j   circleLoop

    	#CONTINUE
    	skipCircleLoop:     

    	popStack($t9)
	popStack($t8)
	popStack($t7)
	popStack($t6)
	popStack($t5)
	popStack($t4)
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
    	popStack($s3)
   	popStack($s2)
    	popStack($s1)
   	popStack($s0)
	
	
.end_macro

.macro DrawGallows(%num)
	pushStack($t0)
	pushStack($s0)
	pushStack($s1)
	pushStack($s2)
	pushStack($s3)
	pushStack($s4)
	pushStack($t9)
	
	#Init
	add $t0,$zero,%num
	
	DrawGallowsSC:
	beq $s0,1,DrawGallows_1
	beq $s0,2,DrawGallows_2
	beq $s0,3,DrawGallows_3
	beq $s0,4,DrawGallows_4
	beq $s0,5,DrawGallows_5
	beq $s0,6,DrawGallows_6
	beq $s0,7,DrawGallows_7
	j EndDrawGallows
	
	DrawGallows_1:
		li $s0,10
		li $s1,40
		li $s2,120
		li $t9, 0x00FFFF00
		drawHorizontalLine($s0, $s2, $s1, $t9)	
	
		li $s0,20
		li $s1,30
		li $s2,20
		li $s3,120
		drawRectangle($s0,$s2,$s1,$s3,$t9)
		
		li $t9, 0x00FF00FF
		li $s0,30
		li $s1,65
		li $s2,20
		drawHorizontalLine($s0, $s2, $s1, $t9)
		#Cape
		li $s0,65
		li $s1,20
		li $s2,30
		drawVerticalLine($s0,$s1,$s2,$t9)
		j EndDrawGallows
	DrawGallows_2:
	#Head
		li $t9, 0x00FFFFFF
		li $s0,65
		li $s1,40
		li $s2,10
		drawCircle($s0,$s1,$s2,$t9)
		li $t9, 0x00FFFFFF
		#left eye
		li $s3,60
		li $s4,40
		drawPixel($s3,$s4,$t9)
		#right eye
		li $s3,70
		li $s4,40
		drawPixel($s3,$s4,$t9)
		#Mouth
		li $s0,62
		li $s1,68
		li $s2,45
		drawHorizontalLine($s0, $s2, $s1, $t9)
		
		j EndDrawGallows
	DrawGallows_3:
		#Body
		li $t9, 0x00FFFFFF
		li $s0,65
		li $s1,50
		li $s2,80
		drawVerticalLine($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	DrawGallows_4:
		#rhand
		li $s0,65
		li $s1,55
		li $s2,13
		li $t9, 0x00FFFFFF
		
		drawlefttorightdiagonal($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	DrawGallows_5:
		#lhand
		li $s0,65
		li $s1,55
		li $s2,13
		li $t9, 0x00FFFFFF
		drawrighttoleftdiagonal($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	DrawGallows_6:
		#rleg
		li $s0,65
		li $s1,80
		li $s2,15
		li $t9, 0x00FFFFFF
		drawlefttorightdiagonal($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	DrawGallows_7:
		#lleg
		li $s0,65
		li $s1,80
		li $s2,15
		li $t9, 0x00FFFFFF
		drawrighttoleftdiagonal($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	EndDrawGallows:
	popStack($t9)
	popStack($s4)
	popStack($s3)
	popStack($s2)
	popStack($s1)
	popStack($s0)
	popStack($t0)
.end_macro
.macro drawlefttorightdiagonal(%x,%y,%length,%color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	
	
	#Init
	add $t0,$zero,%x
	add $t1,$zero,%y
	
	li $t2,0
	looplDrawlrdia:
		drawPixel($t0,$t1,%color)
		# increase x
		addi $t0,$t0,1
		
		# increase y
		addi $t1,$t1,1
		
		#Condition loop
		addi $t2,$t2,1
		blt	$t2,%length,looplDrawlrdia
		
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
	
.end_macro

.macro drawrighttoleftdiagonal(%x,%y,%length,%color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	
	add $t0,$zero,%x
	add $t1,$zero,%y
	
	li $t2,0
	looplDrawrldia:
		
		drawPixel($t0,$t1,%color)
		
		#decrease x
		addi $t0,$t0,-1
		
		# increase y
		addi $t1,$t1,1
		
		#Condition loop
		addi $t2,$t2,1
		blt	$t2,%length,looplDrawrldia
	
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
	
.end_macro
