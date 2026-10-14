//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
//Date        : Tue Dec  9 19:56:36 2025
//Host        : DESKTOP-QUURC0C running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module my_top
   (
  input clk_50MHz,
  input rxd,
  output txd,
  
  output PMOD0_1,
  output PMOD0_2
  
);

assign PMOD0_1  = rxd;
assign PMOD0_2  = txd;


  design_1 design_1_i
       (.clk_50MHz(clk_50MHz),
        .rxd(rxd),
        .txd(txd));
endmodule
