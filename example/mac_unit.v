module mac_unit #(parameter WIDTH = 8) (
    input clk,
    input rst,
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input [2*WIDTH-1:0] acc_in,
    output reg [2*WIDTH-1:0] acc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_out <= 0;
        end else begin
            acc_out <= acc_in + (a * b);
        end
    end

endmodule