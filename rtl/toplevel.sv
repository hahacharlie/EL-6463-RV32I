module toplevel(
    input   logic clk,
    input   logic rst_n,
    input   logic [15:0] boardSwitches,
    output  logic [15:0] boardLEDs
);

    // Define internal signals
    logic PC_s, PC_we, Instr_rd, RegFile_s, RegFile_we, Imm_op, ALU_s1, ALU_s2, DataMem_rd, Data_op, Data_s, Bc_Op, Data_we;
    logic [31:0] current_pc, PC_inputAddress, PC_outputAddress, added4_pc;
    logic [31:0] mem_instr_out;
    logic [31:0] readRd, rs1, rs2;
    logic [4:0] rd_addr, rs1_addr, rs2_addr;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] imm_ext_data;
    logic [3:0] alu_ctrl;
    logic [31:0] operand1, operand2, alu_out, dout, dout_ext;
    logic branch_info;

    // Include submodules
    ControlUnit control_unit(
        .clk(clk),
        .rst(rst_n),
        .opcode(opcode),
        .bc(branch_info),
        // Output signals
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

    ProgramCounter program_counter(
        .clk(clk),
        .rst(rst_n),
        .write_en(PC_we),
        .PC_inputAddress(PC_inputAddress),
        .PC_outputAddress(PC_outputAddress)
    );

    Instruction instruction(
        .clk(clk),
        .rst(rst_n),
        .read_instr(Instr_rd),
        .addr_in(PC_outputAddress),
        .instr_out(mem_instr_out)
    );

    RegisterFile register_file(
        .clk(clk),
        .rst(rst_n),
        .en(RegFile_we),
        .readS1(rs1_addr),
        .readS2(rs2_addr),
        .readRd(rd_addr),
        .data_in(readRd),
        .rs1(rs1),
        .rs2(rs2)
    );

    Instruction_decode instruction_decode(
        .clk(clk),
        .instr_in(mem_instr_out),
        .rd_addr(rd_addr),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .opcode(opcode),
        .funct(funct3),
        .funct7(funct7)
    );

    imm_ext imm_extension(
        .clk(clk),
        .opcode(opcode),
        .instr_in(mem_instr_out),
        .imm_ext(imm_ext_data)
    );

    Branch_control branch_control(
        .operand1(operand1),
        .operand2(operand2),
        .bc_enable(Bc_Op),
        .funct3(funct3),
        .bc_out(branch_info)
    );

    ALU_Control alu_control(
        .clk(clk),
        .rst(rst_n),
        .funct7(funct7),
        .opcode(opcode),
        .funct3(funct3),
        .alu_ctrl(alu_ctrl)
    );

    ALU alu(
        .alu_ctrl(alu_ctrl),
        .operand1(operand1),
        .operand2(operand2),
        .alu_out(alu_out)
    );

    data data_module(
        .clk(clk),
        .we_en(Data_we),
        .func3(funct3),
        .re(DataMem_rd),
        .addr(alu_out),
        .dmem_in(rs2),
        .board_switches(boardSwitches),
        .board_LEDs(boardLEDs),
        .dmem_out(dout)
    );

    data_ext data_extension(
        .data_in(dout),
        .funt3(funct3),
        .data_out(dout_ext)
    );

    // Implement multiplexers
    assign added4_pc = PC_outputAddress + 32'd4;
    assign PC_inputAddress = PC_s ? PC_outputAddress + imm_ext_data : added4_pc;
    assign readRd = RegFile_s ? data_imm_s : added4_pc;
    assign operand1 = ALU_s1 ? PC_inputAddress : rs1;
    assign operand2 = ALU_s2 ? rs2 : imm_ext_data;
    assign data_imm_s = Data_s ? alu_out : dout_ext;

endmodule
