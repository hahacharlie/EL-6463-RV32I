`timescale 1ns / 1ps

module ALU_tb;

// Inputs to the ALU
reg [3:0] alu_ctrl;
reg [31:0] operand1;
reg [31:0] operand2;

// Output from the ALU
wire [31:0] alu_out;

// Instantiate the ALU module
ALU uut (
    .alu_ctrl(alu_ctrl), 
    .operand1(operand1), 
    .operand2(operand2), 
    .alu_out(alu_out)
);

initial begin
    // Initialize Inputs
    alu_ctrl = 0;
    operand1 = 0;
    operand2 = 0;

    // Wait for 100 ns for global reset to finish
    #100;

    // Test addition
    alu_ctrl = 4'b0000;
    operand1 = 32'd20;
    operand2 = 32'd10;
    #10;
    if (alu_out != 30) $display("Addition Test Failed");

    // Test subtraction
    alu_ctrl = 4'b1000;
    operand1 = 32'd20;
    operand2 = 32'd10;
    #10;
    if (alu_out != 10) $display("Subtraction Test Failed");

    // Test XOR
    alu_ctrl = 4'b0100;
    operand1 = 32'd20;
    operand2 = 32'd10;
    #10;
    if (alu_out != 30) $display("XOR Test Failed");

    // Test OR
    alu_ctrl = 4'b0110;
    operand1 = 32'd20;
    operand2 = 32'd10;
    #10;
    if (alu_out != 30) $display("OR Test Failed");

    // Test AND
    alu_ctrl = 4'b0111;
    operand1 = 32'd20;
    operand2 = 32'd10;
    #10;
    if (alu_out != 0) $display("AND Test Failed");

    // Test SLL (Shift Left Logical)
    alu_ctrl = 4'b0001;
    operand1 = 32'd1;
    operand2 = 32'd4;
    #10;
    if (alu_out != 16) $display("SLL Test Failed");

    // Test SRL (Shift Right Logical)
    alu_ctrl = 4'b0101;
    operand1 = 32'd1;
    operand2 = 32'd4;
    #10;
    if (alu_out != 0) $display("SRL Test Failed");

    // Test SRA (Shift Right Arithmetic)
    alu_ctrl = 4'b1101;
    operand1 = 32'd1;
    operand2 = 32'd4;
    #10;
    if (alu_out != 0) $display("SRA Test Failed");

    // Test signed less than
    alu_ctrl = 4'b0010;
    operand1 = -32'd15; // negative number
    operand2 = 32'd10;
    #10;
    if (alu_out != 1) $display("Signed Less Than Test Failed");

    // Test unsigned less than
    alu_ctrl = 4'b0011;
    operand1 = 32'd15;
    operand2 = 32'd10;
    #10;
    if (alu_out != 0) $display("Unsigned Less Than Test Failed");

    $finish;
end
      
endmodule