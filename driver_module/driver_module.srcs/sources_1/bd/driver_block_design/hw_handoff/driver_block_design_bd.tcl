
################################################################
# This is a generated script based on design: driver_block_design
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source driver_block_design_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
   set_property BOARD_PART digilentinc.com:arty-z7-20:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name driver_block_design

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set data_in_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_0 ]
  set data_in_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_1 ]
  set data_in_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_2 ]
  set data_in_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_3 ]
  set data_in_4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_4 ]
  set data_in_5 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_5 ]
  set data_in_6 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_6 ]
  set data_in_7 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_7 ]
  set data_in_8 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_8 ]
  set data_in_9 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_9 ]
  set data_in_10 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 data_in_10 ]

  # Create ports
  set GPIO_IN [ create_bd_port -dir I -from 2 -to 0 GPIO_IN ]
  set clk_0 [ create_bd_port -dir I -type clk clk_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {50000000} \
 ] $clk_0
  set enable_0 [ create_bd_port -dir I enable_0 ]
  set gsclk_0 [ create_bd_port -dir O gsclk_0 ]
  set gsclk_1 [ create_bd_port -dir O gsclk_1 ]
  set gsclk_2 [ create_bd_port -dir O gsclk_2 ]
  set gsclk_3 [ create_bd_port -dir O gsclk_3 ]
  set gsclk_4 [ create_bd_port -dir O gsclk_4 ]
  set gsclk_5 [ create_bd_port -dir O gsclk_5 ]
  set gsclk_6 [ create_bd_port -dir O gsclk_6 ]
  set gsclk_7 [ create_bd_port -dir O gsclk_7 ]
  set gsclk_8 [ create_bd_port -dir O gsclk_8 ]
  set gsclk_9 [ create_bd_port -dir O gsclk_9 ]
  set latch_0 [ create_bd_port -dir O latch_0 ]
  set latch_1 [ create_bd_port -dir O latch_1 ]
  set latch_2 [ create_bd_port -dir O latch_2 ]
  set latch_3 [ create_bd_port -dir O latch_3 ]
  set latch_4 [ create_bd_port -dir O latch_4 ]
  set latch_5 [ create_bd_port -dir O latch_5 ]
  set latch_6 [ create_bd_port -dir O latch_6 ]
  set latch_7 [ create_bd_port -dir O latch_7 ]
  set latch_8 [ create_bd_port -dir O latch_8 ]
  set latch_9 [ create_bd_port -dir O latch_9 ]
  set reset_0 [ create_bd_port -dir I -type rst reset_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset_0
  set sclk_0 [ create_bd_port -dir O sclk_0 ]
  set sclk_1 [ create_bd_port -dir O sclk_1 ]
  set sclk_2 [ create_bd_port -dir O sclk_2 ]
  set sclk_3 [ create_bd_port -dir O sclk_3 ]
  set sclk_4 [ create_bd_port -dir O sclk_4 ]
  set sclk_5 [ create_bd_port -dir O sclk_5 ]
  set sclk_6 [ create_bd_port -dir O sclk_6 ]
  set sclk_7 [ create_bd_port -dir O sclk_7 ]
  set sclk_8 [ create_bd_port -dir O sclk_8 ]
  set sclk_9 [ create_bd_port -dir O sclk_9 ]
  set sout_0 [ create_bd_port -dir O sout_0 ]
  set sout_1 [ create_bd_port -dir O sout_1 ]
  set sout_2 [ create_bd_port -dir O sout_2 ]
  set sout_3 [ create_bd_port -dir O sout_3 ]
  set sout_4 [ create_bd_port -dir O sout_4 ]
  set sout_5 [ create_bd_port -dir O sout_5 ]
  set sout_6 [ create_bd_port -dir O sout_6 ]
  set sout_7 [ create_bd_port -dir O sout_7 ]
  set sout_8 [ create_bd_port -dir O sout_8 ]
  set sout_9 [ create_bd_port -dir O sout_9 ]

  # Create instance: interrupt_0, and set properties
  set interrupt_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:interrupt:1.0 interrupt_0 ]

  # Create instance: mean_machine_module_0, and set properties
  set mean_machine_module_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:mean_machine_module:1.0 mean_machine_module_0 ]

  # Create instance: sout_module_0, and set properties
  set sout_module_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_0 ]

  # Create instance: sout_module_1, and set properties
  set sout_module_1 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_1 ]

  # Create instance: sout_module_2, and set properties
  set sout_module_2 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_2 ]

  # Create instance: sout_module_3, and set properties
  set sout_module_3 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_3 ]

  # Create instance: sout_module_4, and set properties
  set sout_module_4 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_4 ]

  # Create instance: sout_module_5, and set properties
  set sout_module_5 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_5 ]

  # Create instance: sout_module_6, and set properties
  set sout_module_6 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_6 ]

  # Create instance: sout_module_7, and set properties
  set sout_module_7 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_7 ]

  # Create instance: sout_module_8, and set properties
  set sout_module_8 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_8 ]

  # Create instance: sout_module_9, and set properties
  set sout_module_9 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_9 ]

  # Create instance: sout_module_10, and set properties
  set sout_module_10 [ create_bd_cell -type ip -vlnv xilinx.com:user:sout_module:1.0 sout_module_10 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_WIDTH {2} \
 ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net sout_module_0_data_in [get_bd_intf_ports data_in_0] [get_bd_intf_pins sout_module_0/data_in]
  connect_bd_intf_net -intf_net sout_module_10_data_in [get_bd_intf_ports data_in_10] [get_bd_intf_pins sout_module_10/data_in]
  connect_bd_intf_net -intf_net sout_module_1_data_in [get_bd_intf_ports data_in_1] [get_bd_intf_pins sout_module_1/data_in]
  connect_bd_intf_net -intf_net sout_module_2_data_in [get_bd_intf_ports data_in_2] [get_bd_intf_pins sout_module_2/data_in]
  connect_bd_intf_net -intf_net sout_module_3_data_in [get_bd_intf_ports data_in_3] [get_bd_intf_pins sout_module_3/data_in]
  connect_bd_intf_net -intf_net sout_module_4_data_in [get_bd_intf_ports data_in_4] [get_bd_intf_pins sout_module_4/data_in]
  connect_bd_intf_net -intf_net sout_module_5_data_in [get_bd_intf_ports data_in_5] [get_bd_intf_pins sout_module_5/data_in]
  connect_bd_intf_net -intf_net sout_module_6_data_in [get_bd_intf_ports data_in_6] [get_bd_intf_pins sout_module_6/data_in]
  connect_bd_intf_net -intf_net sout_module_7_data_in [get_bd_intf_ports data_in_7] [get_bd_intf_pins sout_module_7/data_in]
  connect_bd_intf_net -intf_net sout_module_8_data_in [get_bd_intf_ports data_in_8] [get_bd_intf_pins sout_module_8/data_in]
  connect_bd_intf_net -intf_net sout_module_9_data_in [get_bd_intf_ports data_in_9] [get_bd_intf_pins sout_module_9/data_in]

  # Create port connections
  connect_bd_net -net GPIO_IN_1 [get_bd_ports GPIO_IN] [get_bd_pins interrupt_0/GPIO_IN]
  connect_bd_net -net clk_0_1 [get_bd_ports clk_0] [get_bd_pins interrupt_0/clk] [get_bd_pins mean_machine_module_0/clk] [get_bd_pins sout_module_0/clk] [get_bd_pins sout_module_1/clk] [get_bd_pins sout_module_10/clk] [get_bd_pins sout_module_2/clk] [get_bd_pins sout_module_3/clk] [get_bd_pins sout_module_4/clk] [get_bd_pins sout_module_5/clk] [get_bd_pins sout_module_6/clk] [get_bd_pins sout_module_7/clk] [get_bd_pins sout_module_8/clk] [get_bd_pins sout_module_9/clk]
  connect_bd_net -net enable_0_1 [get_bd_ports enable_0] [get_bd_pins mean_machine_module_0/enable]
  connect_bd_net -net interrupt_0_buf_select [get_bd_pins interrupt_0/buf_select] [get_bd_pins mean_machine_module_0/buf_selected]
  connect_bd_net -net interrupt_0_next_section [get_bd_pins interrupt_0/next_section] [get_bd_pins mean_machine_module_0/next_section]
  connect_bd_net -net interrupt_0_setup [get_bd_pins interrupt_0/setup] [get_bd_pins mean_machine_module_0/setup]
  connect_bd_net -net mean_machine_module_0_bit_num [get_bd_pins mean_machine_module_0/bit_num] [get_bd_pins sout_module_0/bit_num] [get_bd_pins sout_module_1/bit_num] [get_bd_pins sout_module_10/bit_num] [get_bd_pins sout_module_2/bit_num] [get_bd_pins sout_module_3/bit_num] [get_bd_pins sout_module_4/bit_num] [get_bd_pins sout_module_5/bit_num] [get_bd_pins sout_module_6/bit_num] [get_bd_pins sout_module_7/bit_num] [get_bd_pins sout_module_8/bit_num] [get_bd_pins sout_module_9/bit_num]
  connect_bd_net -net mean_machine_module_0_buf_select [get_bd_pins mean_machine_module_0/buf_select] [get_bd_pins sout_module_1/buf_num] [get_bd_pins sout_module_10/buf_num] [get_bd_pins sout_module_2/buf_num] [get_bd_pins sout_module_3/buf_num] [get_bd_pins sout_module_4/buf_num] [get_bd_pins sout_module_5/buf_num] [get_bd_pins sout_module_6/buf_num] [get_bd_pins sout_module_7/buf_num] [get_bd_pins sout_module_8/buf_num] [get_bd_pins sout_module_9/buf_num]
  connect_bd_net -net mean_machine_module_0_gsclk [get_bd_ports gsclk_0] [get_bd_ports gsclk_1] [get_bd_ports gsclk_2] [get_bd_ports gsclk_3] [get_bd_ports gsclk_4] [get_bd_ports gsclk_5] [get_bd_ports gsclk_6] [get_bd_ports gsclk_7] [get_bd_ports gsclk_8] [get_bd_ports gsclk_9] [get_bd_pins mean_machine_module_0/gsclk]
  connect_bd_net -net mean_machine_module_0_latch [get_bd_ports latch_0] [get_bd_ports latch_1] [get_bd_ports latch_2] [get_bd_ports latch_3] [get_bd_ports latch_4] [get_bd_ports latch_5] [get_bd_ports latch_6] [get_bd_ports latch_7] [get_bd_ports latch_8] [get_bd_ports latch_9] [get_bd_pins mean_machine_module_0/latch]
  connect_bd_net -net mean_machine_module_0_latch_select [get_bd_pins mean_machine_module_0/latch_select] [get_bd_pins sout_module_0/latch_select] [get_bd_pins sout_module_1/latch_select] [get_bd_pins sout_module_10/latch_select] [get_bd_pins sout_module_2/latch_select] [get_bd_pins sout_module_3/latch_select] [get_bd_pins sout_module_4/latch_select] [get_bd_pins sout_module_5/latch_select] [get_bd_pins sout_module_6/latch_select] [get_bd_pins sout_module_7/latch_select] [get_bd_pins sout_module_8/latch_select] [get_bd_pins sout_module_9/latch_select]
  connect_bd_net -net mean_machine_module_0_ready [get_bd_pins interrupt_0/ready] [get_bd_pins mean_machine_module_0/ready]
  connect_bd_net -net mean_machine_module_0_sclk [get_bd_ports sclk_0] [get_bd_ports sclk_1] [get_bd_ports sclk_2] [get_bd_ports sclk_3] [get_bd_ports sclk_4] [get_bd_ports sclk_5] [get_bd_ports sclk_6] [get_bd_ports sclk_7] [get_bd_ports sclk_8] [get_bd_ports sclk_9] [get_bd_pins mean_machine_module_0/sclk] [get_bd_pins sout_module_0/sclk] [get_bd_pins sout_module_1/sclk] [get_bd_pins sout_module_10/sclk] [get_bd_pins sout_module_2/sclk] [get_bd_pins sout_module_3/sclk] [get_bd_pins sout_module_4/sclk] [get_bd_pins sout_module_5/sclk] [get_bd_pins sout_module_6/sclk] [get_bd_pins sout_module_7/sclk] [get_bd_pins sout_module_8/sclk] [get_bd_pins sout_module_9/sclk]
  connect_bd_net -net reset_0_1 [get_bd_ports reset_0] [get_bd_pins interrupt_0/reset] [get_bd_pins mean_machine_module_0/reset] [get_bd_pins sout_module_0/reset] [get_bd_pins sout_module_1/reset] [get_bd_pins sout_module_10/reset] [get_bd_pins sout_module_2/reset] [get_bd_pins sout_module_3/reset] [get_bd_pins sout_module_4/reset] [get_bd_pins sout_module_5/reset] [get_bd_pins sout_module_6/reset] [get_bd_pins sout_module_7/reset] [get_bd_pins sout_module_8/reset] [get_bd_pins sout_module_9/reset]
  connect_bd_net -net sout_module_0_sout [get_bd_pins sout_module_0/sout] [get_bd_pins sout_module_1/pass_through_bit] [get_bd_pins sout_module_10/pass_through_bit] [get_bd_pins sout_module_2/pass_through_bit] [get_bd_pins sout_module_3/pass_through_bit] [get_bd_pins sout_module_4/pass_through_bit] [get_bd_pins sout_module_5/pass_through_bit] [get_bd_pins sout_module_6/pass_through_bit] [get_bd_pins sout_module_7/pass_through_bit] [get_bd_pins sout_module_8/pass_through_bit] [get_bd_pins sout_module_9/pass_through_bit]
  connect_bd_net -net sout_module_10_sout [get_bd_ports sout_9] [get_bd_pins sout_module_10/sout]
  connect_bd_net -net sout_module_1_sout [get_bd_ports sout_0] [get_bd_pins sout_module_1/sout]
  connect_bd_net -net sout_module_2_sout [get_bd_ports sout_1] [get_bd_pins sout_module_2/sout]
  connect_bd_net -net sout_module_3_sout [get_bd_ports sout_2] [get_bd_pins sout_module_3/sout]
  connect_bd_net -net sout_module_4_sout [get_bd_ports sout_3] [get_bd_pins sout_module_4/sout]
  connect_bd_net -net sout_module_5_sout [get_bd_ports sout_4] [get_bd_pins sout_module_5/sout]
  connect_bd_net -net sout_module_6_sout [get_bd_ports sout_5] [get_bd_pins sout_module_6/sout]
  connect_bd_net -net sout_module_7_sout [get_bd_ports sout_6] [get_bd_pins sout_module_7/sout]
  connect_bd_net -net sout_module_8_sout [get_bd_ports sout_7] [get_bd_pins sout_module_8/sout]
  connect_bd_net -net sout_module_9_sout [get_bd_ports sout_8] [get_bd_pins sout_module_9/sout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins sout_module_0/buf_num] [get_bd_pins sout_module_0/pass_through_bit] [get_bd_pins xlconstant_0/dout]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


