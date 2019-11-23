/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this module contains the ALU and performs execution
**/
import riscv_defs::*;

module execution_unit(
    input   logic                           i_clock,
    input   logic                           i_reset,
    input   control_bus_t                   i_control_bus,
    input   logic   [NB_WORD    - 1 : 0]    i_op1,
    input   logic   [NB_WORD    - 1 : 0]    i_op2,
    input   logic   [NB_WORD    - 1 : 0]    i_immediate,
    input   logic   [NB_WORD    - 1 : 0]    i_instruction,
    input   logic   [NB_WORD    - 1 : 0]    i_pc,
    input   logic   [1              : 0]    i_forward_rs1,  //control signal, for forwarding alu result or mem result 
    input   logic   [1              : 0]    i_forward_rs2,
    input   logic   [NB_WORD    - 1 : 0]    i_ex_mem_alu_res,
    input   logic   [NB_WORD    - 1 : 0]    i_wb_res,
    output  logic   [NB_WORD    - 1 : 0]    o_result
);

    logic   [NB_WORD    - 1 : 0]    op1;
    logic   [NB_WORD    - 1 : 0]    op2;
    logic   [NB_WORD    - 1 : 0]    imm;

    //For casting
    instruction_t   instruction;
    assign instruction  = i_instruction;


    assign op1 = ( i_control_bus.alu_src1 ) ? i_pc              : 
                 ( i_forward_rs1 == 2'b10 ) ? i_ex_mem_alu_res  : 
                 ( i_forward_rs1 == 2'b01 ) ? i_wb_res          : 
                 i_op1 ;

    assign op2 = ( i_control_bus.alu_src2 ) ? imm               : 
                 ( i_forward_rs2 == 2'b10 ) ? i_ex_mem_alu_res  : 
                 ( i_forward_rs2 == 2'b01 ) ? i_wb_res          : 
                 i_op2 ;

    assign imm = i_immediate;

    always_comb
    begin
    end

    alu u_alu(
        .i_op1          ( op1                       ),
        .i_op2          ( op2                       ),
        .i_operation    ( i_control_bus.alu_op      ),
        .i_arith_logic  ( i_control_bus.arith_logic ),
        .o_result       ( o_result                  )
    );


endmodule