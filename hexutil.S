@ Copyright 2023, Darran A Lofthouse
@
@ This file is part of pico-util.
@
@ pico-util is free software: you can redistribute it and/or modify it under the terms
@ of the GNU General Public License as published by the Free Software Foundation, either
@ version 3 of the License, or (at your option) any later version.
@
@ pico-util is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
@ without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
@ See the GNU General Public License for more details.
@
@ You should have received a copy of the GNU General Public License along with pico-util.
@ If  not, see <https://www.gnu.org/licenses/>.

@  Function:
@   void int_test(uint32_t * test_value);
@
@  R0 - Address of input String
@
.global int_test   @ This line says the label needs to be global.
int_test:          @ This then defines the label.
    PUSH {R4}
    LDRB R4, [R0]
    LDRB R4, [R0, #1]
    LDRB R4, [R0, #2]
    LDRB R4, [R0, #3]
    LDR R4, [R0]
    @ADD R4, R4, #1
    @REV R4, R4
    LSL R4, R4, #1
    STR R4, [R0]
    LDRB R4, [R0]
    LDRB R4, [R0, #1]
    LDRB R4, [R0, #2]
    LDRB R4, [R0, #3]
    POP {R4}
    BX LR

@ Function:
@ extern void uint8_to_hex(uint8_t value, char * result);
@ Initial Registers
@ R0 - value
@ R1 - result
.global uint8_to_hex     @ This line says the label needs to be global.
 uint8_to_hex:           @ This then defines the label.
    MOV R2, #1           @ Start position
uint8_start_nibble:
    MOV R3, #0xF         @ Set R3 to 0xF so we can mast last 4 bits
    AND R3, R0, R3       @ Update R3 to represent last 4 bits
    CMP R3, #0xA         @ If above 0x9 we need to move to A-F
    BPL uint8_gt_ten     @ More digits below A so minimise additional branch.
    ADD R3, #0x30
uint8_next:STRB R3, [R1, R2] @ Store char at offset
    SUB R2, R2, #1      @ Subtract one from the counter.
    BMI uint8_return     @ If below jump to return.
    LSR R0, R0, #4      @ Shift right by 4.
    B uint8_start_nibble @ Loop again.
uint8_return: BX LR


uint8_gt_ten:
    ADD R3, #0x37         @ Just increment by further 0x11
    B uint8_next

@ Function:
@  void uint32_to_hex(uint32_t value, char * result);
@ Initial Registers:
@  R0 = value
@  R1 = result
@ Scratch Registers:
@  R2 = Position (Start at 7)
@  R3 = Current digit
@ Char Pos:   0    1    2   3    4    5    6    7
@           0000 0000 0000 0000 0000 0000 0000 0000
@ Right Sht:       24   20   16   12   8    4    0
@
@ Each loop will need to calculate two characters as these are
@ represented by a byte which is the smallest unit we can work on.
@
@ For this conversion I am only interested in memory ordering for the result, for
@ the uint will rely on the bitwise operations assuming in normal order.
@
@ Ascii:
@  0 = 48 = 0x30
@   ...
@  9 = 57 = 0x39
@  A = 65 = 0x41
@   ...
@  F = 70 = 0x46
@
.global uint32_to_hex     @ This line says the label needs to be global.
 uint32_to_hex:           @ This then defines the label.
    MOV R2, #7            @ Start position counter at 7, least significant nibble.
start_nibble:
    MOV R3, #0xF          @ Set R3 to 0xF so we can mast last 4 bits
    AND R3, R0, R3        @ Update R3 to represent last 4 bits
    CMP R3, #0xA          @ If above 0x9 we need to move to A-F
    BPL gt_ten            @ More digits below A so minimise additional branch.
    ADD R3, #0x30
next:  STRB R3, [R1, R2] @ Store char at offset
    SUB R2, R2, #1       @ Subtract one from the counter.
    BMI return           @ If below jump to return.
    LSR R0, R0, #4       @ Shift right by 4.
    B start_nibble       @ Loop again.
return: BX LR

gt_ten:
    ADD R3, #0x37         @ Just increment by further 0x11
    B next

@ Function:
@  void uint32_to_hex_string(uint32_t value, char * result);
@
@ Initial Registers:
@  R0 = value
@  R1 = result
@ Scratch Registers:
@  R2 = Position 0
@  R3 = Current digit
@  R4 = Count - Start at 7 so we can detect when we go below 0.
.global uint32_to_hex_string     @ This line says the label needs to be global.
 uint32_to_hex_string:           @ This then defines the label.
    PUSH {R4}
    MOV R2, #0x0
    MOV R4, #0x8
before_rotate:
    SUB R4, R4, #0x1
    BMI end_to_hex_string @ MI - N =1, Negative
    MOV R3, #0x1C         @ Borrow R3 to set how many bits to shift right.
    ROR R0, R0, R3
    MOV R3, #0xF          @ Set R3 to 0xF so we can mask last 4 bits
    AND R3, R0, R3        @ Update R3 to represent last 4 bits
    CMP R2, #0x0          @ Check if we have stored any digits
    BNE store             @ We have already stored one digit so we must store all. NE - Z=0 Not Equal
    CMP R3, #0x0          @ Check is digit 0
    BEQ before_rotate     @ Digit 0 so repeat loop. EQ - Z=1 Equal
store:
    CMP R3, #0xA          @ If above 0x9 we need to move to A-F
    BPL gt_ten2           @ More digits below A so minimise additional branch. PL - N=0 Positive or Zero
    ADD R3, #0x30
to_mem:
    STRB R3, [R1, R2]
    ADD R2, #0x1
    B before_rotate
end_to_hex_string:
    CMP R2, #0x0
    BEQ store_zero        @ We haven't stored any digits, store a 0.
    MOV R3, #0x0
    STRB R3, [R1, R2]     @ Terminate the String with 0
    POP {R4}
    BX LR

gt_ten2:
    ADD R3, #0x37         @ Just increment by further 0x11
    B to_mem

store_zero:
    MOV R3, #0x30
    STRB R3, [R1, R2]
    ADD R2, #0x1
    B end_to_hex_string


@ Function:
@  extern uint32_t hex_string_to_uint32(char * hex);
@
@ Initial Registers
@   R0 - Pointer to first char in String
@ Intermediate Registers
@   R1 - Current character
@   R2 - Result being constructed
@ Return Value - R0
.global hex_string_to_uint32     @ This line says the label needs to be global.
 hex_string_to_uint32:           @ This then defines the label.
    MOV R2, #0x0                  @ Initialise response to 0.
begin_char:
    LDRB R1, [R0]
    CMP R1, #0x0
    BEQ end_hex_string_to_uint32  @ Current byte is 0 so reached end of String
    ADD R0, #0x1                  @ Move to next byte, we know we will have one more loop.
    LSL R2, #0x4                  @ Shift left by 4 discarding the 4 highest bits.  (Redundant on first loop)
    CMP R1, #0x41
    BCS char_greater_A            @ Char is 0x65 or greater
    SUB R1, #0x30
store_digit:
    ORR R2, R1
    B begin_char
end_hex_string_to_uint32:
    MOV R0, R2
    BX LR

char_greater_A:
    SUB R1, #0x37
    B store_digit


@ Function:
@   extern char hex_to_char(char * hex);
@
@ R0 pointer to first char in hex string to convert.
@
@ Response:
@  R0 - Converted char
.global hex_to_char
hex_to_char:
    PUSH { LR }
    LDRB R1, [R0]    @ Load first char
    BL single_hex_to_char
    MOV R2, R1
    LSL R2, #4
    ADD R0, R0, #1
    LDRB R1, [R0]    @ Load second char
    BL single_hex_to_char
    ORR R1, R1, R2
    MOV R0, R1

    POP { PC }

single_hex_to_char:
    CMP R1, #0x61
    BCS lower_case
    CMP R1, #0x41
    BCS upper_case
    SUB R1, R1, #0x30
    BX LR

lower_case:
    SUB R1, R1, #0x57
    BX LR

upper_case:
    SUB R1, R1, #0x37
    BX LR
