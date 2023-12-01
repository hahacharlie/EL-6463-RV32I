module Instruction #(
    parameter ADDR_WIDTH = 10, // Number of bits for addressing ROM
    parameter DATA_WIDTH = 32, // Data width
    parameter ROM_SIZE = 512   // Size of ROM
) (
    input logic clk,
    input logic rst,
    input logic read_instr,
    input logic [DATA_WIDTH-1:0] addr_in,
    output logic [DATA_WIDTH-1:0] instr_out
);

    logic [DATA_WIDTH-1:0] rom_words[ROM_SIZE-1:0];

    initial begin
        $readmemh("instruction.mem", rom_words);
    end 

    always_ff @(posedge clk) begin
        if (read_instr) begin
            instr_out <= rom_words[(addr_in & (~(32'h01000000))) >> 2];
        end
    end

endmodule

