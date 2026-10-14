
`timescale 1 ns / 1 ps

module ms5611_man_v1_0_S00_AXI #(
  parameter integer C_S_AXI_DATA_WIDTH = 32,
  parameter integer C_S_AXI_ADDR_WIDTH = 5
) (
  input                                      MS5611_MI,
  output                                     MS5611_MO,
  MS5611_SCK,
  MS5611_CSN,
  input  wire                                S_AXI_ACLK,
  // Global Reset Signal. This Signal is Active LOW
  input  wire                                S_AXI_ARESETN,
  // Write address (issued by master, acceped by Slave)
  input  wire [    C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
  // Write channel Protection type. This signal indicates the
  // privilege and security level of the transaction, and whether
  // the transaction is a data access or an instruction access.
  input  wire [                       2 : 0] S_AXI_AWPROT,
  // Write address valid. This signal indicates that the master signaling
  // valid write address and control information.
  input  wire                                S_AXI_AWVALID,
  // Write address ready. This signal indicates that the slave is ready
  // to accept an address and associated control signals.
  output wire                                S_AXI_AWREADY,
  // Write data (issued by master, acceped by Slave)
  input  wire [    C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
  // Write strobes. This signal indicates which byte lanes hold
  // valid data. There is one write strobe bit for each eight
  // bits of the write data bus.
  input  wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
  // Write valid. This signal indicates that valid write
  // data and strobes are available.
  input  wire                                S_AXI_WVALID,
  // Write ready. This signal indicates that the slave
  // can accept the write data.
  output wire                                S_AXI_WREADY,
  // Write response. This signal indicates the status
  // of the write transaction.
  output wire [                       1 : 0] S_AXI_BRESP,
  // Write response valid. This signal indicates that the channel
  // is signaling a valid write response.
  output wire                                S_AXI_BVALID,
  // Response ready. This signal indicates that the master
  // can accept a write response.
  input  wire                                S_AXI_BREADY,
  // Read address (issued by master, acceped by Slave)
  input  wire [    C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
  // Protection type. This signal indicates the privilege
  // and security level of the transaction, and whether the
  // transaction is a data access or an instruction access.
  input  wire [                       2 : 0] S_AXI_ARPROT,
  // Read address valid. This signal indicates that the channel
  // is signaling valid read address and control information.
  input  wire                                S_AXI_ARVALID,
  // Read address ready. This signal indicates that the slave is
  // ready to accept an address and associated control signals.
  output wire                                S_AXI_ARREADY,
  // Read data (issued by slave)
  output wire [    C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
  // Read response. This signal indicates the status of the
  // read transfer.
  output wire [                       1 : 0] S_AXI_RRESP,
  // Read valid. This signal indicates that the channel is
  // signaling the required read data.
  output wire                                S_AXI_RVALID,
  // Read ready. This signal indicates that the master can
  // accept the read data and response information.
  input  wire                                S_AXI_RREADY
);

  // AXI4LITE signals
  reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
  reg                            axi_awready;
  reg                            axi_wready;
  reg [                   1 : 0] axi_bresp;
  reg                            axi_bvalid;
  reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
  reg                            axi_arready;
  reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
  reg [                   1 : 0] axi_rresp;
  reg                            axi_rvalid;

  // Example-specific design signals
  // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  // AddrLsb is used for addressing 32/64 bit registers/memories
  // AddrLsb = 2 for 32 bits (n downto 2)
  // AddrLsb = 3 for 64 bits (n downto 3)
  localparam integer AddrLsb = (C_S_AXI_DATA_WIDTH / 32) + 1;
  localparam integer OptMemAddrBits = 2;
  //----------------------------------------------
  //-- Signals for user logic register space example
  //------------------------------------------------
  //-- Number of Slave Registers 8
  reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;
  reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg1;
  reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg2;
  reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg3;
  reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg4;
  reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg5;
  reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg6;
  reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg7;
  wire                             slv_reg_rden;
  wire                             slv_reg_wren;
  reg     [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;
  integer                          byte_index;
  reg                              aw_en;

  // I/O Connections assignments

  assign S_AXI_AWREADY = axi_awready;
  assign S_AXI_WREADY  = axi_wready;
  assign S_AXI_BRESP   = axi_bresp;
  assign S_AXI_BVALID  = axi_bvalid;
  assign S_AXI_ARREADY = axi_arready;
  assign S_AXI_RDATA   = axi_rdata;
  assign S_AXI_RRESP   = axi_rresp;
  assign S_AXI_RVALID  = axi_rvalid;
  // Implement axi_awready generation
  // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
  // de-asserted when reset is low.

  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      axi_awready <= 1'b0;
      aw_en <= 1'b1;
    end else begin
      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
        // slave is ready to accept write address when
        // there is a valid write address and write data
        // on the write address and data bus. This design
        // expects no outstanding transactions.
        axi_awready <= 1'b1;
        aw_en <= 1'b0;
      end else begin
        if (S_AXI_BREADY && axi_bvalid) begin
          aw_en <= 1'b1;
          axi_awready <= 1'b0;
        end else begin
          axi_awready <= 1'b0;
        end
      end
    end
  end

  // Implement axi_awaddr latching
  // This process is used to latch the address when both
  // S_AXI_AWVALID and S_AXI_WVALID are valid.

  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      axi_awaddr <= 0;
    end else begin
      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
        // Write Address latching
        axi_awaddr <= S_AXI_AWADDR;
      end
    end
  end

  // Implement axi_wready generation
  // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
  // de-asserted when reset is low.

  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      axi_wready <= 1'b0;
    end else begin
      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en) begin
        // slave is ready to accept write data when
        // there is a valid write address and write data
        // on the write address and data bus. This design
        // expects no outstanding transactions.
        axi_wready <= 1'b1;
      end else begin
        axi_wready <= 1'b0;
      end
    end
  end

  // Implement memory mapped register select and write logic generation
  // The write data is accepted and written to memory mapped registers when
  // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  // select byte enables of slave registers while writing.
  // These registers are cleared when reset (active low) is applied.
  // Slave register write enable is asserted when valid address and data are available
  // and the slave is ready to accept the write address and write data.
  assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      slv_reg0 <= 0;
      slv_reg1 <= 0;
      slv_reg2 <= 0;
      slv_reg3 <= 0;
      slv_reg4 <= 0;
      slv_reg5 <= 0;
      slv_reg6 <= 0;
      slv_reg7 <= 0;
    end else begin
      if (slv_reg_wren) begin
        case (axi_awaddr[AddrLsb+OptMemAddrBits:AddrLsb])
          3'h0: begin
            for (
                byte_index = 0;
                byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                byte_index = byte_index + 1
            ) begin
              if (S_AXI_WSTRB[byte_index] == 1) begin
                // Respective byte enables are asserted as per write strobes
                // Slave register 0
                slv_reg0[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
              end
            end
          end
          3'h1: begin
            for (
                byte_index = 0;
                byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                byte_index = byte_index + 1
            ) begin
              if (S_AXI_WSTRB[byte_index] == 1) begin
                // Respective byte enables are asserted as per write strobes
                // Slave register 1
                slv_reg1[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
              end
            end
          end
          3'h2: begin
            for (
                byte_index = 0;
                byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                byte_index = byte_index + 1
            ) begin
              if (S_AXI_WSTRB[byte_index] == 1) begin
                // Respective byte enables are asserted as per write strobes
                // Slave register 2
                slv_reg2[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
              end
            end
          end
          3'h3: begin
            for (
                byte_index = 0;
                byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                byte_index = byte_index + 1
            ) begin
              if (S_AXI_WSTRB[byte_index] == 1) begin
                // Respective byte enables are asserted as per write strobes
                // Slave register 3
                slv_reg3[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
              end
            end
          end
          3'h4: begin
            for (
                byte_index = 0;
                byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                byte_index = byte_index + 1
            ) begin
              if (S_AXI_WSTRB[byte_index] == 1) begin
                // Respective byte enables are asserted as per write strobes
                // Slave register 4
                slv_reg4[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
              end
            end
          end
          3'h5: begin
            for (
                byte_index = 0;
                byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                byte_index = byte_index + 1
            ) begin
              if (S_AXI_WSTRB[byte_index] == 1) begin
                // Respective byte enables are asserted as per write strobes
                // Slave register 5
                slv_reg5[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
              end
            end
          end
          3'h6: begin
            for (
                byte_index = 0;
                byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                byte_index = byte_index + 1
            ) begin
              if (S_AXI_WSTRB[byte_index] == 1) begin
                // Respective byte enables are asserted as per write strobes
                // Slave register 6
                slv_reg6[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
              end
            end
          end
          3'h7: begin
            for (
                byte_index = 0;
                byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                byte_index = byte_index + 1
            ) begin
              if (S_AXI_WSTRB[byte_index] == 1) begin
                // Respective byte enables are asserted as per write strobes
                // Slave register 7
                slv_reg7[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
              end
            end
          end
          default: begin
            slv_reg0 <= slv_reg0;
            slv_reg1 <= slv_reg1;
            slv_reg2 <= slv_reg2;
            slv_reg3 <= slv_reg3;
            slv_reg4 <= slv_reg4;
            slv_reg5 <= slv_reg5;
            slv_reg6 <= slv_reg6;
            slv_reg7 <= slv_reg7;
          end
        endcase
      end
    end
  end

  // Implement write response logic generation
  // The write response and response valid signals are asserted by the slave
  // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
  // This marks the acceptance of address and indicates the status of
  // write transaction.

  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      axi_bvalid <= 0;
      axi_bresp  <= 2'b0;
    end else begin
      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
        // indicates a valid write response is available
        axi_bvalid <= 1'b1;
        axi_bresp  <= 2'b0;  // 'OKAY' response
      end else begin
        if (S_AXI_BREADY && axi_bvalid) begin
          axi_bvalid <= 1'b0;
        end
      end
    end
  end

  // Implement axi_arready generation
  // axi_arready is asserted for one S_AXI_ACLK clock cycle when
  // S_AXI_ARVALID is asserted. axi_awready is
  // de-asserted when reset (active low) is asserted.
  // The read address is also latched when S_AXI_ARVALID is
  // asserted. axi_araddr is reset to zero on reset assertion.

  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      axi_arready <= 1'b0;
      axi_araddr  <= 32'b0;
    end else begin
      if (~axi_arready && S_AXI_ARVALID) begin
        // indicates that the slave has acceped the valid read address
        axi_arready <= 1'b1;
        // Read address latching
        axi_araddr  <= S_AXI_ARADDR;
      end else begin
        axi_arready <= 1'b0;
      end
    end
  end

  // Implement axi_arvalid generation
  // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
  // S_AXI_ARVALID and axi_arready are asserted. The slave registers
  // data are available on the axi_rdata bus at this instance. The
  // assertion of axi_rvalid marks the validity of read data on the
  // bus and axi_rresp indicates the status of read transaction.axi_rvalid
  // is deasserted on reset (active low). axi_rresp and axi_rdata are
  // cleared to zero on reset (active low).
  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      axi_rvalid <= 0;
      axi_rresp  <= 0;
    end else begin
      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
        // Valid read data is available at the read data bus
        axi_rvalid <= 1'b1;
        axi_rresp  <= 2'b0;  // 'OKAY' response
      end else begin
        if (axi_rvalid && S_AXI_RREADY) begin
          // Read data is accepted by the master
          axi_rvalid <= 1'b0;
        end
      end
    end
  end
  wire [31:0] ms5611_q;
  // Implement memory mapped register select and read logic generation
  // Slave register read enable is asserted when valid address is available
  // and the slave is ready to accept the read address.
  assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
  wire rd_fifo = slv_reg_rden == 1 && axi_araddr[AddrLsb+OptMemAddrBits:AddrLsb] == 1;
  wire fifo_empty, fifo_full;
  wire [5:0] fifo_cntr;
  always @(*) begin
    case (axi_araddr[AddrLsb+OptMemAddrBits:AddrLsb])
      3'h0: begin
        reg_data_out <= slv_reg0;
      end
      3'h1: begin
        reg_data_out <= ms5611_q;
      end
      3'h2: begin
        reg_data_out <= {fifo_empty, fifo_full, 14'b0, 10'b0, fifo_cntr[5:0]};
      end
      3'h3: begin
        reg_data_out <= slv_reg3;
      end
      3'h4: begin
        reg_data_out <= slv_reg4;
      end
      3'h5: begin
        reg_data_out <= slv_reg5;
      end
      3'h6: begin
        reg_data_out <= slv_reg6;
      end
      3'h7: begin
        reg_data_out <= slv_reg7;
      end
      default: begin
        reg_data_out <= 0;
      end
    endcase
  end

  // Output register or memory read data
  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      axi_rdata <= 0;
    end else begin
      // When there is a valid read address (S_AXI_ARVALID) with
      // acceptance of read address by the slave (axi_arready),
      // output the read dada
      if (slv_reg_rden) begin
        axi_rdata <= reg_data_out;  // register read data
      end
    end
  end

  wire [31:0] Q;
  wire        Q_WR;
  ms5611_man ms5611_man (
    .clk( S_AXI_ACLK ) ,
    .rst(~S_AXI_ARESETN ) ,
    .CSN( MS5611_CSN) ,
    .SCK( MS5611_SCK) ,
    .MO( MS5611_MO) ,
    .MI( MS5611_MI) ,
    .CNVT_D1(slv_reg3[7:0]) ,
    .CNVT_D2(slv_reg4[7:0]) ,
    .Q( Q ) ,
    .Q_WR( Q_WR )  ,
    .start_rd_u24( fifo_empty )
  );

  sc_fifo #(
    .AW(5),
    .DW(32)
  ) sc_fifo (
    .clk( S_AXI_ACLK ),
    .rst( ~S_AXI_ARESETN  ),
    .din( Q ),
    .wr( Q_WR ),
    .full( fifo_full ),
    .dout(),
    .rd( rd_fifo ),
    .empty( fifo_empty ),
    .fwft_dout( ms5611_q ),
    .fifo_cntr( fifo_cntr)
  );
endmodule













module ms5611_man (
  input clk,
  rst,  //时钟和复位
  output reg CSN,
  SCK,
  MO,
  input MI,  //接MS5611的接口
  input [7:0] CNVT_D1,  //命令
  input [7:0] CNVT_D2,  //命令
  output reg [31:0] Q,  //输出结果
  output reg Q_WR,  // 输出结果有效指示  只保持一周期
  input start_rd_u24  // 读一次数值的命令，实际操作读出了2个24位数据，
);
  reg [15:0] st = 0;
  reg [ 7:0] A;
  reg [15:0] RET_ST;
  reg [23:0] R;
  reg q_valid, q_validr;
  reg [31:0] q;
  reg [ 7:0] CNVT_D2r;
  reg [ 7:0] CNVT_D1r;
  reg        MIr;
  always @(posedge clk) begin
    MIr <= MI;
  end
  always @(posedge clk) begin
    if (start_rd_u24 == 1 && st == 30) begin
      CNVT_D2r <= CNVT_D2;
      CNVT_D1r <= CNVT_D1;
    end
  end

  localparam integer IssueCmd = 100;
  localparam integer RdU16 = 200;
  localparam integer RdU24 = 300;

  always @(posedge clk) begin
    q_validr <= q_valid;
    Q_WR <= {q_validr, q_valid} == 2'b01;
    Q <= q;
  end

  reg [8:0] d = 0;
  always @(posedge clk) begin
    d <= d + 1;
  end


  always @(posedge clk) begin
    if (rst) begin
      st <= 0;
    end else begin
      if (d == 0) begin
        case (st)
          0: begin
            st <= 1;
          end
          1: begin
            CSN <= 1;
            SCK <= 0;
            st  <= 10;
          end
          10: begin
            A[7:0] <= 'H1E;
            RET_ST <= st + 1;
            st <= IssueCmd;
          end
          11: begin
            st <= st + 1;
          end

          12: begin
            A[7:0] <= 'HA2 + 'h0;
            RET_ST <= st + 1;
            st <= RdU16;
          end
          13: begin
            q <= {8'h0, R[15:0]};
            q_valid <= 1;
            st <= st + 1;
          end
          14: begin
            q_valid <= 0;
            st <= st + 1;
          end  //read c0

          15: begin
            A[7:0] <= 'HA2 + 'h2;
            RET_ST <= st + 1;
            st <= RdU16;
          end
          16: begin
            q <= {8'h0, R[15:0]};
            q_valid <= 1;
            st <= st + 1;
          end
          17: begin
            q_valid <= 0;
            st <= st + 1;
          end  //read c1
          ///STOP HERE
          18: begin
            A[7:0] <= 'HA2 + 'h4;
            RET_ST <= st + 1;
            st <= RdU16;
          end
          19: begin
            q <= {8'h0, R[15:0]};
            q_valid <= 1;
            st <= st + 1;
          end
          20: begin
            q_valid <= 0;
            st <= st + 1;
          end  //read c2

          21: begin
            A[7:0] <= 'HA2 + 'h6;
            RET_ST <= st + 1;
            st <= RdU16;
          end
          22: begin
            q <= {8'h0, R[15:0]};
            q_valid <= 1;
            st <= st + 1;
          end
          23: begin
            q_valid <= 0;
            st <= st + 1;
          end  //read c3

          24: begin
            A[7:0] <= 'HA2 + 'h8;
            RET_ST <= st + 1;
            st <= RdU16;
          end
          25: begin
            q <= {8'h0, R[15:0]};
            q_valid <= 1;
            st <= st + 1;
          end
          26: begin
            q_valid <= 0;
            st <= st + 1;
          end  //read c4

          27: begin
            A[7:0] <= 'HA2 + 'ha;
            RET_ST <= st + 1;
            st <= RdU16;
          end
          28: begin
            q <= {8'h0, R[15:0]};
            q_valid <= 1;
            st <= st + 1;
          end
          29: begin
            q_valid <= 0;
            st <= st + 1;
          end  //read c5

          30: begin
            if (start_rd_u24) begin
              st <= 31;
            end
          end

          31: begin
            A[7:0] <= CNVT_D1r;
            RET_ST <= st + 1;
            st <= IssueCmd;
          end
          32: begin
            st <= st + 1;
          end
          33: begin
            RET_ST <= st + 1;
            st <= RdU24;
          end
          34: begin
            q <= {8'h0, R[23:0]};
            q_valid <= 1;
            st <= st + 1;
          end
          35: begin
            q_valid <= 0;
            st <= st + 1;
          end

          36: begin
            A[7:0] <= CNVT_D2r;
            RET_ST <= st + 1;
            st <= IssueCmd;
          end
          37: begin
            st <= st + 1;
          end
          38: begin
            RET_ST <= st + 1;
            st <= RdU24;
          end
          39: begin
            q <= {8'h0, R[23:0]};
            q_valid <= 1;
            st <= st + 1;
          end
          40: begin
            q_valid <= 0;
            st <= st + 1;
          end
          41: begin
            st <= 30;
          end


          IssueCmd + 0: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[7];
            st  <= st + 1;
          end
          IssueCmd + 1: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[7];
            st  <= st + 1;
          end
          IssueCmd + 2: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[6];
            st  <= st + 1;
          end
          IssueCmd + 3: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[6];
            st  <= st + 1;
          end
          IssueCmd + 4: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[5];
            st  <= st + 1;
          end
          IssueCmd + 5: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[5];
            st  <= st + 1;
          end
          IssueCmd + 6: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[4];
            st  <= st + 1;
          end
          IssueCmd + 7: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[4];
            st  <= st + 1;
          end
          IssueCmd + 8: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[3];
            st  <= st + 1;
          end
          IssueCmd + 9: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[3];
            st  <= st + 1;
          end
          IssueCmd + 10: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[2];
            st  <= st + 1;
          end
          IssueCmd + 11: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[2];
            st  <= st + 1;
          end
          IssueCmd + 12: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[1];
            st  <= st + 1;
          end
          IssueCmd + 13: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[1];
            st  <= st + 1;
          end
          IssueCmd + 14: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[0];
            st  <= st + 1;
          end
          IssueCmd + 15: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[0];
            st  <= st + 1;
          end
          IssueCmd + 16: begin
            CSN <= 0;
            SCK <= 0;
            if (MIr) begin
              st <= st + 1;
            end
          end
          IssueCmd + 17: begin
            st <= st + 1;
          end
          IssueCmd + 18: begin
            st <= st + 1;
          end
          IssueCmd + 19: begin
            CSN <= 1;
            st  <= st + 1;
          end
          IssueCmd + 20: begin
            st <= st + 1;
          end
          IssueCmd + 21: begin
            st <= RET_ST;
          end



          RdU16 + 0: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[7];
            st  <= st + 1;
          end
          RdU16 + 1: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[7];
            st  <= st + 1;
          end
          RdU16 + 2: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[6];
            st  <= st + 1;
          end
          RdU16 + 3: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[6];
            st  <= st + 1;
          end
          RdU16 + 4: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[5];
            st  <= st + 1;
          end
          RdU16 + 5: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[5];
            st  <= st + 1;
          end
          RdU16 + 6: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[4];
            st  <= st + 1;
          end
          RdU16 + 7: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[4];
            st  <= st + 1;
          end
          RdU16 + 8: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[3];
            st  <= st + 1;
          end
          RdU16 + 9: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[3];
            st  <= st + 1;
          end
          RdU16 + 10: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[2];
            st  <= st + 1;
          end
          RdU16 + 11: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[2];
            st  <= st + 1;
          end
          RdU16 + 12: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[1];
            st  <= st + 1;
          end
          RdU16 + 13: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[1];
            st  <= st + 1;
          end
          RdU16 + 14: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= A[0];
            st  <= st + 1;
          end
          RdU16 + 15: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= A[0];
            st  <= st + 1;
          end

          RdU16 + 16: begin
            CSN <= 0;
            SCK <= 0;
            R[7+8] <= MIr;
            st <= st + 1;
            MO <= 0;
          end
          RdU16 + 17: begin
            CSN <= 0;
            SCK <= 1;
            R[7+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 18: begin
            CSN <= 0;
            SCK <= 0;
            R[6+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 19: begin
            CSN <= 0;
            SCK <= 1;
            R[6+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 20: begin
            CSN <= 0;
            SCK <= 0;
            R[5+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 21: begin
            CSN <= 0;
            SCK <= 1;
            R[5+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 22: begin
            CSN <= 0;
            SCK <= 0;
            R[4+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 23: begin
            CSN <= 0;
            SCK <= 1;
            R[4+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 24: begin
            CSN <= 0;
            SCK <= 0;
            R[3+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 25: begin
            CSN <= 0;
            SCK <= 1;
            R[3+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 26: begin
            CSN <= 0;
            SCK <= 0;
            R[2+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 27: begin
            CSN <= 0;
            SCK <= 1;
            R[2+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 28: begin
            CSN <= 0;
            SCK <= 0;
            R[1+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 29: begin
            CSN <= 0;
            SCK <= 1;
            R[1+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 30: begin
            CSN <= 0;
            SCK <= 0;
            R[0+8] <= MIr;
            st <= st + 1;
          end
          RdU16 + 31: begin
            CSN <= 0;
            SCK <= 1;
            R[0+8] <= MIr;
            st <= st + 1;
          end

          RdU16 + 32: begin
            CSN  <= 0;
            SCK  <= 0;
            R[7] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 33: begin
            CSN  <= 0;
            SCK  <= 1;
            R[7] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 34: begin
            CSN  <= 0;
            SCK  <= 0;
            R[6] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 35: begin
            CSN  <= 0;
            SCK  <= 1;
            R[6] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 36: begin
            CSN  <= 0;
            SCK  <= 0;
            R[5] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 37: begin
            CSN  <= 0;
            SCK  <= 1;
            R[5] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 38: begin
            CSN  <= 0;
            SCK  <= 0;
            R[4] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 39: begin
            CSN  <= 0;
            SCK  <= 1;
            R[4] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 40: begin
            CSN  <= 0;
            SCK  <= 0;
            R[3] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 41: begin
            CSN  <= 0;
            SCK  <= 1;
            R[3] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 42: begin
            CSN  <= 0;
            SCK  <= 0;
            R[2] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 43: begin
            CSN  <= 0;
            SCK  <= 1;
            R[2] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 44: begin
            CSN  <= 0;
            SCK  <= 0;
            R[1] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 45: begin
            CSN  <= 0;
            SCK  <= 1;
            R[1] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 46: begin
            CSN  <= 0;
            SCK  <= 0;
            R[0] <= MIr;
            st   <= st + 1;
          end
          RdU16 + 47: begin
            CSN  <= 0;
            SCK  <= 1;
            R[0] <= MIr;
            st   <= st + 1;
          end

          RdU16 + 48: begin
            SCK <= 0;
            st  <= st + 1;
          end
          RdU16 + 49: begin
            st <= st + 1;
          end
          RdU16 + 50: begin
            CSN <= 1;
            st  <= st + 1;
          end
          RdU16 + 51: begin
            st <= st + 1;
          end
          RdU16 + 52: begin
            st <= RET_ST;
          end


          RdU24 + 0: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 1: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 2: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 3: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 4: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 5: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 6: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 7: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 8: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 9: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 10: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 11: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 12: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 13: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 14: begin
            CSN <= 0;
            SCK <= 0;
            MO  <= 0;
            st  <= st + 1;
          end
          RdU24 + 15: begin
            CSN <= 0;
            SCK <= 1;
            MO  <= 0;
            st  <= st + 1;
          end

          RdU24 + 16: begin
            CSN <= 0;
            SCK <= 0;
            R[7+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 17: begin
            CSN <= 0;
            SCK <= 1;
            R[7+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 18: begin
            CSN <= 0;
            SCK <= 0;
            R[6+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 19: begin
            CSN <= 0;
            SCK <= 1;
            R[6+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 20: begin
            CSN <= 0;
            SCK <= 0;
            R[5+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 21: begin
            CSN <= 0;
            SCK <= 1;
            R[5+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 22: begin
            CSN <= 0;
            SCK <= 0;
            R[4+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 23: begin
            CSN <= 0;
            SCK <= 1;
            R[4+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 24: begin
            CSN <= 0;
            SCK <= 0;
            R[3+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 25: begin
            CSN <= 0;
            SCK <= 1;
            R[3+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 26: begin
            CSN <= 0;
            SCK <= 0;
            R[2+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 27: begin
            CSN <= 0;
            SCK <= 1;
            R[2+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 28: begin
            CSN <= 0;
            SCK <= 0;
            R[1+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 29: begin
            CSN <= 0;
            SCK <= 1;
            R[1+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 30: begin
            CSN <= 0;
            SCK <= 0;
            R[0+8+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 31: begin
            CSN <= 0;
            SCK <= 1;
            R[0+8+8] <= MIr;
            st <= st + 1;
          end

          RdU24 + 32: begin
            CSN <= 0;
            SCK <= 0;
            R[7+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 33: begin
            CSN <= 0;
            SCK <= 1;
            R[7+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 34: begin
            CSN <= 0;
            SCK <= 0;
            R[6+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 35: begin
            CSN <= 0;
            SCK <= 1;
            R[6+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 36: begin
            CSN <= 0;
            SCK <= 0;
            R[5+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 37: begin
            CSN <= 0;
            SCK <= 1;
            R[5+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 38: begin
            CSN <= 0;
            SCK <= 0;
            R[4+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 39: begin
            CSN <= 0;
            SCK <= 1;
            R[4+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 40: begin
            CSN <= 0;
            SCK <= 0;
            R[3+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 41: begin
            CSN <= 0;
            SCK <= 1;
            R[3+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 42: begin
            CSN <= 0;
            SCK <= 0;
            R[2+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 43: begin
            CSN <= 0;
            SCK <= 1;
            R[2+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 44: begin
            CSN <= 0;
            SCK <= 0;
            R[1+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 45: begin
            CSN <= 0;
            SCK <= 1;
            R[1+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 46: begin
            CSN <= 0;
            SCK <= 0;
            R[0+8] <= MIr;
            st <= st + 1;
          end
          RdU24 + 47: begin
            CSN <= 0;
            SCK <= 1;
            R[0+8] <= MIr;
            st <= st + 1;
          end


          RdU24 + 48: begin
            CSN  <= 0;
            SCK  <= 0;
            R[7] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 49: begin
            CSN  <= 0;
            SCK  <= 1;
            R[7] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 50: begin
            CSN  <= 0;
            SCK  <= 0;
            R[6] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 51: begin
            CSN  <= 0;
            SCK  <= 1;
            R[6] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 52: begin
            CSN  <= 0;
            SCK  <= 0;
            R[5] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 53: begin
            CSN  <= 0;
            SCK  <= 1;
            R[5] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 54: begin
            CSN  <= 0;
            SCK  <= 0;
            R[4] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 55: begin
            CSN  <= 0;
            SCK  <= 1;
            R[4] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 56: begin
            CSN  <= 0;
            SCK  <= 0;
            R[3] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 57: begin
            CSN  <= 0;
            SCK  <= 1;
            R[3] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 58: begin
            CSN  <= 0;
            SCK  <= 0;
            R[2] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 59: begin
            CSN  <= 0;
            SCK  <= 1;
            R[2] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 60: begin
            CSN  <= 0;
            SCK  <= 0;
            R[1] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 61: begin
            CSN  <= 0;
            SCK  <= 1;
            R[1] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 62: begin
            CSN  <= 0;
            SCK  <= 0;
            R[0] <= MIr;
            st   <= st + 1;
          end
          RdU24 + 63: begin
            CSN  <= 0;
            SCK  <= 1;
            R[0] <= MIr;
            st   <= st + 1;
          end


          RdU24 + 64: begin
            SCK <= 0;
            st  <= st + 1;
          end
          RdU24 + 65: begin
            st <= st + 1;
          end
          RdU24 + 66: begin
            CSN <= 1;
            st  <= st + 1;
          end
          RdU24 + 67: begin
            st <= st + 1;
          end
          RdU24 + 68: begin
            st <= RET_ST;
          end

          default: begin
            st <= 0;
          end
        endcase
      end
    end
  end

endmodule






module sc_fifo #(
  parameter integer AW           = 5,
  parameter integer DW           = 64,
  parameter integer ALMOST_FULL  = 10,
  parameter integer ALMOST_EMPTY = 12
) (
  input                clk,
  rst,
  input       [DW-1:0] din,
  input                wr,
  rd,
  output               full,
  empty,
  output wire          almost_full,
  output wire          almost_empty,
  output reg  [DW-1:0] dout = 0,
  output reg  [DW-1:0] fwft_dout,
  output reg  [  AW:0] fifo_cntr = 0
);
  parameter integer MAX_FIFO_LEN = (1 << AW);
  parameter integer ALMOST_FULL_LEN = MAX_FIFO_LEN - 10;
  parameter integer ALMOST_EMPTY_LEN = 5;
  reg     [DW-1:0] buff[0:MAX_FIFO_LEN -1];

  integer          i;
  initial begin
    for (i = 0; i < MAX_FIFO_LEN; i = 1 + i) begin
      buff[i] = 0;
    end
  end

  reg [AW-1:0] wr_ptr = 0, rd_ptr = 0;
  assign full = fifo_cntr == (MAX_FIFO_LEN - 2);
  assign empty = fifo_cntr == 0;
  assign almost_full = fifo_cntr > ALMOST_FULL_LEN;
  assign almost_empty = fifo_cntr < ALMOST_EMPTY_LEN;
  wire valid_rd = (~empty) & rd;
  wire valid_wr = (~full) & wr;

  always @(posedge clk) begin
    if (rst) begin
      wr_ptr <= 0;
    end else begin
      if (valid_wr) begin
        wr_ptr <= wr_ptr + 1;
      end
    end
  end
  always @(posedge clk) begin
    if (rst) begin
      rd_ptr <= 0;
    end else begin
      if (valid_rd) begin
        rd_ptr <= rd_ptr + 1;
      end
    end
  end
  always @(posedge clk) begin
    casex ({
      rst, valid_wr, valid_rd
    })
      3'b1xx: begin
        fifo_cntr <= 0;
      end
      3'b010: begin
        fifo_cntr <= fifo_cntr + 1;
      end
      3'b001: begin
        fifo_cntr <= fifo_cntr - 1;
      end
      3'b011, 3'b000: begin
        fifo_cntr <= fifo_cntr;
      end
      default: begin
        fifo_cntr <= fifo_cntr;
      end
    endcase
  end
  always @(posedge clk) begin
    if (valid_wr) begin
      buff[wr_ptr] <= din;
    end
  end
  always @(posedge clk) begin
    if (valid_rd) begin
      dout <= buff[rd_ptr];
    end
  end
  always @(posedge clk) begin
    fwft_dout <= buff[rd_ptr];
  end

  ////////////////////////////////////////////////////////////////////
  //
  // Sanity Check
  //

  // synopsys translate_off
  always @(posedge clk) begin
    if (wr & full) begin
      $display("%m WARNING: Writing while fifo_sc is FULL (%t)", $time);
    end
  end

  always @(posedge clk) begin
    if (rd & empty) begin
      $display("%m WARNING: Reading while fifo_sc is EMPTY (%t)", $time);
    end
  end
  // synopsys translate_on

endmodule




