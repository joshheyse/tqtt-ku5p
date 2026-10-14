`timescale 1ns / 1ns
module sd_card_test (
  input  clk,
  rst,
  output SD_nCS,
  output SD_DCLK,
  output SD_MOSI,
  input  SD_MISO,
  output chk_err,
  output chk_done,
  time_out
);
  wire        sd_sec_read;
  wire [31:0] sd_sec_read_addr;
  wire [ 7:0] sd_sec_read_data;
  wire        sd_sec_read_data_valid;
  wire        sd_sec_read_end;
  wire        sd_sec_write;
  wire [31:0] sd_sec_write_addr;
  wire [ 7:0] sd_sec_write_data;
  wire        sd_sec_write_data_req;
  wire        sd_sec_write_end;
  wire        sd_init_done;
  reg  [24:0] c;
  initial begin
    c = 25'd0;
  end
  always @(posedge clk) begin
    c <= c + 1;
  end
  reg start;
  initial begin
    start = 1'b0;
  end
  always @(posedge clk) begin
    start <= c == 0;
  end
  fsm_sd_chk fsm_sd_chk (
    .clk(clk),
    .rst(rst),
    .start(start),
    .sd_init_done(sd_init_done),
    .sd_sec_read(sd_sec_read),
    .sd_sec_read_addr(sd_sec_read_addr),
    .sd_sec_read_data(sd_sec_read_data),
    .sd_sec_read_data_valid(sd_sec_read_data_valid),
    .sd_sec_read_end(sd_sec_read_end),
    .sd_sec_write(sd_sec_write),
    .sd_sec_write_addr(sd_sec_write_addr),
    .sd_sec_write_data(sd_sec_write_data),
    .sd_sec_write_data_req(sd_sec_write_data_req),
    .sd_sec_write_end(sd_sec_write_end),
    .chk_err(chk_err),
    .chk_done(chk_done),
    .time_out(time_out)
  );
  sd_card_top sd_card_top_m0 (
    .clk(clk),
    .rst(rst),
    .SD_nCS(SD_nCS),
    .SD_DCLK(SD_DCLK),
    .SD_MOSI(SD_MOSI),
    .SD_MISO(SD_MISO),
    .sd_init_done(sd_init_done),
    .sd_sec_read(sd_sec_read),
    .sd_sec_read_addr(sd_sec_read_addr),
    .sd_sec_read_data(sd_sec_read_data),
    .sd_sec_read_data_valid(sd_sec_read_data_valid),
    .sd_sec_read_end(sd_sec_read_end),
    .sd_sec_write(sd_sec_write),
    .sd_sec_write_addr(sd_sec_write_addr),
    .sd_sec_write_data(sd_sec_write_data),
    .sd_sec_write_data_req(sd_sec_write_data_req),
    .sd_sec_write_end(sd_sec_write_end)
  );
endmodule
