`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2023 09:22:59 PM
// Design Name: 
// Module Name: Instruction_decode
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

module Instruction_decode(
    input  logic clk, 
    input  logic [31:0] instr_in,
    output logic [4:0]  rd_addr,
    output logic [4:0]  rs1_addr,
    output logic [4:0]  rs2_addr,
    output logic [6:0]  opcode,
    output logic [2:0]  funct,
    output logic [6:0]  funct7
);

    assign opcode   = instr_in[6:0];
    assign funct    = instr_in[14:12];
    assign rd_addr  = instr_in[11:7];
    assign rs1_addr = instr_in[19:15];
    assign rs2_addr = instr_in[24:20];
    assign funct7   = instr_in[31:25];

endmodule
