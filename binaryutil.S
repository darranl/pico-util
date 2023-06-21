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
