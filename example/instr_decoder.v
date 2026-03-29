module instr_decoder (
    input  [7:0] instr,
    output reg [3:0] opcode,
    output reg [1:0] rd,
    output reg [1:0] rs1,
    output reg [1:0] rs2,
    output reg reg_wr_en,
    output reg ram_wr_en,
    output reg mac_en,
    output reg load_ram_en,
    output reg store_ram_en,
    output reg load_reg_en,
    output reg store_reg_en
);
    always @(*) begin
        opcode = instr[7:4];
        rd     = instr[3:2];
        rs1    = instr[3:2];
        rs2    = instr[1:0];
 
        reg_wr_en    = 0;
        ram_wr_en    = 0;
        mac_en       = 0;
        load_ram_en  = 0;
        store_ram_en = 0;
        load_reg_en  = 0;
        store_reg_en = 0;
 
        case (opcode)
            4'b0000: begin // NOP
            end
            4'b0001: begin // MAC
                mac_en    = 1;
                reg_wr_en = 1;
            end
            4'b0010: begin // LOAD_RAM: Rd = RAM[Rs2]
                load_ram_en = 1;
                reg_wr_en   = 1;
            end
            4'b0011: begin // STORE_RAM: RAM[Rs2] = Rs1
                store_ram_en = 1;
                ram_wr_en    = 1;
            end
            4'b0100: begin // LOAD_REG: Rd = Rs1
                load_reg_en = 1;
                reg_wr_en   = 1;
            end
            4'b0101: begin // STORE_REG: Rd = Rs1
                store_reg_en = 1;
                reg_wr_en    = 1;
            end
            default: begin // NOP
            end
        endcase
    end
endmodule
