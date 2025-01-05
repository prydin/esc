## This file is a general .xdc for the Cmod S7-25 Rev. B
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## 12 MHz System Clock
set_property -dict {PACKAGE_PIN M9 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 83.330 -name clk -waveform {0.000 41.660} [get_ports clk]

## Push Buttons
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
#set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]

## RGB LEDs
#set_property -dict { PACKAGE_PIN F1    IOSTANDARD LVCMOS33 } [get_ports { led0_b }]; #IO_L10N_T1_34 Sch=led0_b
#set_property -dict { PACKAGE_PIN D3    IOSTANDARD LVCMOS33 } [get_ports { led0_g }]; #IO_L9N_T1_DQS_34 Sch=led0_g
#set_property -dict { PACKAGE_PIN F2    IOSTANDARD LVCMOS33 } [get_ports { led0_r }]; #IO_L10P_T1_34 Sch=led0_r

## 4 LEDs
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
#set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
#set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

## Pmod Header JA
#set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { ja[0] }]; #IO_L14P_T2_SRCC_34 Sch=ja[1]
#set_property -dict { PACKAGE_PIN H2    IOSTANDARD LVCMOS33 } [get_ports { ja[1] }]; #IO_L14N_T2_SRCC_34 Sch=ja[2]
#set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { ja[2] }]; #IO_L13P_T2_MRCC_34 Sch=ja[3]
#set_property -dict { PACKAGE_PIN F3    IOSTANDARD LVCMOS33 } [get_ports { ja[3] }]; #IO_L11N_T1_SRCC_34 Sch=ja[4]
#set_property -dict { PACKAGE_PIN H3    IOSTANDARD LVCMOS33 } [get_ports { ja[4] }]; #IO_L13N_T2_MRCC_34 Sch=ja[7]
#set_property -dict { PACKAGE_PIN H1    IOSTANDARD LVCMOS33 } [get_ports { ja[5] }]; #IO_L12P_T1_MRCC_34 Sch=ja[8]
#set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { ja[6] }]; #IO_L12N_T1_MRCC_34 Sch=ja[9]
#set_property -dict { PACKAGE_PIN F4    IOSTANDARD LVCMOS33 } [get_ports { ja[7] }]; #IO_L11P_T1_SRCC_34 Sch=ja[10]

## USB UART
## Note: Port names are from the perspoctive of the FPGA.
#set_property -dict { PACKAGE_PIN L12   IOSTANDARD LVCMOS33 } [get_ports { uart_tx }]; #IO_L6N_T0_D08_VREF_14 Sch=uart_rxd_out
#set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { uart_rx }]; #IO_L5N_T0_D07_14 Sch=uart_txd_in

## Analog Inputs on PIO Pins 32 and 33
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports vaux5_p]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports vaux5_n]
#set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports { vaux12_p }]; #IO_L11P_T1_SRCC_AD12P_15 Sch=ain_p[33]
#set_property -dict { PACKAGE_PIN A12   IOSTANDARD LVCMOS33 } [get_ports { vaux12_n }]; #IO_L11N_T1_SRCC_AD12N_15 Sch=ain_n[33]

## Dedicated Digital I/O on the PIO Headers
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports pio1]
set_property -dict {PACKAGE_PIN M4 IOSTANDARD LVCMOS33} [get_ports pio2]
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports pio3]
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports pio4]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports pio5]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports pio6]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports pio7]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports pio8]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports pio9]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports pio16]
#set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports pio17]
#set_property -dict {PACKAGE_PIN N13 IOSTANDARD LVCMOS33} [get_ports pio18]
#set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports pio19]
#set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports pio20]
#set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports pio21]
#set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { pio22 }]; #IO_L9P_T1_DQS_14 Sch=pio[22]
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { pio23 }]; #IO_L4N_T0_D05_14 Sch=pio[23]
#set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports pio26]
#set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports pio27]
#set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports pio28]
#set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS33 } [get_ports { pio29 }]; #IO_L7P_T1_D09_14 Sch=pio[29]
#set_property -dict {PULLUP TRUE} [get_ports pio29]
#set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { pio30 }]; #IO_L8P_T1_D11_14 Sch=pio[30]
#set_property -dict {PULLUP TRUE} [get_ports pio30]
#set_property -dict { PACKAGE_PIN J11   IOSTANDARD LVCMOS33 } [get_ports { pio31 }]; #IO_0_14 Sch=pio[31]
#set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { pio40 }]; #IO_L5P_T0_34 Sch=pio[40]
#set_property -dict { PACKAGE_PIN A2    IOSTANDARD LVCMOS33 } [get_ports { pio41 }]; #IO_L2N_T0_34 Sch=pio[41]
#set_property -dict { PACKAGE_PIN B2    IOSTANDARD LVCMOS33 } [get_ports { pio42 }]; #IO_L2P_T0_34 Sch=pio[42]
#set_property -dict { PACKAGE_PIN B1    IOSTANDARD LVCMOS33 } [get_ports { pio43 }]; #IO_L4N_T0_34 Sch=pio[43]
#set_property -dict { PACKAGE_PIN C1    IOSTANDARD LVCMOS33 } [get_ports { pio44 }]; #IO_L4P_T0_34 Sch=pio[44]
#set_property -dict { PACKAGE_PIN B3    IOSTANDARD LVCMOS33 } [get_ports { pio45 }]; #IO_L3N_T0_DQS_34 Sch=pio[45]
#set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { pio46 }]; #IO_L3P_T0_DQS_34 Sch=pio[46]
#set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { pio47 }]; #IO_L1N_T0_34 Sch=pio[47]
#set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports pio48]

## Quad SPI Flash
## Note: QSPI clock can only be accessed through the STARTUPE2 primitive
#set_property -dict { PACKAGE_PIN L11   IOSTANDARD LVCMOS33 } [get_ports { qspi_cs }]; #IO_L6P_T0_FCS_B_14 Sch=qspi_cs
#set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[0] }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
#set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[1] }]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
#set_property -dict { PACKAGE_PIN J12   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
#set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]





connect_debug_port u_ila_0/probe2 [get_nets [list {zero_detect/fifo_reg[31]_srl32_n_1}]]
connect_debug_port u_ila_0/probe3 [get_nets [list {zero_detect/fifo_reg[48]_srl17_n_0}]]




connect_debug_port u_ila_0/probe0 [get_nets [list {zero_detect/ones_reg[0]} {zero_detect/ones_reg[1]} {zero_detect/ones_reg[2]} {zero_detect/ones_reg[3]} {zero_detect/ones_reg[4]} {zero_detect/ones_reg[5]} {zero_detect/ones_reg[6]} {zero_detect/ones_reg[7]} {zero_detect/ones_reg[8]}]]
connect_debug_port u_ila_0/probe1 [get_nets [list {zero_detect/head_reg[0]} {zero_detect/head_reg[1]} {zero_detect/head_reg[2]} {zero_detect/head_reg[3]} {zero_detect/head_reg[4]} {zero_detect/head_reg[5]} {zero_detect/head_reg[6]} {zero_detect/head_reg[7]} {zero_detect/head_reg[8]}]]
connect_debug_port u_ila_0/probe2 [get_nets [list {zero_detect/tail0[0]} {zero_detect/tail0[1]} {zero_detect/tail0[2]} {zero_detect/tail0[3]} {zero_detect/tail0[4]} {zero_detect/tail0[5]} {zero_detect/tail0[6]} {zero_detect/tail0[7]}]]
connect_debug_port u_ila_0/probe3 [get_nets [list zero_detect/at_end]]
connect_debug_port u_ila_0/probe5 [get_nets [list zero_detect/sampled_in]]
connect_debug_port u_ila_0/probe6 [get_nets [list zero_detect/state]]




create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clock/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 12 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {duty_cycle[1]} {duty_cycle[2]} {duty_cycle[3]} {duty_cycle[4]} {duty_cycle[5]} {duty_cycle[6]} {duty_cycle[7]} {duty_cycle[8]} {duty_cycle[9]} {duty_cycle[10]} {duty_cycle[11]} {duty_cycle[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {user_speed[0]} {user_speed[1]} {user_speed[2]} {user_speed[3]} {user_speed[4]} {user_speed[5]} {user_speed[6]} {user_speed[7]} {user_speed[8]} {user_speed[9]} {user_speed[10]} {user_speed[11]} {user_speed[12]} {user_speed[13]} {user_speed[14]} {user_speed[15]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets master_clk]
