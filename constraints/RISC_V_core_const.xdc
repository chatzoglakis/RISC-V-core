set_false_path \
    -from [get_cells -hier -filter {NAME =~ *async_swap_request_reg*}] \
    -to   [get_cells -hier -filter {NAME =~ *swap_request_synchronizer*}]

set_false_path \
    -from [get_cells -hier -filter {NAME =~ *async_swap_ack_reg* || NAME =~ *vga_controller*swap_ack*}] \
    -to   [get_cells -hier -filter {NAME =~ *swap_ack_synchronizer*}]

##Clock signal
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

#reset switch
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { rst_btn }];

##Buttons
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { raw_btn_input[0] }]; #Sch=btn[0]
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { raw_btn_input[1] }]; #Sch=btn[1]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { raw_btn_input[2] }]; #Sch=btn[2]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { raw_btn_input[3] }]; #Sch=btn[3]

##Pmod Header JC                                                                                                                  
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33     } [get_ports { r[0] }]; 
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33     } [get_ports { r[1] }]; 
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33     } [get_ports { r[2] }]; 
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33     } [get_ports { r[3] }]; 
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33     } [get_ports { b[0] }]; 
set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33     } [get_ports { b[1] }]; 
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33     } [get_ports { b[2] }]; 
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33     } [get_ports { b[3] }];            
                                                                                                                                 
                                                                                                                                 
##Pmod Header JD                                                                                                                  
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33     } [get_ports { g[0] }]; 
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33     } [get_ports { g[1] }]; 
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33     } [get_ports { g[2] }]; 
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33     } [get_ports { g[3] }]; 
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33     } [get_ports { hsync }]; 
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33     } [get_ports { vsync }];

##Pmod Header JE                                                                                                                  
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { rx }];
