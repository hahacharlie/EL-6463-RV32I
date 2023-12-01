`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2023 08:17:10 PM
// Design Name: 
// Module Name: pc
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


module pc (
    input logic clk,                // Clock signal
    input logic reset,              // Asynchronous reset
    input logic [31:0] next_pc,     // Input for the next PC value
    output logic [31:0] current_pc  // Output of the current PC value
);

    // Register to hold the PC value
    logic [31:0] pc_reg;
    
    assign current_pc = pc_reg; 

    // Sequential logic for updating the PC
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            pc_reg <= 32'h01000000; // Reset PC to the start address of instruction memory
        end else begin
            pc_reg <= next_pc; // Update PC with the next PC value
        end
    end
endmodule
