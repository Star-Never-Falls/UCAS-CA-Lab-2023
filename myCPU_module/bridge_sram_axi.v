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
	// 状态机状态寄存器
	reg [4:0] ar_current_state;	// 读请求状态机
	reg [4:0] ar_next_state;
	reg [4:0] r_current_state;	// 读数据状态机
	reg [4:0] r_next_state;
	reg [4:0] w_current_state;	// 写请求和写数据状态机
	reg [4:0] w_next_state;
	reg [4:0] b_current_state;	// 写相应状态机
	reg [4:0] b_next_state;
	// 地址已经握手成功而未响应的情况，需要计数
	reg [1:0] ar_resp_cnt;
	// 数据寄存器，0-指令SRAM寄存器，1-数据SRAM寄存器（根据id索引）
	reg [31:0] buf_rdata [1:0];
	// 数据相关的判断信号
	wire read_block;
	// rid寄存器
    reg  [ 3:0] rid_r;

//state machine for read req channel

    //读请求通道状态独热码译码
    localparam  AR_REQ_IDLE     = 3'b001,
                AR_REQ_START  	= 3'b010,
				AR_REQ_END		= 3'b100;
	//读请求通道状态机时序逻辑
	always @(posedge aclk) begin
		if(~aresetn)
			ar_current_state <= AR_REQ_IDLE;
		else 
			ar_current_state <= ar_next_state;
	end
	//读请求通道状态机次态组合逻辑
	always @(*) begin
		case(ar_current_state)
			AR_REQ_IDLE:begin
				if(read_block)
					ar_next_state = AR_REQ_IDLE;
				else if(data_sram_req & ~data_sram_wr | inst_sram_req & ~inst_sram_wr)
					ar_next_state = AR_REQ_START;
				else
					ar_next_state = AR_REQ_IDLE;
			end
			AR_REQ_START:begin
				if(arvalid & arready) 
					ar_next_state = AR_REQ_END;
				else 
					ar_next_state = AR_REQ_START;
			end
			AR_REQ_END:
				ar_next_state = AR_REQ_IDLE;
            default:
                ar_next_state = AR_REQ_IDLE;
		endcase
	end

//state machine for read response channel

    //读响应通道状态独热码译码
    localparam  R_DATA_IDLE     = 3'b001,
                R_DATA_START   	= 3'b010,
				R_DATA_END		= 3'b100;
    //读响应通道状态机时序逻辑
	always @(posedge aclk) begin
		if(~aresetn)
			r_current_state <= R_DATA_IDLE;
		else 
			r_current_state <= r_next_state;
	end
	//读响应通道状态机次态组合逻辑
	always @(*) begin
		case(r_current_state)
			R_DATA_IDLE:begin
				if(arvalid & arready | (|ar_resp_cnt))
					r_next_state = R_DATA_START;
				else
					r_next_state = R_DATA_IDLE;
			end
			R_DATA_START:begin
				if(rvalid & rready) 	// 传输完毕
					r_next_state = R_DATA_END;
				else
					r_next_state = R_DATA_START;
			end
			R_DATA_END:
				r_next_state = R_DATA_IDLE;
			default:
				r_next_state = R_DATA_IDLE;
		endcase
	end

//state machine for write req & data channel

    //写请求&写数据通道状态独热码译码
	localparam  W_REQ_IDLE              = 5'b00001,
                W_REQ_START      		= 5'b00010,
				W_ADDR_RESP				= 5'b00100,
				W_DATA_RESP      		= 5'b01000,
				W_REQ_END				= 5'b10000;
    //写请求&写数据通道状态机时序逻辑
	always @(posedge aclk) begin
		if(~aresetn)
			w_current_state <= W_REQ_IDLE;
		else 
			w_current_state <= w_next_state;
	end
	//写请求&写数据通道状态机次态组合逻辑
	always @(*) begin
		case(w_current_state)
			W_REQ_IDLE:begin
				if(data_sram_req & data_sram_wr)
					w_next_state = W_REQ_START;
				else
					w_next_state = W_REQ_IDLE;
			end
			W_REQ_START:begin
				if(awvalid & awready & wvalid & wready)
					w_next_state = W_REQ_END;
				else if(awvalid & awready)
					w_next_state = W_ADDR_RESP;
				else if(wvalid & wready)
					w_next_state = W_DATA_RESP;
				else
					w_next_state = W_REQ_START;
            end
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
			W_REQ_END:begin
				if(bvalid & bready)
					w_next_state = W_REQ_IDLE;
				else
					w_next_state = W_REQ_END;
            end
            default:
                w_next_state = W_REQ_IDLE;
		endcase
	end

//state machine for write response channel

    //写响应通道状态独热码译码
    localparam  B_IDLE      = 3'b001,
                B_START     = 3'b010,
				B_END		= 3'b100;
    //写响应通道状态机时序逻辑
	always @(posedge aclk) begin
		if(~aresetn)
			b_current_state <= B_IDLE;
		else 
			b_current_state <= b_next_state;
	end
	//写响应通道状态机次态组合逻辑
	always @(*) begin
		case(b_current_state)
			B_IDLE:begin
				if(bready)
					b_next_state = B_START;
				else
					b_next_state = B_IDLE;
			end
			B_START:begin
				if(bready & bvalid) 
					b_next_state = B_END;
				else 
					b_next_state = B_START;
			end
			B_END:
				b_next_state = B_IDLE;
            default:
                b_next_state = B_IDLE;
		endcase
	end

//read req channel

	assign arvalid = ar_current_state[1];
	always  @(posedge aclk) begin
		if(~aresetn) begin
			arid <= 4'b0;
			araddr <= 32'b0;
			arsize <= 3'b0;
			{arlen, arburst, arlock, arcache, arprot} <= {8'b0, 2'b1, 2'b0, 4'b0, 3'b0};	// 常值
		end
		else if(ar_current_state[0]) begin	// 读请求状态机为空闲状态，更新数据
			arid <= {3'b0, data_sram_req & ~data_sram_wr};	// 数据RAM请求优先于指令RAM
			araddr <= data_sram_req & ~data_sram_wr? data_sram_addr : inst_sram_addr;
			arsize <= data_sram_req & ~data_sram_wr? {1'b0, data_sram_size} : {1'b0, inst_sram_size};
		end
	end

//read response channel

    always @(posedge aclk) begin
		if(~aresetn)
			ar_resp_cnt <= 2'b0;
		else if(arvalid & arready & rvalid & rready)	// 读地址和数据channel同时完成握手
			ar_resp_cnt <= ar_resp_cnt;
		else if(arvalid & arready)
			ar_resp_cnt <= ar_resp_cnt + 1'b1;
		else if(rvalid & rready)
			ar_resp_cnt <= ar_resp_cnt - 1'b1;
	end
	assign rready = aresetn & r_current_state[1];

//write req channel

	assign awvalid = aresetn & (w_current_state[1] | w_current_state[3]);	// W_REQ_START | W_DATA_RESP

	always  @(posedge aclk) begin
		if(~aresetn) begin
			awaddr <= 32'b0;
			awsize <= 3'b0;
			{awlen, awburst, awlock, awcache, awprot, awid} <= {8'b0, 2'b1, 1'b0, 4'b0, 3'b0, 4'b1};	// 常值
		end
		else if(w_current_state[0]) begin	// 写请求状态机为空闲状态，更新数据
			awaddr <= data_sram_addr;
			awsize <= {1'b0, data_sram_size};
		end
	end

//write data channel

    assign wvalid = aresetn & (w_current_state[1] | w_current_state[2]);	// W_REQ_START | W_ADDR_RESP
	always  @(posedge aclk) begin
		if(~aresetn) begin
			wstrb <= 4'b0;
			wdata <= 32'b0;
			{wid, wlast} <= {4'b1, 1'b1};	// 常值
		end
		else if(w_current_state[0]) begin	// 写请求状态机为空闲状态，更新数据
			wstrb <= data_sram_wstrb;
			wdata <= data_sram_wdata;
		end
	end

//write response channel

    assign bready = aresetn & w_current_state[4];

//rdata buffer

	assign read_block = (araddr == awaddr) & (|w_current_state[4:1]) & ~b_current_state[2];	// 读写地址相同且有写操作且数据未写入
	always @(posedge aclk)begin
		if(~aresetn)
			{buf_rdata[1], buf_rdata[0]} <= 64'b0;
		else if(rvalid & rready)
			buf_rdata[rid] <= rdata;
	end
	assign data_sram_rdata = buf_rdata[1];
	assign data_sram_addr_ok = arid[0] & r_current_state[1] | wid[0] & awvalid & awready;
	assign data_sram_data_ok = rid_r[0] & r_current_state[2] | bid[0] & bvalid & bready;
	
	assign inst_sram_rdata = buf_rdata[0];
	assign inst_sram_data_ok = ~rid_r[0] & r_current_state[2]; // rvalid & rready的下一拍
	assign inst_sram_addr_ok = ~arid[0] & r_current_state[1];

	always @(posedge aclk)  begin
		if(~aresetn)
			rid_r <= 4'b0;
		else if(rvalid & rready)
			rid_r <= rid;
	end	
endmodule
