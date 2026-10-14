set_property PACKAGE_PIN E18 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]


create_clock -period 20.000 [get_ports clk]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 51.0 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]



set_property PACKAGE_PIN af14 [get_ports SD_nCS]
set_property IOSTANDARD LVCMOS18 [get_ports SD_nCS]


set_property PACKAGE_PIN ae15 [get_ports SD_DCLK]
set_property IOSTANDARD LVCMOS18 [get_ports SD_DCLK]

set_property PACKAGE_PIN ad15 [get_ports SD_MOSI]
set_property IOSTANDARD LVCMOS18 [get_ports SD_MOSI]

set_property PACKAGE_PIN af13 [get_ports SD_MISO]
set_property IOSTANDARD LVCMOS18 [get_ports SD_MISO]

set_property PACKAGE_PIN e16 [get_ports led[0]]
set_property IOSTANDARD LVCMOS18 [get_ports led[0]]

set_property PACKAGE_PIN e17 [get_ports led[1]]
set_property IOSTANDARD LVCMOS18 [get_ports led[1]]

set_property PACKAGE_PIN f15 [get_ports led[2]]
set_property IOSTANDARD LVCMOS18 [get_ports led[2]]

set_property PACKAGE_PIN d15 [get_ports led[3]]
set_property IOSTANDARD LVCMOS18 [get_ports led[3]]

set_property PACKAGE_PIN r20 [get_ports arst]
set_property IOSTANDARD LVCMOS18 [get_ports arst]


