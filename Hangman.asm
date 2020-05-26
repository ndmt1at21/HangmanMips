.include "CommonFunc.asm"
.include "FileIO.asm"
.include "Graphics.asm"
.include "Random.asm"

.data
	helloGame:		.asciiz 	"Xin chao ban den voi game Hangman"
	askPlayerName:		.asciiz		"Vui long nhap ten nguoi choi"
	askInputChar:		.asciiz		"Nhap ky tu ban cho rang xuat hien"
	askInputWord:		.asciiz		"Tu ban doan la gi nao?"
	askStatusGame:		.asciiz 	"Ban co muon tiep tuc tro choi?"
	chooseGuessWord:	.asciiz		"Ban muon doan ca tu khong?"
	notiLostGame:		.asciiz		"Ban da bi treo co =))"
	notiRightWord:		.asciiz 	"Chinh xac!!! Ban gioi qua ^^"
	notiWrongChar:		.asciiz		"Ban da doan sai ky tu roi :("
	hiddenWord:		.space		11
	guessWord:		.space		11
	guessChar:		.space		1
	tempStr:		.space		5
	playerName:		.space		21
	playerScore:		.word		0
	playerStatus:		.byte		0
	resetGame:		.byte		0
	dictionary:		.asciiz 	"D:/Assembly/HangmanMips/dictionary.txt"
	dataPlayer:		.asciiz		"D:/Assembly/HangmanMips/nguoichoi.txt"
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
	# get hidden word
	la	$a0, hiddenWord
	getline($a0, '*', dictionary)
	printString($a0)
	
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
		sb	$zero, playerStatus
		lw	$a0, playerScore
		
		# inc score
		strlen($a1)
		add	$a0, $a0, $v0
		
		# continue game
		j LoopHangmanGame
			
	GuessWordWrong:
		# save infor player 
		
		# status player = 7
		li	$a0, 7
		sb	$a0, playerStatus
		
		# show over screen
		j	_GameOver
		
_GameOver:
		# draw man
		jal 	_DrawPlayerStatus
		
		# notifi game over
		la	$a0, notiLostGame
		showMsgBox($a0, 0)
		
		# reset para
		sb	$zero, playerStatus
		sw	$zero, playerScore
		
		# ask continue
		la	$a0, askStatusGame
		showConfirmBox($a0)
		
		beq	$v0, 0, LoopHangmanGame
		j	_Top10Player	
	
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
		
		# show wrong answer 
		la	$a0, notiWrongChar
		showMsgBox($a0, 0)
		
		# draw status
		jal	_DrawPlayerStatus
	
		# jump to Loop Guess One word
		j	LoopGuessOneWord
		
	CharInHidden:
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
