
`timescale 1 ns / 1 ps

module uart2master #(
  parameter         C_M00_AXI_START_DATA_VALUE       = 32'hAA000000,
  parameter         C_M00_AXI_TARGET_SLAVE_BASE_ADDR = 32'h40000000,
  parameter integer C_M00_AXI_ADDR_WIDTH             = 32,
  parameter integer C_M00_AXI_DATA_WIDTH             = 32,
  parameter integer C_M00_AXI_TRANSACTIONS_NUM       = 4
) (
  input                                      rxd,
  output                                     txd,
  output                                     RxD_data_ready,
  output      [                         7:0] RxD_data,
  st,
  input  wire                                m00_axi_aclk,
  input  wire                                m00_axi_aresetn,
  output wire [  C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
  output wire [                       2 : 0] m00_axi_awprot,
  output wire                                m00_axi_awvalid,
  input  wire                                m00_axi_awready,
  output wire [  C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
  output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
  output wire                                m00_axi_wvalid,
  input  wire                                m00_axi_wready,
  input  wire [                       1 : 0] m00_axi_bresp,
  input  wire                                m00_axi_bvalid,
  output wire                                m00_axi_bready,
  output wire [  C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
  output wire [                       2 : 0] m00_axi_arprot,
  output wire                                m00_axi_arvalid,
  input  wire                                m00_axi_arready,
  input  wire [  C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
  input  wire [                       1 : 0] m00_axi_rresp,
  input  wire                                m00_axi_rvalid,
  output wire                                m00_axi_rready
);
  uart2master_master_lite_v1_0_M00_AXI #(
    .C_M_START_DATA_VALUE(C_M00_AXI_START_DATA_VALUE),
    .C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
    .C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
    .C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
    .C_M_TRANSACTIONS_NUM(C_M00_AXI_TRANSACTIONS_NUM)
  ) uart2master_master_lite_v1_0_M00_AXI_inst (
    .INIT_AXI_TXN(0),
    .ERROR(m00_axi_error),
    .TXN_DONE(m00_axi_txn_done),
    .M_AXI_ACLK(m00_axi_aclk),
    .M_AXI_ARESETN(m00_axi_aresetn),
    .M_AXI_AWADDR(m00_axi_awaddr),
    .M_AXI_AWPROT(m00_axi_awprot),
    .M_AXI_AWVALID(m00_axi_awvalid),
    .M_AXI_AWREADY(m00_axi_awready),
    .M_AXI_WDATA(m00_axi_wdata),
    .M_AXI_WSTRB(m00_axi_wstrb),
    .M_AXI_WVALID(m00_axi_wvalid),
    .M_AXI_WREADY(m00_axi_wready),
    .M_AXI_BRESP(m00_axi_bresp),
    .M_AXI_BVALID(m00_axi_bvalid),
    .M_AXI_BREADY(m00_axi_bready),
    .M_AXI_ARADDR(m00_axi_araddr),
    .M_AXI_ARPROT(m00_axi_arprot),
    .M_AXI_ARVALID(m00_axi_arvalid),
    .M_AXI_ARREADY(m00_axi_arready),
    .M_AXI_RDATA(m00_axi_rdata),
    .M_AXI_RRESP(m00_axi_rresp),
    .M_AXI_RVALID(m00_axi_rvalid),
    .M_AXI_RREADY(m00_axi_rready),
    .RxD_data_ready(RxD_data_ready),
    .RxD_data(RxD_data),
    .st(st),
    .txd(txd),
    .rxd(rxd)
  );

endmodule

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
// RS-232 RX and TX module
// (c) fpga4fun.com & KNJN LLC - 2003 to 2016

// The RS-232 settings are fixed
// TX: 8-bit data, 2 stop, no-parity
// RX: 8-bit data, 1 stop, no-parity (the receiver can accept more stop bits of course)

////////////////////////////////////////////////////////
module async_transmitter (
  input        clk,
  input        TxD_start,
  input  [7:0] TxD_data,
  output       TxD,
  output       TxD_busy
);

  // Assert TxD_start for (at least) one clock cycle to start transmission of TxD_data
  // TxD_data is latched so that it doesn't have to stay valid while it is being sent

  parameter integer ClkFrequency = 1000 * 1000 * 100;  // 100MHz
  parameter integer Baud = 115200;

  generate
    if (ClkFrequency < Baud * 8 && (ClkFrequency % Baud != 0))
      ASSERTION_ERROR PARAMETER_OUT_OF_RANGE ("Frequency incompatible with requested Baud rate");
  endgenerate

  ////////////////////////////////
`ifdef SIMULATION
  wire BitTick = 1'b1;
`else
  wire BitTick;
  BaudTickGen #(
    .ClkFrequency(ClkFrequency),
    .Baud(Baud)
  ) tickgen (
    .clk(clk),
    .enable(TxD_busy),
    .tick(BitTick)
  );
`endif

  reg  [3:0] TxD_state = 0;
  wire       TxD_ready = (TxD_state == 0);
  assign TxD_busy = ~TxD_ready;

  reg [7:0] TxD_shift = 0;
  always @(posedge clk) begin
    if (TxD_ready & TxD_start) begin
      TxD_shift <= TxD_data;
    end else begin
      if (TxD_state[3] & BitTick) begin
        TxD_shift <= (TxD_shift >> 1);
      end
    end

    case (TxD_state)
      4'b0000: begin
        if (TxD_start) begin
          TxD_state <= 4'b0100;
        end
      end
      4'b0100: begin
        if (BitTick) begin
          TxD_state <= 4'b1000;
        end
      end  // start bit
      4'b1000: begin
        if (BitTick) begin
          TxD_state <= 4'b1001;
        end
      end  // bit 0
      4'b1001: begin
        if (BitTick) begin
          TxD_state <= 4'b1010;
        end
      end  // bit 1
      4'b1010: begin
        if (BitTick) begin
          TxD_state <= 4'b1011;
        end
      end  // bit 2
      4'b1011: begin
        if (BitTick) begin
          TxD_state <= 4'b1100;
        end
      end  // bit 3
      4'b1100: begin
        if (BitTick) begin
          TxD_state <= 4'b1101;
        end
      end  // bit 4
      4'b1101: begin
        if (BitTick) begin
          TxD_state <= 4'b1110;
        end
      end  // bit 5
      4'b1110: begin
        if (BitTick) begin
          TxD_state <= 4'b1111;
        end
      end  // bit 6
      4'b1111: begin
        if (BitTick) begin
          TxD_state <= 4'b0010;
        end
      end  // bit 7
      4'b0010: begin
        if (BitTick) begin
          TxD_state <= 4'b0011;
        end
      end  // stop1
      4'b0011: begin
        if (BitTick) begin
          TxD_state <= 4'b0000;
        end
      end  // stop2
      default: begin
        if (BitTick) begin
          TxD_state <= 4'b0000;
        end
      end
    endcase
  end

  assign TxD = (TxD_state < 4) | (TxD_state[3] & TxD_shift[0]);
endmodule


////////////////////////////////////////////////////////
module async_receiver (
  input            clk,
  input            RxD,
  output reg       RxD_data_ready = 0,
  // Data received. It is valid for one clock cycle when RxD_data_ready is asserted.
  output reg [7:0] RxD_data = 0,

  // We also detect if a gap occurs in the received stream of characters
  // That can be useful if multiple characters are sent in burst
  //  so that multiple characters can be treated as a "packet"
  output     RxD_idle,
  output reg RxD_endofpacket = 0
);

  parameter integer ClkFrequency = 1000 * 1000 * 100;
  parameter integer Baud = 115200;

  parameter integer Oversampling = 8;

  generate
    if (ClkFrequency < Baud * Oversampling)
      ASSERTION_ERROR PARAMETER_OUT_OF_RANGE (
        "Frequency too low for current Baud rate and oversampling"
      );
    if (Oversampling < 8 || ((Oversampling & (Oversampling - 1)) != 0))
      ASSERTION_ERROR PARAMETER_OUT_OF_RANGE ("Invalid oversampling value");
  endgenerate

  ////////////////////////////////
  reg [3:0] RxD_state = 0;

`ifdef SIMULATION
  wire RxD_bit = RxD;
  wire sampleNow = 1'b1;

`else
  wire OversamplingTick;
  BaudTickGen #(
    .ClkFrequency(ClkFrequency),
    .Baud(Baud),
    .Oversampling(Oversampling)
  ) tickgen (
    .clk(clk),
    .enable(1'b1),
    .tick(OversamplingTick)
  );

  reg [1:0] RxD_sync = 2'b11;
  always @(posedge clk) begin
    if (OversamplingTick) begin
      RxD_sync <= {RxD_sync[0], RxD};
    end
  end

  reg [1:0] Filter_cnt = 2'b11;
  reg       RxD_bit = 1'b1;

  always @(posedge clk) begin
    if (OversamplingTick) begin
      if (RxD_sync[1] == 1'b1 && Filter_cnt != 2'b11) begin
        Filter_cnt <= Filter_cnt + 1'd1;
      end else begin
        if (RxD_sync[1] == 1'b0 && Filter_cnt != 2'b00) begin
          Filter_cnt <= Filter_cnt - 1'd1;
        end
      end

      if (Filter_cnt == 2'b11) begin
        RxD_bit <= 1'b1;
      end else begin
        if (Filter_cnt == 2'b00) begin
          RxD_bit <= 1'b0;
        end
      end
    end
  end

  function automatic integer log2(input integer v);
    begin
      log2 = 0;
      while (v >> log2) begin
        log2 = log2 + 1;
      end
    end
  endfunction
  localparam integer L2O = log2(Oversampling);
  reg [L2O-2:0] OversamplingCnt = 0;
  always @(posedge clk) begin
    if (OversamplingTick) begin
      OversamplingCnt <= (RxD_state == 0) ? 1'd0 : OversamplingCnt + 1'd1;
    end
  end
  wire sampleNow = OversamplingTick && (OversamplingCnt == Oversampling / 2 - 1);
`endif

  always @(posedge clk) begin
    case (RxD_state)
      4'b0000: begin
        if (~RxD_bit) begin
`ifdef SIMULATION
          RxD_state <= 4'b1000;
`else
          RxD_state <= 4'b0001;
`endif
        end
      end
      4'b0001: begin
        if (sampleNow) begin
          RxD_state <= 4'b1000;
        end
      end
      4'b1000: begin
        if (sampleNow) begin
          RxD_state <= 4'b1001;
        end
      end
      4'b1001: begin
        if (sampleNow) begin
          RxD_state <= 4'b1010;
        end
      end
      4'b1010: begin
        if (sampleNow) begin
          RxD_state <= 4'b1011;
        end
      end
      4'b1011: begin
        if (sampleNow) begin
          RxD_state <= 4'b1100;
        end
      end
      4'b1100: begin
        if (sampleNow) begin
          RxD_state <= 4'b1101;
        end
      end
      4'b1101: begin
        if (sampleNow) begin
          RxD_state <= 4'b1110;
        end
      end
      4'b1110: begin
        if (sampleNow) begin
          RxD_state <= 4'b1111;
        end
      end
      4'b1111: begin
        if (sampleNow) begin
          RxD_state <= 4'b0010;
        end
      end
      4'b0010: begin
        if (sampleNow) begin
          RxD_state <= 4'b0000;
        end
      end
      default: begin
        RxD_state <= 4'b0000;
      end
    endcase
  end

  always @(posedge clk) begin
    if (sampleNow && RxD_state[3]) begin
      RxD_data <= {RxD_bit, RxD_data[7:1]};
    end
  end

  always @(posedge clk) begin
    RxD_data_ready <= sampleNow && RxD_state == 4'b0010 && RxD_bit;
  end

`ifdef SIMULATION
  assign RxD_idle = 0;
`else
  reg [L2O+1:0] GapCnt = 0;
  always @(posedge clk) begin
    if (RxD_state != 0) begin
      GapCnt <= 0;
    end else begin
      if (OversamplingTick & ~GapCnt[log2(Oversampling)+1]) begin
        GapCnt <= GapCnt + 1'h1;
      end
    end
  end
  assign RxD_idle = GapCnt[L2O+1];
  always @(posedge clk) begin
    RxD_endofpacket <= OversamplingTick & ~GapCnt[L2O+1] & &GapCnt[L2O:0];
  end
`endif

endmodule


module ASSERTION_ERROR ();
endmodule


module BaudTickGen (
  input  clk,
  enable,
  output tick
);
  parameter integer ClkFrequency = 25000000;
  parameter integer Baud = 115200;
  parameter integer Oversampling = 1;

  function automatic integer log2(input integer v);
    begin
      log2 = 0;
      while (v >> log2) begin
        log2 = log2 + 1;
      end
    end
  endfunction
  localparam integer AccWidth = log2(ClkFrequency / Baud) + 8;
  reg [AccWidth:0] Acc = 0;
  localparam integer ShiftLimiter = log2(Baud * Oversampling >> (31 - AccWidth));
  localparam integer Inc = (
    (Baud * Oversampling << (AccWidth - ShiftLimiter)) +
    (ClkFrequency >> (ShiftLimiter + 1))
  ) / (ClkFrequency >> ShiftLimiter);
  always @(posedge clk) begin
    if (enable) begin
      Acc <= Acc[AccWidth-1:0] + Inc[AccWidth:0];
    end else begin
      Acc <= Inc[AccWidth:0];
    end
  end
  assign tick = Acc[AccWidth];
endmodule


module uart2bus32 (
  input clk,
  rst,

  input [7:0] uart_in_u8,
  input       uart_in_valid,

  output reg [31:0] uart_out_u8,
  output reg        uart_out_valid,
  input             uart_out_busy,


  output reg  [31:0] addr,
  output reg  [31:0] wr_u32,
  output wire        wr_vaild,
  input              wr_ready,
  wr_err,

  output wire        rd_addr_valid,
  input              rd_done,
  rd_err,
  input       [31:0] rd_u32,
  output reg  [ 7:0] st
);

  reg wr_err_r;
  always @(posedge clk) begin
    if (wr_ready) begin
      wr_err_r <= wr_err;
    end
  end

  function automatic [7:0] chksum_u32;
    input [31:0] u;
    begin
      chksum_u32 = u[31:24] + u[23:16] + u[15:8] + u[7:0];
    end
  endfunction

  reg [ 7:0] addr_chksum;
  reg [ 3:0] c;
  reg [ 7:0] delay;
  reg [31:0] rd_u32_r;
  reg [ 7:0] rd_u32_chksum;
  always @(posedge clk) begin
    addr_chksum <= chksum_u32(addr);
  end
  reg [7:0] wr_u32_chksum;
  always @(posedge clk) begin
    wr_u32_chksum <= chksum_u32(wr_u32) + addr_chksum;
  end

  always @(posedge clk) begin
    case (st)
      44: begin
        delay <= delay + 1;
      end
      default: begin
        delay <= 0;
      end
    endcase
  end
  reg [7:0] cmd;
  always @(posedge clk) begin
    if (st == 12) begin
      cmd <= uart_in_u8;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      st <= 5;
    end else begin
      case (st)
        0: begin
          st <= 5;
        end
        5: begin
          st <= 10;
        end
        10: begin
          if (uart_in_valid) begin
            st <= (uart_in_u8 == 'h55) ? (st + 1) : 10;
          end
        end
        11: begin
          if (uart_in_valid) begin
            st <= (uart_in_u8 == 'haa) ? (st + 1) : 10;
          end
        end
        12: begin
          if (uart_in_valid) begin
            case (uart_in_u8)
              3, 5: begin
                st <= 30;
              end
              default: begin
                st <= 10;
              end
            endcase
          end
        end
        30, 31, 32, 33: begin
          if (uart_in_valid) begin
            st <= st + 1;
          end
        end
        34: begin
          if (cmd == 3) begin
            st <= st + 1;
          end else begin
            st <= 50;
          end
        end
        35: begin
          if (uart_in_valid) begin
            st <= (addr_chksum == uart_in_u8) ? 40 : 10;
          end
        end
        40: begin
          st <= st + 1;
        end  // read function
        41: begin
          if (rd_done) begin
            st <= st + 1;
          end
        end
        42: begin
          if (uart_out_busy == 0) begin
            st <= st + 1;
          end
        end
        43: begin
          st <= st + 1;
        end  // do write
        44: begin
          if (delay == 10) begin
            st <= st + 1;
          end
        end
        45: begin
          st <= st + 1;
        end
        46: begin
          if (c != 5) begin
            st <= 42;
          end else begin
            st <= st + 1;
          end  //c++
        end
        47: begin
          st <= st + 1;
        end
        48: begin
          st <= 10;
        end
        50, 51, 52, 53: begin
          if (uart_in_valid) begin
            st <= st + 1;
          end
        end
        54: begin
          if (uart_in_valid) begin
            st <= (wr_u32_chksum == uart_in_u8) ? 55 : 10;
          end
        end
        55: begin
          st <= st + 1;
        end  // set as valid
        56: begin
          if (wr_ready) begin
            st <= st + 1;
          end
        end
        57: begin
          st <= st + 1;
        end
        58: begin
          if (uart_out_busy == 0) begin
            st <= st + 1;
          end
        end
        59: begin
          st <= 10;
        end
        default: begin
          st <= 0;
        end
      endcase
    end
  end

  assign wr_vaild = st == 55;

  always @(posedge clk) begin
    case (st)
      30: begin
        addr[31:24] <= uart_in_u8;
      end
      31: begin
        addr[23:16] <= uart_in_u8;
      end
      32: begin
        addr[15:8] <= uart_in_u8;
      end
      33: begin
        addr[7:0] <= uart_in_u8;
      end
      default: begin
      end
    endcase
  end

  always @(posedge clk) begin
    case (st)
      50: begin
        wr_u32[31:24] <= uart_in_u8;
      end
      51: begin
        wr_u32[23:16] <= uart_in_u8;
      end
      52: begin
        wr_u32[15:8] <= uart_in_u8;
      end
      53: begin
        wr_u32[7:0] <= uart_in_u8;
      end
      default: begin
      end
    endcase
  end

  assign rd_addr_valid = st == 40;

  always @(posedge clk) begin
    if (rd_done) begin
      rd_u32_r <= rd_u32;
      rd_err_r <= rd_err;
    end
  end

  always @(posedge clk) begin
    rd_u32_chksum <= chksum_u32(rd_u32_r) + {7'b0, rd_err_r};
  end
  always @(posedge clk) begin
    case (st)
      40: begin
        c <= 0;
      end
      46: begin
        c <= c + 1;
      end
      default: begin
        c <= c;
      end
    endcase
  end
  always @(posedge clk) begin
    uart_out_valid <= (st == 43) || (st == 59);
  end

  always @(posedge clk) begin
    if (st == 43) begin
      case (c)
        0: begin
          uart_out_u8 <= rd_u32_r[31:24];
        end
        1: begin
          uart_out_u8 <= rd_u32_r[23:16];
        end
        2: begin
          uart_out_u8 <= rd_u32_r[15:8];
        end
        3: begin
          uart_out_u8 <= rd_u32_r[7:0];
        end
        5: begin
          uart_out_u8 <= rd_u32_chksum;
        end
        4: begin
          uart_out_u8 <= {7'b0, rd_err_r};
        end
        default: begin
        end
      endcase
    end else begin
      if (st == 59) begin
        uart_out_u8 <= {7'b0, wr_err_r};
      end else begin
        uart_out_u8 <= 0;
      end
    end
  end

endmodule



module if_uart2bus32 (
  input  clk,
  rst,
  RxD,
  output TxD,

  output [31:0] addr,
  output [31:0] wr_u32,
  output        wr_vaild,
  input         wr_ready,
  wr_err,

  output        rd_addr_valid,
  input         rd_done,
  rd_err,
  input  [31:0] rd_u32,
  output [ 7:0] st,

  output       RxD_data_ready,
  output [7:0] RxD_data
);
  wire TxD_start, TxD_busy;
  wire [7:0] TxD_data;
  async_transmitter async_transmitter (
    .clk(clk),
    .TxD_start(TxD_start),
    .TxD_data(TxD_data),
    .TxD(TxD),
    .TxD_busy(TxD_busy)
  );

  async_receiver async_receiver (
    .clk(clk),
    .RxD(RxD),
    .RxD_data_ready(RxD_data_ready),
    .RxD_data(RxD_data)
  );

  uart2bus32 uart2bus32 (
    .clk(clk),
    .rst(rst),

    .uart_in_u8(RxD_data),
    .uart_in_valid(RxD_data_ready),

    .uart_out_u8(TxD_data),
    .uart_out_valid(TxD_start),
    .uart_out_busy(TxD_busy),

    .addr(addr),
    .wr_u32(wr_u32),
    .wr_vaild(wr_vaild),
    .wr_ready(wr_ready),
    .wr_err(wr_err),

    .rd_addr_valid(rd_addr_valid),
    .rd_done(rd_done),
    .rd_err(rd_err),
    .rd_u32(rd_u32),
    .st(st)
  );


endmodule








