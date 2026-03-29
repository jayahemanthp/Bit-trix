`timescale 1ns/1ps
 
module tb_top;
 
    reg clk, rst;
 
    // Opcode gen inputs
    reg [1:0] op, reg1, reg2;
 
    // Opcode gen output → top input
    wire [7:0] instr;
 
    // Operation encoding
    localparam NOP   = 2'b00;
    localparam MAC   = 2'b01;
    localparam LOAD  = 2'b10;
    localparam STORE = 2'b11;
 
    // Register encoding
    localparam R0 = 2'b00;
    localparam R1 = 2'b01;
    localparam R2 = 2'b10;
    localparam R3 = 2'b11;
 
    // Instantiate opcode generator
    opcode_gen u_opcode_gen (
        .op    (op),
        .reg1  (reg1),
        .reg2  (reg2),
        .instr (instr)
    );
 
    // Instantiate top (instr comes from opcode_gen)
    top u_top (
        .clk   (clk),
        .rst   (rst),
        .instr (instr)
    );
 
    // Clock: 10ns period
    always #5 clk = ~clk;
 
    initial begin
        // Init
        clk = 0; rst = 1;
        op = NOP; reg1 = R0; reg2 = R0;
        #20 rst = 0;
 
        // --- Test 1: NOP ---
        op = NOP; reg1 = R0; reg2 = R0; #10;
        $display("T=%0t | NOP | instr=%b", $time, instr);
 
        // --- Test 2: MAC R1, R2 ---
        op = MAC; reg1 = R1; reg2 = R2; #10;
        $display("T=%0t | MAC R1,R2 | instr=%b | mac_out=%d", $time, instr, u_top.u_mac.acc_out);
 
        // --- Test 3: MAC R0, R3 ---
        op = MAC; reg1 = R0; reg2 = R3; #10;
        $display("T=%0t | MAC R0,R3 | instr=%b | mac_out=%d", $time, instr, u_top.u_mac.acc_out);
 
        // --- Test 4: STORE R1 → RAM[R0] ---
        op = STORE; reg1 = R1; reg2 = R0; #10;
        $display("T=%0t | STORE R1,R0 | instr=%b", $time, instr);
 
        // --- Test 5: LOAD R3 ← RAM[R0] ---
        op = LOAD; reg1 = R3; reg2 = R0; #10;
        $display("T=%0t | LOAD R3,R0 | instr=%b | ram_rd=%d", $time, instr, u_top.u_ram.rd_data);
 
        // --- Test 6: MAC R3, R1 ---
        op = MAC; reg1 = R3; reg2 = R1; #10;
        $display("T=%0t | MAC R3,R1 | instr=%b | mac_out=%d", $time, instr, u_top.u_mac.acc_out);
 
        // --- Test 7: NOP ---
        op = NOP; reg1 = R0; reg2 = R0; #10;
        $display("T=%0t | NOP | instr=%b", $time, instr);
 
        #20;
        $display("---------------------------------------");
        $display("Simulation Complete.");
        $finish;
    end
 
    // Waveform dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end
 
endmodule
