/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the logic for branch and 
              jump instructions
**/
import riscv_defs::*;

module branch_jump_unit(
    input   logic                           i_clock,
    input   logic                           i_reset,
    input   logic   [NB_WORD    - 1 : 0]    i_pc,
    input   logic   [NB_WORD    - 1 : 0]    i_instruction,
    input   logic   [NB_WORD    - 1 : 0]    i_rs1,
    input   logic   [NB_WORD    - 1 : 0]    i_rs2,
    output  logic                           o_branch_taken,
    output  logic   [NB_ADDR    - 1 : 0]    o_branch_addr,
    output  logic   [NB_ADDR    - 1 : 0]    o_ret_addr,
    output  logic                           o_wr_retaddr,
    output  logic   [NB_OPERAND - 1 : 0]    o_rd_retaddr,
    output  logic                           o_flush
);

    instruction_t   instruction     = i_instruction;    //cast
    
    logic   [20:0]  j_type_offset   = { instruction.j_type.imm20,
                                        instruction.j_type.imm19_12,
                                        instruction.j_type.imm11,
                                        instruction.j_type.imm10_1,
                                        1'b0 };    

    logic   [11:0]  i_type_offset   = instruction.i_type.imm;

    logic   [12:0]  b_type_imm      = {
                                        instruction.b_type.imm12,
                                        instruction.b_type.imm11,
                                        instruction.b_type.imm10_5,
                                        instruction.b_type.imm4_1,
                                        1'b0 };          


    always_comb    
    begin
        o_branch_taken  = '0;
        o_branch_addr   = '0;
        o_ret_addr      = '0;
        o_wr_retaddr    = '0;        
        o_rd_retaddr    = '0;
        o_flush         = '0;
        case( instruction.r_type.opcode ):
            JAL:
            begin
                o_branch_taken  = 1'b1;
                o_branch_addr   = i_pc + j_type_offset - 32'd4; //i_pc is the address of the next instruction, and I need the address of the jump instruction
                o_ret_addr      = i_pc;     //[TOCHECK] already added +4?
                o_wr_retaddrr   = 1'b1;
                o_rd_retaddr    = instruction.j_type.rd;
                o_flush         = 1'b1;
            end
            JALR:
            begin
                o_branch_taken  = 1'b1;
                o_branch_addr   = (i_pc + i_type_offset - 32'd4) ^ -2; //^-2 sets the lsb to 0
                o_ret_addr      = i_pc;     //[TOCHECK] already added +4?
                o_wr_retaddrr   = 1'b1;
                o_rd_retaddr    = instruction.i_type.rd;
                o_flush         = 1'b1;
            end
            BRANCH:
            case( instruction.b_type.funct3 )                
                branch_funct3::F3_BEQ :
                begin
                    o_branch_taken  = (i_rs1 == i_rs2 );
                    o_branch_addr   = (i_rs1 == i_rs2 ) ? i_pc + 32'b(signed'(b_type_imm)) - 32'd4;
                end
                branch_funct3::F3_BNE :
                begin
                    o_branch_taken  = (i_rs1 != i_rs2 );
                    o_branch_addr   = (i_rs1 != i_rs2 ) ? i_pc + 32'b(signed'(b_type_imm)) - 32'd4;
                end
                branch_funct3::F3_BLT :
                begin
                    o_branch_taken  = (signed'(i_rs1) < signed'(i_rs2) );
                    o_branch_addr   = (signed'(i_rs1) < signed'(i_rs2) ) ? i_pc + 32'b(signed'(b_type_imm)) - 32'd4;
                end
                branch_funct3::F3_BGE :
                begin
                    o_branch_taken  = (signed'(i_rs1) >= signed'(i_rs2) );
                    o_branch_addr   = (signed'(i_rs1) >= signed'(i_rs2) ) ? i_pc + 32'b(signed'(b_type_imm)) - 32'd4;
                end
                branch_funct3::F3_BLTU:
                begin
                    o_branch_taken  = (unsigned'(i_rs1) < unsigned'(i_rs2) );
                    o_branch_addr   = (unsigned'(i_rs1) < unsigned'(i_rs2) ) ? i_pc + 32'b(signed'(b_type_imm)) - 32'd4;
                end
                branch_funct3::F3_BGEU:
                begin
                    o_branch_taken  = (unsigned'(i_rs1) >= unsigned'(i_rs2) );
                    o_branch_addr   = (unsigned'(i_rs1) >= unsigned'(i_rs2) ) ? i_pc + 32'b(signed'(b_type_imm)) - 32'd4;
                end
        endcase
    end


endmodule

              //opcode                  //funct3
//JAL         = 7'b1101111, /*Type J*/
//JALR        = 7'b1100111, /*Type I*/    F3_JALR     = 3'b000,
//BEQ         = 7'b1100011, /*Type B*/    F3_BEQ      = 3'b000, 
//BNE         = 7'b1100011, /*Type B*/    F3_BNE      = 3'b001,
//BLT         = 7'b1100011, /*Type B*/    F3_BLT      = 3'b100,
//BGE         = 7'b1100011, /*Type B*/    F3_BGE      = 3'b101,
//BLTU        = 7'b1100011, /*Type B*/    F3_BLTU     = 3'b110,
//BGEU        = 7'b1100011, /*Type B*/    F3_BGEU     = 3'b111,
