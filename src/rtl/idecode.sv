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
    input   logic   [NB_OPERAND - 1 : 0]    i_wr_addr,
    input   logic   [NB_WORD    - 1 : 0]    i_wr_value,
    output  logic   [NB_WORD    - 1 : 0]    o_op1,
    output  logic   [NB_WORD    - 1 : 0]    o_op2,
    output  logic   [NB_WORD    - 1 : 0]    o_imm

);
    
    //Register file instance
    register_file_t                         RF;

    //Instruction casting
    instruction_t   instruction ;

    //Source addresses
    logic   [NB_OPERAND - 1 : 0]            rs1;
    logic   [NB_OPERAND - 1 : 0]            rs2;

    //Intermediate values
    logic   [NB_WORD    - 1 : 0]            op1;
    logic   [NB_WORD    - 1 : 0]            op2;

    //Write registers
    always_ff @(posedge i_clock)
    if( i_reset )
        RF <= '{default:'0};
    else
    begin
        if( i_wr_retaddr && i_rd_retaddr != '0 )
            RF.R[i_rd_retaddr]    <= i_ret_addr;

        if( i_write && i_wr_addr != '0)
            RF.R[i_wr_addr]       <= i_wr_value;
    end

    //Read registers
    assign instruction = i_instruction;
    assign rs1 = instruction.r_type.rs1;
    assign rs2 = instruction.r_type.rs2;

    always_comb
    case( i_forward_rs1 )
        2'b00:
            op1 = RF.R[rs1];
        2'b01:
            op1 = i_alu_result;
        2'b10:
            op1 = i_mem_result;
        default:
            op1 = RF.R[rs1];  
    endcase

    always_comb
    case( i_forward_rs2 )
        2'b00:
            op2 = RF.R[rs2];
        2'b01:
            op2 = i_alu_result;
        2'b10:
            op2 = i_mem_result;
        default:
            op2 = RF.R[rs2];
    endcase

    //Assign outputs
    assign  o_op1   = op1;
    assign  o_op2   = op2;
    
    //Decode immediate
    always_comb    
    case( instruction.r_type.opcode )
        STORE:
            o_imm = 32'(signed'({   instruction.s_type.upper_imm,
                                    instruction.s_type.lower_imm    }));
        LUI: AUIPC:
            o_imm = { instruction.u_type.imm, 12'd0 };
        default:                
            o_imm = 32'(signed'(instruction.i_type.imm)) ;
    endcase

endmodule