`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2023 05:44:51 PM
// Design Name: 
// Module Name: imm_ext
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

module imm_ext(
    input logic clk,
    input logic [6:0] opcode,
    input logic [31:0] instr_in,
    output logic [31:0] imm_ext
);

    logic [31:0] imm_temp;
    localparam logic [6:0] R_TYPE  = 7'b0110011,
                            I_TYPE  = 7'b0010011,
                            S_TYPE  = 7'b0100011,
                            L_TYPE  = 7'b0000011,
                            B_TYPE  = 7'b1100011,
                            JALR    = 7'b1100111,
                            JAL     = 7'b1101111,
                            AUIPC   = 7'b0010111,
                            LUI     = 7'b0110111;

    always_ff @(posedge clk) begin
        case(opcode) 
            LUI, AUIPC:
                imm_temp = {instr_in[31:12], 12'b0};
            JAL:
                imm_temp = {{12{instr_in[31]}}, instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};
            I_TYPE, L_TYPE, JALR:
                imm_temp = {{21{instr_in[31]}}, instr_in[30:20]};
            B_TYPE:
                imm_temp = {{20{instr_in[31]}}, instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};
            S_TYPE:
                imm_temp = {{21{instr_in[31]}}, instr_in[30:25], instr_in[11:7]};
            default:
                imm_temp = {{21{instr_in[31]}}, instr_in[30:20]}; // ITYPE ALU 
        endcase
    end

    assign imm_ext = imm_temp;
endmodule

