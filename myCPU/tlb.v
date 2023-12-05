module tlb
#(
    parameter TLBNUM = 16
)
(
    input  wire                      clk,

    // search port 0 (for fetching instruction)
    input  wire [              18:0] s0_vppn,
    input  wire                      s0_va_bit12,
    input  wire [               9:0] s0_asid,
    output wire                      s0_found,
    output wire [$clog2(TLBNUM)-1:0] s0_index,
    output wire [              19:0] s0_ppn,
    output wire [               5:0] s0_ps,
    output wire [               1:0] s0_plv,
    output wire [               1:0] s0_mat,
    output wire                      s0_d,
    output wire                      s0_v,

    // search port 1 (for load/store instructions)
    input  wire [              18:0] s1_vppn,
    input  wire                      s1_va_bit12,
    input  wire [               9:0] s1_asid,
    output wire                      s1_found,
    output wire [$clog2(TLBNUM)-1:0] s1_index,
    output wire [              19:0] s1_ppn,
    output wire [               5:0] s1_ps,
    output wire [               1:0] s1_plv,
    output wire [               1:0] s1_mat,
    output wire                      s1_d,
    output wire                      s1_v,

    // invtlb opcode
    input  wire                      invtlb_valid,
    input  wire [               4:0] invtlb_op,

    // write port
    input  wire                      we,
    input  wire [$clog2(TLBNUM)-1:0] w_index,
    input  wire                      w_e,
    input  wire [              18:0] w_vppn,
    input  wire [               5:0] w_ps,
    input  wire [               9:0] w_asid,
    input  wire                      w_g,
    input  wire [              19:0] w_ppn0,
    input  wire [               1:0] w_plv0,
    input  wire [               1:0] w_mat0,
    input  wire                      w_d0,
    input  wire                      w_v0,
    input  wire [              19:0] w_ppn1,
    input  wire [               1:0] w_plv1,
    input  wire [               1:0] w_mat1,
    input  wire                      w_d1,
    input  wire                      w_v1,

    // read port
    input  wire [$clog2(TLBNUM)-1:0] r_index,
    output wire                      r_e,
    output wire [              18:0] r_vppn,
    output wire [               5:0] r_ps,
    output wire [               9:0] r_asid,
    output wire                      r_g,
    output wire [              19:0] r_ppn0,
    output wire [               1:0] r_plv0,
    output wire [               1:0] r_mat0,
    output wire                      r_d0,
    output wire                      r_v0,
    output wire [              19:0] r_ppn1,
    output wire [               1:0] r_plv1,
    output wire [               1:0] r_mat1,
    output wire                      r_d1,
    output wire                      r_v1
);

genvar idx;
// check if matched in parallel
wire [TLBNUM-1:0] match0;
wire [TLBNUM-1:0] match1;
// 1:odd page 0:even page
wire              page_sel_0;
wire              page_sel_1;
// conditions for invtlb_op matching
wire [TLBNUM-1:0] cond1;
wire [TLBNUM-1:0] cond2;
wire [TLBNUM-1:0] cond3;
wire [TLBNUM-1:0] cond4;
// matched index for modifying tlb_e
wire [TLBNUM-1:0] inv_match;
wire [TLBNUM-1:0] inv_match_4;
wire [TLBNUM-1:0] inv_match_5;
// TLB term
reg  [TLBNUM-1:0] tlb_e;
reg  [TLBNUM-1:0] tlb_ps4MB; // pagesize 1:4MB 0:4KB
reg  [      18:0] tlb_vppn [TLBNUM-1:0];
reg  [       9:0] tlb_asid [TLBNUM-1:0];
reg               tlb_g    [TLBNUM-1:0];
reg  [      19:0] tlb_ppn0 [TLBNUM-1:0];
reg  [       1:0] tlb_plv0 [TLBNUM-1:0];
reg  [       1:0] tlb_mat0 [TLBNUM-1:0];
reg               tlb_d0   [TLBNUM-1:0];
reg               tlb_v0   [TLBNUM-1:0];
reg  [      19:0] tlb_ppn1 [TLBNUM-1:0];
reg  [       1:0] tlb_plv1 [TLBNUM-1:0];
reg  [       1:0] tlb_mat1 [TLBNUM-1:0];
reg               tlb_d1   [TLBNUM-1:0];
reg               tlb_v1   [TLBNUM-1:0];

// search TLB
generate
    for (idx = 0; idx < TLBNUM; idx = idx + 1)
    begin : MATCH
        assign match0[idx] = tlb_e[idx] && (s0_vppn[18:9] == tlb_vppn[idx][18:9])
                          && (tlb_ps4MB[idx] || s0_vppn[8:0] == tlb_vppn[idx][8:0])
                          && (s0_asid == tlb_asid[idx] || tlb_g[idx]);
        assign match1[idx] = tlb_e[idx] && (s1_vppn[18:9] == tlb_vppn[idx][18:9])
                          && (tlb_ps4MB[idx] || s1_vppn[8:0] == tlb_vppn[idx][8:0])
                          && (s1_asid == tlb_asid[idx] || tlb_g[idx]);
    end
endgenerate
// search port0 results
assign s0_found   = |match0;
assign s0_index   = {$clog2(TLBNUM){match0[ 0]}} & 0
                  | {$clog2(TLBNUM){match0[ 1]}} & 1
                  | {$clog2(TLBNUM){match0[ 2]}} & 2
                  | {$clog2(TLBNUM){match0[ 3]}} & 3
                  | {$clog2(TLBNUM){match0[ 4]}} & 4
                  | {$clog2(TLBNUM){match0[ 5]}} & 5
                  | {$clog2(TLBNUM){match0[ 6]}} & 6
                  | {$clog2(TLBNUM){match0[ 7]}} & 7
                  | {$clog2(TLBNUM){match0[ 8]}} & 8
                  | {$clog2(TLBNUM){match0[ 9]}} & 9
                  | {$clog2(TLBNUM){match0[10]}} & 10
                  | {$clog2(TLBNUM){match0[11]}} & 11
                  | {$clog2(TLBNUM){match0[12]}} & 12
                  | {$clog2(TLBNUM){match0[13]}} & 13
                  | {$clog2(TLBNUM){match0[14]}} & 14
                  | {$clog2(TLBNUM){match0[15]}} & 15;
assign page_sel_0 = tlb_ps4MB[s0_index] ? s0_vppn[8] : s0_va_bit12; // 4MB页的vppn只有18:9位有效
assign s0_ppn     = page_sel_0 ? tlb_ppn1[s0_index] : tlb_ppn0[s0_index];
assign s0_ps      = tlb_ps4MB[s0_index] ? 6'd21 : 6'd12;
assign s0_plv     = page_sel_0 ? tlb_plv1[s0_index] : tlb_plv0[s0_index];
assign s0_mat     = page_sel_0 ? tlb_mat1[s0_index] : tlb_mat0[s0_index];
assign s0_d       = page_sel_0 ? tlb_d1[s0_index]   : tlb_d0[s0_index];
assign s0_v       = page_sel_0 ? tlb_v1[s0_index]   : tlb_v0[s0_index];
// search port1 results
assign s1_found   = |match1;
assign s1_index   = {$clog2(TLBNUM){match1[ 0]}} & 0
                  | {$clog2(TLBNUM){match1[ 1]}} & 1
                  | {$clog2(TLBNUM){match1[ 2]}} & 2
                  | {$clog2(TLBNUM){match1[ 3]}} & 3
                  | {$clog2(TLBNUM){match1[ 4]}} & 4
                  | {$clog2(TLBNUM){match1[ 5]}} & 5
                  | {$clog2(TLBNUM){match1[ 6]}} & 6
                  | {$clog2(TLBNUM){match1[ 7]}} & 7
                  | {$clog2(TLBNUM){match1[ 8]}} & 8
                  | {$clog2(TLBNUM){match1[ 9]}} & 9
                  | {$clog2(TLBNUM){match1[10]}} & 10
                  | {$clog2(TLBNUM){match1[11]}} & 11
                  | {$clog2(TLBNUM){match1[12]}} & 12
                  | {$clog2(TLBNUM){match1[13]}} & 13
                  | {$clog2(TLBNUM){match1[14]}} & 14
                  | {$clog2(TLBNUM){match1[15]}} & 15;
assign page_sel_1 = tlb_ps4MB[s1_index] ? s1_vppn[8] : s1_va_bit12; // 4MB页的vppn只有18:10位有效
assign s1_ppn     = page_sel_1 ? tlb_ppn1[s1_index] : tlb_ppn0[s1_index];
assign s1_ps      = tlb_ps4MB[s1_index] ? 6'd21 : 6'd12;
assign s1_plv     = page_sel_1 ? tlb_plv1[s1_index] : tlb_plv0[s1_index];
assign s1_mat     = page_sel_1 ? tlb_mat1[s1_index] : tlb_mat0[s1_index];
assign s1_d       = page_sel_1 ? tlb_d1[s1_index]   : tlb_d0[s1_index];
assign s1_v       = page_sel_1 ? tlb_v1[s1_index]   : tlb_v0[s1_index];

// INVTLB
generate
    for (idx = 0; idx < 4; idx = idx + 1)
    begin : COND_AND_MATCH
        assign cond1[idx] = ~tlb_g[idx];
        assign cond2[idx] = tlb_g[idx];
        assign cond3[idx] = s1_asid == tlb_asid[idx];
        assign cond4[idx] = (s1_vppn[18:9] == tlb_vppn[idx][18:9]) && (tlb_ps4MB[idx] || s1_vppn[8:0] == tlb_vppn[idx][8:0]);
        assign inv_match_4[idx] = cond1[idx] && cond3[idx];
        assign inv_match_5[idx] = cond1[idx] && cond3[idx] && cond4[idx];
    end
endgenerate
assign inv_match = (invtlb_op == 5'd0 || invtlb_op == 5'd1) ? {TLBNUM{1'b1}} :
                    invtlb_op == 5'd2                       ? cond2          :
                    invtlb_op == 5'd3                       ? cond1          :
                    invtlb_op == 5'd4                       ? inv_match_4    :
                    invtlb_op == 5'd5                       ? inv_match_5    :
                    invtlb_op == 5'd6                       ? match1         :
                    ~tlb_e; // defalt: do nothing
always @(posedge clk) begin
    if (invtlb_valid)
        tlb_e = ~inv_match & tlb_e;
end

// write TLB
always @(posedge clk) begin
    if (we) begin
        tlb_e    [w_index] <= w_e;
        tlb_vppn [w_index] <= w_vppn;
        tlb_ps4MB[w_index] <= w_ps == 6'd21;
        tlb_asid [w_index] <= w_asid;
        tlb_g    [w_index] <= w_g;
        tlb_ppn0 [w_index] <= w_ppn0;
        tlb_plv0 [w_index] <= w_plv0;
        tlb_mat0 [w_index] <= w_mat0;
        tlb_d0   [w_index] <= w_d0;
        tlb_v0   [w_index] <= w_v0;
        tlb_ppn1 [w_index] <= w_ppn1;
        tlb_plv1 [w_index] <= w_plv1;
        tlb_mat1 [w_index] <= w_mat1;
        tlb_d1   [w_index] <= w_d1;
        tlb_v1   [w_index] <= w_v1;
    end
end

// read TLB
assign r_e    = tlb_e    [r_index];
assign r_vppn = tlb_vppn [r_index];
assign r_ps   = tlb_ps4MB[r_index] ? 6'd21 : 6'd12;
assign r_asid = tlb_asid [r_index];
assign r_g    = tlb_g    [r_index];
assign r_ppn0 = tlb_ppn0 [r_index];
assign r_plv0 = tlb_plv0 [r_index];
assign r_mat0 = tlb_mat0 [r_index];
assign r_d0   = tlb_d0   [r_index];
assign r_v0   = tlb_v0   [r_index];
assign r_ppn1 = tlb_ppn1 [r_index];
assign r_plv1 = tlb_plv1 [r_index];
assign r_mat1 = tlb_mat1 [r_index];
assign r_d1   = tlb_d1   [r_index];
assign r_v1   = tlb_v1   [r_index];

endmodule
