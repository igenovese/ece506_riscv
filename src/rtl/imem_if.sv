/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the instruction memory interface
and its corresponding modports
**/

import riscv_defs::*;

interface imem_if ();

    logic   [NB_ADDR    - 1 : 0]    imem_pc;     
    logic   [NB_WORD    - 1 : 0]    imem_instruction;

    modport memory(
        input   imem_pc,        
        output  imem_instruction
    );

    modport cpu(
        output  imem_pc,        
        input   imem_instruction
    );

endinterface