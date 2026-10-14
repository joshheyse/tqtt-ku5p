`timescale 1ns / 1ns
// Copyright (c) 2017, ALINX (Shanghai) Technology Co., Ltd.
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
module sd_card_sec_read_write #(
  parameter integer SPI_LOW_SPEED_DIV  = 248,
  parameter integer SPI_HIGH_SPEED_DIV = 0
) (
  input             clk,
  input             rst,
  output reg        sd_init_done,
  input             sd_sec_read,
  input      [31:0] sd_sec_read_addr,
  output     [ 7:0] sd_sec_read_data,
  output            sd_sec_read_data_valid,
  output            sd_sec_read_end,
  input             sd_sec_write,
  input      [31:0] sd_sec_write_addr,
  input      [ 7:0] sd_sec_write_data,
  output reg        sd_sec_write_data_req,
  output            sd_sec_write_end,
  output reg [15:0] spi_clk_div,
  output reg        cmd_req,
  input             cmd_req_ack,
  input             cmd_req_error,
  output reg [47:0] cmd,
  output reg [ 7:0] cmd_r1,
  output reg [15:0] cmd_data_len,
  output reg        block_read_req,
  input             block_read_valid,
  input      [ 7:0] block_read_data,
  input             block_read_req_ack,
  output reg        block_write_req,
  output     [ 7:0] block_write_data,
  input             block_write_data_rd,
  input             block_write_req_ack
);
  localparam logic [4:0] SIDLE = 5'd0;
  localparam logic [4:0] SCMD0 = 5'd1;
  localparam logic [4:0] SCMD8 = 5'd2;
  localparam logic [4:0] SCMD55 = 5'd3;
  localparam logic [4:0] SCMD41 = 5'd4;
  localparam logic [4:0] SCMD17 = 5'd5;
  localparam logic [4:0] SREAD = 5'd6;
  localparam logic [4:0] SCMD24 = 5'd7;
  localparam logic [4:0] SWRITE = 5'd8;
  localparam logic [4:0] SWRITEEND = 5'd15;
  localparam logic [4:0] SREADEND = 5'd16;
  localparam logic [4:0] SWAITREADWRITE = 5'd17;
  localparam logic [4:0] SCMD16 = 5'd18;
  reg [ 4:0] state;
  reg [31:0] sec_addr;
  assign sd_sec_read_data_valid = (state == SREAD) && block_read_valid;
  assign sd_sec_read_data = block_read_data;
  assign sd_sec_read_end = (state == SREADEND);
  wire sd_sec_write_data_req_w = (state == SWRITE) && block_write_data_rd;
  always @(posedge clk) begin
    sd_sec_write_data_req <= sd_sec_write_data_req_w;
  end
  assign block_write_data = sd_sec_write_data;
  assign sd_sec_write_end = (state == SWRITEEND);
  always @(posedge clk) begin
    if (rst == 1'b1) begin
      state <= SIDLE;
      cmd_req <= 1'b0;
      cmd_data_len <= 16'd0;
      cmd_r1 <= 8'd0;
      cmd <= 48'd0;
      spi_clk_div <= SPI_LOW_SPEED_DIV[15:0];
      block_write_req <= 1'b0;
      block_read_req <= 1'b0;
      sec_addr <= 32'd0;
      sd_init_done <= 1'b0;
    end else begin
      case (state)
        SIDLE: begin
          state <= SCMD0;
          sd_init_done <= 1'b0;
          spi_clk_div <= SPI_LOW_SPEED_DIV[15:0];
        end
        SCMD0: begin
          if (cmd_req_ack & ~cmd_req_error) begin
            state   <= SCMD8;
            cmd_req <= 1'b0;
          end else begin
            cmd_req <= 1'b1;
            cmd_data_len <= 16'd0;
            cmd_r1 <= 8'h01;
            cmd <= {8'd0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h95};
          end
        end
        SCMD8: begin
          if (cmd_req_ack & ~cmd_req_error) begin
            state   <= SCMD55;
            cmd_req <= 1'b0;
          end else begin
            cmd_req <= 1'b1;
            cmd_data_len <= 16'd4;
            cmd_r1 <= 8'h01;
            cmd <= {8'd8, 8'h00, 8'h00, 8'h01, 8'haa, 8'h87};
          end
        end
        SCMD55: begin
          if (cmd_req_ack & ~cmd_req_error) begin
            state   <= SCMD41;
            cmd_req <= 1'b0;
          end else begin
            cmd_req <= 1'b1;
            cmd_data_len <= 16'd0;
            cmd_r1 <= 8'h01;
            cmd <= {8'd55, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff};
          end
        end
        SCMD41: begin
          if (cmd_req_ack & ~cmd_req_error) begin
            state <= SCMD16;
            cmd_req <= 1'b0;
            sd_init_done <= 1'b1;
            spi_clk_div <= SPI_HIGH_SPEED_DIV[15:0];
          end else begin
            if (cmd_req_ack) begin
              state <= SCMD55;
            end else begin
              cmd_req <= 1'b1;
              cmd_data_len <= 16'd0;
              cmd_r1 <= 8'h00;
              cmd <= {8'd41, 8'h40, 8'h00, 8'h00, 8'h00, 8'hff};
            end
          end
        end
        SCMD16: begin
          if (cmd_req_ack & ~cmd_req_error) begin
            state <= SWAITREADWRITE;
            cmd_req <= 1'b0;
            sd_init_done <= 1'b1;
            spi_clk_div <= SPI_HIGH_SPEED_DIV[15:0];
          end else begin
            if (cmd_req_ack) begin
              state <= SCMD55;
            end else begin
              cmd_req <= 1'b1;
              cmd_data_len <= 16'd0;
              cmd_r1 <= 8'h00;
              cmd <= {8'd16, 32'd512, 8'hff};
            end
          end
        end
        SWAITREADWRITE: begin
          if (sd_sec_write == 1'b1) begin
            state <= SCMD24;
            sec_addr <= sd_sec_write_addr;
          end else begin
            if (sd_sec_read == 1'b1) begin
              state <= SCMD17;
              sec_addr <= sd_sec_read_addr;
            end
          end
          spi_clk_div <= 16'd0;
        end
        SCMD24: begin
          if (cmd_req_ack & ~cmd_req_error) begin
            state   <= SWRITE;
            cmd_req <= 1'b0;
          end else begin
            cmd_req <= 1'b1;
            cmd_data_len <= 16'd0;
            cmd_r1 <= 8'h00;
            cmd <= {8'd24, sec_addr, 8'hff};
          end
        end
        SWRITE: begin
          if (block_write_req_ack == 1'b1) begin
            block_write_req <= 1'b0;
            state <= SWRITEEND;
          end else begin
            block_write_req <= 1'b1;
          end
        end
        SCMD17: begin
          if (cmd_req_ack & ~cmd_req_error) begin
            state   <= SREAD;
            cmd_req <= 1'b0;
          end else begin
            cmd_req <= 1'b1;
            cmd_data_len <= 16'd0;
            cmd_r1 <= 8'h00;
            cmd <= {8'd17, sec_addr, 8'hff};
          end
        end
        SREAD: begin
          if (block_read_req_ack) begin
            state <= SREADEND;
            block_read_req <= 1'b0;
          end else begin
            block_read_req <= 1'b1;
          end
        end
        SWRITEEND: begin
          state <= SWAITREADWRITE;
        end
        SREADEND: begin
          state <= SWAITREADWRITE;
        end
        default: begin
          state <= SIDLE;
        end
      endcase
    end
  end
endmodule
