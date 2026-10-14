`timescale 1ns / 1ps
module ds18b20_drive (
  input         clk,
  input         rst_n,
  inout         one_wire,
  output [15:0] temperature
);
  reg [5:0] cnt;
  always @(posedge clk) begin
    if (!rst_n) begin
      cnt <= 0;
    end else begin
      if (cnt == 49) begin
        cnt <= 0;
      end else begin
        cnt <= cnt + 1'b1;
      end
    end
  end
  reg clk_1us;
  always @(posedge clk) begin
    if (!rst_n) begin
      clk_1us <= 0;
    end else begin
      if (cnt <= 24) begin
        clk_1us <= 0;
      end else begin
        clk_1us <= 1;
      end
    end
  end
  reg [19:0] cnt_1us;
  reg        cnt_1us_clear;
  always @(posedge clk) begin
    if (cnt == 49) begin
      if (cnt_1us_clear) begin
        cnt_1us <= 0;
      end else begin
        cnt_1us <= cnt_1us + 1'b1;
      end
    end
  end
  parameter logic [4:0] S00 = 5'h00;
  parameter logic [4:0] S0 = 5'h01;
  parameter logic [4:0] S1 = 5'h03;
  parameter logic [4:0] S2 = 5'h02;
  parameter logic [4:0] S3 = 5'h06;
  parameter logic [4:0] S4 = 5'h07;
  parameter logic [4:0] S5 = 5'h05;
  parameter logic [4:0] S6 = 5'h04;
  parameter logic [4:0] S7 = 5'h0C;
  parameter logic [4:0] WRITE0 = 5'h0D;
  parameter logic [4:0] WRITE1 = 5'h0F;
  parameter logic [4:0] WRITE00 = 5'h0E;
  parameter logic [4:0] WRITE01 = 5'h0A;
  parameter logic [4:0] READ0 = 5'h0B;
  parameter logic [4:0] READ1 = 5'h09;
  parameter logic [4:0] READ2 = 5'h08;
  parameter logic [4:0] READ3 = 5'h18;
  reg [ 4:0] state;
  reg        one_wire_buf;
  reg [15:0] temperature_buf;
  reg [ 5:0] step;
  reg [ 3:0] bit_valid;
  always @(posedge clk) begin
    if (cnt == 49) begin
      if (!rst_n) begin
        one_wire_buf <= 1'bZ;
        step         <= 0;
        state        <= S00;
      end else begin
        case (state)
          S00: begin
            temperature_buf <= 16'h001F;
            state           <= S0;
          end
          S0: begin
            cnt_1us_clear <= 1;
            one_wire_buf  <= 0;
            state         <= S1;
          end
          S1: begin
            cnt_1us_clear <= 0;
            if (cnt_1us == 500) begin
              cnt_1us_clear <= 1;
              one_wire_buf  <= 1'bZ;
              state         <= S2;
            end
          end
          S2: begin
            cnt_1us_clear <= 0;
            if (cnt_1us == 100) begin
              cnt_1us_clear <= 1;
              state         <= S3;
            end
          end
          S3: begin
            if (~one_wire) begin
              state <= S4;
            end else begin
              if (one_wire) begin
                state <= S0;
              end
            end
          end
          S4: begin
            cnt_1us_clear <= 0;
            if (cnt_1us == 400) begin
              cnt_1us_clear <= 1;
              state         <= S5;
            end
          end
          S5: begin
            if (step == 0) begin
              step  <= step + 1'b1;
              state <= WRITE0;
            end else begin
              if (step == 1) begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end else begin
                if (step == 2) begin
                  one_wire_buf <= 0;
                  step         <= step + 1'b1;
                  state        <= WRITE01;
                end else begin
                  if (step == 3) begin
                    one_wire_buf <= 0;
                    step         <= step + 1'b1;
                    state        <= WRITE01;
                  end else begin
                    if (step == 4) begin
                      step  <= step + 1'b1;
                      state <= WRITE0;
                    end else begin
                      if (step == 5) begin
                        step  <= step + 1'b1;
                        state <= WRITE0;
                      end else begin
                        if (step == 6) begin
                          one_wire_buf <= 0;
                          step         <= step + 1'b1;
                          state        <= WRITE01;
                        end else begin
                          if (step == 7) begin
                            one_wire_buf <= 0;
                            step         <= step + 1'b1;
                            state        <= WRITE01;
                          end else begin
                            if (step == 8) begin
                              step  <= step + 1'b1;
                              state <= WRITE0;
                            end else begin
                              if (step == 9) begin
                                step  <= step + 1'b1;
                                state <= WRITE0;
                              end else begin
                                if (step == 10) begin
                                  one_wire_buf <= 0;
                                  step         <= step + 1'b1;
                                  state        <= WRITE01;
                                end else begin
                                  if (step == 11) begin
                                    step  <= step + 1'b1;
                                    state <= WRITE0;
                                  end else begin
                                    if (step == 12) begin
                                      step  <= step + 1'b1;
                                      state <= WRITE0;
                                    end else begin
                                      if (step == 13) begin
                                        step  <= step + 1'b1;
                                        state <= WRITE0;
                                      end else begin
                                        if (step == 14) begin
                                          one_wire_buf <= 0;
                                          step         <= step + 1'b1;
                                          state        <= WRITE01;
                                        end else begin
                                          if (step == 15) begin
                                            step  <= step + 1'b1;
                                            state <= WRITE0;
                                          end else begin
                                            if (step == 16) begin
                                              one_wire_buf <= 1'bZ;
                                              step         <= step + 1'b1;
                                              state        <= S6;
                                            end else begin
                                              if (step == 17) begin
                                                step  <= step + 1'b1;
                                                state <= WRITE0;
                                              end else begin
                                                if (step == 18) begin
                                                  step  <= step + 1'b1;
                                                  state <= WRITE0;
                                                end else begin
                                                  if (step == 19) begin
                                                    one_wire_buf <= 0;
                                                    step         <= step + 1'b1;
                                                    state        <= WRITE01;
                                                  end else begin
                                                    if (step == 20) begin
                                                      step <= step + 1'b1;
                                                      state <= WRITE01;
                                                      one_wire_buf <= 0;
                                                    end else begin
                                                      if (step == 21) begin
                                                        step  <= step + 1'b1;
                                                        state <= WRITE0;
                                                      end else begin
                                                        if (step == 22) begin
                                                          step  <= step + 1'b1;
                                                          state <= WRITE0;
                                                        end else begin
                                                          if (step == 23) begin
                                                            one_wire_buf <= 0;
                                                            step         <= step + 1'b1;
                                                            state        <= WRITE01;
                                                          end else begin
                                                            if (step == 24) begin
                                                              one_wire_buf <= 0;
                                                              step         <= step + 1'b1;
                                                              state        <= WRITE01;
                                                            end else begin
                                                              if (step == 25)      // 0xBE
              begin
                                                                step  <= step + 1'b1;
                                                                state <= WRITE0;
                                                              end else begin
                                                                if (step == 26) begin
                                                                  one_wire_buf <= 0;
                                                                  step         <= step + 1'b1;
                                                                  state        <= WRITE01;
                                                                end else begin
                                                                  if (step == 27) begin
                                                                    one_wire_buf <= 0;
                                                                    step         <= step + 1'b1;
                                                                    state        <= WRITE01;
                                                                  end else begin
                                                                    if (step == 28) begin
                                                                      one_wire_buf <= 0;
                                                                      step         <= step + 1'b1;
                                                                      state        <= WRITE01;
                                                                    end else begin
                                                                      if (step == 29) begin
                                                                        one_wire_buf <= 0;
                                                                        step         <= step + 1'b1;
                                                                        state        <= WRITE01;
                                                                      end else begin
                                                                        if (step == 30) begin
                                                                          one_wire_buf <= 0;
                                                                          step <= step + 1'b1;
                                                                          state <= WRITE01;
                                                                        end else begin
                                                                          if (step == 31) begin
                                                                            step  <= step + 1'b1;
                                                                            state <= WRITE0;
                                                                          end else begin
                                                                            if (step == 32) begin
                                                                              one_wire_buf <= 0;
                                                                              step <= step + 1'b1;
                                                                              state <= WRITE01;
                                                                            end else begin
                                                                              if (step == 33) begin
                                                                                step <= step + 1'b1;
                                                                                state <= S7;
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          S6: begin
            cnt_1us_clear <= 0;
            if (cnt_1us == 750000 | one_wire) begin
              cnt_1us_clear <= 1;
              state         <= S0;
            end
          end
          S7: begin
            if (step == 34) begin
              bit_valid    <= 0;
              one_wire_buf <= 0;
              step         <= step + 1'b1;
              state        <= READ0;
            end else begin
              if (step == 35) begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end else begin
                if (step == 36) begin
                  bit_valid    <= bit_valid + 1'b1;
                  one_wire_buf <= 0;
                  step         <= step + 1'b1;
                  state        <= READ0;
                end else begin
                  if (step == 37) begin
                    bit_valid    <= bit_valid + 1'b1;
                    one_wire_buf <= 0;
                    step         <= step + 1'b1;
                    state        <= READ0;
                  end else begin
                    if (step == 38) begin
                      bit_valid    <= bit_valid + 1'b1;
                      one_wire_buf <= 0;
                      step         <= step + 1'b1;
                      state        <= READ0;
                    end else begin
                      if (step == 39) begin
                        bit_valid    <= bit_valid + 1'b1;
                        one_wire_buf <= 0;
                        step         <= step + 1'b1;
                        state        <= READ0;
                      end else begin
                        if (step == 40) begin
                          bit_valid    <= bit_valid + 1'b1;
                          one_wire_buf <= 0;
                          step         <= step + 1'b1;
                          state        <= READ0;
                        end else begin
                          if (step == 41) begin
                            bit_valid    <= bit_valid + 1'b1;
                            one_wire_buf <= 0;
                            step         <= step + 1'b1;
                            state        <= READ0;
                          end else begin
                            if (step == 42) begin
                              bit_valid    <= bit_valid + 1'b1;
                              one_wire_buf <= 0;
                              step         <= step + 1'b1;
                              state        <= READ0;
                            end else begin
                              if (step == 43) begin
                                bit_valid    <= bit_valid + 1'b1;
                                one_wire_buf <= 0;
                                step         <= step + 1'b1;
                                state        <= READ0;
                              end else begin
                                if (step == 44) begin
                                  bit_valid    <= bit_valid + 1'b1;
                                  one_wire_buf <= 0;
                                  step         <= step + 1'b1;
                                  state        <= READ0;
                                end else begin
                                  if (step == 45) begin
                                    bit_valid    <= bit_valid + 1'b1;
                                    one_wire_buf <= 0;
                                    step         <= step + 1'b1;
                                    state        <= READ0;
                                  end else begin
                                    if (step == 46) begin
                                      bit_valid    <= bit_valid + 1'b1;
                                      one_wire_buf <= 0;
                                      step         <= step + 1'b1;
                                      state        <= READ0;
                                    end else begin
                                      if (step == 47) begin
                                        bit_valid    <= bit_valid + 1'b1;
                                        one_wire_buf <= 0;
                                        step         <= step + 1'b1;
                                        state        <= READ0;
                                      end else begin
                                        if (step == 48) begin
                                          bit_valid    <= bit_valid + 1'b1;
                                          one_wire_buf <= 0;
                                          step         <= step + 1'b1;
                                          state        <= READ0;
                                        end else begin
                                          if (step == 49) begin
                                            bit_valid    <= bit_valid + 1'b1;
                                            one_wire_buf <= 0;
                                            step         <= step + 1'b1;
                                            state        <= READ0;
                                          end else begin
                                            if (step == 50) begin
                                              step  <= 0;
                                              state <= S0;
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          WRITE0: begin
            cnt_1us_clear <= 0;
            one_wire_buf  <= 0;
            if (cnt_1us == 80) begin
              cnt_1us_clear <= 1;
              one_wire_buf  <= 1'bZ;
              state         <= WRITE00;
            end
          end
          WRITE00: begin
            state <= S5;
          end
          WRITE01: begin
            state <= WRITE1;
          end
          WRITE1: begin
            cnt_1us_clear <= 0;
            one_wire_buf  <= 1'bZ;
            if (cnt_1us == 80) begin
              cnt_1us_clear <= 1;
              state         <= S5;
            end
          end
          READ0: begin
            state <= READ1;
          end
          READ1: begin
            cnt_1us_clear <= 0;
            one_wire_buf  <= 1'bZ;
            if (cnt_1us == 10) begin
              cnt_1us_clear <= 1;
              state         <= READ2;
            end
          end
          READ2: begin
            temperature_buf[bit_valid] <= one_wire;
            state                      <= READ3;
          end
          READ3: begin
            cnt_1us_clear <= 0;
            if (cnt_1us == 55) begin
              cnt_1us_clear <= 1;
              state         <= S7;
            end
          end
          default: begin
            state <= S00;
          end
        endcase
      end
    end
  end
  assign one_wire = one_wire_buf;
  wire [15:0] t_buf = temperature_buf & 16'h07FF;
  assign temperature[3:0]   = (t_buf[3:0] * 10) >> 4;
  assign temperature[7:4]   = (t_buf[7:4] >= 10) ? (t_buf[7:4] - 10) : t_buf[7:4];
  assign temperature[11:8]  = (t_buf[7:4] >= 10) ? (t_buf[11:8] + 1) : t_buf[11:8];
  assign temperature[15:12] = temperature_buf[12] ? 1 : 0;
  ila_1_16_16 your_instance_name (
    .clk(clk),
    .probe0(one_wire),
    .probe1(t_buf),
    .probe2(temperature)
  );
endmodule
`timescale 1ns / 1ps
