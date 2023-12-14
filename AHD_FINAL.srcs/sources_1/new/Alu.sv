//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2023 02:58:41 PM
// Design Name: 
// Module Name: ALU
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

`timescale 1ns / 1ps

module ALU(
    input logic [3:0] alu_ctrl,
    input logic [31:0] operand1,
    input logic [31:0] operand2,
    output logic [31:0] alu_out
);

// Intermediate signals for different operations
logic [31:0] add_result, sub_result, xor_result, or_result, and_result;
logic [31:0] sll_result, srl_result, sra_result;
logic signed_less_than, unsigned_less_than;

// Add and Subtract
assign add_result = operand1 + operand2;
assign sub_result = operand1 - operand2;

// Logical operations
assign xor_result = operand1 ^ operand2;
assign or_result = operand1 | operand2;
assign and_result = operand1 & operand2;

// Shift operations
assign sll_result = operand1 << operand2[4:0];
assign srl_result = operand1 >> operand2[4:0];
assign sra_result = $signed(operand1) >>> operand2[4:0];

// Comparison operations
assign signed_less_than = $signed(operand1) < $signed(operand2);
assign unsigned_less_than = operand1 < operand2;

// ALU control logic
always_comb begin
    case (alu_ctrl)
        4'b0000: alu_out = add_result;
        4'b1000: alu_out = sub_result;
        4'b0001: alu_out = sll_result;
        4'b0010: alu_out = signed_less_than;
        4'b0011: alu_out = unsigned_less_than;
        4'b0100: alu_out = xor_result;
        4'b0101: alu_out = srl_result;
        4'b1101: alu_out = sra_result;
        4'b0110: alu_out = or_result;
        4'b0111: alu_out = and_result;
        default: alu_out = 32'd0;
    endcase
end

endmodule
