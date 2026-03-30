TOPLEVEL_LANG = verilog
SIM = verilator

TOPLEVEL = top
MODULE = test_impulse   # your cocotb file name (without .py)
#mention all the source files that are required here.
VERILOG_SOURCES = $(wildcard $(PWD)../src/*.v)

VERILATOR_FLAGS += -CFLAGS "-std=c++14" -CXXFLAGS "-std=c++14"
export CXX = g++
export CXXFLAGS = -std=c++14

include $(shell cocotb-config --makefiles)/Makefile.sim
