/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this module performs ALU operations
**/
import riscv_defs::*;

module alu(
        input   logic   [NB_WORD    - 1 : 0]    i_rs1,
        input   logic   [NB_WORD    - 1 : 0]    i_rs2,
        input   logic   [NB_FUNCT3  - 1 : 0]    i_operation,
        input   logic                           i_arith_logic,
        output  logic   [NB_WORD    - 1 : 0]    o_result  
);

    always_comb
    begin
        case( i_operation ):
            r_funct3::F3_ADD_SUB: //ADD, SUB, ADDI, STORES & LOADS ADDRESS CALC  //[TOCHECK]
                o_result = (i_arith_logic) ? i_rs1 - i_rs2 : i_rs1 + i_rs2;
            r_funct3::F3_SLL: //SLL, SSLI
                o_result = i_rs1 << i_rs2[4:0];
            r_funct3::F3_SLT: //SLT, SLTI
                o_result = ( signed'(i_rs1) < signed'(i_rs2) ) ? { NB_WORD-1{1'b0}, 1'b1} : '0;
            r_funct3::F3_SLTU: //SLTU, SLTIU
                o_result = ( unsigned'(i_rs1) < unsigned'(i_rs2) ) ? { NB_WORD-1{1'b0}, 1'b1} : '0;
            r_funct3::F3_XOR: //XOR, XORI
                o_result = i_rs1 ^ i_rs2;
            r_funct3::F3_SRL_SRA: //SRL, SRA, SRLI, SRAI -> check arith logic
                o_result = ( i_arith_logic ) ? i_rs1 >>> i_rs2[4:0] : i_rs1 >> i_rs2[4:0] ;
            r_funct3::F3_OR: //OR, ORI
                o_result = i_rs1 | i_rs2;
            r_funct3::F3_AND: //AND, ANDI
                o_result = i_rs1 & i_rs2;
            default:
                o_result = '0;
        endcase
    end


endmodule