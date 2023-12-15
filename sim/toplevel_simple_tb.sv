`timescale 1ns / 1ps

module toplevel_simple_tb;

    // Clock and Reset
    reg clk = 0;
    reg rst;

    // LEDs and Switches
    wire [15:0] leds;
    reg [15:0] switches;

    // Instantiate the toplevel module
        toplevel dut (
        .clk(clk),
        .rst(rst),
        .leds(leds),
        .switches(switches)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz clock

    // Initial setup and reset
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    // Test logic
    initial begin
        // Initialize switches
        switches = 16'b0;
        #100;

        // Set switches to a specific state and observe LED changes
        switches = 16'b1010101010101010;
        #100;

        // More test cases can be added here

        $finish;
    end

    // Optional: Monitor changes
    initial begin
        $monitor("Time = %0t, Switches = %b, LEDs = %b", $time, switches, leds);
    end

endmodule
