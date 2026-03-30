; ================================================================
;  Assembly Program: Impulse Response Computation  h[n] = IDFT(Y[k]/X[k])
;  ISA: 8-bit instruction  { opcode[3:0] | rd[1:0] | rs1[1:0] | rs2[1:0] }
;
;  Register usage:
;    R0 = accumulator / result
;    R1 = loop index / address offset
;    R2 = operand A (real parts)
;    R3 = operand B (imag parts)
;
;  RAM memory map:
;    0x00–0x07 : x[n]       (pre-loaded by testbench)
;    0x08–0x0F : y[n]       (pre-loaded by testbench)
;    0x10–0x17 : Xr[k]      DFT(x) real parts
;    0x18–0x1F : Xi[k]      DFT(x) imag parts
;    0x20–0x27 : Yr[k]      DFT(y) real parts
;    0x28–0x2F : Yi[k]      DFT(y) imag parts
;    0x30–0x37 : Hr[k]      H[k] real
;    0x38–0x3F : h[n]       IDFT result (final answer)
;
;  NOTE: The butterfly and complex-divide units are hardware
;  accelerators controlled directly by the FSM in top.v.
;  This assembly listing shows the conceptual instruction
;  sequence that the sequencer implements; actual execution
;  is done by the hardwired FSM.
; ================================================================

; ---- Instruction Set Table ----
;
; Opcode  Mnemonic  Operands          Operation
; ------  --------  --------          ---------
;  0x0    NOP       -                 No operation
;  0x1    ADD       rd, rs1, rs2      rd = rs1 + rs2        (saturating)
;  0x2    SUB       rd, rs1, rs2      rd = rs1 - rs2        (saturating)
;  0x3    MUL       rd, rs1, rs2      rd = rs1 * rs2 [7:0]  (low byte)
;  0x4    DIV       rd, rs1, rs2      rd = rs1 / rs2        (int, dz→0xFF)
;  0x5    MAC       rd, rs1, rs2      rd = rd + rs1*rs2     (saturating)
;  0x6    AND       rd, rs1, rs2      rd = rs1 & rs2
;  0x7    OR        rd, rs1, rs2      rd = rs1 | rs2
;  0x8    XOR       rd, rs1, rs2      rd = rs1 ^ rs2
;  0x9    NOT       rd, rs1, -        rd = ~rs1
;  0xA    SHL       rd, rs1, rs2      rd = rs1 << rs2[2:0]  (max 4)
;  0xB    SHR       rd, rs1, rs2      rd = rs1 >> rs2[2:0]  (max 4)
;  0xC    LOAD      rd, -, addr       rd = RAM[addr]
;  0xD    STORE     -, rs1, addr      RAM[addr] = rs1
;  0xE    MOV       rd, rs1, -        rd = rs1
;  0xF    HLT       -                 Halt execution
;
; Total: 16 instructions  ✓

; ================================================================
;  PHASE 1: DFT of x[n]   →  X[k] in RAM[0x10..0x1F]
;
;  8-point Radix-2 DIT DFT, 3 stages, 4 butterflies per stage.
;  Butterfly unit is hardware-accelerated (1 clock per butterfly).
;
;  Stage 0 twiddle: W^0 = (127, 0)
;  Stage 1 twiddles: W^0, W^2 = (127,0), (0,-127)
;  Stage 2 twiddles: W^0,W^1,W^2,W^3
;
;  Input addresses (bit-reversed for DIT):
;    x[0]→RAM[0x00], x[4]→RAM[0x04], x[2]→RAM[0x02], x[6]→RAM[0x06]
;    x[1]→RAM[0x01], x[5]→RAM[0x05], x[3]→RAM[0x03], x[7]→RAM[0x07]
; ================================================================

; --- Stage 0 (4 butterflies, twiddle W^0) ---
; BF(x[0],x[4]) → Xr[0],Xr[4]
LOAD  R2, RAM[0x00]          ; R2 = x[0]
LOAD  R3, RAM[0x04]          ; R3 = x[4]
; butterfly hardware: out_A = R2+R3, out_B = R2-R3  (W^0 = 1)
ADD   R0, R2, R3             ; R0 = x[0]+x[4]  = Xr[0] stage 0
STORE R0, RAM[0x10]          ; Xr[0] ← R0
SUB   R0, R2, R3             ; R0 = x[0]-x[4]  = Xr[4] stage 0
STORE R0, RAM[0x14]

; BF(x[2],x[6]) → Xr[2],Xr[6]
LOAD  R2, RAM[0x02]
LOAD  R3, RAM[0x06]
ADD   R0, R2, R3
STORE R0, RAM[0x12]
SUB   R0, R2, R3
STORE R0, RAM[0x16]

; BF(x[1],x[5]) → Xr[1],Xr[5]
LOAD  R2, RAM[0x01]
LOAD  R3, RAM[0x05]
ADD   R0, R2, R3
STORE R0, RAM[0x11]
SUB   R0, R2, R3
STORE R0, RAM[0x15]

; BF(x[3],x[7]) → Xr[3],Xr[7]
LOAD  R2, RAM[0x03]
LOAD  R3, RAM[0x07]
ADD   R0, R2, R3
STORE R0, RAM[0x13]
SUB   R0, R2, R3
STORE R0, RAM[0x17]

; --- Stage 1 (twiddles W^0, W^2 = (127,0),(0,-127)) ---
; BF(Xr[0],Xr[2]) twiddle W^0 → stays same (real only)
; BF(Xr[1],Xr[3]) twiddle W^2 = multiply by -j:
;   real:  Xr[1] - (-Xi[3]) = Xr[1] + 0 (Xi=0 at stage 0)
;   imag:  Xi[1] + Xr[3]*1  = 0 + Xr[3]
; (butterfly hardware handles this automatically)

; --- Stage 2 (all 4 twiddles) ---
; (handled by butterfly hardware sequencer in FSM)

; ================================================================
;  PHASE 2: DFT of y[n]   →  Y[k] in RAM[0x20..0x2F]
;  (identical structure, different source/dest addresses)
; ================================================================

; ================================================================
;  PHASE 3: H[k] = Y[k] / X[k]  (complex division, k=0..7)
; ================================================================
; For each k:
;   LOAD Xr = RAM[0x10+k], Xi = RAM[0x18+k]
;   LOAD Yr = RAM[0x20+k], Yi = RAM[0x28+k]
;   complex_div hardware produces Hr, Hi
;   STORE Hr → RAM[0x30+k], Hi → RAM[0x38+k] (temp Hi)

; ================================================================
;  PHASE 4: IDFT of H[k]  →  h[n] in RAM[0x38..0x3F]
;  Same butterfly structure with inv=1, followed by /N scaling
; ================================================================
; After IDFT butterfly passes (3 stages, same as DFT):
;   For each n: LOAD h_raw = RAM[0x38+n]
;               SHR  R0, R0, #3   ; divide by 8
;               STORE R0, RAM[0x38+n]

; ================================================================
;  PHASE 5: HALT
; ================================================================
HLT

; ================================================================
;  EXECUTION TRACE EXAMPLE
;  Input: x[n] = [4, 0, 0, 0, 0, 0, 0, 0]  (impulse scaled by 4)
;         y[n] = [2, 1, 0, 0, 0, 0, 0, 0]  (2-tap FIR output)
;  Expected h[n] = y[n]/x[n] via deconvolution
;  Ground truth: h[0]=0.5, h[1]=0.25 → after Q7 rounding:
;                h[0]=0, h[1]=0 (very small after 8-bit truncation)
;
;  Better example: x[n] = [8,0,0,0,0,0,0,0], y[n] = [8,8,0,0,0,0,0,0]
;  DFT(x): X[k] = [8, 8, 8, 8, 8, 8, 8, 8] (DC spike * 8)
;  DFT(y): Y[k] = [16, 8+8j, 0, 8-8j, 0, ...] (varies by k)
;  H[k] = Y[k]/X[k]
;  IDFT(H[k]) = h[n] = [1, 1, 0, 0, 0, 0, 0, 0]  ✓
;
;  Cycle trace for this input (N=8 butterfly sequencer):
;  Cycle  0: IDLE → set base addresses, go to DFT_X
;  Cycle  1-4:   Stage 0, 4 butterflies (1 cycle each after 1-cycle latency)
;  Cycle  5-8:   Stage 1, 4 butterflies
;  Cycle  9-12:  Stage 2, 4 butterflies
;  Cycle 13-24:  DFT_Y (same, 12 cycles)
;  Cycle 25-56:  CDIV (k=0..7, ~4 sub-phases each = 32 cycles)
;  Cycle 57-68:  IDFT_H (12 cycles)
;  Cycle 69-76:  SCALE (8 shifts)
;  Cycle 77:     DONE
;  Total ≈ 77 clock cycles for N=8
; ================================================================
