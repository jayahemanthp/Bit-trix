// =============================================================
//  Instruction Decoder
//  Encoding:  [7:4] opcode | [5:4] rd | [3:2] rs1 | [1:0] rs2
//  Note: opcode occupies [7:4]; rd overlaps [5:4] inside that
//  byte, so we re-slice the full 8-bit word as:
//      instr[7:6] = opcode high (2 bits → 16 ops with [5:4])
//  Simpler flat encoding used here:
//      instr[7:4] = opcode (4 bits, up to 16 opcodes)
//      instr[5:4] = rd     (reused from opcode low nibble)
//      instr[3:2] = rs1
//      instr[1:0] = rs2
//  This means opcode HIGH 2 bits select the group,
//  rd is carried inside the low 2 bits of the high nibble.
// =============================================================
module instr_decoder (
    input  [7:0] instr,
    // decoded fields
    output reg [3:0] opcode,
    output reg [1:0] rd,
    output reg [1:0] rs1,
    output reg [1:0] rs2,
    // control signals
    output reg       alu_en,
    output reg       mem_wr,
    output reg       mem_rd,
    output reg       reg_wr,
    output reg       use_imm,   // rs2 field is an immediate / RAM address
    output reg       halt,
    output reg [3:0] alu_op     // mirrors opcode for ALU
);
    // ---- Opcode definitions (4-bit, max 16) ----
    localparam NOP   = 4'h0;
    localparam ADD   = 4'h1;
    localparam SUB   = 4'h2;
    localparam MUL   = 4'h3;
    localparam DIV   = 4'h4;
    localparam MAC   = 4'h5;  // rd = rd + rs1*rs2
    localparam AND   = 4'h6;
    localparam OR    = 4'h7;
    localparam XOR   = 4'h8;
    localparam NOT   = 4'h9;
    localparam SHL   = 4'hA;  // barrel shift left  (≤4)
    localparam SHR   = 4'hB;  // barrel shift right (≤4)
    localparam LOAD  = 4'hC;  // rd ← RAM[rs2_addr]
    localparam STORE = 4'hD;  // RAM[rs2_addr] ← rs1
    localparam MOV   = 4'hE;  // rd ← rs1
    localparam HLT   = 4'hF;

    always @(*) begin
        // default all signals
        opcode  = instr[7:4];
        rd      = instr[5:4];   // low 2 bits of high nibble
        rs1     = instr[3:2];
        rs2     = instr[1:0];
        alu_en  = 1'b0;
        mem_wr  = 1'b0;
        mem_rd  = 1'b0;
        reg_wr  = 1'b0;
        use_imm = 1'b0;
        halt    = 1'b0;
        alu_op  = instr[7:4];

        case (opcode)
            NOP: begin
                // nothing
            end
            ADD, SUB, MUL, DIV,
            AND, OR,  XOR, NOT,
            SHL, SHR: begin
                alu_en = 1'b1;
                reg_wr = 1'b1;
            end
            MAC: begin
                alu_en = 1'b1;
                reg_wr = 1'b1;
            end
            MOV: begin
                alu_en = 1'b0;
                reg_wr = 1'b1;
            end
            LOAD: begin
                mem_rd  = 1'b1;
                reg_wr  = 1'b1;
                use_imm = 1'b1;  // rs2 field = RAM address
            end
            STORE: begin
                mem_wr  = 1'b1;
                use_imm = 1'b1;  // rs2 field = RAM address
            end
            HLT: begin
                halt = 1'b1;
            end
            default: begin
                // treat unknown as NOP
            end
        endcase
    end
endmodule
