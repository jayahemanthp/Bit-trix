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
 
OPCODE_MAP = {
    NOP:       0b0000,
    MAC:       0b0001,
    LOAD_RAM:  0b0010,
    STORE_RAM: 0b0011,
    LOAD_REG:  0b0100,
    STORE_REG: 0b0101,
}
 
OP_NAMES = {
    NOP:       "NOP",
    MAC:       "MAC",
    LOAD_RAM:  "LOAD_RAM",
    STORE_RAM: "STORE_RAM",
    LOAD_REG:  "LOAD_REG",
    STORE_REG: "STORE_REG",
}
 
REG_NAMES = {R0: "R0", R1: "R1", R2: "R2", R3: "R3"}
 
# ─── Instruction generator ──────────────────────────────────────────────────
def gen_instr(op, reg1, reg2):
    opcode = OPCODE_MAP[op]
    return (opcode << 4) | (reg1 << 2) | reg2
 
# ─── Your program: write instructions here ─────────────────────────────────
# Format: (op, reg1, reg2)
program = [
    (NOP,       R0, R0),   # 0: NOP
    (MAC,       R1, R2),   # 1: R1 = acc + R1 * R2
    (MAC,       R0, R3),   # 2: R0 = acc + R0 * R3
    (STORE_RAM, R1, R0),   # 3: RAM[R0] = R1
    (LOAD_RAM,  R3, R0),   # 4: R3 = RAM[R0]
    (LOAD_REG,  R2, R1),   # 5: R2 = R1 (reg to reg)
    (STORE_REG, R3, R2),   # 6: R3 = R2 (reg to reg)
    (MAC,       R3, R2),   # 7: acc = acc + R3 * R2
    (NOP,       R0, R0),   # 8: NOP
]
 
# ─── Generate and print ─────────────────────────────────────────────────────
print("=" * 60)
print(f"{'PC':<5} {'Instruction':<20} {'Binary':>10}  {'Hex':>6}")
print("=" * 60)
 
instructions = []
for i, (op, reg1, reg2) in enumerate(program):
    instr = gen_instr(op, reg1, reg2)
    instructions.append(instr)
    name = f"{OP_NAMES[op]} {REG_NAMES[reg1]},{REG_NAMES[reg2]}"
    print(f"PC={i:<3} {name:<20} {instr:08b}   {instr:#04x}")
 
print("=" * 60)
print(f"Total instructions: {len(instructions)}")
 
# ─── Write to memory file (loaded by CocotB into RAM) ──────────────────────
with open("program.mem", "w") as f:
    for instr in instructions:
        f.write(f"{instr:08b}\n")
 
print("\nWritten to program.mem — CocotB will load this into instruction RAM")
