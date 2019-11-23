/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains the testbench
[FIXME] complete description
**/

import riscv_defs::*;

module tb();

    localparam  CLK_PERIOD  = 10;
    localparam  N_TESTS     = 1;

    logic       clock = 0;
    logic       reset;    
    string      current_test;
    int         test_errors  = 0;
    int         total_errors = 0;


    string  test_name[N_TESTS] = '{
                                    "test"
                                };

    string  testcases[N_TESTS] = '{
                                    "../src/tb/testcases/test" //will be run in sim folder
                                };

    string  rf_results[N_TESTS] = '{
                                    "../src/tb/testcases/test_rf" //will be run in sim folder
                                };

    string  mem_results[N_TESTS] = '{
                                    "../src/tb/testcases/test_mem" //will be run in sim folder
                                };

    
    //For comparison with actual RF and data memory
    integer                         reg_file;
    integer                         mem_file; 
    integer                         reg_line;
    integer                         mem_line;                               
    register_file_t                 rf_comp;
    logic   [NB_BYTE    - 1 : 0]    dmem_comp[MEM_SIZE];


    initial
    begin
        for( int i = 0; i < N_TESTS; i++ )
        begin
            current_test = test_name[i];
            sys_reset;            
            test_errors = 0;
            //Begin actual test
            $readmemb(testcases[i], tb.u_riscv_top.u_imem.IMEM.WORD.MEM );
            $display("READMEMB COMPLETE"); 
            //print_imem;
            #10            
            read_rf_results(i);
            //read_mem_results(i); //[FIXME]
            //Run
            #(CLK_PERIOD*30)
            //Compare RFs
            for( int j = 0; j < 8; j++ ) 
                if( rf_comp.R[j] != tb.u_riscv_top.u_idecode.RF.R[j] )
                begin
                    $error("ERROR IN REGISTER FILE COMPARISON - REGISTER %d TEST %s", j, testcases[i]);
                    $display("EXPECTED RESULT = %d, OBTAINED VALUE = %d",rf_comp.R[j],  tb.u_riscv_top.u_idecode.RF.R[j] );
                    test_errors++;
                end
            //Compare MEM
            //for( int j = 0; j < 256; j++ ) 
            //    if( dmem_comp[j] != tb.u_riscv_top.u_dmem.DMEM[j] )
            //    begin
            //        $error("ERROR IN MEMORY COMPARISON - MEMORY POSITION %d TEST %s", j, testcases[i]);
            //        $display("EXPECTED RESULT = %d, OBTAINED VALUE = %d",dmem_comp[j], tb.u_riscv_top.u_dmem.DMEM[j] );
            //        test_errors++;
            //    end
            //
            if( test_errors == 0 )            
                $display("*************** TEST %s PASS\n", testcases[i]);                            
            else            
                $error("*************** TEST %s FAILED\n", testcases[i]);                
            total_errors += test_errors;
        end
        if( total_errors == 0 )
            $display("********** SIMULATION PASSED - NO ERRORS FOUND! ***********");
        else
            $error("********** SIMULATION FAILED - ERRORS FOUND! ***********");
        $stop();
    end

    always #(CLK_PERIOD/2) 
        clock =~clock;
    

    riscv_top u_riscv_top(
        .i_clock        ( clock ),
        .i_reset        ( reset )
    );

    task sys_reset;
        begin
            tb.u_riscv_top.u_imem.IMEM.WORD.MEM = '{default:'0};
            tb.u_riscv_top.u_dmem.DMEM = '{default:'0};
            reset = 1;
            #(CLK_PERIOD*2) reset = 0;            
        end
    endtask

    task read_rf_results(int test);
    begin
        reg_file = $fopen(rf_results[test],"r");
        if( reg_file == 0 ) 
            begin
                $error("UNABLE TO OPEN REGISTER FILE RESULTS FILE %s \n", rf_results[test] );
                total_errors++;
                //break;
            end
        rf_comp = '{default:'0};
        for( int j = 0; j < 32; j++ ) 
            $fscanf(reg_file, "%d\n", rf_comp.R[j]);
    end
    endtask

    task read_mem_results(int test);
    begin
        mem_file = $fopen(mem_results[test],"r");
        if( mem_file == 0 ) 
            begin
                $error("UNABLE TO OPEN MEMORY FILE RESULTS FILE %s \n", mem_results[test] );
                total_errors++;
                //break;
            end
        dmem_comp = '{default:'0};
        for( int j = 0; j < MEM_SIZE; j++ ) 
            $fscanf(mem_file, "%d\n", dmem_comp[j]);
    end
    endtask

    task print_imem;
        for( int j = 0; j < 32; j++ )
                $display("IMEM[%d]= %b ", j,tb.u_riscv_top.u_imem.IMEM.WORD.MEM[j]);

            for( int j = 0; j < 32*4; j++ )
                $display("IMEM[%d]= %b ", j,tb.u_riscv_top.u_imem.IMEM.BYTE.MEM[j]);
    endtask

endmodule 