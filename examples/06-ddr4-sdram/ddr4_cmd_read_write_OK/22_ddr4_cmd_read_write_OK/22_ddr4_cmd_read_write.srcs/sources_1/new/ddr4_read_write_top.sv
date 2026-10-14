module ddr4_read_write_top (
  input         sys_rstn,                //Common port for all controllers
  output        c0_init_calib_complete,
  input         c0_sys_clk_p,
  input         c0_sys_clk_n,
  output        c0_ddr4_act_n,
  output [16:0] c0_ddr4_adr,
  output [ 1:0] c0_ddr4_ba,
  output [ 0:0] c0_ddr4_bg,
  output [ 0:0] c0_ddr4_cke,
  output [ 0:0] c0_ddr4_odt,
  output [ 0:0] c0_ddr4_cs_n,
  output [ 0:0] c0_ddr4_ck_t,
  output [ 0:0] c0_ddr4_ck_c,
  output        c0_ddr4_reset_n,
  inout  [ 3:0] c0_ddr4_dm_dbi_n,
  inout  [31:0] c0_ddr4_dq,
  inout  [ 3:0] c0_ddr4_dqs_t,
  inout  [ 3:0] c0_ddr4_dqs_c
);
  //data width related
  parameter integer APP_ADDR_WIDTH = 28;
  parameter integer APP_DATA_WIDTH = 256;
  parameter integer APP_MASK_WIDTH = 64;
  //ddr4 user port,debug to catch it
  (*mark_debug="true"*)wire                      c0_ddr4_ui_clk;
  wire                      c0_ddr4_ui_rst;
  (*mark_debug="true"*)wire [              28:0] app_addr;
  (*mark_debug="true"*)wire [               2:0] app_cmd;
  (*mark_debug="true"*)wire                      app_en;
  (*mark_debug="true"*)wire [APP_DATA_WIDTH-1:0] app_wdf_data;
  (*mark_debug="true"*)wire                      app_wdf_end;
  (*mark_debug="true"*)wire                      app_wdf_wren;
  (*mark_debug="true"*)wire [APP_DATA_WIDTH-1:0] app_rd_data;
  (*mark_debug="true"*)wire                      app_rd_data_end;
  (*mark_debug="true"*)wire                      app_rd_data_valid;
  (*mark_debug="true"*)wire                      app_rdy;
  (*mark_debug="true"*)wire                      app_wdf_rdy;
  (*mark_debug="true"*)wire                      write_state_flag;
  //user port reg
  reg  [              28:0] app_addr_reg;
  reg  [               2:0] app_cmd_reg;
  reg                       app_en_reg;
  reg  [APP_DATA_WIDTH-1:0] app_wdf_data_reg;
  reg                       app_wdf_wren_reg;
  reg                       app_wdf_end_reg;
  (*mark_debug="true"*)reg  [APP_DATA_WIDTH-1:0] app_rd_data_reg;
  parameter logic [3:0] STATE_IDLE = 4'd0;  //idle
  parameter logic [3:0] STATE_WRITE = 4'd1;
  parameter logic [3:0] STATE_WAIT = 4'd2;
  parameter logic [3:0] STATE_READ = 4'd3;
  parameter logic [3:0] STATE_END = 4'd4;
  reg [3:0] state_reg;
  assign app_addr     = app_addr_reg;
  assign app_wdf_data = app_wdf_data_reg;
  assign app_wdf_wren = (state_reg == STATE_WRITE) && app_rdy && app_wdf_rdy;
  assign app_wdf_end  = app_wdf_wren;
  //every state time period count
  parameter logic [15:0] FSM_IDLE_TIME = 16'd128;  //ilde 128 clk period
  parameter logic [15:0] FSM_WRITE_TIME = 16'd256;  //write 256 data clock perod
  parameter logic [15:0] FSM_WAIT_TIME = 16'd8;  //wait 8 clk period
  parameter logic [15:0] FSM_READ_TIME = 16'd256;  //read 256 period
  parameter logic [2:0] CMD_WRITE = 3'b000;
  parameter logic [2:0] CMD_READ = 3'b001;
  parameter logic [28:0] ADDR_INCREMENT = 29'd32;
  parameter logic [255:0] DATA_INCREMENT =
    256'h01010101_01010101_01010101_01010101_01010101_01010101_01010101_01010101;
  assign write_state_flag = (state_reg == STATE_WRITE) ? 1'b1 : 1'b0;  //if state=write,indicate it
  assign app_en = ((state_reg == STATE_WRITE && (app_rdy && app_wdf_rdy)) ||
                   (state_reg == STATE_READ && app_rdy)) ? 1'b1 : 1'b0;  //data port en
  assign app_cmd = (state_reg == STATE_READ) ? 3'd1 : 3'd0;  //if write,cmd=0,if read ,cmd=1
  //if app_rd_data_valid=1,data is active,store to register
  always @(posedge c0_ddr4_ui_clk) begin
    if (app_rd_data_valid == 'b1) begin
      app_rd_data_reg <= app_rd_data;
    end
  end
  reg [15:0] fsm_cnt_reg;  //fsm state change counter
  //read write FSM,idle->write->read->end->idle
  always @(posedge c0_ddr4_ui_clk or posedge c0_ddr4_ui_rst) begin
    if (c0_ddr4_ui_rst) begin
      state_reg   <= 'd0;
      fsm_cnt_reg <= 'd0;
    end else begin
      case (state_reg)
        STATE_IDLE: begin  //state idle,fsm_cnt_reg timeout change to STATE_WRITE
          if (c0_init_calib_complete == 'b1) begin
            if (fsm_cnt_reg < FSM_IDLE_TIME - 16'd1) begin
              fsm_cnt_reg <= fsm_cnt_reg + 'd1;
            end else begin
              fsm_cnt_reg <= 'd0;
              state_reg   <= STATE_WRITE;
            end
          end
        end
        STATE_WRITE: begin  //state write,fsm_cnt_reg timeout change to STATE_WAIT
          if (fsm_cnt_reg < FSM_WRITE_TIME - 16'd1) begin
            fsm_cnt_reg <= fsm_cnt_reg + 'd1;
          end else begin
            fsm_cnt_reg <= 'd0;
            state_reg   <= STATE_WAIT;
          end
        end
        STATE_WAIT: begin  //state waite,do nothing,fsm_cnt_reg timeout change to STATE_READ
          if (fsm_cnt_reg < FSM_WAIT_TIME - 16'd1) begin
            fsm_cnt_reg <= fsm_cnt_reg + 'd1;
          end else begin
            fsm_cnt_reg <= 'd0;
            state_reg   <= STATE_READ;
          end
        end
        STATE_READ: begin  //state read£¬fsm_cnt_reg timeout change to STATE_END
          if (fsm_cnt_reg < FSM_WRITE_TIME - 16'd1) begin
            fsm_cnt_reg <= fsm_cnt_reg + 'd1;
          end else begin
            fsm_cnt_reg <= 'd0;
            state_reg   <= STATE_END;
          end
        end
        STATE_END: begin  //state END£¬fsm_cnt_reg timeout change to STATE_IDLE
          state_reg <= STATE_IDLE;
        end
        default: begin
          state_reg <= STATE_IDLE;
        end
      endcase
    end
  end
  //generate read\write signal and data
  always @(posedge c0_ddr4_ui_clk or posedge c0_ddr4_ui_rst) begin
    if (c0_ddr4_ui_rst) begin
      app_addr_reg <= 'd0;
      app_wdf_data_reg <= 'd0;
    end else begin
      case (state_reg)
        STATE_IDLE: begin  //idle ,do nothing
          app_addr_reg <= 'd0;
          app_wdf_data_reg <= 'd0;
        end
        STATE_WRITE: begin  //data just DATA_INCREMENT£¬and addr just ADDR_INCREMENT
          if (app_wdf_wren == 'b1) begin
            app_addr_reg <= app_addr_reg + ADDR_INCREMENT;
            app_wdf_data_reg <= app_wdf_data_reg + DATA_INCREMENT;
          end
        end
        STATE_WAIT: begin  //do nothing
          app_addr_reg <= 'd0;
          app_wdf_data_reg <= 'd0;
        end
        STATE_READ: begin  //ddr just ADDR_INCREMENT,read next addr
          if (app_rdy == 'b1) begin
            app_addr_reg <= app_addr_reg + ADDR_INCREMENT;
          end
        end
        STATE_END: begin  //do nothing
          app_addr_reg <= 'd0;
        end
        default: ;
      endcase
    end
  end
  wire         unused_dbg_clk;
  wire [511:0] unused_dbg_bus;
  //ddr4 ip module instance
  ddr4_0 u_ddr4_0 (
    .sys_rst(sys_rstn),
    .c0_sys_clk_p(c0_sys_clk_p),
    .c0_sys_clk_n(c0_sys_clk_n),
    .c0_init_calib_complete(c0_init_calib_complete),
    .c0_ddr4_act_n(c0_ddr4_act_n),
    .c0_ddr4_adr(c0_ddr4_adr),
    .c0_ddr4_ba(c0_ddr4_ba),
    .c0_ddr4_bg(c0_ddr4_bg),
    .c0_ddr4_cke(c0_ddr4_cke),
    .c0_ddr4_odt(c0_ddr4_odt),
    .c0_ddr4_cs_n(c0_ddr4_cs_n),
    .c0_ddr4_ck_t(c0_ddr4_ck_t),
    .c0_ddr4_ck_c(c0_ddr4_ck_c),
    .c0_ddr4_reset_n(c0_ddr4_reset_n),
    .c0_ddr4_dm_dbi_n(c0_ddr4_dm_dbi_n),
    .c0_ddr4_dq(c0_ddr4_dq),
    .c0_ddr4_dqs_c(c0_ddr4_dqs_c),
    .c0_ddr4_dqs_t(c0_ddr4_dqs_t),
    .c0_ddr4_ui_clk(c0_ddr4_ui_clk),
    .c0_ddr4_ui_clk_sync_rst(c0_ddr4_ui_rst),
    .dbg_clk(unused_dbg_clk),
    .c0_ddr4_app_addr(app_addr),
    .c0_ddr4_app_cmd(app_cmd),
    .c0_ddr4_app_en(app_en),
    .c0_ddr4_app_hi_pri(1'b0),
    .c0_ddr4_app_wdf_data(app_wdf_data),
    .c0_ddr4_app_wdf_end(app_wdf_end),
    .c0_ddr4_app_wdf_mask(64'd0),
    .c0_ddr4_app_wdf_wren(app_wdf_wren),
    .c0_ddr4_app_rd_data(app_rd_data),
    .c0_ddr4_app_rd_data_end(app_rd_data_end),
    .c0_ddr4_app_rd_data_valid(app_rd_data_valid),
    .c0_ddr4_app_rdy(app_rdy),
    .c0_ddr4_app_wdf_rdy(app_wdf_rdy),
    // Debug Port
    .dbg_bus(unused_dbg_bus)
  );
endmodule
