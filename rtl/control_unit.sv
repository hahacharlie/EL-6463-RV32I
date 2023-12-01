`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2023 08:17:10 PM
// Design Name: 
// Module Name: control_unit
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


module control_unit (
    input logic [31:0] instruction,        // 32-bit instruction
    output logic branch,                   // Branch signal
    output logic mem_read,            // Memory read signal
    output logic mem_to_reg,         // Memory to register file signal
    output logic [3:0] alu_op,          // ALU operation signal
    output logic mem_write,           // Memory write signal
    output logic alu_src,                 // ALU source signal
    output logic reg_write              // Register write signal
);

    // Extract fields from instruction
    wire [6:0] opcode = instruction[6:0];
    // wire [4:0] rd = instruction[11:7];
    wire [2:0] funct3 = instruction[14:12];
    // wire [4:0] rs1 = instruction[19:15];
    // wire [4:0] rs2 = instruction[24:20];
    wire [6:0] funct7 = instruction[31:25];

    // Immediate values for different instruction formats
    // wire [11:0] imm_I = instruction[31:20];
    // wire [11:0] imm_S = {instruction[31:25], instruction[11:7]};
    // wire [12:0] imm_B = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
    // wire [19:0] imm_U = instruction[31:12];
    // wire [20:0] imm_J = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};

    // Define ALU operation codes
    typedef enum logic [3:0] {
        ALU_ADD = 4'h0,
        ALU_SUB = 4'h1,
        ALU_SLL = 4'h2,
        ALU_SLT = 4'h3,
        ALU_XOR = 4'h4,
        ALU_SRL = 4'h5,
        ALU_SRA = 4'h6,
        ALU_OR = 4'h7,
        ALU_AND = 4'h8, 
        ALU_BEQ = 4'h9,
        ALU_BNE = 4'hA,
        ALU_BLT = 4'hB,
        ALU_BGE = 4'hC,
        ALU_LUI = 4'hD, 
        ALU_AUIPC = 4'hE, 
        ALU_PASS = 4'hF
    } alu_ops_e;

    // Control logic based on the opcode
    always_comb begin

        case (opcode)

            // R-type instructions
            7'b0110011: begin
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_write = 1;
                
                //ALU operation logic based on funct3 and funct7
                case (funct3)
                    3'h0: begin // ADD, SUB
                        case (funct7)
                            7'h0: alu_op = ALU_ADD;
                            7'h20: alu_op = ALU_SUB;
                        endcase
                    end
                    3'h4: alu_op = ALU_SLL; // SLL
                    3'h6: alu_op = ALU_SLT; // SLT
                    3'h7: alu_op = ALU_SLT; // SLTU
                    3'h1: alu_op = ALU_XOR; // XOR
                    3'h5: begin // SRL, SRA
                        case (funct7)
                            7'h0: alu_op = ALU_SRL;
                            7'h20: alu_op = ALU_SRA; 
                        endcase
                    end
                    3'h2: alu_op = ALU_OR; // OR
                    3'h3: alu_op = ALU_AND; // AND
                    default: alu_op = ALU_ADD;
                endcase

            end

            // I-type instructions (load)
            7'b0000011: begin // Load instructions
                branch = 0;
                mem_read = 1;
                mem_to_reg = 1;
                mem_write = 0;
                alu_src = 1;
                reg_write = 0;

                alu_op = ALU_ADD; // most common load alu operation

            end

            // I-type instructions (immediate arithmetic)
            7'b0010011: begin // Load instructions
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 1;
                reg_write = 1;

                // ALU operation logic based on funct3
                case (funct3)
                    3'h0: alu_op = ALU_ADD; // ADDI
                    3'h1: alu_op = ALU_SLL; // SLLI
                    3'h2: alu_op = ALU_SLT; // SLTI
                    3'h3: alu_op = ALU_SLT; // SLTIU
                    3'h4: alu_op = ALU_XOR; // XORI
                    3'h5: begin // SRLI, SRAI
                        case (funct7)
                            7'h0: alu_op = ALU_SRL;
                            7'h20: alu_op = ALU_SRA; 
                        endcase
                    end
                    3'h6: alu_op = ALU_OR; // ORI
                    3'h7: alu_op = ALU_AND; // ANDI
                    default: alu_op = ALU_ADD;
                endcase

            end

            // S-type instructions (store)
            7'b0100011: begin
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 1;
                alu_src = 1;
                reg_write = 0;

                case (funct3)
                    3'h0: alu_op = ALU_ADD; // SB
                    3'h1: alu_op = ALU_ADD; // SH
                    3'h2: alu_op = ALU_ADD; // SW
                    default: alu_op = ALU_ADD;
                endcase

            end

            // B-type instructions (branch)
            7'b1100011: begin
                branch = 1;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_write = 0;

                case (funct3)
                    3'b000: alu_op = ALU_BEQ;        // For BEQ, branch if equal
                    3'b001: alu_op = ALU_BNE;        // For BNE, branch if not equal
                    3'b100: alu_op = ALU_BLT;         // For BLT, branch if less than
                    3'b101: alu_op = ALU_BGE;      // For BGE, branch if greater than or equal
                    3'b110: alu_op = ALU_BLT;       // For BLTU, branch if less than, unsigned
                    3'b111: alu_op = ALU_BGE;     // For BGEU, branch if greater than or equal, unsigned
                    default: branch = 0;               // Default no branching for unrecognized funct3
                endcase

            end

            // U-type instructions (LUI: Load upper immediate)
            7'b0110111: begin
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 1;
                reg_write = 1;

                alu_op = ALU_LUI;
            end

            // U-type instructions (AUIPC: Add Upper Imm to PC)
            7'b0010111: begin
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 1;
                reg_write = 1;

                alu_op = ALU_AUIPC;
            end

            // J-type instructions (JAL)
            7'b1101111: begin
                branch = 1;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 1;
                reg_write = 1;

                // ALU operation is typically set to pass the PC value through
                // since the immediate offset is added separately
                alu_op = ALU_PASS;
            end
            
            // J_type instructions (JALR)
            7'b1100111: begin
                branch = 1;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 1;
                reg_write = 1;

                // ALU operation is typically set to pass the PC value through
                // since the immediate offset is added separately
                alu_op = ALU_PASS;
            end
            
            // FENCE: Implement as NOP (addi R0, R0, 0)
            7'b0001111: begin
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 1;
                reg_write = 1;

                // ALU operation is typically set to pass the PC value through
                // since the immediate offset is added separately
                alu_op = ALU_ADD;
            end
            
            // ECALL, EBREAK: Implement as HALT (stop program execution)
            7'b1110011: begin
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_write = 0;

                // ALU operation is typically set to pass the PC value through
                // since the immediate offset is added separately
                alu_op = ALU_ADD;
            end

        endcase
    end
endmodule
