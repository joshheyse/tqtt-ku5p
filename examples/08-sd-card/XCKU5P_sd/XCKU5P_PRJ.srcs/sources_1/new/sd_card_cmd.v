`timescale 1ns / 1ns
// Copyright (c) 2017, ALINX (Shanghai) Technology Co., Ltd.
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
module sd_card_cmd (
  input             sys_clk,
  input             rst,
  input      [15:0] spi_clk_div,
  input             cmd_req,
  output            cmd_req_ack,
  output reg        cmd_req_error,
  input      [47:0] cmd,
  input      [ 7:0] cmd_r1,
  input      [15:0] cmd_data_len,
  input             block_read_req,
  output reg        block_read_valid,
  output reg [ 7:0] block_read_data,
  output            block_read_req_ack,
  input             block_write_req,
  input      [ 7:0] block_write_data,
  output            block_write_data_rd,
  output            block_write_req_ack,
  output            nCS_ctrl,
  output reg [15:0] clk_div,
  output reg        spi_wr_req,
  input             spi_wr_ack,
  output     [ 7:0] spi_data_in,
  input      [ 7:0] spi_data_out
);
  parameter logic [4:0] S_IDLE = 5'd0;
  parameter logic [4:0] S_WAIT = 5'd1;
  parameter logic [4:0] S_INIT = 5'd2;
  parameter logic [4:0] S_CMD_PRE = 5'd3;
  parameter logic [4:0] S_CMD = 5'd4;
  parameter logic [4:0] S_CMD_DATA = 5'd5;
  parameter logic [4:0] S_READ_WAIT = 5'd6;
  parameter logic [4:0] S_READ = 5'd7;
  parameter logic [4:0] S_READ_ACK = 5'd8;
  parameter logic [4:0] S_WRITE_TOKEN = 5'd9;
  parameter logic [4:0] S_WRITE_DATA_0 = 5'd10;
  parameter logic [4:0] S_WRITE_DATA_1 = 5'd11;
  parameter logic [4:0] S_WRITE_CRC = 5'd12;
  parameter logic [4:0] S_WRITE_SUC = 5'd13;
  parameter logic [4:0] S_WRITE_BUSY = 5'd14;
  parameter logic [4:0] S_WRITE_ACK = 5'd15;
  parameter logic [4:0] S_ERR = 5'd16;
  parameter logic [4:0] S_END = 5'd17;
  reg  [ 4:0] state;
  reg         CS_reg;
  reg  [15:0] byte_cnt;
  reg  [ 7:0] send_data;
  wire [ 7:0] data_recv;
  reg  [ 9:0] wr_data_cnt;
  assign cmd_req_ack = (state == S_END);
  assign block_read_req_ack = (state == S_READ_ACK);
  assign block_write_req_ack = (state == S_WRITE_ACK);
  assign block_write_data_rd = (state == S_WRITE_DATA_0);
  assign spi_data_in = send_data;
  assign data_recv = spi_data_out;
  assign nCS_ctrl = CS_reg;
  always @(posedge sys_clk) begin
    if (rst == 1'b1) begin
      CS_reg <= 1'b1;
      spi_wr_req <= 1'b0;
      byte_cnt <= 16'd0;
      clk_div <= 16'd0;
      send_data <= 8'hff;
      state <= S_IDLE;
      cmd_req_error <= 1'b0;
      wr_data_cnt <= 10'd0;
    end else begin
      case (state)
        S_IDLE: begin
          state   <= S_INIT;
          clk_div <= spi_clk_div;
          CS_reg  <= 1'b1;
        end
        S_INIT: begin
          if (spi_wr_ack == 1'b1) begin
            if (byte_cnt >= 16'd10) begin
              byte_cnt <= 16'd0;
              spi_wr_req <= 1'b0;
              state <= S_WAIT;
            end
            begin
              byte_cnt <= byte_cnt + 16'd1;
            end
          end else begin
            spi_wr_req <= 1'b1;
            send_data  <= 8'hff;
          end
        end
        S_WAIT: begin
          cmd_req_error <= 1'b0;
          wr_data_cnt   <= 10'd0;
          if (cmd_req == 1'b1) begin
            state <= S_CMD_PRE;
          end else begin
            if (block_read_req == 1'b1) begin
              state <= S_READ_WAIT;
            end else begin
              if (block_write_req == 1'b1) begin
                state <= S_WRITE_TOKEN;
              end
            end
          end
          clk_div <= spi_clk_div;
        end
        S_CMD_PRE: begin
          if (spi_wr_ack == 1'b1) begin
            state <= S_CMD;
            spi_wr_req <= 1'b0;
            byte_cnt <= 16'd0;
          end else begin
            spi_wr_req <= 1'b1;
            CS_reg <= 1'b1;
            send_data <= 8'hff;
          end
        end
        S_CMD: begin
          if (spi_wr_ack == 1'b1) begin
            if ((byte_cnt == 16'hffff) || (data_recv != cmd_r1 && data_recv[7] == 1'b0)) begin
              state <= S_ERR;
              spi_wr_req <= 1'b0;
              byte_cnt <= 16'd0;
            end else begin
              if (data_recv == cmd_r1) begin
                spi_wr_req <= 1'b0;
                if (cmd_data_len != 16'd0) begin
                  state <= S_CMD_DATA;
                  byte_cnt <= 16'd0;
                end else begin
                  state <= S_END;
                  byte_cnt <= 16'd0;
                end
              end else begin
                byte_cnt <= byte_cnt + 16'd1;
              end
            end
          end else begin
            spi_wr_req <= 1'b1;
            CS_reg <= 1'b0;
            if (byte_cnt == 16'd0) begin
              send_data <= (cmd[47:40] | 8'h40);
            end else begin
              if (byte_cnt == 16'd1) begin
                send_data <= cmd[39:32];
              end else begin
                if (byte_cnt == 16'd2) begin
                  send_data <= cmd[31:24];
                end else begin
                  if (byte_cnt == 16'd3) begin
                    send_data <= cmd[23:16];
                  end else begin
                    if (byte_cnt == 16'd4) begin
                      send_data <= cmd[15:8];
                    end else begin
                      if (byte_cnt == 16'd5) begin
                        send_data <= cmd[7:0];
                      end else begin
                        send_data <= 8'hff;
                      end
                    end
                  end
                end
              end
            end
          end
        end
        S_CMD_DATA: begin
          if (spi_wr_ack == 1'b1) begin
            if (byte_cnt == cmd_data_len - 16'd1) begin
              state <= S_END;
              spi_wr_req <= 1'b0;
              byte_cnt <= 16'd0;
            end else begin
              byte_cnt <= byte_cnt + 16'd1;
            end
          end else begin
            spi_wr_req <= 1'b1;
            send_data  <= 8'hff;
          end
        end
        S_READ_WAIT: begin
          if (spi_wr_ack == 1'b1 && data_recv == 8'hfe) begin
            spi_wr_req <= 1'b0;
            state <= S_READ;
            byte_cnt <= 16'd0;
          end else begin
            spi_wr_req <= 1'b1;
            send_data  <= 8'hff;
          end
        end
        S_READ: begin
          if (spi_wr_ack == 1'b1) begin
            if (byte_cnt == 16'd513) begin
              state <= S_READ_ACK;
              spi_wr_req <= 1'b0;
              byte_cnt <= 16'd0;
            end else begin
              byte_cnt <= byte_cnt + 16'd1;
            end
          end else begin
            spi_wr_req <= 1'b1;
            send_data  <= 8'hff;
          end
        end
        S_WRITE_TOKEN: begin
          if (spi_wr_ack == 1'b1) begin
            state <= S_WRITE_DATA_0;
            spi_wr_req <= 1'b0;
            byte_cnt <= 16'd0;
          end else begin
            spi_wr_req <= 1'b1;
            send_data  <= 8'hfe;
          end
        end
        S_WRITE_DATA_0: begin
          state <= S_WRITE_DATA_1;
          wr_data_cnt <= wr_data_cnt + 10'd1;
        end
        S_WRITE_DATA_1: begin
          if (spi_wr_ack == 1'b1 && wr_data_cnt == 10'd512) begin
            state <= S_WRITE_CRC;
            spi_wr_req <= 1'b0;
          end else begin
            if (spi_wr_ack == 1'b1) begin
              state <= S_WRITE_DATA_0;
              spi_wr_req <= 1'b0;
            end else begin
              spi_wr_req <= 1'b1;
              send_data  <= block_write_data;
            end
          end
        end
        S_WRITE_CRC: begin
          if (spi_wr_ack == 1'b1) begin
            if (byte_cnt == 16'd1) begin
              state <= S_WRITE_SUC;
              spi_wr_req <= 1'b0;
              byte_cnt <= 16'd0;
            end else begin
              byte_cnt <= byte_cnt + 16'd1;
            end
          end else begin
            spi_wr_req <= 1'b1;
            send_data  <= 8'hff;
          end
        end
        S_WRITE_SUC: begin
          if (spi_wr_ack == 1'b1) begin
            if (data_recv[4:0] == 5'b00101) begin
              state <= S_WRITE_BUSY;
              spi_wr_req <= 1'b0;
            end
          end else begin
            spi_wr_req <= 1'b1;
            send_data  <= 8'hff;
          end
        end
        S_WRITE_BUSY: begin
          if (spi_wr_ack == 1'b1) begin
            if (data_recv == 8'hff) begin
              state <= S_WRITE_ACK;
              spi_wr_req <= 1'b0;
            end
          end else begin
            spi_wr_req <= 1'b1;
            send_data  <= 8'hff;
          end
        end
        S_ERR: begin
          state <= S_END;
          cmd_req_error <= 1'b1;
        end
        S_READ_ACK, S_WRITE_ACK, S_END: begin
          state <= S_WAIT;
        end
        default: begin
          state <= S_IDLE;
        end
      endcase
    end
  end
  always @(posedge sys_clk) begin
    if (rst == 1'b1) begin
      block_read_valid <= 1'b0;
    end else begin
      if (state == S_READ && byte_cnt < 16'd512) begin
        block_read_valid <= spi_wr_ack;
      end else begin
        block_read_valid <= 1'b0;
      end
    end
  end
  always @(posedge sys_clk) begin
    if (rst == 1'b1) begin
      block_read_data <= 8'd0;
    end else begin
      if (state == S_READ && spi_wr_ack == 1'b1) begin
        block_read_data <= data_recv;
      end
    end
  end
endmodule
