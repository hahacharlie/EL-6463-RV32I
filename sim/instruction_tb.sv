module Instruction_TB;

    logic         t_clk = 0;
    logic         t_rst = 0;
    logic         t_read_instr = 0;
    logic [31:0]  t_addr_in;
    wire [31:0]   t_instr_out;
   
    Instruction dut(
        .clk(t_clk), 
        .rst(t_rst), 
        .read_instr(t_read_instr), 
        .addr_in(t_addr_in), 
        .instr_out(t_instr_out)
    );
   
    // Clock process
    always begin
        t_clk = 0;
        #5;
        t_clk = 1;
        #5;
    end

    logic [31:0] file_instr;
    logic [31:0] instr_ram[0:511];

    // Initial block for testbench execution
    initial begin   
        #1;
        $readmemh("instruction.mem", instr_ram);
        t_read_instr = 1;
        t_addr_in = 32'h01000000;
        file_instr = instr_ram[t_addr_in[23:2]];
        #10;
        if (t_instr_out != file_instr) begin
            t_read_instr = 0;
            $display("FAILURE: Do not match (instruction)");
            $stop;
        end else begin
            t_read_instr = 0;
        end
        #40;
        
        // Repeat test for remaining addresses
        repeat (511) begin
            t_read_instr = 1;
            t_addr_in += 4;
            file_instr = instr_ram[t_addr_in[23:2]];
            #10;
            if (t_instr_out != file_instr) begin
                $display("FAILURE: Do not match (instruction)");
                $stop;
            end else begin
                t_read_instr = 0;
            end
            #40;
        end
        
        t_rst = 0;
        #28;
        t_rst = 1;
        #2;

        $display("Test finished");
    end
      
endmodule

