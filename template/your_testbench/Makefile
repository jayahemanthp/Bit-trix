TOPLEVEL_LANG = verilog
SIM = verilator

SRC_DIR = ../src

TOPLEVEL = top
MODULE = test_impulse   # your cocotb file name (without .py)
#mention all the source files that are required here.
VERILOG_SOURCES = VERILOG_SOURCES = $(wildcard $(SRC_DIR)/*.v)

VERILOG_INCLUDE_DIRS = $(SRC_DIR)

EXTRA_ARGS += --trace



# Optional but useful
VERILATOR_FLAGS += -Wall
VERILATOR_FLAGS += -CFLAGS "-std=c++14" -CXXFLAGS "-std=c++14"
export CXX = g++
export CXXFLAGS = -std=c++14

include $(shell cocotb-config --makefiles)/Makefile.sim
