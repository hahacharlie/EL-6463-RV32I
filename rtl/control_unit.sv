`timescale 1ns / 1ps

module ControlUnit(
    input logic clk, rst, branch_control, 
    input reg [6:0] opcode,
    output logic pc_src, pc_w, instr_r, reg_file_src, reg_file_w, imm_ext, ALU_s1, ALU_s2, mem_r, mem_w, data_src, bc_op,
    output reg [1:0] ALU_op, data_op
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
                pc_src          = 1'b0; 
                pc_w            = 1'b0; 
                instr_r         = 1'b0; 
                reg_file_src    = 1'b0; 
                reg_file_w      = 1'b0; 
                imm_ext         = 1'b0; 
                ALU_s1          = 1'b0; 
                ALU_s2          = 1'b0; 
                ALU_op          = 2'bxx;
                mem_r           = 1'b0; 
                mem_w           = 1'b0; 
                data_op         = 2'b00; 
                data_src        = 1'b0;
                bc_op           = 1'b0; 

            end
        
            FETCH: begin // fetch the next instruction
                pc_src          = 1'b0; 
                pc_w            = 1'b0; 
                instr_r         = 1'b1; // read from the instruction memeory, save to instruction register
                reg_file_src    = 1'b0; 
                reg_file_w      = 1'b0; 
                imm_ext         = 1'b0; 
                ALU_s1          = 1'b0; 
                ALU_s2          = 1'b0; 
                ALU_op          = 2'bxx; // not using the ALU
                mem_r           = 1'b0; 
                mem_w           = 1'b0; 
                data_op         = 2'b00; 
                data_src        = 1'b0;
                bc_op           = 1'b0; 
            end
        
            DECODE: begin // decode the instruction
                pc_src          = 1'b0; 
                pc_w            = 1'b0; 
                instr_r         = 1'b1; // parse the instruction in the instruction register
                reg_file_src    = 1'b0; 
                reg_file_w      = 1'b0; 
                imm_ext         = 1'b0; 
                ALU_s1          = 1'b0; 
                ALU_s2          = 1'b0; 
                ALU_op          = 2'bxx; // not using the ALU
                mem_r           = 1'b0; 
                mem_w           = 1'b0; 
                data_op         = 2'b00; 
                data_src        = 1'b0;
                bc_op           = 1'b0; 
            end
        
            EXECUTE: begin 
                case (opcode)
                    LUI: begin // load upper immediate
                    // rd={imm[31:12], 12'b0}
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;// load
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'bxx; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    AUIPC: begin // add upper immediate to pc
                    // rd=PC+{imm[31:12], 12'b0}
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b1; // write to the pc
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE; // load
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    JAL: begin // jump and link
                    // rd=PC+4, PC=PC+sign_ext(imm)
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b1; // write to the pc
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    JALR: begin // jump and link register
                    // rd=PC+4, PC=rs1+sign_ext(imm)
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b1; // write to the pc
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    BRANCH: begin // branch instructions
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = COMPARE; // set the ALU operation to the branch operation
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b1; // set the branch control to 1
                    end

                    LOAD: begin // load instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b1; // read from the data memory
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b1; // set the data source to the data memory output
                        bc_op           = 1'b0; 
                    end

                    STORE: begin // store instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b1; // write to the data memory
                        data_op         = 2'b00; 
                        data_src        = 1'b1; // set the data source to the data memory output
                        bc_op           = 1'b0; 
                    end

                    OP_IMM: begin // I-type instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = ARITHMETIC; // set the ALU operation to do arithmetic
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    OP: begin // R-type instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b1; // set the ALU source 2 to the register file output
                        ALU_op          = ARITHMETIC; // set the ALU operation to do arithmetic
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    MISC_MEM: begin // FENCE
                    // addi R0, R0, 0
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = 2'b00;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    SYSTEM: begin // ECALL, EBREAK
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = 2'bxx;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'bxx; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    default: begin
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = 2'bxx;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'bxx; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end
                endcase
            end

            MEMORY: begin // memory access
                case (opcode)
                    LUI: begin // load upper immediate
                    // rd={imm[31:12], 12'b0}
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;// load
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'bxx; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    AUIPC: begin // add upper immediate to pc
                    // rd=PC+{imm[31:12], 12'b0}
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b1; // write to the pc
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE; // load
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    JAL: begin // jump and link
                    // rd=PC+4, PC=PC+sign_ext(imm)
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b1; // write to the pc
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    JALR: begin // jump and link register
                    // rd=PC+4, PC=rs1+sign_ext(imm)
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b1; // write to the pc
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    BRANCH: begin // branch instructions
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = COMPARE; // set the ALU operation to the branch operation
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b1; // set the branch control to 1
                    end

                    LOAD: begin // load instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b1; // read from the data memory
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b1; // set the data source to the data memory output
                        bc_op           = 1'b0; 
                    end

                    STORE: begin // store instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b1; // write to the data memory
                        data_op         = 2'b00; 
                        data_src        = 1'b1; // set the data source to the data memory output
                        bc_op           = 1'b0; 
                    end

                    OP_IMM: begin // I-type instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = ARITHMETIC; // set the ALU operation to do arithmetic
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    OP: begin // R-type instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b1; // set the ALU source 2 to the register file output
                        ALU_op          = ARITHMETIC; // set the ALU operation to do arithmetic
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    MISC_MEM: begin // FENCE
                    // addi R0, R0, 0
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = 2'b00;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    SYSTEM: begin // ECALL, EBREAK
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = 2'bxx;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'bxx; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    default: begin
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = 2'bxx;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'bxx; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end
                endcase
            end

            WRITEBACK: begin // writeback
                case (opcode)
                    LUI: begin // load upper immediate
                    // rd={imm[31:12], 12'b0}
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;// load
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'bxx; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    AUIPC: begin // add upper immediate to pc
                    // rd=PC+{imm[31:12], 12'b0}
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b1; // write to the pc
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE; // load
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    JAL: begin // jump and link
                    // rd=PC+4, PC=PC+sign_ext(imm)
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b1; // write to the pc
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    JALR: begin // jump and link register
                    // rd=PC+4, PC=rs1+sign_ext(imm)
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b1; // write to the pc
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    BRANCH: begin // branch instructions
                        pc_src          = 1'b1; // set the pc source to the ALU output
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = COMPARE; // set the ALU operation to the branch operation
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b1; // set the branch control to 1
                    end

                    LOAD: begin // load instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b1; // read from the data memory
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b1; // set the data source to the data memory output
                        bc_op           = 1'b0; 
                    end

                    STORE: begin // store instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = LOAD_STORE;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b1; // write to the data memory
                        data_op         = 2'b00; 
                        data_src        = 1'b1; // set the data source to the data memory output
                        bc_op           = 1'b0; 
                    end

                    OP_IMM: begin // I-type instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b1; // extend the immediate
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b0; 
                        ALU_op          = ARITHMETIC; // set the ALU operation to do arithmetic
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    OP: begin // R-type instructions
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b1; // write to the register file
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b1; // set the ALU source 1 to the register file output
                        ALU_s2          = 1'b1; // set the ALU source 2 to the register file output
                        ALU_op          = ARITHMETIC; // set the ALU operation to do arithmetic
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    MISC_MEM: begin // FENCE
                    // addi R0, R0, 0
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = 2'b00;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'b00; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    SYSTEM: begin // ECALL, EBREAK
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = 2'bxx;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'bxx; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end

                    default: begin
                        pc_src          = 1'b0; 
                        pc_w            = 1'b0; 
                        instr_r         = 1'b0; 
                        reg_file_src    = 1'b0; 
                        reg_file_w      = 1'b0; 
                        imm_ext         = 1'b0; 
                        ALU_s1          = 1'b0; 
                        ALU_s2          = 1'b0; 
                        ALU_op          = 2'bxx;
                        mem_r           = 1'b0; 
                        mem_w           = 1'b0; 
                        data_op         = 2'bxx; 
                        data_src        = 1'b0;
                        bc_op           = 1'b0; 
                    end
                endcase
            end

            default: begin
                pc_src          = 1'b0; 
                pc_w            = 1'b0; 
                instr_r         = 1'b0; 
                reg_file_src    = 1'b0; 
                reg_file_w      = 1'b0; 
                imm_ext         = 1'b0; 
                ALU_s1          = 1'b0; 
                ALU_s2          = 1'b0; 
                ALU_op          = 2'bxx;
                mem_r           = 1'b0; 
                mem_w           = 1'b0; 
                data_op         = 2'bxx; 
                data_src        = 1'b0;
                bc_op           = 1'b0; 
            end
        endcase
    end
endmodule