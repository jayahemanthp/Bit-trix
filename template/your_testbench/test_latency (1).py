"""
test_latency.py  –  cocotb testbench for Bit-Trix 2026 impulse response processor
Simulator : Verilator  (via cocotb Makefile)
DUT       : top (top.v)

Tests
-----
1. test_reset          – check cycle_count resets to 0
2. test_dft_x_latency  – measure cycles to complete DFT of x[n] (phase 0 done)
3. test_full_pipeline  – load x[n]/y[n], run full h[n] computation, verify result
4. test_known_impulse  – x[n] = δ[n], y[n] = h_ref[n]  → h[n] == h_ref[n]
5. test_cycle_budget   – assert total cycles ≤ MAX_CYCLES
"""

import cocotb
from cocotb.clock      import Clock
from cocotb.triggers   import RisingEdge, ClockCycles, Timer
from cocotb.result     import TestFailure
import math

# ──────────────────────────────────────────────
# Constants matching top.v / ram.v memory map
# ──────────────────────────────────────────────
ADDR_X      = 0x00   # x[n]  base
ADDR_Y      = 0x08   # y[n]  base
ADDR_XR     = 0x10   # Xr[k] base
ADDR_XI     = 0x18   # Xi[k] base
ADDR_YR     = 0x20   # Yr[k] base
ADDR_YI     = 0x28   # Yi[k] base
ADDR_HR     = 0x30   # Hr[k] base
ADDR_HN     = 0x38   # h[n]  base  ← final answer

N           = 8      # DFT size
CLK_PERIOD  = 10     # ns
MAX_CYCLES  = 200    # total latency budget

# FSM state values (must match top.v localparam)
S_IDLE      = 0
S_DFT_X     = 1
S_DFT_Y     = 2
S_CDIV      = 3
S_IDFT_H    = 4
S_SCALE     = 5
S_DONE      = 6

# ──────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────

async def reset_dut(dut):
    """Apply synchronous reset for 4 cycles."""
    dut.rst.value = 1
    dut.instr.value = 0
    await ClockCycles(dut.clk, 4)
    dut.rst.value = 0
    await RisingEdge(dut.clk)


def load_ram(dut, base_addr, data):
    """
    Backdoor write into DUT's RAM array.
    cocotb hierarchical path: dut.u_ram.mem
    """
    for i, val in enumerate(data):
        dut.u_ram.mem[base_addr + i].value = int(val) & 0xFF


def read_ram(dut, base_addr, length):
    """Backdoor read from DUT's RAM array."""
    return [int(dut.u_ram.mem[base_addr + i].value) for i in range(length)]


def signed8(v):
    """Convert unsigned 8-bit int to signed Python int."""
    v = int(v) & 0xFF
    return v if v < 128 else v - 256


async def wait_for_state(dut, target_state, timeout_cycles=MAX_CYCLES):
    """
    Poll dut.state every rising edge.
    Returns the cycle count at which target_state is first seen.
    Raises TestFailure on timeout.
    """
    for cycle in range(timeout_cycles):
        await RisingEdge(dut.clk)
        if int(dut.state.value) == target_state:
            return cycle + 1
    raise TestFailure(
        f"Timeout: state {target_state} not reached within {timeout_cycles} cycles"
    )


async def wait_done(dut, timeout_cycles=MAX_CYCLES):
    """Wait until FSM reaches S_DONE."""
    return await wait_for_state(dut, S_DONE, timeout_cycles)


def dft8_real(xn):
    """
    Reference N=8 DFT of a real-valued sequence (Python float math).
    Returns (Xr, Xi) lists of length 8.
    """
    Xr, Xi = [], []
    for k in range(N):
        re = sum(xn[n] * math.cos(2 * math.pi * k * n / N) for n in range(N))
        im = sum(-xn[n] * math.sin(2 * math.pi * k * n / N) for n in range(N))
        Xr.append(re)
        Xi.append(im)
    return Xr, Xi


def idft8(Xr, Xi):
    """Reference N=8 IDFT, returns real part list (rounded to int)."""
    out = []
    for n in range(N):
        re = sum(
            Xr[k] * math.cos(2 * math.pi * k * n / N)
            - Xi[k] * math.sin(2 * math.pi * k * n / N)
            for k in range(N)
        ) / N
        out.append(round(re))
    return out


def deconvolve_ref(xn, yn):
    """
    Reference h[n] = IDFT(DFT(y) / DFT(x)).
    Returns integer list (8-bit saturated, signed).
    """
    Xr, Xi = dft8_real(xn)
    Yr, Yi = dft8_real(yn)
    Hr, Hi = [], []
    for k in range(N):
        denom = Xr[k]**2 + Xi[k]**2
        if denom < 1e-9:
            Hr.append(0.0)
            Hi.append(0.0)
        else:
            Hr.append((Yr[k]*Xr[k] + Yi[k]*Xi[k]) / denom)
            Hi.append((Yi[k]*Xr[k] - Yr[k]*Xi[k]) / denom)
    hn = idft8(Hr, Hi)
    # Saturate to 8-bit signed
    return [max(-128, min(127, v)) for v in hn]


# ──────────────────────────────────────────────
# Test 1 – Reset behaviour
# ──────────────────────────────────────────────

@cocotb.test()
async def test_reset(dut):
    """cycle_count must be 0 immediately after reset."""
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD, units="ns").start())
    await reset_dut(dut)
    # One extra cycle so the counter has ticked once post-reset
    await RisingEdge(dut.clk)
    count = int(dut.cycle_count.value)
    assert count <= 2, (
        f"Expected cycle_count ≈ 1 after reset, got {count}"
    )
    dut._log.info(f"[PASS] test_reset  cycle_count={count}")


# ──────────────────────────────────────────────
# Test 2 – FSM transitions (DFT_X → DFT_Y → CDIV)
# ──────────────────────────────────────────────

@cocotb.test()
async def test_fsm_transitions(dut):
    """
    Verify FSM moves through DFT_X → DFT_Y → CDIV in order
    and each transition happens within the latency budget.
    """
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD, units="ns").start())
    load_ram(dut, ADDR_X, [8, 0, 0, 0, 0, 0, 0, 0])
    load_ram(dut, ADDR_Y, [8, 8, 0, 0, 0, 0, 0, 0])
    await reset_dut(dut)

    c1 = await wait_for_state(dut, S_DFT_Y,  timeout_cycles=60)
    dut._log.info(f"DFT_X complete at cycle {c1}")

    c2 = await wait_for_state(dut, S_CDIV,   timeout_cycles=60)
    dut._log.info(f"DFT_Y complete at cycle {c2}")

    c3 = await wait_for_state(dut, S_IDFT_H, timeout_cycles=60)
    dut._log.info(f"CDIV complete at cycle {c3}")

    c4 = await wait_for_state(dut, S_DONE,   timeout_cycles=60)
    dut._log.info(f"DONE at cycle {c4}")

    assert c1 < c2 < c3 < c4, "FSM did not progress in expected order"
    dut._log.info("[PASS] test_fsm_transitions")


# ──────────────────────────────────────────────
# Test 3 – Full pipeline: x=[8,0…], y=[8,8,0…]
# Expected h[n] = [1, 1, 0, 0, 0, 0, 0, 0]
# ──────────────────────────────────────────────

@cocotb.test()
async def test_full_pipeline(dut):
    """
    Load a simple 2-tap FIR test case and verify h[n] output.
    x[n] = [8,0,0,0,0,0,0,0]
    y[n] = [8,8,0,0,0,0,0,0]
    Expected h[n] ≈ [1,1,0,0,0,0,0,0]
    """
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD, units="ns").start())

    xn = [8, 0, 0, 0, 0, 0, 0, 0]
    yn = [8, 8, 0, 0, 0, 0, 0, 0]
    load_ram(dut, ADDR_X, xn)
    load_ram(dut, ADDR_Y, yn)

    await reset_dut(dut)
    cycles = await wait_done(dut)

    hn_hw  = [signed8(v) for v in read_ram(dut, ADDR_HN, N)]
    hn_ref = deconvolve_ref(xn, yn)

    dut._log.info(f"h[n] hw  = {hn_hw}")
    dut._log.info(f"h[n] ref = {hn_ref}")
    dut._log.info(f"Completed in {cycles} cycles")

    # Allow ±1 LSB tolerance for fixed-point rounding
    errors = [abs(hn_hw[i] - hn_ref[i]) for i in range(N)]
    max_err = max(errors)
    assert max_err <= 1, (
        f"h[n] mismatch beyond ±1 LSB\n  hw={hn_hw}\n  ref={hn_ref}\n  err={errors}"
    )
    dut._log.info(f"[PASS] test_full_pipeline  max_err={max_err}  cycles={cycles}")


# ──────────────────────────────────────────────
# Test 4 – Known impulse: x[n]=δ[n], y[n]=h_ref
# h[n] must equal y[n] (identity deconvolution)
# ──────────────────────────────────────────────

@cocotb.test()
async def test_known_impulse(dut):
    """
    When x[n] = δ[n] (unit impulse, scaled by 4),
    h[n] should equal y[n]/4 (the system's impulse response directly).
    Use a 3-tap FIR: h_ref = [2, 1, 3, 0, 0, 0, 0, 0]
    """
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD, units="ns").start())

    scale = 4
    h_ref  = [2, 1, 3, 0, 0, 0, 0, 0]
    xn     = [scale] + [0] * (N - 1)         # scaled impulse
    yn     = [v * scale for v in h_ref]       # y = h convolved with x = h * scale

    load_ram(dut, ADDR_X, xn)
    load_ram(dut, ADDR_Y, yn)

    await reset_dut(dut)
    cycles = await wait_done(dut)

    hn_hw  = [signed8(v) for v in read_ram(dut, ADDR_HN, N)]
    hn_ref = deconvolve_ref(xn, yn)

    dut._log.info(f"h[n] hw  = {hn_hw}")
    dut._log.info(f"h[n] ref = {hn_ref}")

    errors  = [abs(hn_hw[i] - hn_ref[i]) for i in range(N)]
    max_err = max(errors)
    assert max_err <= 1, (
        f"Impulse identity failed\n  hw={hn_hw}\n  ref={hn_ref}\n  err={errors}"
    )
    dut._log.info(f"[PASS] test_known_impulse  max_err={max_err}  cycles={cycles}")


# ──────────────────────────────────────────────
# Test 5 – Cycle budget
# ──────────────────────────────────────────────

@cocotb.test()
async def test_cycle_budget(dut):
    """
    Full pipeline must complete within MAX_CYCLES clock cycles.
    Measures wall-clock cycles via the hardware cycle_count register.
    """
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD, units="ns").start())

    load_ram(dut, ADDR_X, [8, 0, 0, 0, 0, 0, 0, 0])
    load_ram(dut, ADDR_Y, [8, 8, 0, 0, 0, 0, 0, 0])

    await reset_dut(dut)
    cycles = await wait_done(dut)

    hw_count = int(dut.cycle_count.value)

    dut._log.info(
        f"FSM cycles  = {cycles}\n"
        f"HW counter  = {hw_count}\n"
        f"Budget      = {MAX_CYCLES}"
    )
    assert cycles <= MAX_CYCLES, (
        f"Cycle budget exceeded: {cycles} > {MAX_CYCLES}"
    )
    dut._log.info(f"[PASS] test_cycle_budget  {cycles}/{MAX_CYCLES} cycles used")


# ──────────────────────────────────────────────
# Test 6 – Per-phase latency breakdown
# ──────────────────────────────────────────────

@cocotb.test()
async def test_phase_latency_breakdown(dut):
    """
    Measure individual latency of each FSM phase and log them.
    Does not fail unless total exceeds MAX_CYCLES.
    Useful for profiling optimisation.
    """
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD, units="ns").start())

    load_ram(dut, ADDR_X, [8, 0, 0, 0, 0, 0, 0, 0])
    load_ram(dut, ADDR_Y, [8, 8, 0, 0, 0, 0, 0, 0])
    await reset_dut(dut)

    # Sample cycle_count at each FSM boundary
    t_start    = int(dut.cycle_count.value)

    await wait_for_state(dut, S_DFT_Y)
    t_dft_x    = int(dut.cycle_count.value)

    await wait_for_state(dut, S_CDIV)
    t_dft_y    = int(dut.cycle_count.value)

    await wait_for_state(dut, S_IDFT_H)
    t_cdiv     = int(dut.cycle_count.value)

    await wait_for_state(dut, S_SCALE)
    t_idft     = int(dut.cycle_count.value)

    await wait_for_state(dut, S_DONE)
    t_done     = int(dut.cycle_count.value)

    dut._log.info("──── Phase latency breakdown ────")
    dut._log.info(f"  DFT  x[n]   : {t_dft_x - t_start:>4} cycles")
    dut._log.info(f"  DFT  y[n]   : {t_dft_y - t_dft_x:>4} cycles")
    dut._log.info(f"  CDIV H[k]   : {t_cdiv  - t_dft_y:>4} cycles")
    dut._log.info(f"  IDFT H[k]   : {t_idft  - t_cdiv:>4} cycles")
    dut._log.info(f"  Scale ÷8    : {t_done  - t_idft:>4} cycles")
    dut._log.info(f"  TOTAL       : {t_done  - t_start:>4} cycles  (budget {MAX_CYCLES})")
    dut._log.info("─────────────────────────────────")

    assert (t_done - t_start) <= MAX_CYCLES, (
        f"Total latency {t_done - t_start} exceeds budget {MAX_CYCLES}"
    )
    dut._log.info("[PASS] test_phase_latency_breakdown")


# ──────────────────────────────────────────────
# Test 7 – RAM persistence: h[n] stays in RAM
# ──────────────────────────────────────────────

@cocotb.test()
async def test_ram_persistence(dut):
    """
    After S_DONE, verify that h[n] values remain stable in RAM
    across 10 additional clock cycles (no spurious writes).
    """
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD, units="ns").start())

    load_ram(dut, ADDR_X, [8, 0, 0, 0, 0, 0, 0, 0])
    load_ram(dut, ADDR_Y, [8, 8, 0, 0, 0, 0, 0, 0])
    await reset_dut(dut)
    await wait_done(dut)

    snap1 = read_ram(dut, ADDR_HN, N)
    await ClockCycles(dut.clk, 10)
    snap2 = read_ram(dut, ADDR_HN, N)

    assert snap1 == snap2, (
        f"h[n] changed after DONE:\n  before={snap1}\n  after={snap2}"
    )
    dut._log.info(f"[PASS] test_ram_persistence  h[n]={snap1}")


# ──────────────────────────────────────────────
# Test 8 – Overflow / saturation: large inputs
# ──────────────────────────────────────────────

@cocotb.test()
async def test_saturation(dut):
    """
    Drive x[n] and y[n] with max values (0xFF) and confirm the
    DUT produces a finite (non-X/Z) h[n] without hanging.
    """
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD, units="ns").start())

    xn = [127] + [0] * (N - 1)
    yn = [127, 63] + [0] * (N - 2)
    load_ram(dut, ADDR_X, xn)
    load_ram(dut, ADDR_Y, yn)

    await reset_dut(dut)
    cycles = await wait_done(dut)

    hn_raw = read_ram(dut, ADDR_HN, N)
    # All values must be valid 8-bit integers (no X/Z = cocotb would raise)
    for i, v in enumerate(hn_raw):
        assert 0 <= v <= 255, f"h[{i}]={v} out of 8-bit range"

    dut._log.info(f"[PASS] test_saturation  h[n]={hn_raw}  cycles={cycles}")
