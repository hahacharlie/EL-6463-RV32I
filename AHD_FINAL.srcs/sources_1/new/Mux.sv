`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2023 03:45:12 PM
// Design Name: 
// Module Name: Mux
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
module Mux (
    input logic UpperInput,
    input logic LowerInput,
    input logic ControlSignal,
    output logic selectedVal
);

    always_comb begin
        if (ControlSignal) 
            selectedVal = UpperInput;
        else 
            selectedVal = LowerInput;
    end

endmodule
