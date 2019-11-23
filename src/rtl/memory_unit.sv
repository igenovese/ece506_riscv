/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the data memory unit, performs 
read & writes
**/

import riscv_defs::*;

module memory_unit(
    input   logic                           i_clock,
    input   logic                           i_reset,
    input   logic                           i_dmem_wr,
    input   logic   [NB_WORD    - 1 : 0]    i_wr_data,
    input   logic   [NB_ADDR    - 1 : 0]    i_wr_address, //[FIXME] rename to address
    dmem_if.cpu                             DMEM_IF,
    input   logic   [NB_FUNCT3  - 1 : 0]    i_ld_st_funct3,
    output  logic   [NB_WORD    - 1 : 0]    o_read_data
);

    logic   [NB_WORD    - 1 : 0]    aux_wr_data;
    logic   [NB_WORD    - 1 : 0]    aux_rd_data;

    //Set data to write
    always_comb
    begin
        case( i_ld_st_funct3 )
            F3_SB:
                aux_wr_data = {24'd0, i_wr_data[7:0]};
            F3_SH:
                aux_wr_data = {16'd0, i_wr_data[15:0]};
            F3_SW:
                aux_wr_data = i_wr_data;
            default:
                aux_wr_data = i_wr_data;
        endcase
    end

    always_comb
    begin
        DMEM_IF.dmem_address    = i_wr_address;
        DMEM_IF.dmem_wr_data    = aux_wr_data;
        DMEM_IF.dmem_wr_enable  = i_dmem_wr;
    end

    //Truncate read data
    always_comb
    begin
        case( i_ld_st_funct3 )
            F3_LB:
                aux_rd_data = 32'(signed'(DMEM_IF.dmem_rd_data[7:0]));
            F3_LH:
                aux_rd_data = 32'(signed'(DMEM_IF.dmem_rd_data[15:0]));
            F3_LW:
                aux_rd_data = DMEM_IF.dmem_rd_data;
            F3_LBU:
                aux_rd_data = {24'd0, DMEM_IF.dmem_rd_data[7:0]};
            F3_LHU:
                aux_rd_data = {16'd0, DMEM_IF.dmem_rd_data[15:0]};
            default:
                aux_rd_data = DMEM_IF.dmem_rd_data;
        endcase
    end

    assign o_read_data = aux_rd_data;

endmodule
