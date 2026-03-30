# Memory Access Strategy

## RAM Organization (64 × 8-bit)

| Address Range | Content | Size | Description |
|---------------|---------|------|-------------|
| 0x00-0x07 | x[n] | 8 bytes | Input signal (pre-loaded) |
| 0x08-0x0F | y[n] | 8 bytes | Output signal (pre-loaded) |
| 0x10-0x17 | Xr[k] | 8 bytes | DFT of x[n] - real parts |
| 0x18-0x1F | Xi[k] | 8 bytes | DFT of x[n] - imag parts |
| 0x20-0x27 | Yr[k] | 8 bytes | DFT of y[n] - real parts |
| 0x28-0x2F | Yi[k] | 8 bytes | DFT of y[n] - imag parts |
| 0x30-0x37 | Hr[k] | 8 bytes | H[k] real parts (Y/X) |
| 0x38-0x3F | h[n] | 8 bytes | Final impulse response |
| 0x40-0x3F | - | 24 bytes | Reserved for future use |

## Memory Access Patterns by Phase

### Phase 1: DFT of x[n] → X[k]

#### Stage 0 (Input stage, bit-reversed)
| Cycle | Operation | Address | Data | Description |
|-------|-----------|---------|------|-------------|
| 1 | Read | 0x00 | x[0] | Read A operand |
| 2 | Read | 0x04 | x[4] | Read B operand |
| 3 | Write | 0x10 | Xr[0] | Write A result |
| 4 | Write | 0x14 | Xr[4] | Write B result |
| 5-8 | Repeat | 0x02,0x06 | x[2],x[6] | Next butterfly pair |
| 9-12 | Repeat | 0x01,0x05 | x[1],x[5] | Next butterfly pair |
| 13-16 | Repeat | 0x03,0x07 | x[3],x[7] | Final butterfly pair |

#### Stages 1-2 (In-place computation)
| Cycle | Operation | Address | Data | Description |
|-------|-----------|---------|------|-------------|
| 1 | Read | 0x10 | Xr[0] | Read A from stage 0 |
| 2 | Read | 0x11 | Xr[1] | Read B from stage 0 |
| 3 | Write | 0x10 | Xr[0]' | Write updated A |
| 4 | Write | 0x11 | Xr[1]' | Write updated B |

### Phase 2: DFT of y[n] → Y[k]
- Identical pattern to Phase 1, but using addresses 0x08-0x0F (y[n]) as input
- Results written to 0x20-0x27 (Yr) and 0x28-0x2F (Yi)

### Phase 3: Complex Division H[k] = Y[k]/X[k]

| k | Read Operations | Write Operations |
|---|-----------------|------------------|
| 0 | 0x10 (Xr[0]), 0x18 (Xi[0]), 0x20 (Yr[0]), 0x28 (Yi[0]) | 0x30 (Hr[0]), 0x38 (Hi[0]) |
| 1 | 0x11 (Xr[1]), 0x19 (Xi[1]), 0x21 (Yr[1]), 0x29 (Yi[1]) | 0x31 (Hr[1]), 0x39 (Hi[1]) |
| ... | ... | ... |
| 7 | 0x17 (Xr[7]), 0x1F (Xi[7]), 0x27 (Yr[7]), 0x2F (Yi[7]) | 0x37 (Hr[7]), 0x3F (Hi[7]) |

### Phase 4: IDFT of H[k] → h[n]

| Cycle | Operation | Address | Data | Description |
|-------|-----------|---------|------|-------------|
| 1 | Read | 0x30 | Hr[0] | Read A operand |
| 2 | Read | 0x34 | Hr[4] | Read B operand (bit-reversed) |
| 3 | Write | 0x38 | h[0]' | Write intermediate result |
| 4 | Write | 0x3C | h[4]' | Write intermediate result |
| ... | ... | ... | ... | Continue for all butterflies |

### Phase 5: Scaling (h[n] = h[n] >> 3)

| n | Read Address | Write Address | Operation |
|---|--------------|---------------|-----------|
| 0 | 0x38 | 0x38 | h[0] >> 3 |
| 1 | 0x39 | 0x39 | h[1] >> 3 |
| ... | ... | ... | ... |
| 7 | 0x3F | 0x3F | h[7] >> 3 |

## Memory Access Optimization

### 1. In-place FFT
- X[k] and Y[k] computed in-place to minimize memory usage
- Intermediate results overwrite source data

### 2. Sequential Access Pattern
- Complex division reads data sequentially for better cache efficiency
- k index increments linearly through all 8 points

### 3. Bit-reversal Strategy
- Stage 0 uses bit-reversed addressing for DIT FFT
- Hardware generates bit-reversed addresses automatically

### 4. Memory Bandwidth Requirements
- Maximum: 4 memory accesses per butterfly (2 reads, 2 writes)
- Butterfly unit pipelined to hide memory latency
- 1-cycle latency between read and write

## Address Generation Logic

### Bit-Reversal for N=8 DIT FFT
| Linear Index | Binary | Reversed | Bit-Reversed Index |
|--------------|--------|----------|-------------------|
| 0 | 000 | 000 | 0 |
| 1 | 001 | 100 | 4 |
| 2 | 010 | 010 | 2 |
| 3 | 011 | 110 | 6 |
| 4 | 100 | 001 | 1 |
| 5 | 101 | 101 | 5 |
| 6 | 110 | 011 | 3 |
| 7 | 111 | 111 | 7 |

### Twiddle Factor Addresses
| Stage | Group Size | Twiddle Pattern | Address Formula |
|-------|------------|-----------------|-----------------|
| 0 | 1 | W⁰ only | Fixed index 0 |
| 1 | 2 | W⁰, W² | idx = pair_idx × 2 |
| 2 | 4 | W⁰, W¹, W², W³ | idx = pair_idx |