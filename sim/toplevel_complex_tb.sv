`timescale 1ns / 1ps

module toplevel_complex_tb;

    // Clock and Reset
    reg clk = 0;
    reg rst;

    // Data, key, and control signals for the RC5 module
    reg [63:0] data_in;
    wire [63:0] data_out;
    reg [127:0] key;
    reg start;
    wire done;

    toplevel dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out),
        .key(key),
        .start(start),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz clock

    // Initial setup and reset
    initial begin
        rst = 1;
        start = 0;
        #20;
        rst = 0;
    end

    // Test logic for encryption and decryption
    initial begin
        // Set input data and key
        data_in = 64'h0123456789ABCDEF;
        key = 128'h00112233445566778899AABBCCDDEEFF;
        #100;

        // Start encryption
        start = 1;
        #10;
        start = 0;

        // Wait for encryption to complete
        wait(done);
        #100;

        // Start decryption with encrypted data
        data_in = data_out;
        #10;

        // Start decryption
        start = 1;
        #10;
        start = 0;

        // Wait for decryption to complete
        wait(done);

        // Check if decrypted data matches original
        if (data_in != 64'h0123456789ABCDEF) begin
            $display("Decryption failed.");
        end else begin
            $display("Decryption successful.");
        end

        $finish;
    end

    // Optional: Monitor changes
    initial begin
        $monitor("Time = %0t, Data In = %h, Data Out = %h, Done = %b", $time, data_in, data_out, done);
    end

endmodule
