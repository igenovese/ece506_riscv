onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u_riscv_top/u_imem/IMEM
add wave -noupdate /tb/u_riscv_top/i_clock
add wave -noupdate /tb/u_riscv_top/i_reset
add wave -noupdate -group IFETCH /tb/u_riscv_top/u_ifetch/i_hazard_detected
add wave -noupdate -group IFETCH /tb/u_riscv_top/u_ifetch/i_branch_taken
add wave -noupdate -group IFETCH /tb/u_riscv_top/u_ifetch/i_branch_addr
add wave -noupdate -group IFETCH /tb/u_riscv_top/u_ifetch/o_instruction
add wave -noupdate -group IFETCH /tb/u_riscv_top/u_ifetch/o_pc
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/i_instruction
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/i_forward_rs1
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/i_forward_rs2
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/rs1
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/rs2
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/op1
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/op2
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/i_write
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/i_wr_addr
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/i_wr_value
add wave -noupdate -group IDECODE /tb/u_riscv_top/u_idecode/RF
add wave -noupdate -group EXECUTE /tb/u_riscv_top/u_execution_unit/i_instruction
add wave -noupdate -group EXECUTE /tb/u_riscv_top/u_execution_unit/i_forward_rs1
add wave -noupdate -group EXECUTE /tb/u_riscv_top/u_execution_unit/i_forward_rs2
add wave -noupdate -group EXECUTE /tb/u_riscv_top/u_execution_unit/op1
add wave -noupdate -group EXECUTE /tb/u_riscv_top/u_execution_unit/op2
add wave -noupdate -group EXECUTE /tb/u_riscv_top/u_execution_unit/imm
add wave -noupdate -group EXECUTE /tb/u_riscv_top/u_execution_unit/u_alu/i_operation
add wave -noupdate -group EXECUTE /tb/u_riscv_top/u_execution_unit/u_alu/i_arith_logic
add wave -noupdate -group EXECUTE /tb/u_riscv_top/u_execution_unit/u_alu/o_result
add wave -noupdate -group MEM /tb/u_riscv_top/u_memory_unit/i_wr_data
add wave -noupdate -group MEM /tb/u_riscv_top/u_memory_unit/i_wr_address
add wave -noupdate -group MEM /tb/u_riscv_top/u_memory_unit/o_read_data
add wave -noupdate -group MEM /tb/u_riscv_top/u_memory_unit/i_dmem_wr
add wave -noupdate -group WB /tb/u_riscv_top/wb_write_rf
add wave -noupdate -group WB /tb/u_riscv_top/wb_write_data
add wave -noupdate -group WB /tb/u_riscv_top/wb_write_addr
add wave -noupdate -group BRANCH /tb/u_riscv_top/u_branch_jump_unit/o_branch_taken
add wave -noupdate -group BRANCH /tb/u_riscv_top/u_branch_jump_unit/o_branch_addr
add wave -noupdate -group BRANCH /tb/u_riscv_top/u_branch_jump_unit/o_ret_addr
add wave -noupdate -group BRANCH /tb/u_riscv_top/u_branch_jump_unit/o_wr_retaddr
add wave -noupdate -group BRANCH /tb/u_riscv_top/u_branch_jump_unit/o_rd_retaddr
add wave -noupdate -group BRANCH /tb/u_riscv_top/u_branch_jump_unit/o_flush
add wave -noupdate -group HAZARD /tb/u_riscv_top/u_hazard_detection_unit/i_ex_is_load
add wave -noupdate -group HAZARD /tb/u_riscv_top/u_hazard_detection_unit/i_ex_rd
add wave -noupdate -group HAZARD /tb/u_riscv_top/u_hazard_detection_unit/i_id_rs1
add wave -noupdate -group HAZARD /tb/u_riscv_top/u_hazard_detection_unit/i_id_rs2
add wave -noupdate -group HAZARD /tb/u_riscv_top/u_hazard_detection_unit/i_branch_taken
add wave -noupdate -group HAZARD /tb/u_riscv_top/u_hazard_detection_unit/o_branch_hazard
add wave -noupdate -group HAZARD /tb/u_riscv_top/u_hazard_detection_unit/o_load_hazard
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_id_ex_rf_write
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_ex_mem_rf_write
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_mem_wb_rf_write
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_id_ex_rd
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_ex_mem_rd
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_mem_wb_rd
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_if_id_rs1
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_if_id_rs2
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_id_ex_rs1
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/i_id_ex_rs2
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/o_forward_if_id_rs1
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/o_forward_if_id_rs2
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/o_forward_id_ex_rs1
add wave -noupdate -group FORWARDING /tb/u_riscv_top/u_forwarding_unit/o_forward_id_ex_rs2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {911 ns}
