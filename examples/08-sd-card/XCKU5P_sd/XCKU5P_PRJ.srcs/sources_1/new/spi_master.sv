`timescale 1ns / 1ns
// Copyright (c) 2017, ALINX (Shanghai) Technology Co., Ltd.
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
module spi_master (
  input         sys_clk,
  input         rst,
  output        nCS,
  output        DCLK,
  output        MOSI,
  input         MISO,
  input         CPOL,
  input         CPHA,
  input         nCS_ctrl,
  input  [15:0] clk_div,
  input         wr_req,
  output        wr_ack,
  input  [ 7:0] data_in,
  output [ 7:0] data_out
);
  localparam logic [2:0] IDLE = 3'd0;
  localparam logic [2:0] DCLKEDGE = 3'd1;
  localparam logic [2:0] DCLKIDLE = 3'd2;
  localparam logic [2:0] ACK = 3'd3;
  localparam logic [2:0] LASTHALFCYCLE = 3'd4;
  localparam logic [2:0] ACKWAIT = 3'd5;
  reg        DCLK_reg;
  reg [ 7:0] MOSI_shift;
  reg [ 7:0] MISO_shift;
  reg [ 2:0] state;
  reg [ 2:0] next_state;
  reg [15:0] clk_cnt;
  reg [ 4:0] clk_edge_cnt;
  assign MOSI = MOSI_shift[7];
  assign DCLK = DCLK_reg;
  assign data_out = MISO_shift;
  assign wr_ack = (state == ACK);
  assign nCS = nCS_ctrl;
  always @(posedge sys_clk) begin
    if (rst) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end
  always_comb begin
    case (state)
      IDLE: begin
        if (wr_req == 1'b1) begin
          next_state = DCLKIDLE;
        end else begin
          next_state = IDLE;
        end
      end
      DCLKIDLE: begin
        if (clk_cnt == clk_div) begin
          next_state = DCLKEDGE;
        end else begin
          next_state = DCLKIDLE;
        end
      end
      DCLKEDGE: begin
        if (clk_edge_cnt == 5'd15) begin
          next_state = LASTHALFCYCLE;
        end else begin
          next_state = DCLKIDLE;
        end
      end
      LASTHALFCYCLE: begin
        if (clk_cnt == clk_div) begin
          next_state = ACK;
        end else begin
          next_state = LASTHALFCYCLE;
        end
      end
      ACK: begin
        next_state = ACKWAIT;
      end
      ACKWAIT: begin
        next_state = IDLE;
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end
  always @(posedge sys_clk) begin
    if (rst) begin
      DCLK_reg <= 1'b0;
    end else begin
      if (state == IDLE) begin
        DCLK_reg <= CPOL;
      end else begin
        if (state == DCLKEDGE) begin
          DCLK_reg <= ~DCLK_reg;
        end
      end
    end
  end
  always @(posedge sys_clk) begin
    if (rst) begin
      clk_cnt <= 16'd0;
    end else begin
      if (state == DCLKIDLE || state == LASTHALFCYCLE) begin
        clk_cnt <= clk_cnt + 16'd1;
      end else begin
        clk_cnt <= 16'd0;
      end
    end
  end
  always @(posedge sys_clk) begin
    if (rst) begin
      clk_edge_cnt <= 5'd0;
    end else begin
      if (state == DCLKEDGE) begin
        clk_edge_cnt <= clk_edge_cnt + 5'd1;
      end else begin
        if (state == IDLE) begin
          clk_edge_cnt <= 5'd0;
        end
      end
    end
  end
  always @(posedge sys_clk) begin
    if (rst) begin
      MOSI_shift <= 8'd0;
    end else begin
      if (state == IDLE && wr_req) begin
        MOSI_shift <= data_in;
      end else begin
        if (state == DCLKEDGE) begin
          if (CPHA == 1'b0 && clk_edge_cnt[0] == 1'b1) begin
            MOSI_shift <= {MOSI_shift[6:0], MOSI_shift[7]};
          end else begin
            if (CPHA == 1'b1 && (clk_edge_cnt != 5'd0 && clk_edge_cnt[0] == 1'b0)) begin
              MOSI_shift <= {MOSI_shift[6:0], MOSI_shift[7]};
            end
          end
        end
      end
    end
  end
  always @(posedge sys_clk) begin
    if (rst) begin
      MISO_shift <= 8'd0;
    end else begin
      if (state == IDLE && wr_req) begin
        MISO_shift <= 8'h00;
      end else begin
        if (state == DCLKEDGE) begin
          if (CPHA == 1'b0 && clk_edge_cnt[0] == 1'b0) begin
            MISO_shift <= {MISO_shift[6:0], MISO};
          end else begin
            if (CPHA == 1'b1 && (clk_edge_cnt[0] == 1'b1)) begin
              MISO_shift <= {MISO_shift[6:0], MISO};
            end
          end
        end
      end
    end
  end
endmodule
