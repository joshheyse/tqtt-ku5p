
`timescale 1 ns / 1 ps

module dummy_slave_slave_lite_v1_0_S00_AXI #(
  parameter integer C_S_AXI_DATA_WIDTH = 32,
  parameter integer C_S_AXI_ADDR_WIDTH = 5
) (
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
  integer                          byte_index;

  // I/O Connections assignments

  assign S_AXI_AWREADY = axi_awready;
  assign S_AXI_WREADY  = axi_wready;
  assign S_AXI_BRESP   = axi_bresp;
  assign S_AXI_BVALID  = axi_bvalid;
  assign S_AXI_ARREADY = axi_arready;
  assign S_AXI_RRESP   = axi_rresp;
  assign S_AXI_RVALID  = axi_rvalid;
  //state machine varibles
  reg [1:0] state_write;
  reg [1:0] state_read;
  //State machine local parameters
  localparam integer Idle = 2'b00, Raddr = 2'b10, Rdata = 2'b11, Waddr = 2'b10, Wdata = 2'b11;
  // Implement Write state machine
  // Outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      axi_awready <= 0;
      axi_wready  <= 0;
      axi_bvalid  <= 0;
      axi_bresp   <= 0;
      axi_awaddr  <= 0;
      state_write <= Idle;
    end else begin
      case (state_write)
        Idle: begin
          if (S_AXI_ARESETN == 1'b1) begin
            axi_awready <= 1'b1;
            axi_wready  <= 1'b1;
            state_write <= Waddr;
          end else begin
            state_write <= state_write;
          end
        end
        Waddr: begin
          if (S_AXI_AWVALID && S_AXI_AWREADY) begin
            axi_awaddr <= S_AXI_AWADDR;
            if (S_AXI_WVALID) begin
              axi_awready <= 1'b1;
              state_write <= Waddr;
              axi_bvalid  <= 1'b1;
            end else begin
              axi_awready <= 1'b0;
              state_write <= Wdata;
              if (S_AXI_BREADY && axi_bvalid) begin
                axi_bvalid <= 1'b0;
              end
            end
          end else begin
            state_write <= state_write;
            if (S_AXI_BREADY && axi_bvalid) begin
              axi_bvalid <= 1'b0;
            end
          end
        end
        Wdata: begin
          if (S_AXI_WVALID) begin
            state_write <= Waddr;
            axi_bvalid  <= 1'b1;
            axi_awready <= 1'b1;
          end else begin
            state_write <= state_write;
            if (S_AXI_BREADY && axi_bvalid) begin
              axi_bvalid <= 1'b0;
            end
          end
        end
        default: begin
          state_write <= Idle;
        end
      endcase
    end
  end

  // Implement memory mapped register select and write logic generation
  // The write data is accepted and written to memory mapped registers when
  // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  // select byte enables of slave registers while writing.
  // These registers are cleared when reset (active low) is applied.
  // Slave register write enable is asserted when valid address and data are available
  // and the slave is ready to accept the write address and write data.


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
      if (S_AXI_WVALID) begin
        case ((S_AXI_AWVALID) ? S_AXI_AWADDR[AddrLsb+OptMemAddrBits:AddrLsb] :
                                  axi_awaddr[AddrLsb+OptMemAddrBits:AddrLsb])
          3'h0: begin
            for (
                byte_index = 0;
                byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                byte_index = byte_index + 1
            ) begin
              if (S_AXI_WSTRB[byte_index] == 1) begin
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

  // Implement read state machine
  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 1'b0) begin
      //asserting initial values to all 0's during reset
      axi_arready <= 1'b0;
      axi_rvalid  <= 1'b0;
      axi_rresp   <= 1'b0;
      state_read  <= Idle;
    end else begin
      case (state_read)
        Idle: begin
          if (S_AXI_ARESETN == 1'b1) begin
            state_read  <= Raddr;
            axi_arready <= 1'b1;
          end else begin
            state_read <= state_read;
          end
        end
        Raddr: begin
          if (S_AXI_ARVALID && S_AXI_ARREADY) begin
            state_read  <= Rdata;
            axi_araddr  <= S_AXI_ARADDR;
            axi_rvalid  <= 1'b1;
            axi_arready <= 1'b0;
          end else begin
            state_read <= state_read;
          end
        end
        Rdata: begin
          if (S_AXI_RVALID && S_AXI_RREADY) begin
            axi_rvalid  <= 1'b0;
            axi_arready <= 1'b1;
            state_read  <= Raddr;
          end else begin
            state_read <= state_read;
          end
        end
        default: begin
          state_read <= Idle;
        end
      endcase
    end
  end
  // Implement memory mapped register select and read logic generation
  assign S_AXI_RDATA =
      (axi_araddr[AddrLsb+OptMemAddrBits:AddrLsb] == 2'h0) ? slv_reg0 :
      (axi_araddr[AddrLsb+OptMemAddrBits:AddrLsb] == 2'h1) ? slv_reg1 :
      (axi_araddr[AddrLsb+OptMemAddrBits:AddrLsb] == 2'h2) ? slv_reg2 :
      (axi_araddr[AddrLsb+OptMemAddrBits:AddrLsb] == 2'h3) ? slv_reg3 : 0;
endmodule
