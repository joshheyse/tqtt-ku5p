`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/11/25 10:41:57
// Design Name:
// Module Name: ds18b20_ctrl
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
module ds18b20_ctrl (
  input  CLK_50M,
  inout  DS18B20_IO,
  output LED0,
  LED1,
  LED2,
  LED3,
  LED4,
  LED5,
  LED6,
  LED7
);
  wire [15:0] led;
  assign {LED7, LED6, LED5, LED4, LED3, LED2, LED1, LED0} = led[4+7:4];
  ds18b20_drive u1 (
    .clk(CLK_50M),
    .rst_n(1),
    .one_wire(DS18B20_IO),
    .temperature(led)
  );
endmodule
