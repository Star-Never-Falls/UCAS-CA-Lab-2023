`include "macro.h"
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

    wire [31:0] wb_pc;

    wire [39:0] es_rf_zip;
    wire [39:0] ms_rf_zip;
    wire [37:0] ws_rf_zip;

    wire [33:0] br_zip;
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
    wire [31:0] refetch_target;    // (TLB) REUSE ERTN FOR REFETCH 

    wire        has_int;
    wire        ertn_flush;
    wire        ms_ex;
    wire        wb_ex;
    wire [31:0] wb_vaddr;
    wire [ 5:0] wb_ecode;
    wire [ 8:0] wb_esubcode;

// TLB
    // search port 0 (for fetch)
    wire [18:0] s0_vppn;
    wire        s0_va_bit12;
    // wire [ 9:0] s0_asid;  由CSR.ASID给出
    wire        s0_found;
    wire [`TLBNUM_IDX-1:0] s0_index;
    wire [19:0] s0_ppn;
    wire [ 5:0] s0_ps;
    wire [ 1:0] s0_plv;
    wire [ 1:0] s0_mat;
    wire        s0_d;
    wire        s0_v;

    // search port 1 (for load/store)
    wire [18:0] s1_vppn;
    wire        s1_va_bit12;
    wire [ 9:0] s1_asid;
    wire        s1_found;
    wire [`TLBNUM_IDX-1:0] s1_index;
    wire [19:0] s1_ppn;
    wire [ 5:0] s1_ps;
    wire [ 1:0] s1_plv;
    wire [ 1:0] s1_mat;
    wire        s1_d;
    wire        s1_v;

    // invtlb opcode
    wire        invtlb_valid;
    wire [ 4:0] invtlb_op;

    wire        tlb_we;
    wire        w_e;
    wire [18:0] tlbehi_vppn_CSRoutput;
    wire [ 5:0] w_ps; // 21:4MB 12:4KB
    wire [ 9:0] asid_asid_CSRoutput;
    wire        w_g;
    wire [19:0] w_ppn0;
    wire [ 1:0] w_plv0;
    wire [ 1:0] w_mat0;
    wire        w_d0;
    wire        w_v0;
    wire [19:0] w_ppn1;
    wire [ 1:0] w_plv1;
    wire [ 1:0] w_mat1;
    wire        w_d1;
    wire        w_v1;

    wire        r_e;
    wire [18:0] r_vppn;
    wire [ 5:0] r_ps;
    wire [ 9:0] r_asid;
    wire        r_g;
    wire [19:0] r_ppn0;
    wire [ 1:0] r_plv0;
    wire [ 1:0] r_mat0;
    wire        r_d0;
    wire        r_v0;
    wire [19:0] r_ppn1;
    wire [ 1:0] r_plv1;
    wire [ 1:0] r_mat1;
    wire        r_d1;
    wire        r_v1;

    // CSR-TLB
    wire                   inst_wb_tlbsrch;
    wire                   wb_tlbsrch_found;
    wire [`TLBNUM_IDX-1:0] wb_tlbsrch_idxgot;
    wire [`TLBNUM_IDX-1:0] tlbidx_index_CSRoutput;

    wire        inst_wb_tlbrd;
    
    // tlb block
    wire [`TLB_CONFLICT_BUS_LEN-1:0] es_tlb_zip;
    wire [`TLB_CONFLICT_BUS_LEN-1:0] ms_tlb_zip;

    wire        wb_refetch_flush;

    wire [ 1:0] crmd_plv_CSRoutput;
    wire        dmw0_plv0_CSRoutput;
    wire        dmw0_plv3_CSRoutput;
    wire [ 2:0] dmw0_pseg_CSRoutput;
    wire [ 2:0] dmw0_vseg_CSRoutput;
    wire        dmw1_plv0_CSRoutput;
    wire        dmw1_plv3_CSRoutput;
    wire [ 2:0] dmw1_pseg_CSRoutput;
    wire [ 2:0] dmw1_vseg_CSRoutput;

    wire        dir_addr_trans_mode;
    wire [ 5:0] estat_ecode_CSRoutput;
    wire        is_fs_except;

    assign refetch_target = ertn_flush ? ertn_entry : debug_wb_pc + 32'd4; // Refetch Target

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
        
        .ds_allowin(ds_allowin),
        .br_zip(br_zip),
        .fs2ds_valid(fs2ds_valid),
        .fs2ds_bus(fs2ds_bus),

        .wb_ex(wb_ex),
        .ertn_flush(ertn_flush | wb_refetch_flush),
        .ex_entry(ex_entry),
        .ertn_entry(refetch_target),

        .s0_vppn    (s0_vppn   ),
        .s0_va_bit12(s0_va_bit12),
        .s0_found   (s0_found  ),
        .s0_index   (s0_index  ),
        .s0_ppn     (s0_ppn    ),
        .s0_ps      (s0_ps     ),
        .s0_plv     (s0_plv    ),
        .s0_mat     (s0_mat    ),
        .s0_d       (s0_d      ),
        .s0_v       (s0_v      ),

        .dmw0_vseg_CSRoutput(dmw0_vseg_CSRoutput),
        .dmw0_pseg_CSRoutput(dmw0_pseg_CSRoutput),
        .dmw0_plv0_CSRoutput(dmw0_plv0_CSRoutput),
        .dmw0_plv3_CSRoutput(dmw0_plv3_CSRoutput),
        .dmw1_vseg_CSRoutput(dmw1_vseg_CSRoutput),
        .dmw1_pseg_CSRoutput(dmw1_pseg_CSRoutput),
        .dmw1_plv0_CSRoutput(dmw1_plv0_CSRoutput),
        .dmw1_plv3_CSRoutput(dmw1_plv3_CSRoutput),
        .crmd_plv_CSRoutput(crmd_plv_CSRoutput),
        .dir_addr_trans_mode(dir_addr_trans_mode)
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

        .es_tlb_zip(es_tlb_zip),
        .ms_tlb_zip(ms_tlb_zip),

        .has_int(has_int),
        .wb_ex(wb_ex|ertn_flush|wb_refetch_flush)
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
        .es_tlb_zip(es_tlb_zip),
        .es2ms_valid(es2ms_valid),
        
        .data_sram_req(data_sram_req),
        .data_sram_wr(data_sram_wr),
        .data_sram_size(data_sram_size),
        .data_sram_wstrb(data_sram_wstrb),
        .data_sram_wdata(data_sram_wdata),
        .data_sram_addr(data_sram_addr),
        .data_sram_addr_ok(data_sram_addr_ok),

        .ms_ex(ms_ex),
        .wb_ex(wb_ex|ertn_flush|wb_refetch_flush),

        .invtlb_op   (invtlb_op),
        .inst_invtlb (invtlb_valid),
        .s1_vppn     (s1_vppn),
        .s1_va_bit12 (s1_va_bit12),
        .s1_asid     (s1_asid),
        .s1_found    (s1_found  ),
        .s1_index    (s1_index  ),
        .s1_ppn      (s1_ppn    ),
        .s1_ps       (s1_ps     ),
        .s1_plv      (s1_plv    ),
        .s1_mat      (s1_mat    ),
        .s1_d        (s1_d      ),
        .s1_v        (s1_v      ),
        .tlbehi_vppn_CSRoutput(tlbehi_vppn_CSRoutput),
        .asid_asid_CSRoutput(asid_asid_CSRoutput),

        .dmw0_vseg_CSRoutput(dmw0_vseg_CSRoutput),
        .dmw0_pseg_CSRoutput(dmw0_pseg_CSRoutput),
        .dmw0_plv0_CSRoutput(dmw0_plv0_CSRoutput),
        .dmw0_plv3_CSRoutput(dmw0_plv3_CSRoutput),
        .dmw1_vseg_CSRoutput(dmw1_vseg_CSRoutput),
        .dmw1_pseg_CSRoutput(dmw1_pseg_CSRoutput),
        .dmw1_plv0_CSRoutput(dmw1_plv0_CSRoutput),
        .dmw1_plv3_CSRoutput(dmw1_plv3_CSRoutput),
        .crmd_plv_CSRoutput(crmd_plv_CSRoutput),
        .dir_addr_trans_mode(dir_addr_trans_mode)
    );

    MEMreg my_memReg(
        .clk(clk),
        .resetn(resetn),

        .ms_allowin(ms_allowin),
        .es2ms_bus(es2ms_bus),
        .es_rf_zip(es_rf_zip),
        .ms_tlb_zip(ms_tlb_zip),
        .es2ms_valid(es2ms_valid),
        
        .ws_allowin(ws_allowin),
        .ms_rf_zip(ms_rf_zip),
        .ms2ws_valid(ms2ws_valid),
        .ms2ws_bus(ms2ws_bus),

        .data_sram_data_ok(data_sram_data_ok),
        .data_sram_rdata(data_sram_rdata),

        .ms_ex(ms_ex),
        .wb_ex(wb_ex|ertn_flush|wb_refetch_flush)
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
        .wb_esubcode(wb_esubcode),

        .inst_wb_tlbfill(inst_wb_tlbfill),
        .inst_wb_tlbsrch(inst_wb_tlbsrch),
        .tlb_we      (tlb_we),
        .inst_wb_tlbrd(inst_wb_tlbrd),
        .wb_tlbsrch_found(wb_tlbsrch_found),
        .wb_tlbsrch_idxgot(wb_tlbsrch_idxgot),
        .wb_refetch_flush(wb_refetch_flush),
        .is_fs_except(is_fs_except)
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
        .wb_esubcode(wb_esubcode),

        // CSR-TLB
        .inst_wb_tlbsrch(inst_wb_tlbsrch),
        .tlbsrch_found(wb_tlbsrch_found), //EX生成，WB写入，下同
        .tlbsrch_idxgot(wb_tlbsrch_idxgot),
        .tlbidx_index_CSRoutput(tlbidx_index_CSRoutput),

        .inst_wb_tlbrd(inst_wb_tlbrd),

        .tlbread_e  (r_e), 
        .tlbread_ps (r_ps),
        .tlbread_vppn(r_vppn),
        .tlbread_asid(r_asid),
        .tlbread_g  (r_g),

        .tlbread_ppn0(r_ppn0),
        .tlbread_plv0(r_plv0),
        .tlbread_mat0(r_mat0),
        .tlbread_d0 (r_d0),
        .tlbread_v0 (r_v0),

        .tlbread_ppn1(r_ppn1),
        .tlbread_plv1(r_plv1),
        .tlbread_mat1(r_mat1),
        .tlbread_d1(r_d1),
        .tlbread_v1(r_v1),

        .tlbwr_e	(w_e),
        .tlbwr_ps	(w_ps),
        .tlbehi_vppn_CSRoutput(tlbehi_vppn_CSRoutput),
        .asid_asid_CSRoutput(asid_asid_CSRoutput),
        .tlbwr_g	(w_g),

        .tlbwr_ppn0	(w_ppn0),
        .tlbwr_plv0	(w_plv0),
        .tlbwr_mat0	(w_mat0),
        .tlbwr_d0	(w_d0),
        .tlbwr_v0	(w_v0),

        .tlbwr_ppn1	(w_ppn1),
        .tlbwr_plv1	(w_plv1),
        .tlbwr_mat1	(w_mat1),
        .tlbwr_d1	(w_d1),
        .tlbwr_v1	(w_v1),

        .dmw0_vseg_CSRoutput(dmw0_vseg_CSRoutput),
        .dmw0_pseg_CSRoutput(dmw0_pseg_CSRoutput),
        .dmw0_plv0_CSRoutput(dmw0_plv0_CSRoutput),
        .dmw0_plv3_CSRoutput(dmw0_plv3_CSRoutput),
        .dmw1_vseg_CSRoutput(dmw1_vseg_CSRoutput),
        .dmw1_pseg_CSRoutput(dmw1_pseg_CSRoutput),
        .dmw1_plv0_CSRoutput(dmw1_plv0_CSRoutput),
        .dmw1_plv3_CSRoutput(dmw1_plv3_CSRoutput),
        .crmd_plv_CSRoutput(crmd_plv_CSRoutput),
        .dir_addr_trans_mode(dir_addr_trans_mode),
        .estat_ecode_CSRoutput(estat_ecode_CSRoutput),
        .is_fs_except(is_fs_except)
    );

    tlb u_tlb(
        .clk        (clk       ),

        .s0_vppn    (s0_vppn   ),
        .s0_va_bit12(s0_va_bit12),
        .s0_asid    (asid_asid_CSRoutput),
        .s0_found   (s0_found  ),
        .s0_index   (s0_index  ),
        .s0_ppn     (s0_ppn    ),
        .s0_ps      (s0_ps     ),
        .s0_plv     (s0_plv    ),
        .s0_mat     (s0_mat    ),
        .s0_d       (s0_d      ),
        .s0_v       (s0_v      ),

        .s1_vppn    (s1_vppn   ),
        .s1_va_bit12(s1_va_bit12),
        .s1_asid    (s1_asid   ),
        .s1_found   (s1_found  ),
        .s1_index   (s1_index  ),
        .s1_ppn     (s1_ppn    ),
        .s1_ps      (s1_ps     ),
        .s1_plv     (s1_plv    ),
        .s1_mat     (s1_mat    ),
        .s1_d       (s1_d      ),
        .s1_v       (s1_v      ),

        .invtlb_valid(invtlb_valid),
        .invtlb_op  (invtlb_op ),

        .we         (tlb_we     ),
        .w_index    (tlbidx_index_CSRoutput),
        .w_e        ((estat_ecode_CSRoutput == `ECODE_TLBR) | w_e),
        .w_vppn     (tlbehi_vppn_CSRoutput),
        .w_ps       (w_ps      ),
        .w_asid     (asid_asid_CSRoutput),
        .w_g        (w_g       ),
        .w_ppn0     (w_ppn0    ),
        .w_plv0     (w_plv0    ),
        .w_mat0     (w_mat0    ),
        .w_d0       (w_d0      ),
        .w_v0       (w_v0      ),
        .w_ppn1     (w_ppn1    ),
        .w_plv1     (w_plv1    ),
        .w_mat1     (w_mat1    ),
        .w_d1       (w_d1      ),
        .w_v1       (w_v1      ),

        .r_index    (tlbidx_index_CSRoutput),
        .r_e        (r_e       ),
        .r_vppn     (r_vppn    ),
        .r_ps       (r_ps      ),
        .r_asid     (r_asid    ),
        .r_g        (r_g       ),
        .r_ppn0     (r_ppn0    ),
        .r_plv0     (r_plv0    ),
        .r_mat0     (r_mat0    ),
        .r_d0       (r_d0      ),
        .r_v0       (r_v0      ),
        .r_ppn1     (r_ppn1    ),
        .r_plv1     (r_plv1    ),
        .r_mat1     (r_mat1    ),
        .r_d1       (r_d1      ),
        .r_v1       (r_v1      )
    );

endmodule
