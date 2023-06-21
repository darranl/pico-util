
@ Function:
@  void int_to_binary(uint32_t to_convert, char * result);
@
@  R0 - Input number
@  R1 - Address of result array.
.global int_to_binary
int_to_binary:
    MOV R3, #0x20    @ Initialise counter to 32
next_bit:
    LSL R0, #1       @ Shift left so something is carried
    BCS it_is_one
    MOV R2, #0x30    @ Place Digit 0 in R2
resume:
    STRB R2, [R1]    @ Store the byte in R2 at next memory location
    SUB R3, #1       @ Decrement counter by one
    BEQ return       @ Down to 0 so can return
    ADD R1, #1       @ Move the address pointer on by one byte
    B next_bit

it_is_one:
    MOV R2, #0x31    @ Place Digit 1 in R2
    B resume

return:
    BX LR
