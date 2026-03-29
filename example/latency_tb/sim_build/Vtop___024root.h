// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtop.h for the primary calling header

#ifndef VERILATED_VTOP___024ROOT_H_
#define VERILATED_VTOP___024ROOT_H_  // guard

#include "verilated.h"


class Vtop__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtop___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    // Anonymous structures to workaround compiler member-count bugs
    struct {
        VL_IN8(clk,0,0);
        VL_IN8(rst,0,0);
        VL_IN8(instr,7,0);
        CData/*0:0*/ top__DOT__clk;
        CData/*0:0*/ top__DOT__rst;
        CData/*7:0*/ top__DOT__instr;
        CData/*3:0*/ top__DOT__opcode;
        CData/*1:0*/ top__DOT__rd;
        CData/*1:0*/ top__DOT__rs1;
        CData/*1:0*/ top__DOT__rs2;
        CData/*0:0*/ top__DOT__reg_wr_en;
        CData/*0:0*/ top__DOT__ram_wr_en;
        CData/*0:0*/ top__DOT__mac_en;
        CData/*0:0*/ top__DOT__load_ram_en;
        CData/*0:0*/ top__DOT__store_ram_en;
        CData/*0:0*/ top__DOT__load_reg_en;
        CData/*0:0*/ top__DOT__store_reg_en;
        CData/*7:0*/ top__DOT__rs1_data;
        CData/*7:0*/ top__DOT__rs2_data;
        CData/*7:0*/ top__DOT__reg_wr_data;
        CData/*7:0*/ top__DOT__ram_rd_data;
        CData/*7:0*/ top__DOT__u_decoder__DOT__instr;
        CData/*3:0*/ top__DOT__u_decoder__DOT__opcode;
        CData/*1:0*/ top__DOT__u_decoder__DOT__rd;
        CData/*1:0*/ top__DOT__u_decoder__DOT__rs1;
        CData/*1:0*/ top__DOT__u_decoder__DOT__rs2;
        CData/*0:0*/ top__DOT__u_decoder__DOT__reg_wr_en;
        CData/*0:0*/ top__DOT__u_decoder__DOT__ram_wr_en;
        CData/*0:0*/ top__DOT__u_decoder__DOT__mac_en;
        CData/*0:0*/ top__DOT__u_decoder__DOT__load_ram_en;
        CData/*0:0*/ top__DOT__u_decoder__DOT__store_ram_en;
        CData/*0:0*/ top__DOT__u_decoder__DOT__load_reg_en;
        CData/*0:0*/ top__DOT__u_decoder__DOT__store_reg_en;
        CData/*0:0*/ top__DOT__u_regfile__DOT__clk;
        CData/*0:0*/ top__DOT__u_regfile__DOT__rst;
        CData/*0:0*/ top__DOT__u_regfile__DOT__wr_en;
        CData/*1:0*/ top__DOT__u_regfile__DOT__rd_addr;
        CData/*1:0*/ top__DOT__u_regfile__DOT__rs1_addr;
        CData/*1:0*/ top__DOT__u_regfile__DOT__rs2_addr;
        CData/*7:0*/ top__DOT__u_regfile__DOT__wr_data;
        CData/*7:0*/ top__DOT__u_regfile__DOT__rs1_data;
        CData/*7:0*/ top__DOT__u_regfile__DOT__rs2_data;
        CData/*0:0*/ top__DOT__u_mac__DOT__clk;
        CData/*0:0*/ top__DOT__u_mac__DOT__rst;
        CData/*7:0*/ top__DOT__u_mac__DOT__a;
        CData/*7:0*/ top__DOT__u_mac__DOT__b;
        CData/*0:0*/ top__DOT__u_ram__DOT__clk;
        CData/*0:0*/ top__DOT__u_ram__DOT__wr_en;
        CData/*7:0*/ top__DOT__u_ram__DOT__addr;
        CData/*7:0*/ top__DOT__u_ram__DOT__wr_data;
        CData/*7:0*/ top__DOT__u_ram__DOT__rd_data;
        CData/*0:0*/ __VstlFirstIteration;
        CData/*0:0*/ __VicoFirstIteration;
        CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
        CData/*0:0*/ __Vtrigprevexpr___TOP__rst__0;
        CData/*0:0*/ __VactContinue;
        SData/*15:0*/ top__DOT__mac_out;
        SData/*15:0*/ top__DOT__acc_reg;
        SData/*15:0*/ top__DOT__u_mac__DOT__acc_in;
        SData/*15:0*/ top__DOT__u_mac__DOT__acc_out;
        IData/*31:0*/ top__DOT__u_regfile__DOT__i;
        IData/*31:0*/ top__DOT__u_ram__DOT__i;
        IData/*31:0*/ __VactIterCount;
        VlUnpacked<CData/*7:0*/, 4> top__DOT__u_regfile__DOT__regs;
    };
    struct {
        VlUnpacked<CData/*7:0*/, 256> top__DOT__u_ram__DOT__mem;
    };
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<2> __VactTriggered;
    VlTriggerVec<2> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vtop__Syms* const vlSymsp;

    // PARAMETERS
    static constexpr IData/*31:0*/ top__DOT__u_mac__DOT__WIDTH = 8U;
    static constexpr IData/*31:0*/ top__DOT__u_ram__DOT__DEPTH = 0x00000100U;
    static constexpr IData/*31:0*/ top__DOT__u_ram__DOT__ADDR_WIDTH = 8U;

    // CONSTRUCTORS
    Vtop___024root(Vtop__Syms* symsp, const char* v__name);
    ~Vtop___024root();
    VL_UNCOPYABLE(Vtop___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
