module alu_control(
    input logic clk,
    input logic rst,
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output logic [3:0] alu_ctrl
);

logic usesFunc7;
logic [3:0] alu_op_tmp;

// Function to determine ALU control signals
function automatic [3:0] determine_alu_ctrl(logic [6:0] opcode, logic [2:0] funct3, logic usesFunc7);
    case (opcode)
        7'b0110011:  // R-type
            return {usesFunc7, funct3};
        7'b0010011:  // I-type
            return {1'b0, funct3};
        7'b1100011:  // Branch
            case (funct3)
                3'b000, 3'b001: return 4'b1000;  // BEQ, BNE
                3'b100, 3'b101: return 4'b0010;  // BLT, BGE
                3'b110, 3'b111: return 4'b0011;  // BLTU, BGEU
                default: return 4'b0000;
            endcase
        default: return 4'b0000;
    endcase
endfunction

always_ff @(posedge clk or negedge rst) begin
    if (!rst)
        alu_ctrl <= 4'b0;
    else 
        alu_ctrl <= alu_op_tmp;
end

assign usesFunc7 = funct7[5];
always_comb begin
    alu_op_tmp = determine_alu_ctrl(opcode, funct3, usesFunc7);
end

endmodule