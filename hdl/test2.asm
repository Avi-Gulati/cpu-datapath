nor $t0, $0, $0     # Set t0 to -1 
srl $t1, $t0, 31    # Set t1 to 1
add $t2, $t1, $t1   # Set t2 to 2 now by adding it to itself
sub $t3, $t2, $t1   # Set t3 to (t2 - t1) = (2-1) = 1. 
or  $t4, $t2, $t3    # Set t4 to 1 | 2 which is 3. 
and $t5, $t4, $t2   # t5 should be 2, because it is ($t4 & $t2), which is (3 & 2) = ('b11 & 'b10) = 'b10. 
nop                 # The program counter should increment by 4 
sll $t6, $t4, 3     # t6 should be 24, which is $t4 * 2^3. So 3 * 8. 
xor $t7, $t6, $t1   # t7 should be 25, because we are xor-ing 24 with 1 (basically adding one)
add $s0, $t0, $t0   # We want to now test sra. For this, we ideally want to test a negative number shifted right arithmetically
add $s0, $s0, $s0   # and make sure the resulting number is negative and divided by 2^constant. Let's first get a negative number into the #s0 register
add $s0, $s0, $s0    
add $s0, $s0, $s0   # So now, $s0 contains -16 
sra $s0, $s0, 3     # If we shift this by three to the right, we should get -16/8 = -2.             
slt $s1, $s0, $t0   # Compare the two registers containing -2 and -1 respectively. s1 should be 1. since -2 < 1
slt $s2, $t0, $s0   # Same thing as the instruction above, but I'm really just verifying that the destination and source register are changed and slt should be zero instead since they are swapped here. 

# Above, we have tested our R-type instructions. Now, let's check whether our 
# store word and load word instructions are working. To this, we will store a value 
# into memory and then load that value into a register. 
sw $s0, 0($0)       # s0 contains -2 from the above r type instructions. so we will 
                    # store -2 in data word 0
lw $s3, 0($0)       # To check the validity of both our sw and lw commands, we can see whether
                    # the register s3 now contains -2. 