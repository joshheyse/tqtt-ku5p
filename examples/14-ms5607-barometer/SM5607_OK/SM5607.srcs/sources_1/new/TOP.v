`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/12/09 18:28:49
// Design Name:
// Module Name: TOP
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module TOP (
  input        clk,
  input        rx_uart,
  output       tx_uart,
  input  [3:0] key,
  output [3:0] led
);
  assign tx_uart = rx_uart;
  assign led = key;
endmodule
