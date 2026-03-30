// =============================================================
//  RAM  –  64 × 8-bit single-port memory
//  Fix: ADDR_WIDTH corrected to 6 (log2(64)) to avoid
//       wasting address decode logic.
//
//  Memory map (for h[n] computation, N=8):
//    0x00–0x07 : x[n]  real  (input, pre-loaded)
//    0x08–0x0F : y[n]  real  (input, pre-loaded)
//    0x10–0x17 : X[k]  real  parts  (DFT of x)
//    0x18–0x1F : X[k]  imag  parts
//    0x20–0x27 : Y[k]  real  parts  (DFT of y)
//    0x28–0x2F : Y[k]  imag  parts
//    0x30–0x37 : H[k]  real  parts  (Y/X in freq domain)
//    0x38–0x3F : h[n]  real  (IDFT → final impulse response)
// =============================================================
module ram #(
    parameter DEPTH      = 64,
    parameter ADDR_WIDTH = 6        // ceil(log2(64)) = 6
)(
    input                      clk,
    input                      wr_en,
    input  [ADDR_WIDTH-1:0]    addr,
    input  [7:0]               wr_data,
    output reg [7:0]           rd_data
);
    reg [7:0] mem [0:DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 8'b0;
    end

    always @(posedge clk) begin
        if (wr_en)
            mem[addr] <= wr_data;
        else
            rd_data   <= mem[addr];
    end
endmodule
