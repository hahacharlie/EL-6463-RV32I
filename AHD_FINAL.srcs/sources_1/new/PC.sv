`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2022 01:14:08 AM
// Design Name: 
// Module Name: ProgramCounter
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

module pc(
    input  logic clk, 
    input  logic rst, 
    input  logic write_en, 
    input  logic [31:0] PC_inputAddress,
    output logic [31:0] PC_outputAddress
    );
    
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) 
            PC_outputAddress <= 32'h01000000; // Upon reset, this should equal the start address of instruction memory (0x01000000)
        else if (write_en) 
            PC_outputAddress <= PC_inputAddress;
        // Note: The explanation about RISC-V and byte addressing remains valid and applicable.
    end
endmodule
