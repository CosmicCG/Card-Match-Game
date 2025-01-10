.data
welcome_msg: .asciiz "\nWelcome to the Math-Match Game: Multiply Easy!\n\n"
instructions: .asciiz "Match multiplication problems with their correct answers.\nSelect two tiles to see if they match.\n\n"
prompt_restart: .asciiz "\nPlay again? (1 = Yes, 0 = No): "
goodbye_msg: .asciiz "\nThanks for playing! Goodbye!\n"
MatchMsg: .asciiz "\nYou found a match! Great job!\n"
MismatchMsg: .asciiz "\nNo match! Try again!\n"
GameCompleteMsg: .asciiz "\nCongratulations! You've matched all the tiles and completed the game!\n"



.text
.globl main, post_turn

main:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Print the welcome message
    li $v0, 4
    la $a0, welcome_msg
    syscall

    # Print the instructions
    li $v0, 4
    la $a0, instructions
    syscall

    # Initialize the game
    jal initialize_Game

    # Display the initial board
    jal display_board

game_loop:
    jal get_tile_selection
    move $s0, $v0         # Store the first selection in $s0
    
    
    jal get_tile_selection
    move $s1, $v0         # Store the second selection in $s1
    
    
    # Check if the tiles match
    move $a0, $s0
    move $a1, $s1
    jal check_match

    # Handle match or mismatch
    beq $v0, 1, match_found
    j mismatch

match_found:
    # Reveal matched cards
    li $v0, 4
    la $a0, MatchMsg      
    syscall
    j post_turn

mismatch:
    # Handle mismatched cards
    li $v0, 4
    la $a0, MismatchMsg   
    syscall

post_turn:
    # Display the updated board
    jal display_board

    # Check if the game is complete
    jal is_game_complete
    beq $v0, 1, game_complete

    # Continue the game loop
    j game_loop

game_complete:
    # Print the game completion message
    li $v0, 4
    la $a0, GameCompleteMsg
    syscall

    # Prompt for replay
    li $v0, 4
    la $a0, prompt_restart
    syscall

    li $v0, 5           
    syscall
    beq $v0, 1, main     # Restart game if input is 1

    # Print goodbye message
    li $v0, 4
    la $a0, goodbye_msg
    syscall


    lw $ra, 0($sp)
    addi $sp, $sp, 4

    li $v0, 10           # Exit syscall
    syscall
