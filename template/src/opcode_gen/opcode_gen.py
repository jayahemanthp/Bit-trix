# Instruction set encoding (matches top.v)
OPCODES = {
    "NOP":   "0000", "ADD":   "0001", "SUB":   "0010", "MUL":   "0011",
    "DIV":   "0100", "MAC":   "0101", "AND":   "0110", "OR":    "0111",
    "XOR":   "1000", "NOT":   "1001", "SHL":   "1010", "SHR":   "1011",
    "LOAD":  "1100", "STORE": "1101", "MOV":   "1110", "HLT":   "1111"
}

REGS = {"R0": "00", "R1": "01", "R2": "10", "R3": "11"}

# Conceptual assembly program for impulse response computation
program = [
    # Phase 1: DFT of x[n] – Stage 0, first butterfly
    ("LOAD", "R2", "R0", "0x00"),   # R2 = x[0]
    ("LOAD", "R3", "R1", "0x04"),   # R3 = x[4]
    ("ADD",  "R0", "R2", "R3"),     # R0 = x[0] + x[4]
    ("STORE","R0", "R0", "0x10"),   # Xr[0] = R0
    ("SUB",  "R0", "R2", "R3"),     # R0 = x[0] - x[4]
    ("STORE","R0", "R0", "0x14"),   # Xr[4] = R0
    # ... (full program would continue)
    ("HLT",  "-",  "-",  "-")
]

print(f"{'PC':<5} {'Mnemonic':<25} {'Binary'}")
print("-" * 45)

with open("program.asm", "w") as f:
    for i, (op, r1, r2, _) in enumerate(program):
        # For instructions without register fields, fill with "00"
        rd = REGS.get(r1, "00")
        rs1 = REGS.get(r2, "00")
        rs2 = "00"  # placeholder for immediate
        binary = OPCODES[op] + rd + rs1 + rs2
        print(f"PC={i:<3} {op:<6} {r1:<3},{r2:<3}    {binary}")
        f.write(binary + "\n")

print("-" * 45)
print(f"Total: {len(program)} instructions written to program.asm")