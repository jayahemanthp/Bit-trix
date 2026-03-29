// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtop__pch.h"
#include "Vtop.h"
#include "Vtop___024root.h"

// FUNCTIONS
Vtop__Syms::~Vtop__Syms()
{

    // Tear down scope hierarchy
    __Vhier.remove(0, &__Vscope_top);
    __Vhier.remove(&__Vscope_top, &__Vscope_top__u_decoder);
    __Vhier.remove(&__Vscope_top, &__Vscope_top__u_mac);
    __Vhier.remove(&__Vscope_top, &__Vscope_top__u_ram);
    __Vhier.remove(&__Vscope_top, &__Vscope_top__u_regfile);

}

Vtop__Syms::Vtop__Syms(VerilatedContext* contextp, const char* namep, Vtop* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    // Setup scopes
    __Vscope_TOP.configure(this, name(), "TOP", "TOP", 0, VerilatedScope::SCOPE_OTHER);
    __Vscope_top.configure(this, name(), "top", "top", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_top__u_decoder.configure(this, name(), "top.u_decoder", "u_decoder", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_top__u_mac.configure(this, name(), "top.u_mac", "u_mac", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_top__u_ram.configure(this, name(), "top.u_ram", "u_ram", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_top__u_regfile.configure(this, name(), "top.u_regfile", "u_regfile", -9, VerilatedScope::SCOPE_MODULE);

    // Set up scope hierarchy
    __Vhier.add(0, &__Vscope_top);
    __Vhier.add(&__Vscope_top, &__Vscope_top__u_decoder);
    __Vhier.add(&__Vscope_top, &__Vscope_top__u_mac);
    __Vhier.add(&__Vscope_top, &__Vscope_top__u_ram);
    __Vhier.add(&__Vscope_top, &__Vscope_top__u_regfile);

    // Setup export functions
    for (int __Vfinal = 0; __Vfinal < 2; ++__Vfinal) {
        __Vscope_TOP.varInsert(__Vfinal,"clk", &(TOP.clk), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"instr", &(TOP.instr), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,1 ,7,0);
        __Vscope_TOP.varInsert(__Vfinal,"rst", &(TOP.rst), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0);
        __Vscope_top.varInsert(__Vfinal,"acc_reg", &(TOP.top__DOT__acc_reg), false, VLVT_UINT16,VLVD_NODIR|VLVF_PUB_RW,1 ,15,0);
        __Vscope_top.varInsert(__Vfinal,"clk", &(TOP.top__DOT__clk), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top.varInsert(__Vfinal,"instr", &(TOP.top__DOT__instr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top.varInsert(__Vfinal,"load_ram_en", &(TOP.top__DOT__load_ram_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top.varInsert(__Vfinal,"load_reg_en", &(TOP.top__DOT__load_reg_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top.varInsert(__Vfinal,"mac_en", &(TOP.top__DOT__mac_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top.varInsert(__Vfinal,"mac_out", &(TOP.top__DOT__mac_out), false, VLVT_UINT16,VLVD_NODIR|VLVF_PUB_RW,1 ,15,0);
        __Vscope_top.varInsert(__Vfinal,"opcode", &(TOP.top__DOT__opcode), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,3,0);
        __Vscope_top.varInsert(__Vfinal,"ram_rd_data", &(TOP.top__DOT__ram_rd_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top.varInsert(__Vfinal,"ram_wr_en", &(TOP.top__DOT__ram_wr_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top.varInsert(__Vfinal,"rd", &(TOP.top__DOT__rd), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_top.varInsert(__Vfinal,"reg_wr_data", &(TOP.top__DOT__reg_wr_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top.varInsert(__Vfinal,"reg_wr_en", &(TOP.top__DOT__reg_wr_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top.varInsert(__Vfinal,"rs1", &(TOP.top__DOT__rs1), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_top.varInsert(__Vfinal,"rs1_data", &(TOP.top__DOT__rs1_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top.varInsert(__Vfinal,"rs2", &(TOP.top__DOT__rs2), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_top.varInsert(__Vfinal,"rs2_data", &(TOP.top__DOT__rs2_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top.varInsert(__Vfinal,"rst", &(TOP.top__DOT__rst), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top.varInsert(__Vfinal,"store_ram_en", &(TOP.top__DOT__store_ram_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top.varInsert(__Vfinal,"store_reg_en", &(TOP.top__DOT__store_reg_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"instr", &(TOP.top__DOT__u_decoder__DOT__instr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"load_ram_en", &(TOP.top__DOT__u_decoder__DOT__load_ram_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"load_reg_en", &(TOP.top__DOT__u_decoder__DOT__load_reg_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"mac_en", &(TOP.top__DOT__u_decoder__DOT__mac_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"opcode", &(TOP.top__DOT__u_decoder__DOT__opcode), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,3,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"ram_wr_en", &(TOP.top__DOT__u_decoder__DOT__ram_wr_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"rd", &(TOP.top__DOT__u_decoder__DOT__rd), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"reg_wr_en", &(TOP.top__DOT__u_decoder__DOT__reg_wr_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"rs1", &(TOP.top__DOT__u_decoder__DOT__rs1), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"rs2", &(TOP.top__DOT__u_decoder__DOT__rs2), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"store_ram_en", &(TOP.top__DOT__u_decoder__DOT__store_ram_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_decoder.varInsert(__Vfinal,"store_reg_en", &(TOP.top__DOT__u_decoder__DOT__store_reg_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_mac.varInsert(__Vfinal,"WIDTH", const_cast<void*>(static_cast<const void*>(&(TOP.top__DOT__u_mac__DOT__WIDTH))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_top__u_mac.varInsert(__Vfinal,"a", &(TOP.top__DOT__u_mac__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top__u_mac.varInsert(__Vfinal,"acc_in", &(TOP.top__DOT__u_mac__DOT__acc_in), false, VLVT_UINT16,VLVD_NODIR|VLVF_PUB_RW,1 ,15,0);
        __Vscope_top__u_mac.varInsert(__Vfinal,"acc_out", &(TOP.top__DOT__u_mac__DOT__acc_out), false, VLVT_UINT16,VLVD_NODIR|VLVF_PUB_RW,1 ,15,0);
        __Vscope_top__u_mac.varInsert(__Vfinal,"b", &(TOP.top__DOT__u_mac__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top__u_mac.varInsert(__Vfinal,"clk", &(TOP.top__DOT__u_mac__DOT__clk), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_mac.varInsert(__Vfinal,"rst", &(TOP.top__DOT__u_mac__DOT__rst), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_ram.varInsert(__Vfinal,"ADDR_WIDTH", const_cast<void*>(static_cast<const void*>(&(TOP.top__DOT__u_ram__DOT__ADDR_WIDTH))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_top__u_ram.varInsert(__Vfinal,"DEPTH", const_cast<void*>(static_cast<const void*>(&(TOP.top__DOT__u_ram__DOT__DEPTH))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_top__u_ram.varInsert(__Vfinal,"addr", &(TOP.top__DOT__u_ram__DOT__addr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top__u_ram.varInsert(__Vfinal,"clk", &(TOP.top__DOT__u_ram__DOT__clk), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_ram.varInsert(__Vfinal,"i", &(TOP.top__DOT__u_ram__DOT__i), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_top__u_ram.varInsert(__Vfinal,"mem", &(TOP.top__DOT__u_ram__DOT__mem), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,2 ,7,0 ,0,255);
        __Vscope_top__u_ram.varInsert(__Vfinal,"rd_data", &(TOP.top__DOT__u_ram__DOT__rd_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top__u_ram.varInsert(__Vfinal,"wr_data", &(TOP.top__DOT__u_ram__DOT__wr_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top__u_ram.varInsert(__Vfinal,"wr_en", &(TOP.top__DOT__u_ram__DOT__wr_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"clk", &(TOP.top__DOT__u_regfile__DOT__clk), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"i", &(TOP.top__DOT__u_regfile__DOT__i), false, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"rd_addr", &(TOP.top__DOT__u_regfile__DOT__rd_addr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"regs", &(TOP.top__DOT__u_regfile__DOT__regs), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,2 ,7,0 ,0,3);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"rs1_addr", &(TOP.top__DOT__u_regfile__DOT__rs1_addr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"rs1_data", &(TOP.top__DOT__u_regfile__DOT__rs1_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"rs2_addr", &(TOP.top__DOT__u_regfile__DOT__rs2_addr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"rs2_data", &(TOP.top__DOT__u_regfile__DOT__rs2_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"rst", &(TOP.top__DOT__u_regfile__DOT__rst), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"wr_data", &(TOP.top__DOT__u_regfile__DOT__wr_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_top__u_regfile.varInsert(__Vfinal,"wr_en", &(TOP.top__DOT__u_regfile__DOT__wr_en), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
    }
}
