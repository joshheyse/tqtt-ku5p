`timescale 1ns / 1ns
module tb_lw_sd_test;
  reg clk = 0;
  reg rst = 0;
  always begin
    #5 clk = !clk;
  end
  initial begin
    $dumpfile("tb_lw_sd_test.vcd");
    $dumpvars(0, tb_lw_sd_test);
    #10;
    rst = 1;
    #100;
    rst = 0;
    #10000000;
    #10000000;
    #10000000;
    #10000000;
    #10000000;
    #10000000;
    #10000000;
    #10000000;
    #10000000;
    #10000000;
    #10000000;
    $finish;
  end
  wire SD_nCS, SD_DCLK, SD_MOSI, chk_err, chk_done, time_out;
  sd_card_test sd_card_test (
    .clk(clk),
    .rst(rst),
    .SD_nCS(SD_nCS),
    .SD_DCLK(SD_DCLK),
    .SD_MOSI(SD_MOSI),
    .SD_MISO(1'b1),
    .chk_err(chk_err),
    .chk_done(chk_done),
    .time_out(time_out)
  );
endmodule
