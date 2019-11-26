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
    imem_if         imem_interface();
    dmem_if         dmem_interface(.*);
    //Instruction fetch outputs
    instruction_t                   instruction;
    logic   [NB_WORD    - 1 : 0]    pc; 

    //Branch/Jump unit outputs
    logic                           branch_taken;
    logic   [NB_ADDR    - 1 : 0]    branch_addr;
    logic   [NB_ADDR    - 1 : 0]    ret_addr;
    logic                           wr_ret_addr;
    logic   [NB_OPERAND - 1 : 0]    rd_retaddr;
    logic                           flush;

    //Instruction decode outputs    
    logic   [NB_WORD    - 1 : 0]    op1;
    logic   [NB_WORD    - 1 : 0]    op2;
    logic   [NB_WORD    - 1 : 0]    immediate;
    control_bus_t                   control_bus;

    //Execution unit outputs
    logic   [NB_WORD    - 1 : 0]    ex_result;

    //Memory unit outputs
    logic   [NB_WORD    - 1 : 0]    mem_read_data;
    logic   [NB_WORD    - 1 : 0]    mem_fw_decode;

    //Writeback stage outputs   
    logic                           wb_write_rf;
    logic   [NB_WORD    - 1 : 0]    wb_write_data;    
    logic   [NB_OPERAND - 1 : 0]    wb_write_addr;
    
    //Hazard detection unit outputs
    logic                           branch_hazard_detected;
    logic                           load_hazard_detected;
    logic                           hazard_detected;

    //Forwarding unit outputs   
    logic   [1              : 0]    fw_decode_rs1;
    logic   [1              : 0]    fw_decode_rs2;
    logic   [1              : 0]    fw_ex_rs1;
    logic   [1              : 0]    fw_ex_rs2;

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
        .i_hazard_detected  ( load_hazard_detected      ),
        .i_branch_taken     ( branch_taken              ),
        .i_branch_addr      ( branch_addr               ),
        .o_instruction      ( instruction               ),
        .o_pc               ( pc                        )
    );

    //Intermediate registers
    instruction_t                   if_instruction_d;
    logic   [NB_WORD    - 1 : 0 ]   if_pc_d;

    always_ff @(posedge i_clock)
    if( i_reset )
    begin
        if_instruction_d    <= '0;
        if_pc_d             <= '0;
    end
    else if( !load_hazard_detected )
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
        .i_instruction      ( if_instruction_d          ),
        .i_op1              ( op1                       ), //from decoder
        .i_op2              ( op2                       ), //from decoder
        .o_branch_taken     ( branch_taken              ),
        .o_branch_addr      ( branch_addr               ),
        .o_ret_addr         ( ret_addr                  ),
        .o_wr_retaddr       ( wr_ret_addr               ),
        .o_rd_retaddr       ( rd_retaddr                ),
        .o_flush            ( flush                     )
    );
    
    logic   [NB_OPERAND - 1 : 0]    id_rs1;
    logic   [NB_OPERAND - 1 : 0]    id_rs2;          
    assign id_rs1 = if_instruction_d.r_type.rs1;
    assign id_rs2 = if_instruction_d.r_type.rs2;   

    hazard_detection_unit u_hazard_detection_unit(
        .i_ex_is_load       ( id_control_bus_d.dmem_rd  ), //instruction in EX is load
        .i_ex_rd            ( id_control_bus_d.rd       ), //instruction in EX rd
        .i_id_rs1           ( id_rs1                    ), //
        .i_id_rs2           ( id_rs2                    ),
        .i_branch_taken     ( branch_taken              ),
        .o_branch_hazard    ( branch_hazard_detected    ),
        .o_load_hazard      ( load_hazard_detected      )
    );

    assign hazard_detected = ( branch_hazard_detected || load_hazard_detected );

    idecode u_idecode(
        .i_clock            ( i_clock                   ),
        .i_reset            ( i_reset                   ),
        .i_instruction      ( if_instruction_d          ),
        .i_forward_rs1      ( fw_decode_rs1             ), //from forwarding unit
        .i_forward_rs2      ( fw_decode_rs2             ),
        .i_alu_result       ( ex_result                 ), //alu result 
        .i_mem_result       ( mem_fw_decode             ),
        .i_wr_retaddr       ( wr_ret_addr               ),
        .i_rd_retaddr       ( rd_retaddr                ),
        .i_ret_addr         ( ret_addr                  ),
        .i_write            ( wb_write_rf               ), //from WB stage
        .i_wr_addr          ( wb_write_addr             ),
        .i_wr_value         ( wb_write_data             ),
        .o_op1              ( op1                       ),
        .o_op2              ( op2                       ),
        .o_imm              ( immediate                 )
    );

    control_unit u_control_unit(
        .i_instruction      ( if_instruction_d          ),
        .o_control_bus      ( control_bus               )
    );

    //Intermediate Registers
    instruction_t                   id_instruction_d;
    logic   [NB_WORD    - 1 : 0]    id_pc_d;
    logic   [NB_WORD    - 1 : 0]    id_op1_d;
    logic   [NB_WORD    - 1 : 0]    id_op2_d;
    logic   [NB_WORD    - 1 : 0]    id_imm_d;
    control_bus_t                   id_control_bus_d;

    logic flush_d;

    always_ff @( posedge i_clock )
    if( i_reset )
    begin
        id_instruction_d    <= '0;
        id_pc_d             <= '0;
        id_op1_d            <= '0;
        id_op2_d            <= '0;
        id_imm_d            <= '0;
        id_control_bus_d    <= '0;
        flush_d             <= '0;
    end
    else
    begin
        id_instruction_d    <= if_instruction_d;
        id_pc_d             <= if_pc_d;
        id_op1_d            <= op1;
        id_op2_d            <= op2;
        id_imm_d            <= immediate;
        flush_d             <= flush;
        id_control_bus_d    <= (hazard_detected || flush_d ) ? '0 : control_bus; 
    end
    
    //----------------------------------------------------------------
    //------------------------------------------------ Execution stage
    //Intermediate registers    
    logic   [NB_WORD    - 1 : 0]    ex_op2_d;    
    control_bus_t                   ex_control_bus_d;
    logic   [NB_WORD    - 1 : 0]    ex_result_d;
    

    execution_unit u_execution_unit(
        .i_clock                    ( i_clock           ),
        .i_reset                    ( i_reset           ),
        .i_control_bus              ( id_control_bus_d  ),
        .i_op1                      ( id_op1_d          ),
        .i_op2                      ( id_op2_d          ),
        .i_immediate                ( id_imm_d          ),
        .i_instruction              ( id_instruction_d  ),
        .i_pc                       ( id_pc_d           ),
        .i_forward_rs1              ( fw_ex_rs1         ), //from forwarding unit
        .i_forward_rs2              ( fw_ex_rs2         ),
        .i_ex_mem_alu_res           ( ex_result_d       ), //from intermediate reg ex_mem
        .i_wb_res                   ( wb_write_data     ), //from intermediate reg mem_wb
        .o_result                   ( ex_result         )
    );


    always_ff @( posedge i_clock )
    if( i_reset )
    begin        
        ex_op2_d            <= '0;        
        ex_control_bus_d    <= '0;
        ex_result_d         <= '0;
    end
    else
    begin        
        ex_op2_d            <= id_op2_d;        
        ex_control_bus_d    <= id_control_bus_d;
        ex_result_d         <= ex_result;
    end

    //----------------------------------------------------------------
    //--------------------------------------------------- Memory stage
    memory_unit u_memory_unit(
        .i_clock                    ( i_clock                       ),
        .i_reset                    ( i_reset                       ),
        .i_dmem_wr                  ( ex_control_bus_d.dmem_wr      ), //write to mem
        .i_wr_data                  ( ex_op2_d                      ), //wr data, op2
        .i_address                  ( ex_result_d                   ), //ALU calculates  address
        .DMEM_IF                    ( dmem_interface.cpu            ),
        .i_ld_st_funct3             ( ex_control_bus_d.ld_st_funct3 ), 
        .o_read_data                ( mem_read_data                 )
    );

    assign mem_fw_decode = ( ex_control_bus_d.dmem_rd ) ? mem_read_data : ex_result_d ; 

    //Intermediate registers
    control_bus_t                   mem_control_bus_d;
    logic   [NB_WORD    - 1 : 0]    mem_read_data_d;
    logic   [NB_WORD    - 1 : 0]    mem_ex_result_d;
    always_ff @( posedge i_clock )
    if( i_reset )
    begin        
        mem_control_bus_d   <= '0;
        mem_read_data_d     <= '0;
        mem_ex_result_d     <= '0;
    end
    else
    begin        
        mem_control_bus_d   <= ex_control_bus_d;
        mem_read_data_d     <= mem_read_data;
        mem_ex_result_d     <= ex_result_d;
    end


    //----------------------------------------------------------------
    //------------------------------------------------ Writeback stage
    assign wb_write_data    = ( mem_control_bus_d.wb_to_rf ) ? mem_read_data_d : mem_ex_result_d;
    assign wb_write_rf      = mem_control_bus_d.rf_wr;
    assign wb_write_addr    = mem_control_bus_d.rd;
    
    
    //----------------------------------------------------------------
    //------------------------------------------------ Forwarding Unit

    forwarding_unit u_forwarding_unit (
        .i_id_ex_rf_write           ( id_control_bus_d.rf_wr        ),
        .i_ex_mem_rf_write          ( ex_control_bus_d.rf_wr        ),
        .i_mem_wb_rf_write          ( mem_control_bus_d.rf_wr       ),
        .i_id_ex_rd                 ( id_control_bus_d.rd           ),
        .i_ex_mem_rd                ( ex_control_bus_d.rd           ),
        .i_mem_wb_rd                ( mem_control_bus_d.rd          ),
        .i_if_id_rs1                ( if_instruction_d.r_type.rs1   ),
        .i_if_id_rs2                ( if_instruction_d.r_type.rs2   ),
        .i_id_ex_rs1                ( id_instruction_d.r_type.rs1   ),
        .i_id_ex_rs2                ( id_instruction_d.r_type.rs2   ),
        .o_forward_if_id_rs1        ( fw_decode_rs1                 ),
        .o_forward_if_id_rs2        ( fw_decode_rs2                 ),
        .o_forward_id_ex_rs1        ( fw_ex_rs1                     ),
        .o_forward_id_ex_rs2        ( fw_ex_rs2                     )
    );

endmodule



