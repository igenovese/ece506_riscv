top_gui:	
	vlib work	
	vlog  -sv +incdir+../src/rtl ../src/rtl/*.sv
	vlog  -sv +incdir+../src/rtl ../src/tb/*.sv
	vsim  -voptargs="+acc" work.tb -do "source wave.do;run -all;" 
coverage_top:	
	vlib work
	vlog  -sv +incdir+../src/rtl/ -cover bcest ../src/rtl/riscv_defs.sv
	vlog  -sv +incdir+../src/rtl/ -cover bcest ../src/rtl/*.sv
	vlog  -sv +incdir+../src/rtl/ -cover bcest ../src/tb/*.sv
	vsim  -c -coverage -voptargs="+cover=bcest+/tb/u_riscv_top +acc" work.tb -do "toggle add -full sim:/tb/u_riscv_top/*; run -all; coverage report -instance /tb/u_riscv_top;coverage report -instance /tb/u_riscv_top/*; fcover report -r /tb/u_riscv_top/*;quit" 
coverage_top_gui:	
	vlib work	
	vlog  -sv +incdir+../src/rtl -cover bcest ../src/rtl/*.sv
	vlog  -sv +incdir+../src/rtl -cover bcest ../src/tb/*.sv
	vsim  -coverage -voptargs="+cover=bcest+/tb/u_riscv_top +acc" work.tb -do "toggle add -full sim:/tb/u_riscv_top/*; run -all; coverage report -instance /tb/u_riscv_top;coverage report -instance /tb/u_riscv_top/*; fcover report -r /tb/u_riscv_top/*;" 
	#vsim  work.mips_16_top -gSAVE_REGS=1 -novopt 
clean:
	rm -rf transcript work/  
	
