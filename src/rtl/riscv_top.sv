/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the RISC V top module
**/
import riscv_defs::*;

module riscv_top(
    input   logic   i_clock,
    input   logic   i_reset
);

    //----------------------------------------------------------------
    //                      SIGNALS DECLARATION
    //----------------------------------------------------------------
    //Interfaces
    IMEM_IF         imem_interface();
    DMEM_IF         dmem_interface(.*);
    //Instruction fetch outputs
    logic   [NB_WORD    - 1 : 0]    instruction;
    logic   [NB_WORD    - 1 : 0]    pc; 

    //Branch/Jump unit outputs
    logic                           branch_taken;
    logic   [NB_ADDR    - 1 : 0]    branch_addr;
    logic   [NB_ADDR    - 1 : 0]    ret_addr;
    logic                           wr_ret_addr;
    logic                           rd_retaddr;
    logic                           flush;

    //Instruction decode outputs    
    logic   [NB_WORD    - 1 : 0]    rs1;
    logic   [NB_WORD    - 1 : 0]    rs2;
    logic   [NB_WORD    - 1 : 0]    immediate;
    control_bus_t                   control_bus;

    
    //Hazard detection unit outputs
    logic                           branch_hazard_detected;
    logic                           load_hazard_detected;
    logic                           hazard_detected;

    //----------------------------------------------------------------
    //                      MODULES INSTANTIATION
    //----------------------------------------------------------------
    //Instruction Memory
    imem u_imem( 
        .IMEM_IF            ( imem_interface.memory     ) 
    );
    
    //Data Memory
    dmem u_dmem( 
        .DMEM_IF            ( dmem_interface.memory     ) 
    );

    //----------------------------------------------------------------
    //---------------------------------------- Instruction Fetch stage
    ifetch u_ifetch(
        .IMEM_IF            ( imem_interface.cpu        ),        
        .i_clock            ( i_clock                   ),
        .i_reset            ( i_reset                   ),
        .i_hazard_detected  ( branch_hazard_detected    ),
        .i_branch_taken     ( branch_taken              ),
        .i_branch_addr      ( branch_addr               ),
        .o_instruction      ( instruction               ),
        .o_pc               ( pc                        )
    );

    //Intermediate registers
    logic   [NB_WORD    - 1 : 0 ]   if_instruction_d;
    logic   [NB_WORD    - 1 : 0 ]   if_pc_d;

    always_ff @(posedge i_clock)
    if( i_reset )
    begin
        if_instruction_d    <= '0;
        if_pc_d             <= '0;
    end
    else
    begin
        if_instruction_d    <= instruction;
        if_pc_d             <= pc;
    end

    //----------------------------------------------------------------
    //--------------------------------------- Instruction Decode stage
    branch_jump_unit u_branch_jump_unit(
        .i_clock            ( i_clock                   ),
        .i_reset            ( i_reset                   ),
        .i_pc               ( if_pc_d                   ),
        .i_instruction      ( if_instruction_d          ).
        .i_rs1              ( rs1                       ), //from decoder
        .i_rs2              ( rs2                       ), //from decoder
        .o_branch_taken     ( branch_taken              ),
        .o_branch_addr      ( branch_addr               ),
        .o_ret_addr         ( ret_addr                  ),
        .o_wr_retaddr       ( wr_ret_addr               ),
        .o_rd_retaddr       ( rd_retaddr                ),
        .o_flush            ( flush                     )
    );

    instruction_t                   id_instruction  = if_instruction_d;
    logic   [NB_OPERAND - 1 : 0]    id_op1          = id_instruction.r_type.rs1;
    logic   [NB_OPERAND - 1 : 0]    id_op2          = id_instruction.r_type.rs1;   

    hazard_detection_unit u_hazard_detection_unit(
        .i_ex_is_load       (),
        .i_ex_rd            (),
        .i_id_rs1           ( id_op1                    ),
        .i_id_rs2           ( id_op2                    ),
        .i_branch_taken     ( branch_taken              ),
        .o_branch_hazard    ( branch_hazard_detected    ),
        .o_load_hazard      ( load_hazard_detected      )
    );

    assign hazard_detected = ( branch_hazard_detected || load_hazard_detected );

    idecode u_idecode(
        .i_clock            ( i_clock                   ),
        .i_reset            ( i_reset                   ),
        .i_instruction      ( if_instruction_d          ),
        .i_forward_rs1      ( ), //from forwarding unit
        .i_forward_rs2      ( ),
        .i_alu_result       ( ),
        .i_mem_result       ( ),
        .i_wr_retaddr       ( wr_ret_addr               ),
        .i_rd_retaddr       ( rd_retaddr                ),
        .i_ret_addr         ( ret_addr                  ),
        .i_write            (), //from WB stage
        .i_wr_addr          (),
        .i_wr_value         (),
        .o_rs1              ( rs1                       ),
        .o_rs2              ( rs2                       ),
        .o_imm              ( immediate                 )
    );

    control_unit u_control_unit(
        .i_instruction      ( if_instruction_d          ),
        .o_control_bus      ( control_bus               )
    );

    //Intermediate Registers
    logic   [NB_WORD    - 1 : 0]    id_instruction_d;
    logic   [NB_WORD    - 1 : 0]    id_pc_d;
    logic   [NB_WORD    - 1 : 0]    id_rs1_d;
    logic   [NB_WORD    - 1 : 0]    id_rs2_d;
    logic   [NB_WORD    - 1 : 0]    id_imm_d;
    control_bus_t                   id_control_bus_d;

    always_ff @( posedge i_clock )
    if( i_reset )
    begin
        id_instruction_d    <= '0;
        id_pc_d             <= '0;
        id_rs1_d            <= '0;
        id_rs2_d            <= '0;
        id_imm_d            <= '0;
        id_control_bus_d    <= '0;
    end
    else
    begin
        id_instruction_d    <= if_instruction_d;
        id_pc_d             <= if_pc_d;
        id_rs1_d            <= rs1;
        id_rs2_d            <= rs2;
        id_imm_d            <= immediate;
        id_control_bus_d    <= (hazard_detected || flush ) ? '0 : control_bus; 
    end
    
    //----------------------------------------------------------------
    //------------------------------------------------ Execution stage
    execution_unit u_execution_unit(
        .i_clock            ( i_clock           ),
        .i_reset            ( i_reset           ),
        .i_control_bus      ( id_control_bus_d  ),
        .i_rs1              ( id_rs1_d          ),
        .i_rs2              ( id_rs2_d          ),
        .i_immediate        ( id_imm_d          ),
        .i_instruction      ( id_instruction_d  ),
        .i_pc               ( id_pc_d           ),
        .i_forward_rs1,     ( ), //from forwarding unit
        .i_forward_rs2      ( ),
        .i_ex_mem_alu_res   ( ), //from mem
        .i_wb_res           ( ), //from wb
        .o_result           ( )
    );

endmodule



