TOPLEVEL_LANG = verilog
SIM = verilator

TOPLEVEL = top
MODULE = test_impulse   # your cocotb file name (without .py)
#mention all the source files that are required here.
VERILOG_SOURCES = VERILOG_SOURCES = $(wildcard $(PWD)/../src/*.v)

# 👇 THIS ENABLES WAVES
EXTRA_ARGS += --trace

# Optional but useful
VERILATOR_FLAGS += -Wall

include $(shell cocotb-config --makefiles)/Makefile.sim
