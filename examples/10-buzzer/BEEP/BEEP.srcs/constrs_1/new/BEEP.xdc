#set_property PACKAGE_PIN W12 [get_ports beep]
#set_property PACKAGE_PIN E18 [get_ports sys_clk]
#set_property PACKAGE_PIN T19 [get_ports sys_rst_n]
#set_property IOSTANDARD LVCMOS12 [get_ports sys_rst_n]
#set_property IOSTANDARD LVDCI_18 [get_ports sys_clk]

#set_property IOSTANDARD LVCMOS33 [get_ports beep]

set_property -dict { PACKAGE_PIN W12 IOSTANDARD LVCMOS33} [get_ports beep]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVDCI_18} [get_ports sys_clk]
set_property -dict { PACKAGE_PIN T19 IOSTANDARD LVCMOS12} [get_ports sys_rst]
