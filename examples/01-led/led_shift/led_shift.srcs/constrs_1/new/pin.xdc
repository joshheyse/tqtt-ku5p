set_property  -dict {PACKAGE_PIN  e18  IOSTANDARD LVCMOS18} [get_ports clk ] ; 

set_property  -dict {PACKAGE_PIN  E16  IOSTANDARD LVCMOS18} [get_ports led[0] ] ; 
set_property  -dict {PACKAGE_PIN  E17  IOSTANDARD LVCMOS18} [get_ports led[1] ] ; 
set_property  -dict {PACKAGE_PIN  F15  IOSTANDARD LVCMOS18} [get_ports led[2] ] ; 
set_property  -dict {PACKAGE_PIN  D15  IOSTANDARD LVCMOS18} [get_ports led[3] ] ; 
set_property  -dict {PACKAGE_PIN  B16  IOSTANDARD LVCMOS18} [get_ports led[4] ] ; 
set_property  -dict {PACKAGE_PIN  D18  IOSTANDARD LVCMOS18} [get_ports led[5] ] ; 
set_property  -dict {PACKAGE_PIN  G15  IOSTANDARD LVCMOS18} [get_ports led[6] ] ; 
set_property  -dict {PACKAGE_PIN  E22  IOSTANDARD LVCMOS18} [get_ports led[7] ] ; 

create_clock -period 20.000 [get_ports clk]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 51.0 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]

