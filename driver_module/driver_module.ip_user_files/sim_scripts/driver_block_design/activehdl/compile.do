vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xlconstant_v1_1_5

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xlconstant_v1_1_5 activehdl/xlconstant_v1_1_5

vlog -work xil_defaultlib  -v2k5 \
"../../../bd/driver_block_design/ipshared/65d9/mean_machine_module.v" \
"../../../bd/driver_block_design/ip/driver_block_design_mean_machine_module_0_0/sim/driver_block_design_mean_machine_module_0_0.v" \
"../../../bd/driver_block_design/ipshared/0c16/sout_module.v" \
"../../../bd/driver_block_design/ip/driver_block_design_sout_module_0_0/sim/driver_block_design_sout_module_0_0.v" \
"../../../bd/driver_block_design/ip/driver_block_design_sout_module_1_0/sim/driver_block_design_sout_module_1_0.v" \

vlog -work xlconstant_v1_1_5  -v2k5 \
"../../../../driver_module.srcs/sources_1/bd/driver_block_design/ipshared/f1c3/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../bd/driver_block_design/ip/driver_block_design_xlconstant_0_0/sim/driver_block_design_xlconstant_0_0.v" \
"../../../../driver_module.srcs/sources_1/bd/driver_block_design/ipshared/445d/INTERRUPT_DRIVER.srcs/sources_1/new/interrupt.v" \
"../../../bd/driver_block_design/ip/driver_block_design_interrupt_0_0/sim/driver_block_design_interrupt_0_0.v" \
"../../../bd/driver_block_design/sim/driver_block_design.v" \

vlog -work xil_defaultlib \
"glbl.v"

