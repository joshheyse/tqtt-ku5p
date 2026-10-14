`timescale 1ns / 1ns
module fsm_sd_chk (
  input             clk,
  rst,
  start,
  input             sd_init_done,
  output reg        sd_sec_read,
  output reg [31:0] sd_sec_read_addr,
  input      [ 7:0] sd_sec_read_data,
  input             sd_sec_read_data_valid,
  input             sd_sec_read_end,
  output reg        sd_sec_write,
  output reg [31:0] sd_sec_write_addr,
  output reg [ 7:0] sd_sec_write_data,
  input             sd_sec_write_data_req,
  input             sd_sec_write_end,
  output reg        chk_err,
  chk_done,
  time_out
);
  reg [7:0] st;
  reg       err;
  initial begin
    err = 1'b0;
  end
  always @(posedge clk) begin
    if (rst) begin
      st <= 0;
    end else begin
      case (st)
        0: begin
          st <= 1;
        end
        1: begin
          if (sd_init_done) begin
            st <= 2;
          end
        end
        2: begin
          st <= 3;
        end
        3: begin
          if (sd_sec_write_end) begin
            st <= 4;
          end
        end
        4: begin
          if (sd_sec_read_end) begin
            st <= 5;
          end
        end
        5: begin
          st <= 6;
        end
        6: begin
          if (err) begin
            st <= 10;
          end else begin
            st <= 7;
          end
        end
        7: begin
          st <= 20;
        end
        10: begin
          st <= 20;
        end
        20: begin
          st <= 21;
        end
        21: begin
          if (start) begin
            st <= 2;
          end
        end
        default: begin
          st <= 0;
        end
      endcase
    end
  end
  reg [7:0] wr_data, rd_data;
  reg [7:0] start_value;
  always @(posedge clk) begin
    if (st == 3) begin
      sd_sec_write <= ~sd_sec_write_end;
    end else begin
      sd_sec_write <= 0;
    end
    if (st == 4) begin
      sd_sec_read <= ~sd_sec_read_end;
    end else begin
      sd_sec_read <= 0;
    end
    if (st == 0) begin
      start_value <= 0;
    end else begin
      if (st == 20) begin
        start_value <= 1 + start_value;
      end
    end
    if (st == 2) begin
      wr_data <= start_value;
    end else begin
      if (sd_sec_write_data_req) begin
        wr_data <= 1 + wr_data;
      end
    end
    if (st == 2) begin
      rd_data <= start_value;
    end else begin
      if (sd_sec_read_data_valid) begin
        rd_data <= 1 + rd_data;
      end
    end
    if (st == 6) begin
      chk_err <= err;
    end
    if (st == 2) begin
      chk_done <= 0;
    end else begin
      if (st == 20) begin
        chk_done <= 1;
      end
    end
    if (st == 2) begin
      err <= 0;
    end else begin
      if ((sd_sec_read_data_valid == 1) && (sd_sec_read_data != rd_data)) begin
        err <= 1;
      end
    end
  end
  wire [31:0] sec_addr = {24'd0, start_value};
  always @(posedge clk) begin
    sd_sec_read_addr  <= sec_addr;
    sd_sec_write_addr <= sec_addr;
  end
  always_comb begin
    sd_sec_write_data = wr_data;
  end
  reg [31:0] c;
  always @(posedge clk) begin
    if (st == 0 || st == 20) begin
      c <= 0;
    end else begin
      if (c[26] == 0) begin
        c <= 1 + c;
      end
    end
    time_out <= c[26];
  end
endmodule
