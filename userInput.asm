.extern CardStatus 16
.extern flipped 16
.data
prompt_select: .asciiz "\nEnter a tile number (1-16): "
invalid_msg: .asciiz "\nInvalid input! Please select a number between 1 and 16.\n"
debug_msg: .asciiz "\nDebug: Value of $t0 is: "
debug_valid: .asciiz "\nDebug: Input is valid.\n"
debug_invalid: .asciiz "\nDebug: Input is invalid.\n"
debug_retry: .asciiz "\nDebug: Retrying input after invalid selection.\n"
debug_validate_selection: .asciiz "\nDebug: validate_selection returned: "
matched: .asciiz "\nYou have already picked this card. Try again!\n"
same: .asciiz "\n You picked the same card. Try again!"
currentCard:   .asciiz "Current card :"
newLine: .asciiz "\n"


.text
.globl get_tile_selection, validate_selection


get_tile_selection:
    li $v0, 4                
    la $a0, prompt_select    
    syscall

    li $v0, 5                # Read integer 
    syscall
    move $t0, $v0            # Store user input in $t0
   
    
    # Validate the input
    blt $t0, 1, invalid_input
    bgt $t0, 16, invalid_input
    
    # Check if same card selected
    beq $t0, $t1, sameCard
    
    # Check if card is already matched
    addi $t3, $t1, -1
    la $t4, flipped
    add $t4, $t4, $t3
    lb $t5, 0($t4)
    bnez $t5, alreadyMatched
    
    beqz $v0, invalid_input  

    
    # Display first card selection
    li $v0, 4
    la $a0, currentCard
    syscall
    li $v0, 1
    move $a0, $t0
    
    # Display first card value
    addi $t3, $t0, -1
    la $t4, fVals
    sll $t5, $t3, 2
    add $t4, $t4, $t5
    lw $a0, 0($t4)
    li $v0, 4
    syscall
    
    li $v0, 4
    la $a0, newLine
    syscall
    

    jr $ra
		

#erroring currently
validate_selection:

    blt $t0, 1, invalid_input
    bgt $t0, 16, invalid_input
    
    # Check if same card selected
    beq $t0, $t1, sameCard
    
    # Check if card is already matched
    la $t3, CardStatus       
    add $t4, $t3, $t0        
    lb $t5, 0($t4)          
    bnez $t5, alreadyMatched

    jr $ra                   # Return to caller
    
invalid_input:
    lw $t0, 0($sp)
    addi $sp, $sp, 4

    li $v0, 4                # Print string syscall
    la $a0, invalid_msg      # Load the invalid input message
    syscall
    j get_tile_selection     # Retry input
    
alreadyMatched:
    li $v0, 4
    la $a0, matched
    syscall
    j get_tile_selection
    
sameCard:
    li $v0, 4
    la $a0, same
    syscall
    j get_tile_selection

