`ifndef MACRO
    `define MACRO

//macros for bus

    `define FS2DS_LEN 73  // from 65 added 8 bits for tlb exceptions
    `define DS2ES_LEN 269 // from 261 added 8 bits for tlb exceptions
    `define ES2MS_LEN 142 // from 134 added 8 bits for tlb exceptions
    `define MS2WS_LEN 168 // from 160 added 8 bits for tlb exceptions

    `define TLB_CONFLICT_BUS_LEN 16 // added for tlb

//macros for TLB

    `define TLBNUM          16
    `define TLBNUM_IDX      $clog2(`TLBNUM)
    `define PALEN           32
    `define TLB_EXC_NUM     8
    `define TLB_EXC_TLBR_F  0
    `define TLB_EXC_TLBR_LS 1
    `define TLB_EXC_PIL     2
    `define TLB_EXC_PIS     3
    `define TLB_EXC_PIF     4
    `define TLB_EXC_PME     5
    `define TLB_EXC_PPI_F   6
    `define TLB_EXC_PPI_LS  7

//macros for csr

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
    // TLB-related csr_num 
    `define CSR_TLBIDX      14'h10
    `define CSR_TLBEHI      14'h11
    `define CSR_TLBELO0     14'h12
    `define CSR_TLBELO1     14'h13
    `define CSR_ASID        14'h18
    `define CSR_TLBRENTRY   14'h88
    `define CSR_DMW0        14'h180     
    `define CSR_DMW1        14'h181     
    // TODO: Cache-related csr_num 

    // macros for index
    `define CSR_CRMD_PLV    1 : 0
    `define CSR_CRMD_IE     2
    `define CSR_CRMD_DA     3
    `define CSR_CRMD_PG     4
    `define CSR_CRMD_DATF   6 : 5
    `define CSR_CRMD_DATM   8 : 7
    `define CSR_PRMD_PPLV   1 : 0
    `define CSR_PRMD_PIE    2
    `define CSR_ECFG_LIE    12: 0
    `define CSR_ESTAT_IS10  1 : 0
    `define CSR_ERA_PC      31: 0
    `define CSR_EENTRY_VA   31: 6
    `define CSR_SAVE_DATA   31: 0
    `define CSR_TID_TID     31: 0
    `define CSR_TCFG_EN     0
    `define CSR_TCFG_PERIOD 1
    `define CSR_TCFG_INITV  31: 2
    `define CSR_TICLR_CLR   0
    // macros for index - tlb-related
    `define CSR_TLBIDX_INDEX  `TLBNUM_IDX-1: 0
    `define CSR_TLBIDX_PS     29:24
    `define CSR_TLBIDX_NE     31
    `define CSR_TLBEHI_VPPN   31:13
    `define CSR_TLBELO_V      0
    `define CSR_TLBELO_D      1
    `define CSR_TLBELO_PLV    3 : 2
    `define CSR_TLBELO_MAT    5 : 4
    `define CSR_TLBELO_G      6
    `define CSR_TLBELO_PPN    `PALEN-5: 8
    `define CSR_ASID_ASID     9 : 0
    `define CSR_ASID_ASIDBITS 23:16
    `define CSR_TLBRENTRY_PA  31: 6
    `define CSR_DMW_PLV0      0
    `define CSR_DMW_PLV3      3
    `define CSR_DMW_MAT       5 : 4
    `define CSR_DMW_PSEG      27:25
    `define CSR_DMW_VSEG      31:29

    // macros for ecode and esubcode
    `define ECODE_INT       6'h00
    `define ECODE_PIL       6'h01
    `define ECODE_PIS       6'h02
    `define ECODE_PIF       6'h03
    `define ECODE_PME       6'h04
    `define ECODE_PPI       6'h07
    `define ECODE_ADE       6'h08   
    `define ECODE_ALE       6'h09   
    `define ECODE_SYS       6'h0B
    `define ECODE_BRK       6'h0C   
    `define ECODE_INE       6'h0D
    `define ECODE_TLBR      6'h3F
    
    `define ESUBCODE_ADEF   9'h00



`endif
