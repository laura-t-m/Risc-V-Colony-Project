.eqv BOARD_SIDE 12
.eqv VISIBLE_SIDE 10
.eqv BOARD_BYTES 144
.eqv CELLS_TO_PLACE 12

.data
test_pattern:
    .asciz "232425323334666768757677"

title_prompt: .asciz "RISC-V Colony\n"
loadTest_prompt: .asciz  "1. Load the test pattern.\n"
createColony_prompt: .asciz "2. Create a colony.\n"
runSimulation_prompt: .asciz "3. Run the simulation.\n"
displayBoard_prompt: .asciz "4. Display current board.\n"
clearBoard_prompt: .asciz "5. Clear the board.\n"
displayStatistics_prompt: .asciz "6. Display statistics.\n"
quit_prompt: .asciz "0. Quit\n"
selection_prompt: .asciz "Selection: "
invalid_prompt: .asciz "Invalid selection, try again.\n"

.text
.globl main

# ---------------------------------------------------------
# main
# Initializes the colony and repeatedly dispatches menu choices.
#
# Arguments:
#     none
#
# Returns:
#     none; exits through a RARS environment call
#
# Modifies:
#     a0, a7, t0
#
# Stack frame:
#     none
# ---------------------------------------------------------
main:
    call reset_colony

menu_loop:

#Display Menu
    li a0, 10               #ASCII for '\n'
    li a7, 11               #Request system call 11 (print char)
    ecall
    
    la a0, title_prompt     #Load address of string to display
    li a7, 4                #Request system call 4 (print string)
    ecall                   #Perform the system call
    
    li a0, 10               
    li a7, 11               
    ecall
    
    la a0, loadTest_prompt 
    li a7, 4               
    ecall                  
    
    la a0, createColony_prompt
    li a7, 4
    ecall
    
    la a0, runSimulation_prompt
    li a7, 4
    ecall
    
    la a0, displayBoard_prompt
    li a7,4
    ecall

    la a0, clearBoard_prompt
    li a7,4
    ecall  
    
    la a0, displayStatistics_prompt
    li a7,4
    ecall

    la a0, quit_prompt
    li a7,4
    ecall
    
    li a0, 10               
    li a7, 11               
    ecall
   
    la a0, selection_prompt
    li a7, 4 
    ecall
    
#Take input
    li a7, 5           #Resquest System call 5 (Read integer)
    ecall              #Perform System call - Program pauses until ENTER is pressed
    
    mv t0, a0          #input (integer) is returned in a0
    
#Call routine based on selection int
    
loadTest: 
    li t1, 1                    #save prompt value
    bne t1, t0, createColony    #compare prompt value with selection value - If !=, branch to next menu option & repeat
    
    call load_test_pattern      #if =, call routine
    j menu_loop                 #Jump back to menu loop -> Display menu again
 
createColony:
   li t1, 2
   bne t1, t0, runSimulation
   
   call create_colony
   j menu_loop
   
runSimulation:
   li t1, 3 
   bne t1, t0, displayBoard
   
   call run_simulation
   j menu_loop

displayBoard:
   li t1, 4
   bne t1, t0, clearBoard
   
   call display_board
   j menu_loop

clearBoard:
   li t1, 5
   bne t1, t0, displayStatistics
   
   call clear_board
   j menu_loop
 
displayStatistics:
   li t1, 6
   bne t1, t0, quit
   
   call display_statistics
   j menu_loop

quit:
   li t1, 0
   bne t1, t0, invalid
   
   j exit

invalid:
   la, a0, invalid_prompt
   li a7, 4
   ecall
   
   j menu_loop

# ---------------------------------------------------------
# reset_colony
# Clears both boards, selects board_a as current, selects board_b
# as next, and resets all statistics.
# ---------------------------------------------------------
reset_colony:

ret
# ---------------------------------------------------------
# clear_board
# Sets all 144 byte locations in one 12 x 12 board to zero.
# ---------------------------------------------------------
clear_board:

ret

# ---------------------------------------------------------
# load_test_pattern
# Clears the colony, decodes twelve row-column digit pairs from
# test_pattern, places them on board_a, and initializes population.
# ---------------------------------------------------------
load_test_pattern:

ret

# ---------------------------------------------------------
# create_colony
# Clears the colony and repeatedly requests coordinates until
# exactly twelve distinct valid living cells have been placed.
# ---------------------------------------------------------
create_colony:

ret

# ---------------------------------------------------------
# place_cell
# Validates a visible row and column and places one living byte
# if the requested location is valid and currently empty.
# ---------------------------------------------------------
place_cell:

ret

# ---------------------------------------------------------
# run_simulation
# Validates a requested generation count, repeatedly calculates
# new boards, swaps board pointers, and updates all statistics.
# ---------------------------------------------------------
run_simulation:

ret

# ---------------------------------------------------------
# display_board
# Displays the current generation number, current population,
# and the visible 10 x 10 portion of a board.
# ---------------------------------------------------------
display_board:

ret

# ---------------------------------------------------------
# count_neighbors
# Counts the eight living cells surrounding one visible cell.
# The invisible border makes all eight byte addresses valid.
# ---------------------------------------------------------
count_neighbors:

ret

# ---------------------------------------------------------
# calculate_generation
# Clears the next board, processes all visible cells with nested
# loops, calls count_neighbors, and writes the complete next state.
# ---------------------------------------------------------
calculate_generation:

ret

# ---------------------------------------------------------
# count_population
# Counts living cells in the visible 10 x 10 portion of a board.
# ---------------------------------------------------------
count_population:

ret

# ---------------------------------------------------------
# display_statistics
# Displays generation, population, largest population, completed
# generations, score, and alive or extinct status.
# ---------------------------------------------------------
display_statistics:

ret
   
# ---------------------------------------------------------
# Exit the program
# ---------------------------------------------------------
exit:
    li a7, 10
    ecall
