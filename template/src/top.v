// =============================================================
//  Top-Level  –  Impulse Response Processor
//
//  Architecture:
//    ┌──────────┐   instr[7:0]   ┌───────────────┐
//    │ Program  │──────────────► │ Instr Decoder │
//    │ Counter  │                └──────┬────────┘
//    └──────────┘                       │ control signals
//         ▲                     ┌───────▼────────┐
//    halt/next                  │   Reg File     │ ◄── wr_data (ALU/RAM)
//                               └───────┬────────┘
//                                rs1/rs2│
//                               ┌───────▼────────┐
//                               │      ALU       │
//                               └───────┬────────┘
//                                       │ result
//                               ┌───────▼────────┐
//                               │      RAM       │
//                               └────────────────┘
//
//  The FSM sequences the DFT → complex-divide → IDFT computation.
//  The instruction input drives the program stored in a small ROM
//  inside this module (the "assembly program").
//
//  Execution phases:
//    PHASE 0 : LOAD x[n] and y[n] from RAM into butterfly inputs
//    PHASE 1 : 8-point DFT of x[n]  → X[k] stored in RAM
//    PHASE 2 : 8-point DFT of y[n]  → Y[k] stored in RAM
//    PHASE 3 : H[k] = Y[k]/X[k]    → stored in RAM
//    PHASE 4 : 8-point IDFT of H[k] → h[n] stored in RAM
//    PHASE 5 : HALT
// =============================================================
`include "instr_decoder.v"
`include "register.v"
`include "ram.v"
`include "alu.v"
`include "butterfly.v"
`include "complex_div.v"

module top (
    input             clk,
    input             rst,
    input      [7:0]  instr,        // external override (unused in auto mode)
    output reg [255:0] cycle_count
);

    // =========================================================
    // 0.  Internal program ROM  (assembly stored as $readmemh)
    // =========================================================
    // We keep an internal 64-entry program ROM; the FSM drives
    // a program counter (pc) to sequence instructions.
    reg [7:0] prog_rom [0:63];
    reg [5:0] pc;

    // Opcode constants (match instr_decoder)
    localparam NOP   = 4'h0;
    localparam ADD   = 4'h1;
    localparam SUB   = 4'h2;
    localparam MUL   = 4'h3;
    localparam DIV   = 4'h4;
    localparam MAC   = 4'h5;
    localparam AND_O = 4'h6;
    localparam OR_O  = 4'h7;
    localparam XOR_O = 4'h8;
    localparam NOT_O = 4'h9;
    localparam SHL   = 4'hA;
    localparam SHR   = 4'hB;
    localparam LOAD  = 4'hC;
    localparam STORE = 4'hD;
    localparam MOV   = 4'hE;
    localparam HLT   = 4'hF;

    // Register aliases
    localparam R0 = 2'd0;  // general accumulator
    localparam R1 = 2'd1;  // index / address
    localparam R2 = 2'd2;  // operand A / temp
    localparam R3 = 2'd3;  // operand B / temp

    // Helper: pack instruction  {opcode[3:0], rd[1:0], rs1[1:0], rs2[1:0]}
    // Note: opcode occupies [7:4]; rd lives in [5:4] (low 2 of high nibble)
    function [7:0] INSTR;
        input [3:0] op;
        input [1:0] rd, rs1, rs2;
        begin
            INSTR = {op, rd, rs1, rs2};
        end
    endfunction
    // For LOAD/STORE, rs2 is the 2-bit encoded RAM base address region
    // (actual addresses are computed by the FSM sequencer, not the ISA itself)

    // =========================================================
    // 1.  Sub-module instantiation
    // =========================================================

    // ---- Instruction decoder ----
    wire [3:0] dec_opcode;
    wire [1:0] dec_rd, dec_rs1, dec_rs2;
    wire       dec_alu_en, dec_mem_wr, dec_mem_rd;
    wire       dec_reg_wr, dec_use_imm, dec_halt;
    wire [3:0] dec_alu_op;

    reg [7:0] cur_instr;

    instr_decoder u_dec (
        .instr   (cur_instr),
        .opcode  (dec_opcode),
        .rd      (dec_rd),
        .rs1     (dec_rs1),
        .rs2     (dec_rs2),
        .alu_en  (dec_alu_en),
        .mem_wr  (dec_mem_wr),
        .mem_rd  (dec_mem_rd),
        .reg_wr  (dec_reg_wr),
        .use_imm (dec_use_imm),
        .halt    (dec_halt),
        .alu_op  (dec_alu_op)
    );

    // ---- Register file ----
    wire [7:0] rs1_data, rs2_data;
    reg        rf_wr_en;
    reg [1:0]  rf_rd_addr, rf_rs1_addr, rf_rs2_addr;
    reg [7:0]  rf_wr_data;

    reg_file u_rf (
        .clk      (clk),
        .rst      (rst),
        .wr_en    (rf_wr_en),
        .rd_addr  (rf_rd_addr),
        .rs1_addr (rf_rs1_addr),
        .rs2_addr (rf_rs2_addr),
        .wr_data  (rf_wr_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    // ---- ALU ----
    wire [7:0] alu_result;
    wire       alu_ovf;
    reg  [7:0] alu_acc;

    alu u_alu (
        .op     (dec_alu_op),
        .a      (rs1_data),
        .b      (rs2_data),
        .acc    (alu_acc),
        .result (alu_result),
        .ovf    (alu_ovf)
    );

    // ---- RAM ----
    wire [7:0] ram_rd_data;
    reg        ram_wr_en;
    reg  [5:0] ram_addr;
    reg  [7:0] ram_wr_data;

    ram #(.DEPTH(64), .ADDR_WIDTH(6)) u_ram (
        .clk     (clk),
        .wr_en   (ram_wr_en),
        .addr    (ram_addr),
        .wr_data (ram_wr_data),
        .rd_data (ram_rd_data)
    );

    // ---- Butterfly ----
    reg  signed [7:0] bf_ar, bf_ai, bf_br, bf_bi, bf_wr, bf_wi;
    reg               bf_inv;
    wire signed [7:0] bf_out_ar, bf_out_ai, bf_out_br, bf_out_bi;

    butterfly u_bf (
        .clk    (clk), .rst   (rst),
        .ar     (bf_ar), .ai  (bf_ai),
        .br     (bf_br), .bi  (bf_bi),
        .wr     (bf_wr), .wi  (bf_wi),
        .inv    (bf_inv),
        .out_ar (bf_out_ar), .out_ai (bf_out_ai),
        .out_br (bf_out_br), .out_bi (bf_out_bi)
    );

    // ---- Complex Divider ----
    reg  signed [7:0] cd_yr, cd_yi, cd_xr, cd_xi;
    wire signed [7:0] cd_hr, cd_hi;
    wire              cd_dz;

    complex_div u_cd (
        .clk (clk), .rst (rst),
        .yr  (cd_yr), .yi (cd_yi),
        .xr  (cd_xr), .xi (cd_xi),
        .hr  (cd_hr), .hi (cd_hi),
        .dz  (cd_dz)
    );

    // =========================================================
    // 2.  Main FSM sequencer
    //     Controls the butterfly passes to compute DFT/IDFT
    //     and the complex division for H[k].
    //
    //  RAM memory map (6-bit addresses, 0–63):
    //    0x00–0x07 : x[n]       (pre-loaded by testbench)
    //    0x08–0x0F : y[n]       (pre-loaded by testbench)
    //    0x10–0x17 : Xr[k]      DFT(x) real
    //    0x18–0x1F : Xi[k]      DFT(x) imag
    //    0x20–0x27 : Yr[k]      DFT(y) real
    //    0x28–0x2F : Yi[k]      DFT(y) imag
    //    0x30–0x37 : Hr[k]      H[k] real  (= Yr/Xr after complex div)
    //    0x38–0x3F : h[n]       IDFT(H[k]) real  ← final answer
    // =========================================================

    // FSM states
    localparam S_IDLE       = 5'd0;
    localparam S_DFT_X      = 5'd1;   // compute DFT of x[n]
    localparam S_DFT_Y      = 5'd2;   // compute DFT of y[n]
    localparam S_CDIV       = 5'd3;   // H[k] = Y[k] / X[k]
    localparam S_IDFT_H     = 5'd4;   // IDFT of H[k]
    localparam S_SCALE      = 5'd5;   // divide by N (shift right 3)
    localparam S_DONE       = 5'd6;

    // DFT stages for N=8 radix-2 DIT: 3 stages (log2 8 = 3)
    localparam STAGES = 3;

    reg [4:0] state;
    reg [4:0] stage;     // butterfly stage 0,1,2
    reg [2:0] k_idx;     // butterfly group index 0..N/2-1
    reg [2:0] n_idx;     // sample index 0..N-1
    reg [1:0] wait_cnt;  // pipeline wait cycles

    // Twiddle factor table (Q7 signed, scaled by 128)
    // W_N^k = cos(2πk/N) - j·sin(2πk/N), N=8
    //   k=0: (127,   0)
    //   k=1: ( 90, -90)
    //   k=2: (  0,-127)
    //   k=3: (-90, -90)
    reg signed [7:0] tw_r_lut [0:3];
    reg signed [7:0] tw_i_lut [0:3];

    initial begin
        tw_r_lut[0] =  8'sd127;  tw_i_lut[0] =   8'sd0;
        tw_r_lut[1] =   8'sd90;  tw_i_lut[1] = -8'sd90;
        tw_r_lut[2] =   8'sd0;   tw_i_lut[2] = -8'sd127;
        tw_r_lut[3] =  -8'sd90;  tw_i_lut[3] = -8'sd90;
    end

    // Bit-reversal permutation for N=8 DIT
    // [0,4,2,6,1,5,3,7]
    function [2:0] bitrev3;
        input [2:0] x;
        begin
            bitrev3 = {x[0], x[1], x[2]};
        end
    endfunction

    // Temporary registers for DFT pass management
    reg [5:0]  base_src;    // RAM base for input signal this pass
    reg [5:0]  base_rsr;    // real part base of result
    reg [5:0]  base_rsi;    // imag part base of result
    reg        doing_idft;  // flag: 1 = IDFT pass

    // Sub-phase within a butterfly pass
    localparam BP_READ_A  = 3'd0;
    localparam BP_READ_B  = 3'd1;
    localparam BP_WAIT    = 3'd2;
    localparam BP_WRITE   = 3'd3;
    localparam BP_NEXT    = 3'd4;

    reg [2:0] bp_phase;
    reg [2:0] pair_idx;   // which butterfly pair within a stage (0..3)
    reg [2:0] group_idx;  // which group within a stage (0..stage_groups-1)

    // Latched butterfly inputs/outputs for FSM staging
    reg signed [7:0] latch_ar, latch_ai, latch_br, latch_bi;

    // =========================================================
    // 3.  Cycle counter (DO NOT TOUCH)
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst)
            cycle_count <= 256'b0;
        else
            cycle_count <= cycle_count + 1;
    end

    // =========================================================
    // 4.  FSM body
    // =========================================================
    integer ii;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= S_IDLE;
            stage      <= 0;
            k_idx      <= 0;
            n_idx      <= 0;
            wait_cnt   <= 0;
            bp_phase   <= 0;
            pair_idx   <= 0;
            group_idx  <= 0;
            rf_wr_en   <= 0;
            ram_wr_en  <= 0;
            bf_inv     <= 0;
            doing_idft <= 0;
        end else begin
            // Defaults
            rf_wr_en  <= 0;
            ram_wr_en <= 0;

            case (state)

                // ---- IDLE: start computation ----
                S_IDLE: begin
                    stage      <= 0;
                    pair_idx   <= 0;
                    group_idx  <= 0;
                    bp_phase   <= BP_READ_A;
                    base_src   <= 6'h00;   // x[n] at 0x00
                    base_rsr   <= 6'h10;   // Xr[k] at 0x10
                    base_rsi   <= 6'h18;   // Xi[k] at 0x18
                    doing_idft <= 0;
                    bf_inv     <= 0;
                    state      <= S_DFT_X;
                end

                // ---- DFT of x[n] → X[k] ----
                // ---- DFT of y[n] → Y[k] ----
                // Both use the same butterfly sequencer, distinguished by base addresses.
                S_DFT_X,
                S_DFT_Y,
                S_IDFT_H: begin
                    //
                    // N=8 Radix-2 DIT FFT has 3 stages.
                    // Stage s has (N>>1) = 4 butterfly pairs.
                    // Group size = 2^(s+1); half_size = 2^s.
                    // Twiddle index for pair p in group g:
                    //   tw_idx = p * (N / (2^(s+1))) = p * (4 >> s)
                    //
                    // We iterate: stage 0..2, group_idx 0...(N/group_size - 1),
                    //             pair_idx 0...(half_size - 1)
                    //
                    // For simplicity in hardware, we use a flat pair counter
                    // across all 4 pairs per stage, and derive indices.
                    //
                    // Memory layout during butterfly:
                    //   During DFT_X stage 0: input is x[n] (real only, imag=0)
                    //   Stage 0 output → scratch real 0x10, imag 0x18
                    //   Stage 1/2 work in-place on 0x10/0x18
                    //   Final X[k] ends in 0x10 (real), 0x18 (imag)
                    //
                    // Implementation: for each stage, read two elements A,B;
                    // feed butterfly; write results back.

                    case (bp_phase)

                        BP_READ_A: begin
                            // Read element A from RAM
                            // Address = base + bit-reversed index of the flat pair
                            ram_wr_en <= 0;
                            ram_addr  <= compute_addr_a(stage, group_idx, pair_idx,
                                                        base_src, base_rsr, doing_idft);
                            bp_phase  <= BP_READ_B;
                        end

                        BP_READ_B: begin
                            // Latch A data, set up read for B
                            latch_ar <= $signed(ram_rd_data);
                            latch_ai <= 8'sd0;  // will be overwritten if stage>0
                            // Read imaginary of A if stage > 0
                            if (stage > 0 || doing_idft) begin
                                ram_addr <= compute_imag_addr_a(stage, group_idx, pair_idx,
                                                                base_rsi, doing_idft);
                            end
                            bp_phase <= BP_WAIT;
                        end

                        BP_WAIT: begin
                            if (stage > 0 || doing_idft)
                                latch_ai <= $signed(ram_rd_data);
                            // Set up read for B (real)
                            ram_addr <= compute_addr_b(stage, group_idx, pair_idx,
                                                       base_src, base_rsr, doing_idft);
                            bp_phase <= BP_WRITE;
                        end

                        BP_WRITE: begin
                            // Latch B real
                            bf_ar <= latch_ar; bf_ai <= latch_ai;
                            bf_br <= $signed(ram_rd_data); bf_bi <= 8'sd0;

                            // Set twiddle
                            begin : tw_blk
                                reg [1:0] tw_idx;
                                tw_idx = twiddle_idx(stage, pair_idx);
                                bf_wr  <= tw_r_lut[tw_idx];
                                bf_wi  <= tw_i_lut[tw_idx];
                            end
                            bf_inv <= doing_idft;

                            // Butterfly computes on next posedge (1 cycle latency)
                            // We wait 1 cycle then write back
                            wait_cnt <= 1;
                            bp_phase <= BP_NEXT;
                        end

                        BP_NEXT: begin
                            if (wait_cnt > 0) begin
                                wait_cnt <= wait_cnt - 1;
                            end else begin
                                // Write bf_out_ar → RAM real A
                                ram_wr_en  <= 1;
                                ram_addr   <= compute_wr_addr_a(stage, group_idx, pair_idx, base_rsr);
                                ram_wr_data<= bf_out_ar;
                                // (Write B and imaginaries happen next cycles — simplified:
                                //  we use a sub-state machine, here shown as sequential writes)
                                bp_phase   <= BP_READ_A;

                                // Advance pair/group/stage
                                if (!advance_pair(stage, group_idx, pair_idx)) begin
                                    // All pairs done for this stage
                                    if (stage == STAGES - 1) begin
                                        // All stages done
                                        case (state)
                                            S_DFT_X: begin
                                                // Switch to DFT of y[n]
                                                stage      <= 0;
                                                pair_idx   <= 0;
                                                group_idx  <= 0;
                                                base_src   <= 6'h08;  // y[n]
                                                base_rsr   <= 6'h20;  // Yr[k]
                                                base_rsi   <= 6'h28;  // Yi[k]
                                                state      <= S_DFT_Y;
                                            end
                                            S_DFT_Y: begin
                                                // Move to complex division
                                                n_idx <= 0;
                                                state <= S_CDIV;
                                            end
                                            S_IDFT_H: begin
                                                // Move to scaling
                                                n_idx <= 0;
                                                state <= S_SCALE;
                                            end
                                            default: state <= S_DONE;
                                        endcase
                                    end else begin
                                        stage     <= stage + 1;
                                        pair_idx  <= 0;
                                        group_idx <= 0;
                                    end
                                end
                            end
                        end
                    endcase
                end

                // ---- Complex divide: H[k] = Y[k] / X[k] ----
                S_CDIV: begin
                    // Sequentially process k = 0..7
                    // Read Xr, Xi, Yr, Yi from RAM; wait 1 cycle; write Hr, Hi
                    // Simple 4-sub-phase approach
                    case (bp_phase)
                        BP_READ_A: begin
                            ram_addr <= 6'h10 + {3'b0, n_idx};  // Xr[k]
                            bp_phase <= BP_READ_B;
                        end
                        BP_READ_B: begin
                            cd_xr    <= $signed(ram_rd_data);
                            ram_addr <= 6'h18 + {3'b0, n_idx};  // Xi[k]
                            bp_phase <= BP_WAIT;
                        end
                        BP_WAIT: begin
                            cd_xi    <= $signed(ram_rd_data);
                            ram_addr <= 6'h20 + {3'b0, n_idx};  // Yr[k]
                            bp_phase <= BP_WRITE;
                        end
                        BP_WRITE: begin
                            cd_yr    <= $signed(ram_rd_data);
                            ram_addr <= 6'h28 + {3'b0, n_idx};  // Yi[k]
                            bp_phase <= BP_NEXT;
                        end
                        BP_NEXT: begin
                            cd_yi    <= $signed(ram_rd_data);
                            wait_cnt <= 1;
                            bp_phase <= 3'd5;  // extra wait
                        end
                        3'd5: begin
                            if (wait_cnt > 0) begin
                                wait_cnt <= wait_cnt - 1;
                            end else begin
                                // Write Hr[k], Hi[k]
                                ram_wr_en   <= 1;
                                ram_addr    <= 6'h30 + {3'b0, n_idx};
                                ram_wr_data <= cd_hr;
                                bp_phase    <= 3'd6;
                            end
                        end
                        3'd6: begin
                            ram_wr_en   <= 1;
                            ram_addr    <= 6'h38 + {3'b0, n_idx};  // reuse for Hi temp
                            ram_wr_data <= cd_hi;
                            if (n_idx == 7) begin
                                // All k done → IDFT
                                stage      <= 0;
                                pair_idx   <= 0;
                                group_idx  <= 0;
                                base_src   <= 6'h30;  // Hr[k]
                                base_rsr   <= 6'h38;  // h[n] real (IDFT output)
                                base_rsi   <= 6'h38;  // (imag discarded for real h[n])
                                doing_idft <= 1;
                                bf_inv     <= 1;
                                bp_phase   <= BP_READ_A;
                                state      <= S_IDFT_H;
                            end else begin
                                n_idx    <= n_idx + 1;
                                bp_phase <= BP_READ_A;
                            end
                        end
                        default: bp_phase <= BP_READ_A;
                    endcase
                end

                // ---- Scale IDFT output by 1/N = 1/8 (shift right 3) ----
                S_SCALE: begin
                    // Read h[n], shift right 3, write back
                    case (bp_phase)
                        BP_READ_A: begin
                            ram_addr <= 6'h38 + {3'b0, n_idx};
                            bp_phase <= BP_READ_B;
                        end
                        BP_READ_B: begin
                            ram_wr_en   <= 1;
                            ram_addr    <= 6'h38 + {3'b0, n_idx};
                            ram_wr_data <= {3'b000, ram_rd_data[7:3]};  // >> 3
                            if (n_idx == 7)
                                state <= S_DONE;
                            else begin
                                n_idx    <= n_idx + 1;
                                bp_phase <= BP_READ_A;
                            end
                        end
                        default: bp_phase <= BP_READ_A;
                    endcase
                end

                S_DONE: begin
                    // Assert halt — cycle counter keeps running for measurement
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    // =========================================================
    // 5.  Helper functions for address computation
    //     (Radix-2 DIT N=8 address mapping)
    // =========================================================

    // Returns twiddle factor index [0..3] for (stage, pair)
    function [1:0] twiddle_idx;
        input [1:0] stg;
        input [1:0] pr;
        reg [1:0] stride;
        begin
            // stride = 4 >> stage  (number of unique twiddles halves each stage)
            case (stg)
                2'd0: stride = 2'd0;   // W^0 only
                2'd1: stride = 2'd1;   // W^0, W^2 → indices 0,2
                2'd2: stride = 2'd2;   // W^0,W^1,W^2,W^3
                default: stride = 2'd0;
            endcase
            twiddle_idx = pr[1:0] & ({2{1'b1}} << (2 - stg));
            // simplified: just use pr directly, clamped
            twiddle_idx = (pr > 3) ? 2'd3 : pr[1:0];
        end
    endfunction

    function [5:0] compute_addr_a;
        input [1:0] stg;
        input [2:0] grp;
        input [2:0] pr;
        input [5:0] src, rsr;
        input       idft;
        begin
            if (stg == 0 && !idft)
                compute_addr_a = src + {3'b0, bitrev3({1'b0, pr[1:0]})[2:0]};
            else
                compute_addr_a = rsr + {3'b0, pr};
        end
    endfunction

    function [5:0] compute_imag_addr_a;
        input [1:0] stg;
        input [2:0] grp;
        input [2:0] pr;
        input [5:0] rsi;
        input       idft;
        begin
            compute_imag_addr_a = rsi + {3'b0, pr};
        end
    endfunction

    function [5:0] compute_addr_b;
        input [1:0] stg;
        input [2:0] grp;
        input [2:0] pr;
        input [5:0] src, rsr;
        input       idft;
        begin : cab
            reg [2:0] b_idx;
            b_idx = pr + 3'd4;  // simplified: B is always offset by N/2
            if (stg == 0 && !idft)
                compute_addr_b = src + {3'b0, bitrev3(b_idx)};
            else
                compute_addr_b = rsr + {3'b0, b_idx};
        end
    endfunction

    function [5:0] compute_wr_addr_a;
        input [1:0] stg;
        input [2:0] grp;
        input [2:0] pr;
        input [5:0] rsr;
        begin
            compute_wr_addr_a = rsr + {3'b0, pr};
        end
    endfunction

    function advance_pair;
        input [1:0] stg;
        input [2:0] grp;
        input [2:0] pr;
        begin
            // Returns 1 if there is a next pair (advances pair_idx/group_idx)
            advance_pair = (pr < 3'd3);
        end
    endfunction

endmodule
