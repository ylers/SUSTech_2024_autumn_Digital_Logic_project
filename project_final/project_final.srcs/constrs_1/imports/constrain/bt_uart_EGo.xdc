
# Clock signal
#Bank = 34, Pin name = ,					Sch name = CLK100MHZ
###################set_property PACKAGE_PIN P17 [get_ports clk_pin]
##################set_property IOSTANDARD LVCMOS33 [get_ports clk_pin]
#create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk_pin]

# Switches
set_property PACKAGE_PIN R3 [get_ports lb_sel_pin]
set_property IOSTANDARD LVCMOS33 [get_ports lb_sel_pin]

#Buttons
#Bank = 14, Pin name = ,					Sch name = BTNC
set_property PACKAGE_PIN T5 [get_ports rst_pin]
set_property IOSTANDARD LVCMOS33 [get_ports rst_pin]

# LEDs
# set_property PACKAGE_PIN F6 [get_ports {led_pins[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[0]}]
# set_property PACKAGE_PIN G4 [get_ports {led_pins[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[1]}]
# set_property PACKAGE_PIN G3 [get_ports {led_pins[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[2]}]
# set_property PACKAGE_PIN J4 [get_ports {led_pins[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[3]}]
# set_property PACKAGE_PIN H4 [get_ports {led_pins[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[4]}]
# set_property PACKAGE_PIN J3 [get_ports {led_pins[5]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[5]}]
# set_property PACKAGE_PIN J2 [get_ports {led_pins[6]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[6]}]
# set_property PACKAGE_PIN K2 [get_ports {led_pins[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[7]}]
# set_property PACKAGE_PIN K1 [get_ports {led_pins[8]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[8]}]
# set_property PACKAGE_PIN H6 [get_ports {led_pins[9]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[9]}]
# set_property PACKAGE_PIN H5 [get_ports {led_pins[10]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[10]}]
# set_property PACKAGE_PIN J5 [get_ports {led_pins[11]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[11]}]
# set_property PACKAGE_PIN K6 [get_ports {led_pins[12]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[12]}]
# set_property PACKAGE_PIN L1 [get_ports {led_pins[13]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[13]}]
# set_property PACKAGE_PIN M1 [get_ports {led_pins[14]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[14]}]
# set_property PACKAGE_PIN K3 [get_ports {led_pins[15]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {led_pins[15]}]

##USB-RS232 Interface
##Bank = 16, Pin name = ,					Sch name = UART_TXD_IN
set_property PACKAGE_PIN L3 [get_ports rxd_pin]
set_property IOSTANDARD LVCMOS33 [get_ports rxd_pin]
#Bank = 16, Pin name = ,					Sch name = UART_RXD_OUT
set_property PACKAGE_PIN N2 [get_ports txd_pin]
set_property IOSTANDARD LVCMOS33 [get_ports txd_pin]

# BT 
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports sw_pin]



set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports bt_pw_on        ]
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports bt_master_slave ]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports bt_sw_hw        ]
set_property -dict {PACKAGE_PIN M2  IOSTANDARD LVCMOS33} [get_ports bt_rst_n        ]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports bt_sw           ]

#7 segment display
# set_property PACKAGE_PIN B4 [get_ports {seg7_0_7bit[0]}]W
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_7bit[0]}]
# set_property PACKAGE_PIN A4 [get_ports {seg7_0_7bit[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_7bit[1]}]
# set_property PACKAGE_PIN A3 [get_ports {seg7_0_7bit[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_7bit[2]}]
# set_property PACKAGE_PIN B1 [get_ports {seg7_0_7bit[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_7bit[3]}]
# set_property PACKAGE_PIN A1 [get_ports {seg7_0_7bit[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_7bit[4]}]
# set_property PACKAGE_PIN B3 [get_ports {seg7_0_7bit[5]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_7bit[5]}]
# set_property PACKAGE_PIN B2 [get_ports {seg7_0_7bit[6]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_7bit[6]}]
# set_property PACKAGE_PIN D5 [get_ports {seg7_0_dp}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_dp}]

# set_property PACKAGE_PIN G2 [get_ports {seg7_0_an[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_an[0]}]
# set_property PACKAGE_PIN C2 [get_ports {seg7_0_an[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_an[1]}]
# set_property PACKAGE_PIN C1 [get_ports {seg7_0_an[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_an[2]}]
# set_property PACKAGE_PIN H1 [get_ports {seg7_0_an[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_0_an[3]}]

# set_property PACKAGE_PIN D4 [get_ports {seg7_1_7bit[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_7bit[0]}]
# set_property PACKAGE_PIN E3 [get_ports {seg7_1_7bit[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_7bit[1]}]
# set_property PACKAGE_PIN D3 [get_ports {seg7_1_7bit[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_7bit[2]}]
# set_property PACKAGE_PIN F4 [get_ports {seg7_1_7bit[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_7bit[3]}]
# set_property PACKAGE_PIN F3 [get_ports {seg7_1_7bit[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_7bit[4]}]
# set_property PACKAGE_PIN E2 [get_ports {seg7_1_7bit[5]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_7bit[5]}]
# set_property PACKAGE_PIN D2 [get_ports {seg7_1_7bit[6]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_7bit[6]}]

# set_property PACKAGE_PIN H2 [get_ports {seg7_1_dp}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_dp}]

# set_property PACKAGE_PIN G1 [get_ports {seg7_1_an[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_an[0]}]
# set_property PACKAGE_PIN F1 [get_ports {seg7_1_an[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_an[1]}]
# set_property PACKAGE_PIN E1 [get_ports {seg7_1_an[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_an[2]}]
# set_property PACKAGE_PIN G6 [get_ports {seg7_1_an[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {seg7_1_an[3]}]

#set_property IOB TRUE [all_fanin -only_cells -startpoints_only -flat [all_outputs]]

# Bind sw[0] to M4
#######set_property PACKAGE_PIN M4 [get_ports {sw[0]}]
########set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]

# Bind sw[1] to N4
########set_property PACKAGE_PIN N4 [get_ports {sw[1]}]
########set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]

# Bind testOut[0] to F6
#########set_property PACKAGE_PIN F6 [get_ports {testOut[0]}]
#########set_property IOSTANDARD LVCMOS33 [get_ports {testOut[0]}]

# Bind testOut[1] to G4
##########set_property PACKAGE_PIN G4 [get_ports {testOut[1]}]
##########set_property IOSTANDARD LVCMOS33 [get_ports {testOut[1]}]

# Bind testOut[2] to G3
##########set_property PACKAGE_PIN G3 [get_ports {testOut[2]}]
##########set_property IOSTANDARD LVCMOS33 [get_ports {testOut[2]}]

# Bind testOut[3] to J4
##########set_property PACKAGE_PIN J4 [get_ports {testOut[3]}]
##########set_property IOSTANDARD LVCMOS33 [get_ports {testOut[3]}]

# Bind testOut[4] to H4
##########set_property PACKAGE_PIN H4 [get_ports {testOut[4]}]
##########set_property IOSTANDARD LVCMOS33 [get_ports {testOut[4]}]

# Bind testOut[5] to J3
##########set_property PACKAGE_PIN J3 [get_ports {testOut[5]}]
##########set_property IOSTANDARD LVCMOS33 [get_ports {testOut[5]}]

# Bind testOut[6] to J2
##########set_property PACKAGE_PIN J2 [get_ports {testOut[6]}]
##########set_property IOSTANDARD LVCMOS33 [get_ports {testOut[6]}]