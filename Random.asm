# rand(size).      
# Size = $t7
# $a2 save selected random number
# $t1 save size curent
# number random return default $a0

.data 
      array: .word 0:100 # int array[100].save selected random number.
.text main:


#khoi tao
li $t7,3    #t7 save size .Example :size = 3

#Check size <=100
 li $t1,101
 slt $t1,$t7,$t1
 blez $t1,resize                # Check $t1=0 ?
 addi $t1,$zero,0         #$t1 save size of array curent
 j RanDom
resize:
li $t7,100

RanDom:
la $a2,array

move $a1,$t7 #Range set from 0 to size(size max =100)
li $v0,42 #generates random number and put it in $a0
syscall

#check
li $t0,0 ##int count =0
check:
          beq $t0,$t1,ExitLoop
          lw $a3,($a2)
          bne $a0,$a3,incre
          j RanDom
           # Neu khong trung thi tang cac gia tri & check tiep
          incre:
          addi $a2,$a2,4
          addi $t0,$t0,1
          j check

#a1 save ramdom number
ExitLoop:
li $t2,4
mult $t2,$t0
mflo $t2
sw $a0,($a2)   # save -> (a$2)
sub $a2,$a2,$t2   # $a2 = $a2- 4*($t0)

#increase index
addi $t1, $t1, 1

#Check full
beq $t1,$t7,End

End:
li $v0,10
syscall









