import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import logging

CLK_PERIOD_NS = 10

@cocotb.test()
async def test_impulse_response(dut):
    """Test the impulse response processor with x[n]=[8,0,...], y[n]=[8,8,0,...]"""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())

    # Reset and preload RAM with test vectors
    dut.rst.value = 1
    await RisingEdge(dut.clk)

    # Backdoor write: x[n] = [8,0,0,0,0,0,0,0]
    dut.u_ram.mem[0].value = 8
    for i in range(1, 8):
        dut.u_ram.mem[i].value = 0

    # y[n] = [8,8,0,0,0,0,0,0]
    for i in range(8):
        dut.u_ram.mem[0x08 + i].value = 8 if i < 2 else 0

    # Release reset
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    # Wait for FSM to reach S_DONE (state == 6)
    while True:
        await RisingEdge(dut.clk)
        if dut.state.value == 6:
            break

    # Read computed h[n] from RAM (addresses 0x38..0x3F)
    h = []
    for i in range(8):
        h.append(int(dut.u_ram.mem[0x38 + i].value))

    expected = [1, 1, 0, 0, 0, 0, 0, 0]
    if h == expected:
        cocotb.log.info("PASS: h[n] matches expected")
    else:
        cocotb.log.error(f"FAIL: h[n] = {h}, expected {expected}")

    total_cycles = int(dut.cycle_count.value)
    total_time_ns = total_cycles * CLK_PERIOD_NS
    cocotb.log.info("=" * 50)
    cocotb.log.info("⏱️  SIMULATION SUMMARY")
    cocotb.log.info("=" * 50)
    cocotb.log.info(f"Total Cycles   : {total_cycles}")
    cocotb.log.info(f"Clock Period   : {CLK_PERIOD_NS} ns")
    cocotb.log.info(f"Total Time     : {total_time_ns} ns")
    cocotb.log.info("=" * 50)