/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this module produce control signals based on 
decoded instruction
**/
import riscv_defs::*;

module control_unit(
    input   logic   [NB_WORD    - 1 : 0]    i_instruction,
    output  control_bus_t                   o_control_bus
);
    
    //For casting
    instruction_t   instruction;
    assign instruction =  i_instruction;

    always_comb
    begin
        o_control_bus.alu_src1      = '0;
        o_control_bus.alu_src2      = '0;
        o_control_bus.alu_op        = '0;
        o_control_bus.arith_logic   = '0;
        o_control_bus.rd            = '0;
        o_control_bus.dmem_rd       = '0;
        o_control_bus.dmem_wr       = '0;
        o_control_bus.ld_st_funct3  = '0;
        o_control_bus.rf_wr         = '0;
        o_control_bus.wb_to_rf      = '0;
        case( instruction.r_type.opcode )
            LUI:
            begin
                o_control_bus.alu_src1          = 1'b1; //Uses pc value (for AUIPC)
                o_control_bus.alu_src2          = 1'b1; //Uses immediate value
                o_control_bus.rd                = instruction.u_type.rd;
                o_control_bus.rf_wr             = 1'b1; //results goes to register
                o_control_bus.wb_to_rf          = 1'b0; //result to rf comes from ALU
            end
            AUIPC:
            begin
                o_control_bus.alu_src1          = 1'b1; //Uses pc value (for AUIPC)
                o_control_bus.alu_src2          = 1'b1; //Uses immediate value
                o_control_bus.rd                = instruction.u_type.rd;
                o_control_bus.rf_wr             = 1'b1; //results goes to register
                o_control_bus.wb_to_rf          = 1'b0; //result to rf comes from ALU
            end            
            LOAD:
            begin
                o_control_bus.alu_src2          = 1'b1; //Uses immediate value
                o_control_bus.rd                = instruction.i_type.rd;
                o_control_bus.dmem_rd           = 1'b1; //read mem
                o_control_bus.ld_st_funct3      = instruction.i_type.funct3; 
                o_control_bus.rf_wr             = 1'b1; //write rf
                o_control_bus.wb_to_rf          = 1'b1; //resutl to rf comes from mem
            end
            STORE: //alu op is add always ('0)
            begin
                o_control_bus.alu_src2          = 1'b1; //Uses immediate value
                o_control_bus.rd                = instruction.s_type.rs2; //value to write to mem comes from rs2
                o_control_bus.dmem_wr           = 1'b1; //write mem
                o_control_bus.ld_st_funct3      = instruction.s_type.funct3;                 
            end
            IMMEDIATE:
            begin
                o_control_bus.alu_src2          = 1'b1;//uses immediate value
                o_control_bus.alu_op            = instruction.i_type.funct3;
                o_control_bus.rd                = instruction.i_type.rd;
                o_control_bus.rf_wr             = 1'b1; //writes register
                o_control_bus.wb_to_rf          = 1'b0; //result to register comes from alu
                o_control_bus.arith_logic       = |(instruction.r_type.funct7);
            end
            R_R:
            begin                
                o_control_bus.alu_op            = instruction.r_type.funct3;
                o_control_bus.rd                = instruction.r_type.rd;
                o_control_bus.rf_wr             = 1'b1; //writes register
                o_control_bus.wb_to_rf          = 1'b0; //result to register comes from alu
                o_control_bus.arith_logic       = |(instruction.r_type.funct7);
            end
        endcase
    end

endmodule