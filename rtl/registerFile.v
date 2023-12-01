module RegisterFile(
    input clk,
    input rst,
    input en,
    input wire [4:0] readS1,
    input wire [4:0] readS2,
    input wire [4:0] readRd,
    input wire [31:0] data_in,
    output reg [31:0] rs1,
    output reg [31:0] rs2
);

reg [31:0] rf [0:31];

// Initialize the register file
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        rf[i] = 32'b0;
    end
    rs1 = 32'b0;
    rs2 = 32'b0;
end

// Reset and Write Operation
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        for (i = 0; i < 32; i = i + 1) begin
            rf[i] <= 32'b0;
        end
    end
    else if (en) begin
        if (readRd != 0) begin // Ensure we don't write to register 0
            rf[readRd] <= data_in;
        end
        rf[0] <= 32'b0; // Register 0 is always 0
    end
end

// Read Operation
always @(*) begin
    rs1 = (readS1 != 0) ? rf[readS1] : 32'b0;
    rs2 = (readS2 != 0) ? rf[readS2] : 32'b0;
end

endmodule