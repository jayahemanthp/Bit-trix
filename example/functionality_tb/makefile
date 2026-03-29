# CocotB Makefile for Mini CPU System
 
# Simulator: use iverilog (free) or xsim (Vivado)
SIM      = icarus
TOPLEVEL_LANG = verilog
 
# All design source files
VERILOG_SOURCES  = $(PWD)/mac_unit.v
VERILOG_SOURCES += $(PWD)/reg_file.v
VERILOG_SOURCES += $(PWD)/ram.v
VERILOG_SOURCES += $(PWD)/instr_decoder.v
VERILOG_SOURCES += $(PWD)/opcode_gen.v
VERILOG_SOURCES += $(PWD)/top.v
 
# Top level DUT module
TOPLEVEL = top
 
# Python testbench file (without .py)
MODULE = tb_top_cocotb
 
include $(shell cocotb-config --makefiles)/Makefile.sim
 
