import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
 
# ─── Opcode & Register constants ───────────────────────────────────────────
NOP       = 0b000
MAC       = 0b001
LOAD_RAM  = 0b010
STORE_RAM = 0b011
LOAD_REG  = 0b100
STORE_REG = 0b101
 
R0 = 0b00
R1 = 0b01
R2 = 0b10
R3 = 0b11
 
# ─── Opcode generator (mirrors opcode_gen.v) ───────────────────────────────
def gen_instr(op, reg1, reg2):
    opcode_map = {
        NOP:       0b0000,
        MAC:       0b0001,
        LOAD_RAM:  0b0010,
        STORE_RAM: 0b0011,
        LOAD_REG:  0b0100,
        STORE_REG: 0b0101,
    }
    opcode = opcode_map[op]
    return (opcode << 4) | (reg1 << 2) | reg2
 
# ─── Helper ────────────────────────────────────────────────────────────────
async def send_instr(dut, op, reg1, reg2, label):
    instr = gen_instr(op, reg1, reg2)
    dut.instr.value = instr
    await RisingEdge(dut.clk)
    dut._log.info(f"{label} | instr={instr:08b}")
 
# ─── Main Test ─────────────────────────────────────────────────────────────
@cocotb.test()
async def test_mini_cpu(dut):
    """Full system test"""
 
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
 
    # Reset
    dut.rst.value = 1
    dut.instr.value = 0
    await Timer(20, units="ns")
    dut.rst.value = 0
    await RisingEdge(dut.clk)
 
    dut._log.info("===== Simulation Start =====")
 
    # ── Test 1: NOP ──────────────────────────────────────────────────────
    await send_instr(dut, NOP, R0, R0, "NOP")
 
    # ── Test 2: MAC R1, R2 ───────────────────────────────────────────────
    await send_instr(dut, MAC, R1, R2, "MAC R1,R2")
    await RisingEdge(dut.clk)
    dut._log.info(f"MAC R1,R2 → acc_out={dut.u_mac.acc_out.value.integer}")
 
    # ── Test 3: STORE_RAM R1 → RAM[R0] ───────────────────────────────────
    await send_instr(dut, STORE_RAM, R1, R0, "STORE_RAM R1,R0")
    dut._log.info("STORE_RAM: R1 → RAM[R0]")
 
    # ── Test 4: LOAD_RAM R3 ← RAM[R0] ────────────────────────────────────
    await send_instr(dut, LOAD_RAM, R3, R0, "LOAD_RAM R3,R0")
    await RisingEdge(dut.clk)
    dut._log.info(f"LOAD_RAM R3,R0 → ram_rd_data={dut.u_ram.rd_data.value.integer}")
 
    # ── Test 5: LOAD_REG R2 ← R1 (register to register) ─────────────────
    await send_instr(dut, LOAD_REG, R2, R1, "LOAD_REG R2,R1")
    await RisingEdge(dut.clk)
    dut._log.info(f"LOAD_REG R2←R1 → reg_wr_data={dut.u_regfile.regs[2].value.integer}")
 
    # ── Test 6: STORE_REG R3 ← R2 (register to register copy) ───────────
    await send_instr(dut, STORE_REG, R3, R2, "STORE_REG R3,R2")
    await RisingEdge(dut.clk)
    dut._log.info(f"STORE_REG R3←R2 → reg_wr_data={dut.u_regfile.regs[3].value.integer}")
 
    # ── Test 7: MAC R3, R2 ───────────────────────────────────────────────
    await send_instr(dut, MAC, R3, R2, "MAC R3,R2")
    await RisingEdge(dut.clk)
    dut._log.info(f"MAC R3,R2 → acc_out={dut.u_mac.acc_out.value.integer}")
 
    # ── Test 8: NOP ──────────────────────────────────────────────────────
    await send_instr(dut, NOP, R0, R0, "NOP")
 
    dut._log.info("===== Simulation Complete =====")
