`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2023 04:13:04 PM
// Design Name: 
// Module Name: Registerfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module RegisterFile(
    input logic clk,
    input logic rst,
    input logic en,
    input logic [4:0] readS1,
    input logic [4:0] readS2,
    input logic [4:0] readRd,
    input logic [31:0] data_in,
    output logic [31:0] rs1,
    output logic [31:0] rs2
);

logic [31:0] rf [0:31];

// Initialize the register file
initial begin
    integer i; // Declare 'i' locally
    for (i = 0; i < 32; i = i + 1) begin
        rf[i] = 32'b0;
    end
end

// Reset and Write Operation
always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        integer i; // Declare 'i' locally
        for (i = 0; i < 32; i = i + 1) begin
            rf[i] <= 32'b0;
        end
    end
    else if (en) begin
        if (readRd != 0) begin // Ensure we don't write to register 0
            rf[readRd] <= data_in;
        end
        rf[0] <= 32'b0; // Register 0 is always 0
    end
end

// Read Operation
always_comb begin
    rs1 = (readS1 != 0) ? rf[readS1] : 32'b0;
    rs2 = (readS2 != 0) ? rf[readS2] : 32'b0;
end

endmodule
