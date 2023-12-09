`timescale 1ns / 1ps

module pc (
    input logic clk,                // Clock signal
    input logic reset,              // Asynchronous reset
    input logic enable,             // Write enable signal
    input logic [31:0] next_pc,     // Input for the next PC value
    output logic [31:0] current_pc  // Output of the current PC value
);

    // Register to hold on to the PC value for outputting
    logic [31:0] pc_reg;

    // Sequential logic for updating the PC
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            pc_reg <= 32'h01000000; // Reset PC to the start address of instruction memory
        end else if (enable) begin
            pc_reg <= next_pc; // Update PC with the next PC value
        end
    end

    assign current_pc = pc_reg; // Assign the current PC value to the output

endmodule
