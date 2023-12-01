`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2023 08:17:57 PM
// Design Name: 
// Module Name: control_unit_tb
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

module control_unit_tb();

    // Testbench Variables
    logic [31:0] instruction;
    logic branch, mem_read, mem_to_reg, alu_src, mem_write, reg_write;
    logic [3:0] alu_op;

    // Instantiate the control_unit
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

    // Test Procedure
    initial begin

        // Test R-type instruction (ADD)
        instruction = 32'h00300293; // ADD R5, R0, R3
        #20;
        assert(branch == 0 && mem_read == 0 && mem_to_reg == 0 && alu_src == 0 && mem_write == 0 && reg_write == 1) else $error("R-type instruction test failed.");

        // Test I-type instruction (Load)
        instruction = 32'h00002303; // LW R6, 0(R0)
        #20;
        assert(branch == 0 && mem_read == 1 && mem_to_reg == 1 && alu_src == 1 && mem_write == 0 && reg_write == 0) else $error("I-type load instruction test failed.");

        // Test S-type instruction (Store)
        instruction = 32'h00202223; // SW R2, 0(R4)
        #20;
        assert(branch == 0 && mem_read == 0 && mem_to_reg == 0 && alu_src == 1 && mem_write == 1 && reg_write == 0) else $error("S-type instruction test failed.");

        // Test B-type instruction (BEQ)
        instruction = 32'h00050663; // BEQ R1, R0, 12
        #20;
        assert(branch == 1 && mem_read == 0 && mem_to_reg == 0 && alu_src == 0 && mem_write == 0 && reg_write == 0) else $error("B-type instruction test failed.");

        // Test U-type instruction (LUI)
        instruction = 32'hFFFFF037; // LUI R0, 0xFFFFF
        #20;
        assert(branch == 0 && mem_read == 0 && mem_to_reg == 0 && alu_src == 1 && mem_write == 0 && reg_write == 1) else $error("U-type LUI instruction test failed.");

        // Test J-type instruction (JAL)
        instruction = 32'h000000EF; // JAL R1, 0
        #20;
        assert(branch == 1 && mem_read == 0 && mem_to_reg == 0 && alu_src == 1 && mem_write == 0 && reg_write == 1) else $error("J-type JAL instruction test failed.");

        // Test FENCE
        instruction = 32'h0000000F; // ADDI R0, R0, 0
        #20;
        assert(branch == 0 && mem_read == 0 && mem_to_reg == 0 && alu_src == 1 && mem_write == 0 && reg_write == 1) else $error("FENCE instruction test failed.");
        
        // Test ECALL
        instruction = 32'h00000073; // ECALL
        #20;
        assert(branch == 0 && mem_read == 0 && mem_to_reg == 0 && alu_src == 0 && mem_write == 0 && reg_write == 0) else $error("ECALL instruction test failed.");
        
        // Test EBREAK
        instruction = 32'h00100073; // EBREAK
        #20;
        assert(branch == 0 && mem_read == 0 && mem_to_reg == 0 && alu_src == 0 && mem_write == 0 && reg_write == 0) else $error("EBREAK instruction test failed.");

        // Test completed
        $display("All tests completed successfully.");

        // End the simulation
        $finish;
    end

endmodule
