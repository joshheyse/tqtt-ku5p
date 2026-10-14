






# file: ibert_ultrascale_gty_0.xdc
####################################################################################

##**************************************************************************
##
## Icon Constraints
##






set_property C_CLK_INPUT_FREQ_HZ 156250000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER true [get_debug_cores dbg_hub]
##
##gtrefclk lock constraints
##






 
set_property PACKAGE_PIN V7 [get_ports gty_refclk0p_i[0]]
set_property PACKAGE_PIN V6 [get_ports gty_refclk0n_i[0]]
set_property PACKAGE_PIN T7 [get_ports gty_refclk1p_i[0]]
set_property PACKAGE_PIN T6 [get_ports gty_refclk1n_i[0]]
##
## Refclk constraints
##





 
create_clock -name gtrefclk0_1 -period 6.4 [get_ports gty_refclk0p_i[0]]
create_clock -name gtrefclk1_1 -period 6.4 [get_ports gty_refclk1p_i[0]]
set_clock_groups -group [get_clocks gtrefclk0_1 -include_generated_clocks] -asynchronous
set_clock_groups -group [get_clocks gtrefclk1_1 -include_generated_clocks] -asynchronous
