.extern CardStatus 16
.extern RandomizedBoard 96
.extern RemainingTiles 16

.data
line: .asciiz "|---|---|---|---|\n"    # Row border
row: .asciiz "|"                  # Vertical separator
unknown: .asciiz " ? "          # unknown value
newline: .asciiz "\n"          

.text
.globl display_board

display_board:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Print top border
    li $v0, 4
    la $a0, line
    syscall

    # Initialize loop counters
    li $t0, 0         
    li $t1, 4          

row_display:
    # Print left border
    li $v0, 4
    la $a0, row
    syscall

    # Process cards in the current row
    li $t2, 0          

column_display:
    # Load card status directly
    la $t3, CardStatus
    add $t4, $t3, $t0
    lb $t5, 0($t4)     # $t5 = CardStatus[t0]
    

    # If status = 1 show the card
    bnez $t5, show_card

    # If status = 0 print the ?
    li $v0, 4
    la $a0, unknown
    syscall
    j print_format

show_card:
    # Print the card value
    la $t6, fVals
    sll $t7, $t0, 2    
    add $t6, $t6, $t7  
    lw $a0, 0($t6)      
    li $v0, 4
    syscall

print_format:
    # Print vertical separator
    li $v0, 4
    la $a0, row
    syscall

    # Increment counters
    addi $t0, $t0, 1     
    addi $t2, $t2, 1     
    blt $t2, $t1, column_display

    li $v0, 4
    la $a0, newline
    syscall

    # Print horizontal line 
    li $v0, 4
    la $a0, line
    syscall

    # Check if all cards have been processed
    li $t3, 16           # Total number of cards
    blt $t0, $t3, row_display

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
