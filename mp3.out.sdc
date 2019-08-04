## Generated SDC file "mp3.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions
## and other software and tools, and its AMPP partner logic
## functions, and any output files from any of the foregoing
## (including device programming or simulation files), and any
## associated documentation or information are expressly subject
## to the terms and conditions of the Intel Program License
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition"

## DATE    "Wed Mar 27 18:06:17 2019"

##
## DEVICE  "5SGXEA7H3F35C3"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]

# use this to purposely fail timing analysis:
# create_clock -name {clk} -period 1.000 -waveform { 0.000 0.5000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -setup 0.070
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -hold 0.060
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -setup 0.070
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -hold 0.060
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -setup 0.070
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -hold 0.060
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -setup 0.070
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -hold 0.060


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {clk}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {ir_in[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_resp_data}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_resp_instr}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_byte_enable[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_byte_enable[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_byte_enable[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_byte_enable[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_read_data}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_read_instr}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_write}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc_out[31]}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
