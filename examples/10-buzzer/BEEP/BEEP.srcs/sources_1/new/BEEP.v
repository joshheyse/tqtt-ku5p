module BEEP #(
  parameter integer TIME_500MS = 24999999,  // 0.5 s count value
  parameter integer DO         = 190839,    // Do tone divider value (262 Hz)
  parameter integer RE         = 170067,    // Re tone divider value (294 Hz)
  parameter integer MI         = 151514,    // Mi tone divider value (330 Hz)
  parameter integer FA         = 143265,    // Fa tone divider value (349 Hz)
  parameter integer SO         = 127550,    // So tone divider value (392 Hz)
  parameter integer LA         = 113635,    // La tone divider value (440 Hz)
  parameter integer XI         = 101214     // Xi tone divider value (494 Hz)
) (
  input  wire sys_clk,  // System clock, 50 MHz
  input  wire sys_rst,  // Active-high system reset
  output reg  beep      // Buzzer control signal
);
  reg  [24:0] cnt;
  reg  [17:0] freq_cnt;
  reg  [ 2:0] cnt_500ms;
  reg  [17:0] freq_data;
  wire [17:0] duty_data;
  assign duty_data = freq_data >> 1'b1;
  always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
      cnt <= 25'd0;
    end else begin
      if (cnt == TIME_500MS[24:0]) begin
        cnt <= 25'd0;
      end else begin
        cnt <= cnt + 25'd1;
      end
    end
  end
  always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
      cnt_500ms <= 3'd0;
    end else begin
      if (cnt == TIME_500MS[24:0] && cnt_500ms == 3'd6) begin
        cnt_500ms <= 3'd0;
      end else begin
        if (cnt == TIME_500MS[24:0]) begin
          cnt_500ms <= cnt_500ms + 3'd1;
        end
      end
    end
  end
  always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
      freq_data <= DO[17:0];
    end else begin
      case (cnt_500ms)
        3'd0: begin
          freq_data <= DO[17:0];
        end
        3'd1: begin
          freq_data <= RE[17:0];
        end
        3'd2: begin
          freq_data <= MI[17:0];
        end
        3'd3: begin
          freq_data <= FA[17:0];
        end
        3'd4: begin
          freq_data <= SO[17:0];
        end
        3'd5: begin
          freq_data <= LA[17:0];
        end
        3'd6: begin
          freq_data <= XI[17:0];
        end
        default: begin
          freq_data <= DO[17:0];
        end
      endcase
    end
  end
  always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
      freq_cnt <= 18'd0;
    end else begin
      if (freq_cnt == freq_data || cnt == TIME_500MS[24:0]) begin
        freq_cnt <= 18'd0;
      end else begin
        freq_cnt <= freq_cnt + 18'd1;
      end
    end
  end
  always @(posedge sys_clk) begin
    if (sys_rst == 1'b1) begin
      beep <= 1'b0;
    end else begin
      if (freq_cnt >= duty_data) begin
        beep <= 1'b1;
      end else begin
        beep <= 1'b0;
      end
    end
  end
endmodule
