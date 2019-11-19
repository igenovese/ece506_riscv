/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the instruction decode logic
**/
import riscv_defs::*;

module idecode(
    input   logic                           i_clock,
    input   logic                           i_reset,
    input   logic   [NB_WORD    - 1 : 0]    i_instruction,
    input   logic   [1:0]                   i_forward_rs1,  //control signal, for forwarding alu result or mem result 
    input   logic   [1:0]                   i_forward_rs2,
    input   logic   [NB_WORD    - 1 : 0]    i_alu_result,
    input   logic   [NB_WORD    - 1 : 0]    i_mem_result,
    input   logic                           i_wr_retaddr,
    input   logic   [NB_OPERAND - 1 : 0]    i_rd_retaddr,
    input   logic   [NB_ADDR    - 1 : 0]    i_ret_addr,
    input   logic                           i_write,
    input   logic   [NB_ADDR    - 1 : 0]    i_wr_addr,
    input   logic   [NB_WORD    - 1 : 0]    i_wr_value,
    output  logic   [NB_WORD    - 1 : 0]    o_rs1,
    output  logic   [NB_WORD    - 1 : 0]    o_rs2,
    output  logic   [NB_WORD    - 1 : 0]    o_imm

);
    
    //Register file instance
    register_file_t                         RF;

    //Instruction casting
    instruction_t   instruction = i_instruction;

    //Source addresses
    logic   [NB_OPERAND - 1 : 0]            op1;
    logic   [NB_OPERAND - 1 : 0]            op2;

    //Intermediate values
    logic   [NB_WORD    - 1 : 0]            rs1;
    logic   [NB_WORD    - 1 : 0]            rs2;

    //Write registers
    always_ff @(posedge i_clock)
    if( i_reset )
        RF <= '0;
    else
    begin
        if( i_wr_retaddr )
            RF[i_rd_retaddr]    <= i_ret_addr;

        if( i_write )
            RF[i_wr_addr]       <= i_wr_value;
    end

    //Read registers
    assign op1 = instruction.r_type.rs1;
    assign op2 = instruction.r_type.rs2;

    always_comb
    case( i_forward_rs1 ):
        2'b00:
            rs1 = RF[op1];
        2'b01:
            rs1 = i_alu_result;
        2'b10:
            rs2 = i_mem_result;
        default:
            rs1 = RF[op1];  

    always_comb
    case( i_forward_rs2 ):
        2'b00:
            rs2 = RF[op2];
        2'b01:
            rs2 = i_alu_result;
        2'b10:
            rs2 = i_mem_result;
        default:
            rs2 = RF[op2];

    always_ff @( posedge i_clock )
    if( i_reset )
    begin
        o_rs1   <= '0;
        o_rs2   <= '0;
    end
    else
    begin
        o_rs1   <= rs1;
        o_rs2   <= rs2;
    end

    //Decode immediate
    always_ff @( posedge i_clock )
    if( i_reset )
        o_imm <= '0;
    else
        case( instruction.r_type.opcode ):
            STORE:
                o_imm <= 32'(signed'({ instruction.s_type.upper_imm,
                                        instruction.s_type.lower_imm }));
            LUI: AUIPC:
                o_imm <= { instruction.u_type.imm, 12'd0 };
            default:                
                o_imm <= 32'(signed'(instruction.i_type.imm)) ;
        endcase

endmodule