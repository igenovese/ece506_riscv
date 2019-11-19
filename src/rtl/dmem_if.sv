/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the data memory interface
and its corresponding modports
**/

import riscv_defs::*;

interface dmem_if (
    input   logic       i_clock,
    input   logic       i_reset
);

    logic   [NB_ADDR    - 1 : 0]    dmem_address;
    logic   [NB_WORD    - 1 : 0]    dmem_wr_data;
    logic                           dmem_wr_enable;
    logic   [NB_WORD    - 1 : 0]    dmem_rd_data;

    modport memory(
        input   i_clock,
        input   i_reset,
        input   dmem_wr_data,
        input   dmem_wr_enable,
        output  dmem_rd_data
    );

    modport cpu(
        input   i_clock,
        input   i_reset,
        output  dmem_wr_data,
        output  dmem_wr_enable,
        input   dmem_rd_data
    );

endinterface