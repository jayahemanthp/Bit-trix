
# README

## Getting Started

1. Fork this repository to your own account.  
2. Clone your fork locally:
```bash
git clone https://github.com/jayahemanthp/Bit-trix.git
cd Bit-trix
````

---

## Running the Latency Counter

1. Navigate to the simulation directory:

```bash
cd testbench
```

2. Run the simulation:

```bash
make
```

The output will display the total cycle count and corresponding time using the `cycle_count` register.

---

## Implementation Guidelines

* All RTL files are located in:

```bash
src/
```

* Add or modify logic only inside files in `src/`
* Integrate new functionality through `top.v`
* Use the existing `cycle_count` register for latency measurement
* Do **not modify** the `cycle_count` implementation

---

## Constraints / Disclaimers

* RAM contains **64 banks of 8-bit memory** → must not be changed
* Register file contains **4 registers** → must not be changed
* Only internal logic should be modified
* Do **not change input/output ports** unless explicitly instructed

---

## Notes

* All Verilog sources are automatically included via wildcard in the Makefile
* Simulation uses **cocotb + Verilator**
* Waveforms (if enabled) can be viewed using:

```bash
gtkwave dump.vcd
```

