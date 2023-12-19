`include "macro.h"
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
    output wire [`TLB_CONFLICT_BUS_LEN-1:0] es_tlb_zip,
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
    input  wire        wb_ex,

    // tlb interface
    output wire [ 4:0] invtlb_op,
    output wire        inst_invtlb,
    output wire [18:0] s1_vppn,
    output wire        s1_va_bit12,
    output wire [ 9:0] s1_asid,
    input  wire        s1_found,
    input  wire [`TLBNUM_IDX-1:0] s1_index,
    input  wire [19:0] s1_ppn,
    input  wire [ 5:0] s1_ps,
    input  wire [ 1:0] s1_plv,
    input  wire [ 1:0] s1_mat,
    input  wire        s1_d,
    input  wire        s1_v,

    // CSR output for pc translation
    input  wire [ 2:0] dmw0_vseg_CSRoutput,
    input  wire [ 2:0] dmw0_pseg_CSRoutput,
    input  wire        dmw0_plv0_CSRoutput,
    input  wire        dmw0_plv3_CSRoutput,
    input  wire [ 2:0] dmw1_vseg_CSRoutput,
    input  wire [ 2:0] dmw1_pseg_CSRoutput,
    input  wire        dmw1_plv0_CSRoutput,
    input  wire        dmw1_plv3_CSRoutput,
    input  wire [ 1:0] crmd_plv_CSRoutput,
    input  wire        dir_addr_trans_mode,
    input  wire [18:0] tlbehi_vppn_CSRoutput,
    input  wire [ 9:0] asid_asid_CSRoutput
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

    wire        dmw0_hit;
    wire [31:0] dmw0_pa;
    wire        dmw1_hit;
    wire [31:0] dmw1_pa;
    wire        tlb_mode;
    wire [31:0] tlb_pa;
    wire [31:0] mem_acc_pa;

    reg  [`TLB_EXC_NUM-1:0] ds2es_tlb_except_zip;
    wire [`TLB_EXC_NUM-1:0] es_tlb_except_zip;
    wire [`TLB_EXC_NUM-1:0] tlb_except_zip;
    
    reg  [ 4:0] es_ld_inst_zip; // {op_ld_b, op_ld_bu,op_ld_h, op_ld_hu, op_ld_w}
    reg  [ 1:0] es_cnt_inst_zip; // {rd_cnt_h, rd_cnt_l}
    wire        es_except_ale;
    reg  [ 5:0] es_except_zip_tmp;
    wire [ 6:0] es_except_zip;
    reg  [78:0] es_csr_zip;
    wire        es_mem_req;

// TLB
    reg  [10:0] ds2es_tlb_zip;
    wire        inst_tlbsrch;
    wire        inst_tlbrd;
    wire        inst_tlbwr;
    wire        inst_tlbfill;
    wire        es_refetch_flag;
    wire [ 9:0] es2ms_tlb_zip;
    //csr
    wire [13:0] es_csr_num;
    wire        es_csr_we;
    wire [31:0] es_csr_wmask;
    wire [31:0] es_csr_wvalue;

//state control signal

    assign es_ex            = ((|es_except_zip) | (|es_tlb_except_zip)) & es_valid;
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

//id and exe state interface

    always @(posedge clk) begin
        if(~resetn)
            {es_alu_op, es_res_from_mem, es_alu_src1, es_alu_src2,
             es_csr_re, es_rf_we, es_rf_waddr, es_rkd_value, es_pc, es_st_op_zip, 
             es_ld_inst_zip, es_cnt_inst_zip, es_csr_zip, es_except_zip_tmp, ds2es_tlb_zip, ds2es_tlb_except_zip} <= {`DS2ES_LEN{1'b0}};
        else if(ds2es_valid & es_allowin)
            {es_alu_op, es_res_from_mem, es_alu_src1, es_alu_src2,
             es_csr_re, es_rf_we, es_rf_waddr, es_rkd_value, es_pc, es_st_op_zip, 
             es_ld_inst_zip, es_cnt_inst_zip, es_csr_zip, es_except_zip_tmp, ds2es_tlb_zip, ds2es_tlb_except_zip} <= ds2es_bus;    
    end
    // 指令拆包
    assign {op_ld_h, op_ld_hu, op_ld_w} = es_ld_inst_zip[2:0];
    assign {op_st_b, op_st_h, op_st_w} = es_st_op_zip;
    assign {rd_cnt_h, rd_cnt_l} = es_cnt_inst_zip;

//exe timer
    
    always @(posedge clk) begin
        if(~resetn)
            es_timer_cnt <= 64'b0;
        else   
            es_timer_cnt <= es_timer_cnt + 1'b1;
    end
    
//exe and mem state interface

    assign es_except_ale = ((|es_alu_result[1:0]) & (op_st_w | op_ld_w)|
                            es_alu_result[0] & (op_st_h|op_ld_hu|op_ld_h)) & es_valid;
                            
    assign es_except_zip = {es_except_ale, es_except_zip_tmp};
    assign es2ms_bus = {es_mem_req,         // 1  bit
                        es_ld_inst_zip,     // 5  bit
                        es_pc,              // 32 bit
                        es_csr_zip,         // 79 bit
                        es_except_zip,      //  7 bit
                        es2ms_tlb_zip,      // 10 bits
                        es_tlb_except_zip   //  8 bits
                        };

//alu interface

    alu u_alu(
        .clk            (clk       ),
        .resetn         (resetn & ~wb_ex & ~(ds2es_valid & es_allowin)),
        .alu_op         (es_alu_op    ),
        .alu_src1       (es_alu_src1  ),
        .alu_src2       (es_alu_src2  ),
        .alu_result     (es_alu_result),
        .complete       (alu_complete)
    );

//memory access address translation

    assign dmw0_hit = (es_alu_result[31:29] == dmw0_vseg_CSRoutput) && (crmd_plv_CSRoutput == 2'd0 && dmw0_plv0_CSRoutput || crmd_plv_CSRoutput == 2'd3 && dmw0_plv3_CSRoutput);
    assign dmw0_pa  = {dmw0_pseg_CSRoutput, es_alu_result[28:0]};
    assign dmw1_hit = (es_alu_result[31:29] == dmw1_vseg_CSRoutput) && (crmd_plv_CSRoutput == 2'd0 && dmw1_plv0_CSRoutput || crmd_plv_CSRoutput == 2'd3 && dmw1_plv3_CSRoutput);
    assign dmw1_pa  = {dmw1_pseg_CSRoutput, es_alu_result[28:0]};
    assign tlb_mode = (es_res_from_mem | (|es_mem_we)) & ~wb_ex & ~ms_ex & ~(|es_except_zip) & ~dir_addr_trans_mode & ~dmw0_hit & ~dmw1_hit;
    assign tlb_pa   = {32{(s1_ps == 6'd21)}} & {s1_ppn[19:9], es_alu_result[20:0]} |
                      {32{(s1_ps == 6'd12)}} & {s1_ppn      , es_alu_result[11:0]};
    assign mem_acc_pa = dir_addr_trans_mode ? es_alu_result :
                        dmw0_hit            ? dmw0_pa       :
                        dmw1_hit            ? dmw1_pa       : tlb_pa;

//tlb exception

    assign {tlb_except_zip[`TLB_EXC_TLBR_F], tlb_except_zip[`TLB_EXC_PIF], tlb_except_zip[`TLB_EXC_PPI_F]} = 3'd0;
    assign tlb_except_zip[`TLB_EXC_TLBR_LS] = es_valid & tlb_mode                   & ~s1_found;
    assign tlb_except_zip[`TLB_EXC_PIL]     = es_valid & tlb_mode & es_res_from_mem &  s1_found & ~s1_v;
    assign tlb_except_zip[`TLB_EXC_PIS]     = es_valid & tlb_mode & (|es_mem_we)    &  s1_found & ~s1_v;
    assign tlb_except_zip[`TLB_EXC_PME]     = es_valid & tlb_mode & (|es_mem_we)    &  s1_found &  s1_v & (crmd_plv_CSRoutput <= s1_plv) & ~s1_d;
    assign tlb_except_zip[`TLB_EXC_PPI_LS]  = es_valid & tlb_mode                   &  s1_found &  s1_v & (crmd_plv_CSRoutput >  s1_plv);
    assign es_tlb_except_zip = ds2es_tlb_except_zip | tlb_except_zip;

//data sram interface

    assign es_cancel        = wb_ex;
    assign es_mem_we[0]     = op_st_w | op_st_h & ~es_alu_result[1] | op_st_b & ~es_alu_result[0] & ~es_alu_result[1];   
    assign es_mem_we[1]     = op_st_w | op_st_h & ~es_alu_result[1] | op_st_b &  es_alu_result[0] & ~es_alu_result[1];   
    assign es_mem_we[2]     = op_st_w | op_st_h &  es_alu_result[1] | op_st_b & ~es_alu_result[0] &  es_alu_result[1];   
    assign es_mem_we[3]     = op_st_w | op_st_h &  es_alu_result[1] | op_st_b &  es_alu_result[0] &  es_alu_result[1];       
    assign es_mem_req       = (es_res_from_mem | (|es_mem_we)) & ~wb_ex & ~ms_ex & ~es_ex;
    assign data_sram_req    = es_mem_req & es_valid & ms_allowin;
    assign data_sram_wr     = (|data_sram_wstrb) & es_valid & ~wb_ex & ~ms_ex & ~es_ex;
    assign data_sram_wstrb  = es_mem_we;
    assign data_sram_size   = {2{op_st_b}} & 2'b0 | {2{op_st_h}} & 2'b1 | {2{op_st_w}} & 2'd2;
    assign data_sram_addr   = mem_acc_pa;
    assign data_sram_wdata[ 7: 0]   = es_rkd_value[ 7: 0];
    assign data_sram_wdata[15: 8]   = op_st_b ? es_rkd_value[ 7: 0] : es_rkd_value[15: 8];
    assign data_sram_wdata[23:16]   = op_st_w ? es_rkd_value[23:16] : es_rkd_value[ 7: 0];
    assign data_sram_wdata[31:24]   = op_st_w ? es_rkd_value[31:24] : 
                                      op_st_h ? es_rkd_value[15: 8] : es_rkd_value[ 7: 0];

//regfile relevant

    // exe阶段暂时选出的写回数据
    assign es_rf_result_tmp = {32{rd_cnt_h}} & es_timer_cnt[63:32] | 
                              {32{rd_cnt_l}} & es_timer_cnt[31: 0] |
                              {32{~rd_cnt_h & ~rd_cnt_l}} & es_alu_result;
    //暂时认为es_rf_wdata等于es_rf_result_tmp, ld类指令在MEM级等待数据返回后再特殊处理
    assign es_rf_zip = {es_csr_re & es_valid, es_res_from_mem & es_valid, es_rf_we & es_valid, es_rf_waddr, es_rf_result_tmp};    

//TLB relevant

    assign {es_refetch_flag, inst_tlbsrch, inst_tlbrd, inst_tlbwr, inst_tlbfill, inst_invtlb, invtlb_op} = ds2es_tlb_zip;
    assign {s1_vppn, s1_va_bit12} = inst_invtlb ? es_rkd_value[31:12] :
                                    inst_tlbsrch ? {tlbehi_vppn_CSRoutput, 1'b0} :
                                    es_alu_result[31:12]; 
    assign s1_asid       = inst_invtlb ?  es_alu_src1[9:0] : asid_asid_CSRoutput; //src1 is rj
    assign es2ms_tlb_zip = {es_refetch_flag, inst_tlbsrch, inst_tlbrd, inst_tlbwr, inst_tlbfill, s1_found, s1_index};
    assign {es_csr_num, es_csr_wmask, es_csr_wvalue, es_csr_we} = es_csr_zip;
    assign es_tlb_zip = {inst_tlbrd & es_valid, es_csr_we & es_valid, es_csr_num};
endmodule
