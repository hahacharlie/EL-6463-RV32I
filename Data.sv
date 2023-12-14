`timescale 1ns / 1ps

module Data(
    input logic clk,
    input logic [31:0] addr,
    input logic [2:0] func3,   
    input logic we_en,
    input logic re,
    input logic [31:0] dmem_in,
    input logic [15:0] board_switches,
    output logic [15:0] board_LEDs,
    output logic [31:0] dmem_out
);

    logic [31:0] dmem [1023:0];
    logic [9:0] dmem_addr;
    logic [31:0] dmem_out_tmp;
    logic [31:0] dmem_tmp;
    logic [31:0] data_out;

    logic [15:0] switch_values;
    
    // Initialize data memory
    initial begin
        $readmemh("initialize.txt", dmem);
    end

    (* rom_style = "block" *) logic [31:0] rom_data;
    always_ff @(posedge clk) begin
        if (re) begin
            case (addr[3:2])
                2'b00: rom_data <= 32'd13000639;
                2'b01: rom_data <= 32'd10923038;
                2'b10: rom_data <= 32'd19039807;        
                2'b11: rom_data <= 32'd00000000;
            endcase
        end
    end
                     
    logic [15:0] LED_temp = 16'hF000;

    // Testing related variables
    logic [2:0] checkAddr;

    (* rom_style = "block" *) logic [31:0] board; 
    always_ff @(posedge clk) begin
        checkAddr = addr[4:2];
        case (addr[4:2])
            3'b100: if (re) board <= {16'b0, board_switches}; // switches
            3'b101: if (re) board <= dmem[addr[11:2]]; // leds
        endcase
    end
    
    // Store decode
    logic [7:0] dmem_in_0_temp;
    logic [7:0] dmem_in_1_temp;
    logic [7:0] dmem_in_2_temp;
    logic [7:0] dmem_in_3_temp;
    assign dmem_addr = addr[11:2]; // 000000001101 will be 0000000011

    always_ff @(posedge clk) begin
        case (func3)
            3'b000, 3'b100: begin // load byte
                dmem_in_0_temp = dmem_in[7:0];
                dmem_in_1_temp = dmem[dmem_addr][15:8];
                dmem_in_2_temp = dmem[dmem_addr][23:16];
                dmem_in_3_temp = dmem[dmem_addr][31:24];
            end
            3'b001, 3'b101: begin // load half, 2 bytes
                dmem_in_0_temp = dmem_in[7:0];
                dmem_in_1_temp = dmem_in[15:8];
                dmem_in_2_temp = dmem[dmem_addr][23:16];
                dmem_in_3_temp = dmem[dmem_addr][31:24];
            end
            3'b010: begin // load word, 4 bytes
                dmem_in_0_temp = dmem_in[7:0];
                dmem_in_1_temp = dmem_in[15:8];
                dmem_in_2_temp = dmem_in[23:16];
                dmem_in_3_temp = dmem_in[31:24];
            end
        endcase 
    end
    
    assign dmem_tmp  = {dmem_in_3_temp, dmem_in_2_temp, dmem_in_1_temp, dmem_in_0_temp};

    // Data memory handling
    always_ff @(posedge clk) begin
        if (we_en) begin
            if (addr[4:2] == 3'b101) begin 
                dmem[dmem_addr] <= dmem_in; 
                LED_temp <= dmem_in;
            end
            dmem[dmem_addr] <= dmem_tmp;
        end
    end

    always_ff @(posedge clk) begin
        if (re) begin 
            data_out <= dmem[dmem_addr];
        end
    end

    assign board_LEDs = LED_temp;
    assign dmem_out = addr[31]? data_out
                    : addr[20]? (addr[4]? board : rom_data)
                    : 'hz;
endmodule
