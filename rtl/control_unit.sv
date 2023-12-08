`timescale 1ns / 1ps

module ControlUnit(
    input logic clk, rst,
    input reg [6:0] opcode,
    input bc,
    output reg PC_enable, 
    output reg [1:0] ALU_op
    );

    // CPU operation opcodes
    typedef enum reg [6:0] { 
        LUI = 7'b0110111,
        AUIPC = 7'b0010111,
        JAL = 7'b1101111,
        JALR = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD = 7'b0000011,
        STORE = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP = 7'b0110011,
        MISC_MEM = 7'b0001111,
        SYSTEM = 7'b1110011
    } op_code;

    // State machine states
    typedef enum reg [2:0] {
        FETCH = 3'b000,
        DECODE = 3'b001,
        EXECUTE = 3'b010,
        MEMORY = 3'b011,
        WRITEBACK = 3'b100, 
        HALT = 3'b101
    } State;

    State current_state, next_state;

    // state reset logic
    always @(posedge clk or negedge rst) begin
        if(!rst)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    // state transition logic
    always @(*) begin
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
        endcase
    end
    
    // state output logic
    always @(posedge clk) begin
        case(current_state)
            HALT: begin // HALT the entire CPU
                PC_s_ = 1'b0; 
                PC_we_temp = 1'b0;  
                Instr_rd_temp = 1'b0; 
                RegFile_s_temp = 1'b0;  
                RegFile_we_temp = 1'b0; 
                Imm_op_temp = 1'b0; 
                ALU_s1_temp = 1'b0; 
                ALU_s2_temp = 1'b0; 
                ALU_op_temp = 2'b00;
                DataMem_rd_temp = 1'b0; 
                Data_op_temp = 2'b00; 
                Data_s_temp = 1'b0;
                Data_we_temp = 1'b0;
                Bc_Op_temp = 1'b0; 
            end
        
            FETCH: begin
                PC_s_temp = 1'b0; 
                PC_we_temp = 1'b0; // allow adder write to pc  
                Instr_rd_temp = 1'b1; // get the current memory
                RegFile_s_temp = 1'b0; 
                // that's all the signal we need to get the command 
                RegFile_we_temp = 1'b0; 
                Imm_op_temp = 1'b0; 
                ALU_s1_temp = 1'b0; 
                ALU_s2_temp = 1'b0; 
                ALU_op_temp = 2'b00;
                DataMem_rd_temp = 1'b0; 
                Data_op_temp = 2'b00; 
                Data_s_temp = 1'b0;
                Data_we_temp = 1'b0;
                Bc_Op_temp = 1'b0;
            end
        
            DECODE: begin
                PC_s_temp = 1'b0; 
                PC_we_temp = 1'b0; // allow adder write to pc  
                Instr_rd_temp = 1'b1; // get the current memory
                RegFile_s_temp = 1'b0; 
                // that's all the signal we need to get the command 
                RegFile_we_temp = 1'b0; 
                Imm_op_temp = 1'b0; 
                ALU_s1_temp = 1'b0; 
                ALU_s2_temp = 1'b0; 
                ALU_op_temp = 2'b00;
                DataMem_rd_temp = 1'b0; 
                Data_op_temp = 2'b00; 
                Data_s_temp = 1'b0;
                Data_we_temp = 1'b0;
                Bc_Op_temp = 1'b0;
            end
        
            EXECUTE: begin 
                case (opcode)
                    : 
                    default: 
                endcase
            end

        MEM: begin
            // this stage stores data back to reg or mem
            case(opcode)
                7'b0110011: begin // R-type
                //rd = rs1 + rs2
                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b0; // add pc counter while store value, so we can continue
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; // select alu result

                    RegFile_we_temp = 1'b0;  // write alu result
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0;  
                    ALU_s2_temp = 1'b1; 
                    ALU_op_temp = 1'b00; 

                    //store 
                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // take ALU result
                    Data_we_temp = 1'b0; 
                    Bc_Op_temp = 1'b0;
                end

               7'b0000011: begin // I-type load and store in rd

                //rd=sign_ext(data[rs1+sign_ext(imm)][7:0])

                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b0; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; // select data 

                    RegFile_we_temp = 1'b0;  // write data to reg
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00; 

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b0; 
                    Data_we_temp = 1'b0;
                    Bc_Op_temp = 1'b0;
                end
                
                7'b0010011: begin // I-type addi ori andi ....
                // ! also implement fence here since it says to do the same as addi.
                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b0; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; // select data 

                    RegFile_we_temp = 1'b0;  // write data to reg
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00; 

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // take alu cal output 
                    Data_we_temp = 1'b0;
                    Bc_Op_temp = 1'b0;
                end
                
                7'b0001111: begin // this is the same as above
                // ! also implement fence here since it says to do the same as addi.
                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b0; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; // select data 

                    RegFile_we_temp = 1'b0;  // write data to reg
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00; 

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // take alu cal output 
                    Data_we_temp = 1'b0;
                    Bc_Op_temp = 1'b0;
                end

                 7'b0100011: begin // S-type store 
                 //e.g. data[rs1+sign_ext(imm)][7:0] = rs2[7:0]

                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b0; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; 

                    RegFile_we_temp = 1'b0; 
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0;  
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00;  // store 
                    
                    // we need to wait for this step and then store
                    DataMem_rd_temp = 1'b0; // store to data
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b0;
                    Data_we_temp = 1'b0; // TODO: check value  may depend on funct3
                    Bc_Op_temp = 1'b0;
                end

                 7'b1100011: begin // B-type Store ... of rs2 to memory
                // e.g. PC=(rs1==rs2) ? PC+sign_ext(imm) : PC+4

                    PC_s_temp = 1'b0; // choose what to take base on bc
                    PC_we_temp = 1'b0; // write pc 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; 

                    RegFile_we_temp = 1'b0; 
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b1; 
                    ALU_op_temp = 2'b01; // cal: check branch

                    // may need to wait here 
                    DataMem_rd_temp = 1'b0; // 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b0; // ! branch info based on branch control 
                    Data_we_temp = 1'b0; // TODO: check value 
                    Bc_Op_temp = 1'b1; // use branch control
                end


                  7'b0110111: begin // U-type load
                    //e.g. rd={imm[31:12]; 12'b0}
                    PC_s_temp = 1'b1; 
                    PC_we_temp = 1'b0; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; // select ALu

                    RegFile_we_temp = 1'b0; // enable reg write
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b0; 
                    ALU_op_temp = 2'b00; // alu load

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // choose alu
                    Data_we_temp = 1'b0;
                    Bc_Op_temp = 1'b0;
                end


                7'b1101111: begin // J-type jump and link 

                //rd=PC+4; PC=PC+sign_ext(imm)
                    // we do PC=PC+sign_ext(imm) this step
                    PC_s_temp = 1'b0; // choose alu value
                    PC_we_temp = 1'b0; // write alu value to pc
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; 

                    RegFile_we_temp = 1'b0; // write  PC=PC+sign_ext
                    Imm_op_temp = 1'b0;
                    ALU_s1_temp = 1'b0;
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00;

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b0; //select ALU
                    Data_we_temp = 1'b0; // need to double check 
                    Bc_Op_temp = 1'b0;
                end  
                
                7'b1100111: begin // JALR 

                    PC_s_temp = 1'b0; // choose alu value
                    PC_we_temp = 1'b0; // write alu value to pc
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; 

                    RegFile_we_temp = 1'b0; // write  PC=PC+sign_ext
                    Imm_op_temp = 1'b0;
                    ALU_s1_temp = 1'b0;
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00;

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b0; //select ALU
                    Data_we_temp = 1'b0; // need to double check 
                    Bc_Op_temp = 1'b0;
                end  
                
                 7'b0010111: begin // AUIPC  
                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b0; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; // take alu 

                    RegFile_we_temp = 1'b0; // write pc + 4
                   Imm_op_temp = 1'b1; // set since we load imm
                    ALU_s1_temp = 1'b1; // select Reg1
                    ALU_s2_temp = 1'b0; // select imm
                    ALU_op_temp = 2'b10; // alu do plus

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // take alu 
                    Data_we_temp = 1'b0; // need to double check 
                    Bc_Op_temp = 1'b0;
                end
            endcase
        end
        
        WRITEBACK: begin
                   case(opcode)
                7'b0110011: begin // R-type
                //rd = rs1 + rs2
                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b1; // add pc counter while store value, so we can continue
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b1; // select alu result

                    RegFile_we_temp = 1'b1;  // write alu result
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0;  
                    ALU_s2_temp = 1'b1; 
                    ALU_op_temp = 1'b00; 

                    //store 
                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // take ALU result
                    Data_we_temp = 1'b0; 
                    Bc_Op_temp = 1'b0;
                end

               7'b0000011: begin // I-type load and store in rd

                //rd=sign_ext(data[rs1+sign_ext(imm)][7:0])

                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b1; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b1; // select data 

                    RegFile_we_temp = 1'b1;  // write data to reg
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00; 

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b0; 
                    Data_we_temp = 1'b0;
                    Bc_Op_temp = 1'b0;
                end
                
                7'b0010011: begin // I-type addi ori andi ....
                // ! also implement fence here since it says to do the same as addi.
                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b1; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b1; // select data 

                    RegFile_we_temp = 1'b1;  // write data to reg
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00; 

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // take alu cal output 
                    Data_we_temp = 1'b0;
                    Bc_Op_temp = 1'b0;
                end
                
                7'b0001111: begin // this is the same as above
                // ! also implement fence here since it says to do the same as addi.
                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b1; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b1; // select data 

                    RegFile_we_temp = 1'b1;  // write data to reg
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00; 

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // take alu cal output 
                    Data_we_temp = 1'b0;
                    Bc_Op_temp = 1'b0;
                end

                 7'b0100011: begin // S-type store 
                 //e.g. data[rs1+sign_ext(imm)][7:0] = rs2[7:0]

                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b1; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; 

                    RegFile_we_temp = 1'b0; 
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0;  
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00;  // store 
                    
                    // we need to wait for this step and then store
                    DataMem_rd_temp = 1'b0; // store to data
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b0;
                    Data_we_temp = 1'b1; // TODO: check value  may depend on funct3
                    Bc_Op_temp = 1'b0;
                end

                 7'b1100011: begin // B-type Store ... of rs2 to memory
                // e.g. PC=(rs1==rs2) ? PC+sign_ext(imm) : PC+4

                    PC_s_temp = bc; // choose what to take base on bc
                    PC_we_temp = 1'b0; // write pc  1
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; 

                    RegFile_we_temp = 1'b0; 
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b0; 
                    ALU_op_temp = 2'b01; // cal: check branch

                    // may need to wait here 
                    DataMem_rd_temp = 1'b0; // 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = bc; // ! branch info based on branch control 
                    Data_we_temp = 1'b0; // TODO: check value 
                    Bc_Op_temp = 1'b0; // use branch control
                end


                  7'b0110111: begin // U-type load
                    //e.g. rd={imm[31:12]; 12'b0}
                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b1; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b1; // select ALu

                    RegFile_we_temp = 1'b1; // enable reg write
                    Imm_op_temp = 1'b0; 
                    ALU_s1_temp = 1'b0; 
                    ALU_s2_temp = 1'b0; 
                    ALU_op_temp = 2'b00; // alu load

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // choose alu
                    Data_we_temp = 1'b0;
                    Bc_Op_temp = 1'b0;
                end


                7'b1101111: begin // J-type jump and link 

                //rd=PC+4; PC=PC+sign_ext(imm)
                    // we do PC=PC+sign_ext(imm) this step
                    PC_s_temp = 1'b1; // choose alu value
                    PC_we_temp = 1'b1; // write alu value to pc
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b0; 

                    RegFile_we_temp = 1'b1; // write  PC=PC+sign_ext
                    Imm_op_temp = 1'b0;
                    ALU_s1_temp = 1'b0;
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00;

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b0; //select ALU
                    Data_we_temp = 1'b0; // need to double check 
                    Bc_Op_temp = 1'b0;
                end  
                
                 7'b1100111: begin // JALR

                    PC_s_temp = 1'b1; // choose alu value
                    PC_we_temp = 1'b1; // write alu value to pc
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b1; // write  PC=PC+sign_ext

                    RegFile_we_temp = 1'b1; // write  PC=PC+sign_ext
                    Imm_op_temp = 1'b0;
                    ALU_s1_temp = 1'b0;
                    ALU_s2_temp = 1'b0;
                    ALU_op_temp = 2'b00;

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; //select ALU
                    Data_we_temp = 1'b0; // need to double check 
                    Bc_Op_temp = 1'b0;
                end 
                
                7'b0010111: begin // AUIPC  
                    PC_s_temp = 1'b0; 
                    PC_we_temp = 1'b0; 
                    Instr_rd_temp = 1'b0;
                    RegFile_s_temp = 1'b1; // take alu 

                    RegFile_we_temp = 1'b1; // write alu output 
                    Imm_op_temp = 1'b1; // set since we load imm
                    ALU_s1_temp = 1'b1; // select Reg1
                    ALU_s2_temp = 1'b0; // select imm
                    ALU_op_temp = 2'b10; // alu do plus

                    DataMem_rd_temp = 1'b0; 
                    Data_op_temp = 1'b0; 
                    Data_s_temp = 1'b1; // take alu 
                    Data_we_temp = 1'b0; // need to double check 
                    Bc_Op_temp = 1'b0;
                end
            endcase
        end
        
        BRANCH_PAUSE_END: begin

            PC_s_temp = bc; // choose what to take base on bc
            PC_we_temp = 1'b1; // write pc 
            Instr_rd_temp = 1'b0;
            RegFile_s_temp = 1'b0; 

            RegFile_we_temp = 1'b0; 
            Imm_op_temp = 1'b0; 
            ALU_s1_temp = 1'b0; 
            ALU_s2_temp = 1'b0; 
            ALU_op_temp = 2'b00; // cal: check branch

            // may need to wait here 
            DataMem_rd_temp = 1'b0; // 
            Data_op_temp = 1'b0; 
            Data_s_temp = bc; // ! branch info based on branch control 
            Data_we_temp = 1'b0; // TODO: check value 
            Bc_Op_temp = 1'b0; // use branch control
        end
    endcase
   end
   
//   PC_s_temp, PC_we_temp, Instr_rd_temp, RegFile_s_temp, RegFile_we_temp, Imm_op_temp, ALU_s1_temp, ALU_s2_temp, DataMem_rd_temp, Data_op_temp, data_s_temp, Bc_Op_temp;
   always @(posedge clk or negedge rst) begin
    if(!rst) begin
        PC_s   = 1'b0;
        PC_we     = 1'b0;
        Instr_rd    = 1'b0;
        RegFile_s     = 1'b0;
        RegFile_we      = 1'b0;
        Imm_op = 1'b0;
        ALU_s1    = 1'b0;
        ALU_s2      = 2'b00;
        ALU_op_temp = 2'b00;
        DataMem_rd    = 1'b0;
        Data_op    = 1'b0;
        Data_s       = 1'b0; 
        Data_we  = 1'b0; 
        Bc_Op        = 1'b0; 
    end
    else begin
        PC_s         = PC_s_temp;
        PC_we        = PC_we_temp;
        Instr_rd     = Instr_rd_temp;
        RegFile_s    = RegFile_s_temp;
        RegFile_we   = RegFile_we_temp;
        Imm_op       = Imm_op_temp;
        ALU_s1       = ALU_s1_temp;
        ALU_s2       = ALU_s2_temp;
        ALU_op       = ALU_op_temp;
        DataMem_rd   = DataMem_rd_temp;
        Data_op      = Data_op_temp;
        Data_s       = Data_s_temp;
        Data_we      = Data_we_temp; 
        Bc_Op        = Bc_Op_temp;
    end
end
   
   //FSM
always @(*) begin
    case(curr_state)
        INITALIZE : 
            if(!rst)
                next_state = INITALIZE;
            else
                next_state = FETCH_INSTRUCTION;
                
        FETCH_INSTRUCTION :
            if(!rst)
                next_state = INITALIZE;
            else
                next_state = FETCH_DECODE;
                
        FETCH_DECODE: 
            if(!rst)
                next_state = INITALIZE;
            else if(opcode == 7'b1110011)
                next_state = HALT;
            else
                next_state = EXECUTION;
                
        EXECUTION :
            if(!rst)
                next_state = INITALIZE;
            else
                next_state = MEM;
                
        MEM : 
         if(!rst)
                next_state = INITALIZE;
         else
                next_state = WRITEBACK;
                
        WRITEBACK  : 
         if(!rst)
                next_state = INITALIZE;
        else if(opcode == 7'b1100011) begin
                next_state = BRANCH_PAUSE;
             end 
         else
                next_state = FETCH_INSTRUCTION;
         HALT:
            if(!rst)
                next_state = INITALIZE;
            else
                next_state = HALT;
         
         
         
         // pause for branch 
         BRANCH_PAUSE: 
            if(!rst) next_state = INITALIZE;
            else  next_state = BRANCH_PAUSE_END;
            
        BRANCH_PAUSE_END:
            if(!rst) next_state = INITALIZE;
            else  next_state = FETCH_INSTRUCTION;
        default:
            next_state = INITALIZE;
    endcase
end    
    
endmodule