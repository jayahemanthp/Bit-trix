# Datapath Explanation and Register Usage Strategy

![bittrix_system_architecture](bittrix_system_architecture.svg)

## Register Allocation Strategy

### Register Roles

| Register | Role | Description |
|----------|------|-------------|
| **R0** | Accumulator (ACC) | Primary result register, holds intermediate computation results |
| **R1** | Index Register (IDX) | Loop counters, address offsets, stage/iteration tracking |
| **R2** | Operand A (OPA) | First operand for ALU operations, temporary storage |
| **R3** | Operand B (OPB) | Second operand for ALU operations, temporary storage |

### Register Usage Across Phases

#### Phase 1: DFT of x[n] (8-point FFT)

| Stage | R0 | R1 | R2 | R3 |
|-------|----|----|----|-----|
| Stage 0 (twiddle W⁰) | Butterfly result A | Stage/group index | x[a] | x[b] |
| Stage 1 (twiddle W⁰,W²) | Butterfly result A | Stage/group index | Xr[a] | Xr[b] |
| Stage 2 (twiddle W⁰-W³) | Butterfly result A | Stage/group index | Xr[a] | Xr[b] |

#### Phase 2: DFT of y[n] (8-point FFT)

| Stage | R0 | R1 | R2 | R3 |
|-------|----|----|----|-----|
| Stage 0 | Butterfly result A | Stage/group index | y[a] | y[b] |
| Stage 1-2 | Butterfly result A | Stage/group index | Yr[a] | Yr[b] |

#### Phase 3: Complex Division H[k] = Y[k]/X[k]

| Operation | R0 | R1 | R2 | R3 |
|-----------|----|----|----|-----|
| Load Xr[k] | Xr[k] | k | - | - |
| Load Xi[k] | Xi[k] | k | Xr[k] | Xi[k] |
| Load Yr[k] | Yr[k] | k | Xr[k] | Xi[k] |
| Load Yi[k] | Yi[k] | k | Xr[k] | Xi[k] |
| Divide | Hr[k] | k | - | - |

#### Phase 4: IDFT and Scaling

| Operation | R0 | R1 | R2 | R3 |
|-----------|----|----|----|-----|
| Butterfly | Result | Stage/group | Hr[a] | Hr[b] |
| Scale | h[n] >> 3 | n | h_raw | - |

## Datapath Flow

### 1. Fetch Stage
PC → Instruction ROM → Instruction Register → Decoder

- Program Counter points to current instruction
- Instruction fetched into instruction register
- Decoder generates control signals

### 2. Register Read Stage
Decoder → Register File → Read Rs1, Rs2

- Register file reads source registers combinatorially
- Data available for ALU in same cycle

### 3. Execute Stage
ALU Inputs (Rs1, Rs2, ACC) → ALU Operation → Result

- ALU performs operation based on opcode
- Overflow flag set if saturation occurs
- Result ready at end of cycle

### 4. Memory/Writeback Stage
ALU Result → Register File Write
Memory Data → Register File Write (for LOAD)

- Results written to destination register
- Memory operations occur in this stage

## Data Flow for FFT Butterfly
```diagram
┌─────────────────────────────────────────────────────────┐
│ Butterfly Data Flow                                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│             RAM → Register File (LOAD)                  │
│              │                                          │
│              ▼                                          │
│             R2 = A_real, R3 = B_real                    │
│             │                                           │
│             ▼                                           │
│           Butterfly Unit (hardware accelerated)         │
│             │                                           │
│             ▼                                           │
│           R0 = A' (result)                              │
│             │                                           │
│             ▼                                           │
│          Register File → RAM (STORE)                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Memory Access Patterns

### DFT Stage 0 (Bit-reversed input)
- Read: x[0] and x[4], x[2] and x[6], etc.
- Write: Xr[0], Xr[4], Xr[2], Xr[6] to 0x10-0x17

### DFT Stages 1-2 (In-place computation)
- Read: Xr[a], Xr[b] from 0x10-0x17
- Write: Updated values to same locations

### Complex Division
- Sequential access: Xr[k], Xi[k], Yr[k], Yi[k] for k=0..7
- Write: Hr[k], Hi[k] to 0x30-0x37 (Hr) and 0x38-0x3F (Hi temp)

### IDFT and Scaling
- Read: Hr[k] from 0x30-0x37
- Butterfly compute
- Write: h[n] to 0x38-0x3F
- Read and scale: h[n] >> 3
