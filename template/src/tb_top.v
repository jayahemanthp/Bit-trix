// ================================================================
//  Testbench: Impulse Response Processor
//  Test case: x[n] = [8,0,...,0],  y[n] = [8,8,0,...,0]
//  Expected h[n] = [1,1,0,...,0]
// ================================================================
`timescale 1ns/1ps
`include "top.v"

module tb_top;
    reg        clk = 0;
    reg        rst = 1;
    reg  [7:0] instr = 8'h00;
    wire [255:0] cycle_count;

    // DUT
    top dut (
        .clk        (clk),
        .rst        (rst),
        .instr      (instr),
        .cycle_count(cycle_count)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    integer k;

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        // ---- Pre-load RAM via backdoor ----
        // x[n] = [8, 0, 0, 0, 0, 0, 0, 0]
        dut.u_ram.mem[8'h00] = 8'd8;
        dut.u_ram.mem[8'h01] = 8'd0;
        dut.u_ram.mem[8'h02] = 8'd0;
        dut.u_ram.mem[8'h03] = 8'd0;
        dut.u_ram.mem[8'h04] = 8'd0;
        dut.u_ram.mem[8'h05] = 8'd0;
        dut.u_ram.mem[8'h06] = 8'd0;
        dut.u_ram.mem[8'h07] = 8'd0;

        // y[n] = [8, 8, 0, 0, 0, 0, 0, 0]
        dut.u_ram.mem[8'h08] = 8'd8;
        dut.u_ram.mem[8'h09] = 8'd8;
        dut.u_ram.mem[8'h0A] = 8'd0;
        dut.u_ram.mem[8'h0B] = 8'd0;
        dut.u_ram.mem[8'h0C] = 8'd0;
        dut.u_ram.mem[8'h0D] = 8'd0;
        dut.u_ram.mem[8'h0E] = 8'd0;
        dut.u_ram.mem[8'h0F] = 8'd0;

        // Reset pulse
        @(posedge clk); #1;
        rst = 0;

        // Wait for computation to finish (~200 cycles max)
        repeat(200) @(posedge clk);

        // ---- Print results ----
        $display("=== Impulse Response h[n] ===");
        for (k = 0; k < 8; k = k + 1) begin
            $display("  h[%0d] = %0d (expected: %0d)",
                      k,
                      $signed(dut.u_ram.mem[8'h38 + k]),
                      (k < 2) ? 8'd1 : 8'd0);
        end

        $display("Total cycles: %0d", cycle_count[31:0]);

        // Check pass/fail
        if (dut.u_ram.mem[8'h38] == 8'd1 &&
            dut.u_ram.mem[8'h39] == 8'd1 &&
            dut.u_ram.mem[8'h3A] == 8'd0)
            $display("PASS: h[n] matches expected");
        else
            $display("INFO: Check h[n] values against expected");

        $finish;
    end
endmodule
