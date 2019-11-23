/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the instruction read-only memory 
**/
import riscv_defs::*;

module imem(
    imem_if.memory                      IMEM_IF  
);

    logic   [NB_BYTE    - 1 : 0]        IMEM[MEM_SIZE];

    //Read operation    
    assign  IMEM_IF.imem_instruction  = { IMEM[IMEM_IF.imem_pc+3],
                                          IMEM[IMEM_IF.imem_pc+2],
                                          IMEM[IMEM_IF.imem_pc+1],
                                          IMEM[IMEM_IF.imem_pc]  };
    

endmodule
