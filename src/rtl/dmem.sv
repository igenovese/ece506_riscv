/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the data memory 
**/
import riscv_defs::*;

module dmem(
    dmem_if.memory                      DMEM_IF,    
);

    logic   [NB_BYTE    - 1 : 0]    DMEM[MEM_SIZE];

    //Read operation
    always_comb
    begin
        DMEM_IF.dmem_rd_data    = { DMEM[DMEM_IF.dmem_address+3],
                                    DMEM[DMEM_IF.dmem_address+2,]
                                    DMEM[DMEM_IF.dmem_address+1],
                                    DMEM[DMEM_IF.dmem_address]  };
    end

    //Write operation
    always_ff @(posedge DMEM_IF.i_clock)
    if( DMEM_IF.dmem_wr_enable )
        { DMEM[DMEM_IF.dmem_address+3],
          DMEM[DMEM_IF.dmem_address+2],
          DMEM[DMEM_IF.dmem_address+1],
          DMEM[DMEM_IF.dmem_address]  } <= DMEM_IF.dmem_wr_data;

endmodule
