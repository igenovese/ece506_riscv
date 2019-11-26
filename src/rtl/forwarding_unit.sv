/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the forwarding unit logic
If any of the instructions in EX, MEM or WB write to a register,
it checks the destination register of it and compares it with
the source registers of instructions in IF/ID, ID/EX
**/

import riscv_defs::*;

module forwarding_unit(
    input   logic                           i_id_ex_rf_write,
    input   logic                           i_ex_mem_rf_write,
    input   logic                           i_mem_wb_rf_write,
    input   logic   [NB_OPERAND - 1 : 0]    i_id_ex_rd,
    input   logic   [NB_OPERAND - 1 : 0]    i_ex_mem_rd,
    input   logic   [NB_OPERAND - 1 : 0]    i_mem_wb_rd,
    input   logic   [NB_OPERAND - 1 : 0]    i_if_id_rs1,
    input   logic   [NB_OPERAND - 1 : 0]    i_if_id_rs2,
    input   logic   [NB_OPERAND - 1 : 0]    i_id_ex_rs1,
    input   logic   [NB_OPERAND - 1 : 0]    i_id_ex_rs2,
    output  logic   [1              : 0]    o_forward_if_id_rs1,
    output  logic   [1              : 0]    o_forward_if_id_rs2,
    output  logic   [1              : 0]    o_forward_id_ex_rs1,
    output  logic   [1              : 0]    o_forward_id_ex_rs2
);
    
    always_comb
    begin
        //From ALU & MEM to ALU
        if( i_ex_mem_rf_write && i_ex_mem_rd != '0 && i_ex_mem_rd == i_id_ex_rs1 )      o_forward_id_ex_rs1 = 2'b10;        //forward alu res to alu                           
        else if( i_mem_wb_rf_write && i_mem_wb_rd != '0 && i_mem_wb_rd == i_id_ex_rs1 ) o_forward_id_ex_rs1 = 2'b01;        //forward mem res to alu                              
        else o_forward_if_id_rs1 = 2'b00;

        if( i_ex_mem_rf_write && i_ex_mem_rd != '0 && i_ex_mem_rd == i_id_ex_rs2 )       o_forward_id_ex_rs2 = 2'b10;       //forward alu res to alu
        else if( i_mem_wb_rf_write && i_mem_wb_rd != '0 && i_mem_wb_rd == i_id_ex_rs2 )  o_forward_id_ex_rs2 = 2'b01;       //forward mem res to alu
        else o_forward_if_id_rs2 = 2'b00;

        //FROM ALU & MEM to ID (for branches)
        if( i_id_ex_rf_write && i_id_ex_rd !='0 && i_id_ex_rd == i_if_id_rs1 )          o_forward_if_id_rs1 = 2'b10;        //forward alu res to id
        else if( i_ex_mem_rf_write && i_ex_mem_rd !='0 && i_ex_mem_rd == i_if_id_rs1 )  o_forward_if_id_rs1 = 2'b01;        //forward mem res to id
        else o_forward_id_ex_rs1 = 2'b00;

        if( i_id_ex_rf_write && i_id_ex_rd !='0 && i_id_ex_rd == i_if_id_rs2 )          o_forward_if_id_rs2 = 2'b10;        //forward alu res to id     
        else if( i_ex_mem_rf_write && i_ex_mem_rd !='0 && i_ex_mem_rd == i_if_id_rs2 )  o_forward_if_id_rs2 = 2'b01;        //forward mem res to id
        else o_forward_id_ex_rs2 = 2'b00;
    end

endmodule
