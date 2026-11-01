.eqv BOARD_SIDE 12
.eqv VISIBLE_SIDE 10
.eqv BOARD_BYTES 144
.eqv CELLS_TO_PLACE 12

.data
test_pattern:
    .asciz "232425323334666768757677"

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
    
    j exit

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
