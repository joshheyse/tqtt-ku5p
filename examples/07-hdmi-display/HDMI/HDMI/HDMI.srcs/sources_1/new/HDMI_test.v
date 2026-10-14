module HDMI_test #(
  parameter integer H_ACTIVE = 1920,
  parameter integer H_FRONT  = 88,
  parameter integer H_SYNC   = 44,
  parameter integer H_BACK   = 148,
  parameter integer V_ACTIVE = 1080,
  parameter integer V_FRONT  = 4,
  parameter integer V_SYNC   = 5,
  parameter integer V_BACK   = 36
) (
  input        pixclk,
  clk_TMDS,
  output [2:0] TMDSp,
  TMDSn,
  output       TMDSp_clock,
  TMDSn_clock
);
  parameter integer H_TOTAL = H_SYNC + H_BACK + H_ACTIVE + H_FRONT;
  parameter integer V_TOTAL = V_SYNC + V_BACK + V_ACTIVE + V_FRONT;
  ////////////////////////////////////////////////////////////////////////
  reg [31:0] CounterX, CounterY;
  reg hSync, vSync, DrawArea;
  wire [7:0] W;
  wire [7:0] A;
  reg [7:0] red, green, blue;
  always @(posedge pixclk) begin
    DrawArea <= (CounterX < H_ACTIVE) && (CounterY < V_ACTIVE);
    CounterX <= (CounterX == (H_TOTAL - 1)) ? 0 : CounterX + 1;
    if (CounterX == (H_TOTAL - 1)) begin
      CounterY <= (CounterY == (V_TOTAL - 1)) ? 0 : CounterY + 1;
    end
    hSync <= (CounterX >= (H_FRONT + H_ACTIVE)) && (CounterX < (H_FRONT + H_ACTIVE + H_SYNC));
    vSync <= (CounterY >= (V_FRONT + V_ACTIVE)) && (CounterY < (V_FRONT + V_ACTIVE + V_SYNC));
    red   <= ({CounterX[5:0] & {6{CounterY[4:3] == ~CounterX[4:3]}}, 2'b00} | W) & ~A;
    green <= (CounterX[7:0] & {8{CounterY[6]}} | W) & ~A;
    blue  <= CounterY[7:0] | W | A;
  end
  assign W = {8{CounterX[7:0] == CounterY[7:0]}};
  assign A = {8{CounterX[7:5] == 3'h2 && CounterY[7:5] == 3'h2}};
  ////////////////////////////////////////////////////////////////////////
  wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
  TMDS_encoder encode_R (
    .clk(pixclk),
    .VD(red),
    .CD(2'b00),
    .VDE(DrawArea),
    .TMDS(TMDS_red)
  );
  TMDS_encoder encode_G (
    .clk(pixclk),
    .VD(green),
    .CD(2'b00),
    .VDE(DrawArea),
    .TMDS(TMDS_green)
  );
  TMDS_encoder encode_B (
    .clk(pixclk),
    .VD(blue),
    .CD({vSync, hSync}),
    .VDE(DrawArea),
    .TMDS(TMDS_blue)
  );
  reg [3:0] TMDS_mod10 = 0;  // modulus 10 counter
  reg [9:0] TMDS_shift_red = 0, TMDS_shift_green = 0, TMDS_shift_blue = 0;
  reg TMDS_shift_load = 0;
  always @(posedge clk_TMDS) begin
    TMDS_shift_load <= (TMDS_mod10 == 4'd9);
    TMDS_shift_red <= TMDS_shift_load ? TMDS_red : {1'b0, TMDS_shift_red[9:1]};
    TMDS_shift_green <= TMDS_shift_load ? TMDS_green : {1'b0, TMDS_shift_green[9:1]};
    TMDS_shift_blue <= TMDS_shift_load ? TMDS_blue : {1'b0, TMDS_shift_blue[9:1]};
    TMDS_mod10 <= (TMDS_mod10 == 4'd9) ? 4'd0 : TMDS_mod10 + 4'd1;
  end
  OBUFDS OBUFDS_red (
    .I(TMDS_shift_red[0]),
    .O(TMDSp[2]),
    .OB(TMDSn[2])
  );
  OBUFDS OBUFDS_green (
    .I(TMDS_shift_green[0]),
    .O(TMDSp[1]),
    .OB(TMDSn[1])
  );
  OBUFDS OBUFDS_blue (
    .I(TMDS_shift_blue[0]),
    .O(TMDSp[0]),
    .OB(TMDSn[0])
  );
  OBUFDS OBUFDS_clock (
    .I(pixclk),
    .O(TMDSp_clock),
    .OB(TMDSn_clock)
  );
endmodule
