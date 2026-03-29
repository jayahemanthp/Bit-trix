// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop__pch.h"
#include "Vtop___024root.h"

VL_ATTR_COLD void Vtop___024root___eval_static(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_static\n"); );
}

VL_ATTR_COLD void Vtop___024root___eval_initial__TOP(Vtop___024root* vlSelf);

VL_ATTR_COLD void Vtop___024root___eval_initial(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_initial\n"); );
    // Body
    Vtop___024root___eval_initial__TOP(vlSelf);
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
    vlSelf->__Vtrigprevexpr___TOP__rst__0 = vlSelf->rst;
}

VL_ATTR_COLD void Vtop___024root___eval_initial__TOP(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_initial__TOP\n"); );
    // Body
    vlSelf->top__DOT__u_ram__DOT__i = 0U;
    while (VL_GTS_III(32, 0x100U, vlSelf->top__DOT__u_ram__DOT__i)) {
        vlSelf->top__DOT__u_ram__DOT__mem[(0xffU & vlSelf->top__DOT__u_ram__DOT__i)] = 0U;
        vlSelf->top__DOT__u_ram__DOT__i = ((IData)(1U) 
                                           + vlSelf->top__DOT__u_ram__DOT__i);
    }
}

VL_ATTR_COLD void Vtop___024root___eval_final(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_final\n"); );
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__stl(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtop___024root___eval_phase__stl(Vtop___024root* vlSelf);

VL_ATTR_COLD void Vtop___024root___eval_settle(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_settle\n"); );
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelf->__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY((0x64U < __VstlIterCount))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("/home/tarun401/Downloads/bit-trix/Bit-trix/example/latency_tb/../top.v", 1, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vtop___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelf->__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__stl(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VstlTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf);

VL_ATTR_COLD void Vtop___024root___eval_stl(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_stl\n"); );
    // Body
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        Vtop___024root___ico_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD void Vtop___024root___eval_triggers__stl(Vtop___024root* vlSelf);

VL_ATTR_COLD bool Vtop___024root___eval_phase__stl(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__stl\n"); );
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtop___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelf->__VstlTriggered.any();
    if (__VstlExecute) {
        Vtop___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__ico(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VicoTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VicoTriggered.word(0U))) {
        VL_DBG_MSGF("         'ico' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__act(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk or posedge rst)\n");
    }
    if ((2ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @(posedge clk)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__nba(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk or posedge rst)\n");
    }
    if ((2ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @(posedge clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtop___024root___ctor_var_reset(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->rst = VL_RAND_RESET_I(1);
    vlSelf->instr = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__rst = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__instr = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__opcode = VL_RAND_RESET_I(4);
    vlSelf->top__DOT__rd = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__rs1 = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__rs2 = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__reg_wr_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__ram_wr_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__mac_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__load_ram_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__store_ram_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__load_reg_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__store_reg_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__rs1_data = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__rs2_data = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__reg_wr_data = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__mac_out = VL_RAND_RESET_I(16);
    vlSelf->top__DOT__acc_reg = VL_RAND_RESET_I(16);
    vlSelf->top__DOT__ram_rd_data = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__u_decoder__DOT__instr = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__u_decoder__DOT__opcode = VL_RAND_RESET_I(4);
    vlSelf->top__DOT__u_decoder__DOT__rd = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__u_decoder__DOT__rs1 = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__u_decoder__DOT__rs2 = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__u_decoder__DOT__reg_wr_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_decoder__DOT__ram_wr_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_decoder__DOT__mac_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_decoder__DOT__load_ram_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_decoder__DOT__store_ram_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_decoder__DOT__load_reg_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_decoder__DOT__store_reg_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_regfile__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_regfile__DOT__rst = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_regfile__DOT__wr_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_regfile__DOT__rd_addr = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__u_regfile__DOT__rs1_addr = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__u_regfile__DOT__rs2_addr = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__u_regfile__DOT__wr_data = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__u_regfile__DOT__rs1_data = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__u_regfile__DOT__rs2_data = VL_RAND_RESET_I(8);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->top__DOT__u_regfile__DOT__regs[__Vi0] = VL_RAND_RESET_I(8);
    }
    vlSelf->top__DOT__u_regfile__DOT__i = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__u_mac__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_mac__DOT__rst = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_mac__DOT__a = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__u_mac__DOT__b = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__u_mac__DOT__acc_in = VL_RAND_RESET_I(16);
    vlSelf->top__DOT__u_mac__DOT__acc_out = VL_RAND_RESET_I(16);
    vlSelf->top__DOT__u_ram__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_ram__DOT__wr_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__u_ram__DOT__addr = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__u_ram__DOT__wr_data = VL_RAND_RESET_I(8);
    vlSelf->top__DOT__u_ram__DOT__rd_data = VL_RAND_RESET_I(8);
    for (int __Vi0 = 0; __Vi0 < 256; ++__Vi0) {
        vlSelf->top__DOT__u_ram__DOT__mem[__Vi0] = VL_RAND_RESET_I(8);
    }
    vlSelf->top__DOT__u_ram__DOT__i = VL_RAND_RESET_I(32);
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__rst__0 = VL_RAND_RESET_I(1);
}
