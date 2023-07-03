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

#include "hardware/regs/addressmap.h"
#include "hardware/regs/m0plus.h"


.EQU ENABLED_FLAG, 0x1
.EQU ENABLE_SYST, 0x5  @ i.e. 0b101

@ Start Function:
@  extern void start_syst_counter();
@
@ Initial Registers:
@   None
@
@ Return Value:
@   None
@
.thumb_func             @ We may B to SDK code
.global start_syst_counter  @ This line says the label needs to be global.
start_syst_counter:              @ This then defines the label.
    MOV R0, #ENABLE_SYST
    LDR R1, syst_csr_offset
    LDR R2, ppb_base
    STR R0, [R2, R1]
    MOV R0, #0x0                @ Not really needed as setting the register causes it to start again.
    LDR R1, syst_cvr_offset
    STR R0, [R2, R1]
    BX LR

@ Start Function:
@  extern uint32_t stop_syst_counter();
@
@ Initial Registers:
@   None
@
@ Return Value:
@   R0 - No of elapsed ticks.
@
.thumb_func             @ We may B to SDK code
.global stop_syst_counter  @ This line says the label needs to be global.
stop_syst_counter:              @ This then defines the label.
    LDR R2, ppb_base
    LDR R3, syst_cvr_offset
    LDR R0, [R2, R3]         @ Grab the current value before we check status in case we cycle.
    LDR R3, syst_csr_offset
    LDR R1, [R2, R3]           @ Load the current status.
    LDR R3, syst_count_flag
    AND R3, R3, R1 
    BNE timer_cycled
    MOV R3, #ENABLED_FLAG
    AND R3, R3, R1 
    BEQ no_timer_running
    LDR R3, syst_rvr_offset
    LDR R1, [R2, R3]
    SUB R0, R1, R0
    SUB R0, #0xa1
stop_timer:
    MOV R1, #0x0
    LDR R3, syst_csr_offset
    STR R1, [R2, R3]
    BX LR

no_timer_running:
    MOV R0, #0x0
    SUB R0, R0, #0x1
    BX LR 

timer_cycled:
    MOV R0, #0x0
    SUB R0, R0, #0x2
    B stop_timer

    .align 4
ppb_base: .word PPB_BASE 
syst_csr_offset: .word M0PLUS_SYST_CSR_OFFSET
syst_rvr_offset: .word M0PLUS_SYST_RVR_OFFSET
syst_cvr_offset: .word M0PLUS_SYST_CVR_OFFSET
syst_count_flag: .word 0x10000
