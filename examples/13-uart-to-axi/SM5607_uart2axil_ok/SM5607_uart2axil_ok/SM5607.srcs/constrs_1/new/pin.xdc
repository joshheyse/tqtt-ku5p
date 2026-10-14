

set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS18} [get_ports clk_50MHz]

set_property -dict { PACKAGE_PIN G19 IOSTANDARD LVCMOS18} [get_ports txd]
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS18} [get_ports rxd]

set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS18} [get_ports led[0]]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS18} [get_ports led[1]]
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS18} [get_ports led[2]]
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS18} [get_ports led[3]]

set_property -dict { PACKAGE_PIN T19 IOSTANDARD LVCMOS12} [get_ports key[0]]
set_property -dict { PACKAGE_PIN N22 IOSTANDARD LVCMOS12} [get_ports key[1]]
set_property -dict { PACKAGE_PIN N21 IOSTANDARD LVCMOS12} [get_ports key[2]]
set_property -dict { PACKAGE_PIN P19 IOSTANDARD LVCMOS12} [get_ports key[3]]




set_property -dict { PACKAGE_PIN d9 IOSTANDARD LVCMOS33} [get_ports PMOD0_1]
set_property -dict { PACKAGE_PIN c9 IOSTANDARD LVCMOS33} [get_ports PMOD0_2]


