`timescale 1ns / 1ns
module top (
  // 50Mhz clock input
  input            clk,
  //sd card interface
  output           SD_nCS,
  output           SD_DCLK,
  output           SD_MOSI,
  input            SD_MISO,
  output reg [3:0] led,
  input            arst
);
  wire time_out, sd_chk_done, sd_chk_err;
  wire unused_arst = arst;
  sd_card_test sd_card_test (
    .clk(clk),
    .rst(1'b0),
    .SD_nCS(SD_nCS),
    .SD_DCLK(SD_DCLK),
    .SD_MOSI(SD_MOSI),
    .SD_MISO(SD_MISO),
    .chk_err(sd_chk_err),
    .chk_done(sd_chk_done),
    .time_out(time_out)
  );
  reg sd_err;
  always @(posedge clk) begin
    if (sd_chk_done) begin
      sd_err <= sd_chk_err;
    end else begin
      sd_err <= time_out;
    end
    led[3:0] <= {sd_err, sd_chk_done, sd_chk_err, time_out};
  end
endmodule
