// =============================================================
//  ALU  –  8-bit, supports all allowed operations
//  Overflow/saturation policy:
//    ADD/SUB : saturate to 0xFF (max) or 0x00 (min)
//    MUL     : keep low 8 bits (modulo 256); overflow flag set
//    DIV     : truncate to integer; divide-by-zero → 0xFF
//    MAC     : acc + (a*b), saturate to 8 bits
//    Shifts  : clamp shift amount to [0,4]
//    Logic   : no overflow possible
// =============================================================
module alu (
    input      [3:0]  op,
    input      [7:0]  a,
    input      [7:0]  b,
    input      [7:0]  acc,     // for MAC (accumulator = rd current)
    output reg [7:0]  result,
    output reg        ovf      // overflow / divide-by-zero flag
);
    // Opcode mirrors from instr_decoder
    localparam ADD  = 4'h1;
    localparam SUB  = 4'h2;
    localparam MUL  = 4'h3;
    localparam DIV  = 4'h4;
    localparam MAC  = 4'h5;
    localparam AND  = 4'h6;
    localparam OR   = 4'h7;
    localparam XOR  = 4'h8;
    localparam NOT  = 4'h9;
    localparam SHL  = 4'hA;
    localparam SHR  = 4'hB;

    // Wider wires for intermediate math
    reg [15:0] mul_res;
    reg [8:0]  add_res;
    reg [8:0]  sub_res;
    reg [15:0] mac_res;
    reg [2:0]  shamt;   // shift amount clamped to [0,4]

    always @(*) begin
        ovf    = 1'b0;
        result = 8'h00;

        case (op)
            // ---- ADD (saturating) ----
            ADD: begin
                add_res = {1'b0, a} + {1'b0, b};
                if (add_res[8]) begin
                    result = 8'hFF;
                    ovf    = 1'b1;
                end else begin
                    result = add_res[7:0];
                end
            end

            // ---- SUB (saturating, unsigned) ----
            SUB: begin
                sub_res = {1'b0, a} - {1'b0, b};
                if (sub_res[8]) begin    // borrow → underflow
                    result = 8'h00;
                    ovf    = 1'b1;
                end else begin
                    result = sub_res[7:0];
                end
            end

            // ---- MUL (low byte, overflow flag) ----
            MUL: begin
                mul_res = a * b;
                result  = mul_res[7:0];
                ovf     = |mul_res[15:8];  // high byte non-zero → overflow
            end

            // ---- DIV (unsigned integer, div-by-zero → 0xFF) ----
            DIV: begin
                if (b == 8'h00) begin
                    result = 8'hFF;
                    ovf    = 1'b1;
                end else begin
                    result = a / b;
                end
            end

            // ---- MAC: acc + a*b, saturating ----
            MAC: begin
                mul_res = a * b;
                mac_res = {8'b0, acc} + mul_res;
                if (|mac_res[15:8]) begin
                    result = 8'hFF;
                    ovf    = 1'b1;
                end else begin
                    result = mac_res[7:0];
                end
            end

            // ---- Logic ----
            AND: result = a & b;
            OR : result = a | b;
            XOR: result = a ^ b;
            NOT: result = ~a;

            // ---- Barrel Shift (±4 max) ----
            SHL: begin
                shamt  = (b[2:0] > 3'd4) ? 3'd4 : b[2:0];
                result = a << shamt;
            end
            SHR: begin
                shamt  = (b[2:0] > 3'd4) ? 3'd4 : b[2:0];
                result = a >> shamt;
            end

            default: result = 8'h00;
        endcase
    end
endmodule
