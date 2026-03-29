TOPLEVEL_LANG = verilog
SIM = verilator

TOPLEVEL = top
MODULE = test_latency   # your cocotb file name (without .py)

VERILOG_SOURCES = \
    $(PWD)/../top.v \
    $(PWD)/../instr_decoder.v \
    $(PWD)/../opcode_gen.v \
    $(PWD)/../mac_unit.v \
    $(PWD)/../ram.v \
    $(PWD)/../register.v

# 👇 THIS ENABLES WAVES
EXTRA_ARGS += --trace

# Optional but useful
VERILATOR_FLAGS += -Wall

include $(shell cocotb-config --makefiles)/Makefile.sim
