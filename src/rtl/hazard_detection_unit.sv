/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file detect hazards:
- when instruction in EX is load and its destination register is 
one of the source registers of the current instruction
- when instruction is a taken branch and address of the branch is
needed for executing the next instruction
**/
module hazard_detection_unit(
    input   logic                           i_ex_is_load,
    input   logic   [NB_OPERAND - 1 : 0]    i_ex_rd,
    input   logic   [NB_OPERAND - 1 : 0]    i_id_rs1,
    input   logic   [NB_OPERAND - 1 : 0]    i_id_rs2,
    input   logic                           i_branch_taken,
    output  logic                           o_branch_hazard,
    output  logic                           o_load_hazard    
);
    
    always_comb
    begin
        o_branch_hazard = 1'b0;
        o_load_hazard   = i_branch_taken;
        if( i_ex_is load && ( i_ex_rd == i_id_rs1 || i_ex_rd == i_id_rs2 ))
        begin            
            o_load_hazard   = 1'b1;
        end
        else if
    end

endmodule
