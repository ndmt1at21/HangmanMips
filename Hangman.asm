.include "CommonFunc.asm"
.include "FileIO.asm"
.include "Graphics.asm"
.include "Random.asm"

.data
	helloGame:	.asciiz 	"Xin chao ban den voi game Hangman"
	str:		.space		10
.text
main:
	li	$t0, 0
	la	$t1, str
	Loop:
		getline($t1, '*')
		printString($t1)
		printChar('\n')
		addi	$t0, $t0, 1
		blt $t0, 25, Loop
