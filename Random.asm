# rand(size).      
# Size = $t7
# $a2 save selected random number
# $t1 save size curent
# number random return default $a0

.data 
      array: .word 0:100 # int array[100].save selected random number.
      sizecurent:.word    # size of array selected random number
.text main:
.macro RanDom_int(%size)
#khoi tao
add $t7,$0,%size    #li $t7,size   #t7 save size 
li $t1,0            # khoi tao t1
#Check size <=100
 la $t1,sizecurent            
 li $t2,101            # t2 dung de so sanh 
 slt $t2,$t7,$t2
 blez $t2,resize                # Check $t2=0 <-> size >100
 
 j RanDom
resize:             # if (size) >100 -> size =100
li $t7,100

RanDom:        
la $a2,array          
move $a1,$t7       #Range set from 0 to size(size max =100)
li $v0,42          #generates random number and put it in $a0
syscall

#check
li $t0,0 ##int count =0
check:
          lw $t1,sizecurent
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
addi $t1,$t1, 1

li $v0,1
syscall

sw $t1,sizecurent  # update size curent
#Check full
beq $t1,$t7,End
j end_marco
End:
li $v0,10
syscall
end_marco:
.end_macro
