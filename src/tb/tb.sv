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
    localparam  N_TESTS     = 4;

    logic       clock = 0;
    logic       reset;    
    string      current_test;
    int         test_errors  = 0;
    int         total_errors = 0;

    int     cycles[N_TESTS] = '{
                                5,
                                65,
                                20,
                                35
                                };

    string  test_name[N_TESTS] = '{
                                    "test",
                                    "typer_i_s",
                                    "jump",
                                    "branch"
                                };

    string  testcases[N_TESTS] = '{
                                    "../src/tb/testcases/test", //will be run in sim folder
                                    "../src/tb/testcases/typer_i_s",
                                    "../src/tb/testcases/jump", 
                                    "../src/tb/testcases/branch"
                                };

    string  rf_results[N_TESTS] = '{
                                    "../src/tb/testcases/test_rf", //will be run in sim folder
                                    "../src/tb/testcases/typer_i_s_rf",
                                    "../src/tb/testcases/jump_rf",
                                    "../src/tb/testcases/branch_rf"
                                };

    //For comparison with actual RF 
    integer                         reg_file;    
    integer                         reg_line;                               
    register_file_t                 rf_comp;
    
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
            //Run
            #(CLK_PERIOD*cycles[i])
            //Compare RFs
            for( int j = 0; j < N_REGISTERS; j++ ) 
                if( rf_comp.R[j] != tb.u_riscv_top.u_idecode.RF.R[j] )
                begin
                    $error("ERROR IN REGISTER FILE COMPARISON - REGISTER %d TEST %s", j, testcases[i]);
                    $display("EXPECTED RESULT = %d, OBTAINED VALUE = %d",rf_comp.R[j],  tb.u_riscv_top.u_idecode.RF.R[j] );
                    test_errors++;
                end
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

    task print_imem;
        for( int j = 0; j < 32; j++ )
                $display("IMEM[%d]= %b ", j,tb.u_riscv_top.u_imem.IMEM.WORD.MEM[j]);

            for( int j = 0; j < 32*4; j++ )
                $display("IMEM[%d]= %b ", j,tb.u_riscv_top.u_imem.IMEM.BYTE.MEM[j]);
    endtask

endmodule 