// =============================================================
//  Radix-2 DIT Butterfly Unit
//  Computes one butterfly step of the Cooley-Tukey FFT/IFFT.
//
//  Inputs  (fixed-point Q7.0, i.e. 8-bit integer):
//    ar, ai  : real & imag part of top input  A
//    br, bi  : real & imag part of bottom input B
//    wr, wi  : real & imag part of twiddle factor W
//    inv     : 0 = forward DFT, 1 = IDFT (negate Wi)
//
//  Butterfly equations:
//    Wr_eff = wr,   Wi_eff = inv ? -wi : wi
//    (tw_r, tw_i) = (B_r * Wr_eff - B_i * Wi_eff,
//                    B_r * Wi_eff + B_i * Wr_eff)  [W*B]
//    Out_A  = A + W*B   (real & imag)
//    Out_B  = A - W*B   (real & imag)
//
//  All arithmetic is 8-bit signed saturating.
//  Products are 16-bit internally; scaled >> 7 (Q7 twiddles).
//
//  Twiddle factors for N=8 DFT (Q7 signed, i.e. scaled by 128):
//    W^0 : wr=127, wi=  0
//    W^1 : wr= 90, wi=-90
//    W^2 : wr=  0, wi=-127
//    W^3 : wr=-90, wi=-90
// =============================================================
module butterfly (
    input             clk,
    input             rst,
    // Operands (signed 8-bit)
    input  signed [7:0] ar, ai,   // top element A
    input  signed [7:0] br, bi,   // bottom element B
    input  signed [7:0] wr, wi,   // twiddle factor W
    input               inv,      // 0=DFT, 1=IDFT
    // Outputs (signed 8-bit, saturated)
    output reg signed [7:0] out_ar, out_ai,  // A' = A + W*B
    output reg signed [7:0] out_br, out_bi   // B' = A - W*B
);
    // Internal wider arithmetic
    reg signed [15:0] tw_r, tw_i;     // W*B  (16-bit)
    reg signed [7:0]  wi_eff;          // effective Wi (sign-flipped for IDFT)
    reg signed [8:0]  sum_r, sum_i;    // A + W*B  (9-bit for sat check)
    reg signed [8:0]  dif_r, dif_i;   // A - W*B

    // Saturation helper function (inline via task)
    function signed [7:0] sat8;
        input signed [8:0] x;
        begin
            if (x > 9'sd127)       sat8 =  8'sd127;
            else if (x < -9'sd128) sat8 = -8'sd128;
            else                   sat8 =  x[7:0];
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_ar <= 0; out_ai <= 0;
            out_br <= 0; out_bi <= 0;
        end else begin
            // Step 1: effective twiddle imaginary part
            wi_eff = inv ? -wi : wi;

            // Step 2: complex multiply  W * B
            //   tw_r = br*wr - bi*wi_eff
            //   tw_i = br*wi_eff + bi*wr
            // Results scaled by 128 (Q7 twiddles), shift right 7
            tw_r = ({{8{br[7]}}, br} * {{8{wr[7]}}, wr}
                  - {{8{bi[7]}}, bi} * {{8{wi_eff[7]}}, wi_eff}) >>> 7;
            tw_i = ({{8{br[7]}}, br} * {{8{wi_eff[7]}}, wi_eff}
                  + {{8{bi[7]}}, bi} * {{8{wr[7]}}, wr}) >>> 7;

            // Step 3: butterfly sums (9-bit for saturation detection)
            sum_r = {ar[7], ar} + tw_r[8:0];
            sum_i = {ai[7], ai} + tw_i[8:0];
            dif_r = {ar[7], ar} - tw_r[8:0];
            dif_i = {ai[7], ai} - tw_i[8:0];

            // Step 4: saturate to 8-bit signed
            out_ar <= sat8(sum_r);
            out_ai <= sat8(sum_i);
            out_br <= sat8(dif_r);
            out_bi <= sat8(dif_i);
        end
    end
endmodule
