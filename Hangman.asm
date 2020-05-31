.include "CommonFunc.asm"
.include "FileIO.asm"
.include "Graphics.asm"
.include "Random.asm"

# max length hidden word: 10
.data
	helloGame:		.asciiz 	"Xin chao ban den voi game Hangman"
	askPlayerName:		.asciiz		"Vui long nhap ten nguoi choi"
	askInputChar:		.asciiz		"Nhap ky tu ban cho rang xuat hien"
	askInputWord:		.asciiz		"Tu ban doan la gi nao?"
	askStatusGame:		.asciiz 	"Ban co muon tiep tuc tro choi?"
	chooseGuessWord:	.asciiz		"Ban muon doan ca tu khong?"
	notiLostGame:		.asciiz		"Ban da bi treo co o_o"
	notiRightWord:		.asciiz 	"Chinh xac!!! Ban gioi qua ^^"
	notiWrongChar:		.asciiz		"Ban da doan sai ky tu roi :("
	hiddenWord:		.space		12
	guessWord:		.space		12
	guessChar:		.space		4
	tempStr:		.space		48
	playerName:		.space		24
	playerScore:		.word		0
	playerWord:		.word		0
	playerStatus:		.word		0
	
	allPlayerNameBuff:	.space		528	# 20 bytes / 1 player -> ~ 25 player
	allPlayerNamePtr:	.space		112	# ptr contains address string name player
	allPlayerScore:		.space		112	# 25 player * 4 bytes
	allPlayerWord:		.space		112	# 25 plyer * 1 bytes
	numPlayer:		.byte		0
	dictionary:		.asciiz 	"dictionary.txt"
	dataPlayer:		.asciiz		"nguoichoi.txt"
	notiName:		.asciiz		"Name\t"
	notiScore:		.asciiz		"Score\t"
	notiWord:		.asciiz		"Num word\n"
.text
main:
	# intro game
	la	$a0, helloGame
	showMsgBox($a0, 1)
	
	# input player name
	InputPlayerName:
		la	$a0, askPlayerName
		la	$a1, playerName
		inputMsgBox($a0, $a1, 20)
		isalnum($a1)
		beq	$v0, 0, InputPlayerName
	
LoopHangmanGame:
	li	$a0, 0
	li	$a1, 0
	LoopYClearScreen:
		LoopXClearScreen:
			drawPixel($a0, $a1, 0x00000000)
			addi	$a0, $a0, 1
			blt	$a0, 128, LoopXClearScreen
		li	$a0, 0
		addi	$a1, $a1, 1
		blt	$a1, 128, LoopYClearScreen
	
	# get hidden word
	la	$a0, hiddenWord
	RanDom_int(25)
	move	$s0, $v0
	getline($s0, $a0, '*', dictionary)
	
	# init guess word
	strlen($a0)
	move	$t0, $v0
	la	$a0, guessWord 
	initString($a0, '@', $t0)
			
	LoopGuessOneWord:
		# show guess word
		la	$a0, guessWord
		showMsgBox($a0, 1)
		
		# choose way guess word
		la	$a0, chooseGuessWord
		showConfirmBox($a0)
		move	$a0, $v0
		beq	$a0, 0, InputGuessOneWord
		beq	$a0, 1, InputGuessOneChar
		j	InputGuessOneWord
		
		InputGuessOneWord:
			la	$a0, askInputWord
			la	$a1, guessWord
			inputMsgBox($a0, $a1, 10)
		j	_CheckGuessWord
		
		InputGuessOneChar:
			la	$a0, askInputChar
			la	$a1, tempStr
			inputMsgBox($a0, $a1, 5)
			lb	$a0, 0($a1) # guess char
			sb	$a0, guessChar
		j	_CheckGuessChar
			
		
_CheckGuessWord:
	la	$a0, hiddenWord
	la	$a1, guessWord
	
	# compare hidden & guesss
	strcmp($a0, $a1)
	beq	$v0, 1, GuessWordRight 
	j 	GuessWordWrong
		
	GuessWordRight:
		# play success sound
		li	$v0, 31
		li	$a0, 72
		li	$a1, 1000
		li	$a2, 12
		li	$a3, 127
		syscall
		
		# noti right word
		la	$a0, notiRightWord
		showMsgBox($a0, 1)
		
		# reset status
		sb	$zero, playerStatus
		
		# inc score
		lw	$a0, playerScore
		la	$a1, hiddenWord
		strlen($a1)
		add	$a0, $a0, $v0
		sw	$a0, playerScore
		
		# inc num right word
		lb	$a0, playerWord
		addi	$a0, $a0, 1
		sb	$a0, playerWord
		
		# continue game
		j LoopHangmanGame
			
	GuessWordWrong:
		# save infor player 
		la	$a0, playerName
		saveString($a0, 1, dataPlayer)
		saveChar('-', 1, dataPlayer)
		
		lw	$a0, playerScore
		la	$a1, tempStr
		toString($a1, $a0)
		saveString($a1, 1, dataPlayer)
		saveChar('-', 1, dataPlayer)
		
		lw	$a0, playerWord
		toString($a1, $a0)
		saveString($a1, 1, dataPlayer)
		saveChar('*', 1, dataPlayer)
		
		# status player = 7
		li	$a0, 7
		sb	$a0, playerStatus
		
		# show over screen
		j	_GameOver
		
_GameOver:
		# play sound game over
		li $v0, 31
		li $a0, 5
		li $a1, 2000
		li $a2, 0
		li $a3, 127	
		syscall	
		
		# draw man
		jal 	_DrawPlayerStatus
		
		# notifi game over
		la	$a0, notiLostGame
		showMsgBox($a0, 0)
		
		# show infor player
		printConstString(" Player's infor\n")
		la	$a0, notiName
		la	$a1, notiScore
		la	$a2, notiWord
		printString($a0)
		printString($a1)
		printString($a2)
		
		la	$a0, playerName
		lw	$a1, playerScore
		lw	$a2, playerWord
		printString($a0)
		printChar('\t')
		printInt($a1)
		printChar('\t')
		printInt($a2)
		printChar('\n')
		
		# reset para
		sb	$zero, playerStatus
		sw	$zero, playerScore
		
		# ask continue
		la	$a0, askStatusGame
		showConfirmBox($a0)
		
		beq	$v0, 0, LoopHangmanGame
		j	_Top10Player	
		
		ContinueGame:
			# clear screen
			addi	$a0, $gp, 1024
			move	$a1, $gp
			
			drawPixel(100, 100, 0x00FF0000)
				
			EndClearScreen:
			j 	LoopHangmanGame
		
	
_CheckGuessChar:
	# check if full char filled, compare with hidden word
	la	$a0, hiddenWord
	la	$a1, guessWord

	strFind($a1, 0, '@')
	beq	$v0, -1, _CheckGuessWord
	  
	# check hidden word contain guessChar
	lb	$a0, guessChar
	la	$a1, hiddenWord
	strFind($a1, 0, $a0)
	
	beq	$v0, -1, CharNotInHidden 
	j	CharInHidden
	
	CharNotInHidden:
		lb	$a0, playerStatus
		addi	$a0, $a0, 1
		sb	$a0, playerStatus
		
		# check status player
		beq	$a0, 7, _GameOver
		
		# play sound
		li $v0, 31
		li $a0, 60	# pitch, C#
		li $a1, 500	#duration in milisecond
		li $a2, 111	#instrument (0 - 7 piano)
		li $a3, 127	#volume
		syscall
		
		# show wrong answer 
		la	$a0, notiWrongChar
		showMsgBox($a0, 0)
		
		# draw status
		jal	_DrawPlayerStatus
	
		# jump to Loop Guess One word
		j	LoopGuessOneWord
		
	CharInHidden:
		# play success sound
		li	$v0, 31
		li	$a0, 72
		li	$a1, 500
		li	$a2, 12
		li	$a3, 127
		syscall
		
		la	$a0, guessWord
		lb	$a1, guessChar
		la	$a2, hiddenWord
		li	$t0, -1

		
		LoopFillChar:
			# posStartFind = prevPos + 1
			addi	$t0, $t0, 1
			
			# find pos char in hideen word 
			strFind($a2, $t0, $a1)
			move	$t0, $v0
			
			# save to guessWord
			add	$a0, $a0, $t0
			sb	$a1, ($a0)
			sub	$a0, $a0, $t0
			
			# condition loop
			bne	$t0, -1, LoopFillChar
			
		
		j	LoopGuessOneWord
			
_DrawPlayerStatus:
	pushStack($ra)
	pushStack($t0)

	lb	$t0, playerStatus
	beq	$t0, 1, draw1
	beq	$t0, 2, draw2
	beq	$t0, 3, draw3
	beq	$t0, 4, draw4
	beq	$t0, 5, draw5
	beq	$t0, 6, draw6
	beq	$t0, 7, draw7
	j 	EndDraw
	
	draw7:  DrawGallows(7)
	draw6:  DrawGallows(6)
	draw5:  DrawGallows(5)
	draw4:  DrawGallows(4)
	draw3:  DrawGallows(3)
	draw2:  DrawGallows(2)
	draw1:  DrawGallows(1)
	
	EndDraw:
	
	popStack($t0)
	popStack($ra)
	
	jr	$ra
	
_Top10Player:
	# load data
	li	$s1, 0
	la	$a0, tempStr
	la	$a1, allPlayerNameBuff
	la	$a2, allPlayerScore
	la	$a3, allPlayerWord
	la	$s0, allPlayerNamePtr
	
	# read from file
	LoopReadDataPlayer:
		# get data 1 player
		getline($s1, $a0, '*', dataPlayer)
		beq	$v0, -1, EndLoopReadDataPlayer
		
		# get name player
		getstr($a1, $a0, '-', 0)
		sw	$a1, ($s0)
		addi	$a1, $a1, 21
		addi	$s0, $s0, 4
		
		# get score
		getstr($a2, $a0, '-', 1)
		toInt($a2)
		sw	$v0, ($a2)
		addi	$a2, $a2, 4
		
		# get num word
		getstr($a3, $a0, '-', 2)
		toInt($a3)
		sw	$v0, ($a3)
		addi	$a3, $a3, 4
		
		# inc number player
		addi	$s1, $s1, 1
		
		# condition loop
		beq	$zero, $zero, LoopReadDataPlayer
		
	EndLoopReadDataPlayer:
		sb	$s1, numPlayer

	# sort 
	la	$a0, allPlayerNamePtr
	la	$a1, allPlayerScore
	la	$a2, allPlayerWord
	
	li	$t0, 0 # i
	li	$t1, 0 # j
	li	$t2, 0 # max_index
	lb	$t3, numPlayer
	li	$t4, 0 # address arr[j]
	li	$t5, 0 # address arr[min_index]
	li	$t6, 4 # for x4
	li	$s0, 0
	li	$s1, 0
	li	$s2, 0
	
	LoopForI:
		move	$t2, $t0
		bge	$t0, $t3, EndLoopForI
		
		move	$t1, $t0
		LoopForJ:
			# codition break
			bge	$t1, $t3, EndLoopForJ 
			
			# cal address element in array
			mult	$t1, $t6
			mflo	$t4
			
			mult	$t2, $t6
			mflo	$t5
			
			# compare and change min_index
			add	$a1, $a1, $t4
			lw	$s0, ($a1)
			sub	$a1, $a1, $t4
			
			add	$a1, $a1, $t5
			lw	$s1, ($a1)
			sub 	$a1, $a1, $t5
		
			bgt 	$s0, $s1, ChangeMaxIndex 
			j 	IncreaseJ
			
			ChangeMaxIndex:
				move	$t2, $t1
				
			IncreaseJ:
				addi	$t1, $t1, 1
				
			beq	$zero, $zero, LoopForJ
		EndLoopForJ:

		# swap
		mult	$t2, $t6
		mflo	$t4
		
		mult	$t0, $t6
		mflo	$t5
		
		# swap name
		add	$a0, $a0, $t4
		lw	$s0, ($a0)
		sub	$a0, $a0, $t4
		
		add	$a0, $a0, $t5
		lw	$s1, ($a0)
		sub	$a0, $a0, $t5
		
		swap($s0, $s1)
		
		add	$a0, $a0, $t4
		sw	$s0, ($a0)
		sub	$a0, $a0, $t4
		
		add	$a0, $a0, $t5
		sw	$s1, ($a0)
		sub	$a0, $a0, $t5
		
		# swap score
		add	$a1, $a1, $t4
		lw	$s0, ($a1)
		sub	$a1, $a1, $t4
		
		add	$a1, $a1, $t5
		lw	$s1, ($a1)
		sub	$a1, $a1, $t5
		
		swap($s0, $s1)
		
		add	$a1, $a1, $t4
		sw	$s0, ($a1)
		sub	$a1, $a1, $t4
		
		add	$a1, $a1, $t5
		sw	$s1, ($a1)
		sub	$a1, $a1, $t5
		
		# swap num word
		add	$a2, $a2, $t4
		lw	$s0, ($a2)
		sub	$a2, $a2, $t4
		
		add	$a2, $a2, $t5
		lw	$s1, ($a2)
		sub	$a2, $a2, $t5
		
		swap($s0, $s1)
		
		add	$a2, $a2, $t4
		sw	$s0, ($a2)
		sub	$a2, $a2, $t4
		
		add	$a2, $a2, $t5
		sw	$s1, ($a2)
		sub	$a2, $a2, $t5
		
		# inc i
		addi	$t0, $t0, 1
		
		beq	$zero, $zero, LoopForI
	EndLoopForI:		
	
	# print header
	printConstString("\nTop 10 Player\n")
	la	$a0, notiName
	la	$a1, notiScore
	la	$a2, notiWord

	printString($a0)
	printString($a1)
	printString($a2)
	
	# print top 10 player
	li	$t0, 0
	lb	$t1, numPlayer
	la	$a0, allPlayerNamePtr
	la	$a1, allPlayerScore
	la	$a2, allPlayerWord
	
	bgt	$t1, 10, Assign10
	j 	LoopPrintTop10
	
	Assign10:
		li	$t1, 10

	LoopPrintTop10:
		# load data
		lw	$s0, ($a0)
		lw	$s1, ($a1)
		lw	$s2, ($a2)
		
		# print data
		printString($s0)
		printChar('\t')
		printInt($s1)
		printChar('\t')
		printInt($s2)
		printChar('\n')
		
		# increase address
		addi	$a0, $a0, 4
		addi	$a1, $a1, 4
		addi	$a2, $a2, 4
		
		# inc count
		addi 	$t0, $t0, 1
		
		# condition loop
		blt	$t0, $t1, LoopPrintTop10
