.include "CommonFunc.asm"
.include "FileIO.asm"
.include "Graphics.asm"
.include "Random.asm"

.macro top10Player()
	
.end_macro

.macro increaseScore(%score)
	pushStack($t0)
	
	lw	$t0, playerScore
	add	$t0, $t0, %score
	
	popStack($t0)
.end_macro


.macro checkResult(%guessStr)
	pushStack($s0)
	pushStack($s1)
	
	move	$s0, %guessStr
	la	$s1, hiddenWord
	strcmp($s0, $s1)
	
	move	$s0, $v0
	beq	$s0, 1, RightResult
	j WrongResult
	
	RightResult:
		li	$v0, 1
		j EndCheckResult
	
	WrongResult:
		li	$v0, 0
		j EndCheckResult
		
	EndCheckResult:
	
	popStack($s1)
	popStack($s0)
.end_macro

.data
	helloGame:		.asciiz 	"Xin chao ban den voi game Hangman"
	askPlayerName:		.asciiz		"Vui long nhap ten nguoi choi"
	askInputChar:		.asciiz		"Nhap ky tu ban cho rang xuat hien"
	askInputWord:		.asciiz		"Tu ban doan la gi nao?"
	askStatusGame:		.asciiz 	"Ban co muon tiep tuc tro choi?"
	chooseGuessWord:	.asciiz		"Ban muon doan ca tu khong?"
	hiddenWord:		.space		11
	guessWord:		.space		11
	guessChar:		.space		1
	tempStr:		.space		5
	playerName:		.space		21
	playerScore:		.word		0
	playerStatus:		.byte		0
	resetGame:		.byte		0
	
.text
main:
	# intro game
	la	$a0, helloGame
	showMsgBox($a0, 1)
	
	# input player name
	InputPlayerName:
		la	$a0, askPlayerName
		la	$a1, playerName
		inputMsgBox($a0, $a1, 10)
		isalnum($a1)
		beq	$v0, 0, InputPlayerName
	
LoopHangmanGame:
	# get hidden word
	la	$a0, hiddenWord
	getline($a0, '*')
	
	# init guess word
	printString($a0)
	strlen($a0)
	move	$t0, $v0
	la	$a0, guessWord 
	printInt($t0)
	initString($a0, '@', $t0)
	
	# check reset game
	lb	$a0, resetGame
	beq	$a0, $zero, ResetWordAndPara
	
	ResetWordAndPara:
		sw	$zero, playerScore
		sb	$zero, playerStatus
		sb	$zero, resetGame
			
			
	LoopGuessOneWord:
		# show guess word
		la	$a0, guessWord
		showMsgBox($a0, 1)
		
		GuessOneWord:
			# input word 
			la	$a0, askInputWord
			la	$a1, guessWord
			inputMsgBox($a0, $a1, 10)
				
		GuessOneChar:
			la	$a0, askInputChar
			la	$a1, tempStr
			inputMsgBox($a0, $a1, 1)
			lb	$a0, 0($a1) # guess char
			sb	$a0, guessChar
		
				
		CheckResult:
			lb	$a0, playerStatus
			beq	$a0, 7, GameOverScreen
				
		GameOverScreen: