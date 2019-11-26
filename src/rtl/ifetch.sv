/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the instruction fetch logic
**/
import riscv_defs::*;

module ifetch(
    imem_if.cpu                             IMEM_IF, 
    input   logic                           i_clock,
    input   logic                           i_reset,   
    input   logic                           i_hazard_detected, 
    input   logic                           i_branch_taken,
    input   logic   [NB_ADDR    - 1 : 0]    i_branch_addr,
    output  logic   [NB_WORD    - 1 : 0]    o_instruction,
    output  logic   [NB_WORD    - 1 : 0]    o_pc
);

    logic   [NB_ADDR    - 1 : 0]    pc;

    always_ff @(posedge i_clock)
    if( i_reset )
        pc  <= '0;
    else if( /*!i_hazard_detected*/1'b1 ) //[FIXME]
        if( i_branch_taken )
            pc <= i_branch_addr;
        else
            pc <= pc + 32'd4;


    assign IMEM_IF.imem_pc  = pc;
    assign o_instruction    = IMEM_IF.imem_instruction;
    assign o_pc             = pc;


endmodule
