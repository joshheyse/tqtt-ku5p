# TQTT-KU5P / HamGeek SKU 101069. FPGA: xcku5p-ffvb676-2-i.
# Source: xcku5p/hardware/XCKU5P-schematic.pdf, pages 1-13.
# Cross-checks: xcku5p/examples/{01-14}/*/constrs_1/new/*.xdc and IP XDC files.
# Active interface: sys_clk, reset_n, led[3:0].
# Inactive interface: commented constraints for ports absent from top.sv.
# Bank supplies: 0 = 1.8 V, 64/65 = 1.2 V, 84/86/87 = 3.3 V, 66/67 = +ADJ.
# TODO(+ADJ): POWER page specifies 1.9 V. Examples use LVCMOS18.
# TODO(timing): Add interface timing when an inactive interface enters the design.

# System clock: CLK_50M, E18, 50 MHz, bank 67. Source: pages 1 and 6, example 01.
# CAUTION: Make sure +ADJ is between 1.71 V and 1.89 V before you use the hardware.
# Make sure CLK_50M is not more than VCCO + 0.20 V. Excess voltage can damage E18.
# U1 uses a 3.3 V supply. The schematic shows only R61 (43 ohm) between U1 and E18.
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS18} [get_ports sys_clk]
create_clock -name sys_clk -period 20.000 [get_ports sys_clk]

# Board reset input: PCIE_RESET / PCIe PERST#, active low, F22, bank 66.
# Source: pages 6 and 8, example 05. The power reset drives dedicated INIT_B.
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS18} [get_ports reset_n]

# User LEDs: LED0-LED7, active high through SI2300 transistors, bank 67.
# Source: pages 1 and 6, examples 01 and 11-14.
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS18 DRIVE 8 SLEW SLOW} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS18 DRIVE 8 SLEW SLOW} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS18 DRIVE 8 SLEW SLOW} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS18 DRIVE 8 SLEW SLOW} [get_ports {led[3]}]
# set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS18} [get_ports {led[4]}]
# set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS18} [get_ports {led[5]}]
# set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS18} [get_ports {led[6]}]
# set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS18} [get_ports {led[7]}]

# User clock: USER1_CLK_P/N, X1, 100 MHz, T24/U24, bank 65.
# Source: page 6, example 06 generated par/ddr4_0.xdc.
# set_property -dict {PACKAGE_PIN T24 IOSTANDARD DIFF_SSTL12} [get_ports user_clk_p]
# set_property -dict {PACKAGE_PIN U24 IOSTANDARD DIFF_SSTL12} [get_ports user_clk_n]
# create_clock -name user_clk -period 10.000 [get_ports user_clk_p]

# Buttons: KEY_PL0-KEY_PL3, K1-K4, active high, 1.2 V, bank 65.
# Source: pages 1 and 6, examples 13 and 14.
# set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS12} [get_ports {key_pl[0]}]
# set_property -dict {PACKAGE_PIN N22 IOSTANDARD LVCMOS12} [get_ports {key_pl[1]}]
# set_property -dict {PACKAGE_PIN N21 IOSTANDARD LVCMOS12} [get_ports {key_pl[2]}]
# set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS12} [get_ports {key_pl[3]}]

# DIP switch: SW1-SW4, SW3 component, active high, 1.2 V, bank 65.
# Source: pages 1 and 6.
# TODO(dip_switch): Vendor XDC files do not supply an I/O standard consistent with the 1.2 V supply.
# set_property PACKAGE_PIN N19 [get_ports {dip_switch[0]}]
# set_property PACKAGE_PIN N23 [get_ports {dip_switch[1]}]
# set_property PACKAGE_PIN R21 [get_ports {dip_switch[2]}]
# set_property PACKAGE_PIN R20 [get_ports {dip_switch[3]}]

# USB UART: UART1_PC2FPGA/FPGA2PC and UART2_PC2FPGA/FPGA2PC, bank 67.
# Source: pages 6 and 13, example 13 supplies LVCMOS18 for UART2.
# UART1 and UART2 connect to the two channels of U10 CP2105.
# TODO(uart1): Vendor XDC files do not supply an I/O standard.
# set_property PACKAGE_PIN H16 [get_ports uart1_rx]
# set_property PACKAGE_PIN G16 [get_ports uart1_tx]
# set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS18} [get_ports uart2_rx]
# set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS18} [get_ports uart2_tx]

# Fan: FAN_PWM/FAN_FB, J10, bank 67. Source: pages 4 and 6, example 11.
# FAN_PWM drives an inverting SI2300 stage. FAN_FB has a pull-up to 1.8 V.
# set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS18} [get_ports fan_pwm]
# set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS18} [get_ports fan_fb]

# Buzzer and temperature sensor: BEEP / DS18B20_IO, bank 84.
# Source: page 4, examples 10 and 12. BEEP is active high.
# set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33} [get_ports beep]
# set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports ds18b20_io]

# Barometer: U8 MS5611-01BA03, bank 86.
# Source: page 4, example 14 (MS5611_SCK/MO/MI/CSN aliases).
# MS5611_CSB is active low. The PS pin selects SPI.
# set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports ms5611_sclk]
# set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports ms5611_sdi]
# set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports ms5611_sdo]
# set_property -dict {PACKAGE_PIN B10 IOSTANDARD LVCMOS33} [get_ports ms5611_csb]

# EEPROM: PL_I2C_SCL/SDA connect to U4 BL24C02, bank 84, 3.3 V pull-ups.
# Source: pages 1 and 4.
# TODO(pl_i2c): CONFIG swaps SCL/SDA at U4. Vendor XDC files do not supply an I/O standard.
# set_property PACKAGE_PIN AB14 [get_ports pl_i2c_scl]
# set_property PACKAGE_PIN W16 [get_ports pl_i2c_sda]

# EEPROM bus: SCL/SDA connect to U16/U25 BL24C256, bank 86, 3.3 V pull-ups.
# Source: page 4.
# TODO(eeprom_i2c): Vendor XDC files do not supply an I/O standard.
# set_property PACKAGE_PIN A9 [get_ports eeprom_i2c_scl]
# set_property PACKAGE_PIN B9 [get_ports eeprom_i2c_sda]

# PMOD0/1: J1/J2, direct 3.3 V interface, bank 86. Source: pages 1 and 4.
# Header pins 1/3/5/7/2/4/6/8 correspond to signal indices 0/1/2/3/4/5/6/7.
# Header pins 9/11 are ground. Header pins 10/12 supply 3.3 V.
# Example 13 supplies LVCMOS33 only for PMOD0_1 and PMOD0_2.
# TODO(pmod0/pmod1): Vendor XDC files do not supply all I/O standards.
# set_property PACKAGE_PIN D10 [get_ports {pmod0[0]}]
# set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports {pmod0[1]}]
# set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {pmod0[2]}]
# set_property PACKAGE_PIN E11 [get_ports {pmod0[3]}]
# set_property PACKAGE_PIN D11 [get_ports {pmod0[4]}]
# set_property PACKAGE_PIN E10 [get_ports {pmod0[5]}]
# set_property PACKAGE_PIN F9 [get_ports {pmod0[6]}]
# set_property PACKAGE_PIN F10 [get_ports {pmod0[7]}]
# set_property PACKAGE_PIN J10 [get_ports {pmod1[0]}]
# set_property PACKAGE_PIN J9 [get_ports {pmod1[1]}]
# set_property PACKAGE_PIN H9 [get_ports {pmod1[2]}]
# set_property PACKAGE_PIN G11 [get_ports {pmod1[3]}]
# set_property PACKAGE_PIN J11 [get_ports {pmod1[4]}]
# set_property PACKAGE_PIN H11 [get_ports {pmod1[5]}]
# set_property PACKAGE_PIN G10 [get_ports {pmod1[6]}]
# set_property PACKAGE_PIN G9 [get_ports {pmod1[7]}]

# PMOD2: J3, direct 3.3 V interface, bank 84. Source: pages 1 and 4.
# PMOD3: J12, 3.3 V header through U21 TXS0108E, FPGA side +ADJ, bank 66.
# Source: pages 1 and 6. PMOD3_n_LS is the FPGA-side vendor alias.
# TODO(pmod2/pmod3): Vendor XDC files do not supply I/O standards.
# set_property PACKAGE_PIN AA14 [get_ports {pmod2[0]}]
# set_property PACKAGE_PIN Y15 [get_ports {pmod2[1]}]
# set_property PACKAGE_PIN AC13 [get_ports {pmod2[2]}]
# set_property PACKAGE_PIN AD13 [get_ports {pmod2[3]}]
# set_property PACKAGE_PIN AB15 [get_ports {pmod2[4]}]
# set_property PACKAGE_PIN AA15 [get_ports {pmod2[5]}]
# set_property PACKAGE_PIN AD14 [get_ports {pmod2[6]}]
# set_property PACKAGE_PIN AC14 [get_ports {pmod2[7]}]
# set_property PACKAGE_PIN K22 [get_ports {pmod3[0]}]
# set_property PACKAGE_PIN K23 [get_ports {pmod3[1]}]
# set_property PACKAGE_PIN M26 [get_ports {pmod3[2]}]
# set_property PACKAGE_PIN K25 [get_ports {pmod3[3]}]
# set_property PACKAGE_PIN M25 [get_ports {pmod3[4]}]
# set_property PACKAGE_PIN K26 [get_ports {pmod3[5]}]
# set_property PACKAGE_PIN L25 [get_ports {pmod3[6]}]
# set_property PACKAGE_PIN L24 [get_ports {pmod3[7]}]

# SD card: J8, SD_CLK/CMD/DAT0-DAT3, 3.3 V, bank 84.
# Source: page 4, example 08 supplies SPI aliases SD_DCLK/MOSI/MISO/nCS.
# SD_DAT3 is active-low chip select in SPI mode. The CD/WP pads do not connect to the FPGA.
# TODO(sd): Example 08 uses LVCMOS18, but the schematic supplies 3.3 V. Resolve the standard before activation.
# set_property PACKAGE_PIN AE15 [get_ports sd_clk]
# set_property PACKAGE_PIN AD15 [get_ports sd_cmd]
# set_property PACKAGE_PIN AF13 [get_ports {sd_dat[0]}]
# set_property PACKAGE_PIN AE13 [get_ports {sd_dat[1]}]
# set_property PACKAGE_PIN AF15 [get_ports {sd_dat[2]}]
# set_property PACKAGE_PIN AF14 [get_ports {sd_dat[3]}]

# HDMI output: HDMI1_CLK_P/N and HDMI1_DATA0-2_P/N, bank 65.
# Source: pages 5 and 6, example 07. The schematic uses AC coupling and 51 ohm terminations.
# Vendor aliases: TMDSp_clock/TMDSn_clock and TMDSp[n]/TMDSn[n].
# TODO(hdmi): Check LVDS compatibility with bank 65 at 1.2 V before activation.
# set_property -dict {PACKAGE_PIN T25 IOSTANDARD LVDS} [get_ports hdmi_clk_p]
# set_property -dict {PACKAGE_PIN U25 IOSTANDARD LVDS} [get_ports hdmi_clk_n]
# set_property -dict {PACKAGE_PIN N24 IOSTANDARD LVDS} [get_ports {hdmi_data_p[0]}]
# set_property -dict {PACKAGE_PIN P24 IOSTANDARD LVDS} [get_ports {hdmi_data_n[0]}]
# set_property -dict {PACKAGE_PIN V24 IOSTANDARD LVDS} [get_ports {hdmi_data_p[1]}]
# set_property -dict {PACKAGE_PIN W24 IOSTANDARD LVDS} [get_ports {hdmi_data_n[1]}]
# set_property -dict {PACKAGE_PIN V23 IOSTANDARD LVDS} [get_ports {hdmi_data_p[2]}]
# set_property -dict {PACKAGE_PIN W23 IOSTANDARD LVDS} [get_ports {hdmi_data_n[2]}]
# HDMI1_OUT_EN enables the 5 V supply and HPD buffer. HDMI1_HPD is the raw connector net.
# Source: pages 4 and 5. HDMI1_OUT_EN is active high.
# Vendor alias: HDMI0_OE in example 07 is HDMI1_OUT_EN at Y16 in the schematic.
# TODO(hdmi_hpd): The I/O standard is unresolved. The schematic does not show an HPD level divider.
# set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports hdmi_out_en]
# set_property PACKAGE_PIN AB16 [get_ports hdmi_hpd]
# TODO(hdmi_i2c): FPGA_I2C_SCL1/SDA1 on page 5 have no matching FPGA net on pages 4 or 6.

# Ethernet: U30 RTL8211EG, GMII, ETHPL_* nets, 3.3 V, bank 87.
# Source: pages 4 and 12. The schematic selects GMII by default through ETHPL_COL.
# ETHPL_RSTB is active low. The PHY has its own 25 MHz crystal.
# TODO(eth): Vendor XDC files do not supply I/O standards or interface timing.
# set_property PACKAGE_PIN E12 [get_ports {eth_txd[0]}]
# set_property PACKAGE_PIN F13 [get_ports {eth_txd[1]}]
# set_property PACKAGE_PIN C14 [get_ports {eth_txd[2]}]
# set_property PACKAGE_PIN C12 [get_ports {eth_txd[3]}]
# set_property PACKAGE_PIN B12 [get_ports {eth_txd[4]}]
# set_property PACKAGE_PIN A12 [get_ports {eth_txd[5]}]
# set_property PACKAGE_PIN A13 [get_ports {eth_txd[6]}]
# set_property PACKAGE_PIN B14 [get_ports {eth_txd[7]}]
# set_property PACKAGE_PIN F12 [get_ports {eth_rxd[0]}]
# set_property PACKAGE_PIN G14 [get_ports {eth_rxd[1]}]
# set_property PACKAGE_PIN G12 [get_ports {eth_rxd[2]}]
# set_property PACKAGE_PIN H14 [get_ports {eth_rxd[3]}]
# set_property PACKAGE_PIN J15 [get_ports {eth_rxd[4]}]
# set_property PACKAGE_PIN J14 [get_ports {eth_rxd[5]}]
# set_property PACKAGE_PIN H13 [get_ports {eth_rxd[6]}]
# set_property PACKAGE_PIN J13 [get_ports {eth_rxd[7]}]
# set_property PACKAGE_PIN E13 [get_ports eth_gtx_clk]
# set_property PACKAGE_PIN C13 [get_ports eth_txclk]
# set_property PACKAGE_PIN D14 [get_ports eth_rxclk]
# set_property PACKAGE_PIN F14 [get_ports eth_txen]
# set_property PACKAGE_PIN A14 [get_ports eth_txer]
# set_property PACKAGE_PIN H12 [get_ports eth_rxdv]
# set_property PACKAGE_PIN J12 [get_ports eth_rxer]
# set_property PACKAGE_PIN D13 [get_ports eth_rst_n]
# TODO(eth_management): ETHPL_MDC/MDIO/COL on page 12 have no matching FPGA net on pages 4 or 6.
# PHY LED0/LED1 connect to RJ45 LEDs. PHY INT and CRS do not connect to the FPGA.

# DDR4: U23/U24 MT40A256M16GE-075E, 32 data bits, banks 64 and 65 at 1.2 V.
# Source: pages 2 and 6, example 06 ku5p_ddr4.xdc and generated par/ddr4_0.xdc.
# DDR4_A14/A15/A16 use the vendor aliases DDR4_WE_B/CAS_B/RAS_B.
# CK and DQS use P/N partners on the same line pair below.
# RESET, ACT, CS, WE, CAS, RAS, ALERT, and DM/DBI have active-low functions.
# TODO(ddr4): MIG must supply its complete electrical constraints and controller timing.
# set_property -dict {PACKAGE_PIN AD24 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[0]}]
# set_property -dict {PACKAGE_PIN AF24 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[1]}]
# set_property -dict {PACKAGE_PIN AB26 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[2]}]
# set_property -dict {PACKAGE_PIN AB24 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[3]}]
# set_property -dict {PACKAGE_PIN AC24 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[4]}]
# set_property -dict {PACKAGE_PIN AB25 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[5]}]
# set_property -dict {PACKAGE_PIN AF25 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[6]}]
# set_property -dict {PACKAGE_PIN AD25 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[7]}]
# set_property -dict {PACKAGE_PIN AD23 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[8]}]
# set_property -dict {PACKAGE_PIN AE23 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[9]}]
# set_property -dict {PACKAGE_PIN AD21 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[10]}]
# set_property -dict {PACKAGE_PIN AC23 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[11]}]
# set_property -dict {PACKAGE_PIN AC22 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[12]}]
# set_property -dict {PACKAGE_PIN AE21 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[13]}]
# set_property -dict {PACKAGE_PIN AB21 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[14]}]
# set_property -dict {PACKAGE_PIN AC21 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[15]}]
# set_property -dict {PACKAGE_PIN AF17 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[16]}]
# set_property -dict {PACKAGE_PIN AE17 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[17]}]
# set_property -dict {PACKAGE_PIN AC19 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[18]}]
# set_property -dict {PACKAGE_PIN AF18 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[19]}]
# set_property -dict {PACKAGE_PIN AF19 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[20]}]
# set_property -dict {PACKAGE_PIN AD19 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[21]}]
# set_property -dict {PACKAGE_PIN AE16 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[22]}]
# set_property -dict {PACKAGE_PIN AD16 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[23]}]
# set_property -dict {PACKAGE_PIN AB20 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[24]}]
# set_property -dict {PACKAGE_PIN AB19 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[25]}]
# set_property -dict {PACKAGE_PIN AA19 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[26]}]
# set_property -dict {PACKAGE_PIN AA20 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[27]}]
# set_property -dict {PACKAGE_PIN Y17 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[28]}]
# set_property -dict {PACKAGE_PIN AA17 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[29]}]
# set_property -dict {PACKAGE_PIN Y18 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[30]}]
# set_property -dict {PACKAGE_PIN AA18 IOSTANDARD POD12_DCI} [get_ports {ddr4_dq[31]}]
# set_property -dict {PACKAGE_PIN P26 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[0]}]
# set_property -dict {PACKAGE_PIN P25 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[1]}]
# set_property -dict {PACKAGE_PIN R22 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[2]}]
# set_property -dict {PACKAGE_PIN AA24 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[3]}]
# set_property -dict {PACKAGE_PIN T23 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[4]}]
# set_property -dict {PACKAGE_PIN W20 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[5]}]
# set_property -dict {PACKAGE_PIN T22 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[6]}]
# set_property -dict {PACKAGE_PIN W19 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[7]}]
# set_property -dict {PACKAGE_PIN U21 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[8]}]
# set_property -dict {PACKAGE_PIN P21 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[9]}]
# set_property -dict {PACKAGE_PIN V22 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[10]}]
# set_property -dict {PACKAGE_PIN U19 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[11]}]
# set_property -dict {PACKAGE_PIN Y25 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[12]}]
# set_property -dict {PACKAGE_PIN P20 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[13]}]
# set_property -dict {PACKAGE_PIN Y23 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[14]}]
# set_property -dict {PACKAGE_PIN U26 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[15]}]
# set_property -dict {PACKAGE_PIN V26 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_addr[16]}]
# set_property -dict {PACKAGE_PIN AC26 IOSTANDARD DIFF_POD12_DCI} [get_ports {ddr4_dqs_p[0]}]
# set_property -dict {PACKAGE_PIN AD26 IOSTANDARD DIFF_POD12_DCI} [get_ports {ddr4_dqs_n[0]}]
# set_property -dict {PACKAGE_PIN AA22 IOSTANDARD DIFF_POD12_DCI} [get_ports {ddr4_dqs_p[1]}]
# set_property -dict {PACKAGE_PIN AB22 IOSTANDARD DIFF_POD12_DCI} [get_ports {ddr4_dqs_n[1]}]
# set_property -dict {PACKAGE_PIN AC18 IOSTANDARD DIFF_POD12_DCI} [get_ports {ddr4_dqs_p[2]}]
# set_property -dict {PACKAGE_PIN AD18 IOSTANDARD DIFF_POD12_DCI} [get_ports {ddr4_dqs_n[2]}]
# set_property -dict {PACKAGE_PIN AB17 IOSTANDARD DIFF_POD12_DCI} [get_ports {ddr4_dqs_p[3]}]
# set_property -dict {PACKAGE_PIN AC17 IOSTANDARD DIFF_POD12_DCI} [get_ports {ddr4_dqs_n[3]}]
# set_property -dict {PACKAGE_PIN AE25 IOSTANDARD POD12_DCI} [get_ports {ddr4_dm_dbi_n[0]}]
# set_property -dict {PACKAGE_PIN AE22 IOSTANDARD POD12_DCI} [get_ports {ddr4_dm_dbi_n[1]}]
# set_property -dict {PACKAGE_PIN AD20 IOSTANDARD POD12_DCI} [get_ports {ddr4_dm_dbi_n[2]}]
# set_property -dict {PACKAGE_PIN Y20 IOSTANDARD POD12_DCI} [get_ports {ddr4_dm_dbi_n[3]}]
# set_property -dict {PACKAGE_PIN U22 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_ba[0]}]
# set_property -dict {PACKAGE_PIN R26 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_ba[1]}]
# set_property -dict {PACKAGE_PIN V21 IOSTANDARD SSTL12_DCI} [get_ports {ddr4_bg[0]}]
# set_property -dict {PACKAGE_PIN W25 IOSTANDARD DIFF_SSTL12_DCI} [get_ports ddr4_ck_p]
# set_property -dict {PACKAGE_PIN W26 IOSTANDARD DIFF_SSTL12_DCI} [get_ports ddr4_ck_n]
# set_property -dict {PACKAGE_PIN P23 IOSTANDARD LVCMOS12 DRIVE 8} [get_ports ddr4_reset_n]
# set_property -dict {PACKAGE_PIN V19 IOSTANDARD SSTL12_DCI} [get_ports ddr4_act_n]
# set_property -dict {PACKAGE_PIN AA25 IOSTANDARD SSTL12_DCI} [get_ports ddr4_odt]
# set_property -dict {PACKAGE_PIN Y22 IOSTANDARD SSTL12_DCI} [get_ports ddr4_cke]
# set_property -dict {PACKAGE_PIN Y26 IOSTANDARD SSTL12_DCI} [get_ports ddr4_cs_n]
# TODO(ddr4_parity/alert): Vendor XDC files do not supply I/O standards.
# set_property PACKAGE_PIN U20 [get_ports ddr4_parity]
# set_property PACKAGE_PIN R23 [get_ports ddr4_alert_n]

# PCIe Gen3 x4: PCIE_TX0-3/RX0-3, GTY quad 224. Source: pages 7 and 8, example 05.
# PCIe reference clock: PCIE_CLK_P/N, AB7/AB6, 100 MHz, MGTREFCLK0_224.
# PCIe reset uses the active reset_n port at F22 above.
# GT serial pins and reference clocks do not use SelectIO IOSTANDARD constraints.
# set_property PACKAGE_PIN AB7 [get_ports pcie_refclk_p]
# set_property PACKAGE_PIN AB6 [get_ports pcie_refclk_n]
# create_clock -name pcie_refclk -period 10.000 [get_ports pcie_refclk_p]
# set_property PACKAGE_PIN AC5 [get_ports {pcie_tx_p[0]}]
# set_property PACKAGE_PIN AC4 [get_ports {pcie_tx_n[0]}]
# set_property PACKAGE_PIN AD7 [get_ports {pcie_tx_p[1]}]
# set_property PACKAGE_PIN AD6 [get_ports {pcie_tx_n[1]}]
# set_property PACKAGE_PIN AE9 [get_ports {pcie_tx_p[2]}]
# set_property PACKAGE_PIN AE8 [get_ports {pcie_tx_n[2]}]
# set_property PACKAGE_PIN AF7 [get_ports {pcie_tx_p[3]}]
# set_property PACKAGE_PIN AF6 [get_ports {pcie_tx_n[3]}]
# set_property PACKAGE_PIN AB2 [get_ports {pcie_rx_p[0]}]
# set_property PACKAGE_PIN AB1 [get_ports {pcie_rx_n[0]}]
# set_property PACKAGE_PIN AD2 [get_ports {pcie_rx_p[1]}]
# set_property PACKAGE_PIN AD1 [get_ports {pcie_rx_n[1]}]
# set_property PACKAGE_PIN AE4 [get_ports {pcie_rx_p[2]}]
# set_property PACKAGE_PIN AE3 [get_ports {pcie_rx_n[2]}]
# set_property PACKAGE_PIN AF2 [get_ports {pcie_rx_p[3]}]
# set_property PACKAGE_PIN AF1 [get_ports {pcie_rx_n[3]}]

# QSFP: J14 QSFP28, QSFP_TX1-4/RX1-4, GTY quad 225. Source: pages 7 and 10, examples 03/04.
# Array index 0 maps to connector lane 1. Array index 3 maps to connector lane 4.
# Reference clock: GTCLK156P25M_P/N, T7/T6, MGTREFCLK1_225.
# TODO(qsfp_refclk): X2 label says 100 MHz. Net names and IBERT XDC files specify 156.25 MHz.
# TODO(qsfp_refclk): Resolve the X2 frequency before adding create_clock.
# MGTREFCLK0_225 at V7/V6 is unconnected despite example 03/04 constraints.
# QSFP MODE_SELn and LP_MODE connect to ground. RSTn has a pull-up.
# QSFP INTn/MOD_PRSn do not connect to the FPGA. SCL/SDA have pull-ups without FPGA nets.
# set_property PACKAGE_PIN T7 [get_ports qsfp_refclk_p]
# set_property PACKAGE_PIN T6 [get_ports qsfp_refclk_n]
# set_property PACKAGE_PIN AA5 [get_ports {qsfp_tx_p[0]}]
# set_property PACKAGE_PIN AA4 [get_ports {qsfp_tx_n[0]}]
# set_property PACKAGE_PIN W5 [get_ports {qsfp_tx_p[1]}]
# set_property PACKAGE_PIN W4 [get_ports {qsfp_tx_n[1]}]
# set_property PACKAGE_PIN U5 [get_ports {qsfp_tx_p[2]}]
# set_property PACKAGE_PIN U4 [get_ports {qsfp_tx_n[2]}]
# set_property PACKAGE_PIN R5 [get_ports {qsfp_tx_p[3]}]
# set_property PACKAGE_PIN R4 [get_ports {qsfp_tx_n[3]}]
# set_property PACKAGE_PIN Y2 [get_ports {qsfp_rx_p[0]}]
# set_property PACKAGE_PIN Y1 [get_ports {qsfp_rx_n[0]}]
# set_property PACKAGE_PIN V2 [get_ports {qsfp_rx_p[1]}]
# set_property PACKAGE_PIN V1 [get_ports {qsfp_rx_n[1]}]
# set_property PACKAGE_PIN T2 [get_ports {qsfp_rx_p[2]}]
# set_property PACKAGE_PIN T1 [get_ports {qsfp_rx_n[2]}]
# set_property PACKAGE_PIN P2 [get_ports {qsfp_rx_p[3]}]
# set_property PACKAGE_PIN P1 [get_ports {qsfp_rx_n[3]}]

# FMC: J6 HPC connector, 34 LA pairs, two clock pairs, eight GTY lanes.
# Source: pages 3, 4, 6, and 7. LA/clock banks 66/67 use +ADJ.
# Vendor FMC_Lnn_P/N corresponds to FMC LA[nn]. FMC_LP01_P/N corresponds to LA01.
# TODO(fmc_la/fmc_clk): Vendor XDC files do not supply I/O standards or clock frequencies.
# set_property PACKAGE_PIN G24 [get_ports {fmc_la_p[0]}]
# set_property PACKAGE_PIN G25 [get_ports {fmc_la_n[0]}]
# set_property PACKAGE_PIN D19 [get_ports {fmc_la_p[1]}]
# set_property PACKAGE_PIN D20 [get_ports {fmc_la_n[1]}]
# set_property PACKAGE_PIN E25 [get_ports {fmc_la_p[2]}]
# set_property PACKAGE_PIN E26 [get_ports {fmc_la_n[2]}]
# set_property PACKAGE_PIN E21 [get_ports {fmc_la_p[3]}]
# set_property PACKAGE_PIN D21 [get_ports {fmc_la_n[3]}]
# set_property PACKAGE_PIN H26 [get_ports {fmc_la_p[4]}]
# set_property PACKAGE_PIN G26 [get_ports {fmc_la_n[4]}]
# set_property PACKAGE_PIN A22 [get_ports {fmc_la_p[5]}]
# set_property PACKAGE_PIN A23 [get_ports {fmc_la_n[5]}]
# set_property PACKAGE_PIN C21 [get_ports {fmc_la_p[6]}]
# set_property PACKAGE_PIN B21 [get_ports {fmc_la_n[6]}]
# set_property PACKAGE_PIN D23 [get_ports {fmc_la_p[7]}]
# set_property PACKAGE_PIN C24 [get_ports {fmc_la_n[7]}]
# set_property PACKAGE_PIN A19 [get_ports {fmc_la_p[8]}]
# set_property PACKAGE_PIN A20 [get_ports {fmc_la_n[8]}]
# set_property PACKAGE_PIN D24 [get_ports {fmc_la_p[9]}]
# set_property PACKAGE_PIN D25 [get_ports {fmc_la_n[9]}]
# set_property PACKAGE_PIN D26 [get_ports {fmc_la_p[10]}]
# set_property PACKAGE_PIN C26 [get_ports {fmc_la_n[10]}]
# set_property PACKAGE_PIN F24 [get_ports {fmc_la_p[11]}]
# set_property PACKAGE_PIN F25 [get_ports {fmc_la_n[11]}]
# set_property PACKAGE_PIN A17 [get_ports {fmc_la_p[12]}]
# set_property PACKAGE_PIN A18 [get_ports {fmc_la_n[12]}]
# set_property PACKAGE_PIN B15 [get_ports {fmc_la_p[13]}]
# set_property PACKAGE_PIN A15 [get_ports {fmc_la_n[13]}]
# set_property PACKAGE_PIN J19 [get_ports {fmc_la_p[14]}]
# set_property PACKAGE_PIN J20 [get_ports {fmc_la_n[14]}]
# set_property PACKAGE_PIN J25 [get_ports {fmc_la_p[15]}]
# set_property PACKAGE_PIN J26 [get_ports {fmc_la_n[15]}]
# set_property PACKAGE_PIN C17 [get_ports {fmc_la_p[16]}]
# set_property PACKAGE_PIN B17 [get_ports {fmc_la_n[16]}]
# set_property PACKAGE_PIN C18 [get_ports {fmc_la_p[17]}]
# set_property PACKAGE_PIN C19 [get_ports {fmc_la_n[17]}]
# set_property PACKAGE_PIN B19 [get_ports {fmc_la_p[18]}]
# set_property PACKAGE_PIN B20 [get_ports {fmc_la_n[18]}]
# set_property PACKAGE_PIN A24 [get_ports {fmc_la_p[19]}]
# set_property PACKAGE_PIN A25 [get_ports {fmc_la_n[19]}]
# set_property PACKAGE_PIN L18 [get_ports {fmc_la_p[20]}]
# set_property PACKAGE_PIN K18 [get_ports {fmc_la_n[20]}]
# set_property PACKAGE_PIN B25 [get_ports {fmc_la_p[21]}]
# set_property PACKAGE_PIN B26 [get_ports {fmc_la_n[21]}]
# set_property PACKAGE_PIN C22 [get_ports {fmc_la_p[22]}]
# set_property PACKAGE_PIN B22 [get_ports {fmc_la_n[22]}]
# set_property PACKAGE_PIN F23 [get_ports {fmc_la_p[23]}]
# set_property PACKAGE_PIN E23 [get_ports {fmc_la_n[23]}]
# set_property PACKAGE_PIN C23 [get_ports {fmc_la_p[24]}]
# set_property PACKAGE_PIN B24 [get_ports {fmc_la_n[24]}]
# set_property PACKAGE_PIN F20 [get_ports {fmc_la_p[25]}]
# set_property PACKAGE_PIN E20 [get_ports {fmc_la_n[25]}]
# set_property PACKAGE_PIN M19 [get_ports {fmc_la_p[26]}]
# set_property PACKAGE_PIN L19 [get_ports {fmc_la_n[26]}]
# set_property PACKAGE_PIN F18 [get_ports {fmc_la_p[27]}]
# set_property PACKAGE_PIN F19 [get_ports {fmc_la_n[27]}]
# set_property PACKAGE_PIN H21 [get_ports {fmc_la_p[28]}]
# set_property PACKAGE_PIN H22 [get_ports {fmc_la_n[28]}]
# set_property PACKAGE_PIN M20 [get_ports {fmc_la_p[29]}]
# set_property PACKAGE_PIN M21 [get_ports {fmc_la_n[29]}]
# set_property PACKAGE_PIN D16 [get_ports {fmc_la_p[30]}]
# set_property PACKAGE_PIN C16 [get_ports {fmc_la_n[30]}]
# set_property PACKAGE_PIN K21 [get_ports {fmc_la_p[31]}]
# set_property PACKAGE_PIN J21 [get_ports {fmc_la_n[31]}]
# set_property PACKAGE_PIN G20 [get_ports {fmc_la_p[32]}]
# set_property PACKAGE_PIN G21 [get_ports {fmc_la_n[32]}]
# set_property PACKAGE_PIN H18 [get_ports {fmc_la_p[33]}]
# set_property PACKAGE_PIN H19 [get_ports {fmc_la_n[33]}]
# set_property PACKAGE_PIN J23 [get_ports {fmc_clk_p[0]}]
# set_property PACKAGE_PIN J24 [get_ports {fmc_clk_n[0]}]
# set_property PACKAGE_PIN H23 [get_ports {fmc_clk_p[1]}]
# set_property PACKAGE_PIN H24 [get_ports {fmc_clk_n[1]}]

# FMC management: FMC_SCL/SDA, bank 86, and FMC_PWRGD, bank 84.
# Source: pages 3 and 4. SCL/SDA have 3.3 V pull-ups.
# TODO(fmc_management): Vendor XDC files do not supply I/O standards. PWRGD direction and polarity need confirmation.
# set_property PACKAGE_PIN K9 [get_ports fmc_scl]
# set_property PACKAGE_PIN K10 [get_ports fmc_sda]
# set_property PACKAGE_PIN W15 [get_ports fmc_pwrgd]
# FMC HA/HB, connector JTAG, PRSNT_M2C_L, and PG_M2C have no FPGA nets in the schematic.

# FMC GTY: FMC_GTY_TX/RX0-3 use quad 227. FMC_GTY_TX/RX4-7 use quad 226.
# FMC_GTY_CLK_0_P/N uses M7/M6, MGTREFCLK1_226.
# FMC_GTY_CLK_1_P/N uses K7/K6, MGTREFCLK0_227.
# Source: pages 3 and 7. GT pins do not use SelectIO IOSTANDARD constraints.
# TODO(fmc_gty_clk): The schematic does not specify the external reference clock frequencies.
# set_property PACKAGE_PIN M7 [get_ports {fmc_gty_clk_p[0]}]
# set_property PACKAGE_PIN M6 [get_ports {fmc_gty_clk_n[0]}]
# set_property PACKAGE_PIN K7 [get_ports {fmc_gty_clk_p[1]}]
# set_property PACKAGE_PIN K6 [get_ports {fmc_gty_clk_n[1]}]
# set_property PACKAGE_PIN B7 [get_ports {fmc_gty_tx_p[0]}]
# set_property PACKAGE_PIN B6 [get_ports {fmc_gty_tx_n[0]}]
# set_property PACKAGE_PIN D7 [get_ports {fmc_gty_tx_p[1]}]
# set_property PACKAGE_PIN D6 [get_ports {fmc_gty_tx_n[1]}]
# set_property PACKAGE_PIN E5 [get_ports {fmc_gty_tx_p[2]}]
# set_property PACKAGE_PIN E4 [get_ports {fmc_gty_tx_n[2]}]
# set_property PACKAGE_PIN F7 [get_ports {fmc_gty_tx_p[3]}]
# set_property PACKAGE_PIN F6 [get_ports {fmc_gty_tx_n[3]}]
# set_property PACKAGE_PIN G5 [get_ports {fmc_gty_tx_p[4]}]
# set_property PACKAGE_PIN G4 [get_ports {fmc_gty_tx_n[4]}]
# set_property PACKAGE_PIN J5 [get_ports {fmc_gty_tx_p[5]}]
# set_property PACKAGE_PIN J4 [get_ports {fmc_gty_tx_n[5]}]
# set_property PACKAGE_PIN L5 [get_ports {fmc_gty_tx_p[6]}]
# set_property PACKAGE_PIN L4 [get_ports {fmc_gty_tx_n[6]}]
# set_property PACKAGE_PIN N5 [get_ports {fmc_gty_tx_p[7]}]
# set_property PACKAGE_PIN N4 [get_ports {fmc_gty_tx_n[7]}]
# set_property PACKAGE_PIN A4 [get_ports {fmc_gty_rx_p[0]}]
# set_property PACKAGE_PIN A3 [get_ports {fmc_gty_rx_n[0]}]
# set_property PACKAGE_PIN B2 [get_ports {fmc_gty_rx_p[1]}]
# set_property PACKAGE_PIN B1 [get_ports {fmc_gty_rx_n[1]}]
# set_property PACKAGE_PIN C4 [get_ports {fmc_gty_rx_p[2]}]
# set_property PACKAGE_PIN C3 [get_ports {fmc_gty_rx_n[2]}]
# set_property PACKAGE_PIN D2 [get_ports {fmc_gty_rx_p[3]}]
# set_property PACKAGE_PIN D1 [get_ports {fmc_gty_rx_n[3]}]
# set_property PACKAGE_PIN F2 [get_ports {fmc_gty_rx_p[4]}]
# set_property PACKAGE_PIN F1 [get_ports {fmc_gty_rx_n[4]}]
# set_property PACKAGE_PIN H2 [get_ports {fmc_gty_rx_p[5]}]
# set_property PACKAGE_PIN H1 [get_ports {fmc_gty_rx_n[5]}]
# set_property PACKAGE_PIN K2 [get_ports {fmc_gty_rx_p[6]}]
# set_property PACKAGE_PIN K1 [get_ports {fmc_gty_rx_n[6]}]
# set_property PACKAGE_PIN M2 [get_ports {fmc_gty_rx_p[7]}]
# set_property PACKAGE_PIN M1 [get_ports {fmc_gty_rx_n[7]}]

# Configuration flash: U15 MT25QU256ABA1EW9-0SIT, 1.8 V, dedicated bank 0.
# Source: pages 1 and 13, examples 01/02/05/07/08.
# FLASH_CLK = Y11 (CCLK). FLASH_CE = AA12 (FCS_B, active low).
# FLASH_D0/D1/D2/D3 = AD11/AC12/AC11/AE11.
# Flash access after configuration uses STARTUPE3 rather than ordinary top-level package constraints.
# JTAG: FPGA_TCK/TMS/TDI/TDO = AE12/AB10/AB12/Y10. Source: pages 1 and 13.
# FPGA_DONE = AB11. RST_1V8 = W10 (INIT_B, active low).
# PROGRAM_B = AB9 has a pull-up. PUDC_B = W9 has a pull-up.
# POR_OVERRIDE = Y12 connects to ground. Reserved W11 connects to ground.
# Analog DXP/DXN/VP/VN/VREFP/VREFN = T14/T13/P14/R13/R14/P13 connect to ground.
# Mode straps: M2/M1/M0 = AF12/AA9/AA10 = ground/ground/1.8 V (SPI).
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 51.0 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
