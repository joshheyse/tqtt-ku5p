
`timescale 1 ns / 1 ps

module uart2master_master_lite_v1_0_M00_AXI #(
  parameter         C_M_START_DATA_VALUE       = 32'hAA000000,
  parameter         C_M_TARGET_SLAVE_BASE_ADDR = 32'h40000000,
  parameter integer C_M_AXI_ADDR_WIDTH         = 32,
  parameter integer C_M_AXI_DATA_WIDTH         = 32,
  parameter integer C_M_TRANSACTIONS_NUM       = 4
) (
  input                                    rxd,
  output                                   txd,
  output                                   RxD_data_ready,
  output      [                       7:0] RxD_data,
  input  wire                              INIT_AXI_TXN,
  output reg                               ERROR,
  output wire                              TXN_DONE,
  input  wire                              M_AXI_ACLK,
  input  wire                              M_AXI_ARESETN,
  output wire [  C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
  output wire [                     2 : 0] M_AXI_AWPROT,
  output wire                              M_AXI_AWVALID,
  input  wire                              M_AXI_AWREADY,
  output wire [  C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
  output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
  output wire                              M_AXI_WVALID,
  input  wire                              M_AXI_WREADY,
  input  wire [                     1 : 0] M_AXI_BRESP,
  input  wire                              M_AXI_BVALID,
  output wire                              M_AXI_BREADY,
  output wire [  C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
  output wire [                     2 : 0] M_AXI_ARPROT,
  output wire                              M_AXI_ARVALID,
  input  wire                              M_AXI_ARREADY,
  input  wire [  C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
  input  wire [                     1 : 0] M_AXI_RRESP,
  input  wire                              M_AXI_RVALID,
  output wire                              M_AXI_RREADY,
  output      [                       7:0] st
);

  function automatic integer clogb2(input integer bit_depth);
    begin
      for (clogb2 = 0; bit_depth > 0; clogb2 = clogb2 + 1) bit_depth = bit_depth >> 1;
    end
  endfunction

  localparam integer TransNumBits = clogb2(C_M_TRANSACTIONS_NUM - 1);

  reg  [                     1:0] mst_exec_state;

  reg                             axi_awvalid;
  reg                             axi_wvalid;
  reg                             axi_arvalid;
  reg                             axi_rready;
  reg                             axi_bready;
  reg  [C_M_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
  reg  [C_M_AXI_DATA_WIDTH-1 : 0] axi_wdata;
  reg  [C_M_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
  wire                            write_resp_error;
  wire                            read_resp_error;
  reg                             start_single_write;
  reg                             start_single_read;
  reg                             write_issued;
  reg                             read_issued;
  reg                             writes_done;
  reg                             reads_done;
  reg                             error_reg;
  reg  [        TransNumBits : 0] write_index;
  reg  [        TransNumBits : 0] read_index;
  reg  [C_M_AXI_DATA_WIDTH-1 : 0] expected_rdata;
  reg                             compare_done;
  reg                             read_mismatch;
  reg                             last_write;
  reg                             last_read;
  reg                             init_txn_ff;
  reg                             init_txn_ff2;
  reg                             init_txn_edge;
  wire                            init_txn_pulse;

  wire [                    31:0] addr;
  assign M_AXI_AWADDR  = axi_awaddr;
  assign M_AXI_WDATA   = axi_wdata;
  assign M_AXI_AWPROT  = 3'b000;
  assign M_AXI_AWVALID = axi_awvalid;
  assign M_AXI_WVALID  = axi_wvalid;
  assign M_AXI_WSTRB   = 4'b1111;
  assign M_AXI_BREADY  = axi_bready;
  assign M_AXI_ARADDR  = axi_araddr;
  assign M_AXI_ARVALID = axi_arvalid;
  assign M_AXI_ARPROT  = 3'b001;
  assign M_AXI_RREADY  = axi_rready;
  always @(posedge M_AXI_ACLK) begin
    if (M_AXI_ARESETN == 0) begin
      axi_awvalid <= 1'b0;
      axi_wvalid  <= 1'b0;
      axi_bready  <= 1'b0;
    end else begin
      if (start_single_write) begin
        axi_awvalid <= 1'b1;
      end else begin
        if (M_AXI_AWREADY && axi_awvalid) begin
          axi_awvalid <= 1'b0;
        end
      end
      if (start_single_write) begin
        axi_wvalid <= 1'b1;
      end else begin
        if (M_AXI_WREADY && axi_wvalid) begin
          axi_wvalid <= 1'b0;
        end
      end
      if (M_AXI_BVALID && ~axi_bready) begin
        axi_bready <= 1'b1;
      end else begin
        if (axi_bready) begin
          axi_bready <= 1'b0;
        end else begin
          axi_bready <= axi_bready;
        end
      end
    end
  end


  assign write_resp_error = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);

  always @(posedge M_AXI_ACLK) begin
    if (M_AXI_ARESETN == 0) begin
      axi_arvalid <= 1'b0;
      axi_rready  <= 1'b0;
    end else begin
      if (start_single_read) begin
        axi_arvalid <= 1'b1;
      end else begin
        if (M_AXI_ARREADY && axi_arvalid) begin
          axi_arvalid <= 1'b0;
        end
      end
      if (M_AXI_RVALID && ~axi_rready) begin
        axi_rready <= 1'b1;
      end else begin
        if (axi_rready) begin
          axi_rready <= 1'b0;
        end
      end
    end
  end

  assign read_resp_error = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);

  always @(posedge M_AXI_ACLK) begin
    axi_awaddr <= addr;
    axi_wdata <= wr_u32;
    axi_araddr <= addr;
    start_single_read <= start_single_read_w;
    start_single_write <= start_single_write_w;
  end

  wire [31:0] wr_u32;
  wire start_single_read_w, start_single_write_w;

  if_uart2bus32 if_uart2bus32 (
    .RxD_data_ready(RxD_data_ready),
    .RxD_data(RxD_data),
    .clk(M_AXI_ACLK),
    .rst(~M_AXI_ARESETN),
    .RxD(rxd),
    .TxD(txd),

    .addr(addr),
    .wr_u32(wr_u32),
    .wr_vaild(start_single_write_w),
    .wr_ready(axi_bready & M_AXI_BVALID),
    .wr_err(M_AXI_BRESP[1]),

    .rd_addr_valid(start_single_read_w),
    .rd_done(axi_rready & M_AXI_RVALID),
    .rd_err(M_AXI_RRESP[1]),
    .rd_u32(M_AXI_RDATA),
    .st(st)
  );

endmodule
