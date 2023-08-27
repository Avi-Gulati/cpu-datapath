    addi $t0, $0, 1     # Set t0 to 1
    ori  $t1, $t0, 2    # Set t1 to 1 | 2 which is 3. 
    andi $t2, $t1, 2    # t2 should be 2, because it is ($t1 & 2), which is (3 & 2) = ('b11 & 'b10) = 'b10. 
    xori $t3, $t0, 24   # t3 should be 25, because we are xor-ing 24 with 1 (basically adding one) 
    slti $s0, $t0, -8   # s0 should be 0 which it is. s1 two lines below should be 1 which it is! 
    addi $s1, $0, -8
    slti $s1, $s1, 1    # I am making sure that slti works both ways when the source < target and target > source 
                        # Yay, we have covered all of the i type instructions. Let's continue.

# Above, we have tested our I-type instructions. Now, let's check whether our 
# store word and load word instructions are working. To this, we will store a value 
# into memory and then load that value into a separate register. 
    sw $t3, 8($0)       # t3 contains 25 from the above i type instructions. so we will 
                        # store 25 in data word 2 (which is 8 offset 0)
    lw $t4, 8($0)       # To check the validity of both our sw and lw commands, we can see whether
                        # the register t4 now contains 25, which it indeed does! 

# Let's now check our beq and bne instructions 
    beq $t4, $t3, checkbeq  # t4 and t3 both contain 25, so this should skip over the next line and go straight to 
                            # the checkbeq label. So, t4 should remain at 25, which it does! 
    addi $t4, $t4, 1
checkbeq:
    beq $t4, $t1, checkBEQwhennotequal 
    addi $t4, $t4, 3        # Now, this instruction should be reached and t4 should go from 25 to 28, which it does! 
checkBEQwhennotequal:
    bne $t3, $t1, checkbne 
    addi $t3, $t3, 82       # This instruction should be skipped, which it is since t3 and t1 are not equal.
checkbne:
    addi $t3, $t3, 3
    bne $t3, $t4, checkbnewhenequal
    addi $t4, $t4, 2       # This instruction should not be skipped, and it isn't! Now, t4 and t3 are 30 and 28 respectively 
                            # and we checked the validity of beq and bne in both cases or each when the variables are equal and not. 
checkbnewhenequal: 

# Now let's check our j type instructions. It is difficult to test j, jal, and jr in the same assembly segment 
# since they're recursive unless I build in some bne or beq like a loop. But for the purposes 
# of this testing, that is not fully necessary since I know bne and beq already work effectively. 
# Here, we should see t4 first going up by 30 and then 1 and then this process repeating. And indeed
# we see this! 
    jal addthirty           
    addi $t4, $t4, 1
addthirty:    
    addi $t4, $t4, 30  
    jr $31


# Above I have tested every instruction but jump. If you read my testing methodology and description, 
# I have included more information about the type of test I used to test my jump instruction. 
# In fact, this assembly file contains a bunch of instructions together, but before I wrote this, 
# I wrote mini tests for each instruction just to make sure each instruction was working by itself. 
# And I have elaborated on those tests in the testing methodology and description file. By the way, 
# my waveform configuration is saved, and it corroborates everything in this assembly file 
# because that's what I had to look at to make sure my processor was working. 