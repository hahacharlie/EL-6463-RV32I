`timescale 1ns / 1ps

module Head(
    input logic clk,
    input logic rst_n,
    input logic [15:0] boardSwitches,
    output logic [15:0] boardLEDs
);

    // output wire
    logic PC_s; 
    logic PC_we; // pc enable signal
    logic Instr_rd; // control instruction enable
    logic RegFile_s; 
    logic RegFile_we; // this is reg_enable
    logic Imm_op; 
    logic ALU_s1; 
    logic ALU_s2; 
    logic DataMem_rd; 
    logic Data_op; 
    logic Data_s; 
    logic Bc_Op; 
    logic Data_we;

    // * pc  
    logic [31:0] current_pc;
    logic [31:0] PC_inputAddress;
    logic [31:0] PC_outputAddress;
    
    logic [31:0] added4_pc;
 
    // * instr_mem
    logic [31:0] mem_instr_out;

    // * registor_file
    logic [31:0] readRd; // data goes in, 32 bits
    // output
    logic [31:0] rs1;
    logic [31:0] rs2;

    // * instruction decode
  
    // output
    logic [4:0] rd_addr;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] imm_ext_data;

    // output 
    logic [3:0] alu_ctrl;

    //* alu
    logic [31:0] operand1;
    logic [31:0] operand2;

    // output
    logic [31:0] alu_out;
    // dout 
    logic [31:0] dout;                  
    // * data ext 
    logic [31:0] dout_ext;
    
    
    
    
    
    ControlUnit ControlUnit(
    // input
    .clk                         (clk                ),
    .rst                         (rst_n              ),
    .opcode                      (opcode   ), // ! this will get opcode (last 7 bits of instr output from memory)
    .bc                          (branch_info),
    
    //output
    .PC_s(PC_s), 
    .PC_we(PC_we), 
    .Instr_rd(Instr_rd), 
    .RegFile_s(RegFile_s), 
    .RegFile_we(RegFile_we), 
    .ALU_s1(ALU_s1), 
    .ALU_s2(ALU_s2), 
    .DataMem_rd(DataMem_rd), 
    .Data_op(Data_op), 
    .Data_s(Data_s), 
    .Bc_Op(Bc_Op), 
    .Data_we(Data_we)
    
    );

    pc pc(
        .clk                         (clk                ),
        .rst                         (rst_n              ),
        .write_en                    (PC_we              ),
        .PC_inputAddress             (PC_inputAddress    ),
        // output
        .PC_outputAddress            (PC_outputAddress   )
    );
    assign current_pc = PC_inputAddress;
    
    
    Instruction Instruction(
        .clk                         (clk                ),
        .rst                         (rst_n              ),
        .read_instr                  (Instr_rd),
        .addr_in(PC_outputAddress),

        // output
        .instr_out(mem_instr_out)
    );
    
    RegisterFile RegisterFile(
        .clk  (clk),
        .rst  (rst_n),
        .en   (RegFile_we), 
        .readS1(rs1_addr), // take it from instr_decode
        .readS2(rs2_addr), // take it from instr_decode
        .readRd(rd_addr),// take it from instr_decode
        .data_in(readRd), // this is generated in reg mux
        
        //output 
        .rs1(rs1),
        .rs2(rs2)
    );
   Instruction_decode Instruction_decode(
        .clk(clk), 
        .instr_in(mem_instr_out), // memory output will be take in here
        
        // output
        .rd_addr(rd_addr),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .opcode(opcode),
        .funct(funct3),
        .funct7(funct7)
    );
    
    // after decode, we will go to imm_ext if needed
    imm_ext imm_ext(
        .clk(clk),
        .opcode(opcode),
        .instr_in(mem_instr_out),
        
        // output 
        .imm_ext(imm_ext_data)
    );

    Branch_control Branch_control(
        .operand1(operand1),
        .operand2(operand2),
        .bc_enable(Bc_Op),// take in control unit branch enable
        .funct3(funct3),
        .bc_out(branch_info)
    );

    alu_control alu_control(
        .clk(clk),
        .rst(rst_n),
        .funct7(funct7),
        .opcode(opcode),
        .funct3(funct3),

        // output 
        .alu_ctrl(alu_ctrl)
    );
    
    ALU ALU(
        .alu_ctrl(alu_ctrl),
        .operand1(operand1),
        .operand2(operand2),
        // output
        .alu_out(alu_out)
    );
    
    Data Data(     
     .clk(clk),
     .we_en(Data_we),
     .func3(funct3), 
     .re(DataMem_rd),
     .addr(alu_out), // alu output will be send to data as address
     .dmem_in(rs2), // reg 2 will be send as data in 
     .board_switches(boardSwitches),
     .board_LEDs(boardLEDs), // output 
     .dmem_out(dout)
    );
    
    data_ext data_ext(
        .data_in(dout),
        .funt3(funct3),
        .data_out(dout_ext)
    );

    // ! for data imm mux output

    wire [31:0] data_imm_s;
    reg [31:0] data_imm_s_temp;
    // ! here we will start implement muxes that are needed for different area 

    // * mux variable 
    reg [31:0] PC_input_addr_temp;
    reg [31:0] readRd_temp;
    reg [31:0] operand1_temp;
    reg [31:0] operand2_temp;

    // *pc_adder
    assign added4_pc = PC_outputAddress + 32'd4;
        
    // *pc_mux
    assign PC_inputAddress = PC_s ? PC_outputAddress + imm_ext_data : added4_pc;
    
    // *regfile mux
    assign readRd = RegFile_s ? data_imm_s : added4_pc;
        
    // *ALU mux 1
    assign operand1 = ALU_s1 ? PC_inputAddress : rs1;
     
    // *ALU mux 2
    assign operand2 = ALU_s2 ? rs2 : imm_ext_data;
    
    // *Data mem mux
    assign data_imm_s = Data_s ? alu_out : dout_ext;

endmodule
