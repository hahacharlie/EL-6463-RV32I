`timescale 1ns / 1ps

module RegisterFile_tb;

// Inputs
logic clk;
logic rst;
logic en;
logic [4:0] readS1;
logic [4:0] readS2;
logic [4:0] readRd;
logic [31:0] data_in;

// Outputs
wire [31:0] rs1;
wire [31:0] rs2;

// Instantiate the Unit Under Test (UUT)
RegisterFile uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .readS1(readS1),
    .readS2(readS2),
    .readRd(readRd),
    .data_in(data_in),
    .rs1(rs1),
    .rs2(rs2)
);

// Clock generation
always #5 clk = ~clk; // 100MHz Clock

initial begin
    // Initialize Inputs
    clk = 0;
    rst = 0;
    en = 0;
    readS1 = 0;
    readS2 = 0;
    readRd = 0;
    data_in = 0;

    // Reset the register file
    #10;
    rst = 1;
    #10;
    rst = 0;
    #10;
    rst = 1;
    #10;

    // Write to register
    en = 1;
    readRd = 5;
    data_in = 32'd10;
    #10;

    // Read from register
    en = 0;
    readS1 = 5;
    readS2 = 0; // Register 0 should always read 0
    #10;

    // Check if the read data is correct
    if (rs1 !== 32'd10) $display("Read from register 5 failed");
    if (rs2 !== 32'b0) $display("Read from register 0 failed");

    // Test Write Enable (en) Behavior
    readRd = 10;
    data_in = 32'd10;
    en = 0; // Disable writing
    #10;
    readS1 = 10;
    #10;
    if (rs1 === 32'd10) $display("Write Enable test failed, register 10 should not be updated");

    // Verify Register 0 Behavior
    readRd = 0;
    data_in = 32'd10;
    en = 1; // Enable writing
    #10;
    readS1 = 0;
    #10;
    if (rs1 !== 32'b0) $display("Register 0 behavior test failed, it should always read 0");

    $finish;
end
      
endmodule
