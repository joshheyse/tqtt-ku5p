`define VGA_1920X1080_60HZ_148_5MHZ
`ifdef VGA_640x480_60HZ_25MHz
//640x480@60HZ_25MHz clock.
`define H_ACTIVE 640
`define H_FRONT 16
`define H_SYNC 96
`define H_BACK 48
`define V_ACTIVE 480
`define V_FRONT 11
`define V_SYNC 2
`define V_BACK 31
`endif
`ifdef VGA_800x600_60HZ_40MHz
//800x600@60HZ_40MHz clock.
`define H_SYNC 128
`define H_BACK 88
`define H_ACTIVE 800
`define H_FRONT 40
`define V_SYNC 4
`define V_BACK 23
`define V_ACTIVE 600
`define V_FRONT 1
`endif
`ifdef VGA_1024x768_60HZ_65MHz
//1024x768@60HZ_65MHz clock.
`define H_SYNC 136
`define H_BACK 160
`define H_ACTIVE 1024
`define H_FRONT 24
`define V_SYNC 6
`define V_BACK 29
`define V_ACTIVE 768
`define V_FRONT 3
`endif
`ifdef VGA_1440x900_60HZ_106_5MHz
//1440x900@60HZ_106.5MHz clock.
`define H_SYNC 152
`define H_BACK 232
`define H_ACTIVE 1440
`define H_FRONT 80
`define V_SYNC 6
`define V_BACK 25
`define V_ACTIVE 900
`define V_FRONT 3
`endif
`ifdef VGA_1280x1024_60HZ_108MHz
//1280x1024@60HZ_108MHz clock.
`define H_SYNC 112
`define H_BACK 248
`define H_ACTIVE 1280
`define H_FRONT 48
`define V_SYNC 3
`define V_BACK 38
`define V_ACTIVE 1024
`define V_FRONT 1
`endif
`ifdef VGA_1600x1200_60HZ_175_5MHz
//1600x1200@65HZ_175.5MHz clock.
`define H_SYNC 192
`define H_BACK 304
`define H_ACTIVE 1600
`define H_FRONT 64
`define V_SYNC 3
`define V_BACK 46
`define V_ACTIVE 1200
`define V_FRONT 1
`endif
`ifdef VGA_1920X1080_60HZ_148_5MHZ
//1920x1080_60HZ_148_5MHz clock.
`define H_SYNC 44
`define H_BACK 148
`define H_ACTIVE 1920
`define H_FRONT 88
`define V_SYNC 5
`define V_BACK 36
`define V_ACTIVE 1080
`define V_FRONT 4
`endif
// (c) fpga4fun.com & KNJN LLC 2013
////////////////////////////////////////////////////////////////////////
module HDMI_test_TOP (
  input        clk_i,
  output [2:0] TMDSp,
  TMDSn,
  output       TMDSp_clock,
  TMDSn_clock,
  output       LED,
  HDMI0_OE
);
  reg [31:0] c;
  wire pclk, pclkx10;
  always @(posedge pclk) begin
    c <= c + 1;
  end
  assign LED = c[23];
  assign HDMI0_OE = 1;
  clk_wiz_0 instance_name (
    .clk_out1(pclk),
    .clk_out2(pclkx10),
    .clk_in1(clk_i)
  );
  HDMI_test #(
    .H_ACTIVE(`H_ACTIVE),
    .H_FRONT(`H_FRONT),
    .H_SYNC(`H_SYNC),
    .H_BACK(`H_BACK),
    .V_ACTIVE(`V_ACTIVE),
    .V_FRONT(`V_FRONT),
    .V_SYNC(`V_SYNC),
    .V_BACK(`V_BACK)
  ) uu (
    .pixclk(pclk),
    .clk_TMDS(pclkx10),
    .TMDSp(TMDSp),
    .TMDSn(TMDSn),
    .TMDSp_clock(TMDSp_clock),
    .TMDSn_clock(TMDSn_clock)
  );
endmodule
