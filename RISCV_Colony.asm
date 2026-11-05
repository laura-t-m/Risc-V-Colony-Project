#constants 
.eqv BOARD_SIDE 12
.eqv VISIBLE_SIDE 10
.eqv BOARD_BYTES 144
.eqv CELLS_TO_PLACE 12

.data
test_pattern:
    .asciz "232425323334666768757677"
     
main_board: .space BOARD_BYTES  # Stores the current gen (reserve space for 144 bytes)
next_board: .space BOARD_BYTES # Stores the next gen

#Menu promps
title_prompt: .asciz "RISC-V Colony\n"
loadTest_prompt: .asciz  "1. Load the test pattern.\n"
createColony_prompt: .asciz "2. Create a colony.\n"
runSimulation_prompt: .asciz "3. Run the simulation.\n"
displayBoard_prompt: .asciz "4. Display current board.\n"
clearBoard_prompt: .asciz "5. Clear the board.\n"
displayStatistics_prompt: .asciz "6. Display statistics.\n"
quit_prompt: .asciz "0. Quit\n"
invalid_prompt: .asciz "Invalid selection, try again.\n"
selection_prompt: .asciz "Selection: "


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
    
    #input (integer) is returned in a0
    
#Call routine based on selection int
    
loadTest: 
    li t0, 1                    #save prompt value
    bne t0, a0, createColony    #compare prompt value with selection value - If !=, branch to next menu option & repeat
    
    call load_test_pattern      #if =, call routine
    j menu_loop                 #Jump back to menu loop -> Display menu again
 
createColony:
   li t0, 2
   bne t0, a0, runSimulation
   
   call create_colony
   j menu_loop
   
runSimulation:
   li t0, 3 
   bne t0, a0, displayBoard
   
   call run_simulation
   j menu_loop

displayBoard:
   li t0, 4
   bne t0, a0, clearBoard
   
   call display_board
   j menu_loop

clearBoard:
   li t0, 5
   bne t0, a0, displayStatistics
   
   call clear_board
   j menu_loop
 
displayStatistics:
   li t0, 6
   bne t0, a0, quit
   
   call display_statistics
   j menu_loop

quit:
   li t0, 0	
   bne t0, a0, invalid
   
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
#
# Arguments:
#
#
# Returns:
#
#
# Modifies:
#
#
# ---------------------------------------------------------
reset_colony:

#call clear board on board_a
#call clear board on board_b

#select board_a as current

#select board_b as next

#reset statistics

#return
ret
# ---------------------------------------------------------
# clear_board
# Sets all 144 byte locations in one 12 x 12 board to zero.
#
# Arguments:
#
#
# Returns:
#
#
# Modifies:
#
#
# ---------------------------------------------------------
clear_board:
	# Take the memory address of main_board or next
	mv t0, a0
	# Counter until there are no more bytes remaining
	li t1, 144

clear_loop:
	# Stores zero into the first memory address
	sb zero, 0(t0)
	# Advance the memory addreess by one byte
	addi t0, t0, 1
	# Update the counter
	addi t1, t1, -1
	# Loops until it reaches 0
	bnez t1, clear_loop

	ret

# ---------------------------------------------------------
# load_test_pattern
# Clears the colony, decodes twelve row-column digit pairs from
# test_pattern, places them on board_a, and initializes population.
#
# Arguments: 
#	none
#
# Returns:
#	a0
#
# Modifies:
#      a0, t0-t5
#
# ---------------------------------------------------------
load_test_pattern:

#clears colony - calls reset colony  on board a and b

#load base addres of the test pattern string 
la t0, test_pattern 

li t1, 12 # t1 = total columns (12 per row)
li t2, 1  # t2 = value representing a live cell - 1
la a0, main_board # a1 = base address of main board

#To decode - Think of string in 12 pairs of char, x (i), y (j), pairs

while:
lb t3, 0(t0)  # Load char for row (i) and check for null terminator
beqz t3, done # Stop loop if hit null terminator = 0 (ASCII for null terminator)

lb t4, 1(t0) # Load char for column (j) from next byte position

#Convert ASCII chars of string into integers, subtract 48 ( char '0' = ASCII 48)
addi t3, t3, -48
addi t4, t4, -48 

#Calculate live cell position = base address + (i * column + j) * byte_size
mul t5, t3, t1   # t5 = i * columns  (rows to jump)
add t5, t5, t1   # Add 12 to account for top/bottom border padding

add t5, t5, t4   # t5 = t5 + j (elements to jump) 
addi t5, t5, 1  # Add 1 to account for left/right border padding

#Store live cell in calculated memory adress
add t5, a0, t5   #Combine base address to  calculated memory address
sb t2, 0(t5)     #store 1 at position calculated

addi t0, t0, 2 #Update pointer to next pair 
j while

done: 

ret

# ---------------------------------------------------------
# create_colony
# Clears the colony and repeatedly requests coordinates until
# exactly twelve distinct valid living cells have been placed.
#
# Arguments: 
#	none
#
# Returns:
#	a0
#
# Modifies:
#
#
# ---------------------------------------------------------
create_colony:


ret

# ---------------------------------------------------------
# place_cell
# Validates a visible row and column and places one living byte
# if the requested location is valid and currently empty.
#
# Arguments: 
#	
#
# Returns:
#	
#
# Modifies:
#
#
# ---------------------------------------------------------
place_cell:

ret

# ---------------------------------------------------------
# run_simulation
# Validates a requested generation count, repeatedly calculates
# new boards, swaps board pointers, and updates all statistics.
#
# Arguments: 
#	
#
# Returns:
#	
#
# Modifies:
#
#
# ---------------------------------------------------------
run_simulation:

ret

# ---------------------------------------------------------
# display_board
# Displays the current generation number, current population,
# and the visible 10 x 10 portion of a board.
#
# Arguments: 
#	
#
# Returns:
#	
#
# Modifies:
#
#
# ---------------------------------------------------------
display_board:

ret

# ---------------------------------------------------------
# count_neighbors
# Counts the eight living cells surrounding one visible cell.
# The invisible border makes all eight byte addresses valid.
#
# Arguments: 
#	
#
# Returns:
#	
#
# Modifies:
#
#
# ---------------------------------------------------------
# call a0 as current cell address and then we count| top left(-13) | top middle(-12) | top right(-11)
#                                                  | left(-1)      | current(a0)     | right(1)
#                                                  | bot left(11)  | bot mid(12)     | bot right(13)
# Then add the value so add a1, a1, t0 so add 0 + 1 or 0 and repeat
count_neighbors:
li a1, 0
lbu t0, -13(a0)
add a1, a1, t0
lbu t0, -12(a0)
add a1, a1, t0
lbu t0, -11(a0)
add a1, a1, t0
lbu t0, -1(a0)
add a1, a1, t0
lbu t0, 1(a0)
add a1, a1, t0
lbu t0, 11(a0)
add a1, a1, t0
lbu t0, 12(a0)
add a1, a1, t0
lbu t0, 13(a0)
add a1, a1, t0
mv a0, a1
ret #returns the number of living cells surround the given cell in a0

# ---------------------------------------------------------
# calculate_generation
# Clears the next board, processes all visible cells with nested
# loops, calls count_neighbors, and writes the complete next state.
#
# Arguments: 
#	
#
# Returns:
#	
#
# Modifies:
#
#
# ---------------------------------------------------------
calculate_generation:

ret

# ---------------------------------------------------------
# count_population
# Counts living cells in the visible 10 x 10 portion of a board.
#
# Arguments: 
#	
#
# Returns:
#	
#
# Modifies:
#
#
# ---------------------------------------------------------
count_population:

ret

# ---------------------------------------------------------
# display_statistics
# Displays generation, population, largest population, completed
# generations, score, and alive or extinct status.
# --------------------------------------------------------
#
# Arguments: 
#	
#
# Returns:
#	
#
# Modifies:
#
#-
display_statistics:

ret
   
# ---------------------------------------------------------
# Exit the program
# ---------------------------------------------------------
exit:
    li a7, 10
    ecall
