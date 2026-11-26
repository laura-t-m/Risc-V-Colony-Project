#constants 
.eqv BOARD_SIDE 12
.eqv VISIBLE_SIDE 10
.eqv BOARD_BYTES 144
.eqv CELLS_TO_PLACE 12


.data
test_pattern:
    .asciz "232425323334666768757677"
     
board_a: .space BOARD_BYTES  # stores 144 bytes for board_a
board_b: .space BOARD_BYTES # stores 144 bytes for board_b

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

#Statistics 
generationNumber: .asciz "Generation: "
currentPopulation: .asciz "Population: "
largestPopulation: .asciz "Largest Population: "
generationsCompleted: .asciz "Generations Completed: "
currentScore: .asciz "Score: "
colonyStatus: .asciz "Colony Status: " #alive or extinct

#Cell Coordinate Request Promps
cell: .asciz "Cell "
of_12: .asciz " of 12\n"
row_prompt: .asciz "Row (0-9): "
column_prompt: .asciz "Column (0-9): "
invalid_coordinate_msg: .asciz "Row or Column Range Invalid. Try again\n"
invalid_occupied_msg: .asciz "Position Choosen is Already Occupied. Try again\n"
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
    call clear_board #clear board/clear colony 

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
# reset_colony #NOT NEEDED (?) Instead use just Clear Board
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


ret

# ---------------------------------------------------------
# clear_board
# Clears both boards (Sets all 144 byte locations in one 12 x 12 board to zero)
# selects board_a as current, selects board_b as next
# resets all statistics.
#
# Arguments:  none
#
#
# Returns: a0 (Current Board/Board_a), a1 (Next Board/Board_b)
#
#
# Modifies: a0-a1 , t0
#
#
# ---------------------------------------------------------
clear_board:
	# Take the memory address of  board_a and board_b
	la a0, board_a
	la a1, board_b
	
	# Counter until there are no more bytes remaining
	li t0, 144
       
clear_boards_loop:
        
	# Stores zero into the first memory address
	sb zero, 0(a0)
	sb zero,0(a1)
	
	# Advance the memory addreess by one byte
	addi a0, a0, 1
	addi a1, a1, 1
	
	# Update the counter
	addi t0, t0, -1
	# Loops until it reaches 0
	bnez t0, clear_boards_loop

clear_statistics:
# resets all statistics

clear_done:
# selects board_a as current, selects board_b as next
     
        
	ret

# ---------------------------------------------------------
# load_test_pattern
# Clears the colony, decodes twelve row-column digit pairs from
# test_pattern, places them on board_a to create colony, and initializes population.
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
#Expand stack, store registers
addi sp, sp, -16
sw ra, 12(sp)

#clears colony/board: Receives board_a in a0 and board_b in a1
call clear_board 

#load base addres of the test pattern string 
la t0, test_pattern 

li t1, 12 # t1 = total columns (12 per row)
li t2, 1  # t2 = value representing a live cell - 1


#To decode - Think of string in 12 pairs of char, x (i), y (j), pairs
while:
lb t3, 0(t0)  # Load char for row (i) and check for null terminator
beqz t3, done # Stop loop if hit null terminator = 0 (ASCII for null terminator)

lb t4, 1(t0) # Load char for column (j) from next byte position

#Convert ASCII chars of string into integers, subtract 48 ( char '0' = ASCII 48)
addi t3, t3, -48
addi t4, t4, -48 

#Add 1 to account for border padding
addi t3, t3, 1
addi t4, t4, 1

#Calculate live cell position (t5) = base address + (i * column + j) * byte_size
mul t5, t3, t1   # t5 = i * columns  (rows to jump)

add t5, t5, t4   # t5 = t5 + j (elements to jump) 

#Store live cell in calculated memory adress
add t5, a0, t5   #Combine base address to  calculated memory address  
sb t2, 0(t5)     #store 1 at position calculated

addi t0, t0, 2 #Update pointer to next pair 
j while

done: 
#Restire registers and Shrink stack
lw ra, 12(sp)
addi sp, sp, 16

ret

# ---------------------------------------------------------
# create_colony -
# Clears the colony/board and repeatedly requests coordinates until
# exactly twelve distinct valid living cells have been placed.
#
# Arguments: 
#	a0 (board_a) and a1 (board_b) from clear board
#
# Returns:
#	a0 (board_a/current colony)
#
# Modifies:
#
#
# ---------------------------------------------------------
create_colony:
addi sp, sp, -16
sw ra, 12(sp)

call clear_board #Clears boards - returns board_a in a0 and board_b in a1
sw a0, 8(sp)
sw a1, 4(sp)

li t0, 12 #living cell limit
li t1, 0 #living cell count

request_coordinates:
	bgt t1, t0, done_requests
	
	#"Cell x of 12"
	la a0, cell 
	li a7, 4
	ecall
	
	add a0,zero, t1
	li a7, 1
	ecall
	
	la a0, of_12
	li a7, 4
	ecall
	
	#Prompt for row number
	la a0, row_prompt
	li a7, 4
	ecall
	#Retrieve row input
	li a7, 5
	ecall
	#save row number
	mv t2, a0 
	
	#Prompt for column number
	la a0, column_prompt
	li a7, 4
	ecall
	#Retrieve column input
	li a7, 5
	ecall
	#save column number
	mv t3, a0 	

	li a0, 10 #newline
	li a7, 11
	ecall 
	
	mv a2, t2 #a2 holds row number
	mv a3, t3 #a3 holds column number
	lw a1, 4(sp) #restore address of board_b
	call place_cell
	
	#ERROR - Try again if position occupied or row/column invalid
	li t4, -1
	beq a0, t4, request_coordinates
	
	#Only count as one of the 12 placed cells if placed successfully
	addi t1, t1, 1
	j request_coordinates
       
done_requests:
#Restore value from stack
lw a0, 8(sp)

#Copy Cell's location from board_b to board_a
mv t0, a1
mv a1, a0
mv a0, t0

lw ra, 12(sp)
addi sp, sp 16
ret

# ---------------------------------------------------------
# place_cell
# Validates a visible row and column and places one living byte
# if the requested location is valid and currently empty.
#
# Arguments:  a1 (board_b), a2 (row number), a3 (column number)
#	
#
# Returns: a1(modified_board), a0 (place cell status)
#	
#
# Modifies: a0-a3, t0-t6
#
#
# ---------------------------------------------------------
place_cell:
	li t0, 12 #column/row amount
	li t2, 0 #lower range bound
        li t3, 9 #upper range bound
        li t4, 1 #Live cell Value
        
	#Check range for row
	bgt a2, t3, invalid_coordinate
	blt a2, t2, invalid_coordinate
	
        #Check range for column
	bgt a3, t3, invalid_coordinate
	blt a3, t2, invalid_coordinate
	
	#Calculate Position of Cell (t5) = base address + (i * column + j) * byte_size
	
        addi a2, a2, 1 #offset by 1 to skip border
	addi a3, a3, 1 #offset by 1 to skip border
	
        mul t5, a2, t0   # t5 = i * columns  (rows to jump)
        add t5, t5, a3   # t5 = t5 + j (elements to jump) 
        add t5, t5, a1   #base address + (...)
        
        #Check address occupation status - If equal to 1 (occupied)
        lb t6, 0(t5)
        beq t6, t4, invalid_coordinate 
        
        #Place Live Cell in position
        sb t4, 0(t5)
done_placing_cell:
        li a0, 0
	ret

#Coordinate for Row or Column Outside of range 0-9
invalid_coordinate:
       la a0, invalid_coordinate_msg
       li a7, 4
       ecall

       li a0, -1 #flag error/invalid
       ret

occupied_position:
       la a0, invalid_occupied_msg
       li a7, 4
       ecall
       
       li a0, -1 #flag error/invalid
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
#save on stack 32 bytes and then save s0-s4 and ra
addi sp, sp, -32
sw s0, 0(sp)
sw s1, 4(sp)
sw ra, 8(sp)
sw s2, 12(sp)
sw s3, 16(sp)
sw s4, 20(sp)

mv s0, a0
mv s1, a1
li s2, 1

outer_loop:
li s3, 1

inner_loop:
#load t1 with 12 for offset calculation of row x 12 + columns
li t1, 12
mul s4, s2, t1
add s4, s4, s3

# add the base adress + offset into a0
add a0, s0, s4
call count_neighbors
add t1, s0, s4
lbu t2, 0(t1)

li t3, 3
beq a0, t3, cell_alive
li t4, 2
beq a0, t4, keep_cell_state
#load t2 with value 0 for dead cell and then Jump to shared_board_storage to load value to next board
li t2, 0
j shared_board_storage 

cell_alive:
li t2, 1
j shared_board_storage

keep_cell_state:
j shared_board_storage

shared_board_storage:
add t1, s1, s4
sb t2, 0(t1)
addi s3, s3, 1
li t5, 11
blt s3, t5, inner_loop
addi s2, s2, 1
blt s2, t5, outer_loop

#load those values back into the registers
lw s0, 0(sp)
lw s1, 4(sp)
lw ra, 8(sp)
lw s2, 12(sp)
lw s3, 16(sp)
lw s4, 20(sp)
addi sp, sp, 32
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
