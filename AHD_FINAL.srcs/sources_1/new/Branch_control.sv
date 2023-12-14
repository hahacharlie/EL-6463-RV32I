`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2023 03:47:26 PM
// Design Name: 
// Module Name: Branch_control
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

module Branch_control(
    input logic bc_enable,
    input logic [2:0] funct3,
    input logic [31:0] operand1,
    input logic [31:0] operand2,
    output logic bc_out
);

always_comb begin
    if (bc_enable) begin
        case(funct3)
            3'b000: bc_out = (operand1 == operand2);
            3'b001: bc_out = (operand1 != operand2);
            3'b100: bc_out = (operand1[31] != operand2[31]) ? (operand1[31] > operand2[31]) : (operand1 < operand2);
            3'b101: bc_out = (operand1[31] != operand2[31]) ? (operand1[31] < operand2[31]) : (operand1 >= operand2);
            3'b110: bc_out = (operand1 >= operand2);
            3'b111: bc_out = (operand1 < operand2);
            default: bc_out = 0;
        endcase
    end else begin
        bc_out = 0;
    end
end

endmodule
