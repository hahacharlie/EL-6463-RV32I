`timescale 1ns / 1ps
`include "../rtl/control_unit.sv"

module tb_control_unit();

    logic [31:0] instruction;
    logic branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    logic [3:0] alu_op;

    control_unit cu(
        .instruction(instruction),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );

    initial begin
        // Test R-type instruction (e.g., ADD)
        instruction = 32'b00000000000100010000000110110011; // ADD x3, x2, x1
        #10;
        
        // Test I-type instruction (e.g., ADDI)
        instruction = 32'b00000000010000010000000110010011; // ADDI x3, x1, 4
        #10;

        // Test S-type instruction (e.g., SW)
        instruction = 32'b00000000001000010010000100100011; // SW x1, 4(x2)
        #10;

        // Test B-type instruction (e.g., BEQ)
        instruction = 32'b00000000010000010000000001100011; // BEQ x1, x2, 4
        #10;

        // Test U-type instruction (e.g., LUI)
        instruction = 32'b00000000000000000001000010110111; // LUI x1, 0x1000
        #10;

        // Test U-type instruction (e.g., AUIPC)
        instruction = 32'b00000000000000000001000010010111; // AUIPC x1, 0x1000
        #10;

        // Test J-type instruction (e.g., JAL)
        instruction = 32'b00000000000000000000000011101111; // JAL x0, 0
        #10;

        $finish;
    end

endmodule
