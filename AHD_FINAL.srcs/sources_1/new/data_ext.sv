`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2023 05:52:59 PM
// Design Name: 
// Module Name: data_ext
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

module data_ext(
    input logic [31:0] data_in,
    input logic [2:0] funt3,
    output logic [31:0] data_out
);

    logic [31:0] data_out_temp;

    always_comb begin
        case(funt3)
            3'b000: data_out_temp = {{24{data_in[7]}}, data_in[7:0]};     // LB
            3'b001: data_out_temp = {{16{data_in[15]}}, data_in[15:0]};   // LH
            3'b100: data_out_temp = {{24{1'b0}}, data_in[7:0]};           // LBU
            3'b101: data_out_temp = {{16{1'b0}}, data_in[15:0]};          // LHU
            default: data_out_temp = data_in;                             // LW
        endcase
    end

    assign data_out = data_out_temp;
endmodule
