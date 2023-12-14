`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2023 09:34:23 PM
// Design Name: 
// Module Name: Data
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

module Data(
    input logic         clk,
    input logic         rst,
    input logic [2:0]   w_mode,
    input logic [2:0]   r_mode,
    input logic [31:0]  addr_in,
    input logic [31:0]  din,
    input logic [9:0]   opc_in,
    output logic [31:0] dout
);

    logic [7:0]     dmem1[0:1023];
    logic [7:0]     dmem2[0:1023];
    logic [7:0]     dmem3[0:1023];
    logic [7:0]     dmem4[0:1023];
    
    initial begin
        for (int i = 0; i < 1024; i++) begin
            dmem1[i] = 0;
            dmem2[i] = 0;
            dmem3[i] = 0;
            dmem4[i] = 0;
        end
    end

    logic [31:0] row;
    logic [31:0] addr_dmem;
    logic [31:0] index_dmem;
    logic [31:0] index;
    logic [31:0] dO;
    logic [31:0] d_t;
    logic        dout_se;
    logic [9:0]  opcode;
    logic [6:0]  func7;
    logic [2:0]  func3;
    
    assign addr_dmem = addr_in & (~32'h80000000);
    assign row = {2'b0, addr_dmem[31:2]};
    assign index_dmem = addr_in & 32'h00000003;
    assign index = index_dmem;
    
    assign opcode = opc_in;
    assign dout_se = (opcode == 10'b0000000011 || opcode == 10'b0010000011);
    
    assign func7 = opc_in[6:0];
    assign func3 = opc_in[9:7];
    
    always_ff @(negedge rst or posedge clk) begin
        if (!rst) begin
            dO <= 0;
        end else begin
            if (addr_dmem < 4096) begin
                case (r_mode)
                    3'b001: dO <= {24'h000000, dmem1[row]};
                    3'b011: dO <= {16'h0000, dmem2[row], dmem1[row]};
                    3'b111: dO <= {dmem4[row], dmem3[row], dmem2[row], dmem1[row]};
                    default: dO <= 0;
                endcase
            end else begin
                dO <= 0;
            end
        end
    end
    
    always_comb begin
        if (dout_se) begin
            case (func3)
                3'b000: d_t = {{24{dO[7]}}, dO[7:0]};
                3'b001: d_t = {{24{dO[15]}}, dO[15:0]};
                default: d_t = dO;
            endcase
        end else begin
            case (func3)
                3'b100: d_t = {{24{dO[7]}}, dO[7:0]};
                3'b101: d_t = {{24{dO[15]}}, dO[15:0]};
                default: d_t = dO;
            endcase
        end
    end

    assign dout = d_t;

    always_ff @(posedge clk) begin
        if (addr_dmem < 4096) begin
            if (w_mode == 3'b001) begin
                case (index)
                    0: dmem1[row] <= din[7:0];
                    1: dmem2[row] <= din[7:0];
                    2: dmem3[row] <= din[7:0];
                    3: dmem4[row] <= din[7:0];
                endcase
            end else if (w_mode == 3'b011) begin
                case (index)
                    0: begin
                            dmem1[row] <= din[7:0];
                            dmem2[row] <= din[15:8];
                        end
                    1: begin
                            dmem2[row] <= din[7:0];
                            dmem3[row] <= din[15:8];
                        end
                    2: begin
                            dmem3[row] <= din[7:0];
                            dmem4[row] <= din[15:8];
                        end
                    3: begin
                            dmem4[row] <= din[7:0];
                            dmem1[row + 1] <= din[15:8];
                        end
                endcase
            end else if (w_mode == 3'b111) begin
                case (index)
                    0: begin
                            dmem1[row] <= din[7:0];
                            dmem2[row] <= din[15:8];
                            dmem3[row] <= din[23:16];
                            dmem4[row] <= din[31:24];
                        end
                    1: begin
                            dmem2[row] <= din[7:0];
                            dmem3[row] <= din[15:8];
                            dmem4[row] <= din[23:16];
                            dmem1[row + 1] <= din[31:24];
                        end
                    2: begin
                            dmem3[row] <= din[7:0];
                            dmem4[row] <= din[15:8];
                            dmem1[row + 1] <= din[23:16];
                            dmem2[row + 1] <= din[31:24];
                        end
                    3: begin
                            dmem4[row] <= din[7:0];
                            dmem1[row + 1] <= din[15:8];
                            dmem2[row + 1] <= din[23:16];
                            dmem3[row + 1] <= din[31:24];
                        end
                endcase
            end
        end
    end

endmodule
