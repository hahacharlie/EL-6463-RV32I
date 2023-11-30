`timescale 1ns / 1ps
`include "../rtl/pc.sv"

module tb_pc();

    logic clk;
    logic reset;
    logic [31:0] next_pc;
    logic [31:0] current_pc;

    // Instantiate the pc module
    pc dut(
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .current_pc(current_pc)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = !clk; // Generate a clock with a period of 10 time units
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        next_pc = 32'h01000000;

        // Assert reset
        #10;
        reset = 0;
        #10;
        reset = 1;
        #10;

        // Normal operation
        next_pc = 32'h01000004;
        #10;
        next_pc = 32'h01000008;
        #10;
        next_pc = 32'h0100000C;
        #10;

        // Check results
        $display("Test completed. Final PC value: %h", current_pc);

        // Finish the simulation
        $finish;
    end

endmodule
