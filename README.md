# Impulse Response Processor

A hardware-software co-design implementation for computing the impulse response of a discrete-time LTI system using DFT-based deconvolution. This project implements an 8-point FFT/IFFT with complex division to compute h[n] from given input x[n] and output y[n] sequences.

## Overview

This project demonstrates a complete system-on-chip design that:
- Computes the impulse response h[n] from input x[n] and output y[n]
- Uses DFT, complex division, and IDFT in the frequency domain
- Implements a hardwired FSM for efficient execution
- Includes a complete Verilog RTL implementation with hardware accelerators

## Features

- **8-point Radix-2 DIT FFT/IFFT** with hardware butterfly unit
- **Complex divider** for frequency domain deconvolution
- **Saturating arithmetic** with overflow detection
- **4 general-purpose registers** (8-bit each)
- **64×8-bit RAM** for data storage
- **16-instruction ISA** with custom ALU
- **Cocotb testbench** for verification
- **Cycle-accurate simulation** support

## Architecture
```diagram
┌─────────────────────────────────────────────────────────┐
│             Impulse Response Processor                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ┌──────────────┐     ┌──────────────┐                   │
│ │ FSM          │───▶│ Butterfly    │                   │
│ │ Sequencer    │     │ Unit         │                   │
│ └──────────────┘     └──────────────┘                   │
│     │                       │                           │
│     ▼                       ▼                           │
│ ┌──────────────┐      ┌──────────────┐                  │
│ │ Register     │◀──▶ │     ALU      │                  │
│ │ File         │      │              │                  │
│ └──────────────┘      └──────────────┘                  │
│         │                   │                           │
│         └─────────┬─────────┘                           │
|                   ▼                                     │
│             ┌──────────────┐                            │
│             │ RAM          │                            │
│             │ (64×8)       │                            │
│             └──────────────┘                            │
│                    │                                    │
│             ┌──────▼──────┐                             │
│             │ Complex     │                             │
│             │ Divider     │                             │
│             └─────────────┘                             │
└─────────────────────────────────────────────────────────┘
```

## Memory Map

| Address Range | Content | Description |
|---------------|---------|-------------|
| 0x00-0x07 | x[n] | Input signal (pre-loaded) |
| 0x08-0x0F | y[n] | Output signal (pre-loaded) |
| 0x10-0x17 | Xr[k] | DFT of x[n] - real parts |
| 0x18-0x1F | Xi[k] | DFT of x[n] - imag parts |
| 0x20-0x27 | Yr[k] | DFT of y[n] - real parts |
| 0x28-0x2F | Yi[k] | DFT of y[n] - imag parts |
| 0x30-0x37 | Hr[k] | H[k] real parts (Y/X) |
| 0x38-0x3F | h[n] | Final impulse response |

## Instruction Set

The processor implements a 16-instruction ISA:

| Opcode | Mnemonic | Operation |
|--------|----------|-----------|
| 0x0 | NOP | No operation |
| 0x1 | ADD | Rd = Rs1 + Rs2 (saturating) |
| 0x2 | SUB | Rd = Rs1 - Rs2 (saturating) |
| 0x3 | MUL | Rd = low(Rs1 × Rs2) |
| 0x4 | DIV | Rd = Rs1 ÷ Rs2 (0xFF if divide by zero) |
| 0x5 | MAC | Rd = Rd + (Rs1 × Rs2) |
| 0x6 | AND | Rd = Rs1 & Rs2 |
| 0x7 | OR | Rd = Rs1 \| Rs2 |
| 0x8 | XOR | Rd = Rs1 ^ Rs2 |
| 0x9 | NOT | Rd = ~Rs1 |
| 0xA | SHL | Rd = Rs1 << Rs2[2:0] |
| 0xB | SHR | Rd = Rs1 >> Rs2[2:0] |
| 0xC | LOAD | Rd = RAM[addr] |
| 0xD | STORE | RAM[addr] = Rs1 |
| 0xE | MOV | Rd = Rs1 |
| 0xF | HLT | Halt execution |

## Hardware Accelerators

### Butterfly Unit
- Radix-2 Decimation-In-Time (DIT) butterfly
- 1-cycle latency
- Supports both forward and inverse transforms
- Built-in saturation to 8-bit signed range

### Complex Divider
- Computes H[k] = Y[k] / X[k]
- 8-bit signed integer arithmetic
- Divide-by-zero detection
- Saturation to ±127

## Getting Started

### Prerequisites

- **Verilator** (4.0+) or **Icarus Verilog**
- **Python 3.6+** with pip
- **Cocotb** (for testbench)
- **Make** (build system)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/impulse-response-processor.git
cd impulse-response-processor
Install Python dependencies
```
```bash
pip install cocotb
Install Verilator (Ubuntu/WSL2)
```
```bash
sudo apt update
sudo apt install verilator
```
Or on macOS:

```bash
brew install verilator
Running Simulations
Basic Testbench
```
```bash
# Run the Verilog testbench
iverilog -o tb_top tb_top.v top.v alu.v butterfly.v complex_div.v instr_decoder.v ram.v register.v
vvp tb_top
```
Cocotb Testbench
```bash
# Run all test cases
make

# Run with waveform generation
make SIM_ARGS=--wave

# Run specific test
make TESTCASE=test_impulse_processor
```
# Project Structure
```directory
impulse-response-processor/
├── src/
│   ├── top.v                 # Top-level module with FSM
│   ├── alu.v                 # Arithmetic Logic Unit
│   ├── butterfly.v           # Radix-2 butterfly unit
│   ├── complex_div.v         # Complex divider
│   ├── instr_decoder.v       # Instruction decoder
│   ├── ram.v                 # 64×8-bit RAM
│   └── register.v            # Register file (4 registers)
├── testbench/
│   ├── tb_top.v              # Verilog testbench
│   ├── test_impulse.py       # Cocotb testbench
│   └── Makefile              # Build configuration
├── docs/
│   ├── ALU_Block_Diagram.md
│   ├── Instruction_Set.md
│   ├── Memory_Map.md
│   ├── Overflow_Handling.md
│   └── Execution_Trace.md
├── asm/
│   ├── assembly_program.asm  # Reference assembly code
│   └── opcode_gen.py         # Opcode generator
└── README.md
```
# Test Cases

The testbench includes multiple test cases:

Impulse Response with Scale 8

x[n] = [8,0,0,0,0,0,0,0]

y[n] = [8,8,0,0,0,0,0,0]

Expected h[n] = [1,1,0,0,0,0,0,0]

Identity System

x[n] = [4,2,1,0,0,0,0,0]

y[n] = [4,2,1,0,0,0,0,0]

Expected h[n] = [1,0,0,0,0,0,0,0]

Two-Tap Averaging

x[n] = [8,8,0,0,0,0,0,0]

y[n] = [8,8,0,0,0,0,0,0]

Expected h[n] = [1,0,0,0,0,0,0,0]

Delayed Impulse

x[n] = [8,0,0,0,0,0,0,0]

y[n] = [0,8,0,0,0,0,0,0]

Expected h[n] = [0,1,0,0,0,0,0,0]

# Performance
Clock cycles: ~125 cycles for 8-point FFT + complex division

Latency: 1 cycle per butterfly operation

Throughput: Complete impulse response computed in ~125 cycles

# Algorithm
The processor computes h[n] using the following steps:

DFT of x[n] - 8-point Radix-2 DIT FFT

DFT of y[n] - 8-point Radix-2 DIT FFT

Complex Division - H[k] = Y[k] / X[k] for k=0..7

IDFT of H[k] - Inverse FFT (same butterfly with inv=1)

Scaling - Divide by N=8 (right shift by 3)

# Saturation Handling
All arithmetic operations use saturating arithmetic to prevent overflow:

ADD/SUB: Clamped to [0, 255]

MUL: Low 8 bits only, overflow flag set

DIV: 0xFF if divide by zero

MAC: Clamped to [0, 255]

Butterfly: Clamped to [-128, 127]

Complex Div: Clamped to [-128, 127]

Waveform Analysis
Generate VCD waveforms for analysis:

```bash
make SIM_ARGS=--wave
gtkwave sim_build/dump.vcd
```

## Acknowledgments
Bit-Trix 2026 competition for the inspiration
