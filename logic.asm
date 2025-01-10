.globl fVals
.data
ProblemsArray: .word 6, 12, 20, 5, 42, 72, 15, 9, 12, 100, 40, 16, 81, 14, 64, 1
form1:  .asciiz "2x3"
form2:  .asciiz "3x4"
form3:  .asciiz "4x5"
form4:  .asciiz "5"
form5:  .asciiz "6x7"
form6:  .asciiz "8x9"
form7:  .asciiz "15"
form8:  .asciiz "3x3"
form9:  .asciiz "12"
form10: .asciiz "10x10"
form11: .asciiz "40"
form12: .asciiz "8x2"
form13: .asciiz "9x9"
form14: .asciiz "2x7"
form15: .asciiz "64"
form16: .asciiz "1"
fVals: .word form1, form2, form3, form4, form5, form6, form7, form8, form9, form10, form11, form12, form13, form14, form15, form16
RandomizedBoard: .space 96
CardStatus: .space 16
RemainingTiles: .word 16
flipped: .space 16
GameCompleteMsg: .asciiz "All cards matched! Game complete!\n"
noMatch: .asciiz "The cards dont match."
cardsMatch: .asciiz "The cards match! Good Job!\n"

.text
.globl initialize_Game, check_match, is_game_complete

initialize_Game:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Initialize CardStatus to 0(?)
    la $t0, CardStatus
    li $t1, 16               # Total number of cards
init_card_status:
    beqz $t1, populate_board
    sb $zero, 0($t0)        
    addi $t0, $t0, 1
    addi $t1, $t1, -1
    j init_card_status

populate_board:
    # Populate RandomizedBoard with ProblemsArray data
    la $t0, ProblemsArray
    la $t1, RandomizedBoard
    li $t2, 8                # Total number of problems

populate_loop:
    beqz $t2, finish_initialize

    # Load problem (a, b, product) and store in RandomizedBoard
    lw $t3, 0($t0)           # Operand a
    sw $t3, 0($t1)
    lw $t4, 4($t0)           # Operand b
    sw $t4, 4($t1)
    lw $t5, 8($t0)           # Product
    sw $t5, 8($t1)

    # Increment pointers
    addi $t0, $t0, 12
    addi $t1, $t1, 12
    addi $t2, $t2, -1
    j populate_loop

finish_initialize:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
 	
check_match:
    move $t0, $a0
    move $t1, $a1
    
    # Compare card values
    la $t2, ProblemsArray
    
    sll $t3, $t0, 2    # Multiply index by 4 
    add $t3, $t2, $t3
    lw $t5, 0($t3)     # Load value of first card
    
    sll $t3, $t1, 2    # Multiply index by 4 
    add $t3, $t2, $t3
    lw $t6, 0($t3)     # Load value of second card
    
    beq $t5, $t6, match_found
    
    # Display no match message
    li $v0, 4
    la $a0, noMatch
    syscall

    # Hide cards again
    la $t2, CardStatus
    add $t3, $t2, $t0
    sb $zero, 0($t3)
    add $t3, $t2, $t1
    sb $zero, 0($t3)

    jal post_turn

match_found:
    
    # Mark cards as matched in matches array
    la $t2, flipped
    add $t3, $t2, $t0
    li $t4, 1
    sb $t4, 0($t3)
    add $t3, $t2, $t1
    sb $t4, 0($t3)
    
    la $t2, CardStatus
    add $t3, $t2, $t0
    li $t4, 1
    sb $t4, 0($t3)
    add $t3, $t2, $t1
    sb $t4, 0($t3)
    

    jal post_turn


is_game_complete:
    la $t0, RemainingTiles
    lw $t1, 0($t0)
    bnez $t1, not_complete

    li $v0, 1                # Game complete
    jr $ra

not_complete:
    li $v0, 0                # Game not complete
    jr $ra
