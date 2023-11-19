module mycpu_top(
    input  aclk   ,
    input  aresetn,
    // read req channel
    output [ 3:0] arid   , // ������ID
    output [31:0] araddr , // �������ַ
    output [ 7:0] arlen  , // �������䳤�ȣ����ݴ���������
    output [ 2:0] arsize , // ���������С�����ݴ���ÿ�ĵ��ֽ�����
    output [ 1:0] arburst, // ��������
    output [ 1:0] arlock , // ԭ����
    output [ 3:0] arcache, // Cache����
    output [ 2:0] arprot , // ��������
    output        arvalid, // �������ַ��Ч
    input         arready, // �������ַ�����ź�
    // read response channel
    input [ 3:0]  rid    , // ������ID�ţ�ͬһ����rid��aridһ��
    input [31:0]  rdata  , // ���������������
    input [ 1:0]  rresp  , // �������Ƿ����                        [�ɺ���]
    input         rlast  , // ���������һ�����ݵ�ָʾ�ź�           [�ɺ���]
    input         rvalid , // ������������Ч
    output        rready , // Master��׼���ý�������
    // write req channel
    output [ 3:0] awid   , // д�����ID��
    output [31:0] awaddr , // д����ĵ�ַ
    output [ 7:0] awlen  , // д�����䳤�ȣ�������
    output [ 2:0] awsize , // д������ÿ���ֽ���
    output [ 1:0] awburst, // д����������
    output [ 1:0] awlock , // ԭ����
    output [ 3:0] awcache, // Cache����
    output [ 2:0] awprot , // ��������
    output        awvalid, // д�����ַ��Ч
    input         awready, // Slave��׼���ý��ܵ�ַ����   
    // write data channel
    output [ 3:0] wid    , // д�����ID��
    output [31:0] wdata  , // д�����д����
    output [ 3:0] wstrb  , // д�����ֽ�ѡͨλ
    output        wlast  , // д��������һ�����ݵ�ָʾ�ź�
    output        wvalid , // д������Ч
    input         wready , // Slave��׼���ý���д���ݴ���   
    // write response channel
    input  [ 3:0] bid    , // д�����ID��            [�ɺ���]
    input  [ 1:0] bresp  , // д��������ź�          [�ɺ���]
    input         bvalid , // д������Ӧ��Ч
    output        bready , // Master��׼���ý�����Ӧ�ź�
    // trace debug interface
    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_we,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

    // inst sram interface
    wire        inst_sram_req;
    wire        inst_sram_wr;
    wire [ 1:0] inst_sram_size;
    wire [ 3:0] inst_sram_wstrb;
    wire [31:0] inst_sram_addr;
    wire [31:0] inst_sram_wdata;
    wire        inst_sram_addr_ok;
    wire        inst_sram_data_ok;
    wire [31:0] inst_sram_rdata;
    // data sram interface
    wire        data_sram_req;
    wire        data_sram_wr;
    wire [ 1:0] data_sram_size;
    wire [ 3:0] data_sram_wstrb;
    wire [31:0] data_sram_addr;
    wire [31:0] data_sram_wdata;
    wire        data_sram_addr_ok;
    wire        data_sram_data_ok;
    wire [31:0] data_sram_rdata;

    mycpu_core my_core(
        .clk            (aclk       ),
        .resetn         (aresetn    ),
        // inst sram interface
        .inst_sram_req      (inst_sram_req      ),
        .inst_sram_wr       (inst_sram_wr       ),
        .inst_sram_size     (inst_sram_size     ),
        .inst_sram_wstrb    (inst_sram_wstrb    ),
        .inst_sram_addr     (inst_sram_addr     ),
        .inst_sram_wdata    (inst_sram_wdata    ),
        .inst_sram_addr_ok  (inst_sram_addr_ok  ),
        .inst_sram_data_ok  (inst_sram_data_ok  ),
        .inst_sram_rdata    (inst_sram_rdata    ),
        .axi_arid           (arid               ),
        // data sram interface
        .data_sram_req      (data_sram_req      ),
        .data_sram_wr       (data_sram_wr       ),
        .data_sram_size     (data_sram_size     ),
        .data_sram_wstrb    (data_sram_wstrb    ),
        .data_sram_addr     (data_sram_addr     ),
        .data_sram_wdata    (data_sram_wdata    ),
        .data_sram_addr_ok  (data_sram_addr_ok  ),
        .data_sram_data_ok  (data_sram_data_ok  ),
        .data_sram_rdata    (data_sram_rdata    ),
        // trace debug interface
        .debug_wb_pc        (debug_wb_pc        ),
        .debug_wb_rf_we     (debug_wb_rf_we     ),
        .debug_wb_rf_wnum   (debug_wb_rf_wnum   ),
        .debug_wb_rf_wdata  (debug_wb_rf_wdata  )
    ); 

    bridge_sram_axi my_bridge_sram_axi(
    .aclk               (aclk               ),
    .aresetn            (aresetn            ),

    .arid               (arid               ),
    .araddr             (araddr             ),
    .arlen              (arlen              ),
    .arsize             (arsize             ),
    .arburst            (arburst            ),
    .arlock             (arlock             ),
    .arcache            (arcache            ),
    .arprot             (arprot             ),
    .arvalid            (arvalid            ),
    .arready            (arready            ),

    .rid                (rid                ),
    .rdata              (rdata              ),
    .rvalid             (rvalid             ),
    .rlast              (rlast              ),
    .rready             (rready             ),

    .awid               (awid               ),
    .awaddr             (awaddr             ),
    .awlen              (awlen              ),
    .awsize             (awsize             ),
    .awburst            (awburst            ),
    .awlock             (awlock             ),
    .awcache            (awcache            ),
    .awprot             (awprot             ),
    .awvalid            (awvalid            ),
    .awready            (awready            ),

    .wid                (wid                ),
    .wdata              (wdata              ),
    .wstrb              (wstrb              ),
    .wlast              (wlast              ),
    .wvalid             (wvalid             ),
    .wready             (wready             ),

    .bid                (bid                ),
    .bvalid             (bvalid             ),
    .bready             (bready             ),

    .inst_sram_req      (inst_sram_req      ),
    .inst_sram_wr       (inst_sram_wr       ),
    .inst_sram_size     (inst_sram_size     ),
    .inst_sram_addr     (inst_sram_addr     ),
    .inst_sram_wstrb    (inst_sram_wstrb    ),
    .inst_sram_wdata    (inst_sram_wdata    ),
    .inst_sram_addr_ok  (inst_sram_addr_ok  ),
    .inst_sram_data_ok  (inst_sram_data_ok  ),
    .inst_sram_rdata    (inst_sram_rdata    ),

    .data_sram_req      (data_sram_req      ),
    .data_sram_wr       (data_sram_wr       ),
    .data_sram_size     (data_sram_size     ),
    .data_sram_addr     (data_sram_addr     ),
    .data_sram_wstrb    (data_sram_wstrb    ),
    .data_sram_wdata    (data_sram_wdata    ),
    .data_sram_addr_ok  (data_sram_addr_ok  ),
    .data_sram_data_ok  (data_sram_data_ok  ),
    .data_sram_rdata    (data_sram_rdata    )
);

endmodule

`ifndef MACRO
    `define MACRO
//-----------------------macros for bus---------------------------

    `define FS2DS_LEN 65
    `define DS2ES_LEN 250
    `define ES2MS_LEN 124
    `define MS2WS_LEN 150

//-----------------------macros for csr---------------------------
    // macros for csr_num
    `define CSR_CRMD   14'h00
    `define CSR_PRMD   14'h01
    `define CSR_EUEN   14'h02
    `define CSR_ECFG   14'h04
    `define CSR_ESTAT  14'h05
    `define CSR_ERA    14'h06
    `define CSR_BADV   14'h07
    `define CSR_EENTRY 14'h0c
    `define CSR_SAVE0  14'h30
    `define CSR_SAVE1  14'h31
    `define CSR_SAVE2  14'h32
    `define CSR_SAVE3  14'h33
    `define CSR_TID    14'h40
    `define CSR_TCFG   14'h41
    `define CSR_TVAL   14'h42
    `define CSR_TICLR  14'h44

    // macros for index
    `define CSR_CRMD_PLV    1 :0
    `define CSR_CRMD_IE     2
    `define CSR_PRMD_PPLV   1 :0
    `define CSR_PRMD_PIE    2
    `define CSR_ECFG_LIE    12:0
    `define CSR_ESTAT_IS10  1 :0
    `define CSR_ERA_PC      31:0
    `define CSR_EENTRY_VA   31:6
    `define CSR_SAVE_DATA   31:0
    `define CSR_TID_TID     31:0
    `define CSR_TCFG_EN     0
    `define CSR_TCFG_PERIOD 1
    `define CSR_TCFG_INITV  31:2
    `define CSR_TICLR_CLR   0

    // macros for ecode and esubcode
    `define ECODE_INT       6'h00
    `define ECODE_ADE       6'h08   // ADEM: esubcode=1; ADEF: esubcode=0
    `define ECODE_ALE       6'h09   
    `define ECODE_SYS       6'h0B
    `define ECODE_BRK       6'h0C   
    `define ECODE_INE       6'h0D
    `define ECODE_TLBR      6'h3F
    
    `define ESUBCODE_ADEF   9'b00

`endif

module mycpu_core(
    input  wire        clk,
    input  wire        resetn,
    // inst sram interface
    output wire         inst_sram_req,
    output wire         inst_sram_wr,
    output wire [ 1:0]  inst_sram_size,
    output wire [ 3:0]  inst_sram_wstrb,
    output wire [31:0]  inst_sram_addr,
    output wire [31:0]  inst_sram_wdata,
    input  wire         inst_sram_addr_ok,
    input  wire         inst_sram_data_ok,
    input  wire [31:0]  inst_sram_rdata,
    input  wire [ 3:0]  axi_arid,
    // data sram interface
    output wire         data_sram_req,
    output wire         data_sram_wr,
    output wire [ 1:0]  data_sram_size,
    output wire [ 3:0]  data_sram_wstrb,
    output wire [31:0]  data_sram_addr,
    output wire [31:0]  data_sram_wdata,
    input  wire         data_sram_addr_ok,
    input  wire         data_sram_data_ok,
    input  wire [31:0]  data_sram_rdata,
    // trace debug interface
    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_we,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);
    wire        ds_allowin;
    wire        es_allowin;
    wire        ms_allowin;
    wire        ws_allowin;

    wire        fs2ds_valid;
    wire        ds2es_valid;
    wire        es2ms_valid;
    wire        ms2ws_valid;

    wire [31:0] es_pc;
    wire [31:0] ms_pc;
    wire [31:0] wb_pc;

    wire [39:0] es_rf_zip;
    wire [39:0] ms_rf_zip;
    wire [37:0] ws_rf_zip;

    wire [33:0] br_zip;
    wire [ 4:0] es_ld_inst_zip;
    wire [`FS2DS_LEN -1:0] fs2ds_bus;
    wire [`DS2ES_LEN -1:0] ds2es_bus;
    wire [`ES2MS_LEN -1:0] es2ms_bus;
    wire [`MS2WS_LEN -1:0] ms2ws_bus;

    wire        csr_re;
    wire [13:0] csr_num;
    wire [31:0] csr_rvalue;
    wire        csr_we;
    wire [31:0] csr_wmask;
    wire [31:0] csr_wvalue;
    wire [31:0] ex_entry;
    wire [31:0] ertn_entry;
    wire        has_int;
    wire        ertn_flush;
    wire        ms_ex;
    wire        wb_ex;
    wire [31:0] wb_vaddr;
    wire [ 5:0] wb_ecode;
    wire [ 8:0] wb_esubcode;

    // wire ms_wait_data_ok;

    IFreg my_ifReg(
        .clk(clk),
        .resetn(resetn),

        .inst_sram_req(inst_sram_req),
        .inst_sram_wr(inst_sram_wr),
        .inst_sram_size(inst_sram_size),
        .inst_sram_wstrb(inst_sram_wstrb),
        .inst_sram_addr(inst_sram_addr),
        .inst_sram_addr_ok(inst_sram_addr_ok),
        .inst_sram_data_ok(inst_sram_data_ok),
        .inst_sram_rdata(inst_sram_rdata),
        .inst_sram_wdata(inst_sram_wdata),
        .axi_arid(axi_arid),
        
        .ds_allowin(ds_allowin),
        .br_zip(br_zip),
        .fs2ds_valid(fs2ds_valid),
        .fs2ds_bus(fs2ds_bus),

        .wb_ex(wb_ex),
        .ertn_flush(ertn_flush),
        .ex_entry(ex_entry),
        .ertn_entry(ertn_entry)
    );

    IDreg my_idReg(
        .clk(clk),
        .resetn(resetn),

        .ds_allowin(ds_allowin),
        .br_zip(br_zip),
        .fs2ds_valid(fs2ds_valid),
        .fs2ds_bus(fs2ds_bus),

        .es_allowin(es_allowin),
        .ds2es_valid(ds2es_valid),
        .ds2es_bus(ds2es_bus),

        .ws_rf_zip(ws_rf_zip),
        .ms_rf_zip(ms_rf_zip),
        .es_rf_zip(es_rf_zip),

        .has_int(has_int),
        .wb_ex(wb_ex|ertn_flush)
    );

    EXEreg my_exeReg(
        .clk(clk),
        .resetn(resetn),
        
        .es_allowin(es_allowin),
        .ds2es_valid(ds2es_valid),
        .ds2es_bus(ds2es_bus),

        .ms_allowin(ms_allowin),
        .es2ms_bus(es2ms_bus),
        .es_rf_zip(es_rf_zip),
        .es2ms_valid(es2ms_valid),
        // .ms_wait_data_ok(ms_wait_data_ok),
        
        .data_sram_req(data_sram_req),
        .data_sram_wr(data_sram_wr),
        .data_sram_size(data_sram_size),
        .data_sram_wstrb(data_sram_wstrb),
        .data_sram_wdata(data_sram_wdata),
        .data_sram_addr(data_sram_addr),
        .data_sram_addr_ok(data_sram_addr_ok),

        .ms_ex(ms_ex),
        .wb_ex(wb_ex|ertn_flush)
    );

    MEMreg my_memReg(
        .clk(clk),
        .resetn(resetn),

        .ms_allowin(ms_allowin),
        .es2ms_bus(es2ms_bus),
        .es_rf_zip(es_rf_zip),
        .es2ms_valid(es2ms_valid),
        // .ms_wait_data_ok(ms_wait_data_ok),
        
        .ws_allowin(ws_allowin),
        .ms_rf_zip(ms_rf_zip),
        .ms2ws_valid(ms2ws_valid),
        .ms2ws_bus(ms2ws_bus),

        .data_sram_data_ok(data_sram_data_ok),
        .data_sram_rdata(data_sram_rdata),

        .ms_ex(ms_ex),
        .wb_ex(wb_ex|ertn_flush)
    ) ;

    WBreg my_wbReg(
        .clk(clk),
        .resetn(resetn),

        .ws_allowin(ws_allowin),
        .ms_rf_zip(ms_rf_zip),
        .ms2ws_valid(ms2ws_valid),
        .ms2ws_bus(ms2ws_bus),

        .debug_wb_pc(debug_wb_pc),
        .debug_wb_rf_we(debug_wb_rf_we),
        .debug_wb_rf_wnum(debug_wb_rf_wnum),
        .debug_wb_rf_wdata(debug_wb_rf_wdata),

        .ws_rf_zip(ws_rf_zip),

        .csr_re     (csr_re    ),
        .csr_num    (csr_num   ),
        .csr_rvalue (csr_rvalue),
        .csr_we     (csr_we    ),
        .csr_wmask  (csr_wmask ),
        .csr_wvalue (csr_wvalue),
        .ertn_flush (ertn_flush),
        .wb_ex      (wb_ex     ),
        .wb_pc      (wb_pc     ),
        .wb_vaddr   (wb_vaddr  ),
        .wb_ecode   (wb_ecode  ),
        .wb_esubcode(wb_esubcode)
    );

    csr u_csr(
        .clk        (clk       ),
        .reset      (~resetn   ),
        .csr_re     (csr_re    ),
        .csr_num    (csr_num   ),
        .csr_rvalue (csr_rvalue),
        .csr_we     (csr_we    ),
        .csr_wmask  (csr_wmask ),
        .csr_wvalue (csr_wvalue),

        .has_int    (has_int   ),
        .ex_entry   (ex_entry  ),
        .ertn_entry (ertn_entry),
        .ertn_flush (ertn_flush),
        .wb_ex      (wb_ex     ),
        .wb_pc      (wb_pc     ),
        .wb_vaddr   (wb_vaddr  ),
        .wb_ecode   (wb_ecode  ),
        .wb_esubcode(wb_esubcode)
    );
endmodule


module bridge_sram_axi(
    input               aclk,
    input               aresetn,
    // read req channel
    output  reg [ 3:0]      arid,
    output  reg [31:0]      araddr,
    output  reg [ 7:0]      arlen,
    output  reg [ 2:0]      arsize,
    output  reg [ 1:0]      arburst,
    output  reg [ 1:0]      arlock,
    output  reg [ 3:0]      arcache,
    output  reg [ 2:0]      arprot,
    output              	arvalid,
    input               	arready,
    // read response channel
    input   	[ 3:0]      rid,
    input   	[31:0]      rdata,
    input   	[ 1:0]      rresp,
    input               	rlast,
    input               	rvalid,
    output              	rready,
    // write req channel
    output  reg [ 3:0]      awid,
    output  reg [31:0]      awaddr,
    output  reg [ 7:0]      awlen,
    output  reg [ 2:0]      awsize,
    output  reg [ 1:0]      awburst,
    output  reg [ 1:0]      awlock,
    output  reg [ 3:0]      awcache,
    output  reg [ 2:0]      awprot,
    output              	awvalid,
    input               	awready,
    // write data channel
    output  reg [ 3:0]      wid,
    output  reg [31:0]      wdata,
    output  reg [ 3:0]      wstrb,
    output  reg         	wlast,
    output              	wvalid,
    input               	wready,
    // write response channel
    input   	[ 3:0]      bid,
    input   	[ 1:0]      bresp,
    input               	bvalid,
    output              	bready,
    // inst sram interface
    input               	inst_sram_req,
    input               	inst_sram_wr,
    input   	[ 1:0]      inst_sram_size,
    input   	[31:0]      inst_sram_addr,
    input   	[ 3:0]      inst_sram_wstrb,
    input   	[31:0]      inst_sram_wdata,
    output              inst_sram_addr_ok,
    output              inst_sram_data_ok,
    output  [31:0]      inst_sram_rdata,
    // data sram interface
    input               	data_sram_req,
    input               	data_sram_wr,
    input   	[ 1:0]      data_sram_size,
    input   	[31:0]      data_sram_addr,
    input   	[31:0]      data_sram_wdata,
    input   	[ 3:0]      data_sram_wstrb,
    output              data_sram_addr_ok,
    output              data_sram_data_ok,
    output  [31:0]      data_sram_rdata
);
	// ״̬��״̬�Ĵ���
	reg [4:0] ar_current_state;	// ������״̬��
	reg [4:0] ar_next_state;
	reg [4:0] r_current_state;	// ������״̬��
	reg [4:0] r_next_state;
	reg [4:0] w_current_state;	// д�����д����״̬��
	reg [4:0] w_next_state;
	reg [4:0] b_current_state;	// д��Ӧ״̬��
	reg [4:0] b_next_state;
	// ��ַ�Ѿ����ֳɹ���δ��Ӧ���������Ҫ����
	reg [1:0] ar_resp_cnt;
	reg [1:0] aw_resp_cnt;
	reg [1:0] wd_resp_cnt;
	// ���ݼĴ�����0-ָ��SRAM�Ĵ�����1-����SRAM�Ĵ���������id������
	reg [31:0] buf_rdata [1:0];
	// ������ص��ж��ź�
	wire read_block;
	// ���ɼĴ���
    reg  [ 3:0] rid_r;

	localparam  IDLE = 5'b1;         //����״̬������IDLE״̬  
//--------------------------------state machine for read req channel-------------------------------------------
    //������ͨ��״̬����������
    localparam  AR_REQ_START  	= 3'b010,
				AR_REQ_END		= 3'b100;
	//������ͨ��״̬��ʱ���߼�
	always @(posedge aclk) begin
		if(~aresetn)
			ar_current_state <= IDLE;
		else 
			ar_current_state <= ar_next_state;
	end
	//������ͨ��״̬����̬����߼�
	always @(*) begin
		case(ar_current_state)
			IDLE:begin
				if(~aresetn | read_block)
					ar_next_state = IDLE;
				else if(data_sram_req & ~data_sram_wr | inst_sram_req & ~inst_sram_wr)
					ar_next_state = AR_REQ_START;
				else
					ar_next_state = IDLE;
			end
			AR_REQ_START:begin
				if(arvalid & arready) 
					ar_next_state = AR_REQ_END;
				else 
					ar_next_state = AR_REQ_START;
			end
			AR_REQ_END:begin
				ar_next_state = IDLE;
			end
		endcase
	end
//--------------------------------state machine for read response channel-------------------------------------------
    //����Ӧͨ��״̬����������
    localparam  R_DATA_START   	= 3'b010,
				R_DATA_END		= 3'b100;
    //����Ӧͨ��״̬��ʱ���߼�
	always @(posedge aclk) begin
		if(~aresetn)
			r_current_state <= IDLE;
		else 
			r_current_state <= r_next_state;
	end
	//����Ӧͨ��״̬����̬����߼�
	always @(*) begin
		case(r_current_state)
			IDLE:begin
				if(aresetn & arvalid & arready | (|ar_resp_cnt))
					r_next_state = R_DATA_START;
				else
					r_next_state = IDLE;
			end
			R_DATA_START:begin
				if(rvalid & rready & rlast) 	// �������
					r_next_state = R_DATA_END;
				else
					r_next_state = R_DATA_START;
			end
			R_DATA_END:
				r_next_state = IDLE;
			default:
				r_next_state = IDLE;
		endcase
	end
//--------------------------------state machine for write req & data channel-------------------------------------------
    //д����&д����ͨ��״̬����������
	localparam  W_REQ_START      		= 5'b00010,
				W_ADDR_RESP				= 5'b00100,
				W_DATA_RESP      		= 5'b01000,
				W_REQ_END				= 5'b10000;
    //д����&д����ͨ��״̬��ʱ���߼�
	always @(posedge aclk) begin
		if(~aresetn)
			w_current_state <= IDLE;
		else 
			w_current_state <= w_next_state;
	end
	//д����&д����ͨ��״̬����̬����߼�
	always @(*) begin
		case(w_current_state)
			IDLE:begin
				if(~aresetn)
					w_next_state = IDLE;
				else if(data_sram_wr)
					w_next_state = W_REQ_START;
				else
					w_next_state = IDLE;
			end
			W_REQ_START:
				if(awvalid & awready & wvalid & wready | (|aw_resp_cnt)&(|wd_resp_cnt))
					w_next_state = W_REQ_END;
				else if(awvalid & awready | (|aw_resp_cnt))
					w_next_state = W_ADDR_RESP;
				else if(wvalid & wready | (|wd_resp_cnt))
					w_next_state = W_DATA_RESP;
				else
					w_next_state = W_REQ_START;
			W_ADDR_RESP:begin
				if(wvalid & wready) 
					w_next_state = W_REQ_END;
				else 
					w_next_state = W_ADDR_RESP;
			end
			W_DATA_RESP:begin
				if(awvalid & awready)
					w_next_state = W_REQ_END;
				else
					w_next_state = W_DATA_RESP;
			end
			W_REQ_END:
				if(bvalid &bvalid)
					w_next_state = IDLE;
				else
					w_next_state = W_REQ_END;
		endcase
	end
//--------------------------------state machine for write response channel-------------------------------------------
    //д��Ӧͨ��״̬����������
    localparam  B_START     = 3'b010,
				B_END		= 3'b100;
    //д��Ӧͨ��״̬��ʱ���߼�
	always @(posedge aclk) begin
		if(~aresetn)
			b_current_state <= IDLE;
		else 
			b_current_state <= b_next_state;
	end
	//д��Ӧͨ��״̬����̬����߼�
	always @(*) begin
		case(b_current_state)
			IDLE:begin
				if(aresetn & bready)
					b_next_state = B_START;
				else
					b_next_state = IDLE;
			end
			B_START:begin
				if(bready & bvalid) 
					b_next_state = B_END;
				else 
					b_next_state = B_START;
			end
			B_END:begin
				b_next_state = IDLE;
			end
		endcase
	end
//-----------------------------------------read req channel---------------------------------------
	assign arvalid = ar_current_state[1];
	always  @(posedge aclk) begin
		if(~aresetn) begin
			arid <= 4'b0;
			araddr <= 32'b0;
			arsize <= 3'b0;
			{arlen, arburst, arlock, arcache, arprot} <= {8'b0, 2'b1, 1'b0, 1'b0, 1'b0};	// ��ֵ
		end
		else if(ar_current_state[0]) begin	// ������״̬��Ϊ����״̬����������
			arid <= {3'b0, data_sram_req & ~data_sram_wr};	// ����RAM����������ָ��RAM
			araddr <= data_sram_req & ~data_sram_wr? data_sram_addr : inst_sram_addr;
			arsize <= data_sram_req & ~data_sram_wr? {1'b0, data_sram_size} : {1'b0, inst_sram_size};
		end
	end

//-----------------------------------------read response channel---------------------------------------
    always @(posedge aclk) begin
		if(~aresetn)
			ar_resp_cnt <= 2'b0;
		else if(arvalid & arready & rvalid & rready)	// ����ַ������channelͬʱ�������
			ar_resp_cnt <= ar_resp_cnt;		
		else if(arvalid & arready)
			ar_resp_cnt <= ar_resp_cnt + 1'b1;
		else if(rvalid & rready)
			ar_resp_cnt <= ar_resp_cnt - 1'b1;
	end
	assign rready = r_current_state[1];
//-----------------------------------------write req channel---------------------------------------
	assign awvalid = w_current_state[1] | w_current_state[3];	// W_REQ_START | W_DATA_RESP

	always  @(posedge aclk) begin
		if(~aresetn) begin
			awaddr <= 32'b0;
			awsize <= 3'b0;
			{awlen, awburst, awlock, awcache, awprot, awid} <= {8'b0, 2'b1, 1'b0, 1'b0, 1'b0, 1'b1};	// ��ֵ
		end
		else if(w_current_state[0]) begin	// д����״̬��Ϊ����״̬����������
			awaddr <= data_sram_wr? data_sram_addr : inst_sram_addr;
			awsize <= data_sram_wr? {1'b0, data_sram_size} : {1'b0, inst_sram_size};
		end
	end
//-----------------------------------------write data channel---------------------------------------
    assign wvalid = w_current_state[1] | w_current_state[2];	// W_REQ_START | W_ADDR_RESP
	always  @(posedge aclk) begin
		if(~aresetn) begin
			wstrb <= 4'b0;
			wdata <= 32'b0;
			{wid, wlast} <= {4'b1, 1'b1};	// ��ֵ
		end
		else if(w_current_state[0]) begin	// д����״̬��Ϊ����״̬����������
			wstrb <= data_sram_wstrb;
			wdata <= data_sram_wdata;
		end
	end
//-----------------------------------------write response channel---------------------------------------
    assign bready = w_current_state[4];
	always @(posedge aclk) begin
		if(~aresetn) begin
			aw_resp_cnt <= 2'b0;
		end
		else if(awvalid & awready)
			aw_resp_cnt <= aw_resp_cnt + {1'b0, ~(bvalid & bready)};
		else if(bvalid & bready) 
			aw_resp_cnt <= aw_resp_cnt - 1'b1;
	end

	always @(posedge aclk) begin
		if(~aresetn) begin
			wd_resp_cnt <= 2'b0;
		end
		else if(wvalid & wready)
			wd_resp_cnt <= wd_resp_cnt + {1'b0, ~(bvalid & bready)};
		else if(bvalid & bready) begin
			wd_resp_cnt <= wd_resp_cnt - 1'b1;
		end
	end
//-----------------------------------------rdata buffer---------------------------------------
	assign read_block = (araddr == awaddr) & (|w_current_state[4:1]) & ~b_current_state[2];	// ��д��ַ��ͬ����д����������δд��
	always @(posedge aclk)begin
		if(!aresetn)
			{buf_rdata[1], buf_rdata[0]} <= 64'b0;
		else if(rvalid & rready)
			buf_rdata[rid] <= rdata;
	end
	assign data_sram_rdata = buf_rdata[1];
	assign data_sram_addr_ok = arid[0] & arvalid & arready | wid[0] & awvalid & awready ; 
	assign data_sram_data_ok = rid_r[0] & r_current_state[2] | bid[0] & bvalid & bready; 
	
	assign inst_sram_rdata = buf_rdata[0];
	assign inst_sram_data_ok = ~rid_r[0] & r_current_state[2] | ~bid[0] & bvalid & bready; // rvalid & rready����һ��
	assign inst_sram_addr_ok = ~arid[0] & arvalid & arready;

	// data_ok ��������������Ϊ��Ҫ��buffer�������ݣ���Ҫ�ȵ���һ��
	// assign inst_sram_data_ok = ~rid[0] & rvalid & rready;

	always @(posedge aclk)  begin
		if(~aresetn)
			rid_r <= 4'b0;
		else if(rvalid & rready)
			rid_r <= rid;
	end	
endmodule

module IFreg(
    input  wire   clk,
    input  wire   resetn,
    // inst sram interface
    output wire         inst_sram_req,
    output wire         inst_sram_wr,
    output wire [ 1:0]  inst_sram_size,
    output wire [ 3:0]  inst_sram_wstrb,
    output wire [31:0]  inst_sram_addr,
    output wire [31:0]  inst_sram_wdata,
    input  wire         inst_sram_addr_ok,
    input  wire         inst_sram_data_ok,
    input  wire [31:0]  inst_sram_rdata,
    input  wire [ 3:0]  axi_arid,
    // ds to fs interface
    input  wire         ds_allowin,
    input  wire [33:0]  br_zip,
    // fs to ds interface
    output wire         fs2ds_valid,
    output wire [`FS2DS_LEN -1:0]  fs2ds_bus,
    // exception interface
    input  wire         wb_ex,
    input  wire         ertn_flush,
    input  wire [31:0]  ex_entry,
    input  wire [31:0]  ertn_entry
);
    wire        pf_ready_go;
    wire        to_fs_valid;
    reg         pf_block;
    reg         fs_valid;
    wire        fs_ready_go;
    wire        fs_allowin;

    wire [31:0] seq_pc;
    wire [31:0] nextpc;

    wire         br_stall;
    wire         br_taken;
    wire [31:0]  br_target;
    reg          br_taken_r;
    reg          wb_ex_r;
    reg          ertn_flush_r;
    reg  [31:0]  br_target_r;
    reg  [31:0]  ex_entry_r;
    reg  [31:0]  ertn_entry_r;

    assign {br_stall, br_taken, br_target} = br_zip;

    wire [31:0] fs_inst;
    reg  [31:0] fs_pc;
    reg  [31:0] fs_inst_buf;
    reg         inst_buf_valid;  // �ж�ָ����Ƿ���Ч

    wire        fs_cancel;
    wire        pf_cancel;
    reg         inst_discard;   // �ж�cancel֮���Ƿ���Ҫ����һ��ָ��

    wire        fs_except_adef;

    assign fs_except_adef = (|fs_pc[1:0]) & fs_valid;
//------------------------------pre-IF signal---------------------------------------
    assign pf_ready_go      = inst_sram_req & inst_sram_addr_ok; 
    assign to_fs_valid      = pf_ready_go & ~pf_cancel & ~pf_block;
    assign seq_pc           = fs_pc + 3'h4;  
    assign nextpc           = wb_ex_r? ex_entry_r: wb_ex? ex_entry:
                              ertn_flush_r? ertn_entry_r: ertn_flush? ertn_entry:
                              br_taken_r? br_target_r: br_taken ? br_target : seq_pc;
    always @(posedge clk) begin
        if(~resetn) begin
            {wb_ex_r, ertn_flush_r, br_taken_r} <= 3'b0;
            {ex_entry_r, ertn_entry_r, br_target_r} <= {3{32'b0}};
        end
        else if(wb_ex) begin
            ex_entry_r <= ex_entry;
            wb_ex_r <= 1'b1;
        end
        else if(ertn_flush) begin
            ertn_entry_r <= ertn_entry;
            ertn_flush_r <= 1'b1;
        end    
        else if(br_taken) begin
            br_target_r <= br_target;
            br_taken_r <= 1'b1;
        end
        // ����Ӧ��ַ�Ѿ����������ָ��SRAM��ok������nextpc���ٴӼĴ�����ȡ
        else if(pf_ready_go) begin
            {wb_ex_r, ertn_flush_r, br_taken_r} <= 3'b0;
        end
    end
    always @(posedge clk) begin
        if(~resetn)
            pf_block <= 1'b0;
        else if(pf_cancel & ~pf_block & ~axi_arid[0])
            pf_block <= 1'b1;
        else if(inst_sram_data_ok)
            pf_block <= 1'b0;
    end
//------------------------------IF signal---------------------------------------
    assign fs_ready_go      = (inst_sram_data_ok | inst_buf_valid) & ~inst_discard;
    assign fs_allowin       = ~fs_valid | fs_ready_go & ds_allowin;     
    assign fs2ds_valid      = fs_valid & fs_ready_go;
    always @(posedge clk) begin
        if(~resetn)
            fs_valid <= 1'b0;
        else if(fs_allowin)
            fs_valid <= to_fs_valid; // ��reset��������һ��ʱ�������زſ�ʼȡָ
        else if(fs_cancel)
            fs_valid <= 1'b0;
    end
//------------------------------inst sram interface---------------------------------------
    assign inst_sram_req    = fs_allowin & resetn & ~br_stall & ~pf_block;
    assign inst_sram_wr     = |inst_sram_wstrb;
    assign inst_sram_wstrb  = 4'b0;
    assign inst_sram_addr   = nextpc;
    assign inst_sram_wdata  = 32'b0;
    assign inst_sram_size   = 3'b0;
//------------------------------cancel relevant---------------------------------------
    assign fs_cancel = wb_ex | ertn_flush | br_taken;
    // assign pf_cancel = 1'b0;       // pre-IF���豻cancel��ԭ�����ڸ���nextpcʱ��ֵ������ȷ��
    assign pf_cancel = fs_cancel;
    always @(posedge clk) begin
        if(~resetn)
            inst_discard <= 1'b0;
        // ��ˮ��ȡ������pre-IF�׶η��ʹ����ַ�����ѱ�ָ��SRAM���� or IF������Чָ�������ڵȴ����ݷ���ʱ����Ҫ����һ��ָ��
        else if(fs_cancel & ~fs_allowin & ~fs_ready_go | pf_cancel & inst_sram_req)
            inst_discard <= 1'b1;
        else if(inst_discard & inst_sram_data_ok)
            inst_discard <= 1'b0;
    end
//------------------------------fs and ds state interface---------------------------------------

    always @(posedge clk) begin
        if(~resetn)
            fs_pc <= 32'h1BFF_FFFC;
        else if(to_fs_valid & fs_allowin)
            fs_pc <= nextpc;
    end
    // ���üĴ������ݴ�ָ�����valid�źű�ʾ����ָ���Ƿ���Ч
    always @(posedge clk) begin
        if(~resetn) begin
            fs_inst_buf <= 32'b0;
            inst_buf_valid <= 1'b0;
        end
        else if(fs2ds_valid & ds_allowin)   // �����Ѿ�������һ��ˮ��
            inst_buf_valid <= 1'b0;
        else if(fs_cancel)                  // IFȡ������Ҫ��յ�ǰbuffer
            inst_buf_valid <= 1'b0;
        else if(~inst_buf_valid & inst_sram_data_ok & ~inst_discard) begin
            fs_inst_buf <= fs_inst;
            inst_buf_valid <= 1'b1;
        end
    end
    assign fs_inst    = inst_buf_valid ? fs_inst_buf : inst_sram_rdata;
    assign fs2ds_bus = {fs_except_adef ,fs_inst, fs_pc}; // 1+32+32
endmodule

module IDreg(
    input  wire        clk,
    input  wire        resetn,
    // fs and ds interface
    input  wire                   fs2ds_valid,
    output wire                   ds_allowin,
    output wire [33:0]            br_zip,
    input  wire [`FS2DS_LEN -1:0] fs2ds_bus,
    // ds and es interface
    input  wire                   es_allowin,
    output wire                   ds2es_valid,
    output wire [`DS2ES_LEN -1:0] ds2es_bus,
    // signals to determine whether conflict occurs
    input  wire [37:0] ws_rf_zip, // {ws_rf_we, ws_rf_waddr, ws_rf_wdata}
    input  wire [39:0] ms_rf_zip, // {ms_csr_re, ms_rf_we, ms_rf_waddr, ms_rf_wdata}
    input  wire [39:0] es_rf_zip, // {es_csr_re, es_res_from_mem, es_rf_we, es_rf_waddr, es_alu_result}
    // exception interface
    input  wire        has_int,
    input  wire        wb_ex
);

    wire        ds_ready_go;
    reg         ds_valid;
    reg  [31:0] ds_inst;
    wire        ds_stall;
    wire        br_stall;

    wire [18:0] ds_alu_op;
    wire [31:0] ds_alu_src1   ;
    wire [31:0] ds_alu_src2   ;
    wire        ds_src1_is_pc;
    wire        ds_src2_is_imm;
    wire        ds_res_from_mem;
    reg  [31:0] ds_pc;
    wire [31:0] ds_rkd_value;

    wire        dst_is_r1;
    wire        dst_is_rj;
    wire        gr_we;
    wire        ds_src_reg_is_rd;
    wire        rj_eq_rd;
    wire        rj_ge_rd_u;
    wire        rj_ge_rd;
    wire [4: 0] dest;
    wire [31:0] rj_value;
    wire [31:0] rkd_value;
    wire [31:0] imm;
    wire [31:0] br_offs;
    wire [31:0] jirl_offs;
    wire        br_taken;
    wire [31:0] br_target;

    wire [ 5:0] op_31_26;
    wire [ 3:0] op_25_22;
    wire [ 1:0] op_21_20;
    wire [ 4:0] op_19_15;
    wire [ 4:0] rd;
    wire [ 4:0] rj;
    wire [ 4:0] rk;
    wire [11:0] i12;
    wire [19:0] i20;
    wire [15:0] i16;
    wire [25:0] i26;

    wire [63:0] op_31_26_d;
    wire [15:0] op_25_22_d;
    wire [ 3:0] op_21_20_d;
    wire [31:0] op_19_15_d;
//������ָ��
    wire        inst_rdcntid;
    wire        inst_rdcntvl;
    wire        inst_rdcntvh;
//�������߼�����
    wire        inst_add_w;
    wire        inst_sub_w;
    wire        inst_slti;
    wire        inst_slt;
    wire        inst_sltui;
    wire        inst_sltu;
    wire        inst_nor;
    wire        inst_and;
    wire        inst_andi;
    wire        inst_or;
    wire        inst_ori;
    wire        inst_xor;
    wire        inst_xori;
    wire        inst_sll_w;
    wire        inst_slli_w;
    wire        inst_srl_w;
    wire        inst_srli_w;
    wire        inst_sra_w;
    wire        inst_srai_w;
    wire        inst_addi_w;
//�ô�ָ��
    wire        inst_ld_b;
    wire        inst_ld_h;
    wire        inst_ld_w;
    wire        inst_ld_bu;
    wire        inst_ld_hu;
    wire        inst_st_b;
    wire        inst_st_h;
    wire        inst_st_w;
//ת��ָ��
    wire        inst_jirl;
    wire        inst_b;
    wire        inst_bl;
    wire        inst_blt;
    wire        inst_bge;
    wire        inst_bltu;
    wire        inst_bgeu;
    wire        inst_beq;
    wire        inst_bne;

    wire        inst_lu12i_w;
    wire        inst_pcaddul2i;
//���������߼�����
    wire        inst_mul_w;
    wire        inst_mulh_w;
    wire        inst_mulh_wu;
    wire        inst_div_w;
    wire        inst_div_wu;
    wire        inst_mod_w;
    wire        inst_mod_wu;
//ϵͳ�����쳣֧��ָ��
    wire        inst_csrrd;
    wire        inst_csrwr;
    wire        inst_csrxchg;
    wire        inst_ertn;
    wire        inst_syscall;
    wire        inst_break;

    wire        type_al;        // �����߼��࣬arithmatic or logic
    wire        type_ld_st;     // �ô��࣬ load or store
    wire        type_bj;        // ��֧��ת�࣬branch or jump
    wire        type_ex;        // ��������࣬exception
    wire        type_else;      // ��֪��ɶ��
    
    wire        need_ui5;
    wire        need_ui12;
    wire        need_si12;
    wire        need_si16;
    wire        need_si20;
    wire        need_si26;
    wire        src2_is_4;


    wire [ 4:0] rf_raddr1;
    wire [31:0] rf_rdata1;
    wire [ 4:0] rf_raddr2;
    wire [31:0] rf_rdata2;

    wire        conflict_r1_wb;
    wire        conflict_r2_wb;
    wire        conflict_r1_mem;
    wire        conflict_r2_mem;
    wire        conflict_r1_exe;
    wire        conflict_r2_exe;
    reg         conflict_r1_wb_r;
    reg         conflict_r2_wb_r;
    reg         conflict_r1_mem_r;
    reg         conflict_r2_mem_r;
    reg         conflict_r1_exe_r;
    reg         conflict_r2_exe_r;

    wire        need_r1;
    wire        need_r2;

    wire        ws_rf_we   ;
    wire [ 4:0] ws_rf_waddr;
    wire [31:0] ws_rf_wdata;
    wire        ms_rf_we   ;
    wire        ms_csr_re  ;
    wire [ 4:0] ms_rf_waddr;
    wire [31:0] ms_rf_wdata;
    wire        es_rf_we   ;
    wire        es_csr_re  ;
    wire [ 4:0] es_rf_waddr;
    wire [31:0] es_rf_wdata;
    wire        es_res_from_mem;
    wire        ms_res_from_mem;
    wire        ms2ws_valid;

    wire        ds_rf_we   ;
    wire [ 4:0] ds_rf_waddr;

    reg         ds_except_adef;
    wire        ds_except_sys;
    wire        ds_except_brk;
    wire        ds_except_ine;
    wire        ds_except_int;
    wire        ds_csr_re;
    wire [13:0] ds_csr_num;
    wire        ds_csr_we;
    wire [31:0] ds_csr_wmask;
    wire [31:0] ds_csr_wvalue;
    wire [ 6:0] ds_rf_zip;
    wire [ 7:0] ds_mem_inst_zip;
    wire [ 1:0] ds_cnt_inst_zip;
    wire [78:0] ds_csr_zip; // {ds_csr_num, ds_csr_wmask, ds_csr_wvalue, ds_csr_we}
    wire [ 5:0] ds_except_zip;  // { ds_except_adef, ds_except_ine, ds_except_int, ds_except_brk, ds_except_sys, inst_ertn}
//------------------------------state control signal---------------------------------------
    assign ds_ready_go      = ~ds_stall;
    assign ds_allowin       = ~ds_valid | ds_ready_go & es_allowin; 
    assign ds_stall         = (es_res_from_mem|es_csr_re) & (conflict_r1_exe & need_r1| conflict_r2_exe & need_r2)|
                              (ms_res_from_mem|ms_csr_re) & (conflict_r1_mem & need_r1| conflict_r2_mem & need_r2);    
    assign br_stall         = ds_stall & type_bj;
    assign ds2es_valid      = ds_valid & ds_ready_go;
    always @(posedge clk) begin
        if(~resetn)
            ds_valid <= 1'b0;
        else if(wb_ex)
            ds_valid <= 1'b0;
        else if(br_taken)
            ds_valid <= 1'b0;
        else if(ds_allowin)
            ds_valid <= fs2ds_valid;
    end

//------------------------------if and id state interface---------------------------------------
    always @(posedge clk) begin
        if(~resetn)
            {ds_except_adef, ds_inst, ds_pc} <= 64'b0;
        if(fs2ds_valid & ds_allowin) begin
            {ds_except_adef, ds_inst, ds_pc} <= fs2ds_bus;
        end
    end

    assign rj_eq_rd = rj_value == rkd_value;
    assign rj_ge_rd = ($signed(rj_value) >= $signed(rkd_value));
    assign rj_ge_rd_u = ($unsigned(rj_value) >= $unsigned(rkd_value));
    assign br_taken = (inst_beq  &  rj_eq_rd
                    | inst_bne   & !rj_eq_rd
                    | inst_bge   &  rj_ge_rd
                    | inst_blt   & !rj_ge_rd
                    | inst_bgeu  &  rj_ge_rd_u
                    | inst_bltu  & !rj_ge_rd_u
                    | inst_jirl
                    | inst_bl
                    | inst_b
                    ) & ds_valid & ~br_stall;
    assign br_target = (inst_beq || inst_bne || inst_bl || inst_b || 
                        inst_bge || inst_bgeu|| inst_blt|| inst_bltu) ? (ds_pc + br_offs) :
                                                    /*inst_jirl*/ (rj_value + jirl_offs);
    assign br_zip = {br_stall, br_taken, br_target}; 
//------------------------------decode instruction---------------------------------------
    
    assign op_31_26  = ds_inst[31:26];
    assign op_25_22  = ds_inst[25:22];
    assign op_21_20  = ds_inst[21:20];
    assign op_19_15  = ds_inst[19:15];

    assign rd   = ds_inst[ 4: 0];
    assign rj   = ds_inst[ 9: 5];
    assign rk   = ds_inst[14:10];

    assign i12  = ds_inst[21:10];
    assign i20  = ds_inst[24: 5];
    assign i16  = ds_inst[25:10];
    assign i26  = {ds_inst[ 9: 0], ds_inst[25:10]};


    decoder_6_64 u_dec0(.in(op_31_26 ), .out(op_31_26_d ));
    decoder_4_16 u_dec1(.in(op_25_22 ), .out(op_25_22_d ));
    decoder_2_4  u_dec2(.in(op_21_20 ), .out(op_21_20_d ));
    decoder_5_32 u_dec3(.in(op_19_15 ), .out(op_19_15_d ));

    assign inst_rdcntid = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h0] & op_19_15_d[5'h00] & (rk == 5'h18) & (rd == 5'h00);
    assign inst_rdcntvl = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h0] & op_19_15_d[5'h00] & (rk == 5'h18) & (rj == 5'h00);
    assign inst_rdcntvh = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h0] & op_19_15_d[5'h00] & (rk == 5'h19) & (rj == 5'h00);
    
    assign inst_add_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h00];
    assign inst_sub_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h02];
    assign inst_slt    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h04];
    assign inst_sltu   = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h05];
    assign inst_nor    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h08];
    assign inst_and    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h09];
    assign inst_or     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0a];
    assign inst_xor    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0b];
    
    assign inst_sll_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0e];
    assign inst_srl_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0f];
    assign inst_sra_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h10];
    
    assign inst_mul_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h18];
    assign inst_mulh_w = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h19];
    assign inst_mulh_wu= op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h1a];
    assign inst_div_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h00];
    assign inst_mod_w  = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h01];
    assign inst_div_wu = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h02];
    assign inst_mod_wu = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h03];

    assign inst_break   = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h14];
    assign inst_syscall = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h2] & op_19_15_d[5'h16];

    assign inst_slli_w = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h01];
    assign inst_srli_w = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h09];
    assign inst_srai_w = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h11];
    assign inst_slti   = op_31_26_d[6'h00] & op_25_22_d[4'h8];
    assign inst_sltui  = op_31_26_d[6'h00] & op_25_22_d[4'h9];
    assign inst_addi_w = op_31_26_d[6'h00] & op_25_22_d[4'ha];
    assign inst_andi   = op_31_26_d[6'h00] & op_25_22_d[4'hd];
    assign inst_ori    = op_31_26_d[6'h00] & op_25_22_d[4'he];
    assign inst_xori   = op_31_26_d[6'h00] & op_25_22_d[4'hf];

    assign inst_ld_b    = op_31_26_d[6'h0a] & op_25_22_d[4'h0];
    assign inst_ld_h    = op_31_26_d[6'h0a] & op_25_22_d[4'h1];
    assign inst_ld_w    = op_31_26_d[6'h0a] & op_25_22_d[4'h2];
    assign inst_st_b    = op_31_26_d[6'h0a] & op_25_22_d[4'h4];
    assign inst_st_h    = op_31_26_d[6'h0a] & op_25_22_d[4'h5];
    assign inst_st_w    = op_31_26_d[6'h0a] & op_25_22_d[4'h6];
    assign inst_ld_bu   = op_31_26_d[6'h0a] & op_25_22_d[4'h8];
    assign inst_ld_hu   = op_31_26_d[6'h0a] & op_25_22_d[4'h9];

    assign inst_jirl   = op_31_26_d[6'h13];
    assign inst_b      = op_31_26_d[6'h14];
    assign inst_bl     = op_31_26_d[6'h15];
    assign inst_beq    = op_31_26_d[6'h16];
    assign inst_bne    = op_31_26_d[6'h17];
    assign inst_blt     = op_31_26_d[6'h18];
    assign inst_bge     = op_31_26_d[6'h19];
    assign inst_bltu    = op_31_26_d[6'h1a];
    assign inst_bgeu    = op_31_26_d[6'h1b];
    assign inst_lu12i_w   = op_31_26_d[6'h05] & ~ds_inst[25];
    assign inst_pcaddul2i = op_31_26_d[6'h07] & ~ds_inst[25];

    assign inst_csrrd   = op_31_26_d[6'h01] & (op_25_22[3:2] == 2'b0) & (rj == 5'h00);
    assign inst_csrwr   = op_31_26_d[6'h01] & (op_25_22[3:2] == 2'b0) & (rj == 5'h01);
    assign inst_csrxchg = op_31_26_d[6'h01] & (op_25_22[3:2] == 2'b0) & ~inst_csrrd & ~inst_csrwr;

    assign inst_ertn    = op_31_26_d[6'h01] & op_25_22_d[4'h9] & op_21_20_d[2'h0] & op_19_15_d[5'h10] 
                        & (rk == 5'h0e) & (~|rj) & (~|rd);

    // ָ�����
    assign type_al    = inst_add_w  | inst_sub_w  | inst_slti   | inst_slt   | inst_sltui  | inst_sltu  |
                        inst_nor    | inst_and    | inst_andi   | inst_or    | inst_ori    | inst_xor   |
                        inst_xori   | inst_sll_w  | inst_slli_w | inst_srl_w | inst_srli_w | inst_sra_w | inst_srai_w | inst_addi_w|
                        // ������������
                        inst_mul_w  | inst_mulh_w | inst_mulh_wu| inst_div_w | inst_div_wu | inst_mod_w |
                        inst_mod_wu;
    assign type_ld_st = inst_ld_b   | inst_ld_h   | inst_ld_w   | inst_ld_bu | inst_ld_hu  | inst_st_b  |
                        inst_st_h   | inst_st_w;
    assign type_bj    = inst_jirl   | inst_b      | inst_bl     | inst_blt   | inst_bge    | inst_bltu  |
                        inst_bgeu   | inst_beq    | inst_bne;
    assign type_ex    = inst_csrrd  | inst_csrwr  | inst_csrxchg| inst_ertn  | inst_syscall| inst_break |
                        inst_rdcntid;
    assign type_else  = inst_rdcntvh| inst_rdcntvl| inst_lu12i_w| inst_pcaddul2i; 

    // alu����������
    assign ds_alu_op[ 0] = inst_add_w | inst_addi_w | inst_ld_w | inst_ld_hu |
                        inst_ld_h  | inst_ld_bu  | inst_ld_b | inst_st_b  | 
                        inst_st_w  | inst_st_h   | inst_jirl | inst_bl    | 
                        inst_pcaddul2i;
    assign ds_alu_op[ 1] = inst_sub_w | inst_bne | inst_beq;
    assign ds_alu_op[ 2] = inst_slt | inst_slti | inst_blt | inst_bge;
    assign ds_alu_op[ 3] = inst_sltu | inst_sltui | inst_bltu | inst_bgeu;
    assign ds_alu_op[ 4] = inst_and | inst_andi;
    assign ds_alu_op[ 5] = inst_nor;
    assign ds_alu_op[ 6] = inst_or | inst_ori;
    assign ds_alu_op[ 7] = inst_xor | inst_xori;
    assign ds_alu_op[ 8] = inst_slli_w | inst_sll_w;
    assign ds_alu_op[ 9] = inst_srli_w | inst_srl_w;
    assign ds_alu_op[10] = inst_srai_w | inst_sra_w;
    assign ds_alu_op[11] = inst_lu12i_w;
    assign ds_alu_op[12] = inst_mul_w ;
    assign ds_alu_op[13] = inst_mulh_w;
    assign ds_alu_op[14] = inst_mulh_wu;
    assign ds_alu_op[15] = inst_div_w;
    assign ds_alu_op[16] = inst_div_wu;
    assign ds_alu_op[17] = inst_mod_w;
    assign ds_alu_op[18] = inst_mod_wu;


    assign need_ui5   =  inst_slli_w | inst_srli_w | inst_srai_w;
    assign need_ui12  =  inst_andi   | inst_ori | inst_xori ;
    assign need_si12  =  inst_slti    | inst_sltui  | inst_addi_w |
                         inst_ld_w    | inst_ld_b   | inst_ld_h   | 
                         inst_ld_bu   | inst_ld_hu  |inst_st_w    | 
                         inst_st_b    | inst_st_h;
    // assign need_si16  =  inst_jirl | inst_beq | inst_bne;
    assign need_si20  =  inst_lu12i_w | inst_pcaddul2i;
    assign need_si26  =  inst_b | inst_bl;
    assign src2_is_4  =  inst_jirl | inst_bl;

    assign imm = src2_is_4 ? 32'h4                      :
                need_si20 ? {i20[19:0], 12'b0}         :
                (need_ui5 || need_si12) ? {{20{i12[11]}}, i12[11:0]} :
                {20'b0, i12[11:0]};

    assign br_offs = need_si26 ? {{ 4{i26[25]}}, i26[25:0], 2'b0} :
                                {{14{i16[15]}}, i16[15:0], 2'b0} ;

    assign jirl_offs = {{14{i16[15]}}, i16[15:0], 2'b0};

    assign ds_src_reg_is_rd = inst_beq | inst_bne  | inst_blt | inst_bltu | 
                           inst_bge | inst_bgeu | inst_st_w| inst_st_h |
                           inst_st_b| inst_csrwr| inst_csrxchg;

    assign ds_src1_is_pc    = inst_jirl | inst_bl | inst_pcaddul2i;

    assign ds_src2_is_imm   = inst_slli_w |
                        inst_srli_w |
                        inst_srai_w |
                        inst_addi_w |
                        inst_ld_w   |
                        inst_ld_b   |
                        inst_ld_bu  |
                        inst_ld_h   |
                        inst_ld_hu  |
                        inst_st_w   |
                        inst_st_b   |
                        inst_st_h   |
                        inst_lu12i_w|
                        inst_jirl   |
                        inst_bl     |
                        inst_pcaddul2i|
                        inst_andi   |
                        inst_ori    |
                        inst_xori   |
                        inst_slti   |
                        inst_sltui;

    assign ds_alu_src1 = ds_src1_is_pc  ? ds_pc[31:0] : rj_value;
    assign ds_alu_src2 = ds_src2_is_imm ? imm : rkd_value;

    assign ds_res_from_mem  = inst_ld_w | inst_ld_h | inst_ld_hu | inst_ld_b | inst_ld_bu;
    assign ds_rkd_value  = rkd_value;
    assign dst_is_r1     = inst_bl;
    assign dst_is_rj     = inst_rdcntid;
    assign gr_we         = ~inst_st_w & ~inst_st_h & ~inst_st_b & ~inst_beq  & 
                           ~inst_bne  & ~inst_b    & ~inst_bge  & ~inst_bgeu & 
                           ~inst_blt  & ~inst_bltu & ~inst_syscall; 
    assign dest          = dst_is_r1 ? 5'd1 : 
                           dst_is_rj ? rj   : rd;

//------------------------------regfile control---------------------------------------
    assign rf_raddr1 = rj;
    assign rf_raddr2 = ds_src_reg_is_rd ? rd :rk;
    assign ds_rf_we    = gr_we & ds_valid; 
    assign ds_rf_waddr = dest; 
    assign ds_rf_zip   = {ds_csr_re, ds_rf_we, ds_rf_waddr};
    //д�ء��ô桢ִ�н׶δ������ݴ���
    assign {ws_rf_we, ws_rf_waddr, ws_rf_wdata} = ws_rf_zip;
    assign {ms_res_from_mem, ms_csr_re, ms_rf_we, ms_rf_waddr, ms_rf_wdata} = ms_rf_zip;
    assign {es_csr_re, es_res_from_mem, es_rf_we, es_rf_waddr, es_rf_wdata} = es_rf_zip;
    regfile u_regfile(
    .clk    (clk      ),
    .raddr1 (rf_raddr1),
    .rdata1 (rf_rdata1),
    .raddr2 (rf_raddr2),
    .rdata2 (rf_rdata2),
    .we     (ws_rf_we    ),
    .waddr  (ws_rf_waddr ),
    .wdata  (ws_rf_wdata )
    );
    // ��ͻ��дʹ�� + д��ַ��Ϊ0�żĴ��� + д��ַ�뵱ǰ���Ĵ�����ַ��ͬ
    assign conflict_r1_wb = (|rf_raddr1) & (rf_raddr1 == ws_rf_waddr) & ws_rf_we;
    assign conflict_r2_wb = (|rf_raddr2) & (rf_raddr2 == ws_rf_waddr) & ws_rf_we;
    assign conflict_r1_mem = (|rf_raddr1) & (rf_raddr1 == ms_rf_waddr) & ms_rf_we;
    assign conflict_r2_mem = (|rf_raddr2) & (rf_raddr2 == ms_rf_waddr) & ms_rf_we;
    assign conflict_r1_exe = (|rf_raddr1) & (rf_raddr1 == es_rf_waddr) & es_rf_we;
    assign conflict_r2_exe = (|rf_raddr2) & (rf_raddr2 == es_rf_waddr) & es_rf_we;
    assign need_r1         = ~ds_src1_is_pc & (|ds_alu_op);
    assign need_r2         = ~ds_src2_is_imm & (|ds_alu_op);
    // �üĴ��������ͻ��Ϣ
    // always @(posedge clk) begin
    //     if(~ds_ready_go) begin
    //         if(conflict_r1_exe)
    //             conflict_r1_exe_r <= 1'b1;
    //         if(conflict_r2_exe)
    //             conflict_r2_exe_r <= 1'b1;
    //         if(conflict_r1_mem)
    //             conflict_r1_mem_r <= 1'b1;
    //         if(conflict_r2_mem)
    //             conflict_r2_mem_r <= 1'b1;
    //         if(conflict_r1_wb)
    //             conflict_r1_wb_r <= 1'b1;
    //         if(conflict_r2_wb)
    //             conflict_r2_wb_r <= 1'b1;
    //     end
    //     else if(fs2ds_valid & ds_allowin) begin
    //         conflict_r1_exe_r <= 1'b0;
    //         conflict_r2_exe_r <= 1'b0;
    //         conflict_r1_mem_r <= 1'b0;
    //         conflict_r2_mem_r <= 1'b0;
    //         conflict_r1_wb_r <= 1'b0;
    //         conflict_r2_wb_r <= 1'b0;
    //     end
    // end
    // ���ݳ�ͻʱ�������Ⱥ�˳�������һ�θ���Ϊ׼
    assign rj_value  =  conflict_r1_exe ? es_rf_wdata:
                        conflict_r1_mem ? ms_rf_wdata:
                        conflict_r1_wb  ? ws_rf_wdata : rf_rdata1; 
    assign rkd_value =  conflict_r2_exe ? es_rf_wdata:
                        conflict_r2_mem ? ms_rf_wdata:
                        conflict_r2_wb  ? ws_rf_wdata : rf_rdata2; 
    // assign rj_value  =  (conflict_r1_exe|conflict_r1_exe_r) ? es_rf_wdata:
    //                     (conflict_r1_mem|conflict_r1_mem_r) ? ms_rf_wdata:
    //                     (conflict_r1_wb |conflict_r1_wb_r)  ? ws_rf_wdata : rf_rdata1; 
    // assign rkd_value =  (conflict_r2_exe|conflict_r2_exe_r) ? es_rf_wdata:
    //                     (conflict_r2_mem|conflict_r2_mem_r) ? ms_rf_wdata:
    //                     (conflict_r2_wb |conflict_r2_wb_r)  ? ws_rf_wdata : rf_rdata2; 
    assign ds_mem_inst_zip =    {inst_st_b, inst_st_h, inst_st_w, inst_ld_b, 
                                inst_ld_bu,inst_ld_h, inst_ld_hu, inst_ld_w};
    assign ds_cnt_inst_zip =    {inst_rdcntvh , inst_rdcntvl}; // ��ȡ����exe�ڲ��ļ���������״̬�Ĵ���TID�еļ���
//------------------------------exception relavant--------------------------------------
    assign ds_csr_re    = inst_csrrd | inst_csrwr | inst_csrxchg | inst_rdcntid;
    assign ds_csr_we    = inst_csrwr | inst_csrxchg;
    assign ds_csr_wmask    = {32{inst_csrxchg}} & rj_value | {32{inst_csrwr}};
    assign ds_csr_wvalue   = rkd_value;
    assign ds_csr_num     = {14{inst_rdcntid}} & `CSR_TID | {14{~inst_rdcntid}} & ds_inst[23:10];
    assign ds_csr_zip     = {ds_csr_num, ds_csr_wmask, ds_csr_wvalue, ds_csr_we};

    assign ds_except_sys  = inst_syscall;
    assign ds_except_brk  = inst_break;
    assign ds_except_ine  = ~(type_al | type_bj | type_ld_st | type_else | type_ex) & ds_valid;
    assign ds_except_int  = has_int;
    assign ds_except_zip  = {ds_except_adef, ds_except_ine, // 14+32+32+1+1 
                             ds_except_int , ds_except_brk, ds_except_sys, inst_ertn};    // 1+1+1+1+1

//------------------------------ds to es interface--------------------------------------
    assign ds2es_bus = {ds_alu_op,          //19 bit
                        ds_res_from_mem,    //1  bit
                        ds_alu_src1,        //32 bit
                        ds_alu_src2,        //32 bit
                        ds_rf_zip,          //7  bit
                        ds_rkd_value,       //32 bit
                        ds_pc,              //32 bit
                        ds_mem_inst_zip,    //8  bit
                        ds_cnt_inst_zip,    //2  bit
                        ds_csr_zip,         //79 bit
                        ds_except_zip       //6  bit
                        };

endmodule

module EXEreg(
    input  wire        clk,
    input  wire        resetn,
    // id and exe interface
    output wire        es_allowin,
    input  wire        ds2es_valid,
    input  wire [`DS2ES_LEN -1:0] ds2es_bus,
    // exe and mem state interface
    input  wire        ms_allowin,
    output wire [`ES2MS_LEN -1:0] es2ms_bus,
    output wire [39:0] es_rf_zip, // {es_csr_re, es_res_from_mem, es_rf_we, es_rf_waddr, es_alu_result}
    output wire        es2ms_valid,
    output reg  [31:0] es_pc,    
    // data sram interface
    output wire         data_sram_req,
    output wire         data_sram_wr,
    output wire [ 1:0]  data_sram_size,
    output wire [ 3:0]  data_sram_wstrb,
    output wire [31:0]  data_sram_addr,
    output wire [31:0]  data_sram_wdata,
    input  wire         data_sram_addr_ok,
    // exception interface
    input  wire        ms_ex,
    input  wire        wb_ex
);

    wire        es_ready_go;
    reg         es_valid;

    reg  [18:0] es_alu_op     ;
    reg  [31:0] es_alu_src1   ;
    reg  [31:0] es_alu_src2   ;
    wire [31:0] es_alu_result ; 
    wire        alu_complete  ;
    reg  [31:0] es_rkd_value  ;
    reg         es_res_from_mem;
    wire [ 3:0] es_mem_we     ;
    reg         es_rf_we      ;
    reg  [4 :0] es_rf_waddr   ;
    wire [31:0] es_rf_result_tmp;

    reg  [ 2:0] es_st_op_zip;

    wire        op_ld_h;
    wire        op_ld_w;
    wire        op_ld_hu;
    wire        op_st_b;
    wire        op_st_h;
    wire        op_st_w;

    wire        rd_cnt_h;
    wire        rd_cnt_l;
    reg  [63:0] es_timer_cnt;

    wire        es_cancel;
    wire        es_ex;
    reg         es_csr_re;
    
    reg  [ 4:0] es_ld_inst_zip; // {op_ld_b, op_ld_bu,op_ld_h, op_ld_hu, op_ld_w}
    reg  [ 1:0] es_cnt_inst_zip; // {rd_cnt_h, rd_cnt_l}
    wire        es_except_ale;
    reg  [ 5:0] es_except_zip_tmp;
    wire [ 6:0] es_except_zip;
    reg  [78:0] es_csr_zip;
    wire        es_mem_req;
//------------------------------state control signal---------------------------------------
    assign es_ex            = (|es_except_zip) & es_valid;
    assign es_ready_go      = alu_complete & (~data_sram_req | data_sram_req & data_sram_addr_ok);
    assign es_allowin       = ~es_valid | es_ready_go & ms_allowin;     
    assign es2ms_valid      = es_valid & es_ready_go;
    always @(posedge clk) begin
        if(~resetn)
            es_valid <= 1'b0;
        else if(wb_ex)
            es_valid <= 1'b0;
        else if(es_allowin)
            es_valid <= ds2es_valid; 
    end
//------------------------------id and exe state interface---------------------------------------
    always @(posedge clk) begin
        if(~resetn)
            {es_alu_op, es_res_from_mem, es_alu_src1, es_alu_src2,
             es_csr_re, es_rf_we, es_rf_waddr, es_rkd_value, es_pc, es_st_op_zip, 
             es_ld_inst_zip, es_cnt_inst_zip, es_csr_zip, es_except_zip_tmp} <= {`DS2ES_LEN{1'b0}};
        else if(ds2es_valid & es_allowin)
            {es_alu_op, es_res_from_mem, es_alu_src1, es_alu_src2,
             es_csr_re, es_rf_we, es_rf_waddr, es_rkd_value, es_pc, es_st_op_zip, 
             es_ld_inst_zip, es_cnt_inst_zip, es_csr_zip, es_except_zip_tmp} <= ds2es_bus;    
    end
    // ָ����
    assign {op_ld_h, op_ld_hu, op_ld_w} = es_ld_inst_zip[2:0];
    assign {op_st_b, op_st_h, op_st_w} = es_st_op_zip;
    assign {rd_cnt_h, rd_cnt_l} = es_cnt_inst_zip;
//------------------------------exe timer---------------------------------------
    
    always @(posedge clk) begin
        if(~resetn)
            es_timer_cnt <= 64'b0;
        else   
            es_timer_cnt <= es_timer_cnt + 1'b0;
    end
    
//------------------------------exe and mem state interface---------------------------------------
    assign es_except_ale = ((|es_alu_result[1:0]) & (op_st_w | op_ld_w)|
                            es_alu_result[0] & (op_st_h|op_ld_hu|op_ld_h)) & es_valid;
                            
    assign es_except_zip = {es_except_ale, es_except_zip_tmp};
    assign es2ms_bus = {
                        es_mem_req,         // 1  bit
                        es_ld_inst_zip,     // 5  bit
                        es_pc,              // 32 bit
                        es_csr_zip,         // 79 bit
                        es_except_zip       //  7 bit
                    };
//------------------------------alu interface---------------------------------------
    alu u_alu(
        .clk            (clk       ),
        .resetn         (resetn & ~wb_ex & ~(ds2es_valid & es_allowin)),
        .alu_op         (es_alu_op    ),
        .alu_src1       (es_alu_src1  ),
        .alu_src2       (es_alu_src2  ),
        .alu_result     (es_alu_result),
        .complete       (alu_complete)
    );

//------------------------------data sram interface---------------------------------------
    assign es_cancel        = wb_ex;
    assign es_mem_we[0]     = op_st_w | op_st_h & ~es_alu_result[1] | op_st_b & ~es_alu_result[0] & ~es_alu_result[1];   
    assign es_mem_we[1]     = op_st_w | op_st_h & ~es_alu_result[1] | op_st_b &  es_alu_result[0] & ~es_alu_result[1];   
    assign es_mem_we[2]     = op_st_w | op_st_h &  es_alu_result[1] | op_st_b & ~es_alu_result[0] &  es_alu_result[1];   
    assign es_mem_we[3]     = op_st_w | op_st_h &  es_alu_result[1] | op_st_b &  es_alu_result[0] &  es_alu_result[1];       
    assign es_mem_req       = (es_res_from_mem | (|es_mem_we));
    assign data_sram_req    = es_mem_req & es_valid & ms_allowin;
    assign data_sram_wr     = (|data_sram_wstrb) & es_valid & ~wb_ex & ~ms_ex & ~es_ex;
    assign data_sram_wstrb  =  es_mem_we;
    assign data_sram_size   = {2{op_st_b}} & 2'b0 | {2{op_st_h}} & 2'b1 | {2{op_st_w}} & 2'd2;
    assign data_sram_addr   = es_alu_result;
    assign data_sram_wdata[ 7: 0]   = es_rkd_value[ 7: 0];
    assign data_sram_wdata[15: 8]   = op_st_b ? es_rkd_value[ 7: 0] : es_rkd_value[15: 8];
    assign data_sram_wdata[23:16]   = op_st_w ? es_rkd_value[23:16] : es_rkd_value[ 7: 0];
    assign data_sram_wdata[31:24]   = op_st_w ? es_rkd_value[31:24] : 
                                      op_st_h ? es_rkd_value[15: 8] : es_rkd_value[ 7: 0];
//------------------------------regfile relevant---------------------------------------
    // exe�׶���ʱѡ����д������
    assign es_rf_result_tmp = {32{rd_cnt_h}} & es_timer_cnt[63:32] | 
                              {32{rd_cnt_l}} & es_timer_cnt[31: 0] |
                              {32{~rd_cnt_h & ~rd_cnt_l}} & es_alu_result;
    //��ʱ��Ϊes_rf_wdata����es_rf_result_tmp,ֻ����ld��ָ����Ҫ���⴦��
    assign es_rf_zip       = {es_csr_re & es_valid, es_res_from_mem & es_valid, es_rf_we & es_valid, es_rf_waddr, es_rf_result_tmp};    
endmodule

module MEMreg(
    input  wire        clk,
    input  wire        resetn,
    // exe and mem state interface
    output wire        ms_allowin,
    input  wire [`ES2MS_LEN -1:0] es2ms_bus,
    input  wire [39:0] es_rf_zip, // {es_csr_re, es_res_from_mem, es_rf_we, es_rf_waddr, es_rf_wdata}
    input  wire        es2ms_valid, // {op_ld_b, op_ld_bu,op_ld_h, op_ld_hu, op_ld_w}
    // mem and wb state interface
    input  wire        ws_allowin,
    output wire [`MS2WS_LEN -1:0] ms2ws_bus,
    output wire [39:0] ms_rf_zip, // {ms_rf_we, ms_rf_waddr, ms_rf_wdata}
    output wire        ms2ws_valid,
    // data sram interface
    input  wire         data_sram_data_ok,
    input  wire [31:0]  data_sram_rdata,
    // exception signal
    output wire        ms_ex,
    input  wire        wb_ex   
);
    wire       op_ld_b;
    wire       op_ld_h;
    wire       op_ld_w;
    wire       op_ld_bu;
    wire       op_ld_hu;

    wire        ms_ready_go;
    reg         ms_valid;
    reg  [31:0] ms_rf_result_tmp ; 
    reg         ms_res_from_mem;
    reg         ms_rf_we      ;
    reg         ms_csr_re     ;
    reg  [4 :0] ms_rf_waddr   ;
    reg  [4 :0] ms_ld_inst_zip;
    wire [31:0] ms_rf_wdata   ;
    wire [31:0] ms_mem_result ;
    wire [31:0] shift_rdata   ;

    reg  [ 6:0] ms_except_zip;
    reg  [78:0] ms_csr_zip;
    reg  [31:0] ms_pc;

    wire        ms_wait_data_ok;
    reg         ms_wait_data_ok_r;
    reg  [31:0] ms_data_buf;
    reg         data_buf_valid;  // �ж�ָ����Ƿ���Ч
//------------------------------state control signal---------------------------------------
    assign ms_wait_data_ok  = ms_wait_data_ok_r & ms_valid & ~wb_ex;
    assign ms_ready_go      = ~ms_wait_data_ok | ms_wait_data_ok & data_sram_data_ok;
    assign ms_allowin       = ~ms_valid | ms_ready_go & ws_allowin;     
    assign ms2ws_valid      = ms_valid & ms_ready_go;
    always @(posedge clk) begin
        if(~resetn)
            ms_valid <= 1'b0;
        else if(wb_ex)
            ms_valid <= 1'b0;
        else if(ms_allowin)
            ms_valid <= es2ms_valid; 
    end
    assign ms_ex = (|ms_except_zip) & ms_valid; 
    
//------------------------------data buffer----------------------------------------------
    // ���üĴ������ݴ����ݣ�����valid�źű�ʾ���������Ƿ���Ч
    always @(posedge clk) begin
        if(~resetn) begin
            ms_data_buf <= 32'b0;
            data_buf_valid <= 1'b0;
        end
        else if(ms2ws_valid & ws_allowin)   // �����Ѿ�������һ��ˮ��
            data_buf_valid <= 1'b0;
        else if(~data_buf_valid & data_sram_data_ok & ms_valid) begin
            ms_data_buf <= data_sram_rdata;
            data_buf_valid <= 1'b1;
        end

    end
//------------------------------exe and mem state interface---------------------------------------
    always @(posedge clk) begin
        if(~resetn) begin
            {ms_wait_data_ok_r, ms_ld_inst_zip, ms_pc, ms_csr_zip, ms_except_zip} <= {`ES2MS_LEN{1'b0}};
            {ms_csr_re, ms_res_from_mem, ms_rf_we, ms_rf_waddr, ms_rf_result_tmp} <= 39'b0;
        end
        if(es2ms_valid & ms_allowin) begin
            {ms_wait_data_ok_r, ms_ld_inst_zip, ms_pc, ms_csr_zip, ms_except_zip} <= es2ms_bus;
            {ms_csr_re, ms_res_from_mem, ms_rf_we, ms_rf_waddr, ms_rf_result_tmp} <= es_rf_zip;
        end
    end
//------------------------------mem and wb state interface---------------------------------------
    // ϸ��������
    assign {op_ld_b, op_ld_bu,op_ld_h, op_ld_hu, op_ld_w} = ms_ld_inst_zip;
    assign shift_rdata   = {24'b0, {32{data_buf_valid}} & ms_data_buf | {32{~data_buf_valid}} & data_sram_rdata} >> {ms_rf_result_tmp[1:0], 3'b0};
    assign ms_mem_result[ 7: 0]   =  shift_rdata[ 7: 0];
    assign ms_mem_result[15: 8]   =  {8{op_ld_b}} & {8{shift_rdata[7]}} |
                                     {8{op_ld_bu}} & 8'b0               |
                                     {8{~op_ld_bu & ~op_ld_b}} & shift_rdata[15: 8];
    assign ms_mem_result[31:16]   =  {16{op_ld_b}} & {16{shift_rdata[7]}} |
                                     {16{op_ld_h}} & {16{shift_rdata[15]}}|
                                     {16{op_ld_bu | op_ld_hu}} & 16'b0    |
                                     {16{op_ld_w}} & shift_rdata[31:16];
    assign ms_rf_wdata = {32{ms_res_from_mem}} & ms_mem_result | {32{~ms_res_from_mem}} & ms_rf_result_tmp;
    assign ms_rf_zip  = {~ms2ws_valid & ms_res_from_mem & ms_valid, ms_csr_re & ms_valid, ms_rf_we & ms_valid, ms_rf_waddr, ms_rf_wdata};
    
    assign ms2ws_bus = {
                        ms_rf_result_tmp,   // 32 bit
                        ms_pc,              // 32 bit
                        ms_csr_zip,         // 79 bit
                        ms_except_zip       //  7 bit
                    };
endmodule

module WBreg(
    input  wire        clk,
    input  wire        resetn,
    // mem and ws state interface
    output wire        ws_allowin,
    input  wire [`MS2WS_LEN -1:0] ms2ws_bus,
    input  wire [38:0] ms_rf_zip, // {ms_csr_re, ms_rf_we, ms_rf_waddr, ms_rf_wdata}
    input  wire        ms2ws_valid,
    // trace debug interface
    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_we,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata,
    // id and ws state interface
    output wire [37:0] ws_rf_zip,  // {ws_rf_we, ws_rf_waddr, ws_rf_wdata_tmp}
    // wb and csr interface
    output reg         csr_re,
    output      [13:0] csr_num,
    input       [31:0] csr_rvalue,
    output             csr_we,
    output      [31:0] csr_wmask,
    output      [31:0] csr_wvalue,
    output             ertn_flush,
    output             wb_ex,
    output reg  [31:0] wb_vaddr,
    output reg  [31:0] wb_pc,
    output      [ 5:0] wb_ecode,
    output      [ 8:0] wb_esubcode
);
    
    wire        ws_ready_go;
    reg         ws_valid;
    wire [31:0] ws_rf_wdata;
    reg  [31:0] ws_rf_wdata_tmp;
    reg  [4 :0] ws_rf_waddr;
    reg         ws_rf_we_tmp;
    wire        ws_rf_we;

    wire        ws_ertn;
    wire        ws_except_adef;
    wire        ws_except_ale;
    wire        ws_except_sys;
    wire        ws_except_brk;
    wire        ws_except_ine;
    wire        ws_except_int;
    reg  [ 6:0] ws_except_zip;
    reg  [78:0] ws_csr_zip;
//------------------------------state control signal---------------------------------------

    assign ws_ready_go      = 1'b1;
    assign ws_allowin       = ~ws_valid | ws_ready_go ;     
    always @(posedge clk) begin
        if(~resetn)
            ws_valid <= 1'b0;
        else if(wb_ex|ertn_flush)
            ws_valid <= 1'b0;
        else if(ws_allowin)
            ws_valid <= ms2ws_valid; 
    end

//------------------------------mem and wb state interface---------------------------------------
    always @(posedge clk) begin
        if(~resetn) begin
            {wb_vaddr, wb_pc, ws_csr_zip, ws_except_zip}  <= {`MS2WS_LEN{1'b0}};
            {csr_re, ws_rf_we_tmp, ws_rf_waddr, ws_rf_wdata_tmp} <= 39'b0;
        end
        if(ms2ws_valid & ws_allowin) begin
            {wb_vaddr, wb_pc, ws_csr_zip, ws_except_zip}  <= ms2ws_bus;
            {csr_re, ws_rf_we_tmp, ws_rf_waddr, ws_rf_wdata_tmp} <= ms_rf_zip;
        end
    end
//-----------------------------wb and csr state interface---------------------------------------
    assign {csr_num, csr_wmask, csr_wvalue,  csr_we} = ws_csr_zip & {79{ws_valid}};
    assign {ws_except_ale, ws_except_adef, ws_except_ine, ws_except_int, ws_except_brk, 
            ws_except_sys, ws_ertn} = ws_except_zip;    // ertn_flush=inst_ertn
    assign ertn_flush = ws_ertn & ws_valid;
    assign wb_ex = (ws_except_adef |                   // �ô����ַȡָ�Ѿ��������ʲ���ws_valid�ҹ�
                    ws_except_int  |                    // �ж���״̬�Ĵ����еļ�ʱ������������ws_valid�ҹ�
                    ws_except_ale | ws_except_ine | ws_except_brk | ws_except_sys) & ws_valid;
    assign wb_ecode =  ws_except_int ? `ECODE_INT:
                       ws_except_adef? `ECODE_ADE:
                       ws_except_ale? `ECODE_ALE: 
                       ws_except_sys? `ECODE_SYS:
                       ws_except_brk? `ECODE_BRK:
                       ws_except_ine? `ECODE_INE:
                        6'b0;   // δ����ADEM��TLBR
    assign wb_esubcode = 9'b0;
//------------------------------id and ws state interface---------------------------------------
    assign ws_rf_wdata = csr_re ? csr_rvalue : ws_rf_wdata_tmp;
    assign ws_rf_we  = ws_rf_we_tmp & ws_valid & ~wb_ex;
    assign ws_rf_zip = {ws_rf_we & ws_valid, ws_rf_waddr, ws_rf_wdata};
//------------------------------trace debug interface---------------------------------------
    assign debug_wb_pc = wb_pc;
    assign debug_wb_rf_wdata = ws_rf_wdata;
    assign debug_wb_rf_we = {4{ws_rf_we & ws_valid}};
    assign debug_wb_rf_wnum = ws_rf_waddr;
endmodule

// 32λBooth��λ����Ҫ����16�����ֻ�
// 32λ�޷������˷���34λ�з������˷�����17�����ֻ�
module Adder (
    input   [63:0] in1,
    input   [63:0] in2,
    input   [63:0] in3,
    output  [63:0] C,
    output  [63:0] S
);
    assign S  = in1 ^ in2 ^ in3;
    assign C = {(in1 & in2 | in1 & in3 | in2 & in3), 1'b0} ;
endmodule

module Wallace_Mul (
    input          mul_clk,
    input          resetn,
    input          mul_signed,
    input   [31:0] A,
    input   [31:0] B,
    output  [63:0] result
);
    reg  [31:0] A_reg;
    reg  [31:0] B_reg;
    wire [63:0] A_add;  
    wire [63:0] A_sub;
    wire [63:0] A2_add;
    wire [63:0] A2_sub;
    wire [34:0] sel_x;
    wire [34:0] sel_2x;
    wire [34:0] sel_neg_x;
    wire [34:0] sel_neg_2x;
    wire [34:0] sel_0;
    wire [16:0] sel_x_val;
    wire [16:0] sel_2x_val;
    wire [16:0] sel_neg_x_val;
    wire [16:0] sel_neg_2x_val;
    wire [16:0] sel_0_val;
    wire [18:0] debug;
    // ��չ��34λ�Լ����޷������˷���ż��λ���ڴ���
    wire [33:0] B_r;
    wire [33:0] B_m;
    wire [33:0] B_l;
    wire [63:0] P [16:0];   // δ����Ĳ��ֻ�

    always @(posedge mul_clk) begin
        if(~resetn)
            {A_reg, B_reg} <= 64'b0;
        else    
            {A_reg, B_reg} <= {A, B};
    end
    assign A_add       = {{32{A[31] & mul_signed}}, A};
    assign A_sub       = ~ A_add + 1'b1;
    assign A2_add      = {A_add, 1'b0};
    assign A2_sub      = ~A2_add + 1'b1; 
    assign B_m  = {{2{B[31] & mul_signed}}, B};
    assign B_l  = {1'b0, B_m[33:1]};
    assign B_r  = {B_m[32:0], 1'b0};

    assign sel_neg_x   = ( B_l &  B_m & ~B_r) | (B_l & ~B_m & B_r);    // 110, 101
    assign sel_x       = (~B_l &  B_m & ~B_r) | (~B_l & ~B_m& B_r);    // 010, 001
    assign sel_neg_2x  = ( B_l & ~B_m & ~B_r) ;                      //  100
    assign sel_2x      = (~B_l & B_m & B_r);                         // 011
    assign sel_0       = (B_l & B_m & B_r) | (~B_l & ~B_m & ~B_r);     // 000, 111

    // ����λ������Ч��ѡȡ�ź�
    assign sel_x_val    = { sel_x[32], sel_x[30], sel_x[28], sel_x[26], sel_x[24],
                            sel_x[22], sel_x[20], sel_x[18], sel_x[16],
                            sel_x[14], sel_x[12], sel_x[10], sel_x[ 8],
                            sel_x[ 6], sel_x[ 4], sel_x[ 2], sel_x[ 0]};
    assign sel_neg_x_val= { sel_neg_x[32], sel_neg_x[30], sel_neg_x[28], sel_neg_x[26], sel_neg_x[24],
                            sel_neg_x[22], sel_neg_x[20], sel_neg_x[18], sel_neg_x[16],
                            sel_neg_x[14], sel_neg_x[12], sel_neg_x[10], sel_neg_x[ 8],
                            sel_neg_x[ 6], sel_neg_x[ 4], sel_neg_x[ 2], sel_neg_x[ 0]};     
    assign sel_2x_val   =  {sel_2x[32], sel_2x[30], sel_2x[28], sel_2x[26], sel_2x[24],
                            sel_2x[22], sel_2x[20], sel_2x[18], sel_2x[16],
                            sel_2x[14], sel_2x[12], sel_2x[10], sel_2x[ 8],
                            sel_2x[ 6], sel_2x[ 4], sel_2x[ 2], sel_2x[ 0]};        
    assign sel_neg_2x_val= {sel_neg_2x[32], sel_neg_2x[30], sel_neg_2x[28], sel_neg_2x[26], sel_neg_2x[24],
                            sel_neg_2x[22], sel_neg_2x[20], sel_neg_2x[18], sel_neg_2x[16],
                            sel_neg_2x[14], sel_neg_2x[12], sel_neg_2x[10], sel_neg_2x[ 8],
                            sel_neg_2x[ 6], sel_neg_2x[ 4], sel_neg_2x[ 2], sel_neg_2x[ 0]};   
    assign sel_0_val    =  {sel_0[32], sel_0[30], sel_0[28], sel_0[26], sel_0[24],
                            sel_0[22], sel_0[20], sel_0[18], sel_0[16],
                            sel_0[14], sel_0[12], sel_0[10], sel_0[ 8],
                            sel_0[ 6], sel_0[ 4], sel_0[ 2], sel_0[ 0]}; 
    // debug�ź�ӦΪ0FFFF                                                                                              
    assign debug        = sel_x_val + sel_neg_2x_val + sel_neg_x_val + sel_2x_val + sel_0_val;
    // ʮ����δ����Ĳ��ֻ�
    assign {P[16], P[15], P[14], P[13], P[12],
            P[11], P[10], P[ 9], P[ 8],
            P[ 7], P[ 6], P[ 5], P[ 4],
            P[ 3], P[ 2], P[ 1], P[ 0]} 
            =  {{64{sel_x_val[16]}}, {64{sel_x_val[15]}}, {64{sel_x_val[14]}}, {64{sel_x_val[13]}}, {64{sel_x_val[12]}},
                {64{sel_x_val[11]}}, {64{sel_x_val[10]}}, {64{sel_x_val[ 9]}}, {64{sel_x_val[ 8]}},
                {64{sel_x_val[ 7]}}, {64{sel_x_val[ 6]}}, {64{sel_x_val[ 5]}}, {64{sel_x_val[ 4]}},
                {64{sel_x_val[ 3]}}, {64{sel_x_val[ 2]}}, {64{sel_x_val[ 1]}}, {64{sel_x_val[ 0]}}} & {17{A_add}} |
               {{64{sel_neg_x_val[16]}}, {64{sel_neg_x_val[15]}}, {64{sel_neg_x_val[14]}}, {64{sel_neg_x_val[13]}}, {64{sel_neg_x_val[12]}},
                {64{sel_neg_x_val[11]}}, {64{sel_neg_x_val[10]}}, {64{sel_neg_x_val[ 9]}}, {64{sel_neg_x_val[ 8]}},
                {64{sel_neg_x_val[ 7]}}, {64{sel_neg_x_val[ 6]}}, {64{sel_neg_x_val[ 5]}}, {64{sel_neg_x_val[ 4]}},
                {64{sel_neg_x_val[ 3]}}, {64{sel_neg_x_val[ 2]}}, {64{sel_neg_x_val[ 1]}}, {64{sel_neg_x_val[ 0]}}}  & {17{A_sub}} |
               {{64{sel_2x_val[16]}}, {64{sel_2x_val[15]}}, {64{sel_2x_val[14]}}, {64{sel_2x_val[13]}}, {64{sel_2x_val[12]}},
                {64{sel_2x_val[11]}}, {64{sel_2x_val[10]}}, {64{sel_2x_val[ 9]}}, {64{sel_2x_val[ 8]}},
                {64{sel_2x_val[ 7]}}, {64{sel_2x_val[ 6]}}, {64{sel_2x_val[ 5]}}, {64{sel_2x_val[ 4]}},
                {64{sel_2x_val[ 3]}}, {64{sel_2x_val[ 2]}}, {64{sel_2x_val[ 1]}}, {64{sel_2x_val[ 0]}}} & {17{A2_add}} |
               {{64{sel_neg_2x_val[16]}}, {64{sel_neg_2x_val[15]}}, {64{sel_neg_2x_val[14]}}, {64{sel_neg_2x_val[13]}}, {64{sel_neg_2x_val[12]}},
                {64{sel_neg_2x_val[11]}}, {64{sel_neg_2x_val[10]}}, {64{sel_neg_2x_val[ 9]}}, {64{sel_neg_2x_val[ 8]}},
                {64{sel_neg_2x_val[ 7]}}, {64{sel_neg_2x_val[ 6]}}, {64{sel_neg_2x_val[ 5]}}, {64{sel_neg_2x_val[ 4]}},
                {64{sel_neg_2x_val[ 3]}}, {64{sel_neg_2x_val[ 2]}}, {64{sel_neg_2x_val[ 1]}}, {64{sel_neg_2x_val[ 0]}}} & {17{A2_sub}}; 

//-----------------------------------------Level 1--------------------------------------------- 
    wire [63:0] level_1 [11:0];
    Adder adder1_1 (
        .in1({P[15], 30'b0}),
        .in2({P[14], 28'b0}),
        .in3({P[13], 26'b0}),
        .C(level_1[0]),
        .S(level_1[1])
    );
    Adder adder1_2 (
        .in1({P[12], 24'b0}),
        .in2({P[11], 22'b0}),
        .in3({P[10], 20'b0}),
        .C(level_1[2]),
        .S(level_1[3])
    );
    Adder adder1_3 (
        .in1({P[ 9], 18'b0}),
        .in2({P[ 8], 16'b0}),
        .in3({P[ 7], 14'b0}),
        .C(level_1[4]),
        .S(level_1[5])
    );
    Adder adder1_4 (
        .in1({P[ 6], 12'b0}),
        .in2({P[ 5], 10'b0}),
        .in3({P[ 4],  8'b0}),
        .C(level_1[6]),
        .S(level_1[7])
    );
    Adder adder1_5 (
        .in1({P[ 3],  6'b0}),
        .in2({P[ 2],  4'b0}),
        .in3({P[ 1],  2'b0}),
        .C(level_1[8]),
        .S(level_1[9])
    );
    assign level_1[10] = P[0];
    assign level_1[11] = {P[16], 32'b0};
//-----------------------------------------Level 2--------------------------------------------- 
    wire [63:0] level_2 [7:0];
    Adder adder2_1 (
        .in1(level_1[0]),
        .in2(level_1[1]),
        .in3(level_1[2]),
        .C(level_2[0]),
        .S(level_2[1])
    );
    Adder adder2_2 (
        .in1(level_1[3]),
        .in2(level_1[4]),
        .in3(level_1[5]),
        .C(level_2[2]),
        .S(level_2[3])
    );
    Adder adder2_3 (
        .in1(level_1[6]),
        .in2(level_1[7]),
        .in3(level_1[8]),
        .C(level_2[4]),
        .S(level_2[5])
    );
    Adder adder2_4 (
        .in1(level_1[9]),
        .in2(level_1[10]),
        .in3(level_1[11]),
        .C(level_2[6]),
        .S(level_2[7])
    );
//-----------------------------------------Level 3--------------------------------------------- 
    wire [63:0] level_3 [5:0];
    Adder adder3_1 (
        .in1(level_2[0]),
        .in2(level_2[1]),
        .in3(level_2[2]),
        .C(level_3[0]),
        .S(level_3[1])
    );
    Adder adder3_2 (
        .in1(level_2[3]),
        .in2(level_2[4]),
        .in3(level_2[5]),
        .C(level_3[2]),
        .S(level_3[3])
    );
    assign level_3[4] = level_2[6];
    assign level_3[5] = level_2[7];
//-----------------------------------------��ˮ���з�-------------------------------------------
    
//-----------------------------------------Level 4--------------------------------------------- 
    wire [63:0] level_4 [3:0];
    Adder adder4_1 (
        .in1(level_3[0]),
        .in2(level_3[1]),
        .in3(level_3[2]),
        .C(level_4[0]),
        .S(level_4[1])
    );
    Adder adder4_2 (
        .in1(level_3[3]),
        .in2(level_3[4]),
        .in3(level_3[5]),
        .C(level_4[2]),
        .S(level_4[3])
    );
//-----------------------------------------Level 5--------------------------------------------- 
    wire [63:0] level_5 [2:0];
    Adder adder5_1 (
        .in1(level_4[0]),
        .in2(level_4[1]),
        .in3(level_4[2]),
        .C(level_5[0]),
        .S(level_5[1])
    );
    assign level_5[2] = level_4[3]; 
//-----------------------------------------Level 6--------------------------------------------- 
    wire [63:0] level_6 [1:0];
    Adder adder6_1 (
        .in1(level_5[0]),
        .in2(level_5[1]),
        .in3(level_5[2]),
        .C(level_6[0]),
        .S(level_6[1])
    );
//-----------------------------------------��ˮ���з�-------------------------------------------
    reg  [63:0] level_6_r [1:0];
    always @(posedge mul_clk) begin
        if(~resetn)
            {level_6_r[0],level_6_r[1]} <= {2{64'b0}};
        else
            {level_6_r[0],level_6_r[1]} <= {level_6[0],level_6[1]};
    end
    assign result = level_6_r[0] + level_6_r[1];
endmodule

module Div(
    input  wire    div_clk,
    input  wire    resetn,
    input  wire    div,
    input  wire    div_signed,
    input  wire [31:0] x,   //������
    input  wire [31:0] y,   //����
    output wire [31:0] s,   //��
    output wire [31:0] r,   //����
    output wire    complete //��������ź�
);

    wire        sign_s;
    wire        sign_r;
    wire [31:0] abs_x;
    wire [31:0] abs_y;
    wire [32:0] pre_r;
    wire [32:0] recover_r;
    reg  [63:0] x_pad;
    reg  [32:0] y_pad;
    reg  [31:0] s_r;
    reg  [32:0] r_r;    // ��ǰ������
    reg  [ 5:0] counter;

// 1.ȷ������λ
    assign sign_s = (x[31]^y[31]) & div_signed;
    assign sign_r = x[31] & div_signed;
    assign abs_x  = (div_signed & x[31]) ? (~x+1'b1): x;
    assign abs_y  = (div_signed & y[31]) ? (~y+1'b1): y;
// 2.ѭ�������õ��̺���������ֵ
    assign complete = counter == 6'd33;
    //��ʼ��������
    always @(posedge div_clk) begin
        if(~resetn) begin
            counter <= 6'b0;
        end
        else if(div) begin
            if(complete)
                counter <= 6'b0;
            else
                counter <= counter + 1'b1;
        end
    end
    //׼��������,counter=0
    always @(posedge div_clk) begin
        if(~resetn)
            {x_pad, y_pad} <= {64'b0, 33'b0};
        else if(div) begin
            if(~|counter)
                {x_pad, y_pad} <= {32'b0, abs_x, 1'b0, abs_y};
        end
    end

    //��⵱ǰ�����ļ������
    assign pre_r = r_r - y_pad;                     //δ�ָ������Ľ��
    assign recover_r = pre_r[32] ? r_r : pre_r;     //�ָ������Ľ��
    always @(posedge div_clk) begin
        if(~resetn) 
            s_r <= 32'b0;
        else if(div & ~complete & |counter) begin
            s_r[32-counter] <= ~pre_r[32];
        end
    end
    always @(posedge div_clk) begin
        if(~resetn)
            r_r <= 33'b0;
        if(div & ~complete) begin
            if(~|counter)   //������ʼ��
                r_r <= {32'b0, abs_x[31]};
            else
                r_r <=  (counter == 32) ? recover_r : {recover_r, x_pad[31 - counter]};
        end
    end
// 3.���������̺�����
    assign s = div_signed & sign_s ? (~s_r+1'b1) : s_r;
    assign r = div_signed & sign_r ? (~r_r+1'b1) : r_r;
endmodule

module csr(
    input  wire          clk       ,
    input  wire          reset     ,
    // ���˿�
    input  wire          csr_re    ,
    input  wire [13:0]   csr_num   ,
    output wire [31:0]   csr_rvalue,
    // д�˿�
    input  wire          csr_we    ,
    input  wire [31:0]   csr_wmask ,
    input  wire [31:0]   csr_wvalue,
    // ��Ӳ����·�����Ľӿ��ź�
    output wire [31:0]   ex_entry  , //����pre-IF���쳣��ڵ�ַ
    output wire [31:0]   ertn_entry, //����pre-IF�ķ�����ڵ�ַ
    output wire          has_int   , //����ID�׶ε��ж���Ч�ź�
    input  wire          ertn_flush, //����WB�׶ε�ertnָ��ִ����Ч�ź�
    input  wire          wb_ex     , //����WB�׶ε��쳣�������ź�
    input  wire [ 5:0]   wb_ecode  , //����WB�׶ε��쳣����
    input  wire [ 8:0]   wb_esubcode,//����WB�׶ε��쳣���͸�����
    input  wire [31:0]   wb_vaddr   ,//����WB�׶εķô��ַ
    input  wire [31:0]   wb_pc       //д�صķ��ص�ַ
);
    wire [ 7: 0] hw_int_in;
    wire         ipi_int_in;
    // ��ǰģʽ��Ϣ
    wire [31: 0] csr_crmd_data;
    reg  [ 1: 0] csr_crmd_plv;      //CRMD��PLV�򣬵�ǰ��Ȩ�ȼ�
    reg          csr_crmd_ie;       //CRMD��ȫ���ж�ʹ���ź�
    reg          csr_crmd_da;       //CRMD��ֱ�ӵ�ַ����ʹ��
    reg          csr_crmd_pg;
    reg  [ 6: 5] csr_crmd_datf;
    reg  [ 8: 7] csr_crmd_datm;
    // reg  [31: 9] csr_crmd_r0;

    // ����ǰģʽ��Ϣ
    wire [31: 0] csr_prmd_data;
    reg  [ 1: 0] csr_prmd_pplv;     //CRMD��PLV���ֵ
    reg          csr_prmd_pie;      //CRMD��IE���ֵ

    // �������
    wire [31: 0] csr_ecfg_data;     // ����λ31:13
    reg  [12: 0] csr_ecfg_lie;      //�ֲ��ж�ʹ��λ

    // ����״̬
    wire [31: 0] csr_estat_data;    // ����λ15:13, 31
    reg  [12: 0] csr_estat_is;      // �����жϵ�״̬λ��8��Ӳ���ж�+1����ʱ���ж�+1���˼��ж�+2������жϣ�
    reg  [ 5: 0] csr_estat_ecode;   // ��������һ������
    reg  [ 8: 0] csr_estat_esubcode;// �������Ͷ�������

    // ���ⷵ�ص�ַERA
    reg  [31: 0] csr_era_data;  // data

    // ������ڵ�ַeentry
    wire [31: 0] csr_eentry_data;   // ����λ5:0
    reg  [25: 0] csr_eentry_va;     // �����ж���ڸ�λ��ַ
    // ���ݱ���
    reg  [31: 0] csr_save0_data;
    reg  [31: 0] csr_save1_data;
    reg  [31: 0] csr_save2_data;
    reg  [31: 0] csr_save3_data;
    // �������ַ
    wire         wb_ex_addr_err;
    reg  [31: 0] csr_badv_vaddr;
    wire [31: 0] csr_badv_data;
    // ��ʱ����� 
    wire [31: 0] csr_tid_data;
    reg  [31: 0] csr_tid_tid;

    // ��ʱ������
    wire [31: 0] csr_tcfg_data;
    reg          csr_tcfg_en;
    reg          csr_tcfg_periodic;
    reg  [29: 0] csr_tcfg_initval;
    wire [31: 0] tcfg_next_value;

    // ��ʱ����ֵ
    wire [31: 0] csr_tval_data;
    reg  [31: 0] timer_cnt;
    // ��ʱ�ж����
    wire [31: 0] csr_ticlr_data;

    assign has_int = (|(csr_estat_is[11:0] & csr_ecfg_lie[11:0])) & csr_crmd_ie;
    assign ex_entry = csr_eentry_data;
    assign ertn_entry = csr_era_data;
    // CRMD��PLV��IE��
    always @(posedge clk) begin
        if (reset) begin
            csr_crmd_plv <= 2'b0;
            csr_crmd_ie  <= 1'b0;
        end
        else if (wb_ex) begin
            csr_crmd_plv <= 2'b0;
            csr_crmd_ie  <= 1'b0;
        end
        else if (ertn_flush) begin
            csr_crmd_plv <= csr_prmd_pplv;
            csr_crmd_ie  <= csr_prmd_pie;
        end
        else if (csr_we && csr_num == `CSR_CRMD) begin
            csr_crmd_plv <= csr_wmask[`CSR_CRMD_PLV] & csr_wvalue[`CSR_CRMD_PLV]
                          | ~csr_wmask[`CSR_CRMD_PLV] & csr_crmd_plv;
            csr_crmd_ie  <= csr_wmask[`CSR_CRMD_IE ] & csr_wvalue[`CSR_CRMD_IE ]
                          | ~csr_wmask[`CSR_CRMD_IE ] & csr_crmd_ie;
        end
    end

    // CRMD��DA��PG��DATF��DATM��
    always @(posedge clk) begin
        if(reset) begin
            csr_crmd_da   <= 1'b1;
            csr_crmd_pg   <= 1'b0;
            csr_crmd_datf <= 2'b0;
            csr_crmd_datm <= 2'b0;
        end
        else if(csr_we &&  wb_ecode==`ECODE_TLBR) begin
            csr_crmd_da   <= 1'b1;
            csr_crmd_pg   <= 1'b1;
        end
        else if (csr_we && csr_estat_ecode == `ECODE_TLBR) begin
            csr_crmd_da   <= 1'b0;
            csr_crmd_pg   <= 1'b1;
            csr_crmd_datf <= 2'b01;
            csr_crmd_datm <= 2'b01;            
        end
    end

    // PRMD��PPLV��PIE��
    always @(posedge clk) begin
        if (wb_ex) begin
            csr_prmd_pplv <= csr_crmd_plv;
            csr_prmd_pie  <= csr_crmd_ie;
        end
        else if (csr_we && csr_num==`CSR_PRMD) begin
            csr_prmd_pplv <=  csr_wmask[`CSR_PRMD_PPLV] & csr_wvalue[`CSR_PRMD_PPLV]
                           | ~csr_wmask[`CSR_PRMD_PPLV] & csr_prmd_pplv;
            csr_prmd_pie  <=  csr_wmask[`CSR_PRMD_PIE ] & csr_wvalue[`CSR_PRMD_PIE ]
                           | ~csr_wmask[`CSR_PRMD_PIE ] & csr_prmd_pie;
        end
    end

    // ECFG��LIE��
    always @(posedge clk) begin
        if(reset)
            csr_ecfg_lie <= 13'b0;
        else if(csr_we && csr_num == `CSR_ECFG)
            csr_ecfg_lie <= csr_wmask[`CSR_ECFG_LIE] & 13'h1bff & csr_wvalue[`CSR_ECFG_LIE]
                        |  ~csr_wmask[`CSR_ECFG_LIE] & 13'h1bff & csr_ecfg_lie;
    end
    // ESTAT��IS��
    assign hw_int_in = 8'b0;
    assign ipi_int_in= 1'b0;
    always @(posedge clk) begin
        if (reset) begin
            csr_estat_is[1:0] <= 2'b0;
        end
        else if (csr_we && (csr_num == `CSR_ESTAT)) begin
            csr_estat_is[1:0] <= ( csr_wmask[`CSR_ESTAT_IS10] & csr_wvalue[`CSR_ESTAT_IS10])
                               | (~csr_wmask[`CSR_ESTAT_IS10] & csr_estat_is[1:0]          );
        end

        csr_estat_is[9:2] <= hw_int_in[7:0]; //Ӳ�ж�
        csr_estat_is[10] <= 1'b0; 

        if (timer_cnt[31:0] == 32'b0) begin
            csr_estat_is[11] <= 1'b1;
        end
        else if (csr_we && csr_num == `CSR_TICLR && csr_wmask[`CSR_TICLR_CLR] 
                && csr_wvalue[`CSR_TICLR_CLR]) 
            csr_estat_is[11] <= 1'b0;
        csr_estat_is[12] <= ipi_int_in;     // �˼��ж�
    end    
    // ESTAT��Ecode��EsubCode��
    always @(posedge clk) begin
        if (wb_ex) begin
            csr_estat_ecode    <= wb_ecode;
            csr_estat_esubcode <= wb_esubcode;
        end
    end
    // ERA��PC��
    always @(posedge clk) begin
        if(wb_ex)
            csr_era_data <= wb_pc;
        else if (csr_we && csr_num == `CSR_ERA) 
            csr_era_data <= csr_wmask[`CSR_ERA_PC] & csr_wvalue[`CSR_ERA_PC]
                        | ~csr_wmask[`CSR_ERA_PC] & csr_era_data;
    end
     // EENTRY
    always @(posedge clk) begin
        if (csr_we && (csr_num == `CSR_EENTRY))
            csr_eentry_va <=   csr_wmask[`CSR_EENTRY_VA] & csr_wvalue[`CSR_EENTRY_VA]
                            | ~csr_wmask[`CSR_EENTRY_VA] & csr_eentry_va ;
    end

    // SAVE0~3
    always @(posedge clk) begin
        if (csr_we && csr_num == `CSR_SAVE0) 
            csr_save0_data <=  csr_wmask[`CSR_SAVE_DATA] & csr_wvalue[`CSR_SAVE_DATA]
                            | ~csr_wmask[`CSR_SAVE_DATA] & csr_save0_data;
        if (csr_we && (csr_num == `CSR_SAVE1)) 
            csr_save1_data <=  csr_wmask[`CSR_SAVE_DATA] & csr_wvalue[`CSR_SAVE_DATA]
                            | ~csr_wmask[`CSR_SAVE_DATA] & csr_save1_data;
        if (csr_we && (csr_num == `CSR_SAVE2)) 
            csr_save2_data <=  csr_wmask[`CSR_SAVE_DATA] & csr_wvalue[`CSR_SAVE_DATA]
                            | ~csr_wmask[`CSR_SAVE_DATA] & csr_save2_data;
        if (csr_we && (csr_num == `CSR_SAVE3)) 
            csr_save3_data <=  csr_wmask[`CSR_SAVE_DATA] & csr_wvalue[`CSR_SAVE_DATA]
                            | ~csr_wmask[`CSR_SAVE_DATA] & csr_save3_data;
    end
    // BADV��VAddr��
    assign wb_ex_addr_err = wb_ecode==`ECODE_ALE || wb_ecode==`ECODE_ADE; 
    always @(posedge clk) begin
        if (wb_ex && wb_ex_addr_err) begin
            csr_badv_vaddr <= (wb_ecode==`ECODE_ADE && wb_esubcode==`ESUBCODE_ADEF) ? wb_pc:wb_vaddr;
        end
    end
    // TID
    always @(posedge clk) begin
        if (reset) begin
            csr_tid_tid <= 32'b0;
        end
        else if (csr_we && csr_num == `CSR_TID) begin
            csr_tid_tid <= csr_wmask[`CSR_TID_TID] & csr_wvalue[`CSR_TID_TID]
                        | ~csr_wmask[`CSR_TID_TID] & csr_tid_tid;
        end
    end

    // TCFG��EN��Periodic��InitVal��
    always @(posedge clk) begin
        if (reset) 
            csr_tcfg_en <= 1'b0;
        else if (csr_we && csr_num == `CSR_TCFG) begin
            csr_tcfg_en <= csr_wmask[`CSR_TCFG_EN] & csr_wvalue[`CSR_TCFG_EN]
                        | ~csr_wmask[`CSR_TCFG_EN] & csr_tcfg_en;
        end
        if (csr_we && csr_num == `CSR_TCFG) begin
            csr_tcfg_periodic <= csr_wmask[`CSR_TCFG_PERIOD] & csr_wvalue[`CSR_TCFG_PERIOD]
                              | ~csr_wmask[`CSR_TCFG_PERIOD] & csr_tcfg_periodic;
            csr_tcfg_initval  <= csr_wmask[`CSR_TCFG_INITV] & csr_wvalue[`CSR_TCFG_INITV]
                              | ~csr_wmask[`CSR_TCFG_INITV] & csr_tcfg_initval;
        end
    end

    // TVAL
    assign tcfg_next_value = csr_wmask[31:0] & csr_wvalue[31:0]
                           |~csr_wmask[31:0] & csr_tcfg_data;
    always @(posedge clk) begin
        if (reset) begin
            timer_cnt <= 32'hffffffff;
        end
        else if (csr_we && csr_num == `CSR_TCFG && tcfg_next_value[`CSR_TCFG_EN]) begin
            timer_cnt <= {tcfg_next_value[`CSR_TCFG_INITV], 2'b0};
        end
        else if (csr_tcfg_en && timer_cnt != 32'hffffffff) begin
            if (timer_cnt[31:0] == 32'b0 && csr_tcfg_periodic) begin
                timer_cnt <= {csr_tcfg_initval, 2'b0};
            end
            else begin
                timer_cnt <= timer_cnt - 1'b1;
            end
        end
    end

    // TICLR��CLR��
    assign csr_ticlr_clr = 1'b0;

    assign csr_crmd_data  = {23'b0, csr_crmd_datm, csr_crmd_datf, csr_crmd_pg, 
                            csr_crmd_da, csr_crmd_ie, csr_crmd_plv};
    assign csr_prmd_data  = {29'b0, csr_prmd_pie, csr_prmd_pplv};
    assign csr_ecfg_data  = {19'b0, csr_ecfg_lie};
    assign csr_estat_data = { 1'b0, csr_estat_esubcode, csr_estat_ecode, 3'b0, csr_estat_is};
    assign csr_eentry_data= {csr_eentry_va, 6'b0};
    assign csr_badv_data  = csr_badv_vaddr;
    assign csr_tid_data   = csr_tid_tid;
    assign csr_tcfg_data  = {csr_tcfg_initval, csr_tcfg_periodic, csr_tcfg_en};
    assign csr_tval_data  = timer_cnt;
    assign csr_ticlr_data = {31'b0, csr_ticlr_clr};
    assign csr_rvalue = {32{csr_num == `CSR_CRMD  }} & csr_crmd_data
                      | {32{csr_num == `CSR_PRMD  }} & csr_prmd_data
                      | {32{csr_num == `CSR_ECFG  }} & csr_ecfg_data
                      | {32{csr_num == `CSR_ESTAT }} & csr_estat_data
                      | {32{csr_num == `CSR_ERA   }} & csr_era_data
                      | {32{csr_num == `CSR_EENTRY}} & csr_eentry_data
                      | {32{csr_num == `CSR_SAVE0 }} & csr_save0_data
                      | {32{csr_num == `CSR_SAVE1 }} & csr_save1_data
                      | {32{csr_num == `CSR_SAVE2 }} & csr_save2_data
                      | {32{csr_num == `CSR_SAVE3 }} & csr_save3_data
                      | {32{csr_num == `CSR_BADV  }} & csr_badv_data
                      | {32{csr_num == `CSR_TID   }} & csr_tid_data
                      | {32{csr_num == `CSR_TCFG  }} & csr_tcfg_data
                      | {32{csr_num == `CSR_TVAL  }} & csr_tval_data
                      | {32{csr_num == `CSR_TICLR }} & csr_ticlr_data;

endmodule