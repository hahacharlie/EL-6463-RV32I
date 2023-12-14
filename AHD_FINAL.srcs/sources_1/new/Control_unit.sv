`timescale 1ns / 1ps

module ControlUnit(
    input logic clk, rst,
    input logic [6:0] opcode,
    input logic bc, // branch info
    output reg PC_s, 
               PC_we, 
               Instr_rd, 
               RegFile_s, 
               RegFile_we, 
               Imm_op, 
               ALU_s1, 
               ALU_s2, 
               DataMem_rd, 
               Data_op, 
               Data_s, 
               Bc_Op, 
               Data_we,
    output reg [1:0] ALU_op
    );

    // CPU operation opcodes
    typedef enum reg [6:0] { 
        LUI         = 7'b0110111, // load upper immediate
        AUIPC       = 7'b0010111, // add upper immediate to pc
        JAL         = 7'b1101111, // jump and link
        JALR        = 7'b1100111, // jump and link register
        BRANCH      = 7'b1100011, // B-type instructions
        LOAD        = 7'b0000011, // I-type instructions (load)
        STORE       = 7'b0100011, // S-type instructions
        OP_IMM      = 7'b0010011, // I-type instructions
        OP          = 7'b0110011, // R-type instructions
        MISC_MEM    = 7'b0001111, // FENCE: Implement as NOP (addi R0, R0, 0)
        SYSTEM      = 7'b1110011  // ECALL, EBREAK: Implement as HALT
    } op_code;

    //ALU operation opcodes
    typedef enum reg [1:0] { 
        LOAD_STORE  = 2'b00, // load, store: basically do add operation
        ARITHMETIC  = 2'b01, // add, subtract, shift, and, or, xor
        COMPARE     = 2'b10 // comparison operations
    } ALU_op_code;

    // State machine states
    typedef enum reg [2:0] {
        FETCH       = 3'b000,
        DECODE      = 3'b001,
        EXECUTE     = 3'b010,
        MEMORY      = 3'b011,
        WRITEBACK   = 3'b100, 
        HALT        = 3'b101
    } State;

    State current_state, next_state; // state variables

    // state reset logic
    always @(posedge clk or negedge rst) begin
        if(!rst)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    // state transition logic
    always_comb begin : state_transition
        case(current_state)
            FETCH: begin
                next_state = DECODE;
            end

            DECODE: begin
                next_state = EXECUTE;
            end

            EXECUTE: begin
                next_state = MEMORY;
            end

            MEMORY: begin
                next_state = WRITEBACK;
            end

            WRITEBACK: begin
                next_state = FETCH;
            end

            HALT: begin
                if (opcode != 7'b000000) begin
                    next_state = HALT;
                end else begin
                    next_state = FETCH;
                end
            end

            default: begin
                next_state = HALT;
            end
        endcase
    end

    // state output logic
always @(posedge clk) begin
    case(current_state)
        HALT: begin // HALT the entire CPU
            PC_s          = 1'b0;
            PC_we         = 1'b0;
            Instr_rd      = 1'b0;
            RegFile_s     = 1'b0;
            RegFile_we    = 1'b0;
            Imm_op        = 1'b0;
            ALU_s1        = 1'b0;
            ALU_s2        = 1'b0;
            ALU_op        = 2'b00; // Assuming default value 00 instead of 'xx'
            DataMem_rd    = 1'b0;
            Data_we       = 1'b0;
            Data_op       = 1'b0;
            Data_s        = 1'b0;
            Bc_Op         = 1'b0;
        end
    
        FETCH: begin // fetch the next instruction
            PC_s          = 1'b0;
            PC_we         = 1'b0;
            Instr_rd      = 1'b1; // read from the instruction memory, save to instruction register
            RegFile_s     = 1'b0;
            RegFile_we    = 1'b0;
            Imm_op        = 1'b0;
            ALU_s1        = 1'b0;
            ALU_s2        = 1'b0;
            ALU_op        = 2'b00;
            DataMem_rd    = 1'b0;
            Data_we       = 1'b0;
            Data_op       = 1'b0;
            Data_s        = 1'b0;
            Bc_Op         = 1'b0;
        end
    
        DECODE: begin // decode the instruction
            PC_s          = 1'b0;
            PC_we         = 1'b0;
            Instr_rd      = 1'b1; // parse the instruction in the instruction register
            RegFile_s     = 1'b0;
            RegFile_we    = 1'b0;
            Imm_op        = 1'b0;
            ALU_s1        = 1'b0;
            ALU_s2        = 1'b0;
            ALU_op        = 2'b00;
            DataMem_rd    = 1'b0;
            Data_we       = 1'b0;
            Data_op       = 1'b0;
            Data_s        = 1'b0;
            Bc_Op         = 1'b0;
        end
    
        EXECUTE: begin 
            case (opcode)
                LUI: begin // load upper immediate
                    // rd={imm[31:12], 12'b0}
                    PC_s          = 1'b0;
                    PC_we         = 1'b0;
                    Instr_rd      = 1'b0;
                    RegFile_s     = 1'b0;
                    RegFile_we    = 1'b1; // write to the register file
                    Imm_op        = 1'b1; // extend the immediate
                    ALU_s1        = 1'b0;
                    ALU_s2        = 1'b0;
                    ALU_op        = LOAD_STORE; // load
                    DataMem_rd    = 1'b0;
                    Data_we       = 1'b0;
                    Data_op       = 1'b0;
                    Data_s        = 1'b0;
                    Bc_Op         = 1'b0;
                end

 AUIPC: begin
                    PC_s = 1'b1;
                    PC_we = 1'b1;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b1;
                    Imm_op = 1'b1;
                    ALU_s1 = 1'b0;
                    ALU_s2 = 1'b0;
                    ALU_op = LOAD_STORE;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b0;
                    Data_op = 2'b00;
                    Data_s = 1'b0;
                    Bc_Op = 1'b0;
                end

                JAL: begin
                    PC_s = 1'b1;
                    PC_we = 1'b1;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b1;
                    Imm_op = 1'b1;
                    ALU_s1 = 1'b0;
                    ALU_s2 = 1'b0;
                    ALU_op = LOAD_STORE;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b0;
                    Data_op = 2'b00;
                    Data_s = 1'b0;
                    Bc_Op = 1'b0;
                end

                JALR: begin
                    PC_s = 1'b1;
                    PC_we = 1'b1;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b1;
                    Imm_op = 1'b1;
                    ALU_s1 = 1'b1;
                    ALU_s2 = 1'b0;
                    ALU_op = LOAD_STORE;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b0;
                    Data_op = 2'b00;
                    Data_s = 1'b0;
                    Bc_Op = 1'b0;
                end

                BRANCH: begin
                    PC_s = 1'b1;
                    PC_we = 1'b0;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b0;
                    Imm_op = 1'b1;
                    ALU_s1 = 1'b1;
                    ALU_s2 = 1'b0;
                    ALU_op = COMPARE;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b0;
                    Data_op = 2'b00;
                    Data_s = 1'b0;
                    Bc_Op = 1'b1;
                end

                LOAD: begin
                    PC_s = 1'b0;
                    PC_we = 1'b0;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b1;
                    Imm_op = 1'b1;
                    ALU_s1 = 1'b1;
                    ALU_s2 = 1'b0;
                    ALU_op = LOAD_STORE;
                    DataMem_rd = 1'b1;
                    Data_we = 1'b0;
                    Data_op = 2'b00;
                    Data_s = 1'b1;
                    Bc_Op = 1'b0;
                end

                STORE: begin
                    PC_s = 1'b0;
                    PC_we = 1'b0;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b0;
                    Imm_op = 1'b1;
                    ALU_s1 = 1'b1;
                    ALU_s2 = 1'b0;
                    ALU_op = LOAD_STORE;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b1;
                    Data_op = 2'b00;
                    Data_s = 1'b1;
                    Bc_Op = 1'b0;
                end

                OP_IMM: begin
                    PC_s = 1'b0;
                    PC_we = 1'b0;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b1;
                    Imm_op = 1'b1;
                    ALU_s1 = 1'b1;
                    ALU_s2 = 1'b0;
                    ALU_op = ARITHMETIC;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b0;
                    Data_op = 2'b00;
                    Data_s = 1'b0;
                    Bc_Op = 1'b0;
                end

                OP: begin
                    PC_s = 1'b0;
                    PC_we = 1'b0;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b1;
                    Imm_op = 1'b0;
                    ALU_s1 = 1'b1;
                    ALU_s2 = 1'b1;
                    ALU_op = ARITHMETIC;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b0;
                    Data_op = 2'b00;
                    Data_s = 1'b0;
                    Bc_Op = 1'b0;
                end

                MISC_MEM: begin
                    PC_s = 1'b0;
                    PC_we = 1'b0;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b0;
                    Imm_op = 1'b0;
                    ALU_s1 = 1'b0;
                    ALU_s2 = 1'b0;
                    ALU_op = 2'b00;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b0;
                    Data_op = 2'b00;
                    Data_s = 1'b0;
                    Bc_Op = 1'b0;
                end

                SYSTEM: begin
                    PC_s = 1'b0;
                    PC_we = 1'b0;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b0;
                    Imm_op = 1'b0;
                    ALU_s1 = 1'b0;
                    ALU_s2 = 1'b0;
                    ALU_op = 2'bxx;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b0;
                    Data_op = 2'bxx;
                    Data_s = 1'b0;
                    Bc_Op = 1'b0;
                end

                default: begin
                    PC_s = 1'b0;
                    PC_we = 1'b0;
                    Instr_rd = 1'b0;
                    RegFile_s = 1'b0;
                    RegFile_we = 1'b0;
                    Imm_op = 1'b0;
                    ALU_s1 = 1'b0;
                    ALU_s2 = 1'b0;
                    ALU_op = 2'bxx;
                    DataMem_rd = 1'b0;
                    Data_we = 1'b0;
                    Data_op = 2;
                    Data_s  = 1'b0;
                    Bc_Op   = 1'b0; 
                    end
                endcase
            end

MEMORY: begin 
    case (opcode)
        LUI: begin
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b1;
            Imm_op = 1'b1;
            ALU_s1 = 1'b0;
            ALU_s2 = 1'b0;
            ALU_op = LOAD_STORE;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 1'b0;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end

        AUIPC: begin
            PC_s = 1'b1;
            PC_we = 1'b1;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b1;
            Imm_op = 1'b1;
            ALU_s1 = 1'b0;
            ALU_s2 = 1'b0;
            ALU_op = LOAD_STORE;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 1'b0;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end

        JAL: begin
            PC_s = 1'b1;
            PC_we = 1'b1;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b1;
            Imm_op = 1'b1;
            ALU_s1 = 1'b0;
            ALU_s2 = 1'b0;
            ALU_op = LOAD_STORE;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 1'b0;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end

        JALR: begin
            PC_s = 1'b1;
            PC_we = 1'b1;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b1;
            Imm_op = 1'b1;
            ALU_s1 = 1'b1;
            ALU_s2 = 1'b0;
            ALU_op = LOAD_STORE;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 1'b0;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end

        BRANCH: begin
            PC_s = 1'b1;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b0;
            Imm_op = 1'b1;
            ALU_s1 = 1'b1;
            ALU_s2 = 1'b0;
            ALU_op = COMPARE;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 1'b0;
            Data_s = 1'b0;
            Bc_Op = 1'b1;
        end

        LOAD: begin
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b1;
            Imm_op = 1'b1;
            ALU_s1 = 1'b1;
            ALU_s2 = 1'b0;
            ALU_op = LOAD_STORE;
            DataMem_rd = 1'b1;
            Data_we = 1'b0;
            Data_op = 1'b0;
            Data_s = 1'b1;
            Bc_Op = 1'b0;
        end

                   STORE: begin // store instructions
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b0;
            Imm_op = 1'b1;
            ALU_s1 = 1'b1;
            ALU_s2 = 1'b0;
            ALU_op = LOAD_STORE;
            DataMem_rd = 1'b0;
            Data_we = 1'b1;
            Data_op = 2'b00;
            Data_s = 1'b1;
            Bc_Op = 1'b0;
        end

        OP_IMM: begin // I-type instructions
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b1;
            Imm_op = 1'b1;
            ALU_s1 = 1'b1;
            ALU_s2 = 1'b0;
            ALU_op = ARITHMETIC;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 2'b00;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end

        OP: begin // R-type instructions
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b1;
            Imm_op = 1'b0;
            ALU_s1 = 1'b1;
            ALU_s2 = 1'b1;
            ALU_op = ARITHMETIC;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 2'b00;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end

        MISC_MEM: begin // FENCE
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b0;
            Imm_op = 1'b0;
            ALU_s1 = 1'b0;
            ALU_s2 = 1'b0;
            ALU_op = 2'b00;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 2'b00;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end

        SYSTEM: begin // ECALL, EBREAK
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b0;
            Imm_op = 1'b0;
            ALU_s1 = 1'b0;
            ALU_s2 = 1'b0;
            ALU_op = 2'bxx;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 2'bxx;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end

        default: begin
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b0;
            Imm_op = 1'b0;
            ALU_s1 = 1'b0;
            ALU_s2 = 1'b0;
            ALU_op = 2'bxx;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 2'bxx;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end
    endcase
end

            
    WRITEBACK: begin 
    case (opcode)
        LUI, AUIPC, JAL, JALR, LOAD, OP_IMM, OP: begin // For instructions that write back to the register file
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b1;
            Imm_op = (opcode == LUI || opcode == AUIPC || opcode == JAL || opcode == JALR || opcode == LOAD || opcode == OP_IMM) ? 1'b1 : 1'b0;
            ALU_s1 = (opcode == JALR || opcode == LOAD || opcode == STORE || opcode == OP_IMM || opcode == OP) ? 1'b1 : 1'b0;
            ALU_s2 = (opcode == OP) ? 1'b1 : 1'b0;
            ALU_op = (opcode == OP || opcode == OP_IMM) ? ARITHMETIC : LOAD_STORE;
            DataMem_rd = (opcode == LOAD) ? 1'b1 : 1'b0;
            Data_we = (opcode == STORE) ? 1'b1 : 1'b0;
            Data_op = 2'b00;
            Data_s = (opcode == LOAD) ? 1'b1 : 1'b0;
            Bc_Op = 1'b0;
        end

        BRANCH, MISC_MEM, SYSTEM: begin // For instructions that do not write back to the register file
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b0;
            Imm_op = 1'b0;
            ALU_s1 = 1'b0;
            ALU_s2 = 1'b0;
            ALU_op = 2'b00;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 2'b00;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end

        default: begin // Default case
            PC_s = 1'b0;
            PC_we = 1'b0;
            Instr_rd = 1'b0;
            RegFile_s = 1'b0;
            RegFile_we = 1'b0;
            Imm_op = 1'b0;
            ALU_s1 = 1'b0;
            ALU_s2 = 1'b0;
            ALU_op = 2'bxx;
            DataMem_rd = 1'b0;
            Data_we = 1'b0;
            Data_op = 2'bxx;
            Data_s = 1'b0;
            Bc_Op = 1'b0;
        end
    endcase
end

           // Default state output logic
    default: begin
        PC_s = 1'b0;
        PC_we = 1'b0;
        Instr_rd = 1'b0;
        RegFile_s = 1'b0;
        RegFile_we = 1'b0;
        Imm_op = 1'b0;
        ALU_s1 = 1'b0;
        ALU_s2 = 1'b0;
        ALU_op = 2'bxx;
        DataMem_rd = 1'b0;
        Data_we = 1'b0;
        Data_s = 1'b0;
        Bc_Op = 1'b0;
            end
        endcase
    end
endmodule
