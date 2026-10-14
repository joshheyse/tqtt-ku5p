module TMDS_encoder (
  input clk,
  input [7:0] VD,  // video data (red, green or blue)
  input [1:0] CD,  // control data
  input VDE,  // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
  output reg [9:0] TMDS = 0
);
  wire [3:0] Nb1s;
  wire       XNOR;
  wire [7:0] q_m_data;
  wire [8:0] q_m;
  assign Nb1s = {3'b000, VD[0]} + {3'b000, VD[1]} + {3'b000, VD[2]} +
                {3'b000, VD[3]} + {3'b000, VD[4]} + {3'b000, VD[5]} +
                {3'b000, VD[6]} + {3'b000, VD[7]};
  assign XNOR = (Nb1s > 4'd4) || (Nb1s == 4'd4 && VD[0] == 1'b0);
  assign q_m_data[0] = VD[0];
  assign q_m_data[1] = q_m_data[0] ^ VD[1] ^ XNOR;
  assign q_m_data[2] = q_m_data[1] ^ VD[2] ^ XNOR;
  assign q_m_data[3] = q_m_data[2] ^ VD[3] ^ XNOR;
  assign q_m_data[4] = q_m_data[3] ^ VD[4] ^ XNOR;
  assign q_m_data[5] = q_m_data[4] ^ VD[5] ^ XNOR;
  assign q_m_data[6] = q_m_data[5] ^ VD[6] ^ XNOR;
  assign q_m_data[7] = q_m_data[6] ^ VD[7] ^ XNOR;
  assign q_m = {~XNOR, q_m_data};
  reg  [3:0] balance_acc = 0;
  wire [3:0] balance;
  wire       balance_sign_eq;
  wire       invert_q_m;
  wire [3:0] balance_acc_inc;
  wire [3:0] balance_acc_new;
  wire [9:0] TMDS_data;
  wire [9:0] TMDS_code;
  assign balance = {3'b000, q_m[0]} + {3'b000, q_m[1]} + {3'b000, q_m[2]} +
                   {3'b000, q_m[3]} + {3'b000, q_m[4]} + {3'b000, q_m[5]} +
                   {3'b000, q_m[6]} + {3'b000, q_m[7]} - 4'd4;
  assign balance_sign_eq = (balance[3] == balance_acc[3]);
  assign invert_q_m = (balance == 0 || balance_acc == 0) ? ~q_m[8] : balance_sign_eq;
  assign balance_acc_inc = balance -
    {3'b000, (q_m[8] ^ ~balance_sign_eq) & !(balance == 0 || balance_acc == 0)};
  assign balance_acc_new = invert_q_m ? balance_acc - balance_acc_inc :
                                        balance_acc + balance_acc_inc;
  assign TMDS_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};
  assign TMDS_code = CD[1] ? (CD[0] ? 10'b1010101011 : 10'b0101010100) :
                             (CD[0] ? 10'b0010101011 : 10'b1101010100);
  always @(posedge clk) begin
    TMDS <= VDE ? TMDS_data : TMDS_code;
    balance_acc <= VDE ? balance_acc_new : 4'h0;
  end
endmodule
////////////////////////////////////////////////////////////////////////
