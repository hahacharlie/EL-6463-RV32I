`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2023 04:05:28 PM
// Design Name: 
// Module Name: Board
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

module Board(
    input logic CLK100MHZ,
    input logic [15:0] sw,
    input logic btnU, 
    output logic [15:0] LED
);
    logic unsigned [15:0] inter_clock;
    
    // clock divider for testing
    logic slowclock;
    always_ff @(posedge CLK100MHZ) begin 
        inter_clock <= inter_clock + 1;
    end
    assign slowclock  = inter_clock[15];

    Head Head_inst (
        .rst_n(btnU),
        .clk(slowclock), 
        .boardLEDs(LED),
        .boardSwitches(sw)
    );

endmodule

