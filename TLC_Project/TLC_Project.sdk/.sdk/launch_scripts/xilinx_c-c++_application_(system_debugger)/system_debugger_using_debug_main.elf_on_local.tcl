connect -url tcp:127.0.0.1:3121
source C:/github/Senior-Project-Vivado/TLC_Project/TLC_Project.sdk/design_1_wrapper_hw_platform_0/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Arty Z7 003017A703B2A"} -index 0
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Arty Z7 003017A703B2A" && level==0} -index 1
fpga -file C:/github/Senior-Project-Vivado/TLC_Project/TLC_Project.sdk/design_1_wrapper_hw_platform_0/design_1_wrapper.bit
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Arty Z7 003017A703B2A"} -index 0
loadhw -hw C:/github/Senior-Project-Vivado/TLC_Project/TLC_Project.sdk/design_1_wrapper_hw_platform_0/system.hdf -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Arty Z7 003017A703B2A"} -index 0
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Arty Z7 003017A703B2A"} -index 0
dow C:/github/Senior-Project-Vivado/TLC_Project/TLC_Project.sdk/main/Debug/main.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Arty Z7 003017A703B2A"} -index 0
con
