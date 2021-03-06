# rand(size).      
# Size = $t7
# $a2 save selected random number
# $t1 save size curent
# number random return default $v0
.data 
      array: .word 0:100 # int array[100].save selected random number.

      sizecurent:.word 0:100    # size of array selected random number

.macro RanDom_int(%size)
        pushStack($t7)
        pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($a0)
	pushStack($a1)
	pushStack($a2)
	pushStack($a3)

        #khoi tao
        add $t7,$0,%size               #li $t7,size   #t7 save size 
        la $t1,sizecurent   
        lw $t1,sizecurent
          #Check size <=100
        li $t2,101                      # t2 dung de so sanh 
        slt $t2,$t7,$t2
        blez $t2,resize                # Check $t2=0 <-> size >100
 
         j RanDom
resize:                       # if (size) >100 -> size =100
         li $t7,100

RanDom:        
          la $a2,array          
          move $a1,$t7       #Range set from 0 to size(size max =100)
          li $v0,42          #generates random number and put it in $a0
          syscall

          beq $t1,$t7,End           #Check full
          li $t0,0 ##int count =0
        
       
check:                           #check
          beq $t0,$t1,ExitLoop
          lw $a3,0($a2)
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
         addi $t1,$t1,1
         sw $t1,sizecurent
         
         move $v0,$a0  # save $v0
         j end_marco
End:
         li $v0,10
          syscall
end_marco:
	popStack($a3)
	popStack($a2)
	popStack($a1)
	popStack($a0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
        popStack($t7)	
.end_macro
