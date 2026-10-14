module led_shift #(
  parameter integer CNT_MAX = 49_999_999
) (
  input            clk,
  output reg [7:0] led
);
  reg  [31:0] cntr;
  reg  [ 2:0] sec_cntr;
  wire        cntr_end = cntr == CNT_MAX;
  always @(posedge clk) begin
    cntr <= (cntr_end) ? 0 : (cntr + 1);
    if (cntr_end) begin
      sec_cntr <= sec_cntr + 1;
    end
  end
  always @(posedge clk) begin
    led <= 1 << sec_cntr;
  end
endmodule
