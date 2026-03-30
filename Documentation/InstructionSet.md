# Instruction Set Architecture (ISA)

## Instruction Format (8-bit)

| Bit 7-4 | Bit 5-4 | Bit 3-2 | Bit 1-0 |
|---------|---------|---------|---------|
| Opcode  | Rd      | Rs1     | Rs2     |

- **Opcode (4 bits)**: Operation to perform
- **Rd (2 bits)**: Destination register (R0-R3)
- **Rs1 (2 bits)**: Source register 1
- **Rs2 (2 bits)**: Source register 2 or immediate address

## Complete Instruction Set (16 instructions)

| Opcode | Mnemonic | Format | Operation | Description |
|--------|----------|--------|-----------|-------------|
| 0x0 | NOP | - | No operation | No operation, stall for one cycle |
| 0x1 | ADD | Rd, Rs1, Rs2 | Rd = Rs1 + Rs2 | Addition with saturation (0-255) |
| 0x2 | SUB | Rd, Rs1, Rs2 | Rd = Rs1 - Rs2 | Subtraction with saturation (0-255) |
| 0x3 | MUL | Rd, Rs1, Rs2 | Rd = (Rs1 × Rs2)[7:0] | Multiplication, keep low byte |
| 0x4 | DIV | Rd, Rs1, Rs2 | Rd = Rs1 ÷ Rs2 | Integer division, 0xFF if divide by zero |
| 0x5 | MAC | Rd, Rs1, Rs2 | Rd = Rd + (Rs1 × Rs2) | Multiply-accumulate with saturation |
| 0x6 | AND | Rd, Rs1, Rs2 | Rd = Rs1 & Rs2 | Bitwise AND |
| 0x7 | OR  | Rd, Rs1, Rs2 | Rd = Rs1 \| Rs2 | Bitwise OR |
| 0x8 | XOR | Rd, Rs1, Rs2 | Rd = Rs1 ^ Rs2 | Bitwise XOR |
| 0x9 | NOT | Rd, Rs1, -   | Rd = ~Rs1 | Bitwise NOT |
| 0xA | SHL | Rd, Rs1, Rs2 | Rd = Rs1 << Rs2[2:0] | Shift left (max 4 bits) |
| 0xB | SHR | Rd, Rs1, Rs2 | Rd = Rs1 >> Rs2[2:0] | Shift right (max 4 bits) |
| 0xC | LOAD | Rd, -, addr | Rd = RAM[addr] | Load from memory |
| 0xD | STORE | -, Rs1, addr | RAM[addr] = Rs1 | Store to memory |
| 0xE | MOV | Rd, Rs1, -   | Rd = Rs1 | Move between registers |
| 0xF | HLT | - | Halt execution | Stop the processor |

## Register Encoding

| Register | Encoding | Usage |
|----------|----------|-------|
| R0 | 00 | Accumulator, result storage |
| R1 | 01 | Loop index / address pointer |
| R2 | 10 | Operand A / temporary |
| R3 | 11 | Operand B / temporary |

## Instruction Examples
; Basic arithmetic
ADD R0, R1, R2 ; R0 = R1 + R2
SUB R0, R1, R2 ; R0 = R1 - R2
MUL R0, R1, R2 ; R0 = low(R1 × R2)

; Memory operations
LOAD R0, R0, 0x10 ; R0 = RAM[0x10]
STORE R0, R0, 0x20 ; RAM[0x20] = R0

; Register operations
MOV R2, R1, R1 ; R2 = R1
MAC R0, R1, R2 ; R0 = R0 + (R1 × R2)

; Logical operations
AND R0, R1, R2 ; R0 = R1 & R2
SHL R0, R1, #2 ; R0 = R1 << 2