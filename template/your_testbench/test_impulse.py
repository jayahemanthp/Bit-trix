import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import logging

CLK_PERIOD_NS = 10

# Test cases: (x[n], y[n], expected h[n])
# x and y are lists of 8 integers, expected h is list of 8 integers
TEST_CASES = [
    {
        "name": "Impulse response with scale 8",
        "x": [8, 0, 0, 0, 0, 0, 0, 0],
        "y": [8, 8, 0, 0, 0, 0, 0, 0],
        "h": [1, 1, 0, 0, 0, 0, 0, 0]
    },
    {
        "name": "Identity system (x=y)",
        "x": [4, 2, 1, 0, 0, 0, 0, 0],
        "y": [4, 2, 1, 0, 0, 0, 0, 0],
        "h": [1, 0, 0, 0, 0, 0, 0, 0]   # only first sample is 1
    },
    {
        "name": "Two‑tap averaging",
        "x": [8, 8, 0, 0, 0, 0, 0, 0],
        "y": [8, 8, 0, 0, 0, 0, 0, 0],   # same as x, so h = [1,0,...]
        "h": [1, 0, 0, 0, 0, 0, 0, 0]
    },
    {
        "name": "Delayed impulse",
        "x": [8, 0, 0, 0, 0, 0, 0, 0],
        "y": [0, 8, 0, 0, 0, 0, 0, 0],
        "h": [0, 1, 0, 0, 0, 0, 0, 0]
    }
]

async def load_ram(dut, addr_base, data):
    """Backdoor write to RAM (while reset is active)."""
    for i, val in enumerate(data):
        dut.u_ram.mem[addr_base + i].value = val

async def reset_dut(dut):
    """Apply reset and hold for 5 cycles."""
    dut.rst.value = 1
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

@cocotb.test()
async def test_impulse_processor(dut):
    """Run all test cases and verify h[n]."""
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())

    for case in TEST_CASES:
        # Reset and preload RAM
        dut.rst.value = 1
        await RisingEdge(dut.clk)
        await load_ram(dut, 0x00, case["x"])
        await load_ram(dut, 0x08, case["y"])
        await reset_dut(dut)

        # Wait for completion (state == S_DONE = 6)
        while True:
            await RisingEdge(dut.clk)
            if dut.state.value == 6:
                break

        # Read computed h[n]
        h_computed = []
        for i in range(8):
            h_computed.append(int(dut.u_ram.mem[0x38 + i].value))

        # Compare
        if h_computed == case["h"]:
            result = "PASS"
        else:
            result = "FAIL"

        cycles = int(dut.cycle_count.value)
        logging.info("=" * 60)
        logging.info(f"Test: {case['name']} – {result}")
        logging.info(f"  x: {case['x']}")
        logging.info(f"  y: {case['y']}")
        logging.info(f"  Expected h: {case['h']}")
        logging.info(f"  Computed h: {h_computed}")
        logging.info(f"  Total cycles: {cycles}")
        logging.info("=" * 60)

        if result == "FAIL":
            assert False, f"Test '{case['name']}' failed."

    logging.info("All tests passed.")