# Description: Simple program that adds a value over and over until it the sum is greater than or equal to the target value

.data
    
value: .word 5
target: .word 15

.text

    lw t0, value(x0) # value = *value
    add t1, x0, x0 # sum = 0
    lw t2, target(x0) # target = *target

routine: 

    add t1, t1, t0 # sum = sum + value

    blt t1, t2, routine # if (sum < target) -> routine


addi s1, x0, -1 # Used to mark program completion on waveform

# Infinite loop after program
loop:
    jal x0, loop
