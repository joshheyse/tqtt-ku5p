`timescale 1ns / 1ps
module fan_pwm #(
  parameter integer FRQ            = 50 * 1000 * 1000,
  parameter integer DIV_PER_SECOND = 1
) (
  input  CLK_50M,
  output FAN_PWM,
  output LED0,
  LED1,
  LED2,
  LED3,
  LED4,
  LED5,
  LED6,
  LED7,
  input  FAN_FB
);
  localparam logic [20:0] PREDIV = 21'(FRQ / (25_000 * 100));
  reg  [ 6:0] pwm_value;
  reg  [20:0] delay_cntr;
  reg  [ 6:0] pwm_count;
  reg         pwm_reg;
  reg  [31:0] edge_count;
  wire        edge_count_overflow = edge_count >= (FRQ / (1000 * 1000));
  reg  [31:0] interval_count;
  reg  [15:0] fan_count;
  reg  [ 3:0] fan_feedback;
  reg         fan_feedback_change;
  wire        interval_count_overflow = interval_count >= (FRQ / DIV_PER_SECOND);
  reg  [15:0] fan_count_result;

  assign FAN_PWM = pwm_reg;
  assign {LED7, LED6, LED5, LED4, LED3, LED2, LED1, LED0} =
    (fan_count_result[15:8] != 0) ? 8'hff : fan_count_result[7:0];

  always @(posedge CLK_50M) begin
    if (7'd80 >= 7'd99) begin
      pwm_value <= 7'd99;
    end else begin
      if (7'd80 < 7'd1) begin
        pwm_value <= 7'd1;
      end else begin
        pwm_value <= 7'd80;
      end
    end
  end

  always @(posedge CLK_50M) begin
    delay_cntr <= (delay_cntr == (PREDIV - 21'd1)) ? 21'd0 : (delay_cntr + 21'd1);
  end

  always @(posedge CLK_50M) begin
    if (delay_cntr == 0) begin
      pwm_count <= (pwm_count >= 7'd99) ? 7'd0 : (pwm_count + 7'd1);
    end
  end

  always @(posedge CLK_50M) begin
    if (pwm_count == 0) begin
      pwm_reg <= 1'b0;
    end else begin
      if (pwm_count == pwm_value) begin
        pwm_reg <= 1'b1;
      end
    end
  end

  always @(posedge CLK_50M) begin
    fan_feedback[1:0] <= {fan_feedback[0], FAN_FB};
    if (edge_count_overflow) begin
      fan_feedback[2] <= fan_feedback[1];
    end
    fan_feedback[3] <= fan_feedback[2];
    fan_feedback_change <= {fan_feedback[2], fan_feedback[3]} == 2'b10;
  end

  always @(posedge CLK_50M) begin
    if (edge_count_overflow) begin
      edge_count <= 32'd0;
    end else begin
      edge_count <= edge_count + 32'd1;
    end
  end

  always @(posedge CLK_50M) begin
    if (interval_count_overflow) begin
      interval_count <= 32'd0;
    end else begin
      interval_count <= interval_count + 32'd1;
    end
    if (interval_count_overflow) begin
      fan_count <= 16'd0;
    end else begin
      if (fan_feedback_change) begin
        fan_count <= fan_count + 16'd1;
      end
    end
    if (interval_count_overflow) begin
      fan_count_result <= fan_count;
    end
  end

  ila_1_1_1_16 your_instance_name (
    .clk(CLK_50M),
    .probe0(FAN_FB),
    .probe1(fan_feedback_change),
    .probe2(interval_count_overflow),
    .probe3(fan_count_result)
  );
endmodule
