`include "macro.h"
module WBreg(
    input  wire        clk,
    input  wire        resetn,
    // mem and ws state interface
    output wire        ws_allowin,
    input  wire [`MS2WS_LEN -1:0] ms2ws_bus,
    input  wire [39:0] ms_rf_zip, // {ms_csr_re, ms_rf_we, ms_rf_waddr, ms_rf_wdata}
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
    output      [ 8:0] wb_esubcode,

    // TLB
    output wire         inst_wb_tlbfill,
    output wire         inst_wb_tlbsrch,
    output wire         tlb_we,
    output wire         inst_wb_tlbrd,
    output wire         wb_tlbsrch_found,
    output wire [`TLBNUM_IDX-1:0] wb_tlbsrch_idxgot,
    output wire         wb_refetch_flush,
    output wire         is_fs_except
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

// TLB
    reg  [ 9:0] ms2wb_tlb_zip;
    wire        inst_wb_tlbwr;
    wire        wb_refetch_flag;
    reg  [`TLB_EXC_NUM-1:0] ws_tlb_except_zip;

//state control signal

    assign ws_ready_go      = 1'b1;
    assign ws_allowin       = ~ws_valid | ws_ready_go ;     
    always @(posedge clk) begin
        if(~resetn)
            ws_valid <= 1'b0;
        else if(wb_ex|ertn_flush|wb_refetch_flush)
            ws_valid <= 1'b0;
        else if(ws_allowin)
            ws_valid <= ms2ws_valid; 
    end

//mem and wb state interface

    always @(posedge clk) begin
        if(~resetn) begin
            {wb_vaddr, wb_pc, ws_csr_zip, ws_except_zip, ms2wb_tlb_zip, ws_tlb_except_zip}  <= {`MS2WS_LEN{1'b0}};
            {csr_re, ws_rf_we_tmp, ws_rf_waddr, ws_rf_wdata_tmp} <= 39'b0;
        end
        if(ms2ws_valid & ws_allowin) begin
            {wb_vaddr, wb_pc, ws_csr_zip, ws_except_zip, ms2wb_tlb_zip, ws_tlb_except_zip}  <= ms2ws_bus;
            {csr_re, ws_rf_we_tmp, ws_rf_waddr, ws_rf_wdata_tmp} <= ms_rf_zip;
        end
    end

//wb and csr state interface

    assign {csr_num, csr_wmask, csr_wvalue,  csr_we} = ws_csr_zip & {79{ws_valid}};
    assign {ws_except_ale, ws_except_adef, ws_except_ine, ws_except_int, ws_except_brk, 
            ws_except_sys, ws_ertn} = ws_except_zip;
    assign ertn_flush = ws_ertn & ws_valid;
    assign wb_ex = (ws_except_adef | ws_except_int | ws_except_ale | ws_except_ine |
                    ws_except_brk | ws_except_sys | (|ws_tlb_except_zip)) & ws_valid;
    assign wb_ecode =  ws_except_int ? `ECODE_INT:
                       ws_except_adef? `ECODE_ADE:
                       (ws_tlb_except_zip[`TLB_EXC_TLBR_F] | ws_tlb_except_zip[`TLB_EXC_TLBR_LS]) ? `ECODE_TLBR:
                       ws_tlb_except_zip[`TLB_EXC_PIL] ? `ECODE_PIL:
                       ws_tlb_except_zip[`TLB_EXC_PIS] ? `ECODE_PIS:
                       ws_tlb_except_zip[`TLB_EXC_PIF] ? `ECODE_PIF:
                       ws_tlb_except_zip[`TLB_EXC_PME] ? `ECODE_PME:
                       (ws_tlb_except_zip[`TLB_EXC_PPI_F] | ws_tlb_except_zip[`TLB_EXC_PPI_LS]) ? `ECODE_PPI:
                       ws_except_ale? `ECODE_ALE: 
                       ws_except_sys? `ECODE_SYS:
                       ws_except_brk? `ECODE_BRK:
                       ws_except_ine? `ECODE_INE:
                                      6'b0;   // 未包含ADEM
    assign wb_esubcode = 9'b0;
    assign is_fs_except = ws_except_adef | ws_tlb_except_zip[`TLB_EXC_TLBR_F] | ws_tlb_except_zip[`TLB_EXC_PIF] | ws_tlb_except_zip[`TLB_EXC_PPI_F];

//id and ws state interface

    assign ws_rf_wdata = csr_re ? csr_rvalue : ws_rf_wdata_tmp;
    assign ws_rf_we  = ws_rf_we_tmp & ws_valid & ~wb_ex;
    assign ws_rf_zip = {ws_rf_we & ws_valid, ws_rf_waddr, ws_rf_wdata};

//trace debug interface

    assign debug_wb_pc = wb_pc;
    assign debug_wb_rf_wdata = ws_rf_wdata;
    assign debug_wb_rf_we = {4{ws_rf_we & ws_valid}};
    assign debug_wb_rf_wnum = ws_rf_waddr;

//tlb interface

    assign {wb_refetch_flag, inst_wb_tlbsrch, inst_wb_tlbrd, inst_wb_tlbwr, inst_wb_tlbfill, wb_tlbsrch_found, wb_tlbsrch_idxgot} = ms2wb_tlb_zip;
    assign tlb_we = (inst_wb_tlbwr || inst_wb_tlbfill) && ws_valid;
    assign wb_refetch_flush = wb_refetch_flag && ws_valid;
endmodule
