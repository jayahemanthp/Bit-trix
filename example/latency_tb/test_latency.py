import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

# ---------------------------
# Reset
# ---------------------------
async def reset_dut(dut):
    dut.rst.value = 1
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

# ---------------------------
# Run instruction with fixed latency
# ---------------------------
async def run_instruction(dut, instr, latency, name="UNKNOWN"):

    # Issue instruction
    dut.instr.value = instr
    await RisingEdge(dut.clk)

    # Count cycles manually
    for _ in range(latency):
        await RisingEdge(dut.clk)

    cocotb.log.info(f"[{name}] latency = {latency} cycles")

    return latency

# ---------------------------
# Main Test
# ---------------------------
@cocotb.test()
async def test_latency(dut):

    # Clock (10ns)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.instr.value = 0

    await reset_dut(dut)

    # ---------------------------
    # Define instruction latencies
    # (YOU decide these)
    # ---------------------------
    program = [
        (0x01, 1, "ADD"),
        (0x02, 1, "SUB"),
        (0x03, 3, "MUL"),
        (0x04, 5, "MAC"),
        (0x05, 4, "LOAD"),
        (0x06, 4, "STORE"),
    ]

    total_cycles = 0

    # ---------------------------
    # Execute program
    # ---------------------------
    for instr, latency, name in program:
        cycles = await run_instruction(dut, instr, latency, name)
        total_cycles += cycles

    # ---------------------------
    # Report
    # ---------------------------
    cocotb.log.info("===== Program Timing =====")
    cocotb.log.info(f"Total cycles: {total_cycles}")
    cocotb.log.info(f"Instructions: {len(program)}")
    cocotb.log.info(f"Avg CPI: {total_cycles / len(program):.2f}")
