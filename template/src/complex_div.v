// =============================================================
//  Complex Divider  –  single real division block
//  Computes H[k] = Y[k] / X[k]  in the frequency domain.
//
//  Formula (complex division):
//    H_r = (Y_r*X_r + Y_i*X_i) / (X_r^2 + X_i^2)
//    H_i = (Y_i*X_r - Y_r*X_i) / (X_r^2 + X_i^2)
//
//  If denominator == 0  → output 0 (undefined impulse response).
//  All values: 8-bit signed.  Products: 16-bit, saturated back.
// =============================================================
module complex_div (
    input             clk,
    input             rst,
    input  signed [7:0] yr, yi,   // Y[k]
    input  signed [7:0] xr, xi,   // X[k]
    output reg signed [7:0] hr,   // H[k] real
    output reg signed [7:0] hi,   // H[k] imag
    output reg        dz          // divide-by-zero flag
);
    reg signed [15:0] denom;
    reg signed [15:0] num_r, num_i;
    reg signed [15:0] quot_r, quot_i;

    // Saturate 16-bit signed to 8-bit signed
    function signed [7:0] sat8s;
        input signed [15:0] x;
        begin
            if      (x >  127) sat8s =  8'sd127;
            else if (x < -128) sat8s = -8'sd128;
            else               sat8s = x[7:0];
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hr <= 0; hi <= 0; dz <= 0;
        end else begin
            denom = xr * xr + xi * xi;   // |X[k]|^2

            if (denom == 0) begin
                hr <= 0; hi <= 0; dz <= 1;
            end else begin
                dz    <= 0;
                num_r  = yr * xr + yi * xi;
                num_i  = yi * xr - yr * xi;
                quot_r = num_r / denom;
                quot_i = num_i / denom;
                hr    <= sat8s(quot_r);
                hi    <= sat8s(quot_i);
            end
        end
    end
endmodule
