`timescale 1ns / 1ps

module toplevel_complete_tb;
    // Parameters for clock
    localparam f = 200; // MHz
    localparam PERIOD = 1/(f * 0.001);

    // Testbench signals
    logic clk = 0;
    logic rst;
    logic [15:0] placeholderLEDs;
    logic [15:0] placeholderSwitches = 16'b0;

    // Instantiate the toplevel module
    toplevel dut(
        .clk(clk), 
        .rst_n(rst),
        .boardLEDs(placeholderLEDs), 
        .boardSwitches(placeholderSwitches)
    );

    // Data Memory Initialization
    initial begin
        dut.data.dmem[0] = 32'b1;
        dut.data.dmem[1] = 32'b1111;
        dut.data.dmem[2] = 32'b1; 
    end

    // Test variables and logic
    logic [6:0] round_count = 0;

    // Reset Logic
    initial begin
        rst = 1'b0;
        #100;
        rst = 1'b1;
    end

    // Instruction Memory Initialization
    logic [31:0] operand1 = 32'b000000110010;
    logic [31:0] operand2 = 32'b000001100100;
    initial begin
        dut.instruction_memory[0] = operand1;
        dut.instruction_memory[1] = operand2;
        // More instruction memory initializations can be added here
    end

    // Test Case Logic
    always @(*) begin
        if (dut.ControlUnit.next_state == 4'd2) begin
            round_count = round_count + 1;
        end
    end

    // Clock Generation
    initial begin
        forever #(PERIOD/2) clk = ~clk;
    end

    always @(round_count) begin
        // Testing R-type instructions
        if (round_count == 6'd13) begin
            $display("Testing R-type instructions at cycle %d", round_count);
            // Example: Check the results of an ADD operation
            // Assuming the operation is ADD x3, x1, x2 and the result should be in x3
            if (dut.RegisterFile.rf[3] != dut.RegisterFile.rf[1] + dut.RegisterFile.rf[2]) begin
                $display("R-type ADD test failed. Expected: %d, Got: %d", 
                         dut.RegisterFile.rf[1] + dut.RegisterFile.rf[2], dut.RegisterFile.rf[3]);
            end else begin
                $display("R-type ADD test passed.");
            end
        end

        // Testing I-type instructions (Immediate)
        if (round_count == 6'd14) begin
            $display("Testing I-type instructions at cycle %d", round_count);
            // Example: Check the result of an ADDI operation
            // Assuming the operation is ADDI x4, x1, immediate_value and the result should be in x4
            // immediate_value needs to be set appropriately
            int immediate_value = 10;
            if (dut.RegisterFile.rf[4] != dut.RegisterFile.rf[1] + immediate_value) begin
                $display("I-type ADDI test failed. Expected: %d, Got: %d",
                        dut.RegisterFile.rf[1] + immediate_value, dut.RegisterFile.rf[4]);
            end else begin
                $display("I-type ADDI test passed.");
            end
        end

        // Testing S-type instructions (Store)
        if (round_count == 6'd15) begin
            $display("Testing S-type instructions at cycle %d", round_count);
            // Example: Check if data is correctly stored in memory
            // Assuming the operation is STORE with data from x5 to a memory address
            // The specific memory address and data value in x5 need to be set
            logic [31:0] expected_data = dut.RegisterFile.rf[5];
            logic [31:0] memory_address = 0; // Set appropriate memory address
            if (dut.data.dmem[memory_address] != expected_data) begin
                $display("S-type STORE test failed. Expected: %d, Got: %d",
                        expected_data, dut.data.dmem[memory_address]);
            end else begin
                $display("S-type STORE test passed.");
            end
        end

        // Testing B-type instructions (Branch)
        if (round_count == 6'd16) begin
            $display("Testing B-type instructions at cycle %d", round_count);
            // Example: Check if a branch is taken or not taken based on condition
            // Assuming a BEQ operation, check if the program counter is updated correctly
            // Specific registers and branch condition need to be set before this test
            logic [31:0] expected_pc_after_branch = 0; // Set this based on the branch target
            if (dut.ProgramCounter.PC_outputAddress != expected_pc_after_branch) begin
                $display("B-type BEQ test failed. Expected PC: %d, Got PC: %d",
                        expected_pc_after_branch, dut.ProgramCounter.PC_outputAddress);
            end else begin
                $display("B-type BEQ test passed.");
            end
        end

        // Testing U-type instructions (Upper Immediate)
        if (round_count == 6'd17) begin
            $display("Testing U-type instructions at cycle %d", round_count);
            // Example: Check the result of a LUI operation
            // Assuming the operation is LUI x6, immediate_value and the result should be in x6
            // immediate_value needs to be set appropriately
            int u_immediate_value = 0x12345;
            if (dut.RegisterFile.rf[6] != (u_immediate_value << 12)) begin
                $display("U-type LUI test failed. Expected: %d, Got: %d",
                        u_immediate_value << 12, dut.RegisterFile.rf[6]);
            end else begin
                $display("U-type LUI test passed.");
            end
        end

        // Testing J-type instructions (Jump)
        if (round_count == 6'd18) begin
            $display("Testing J-type instructions at cycle %d", round_count);
            // Example: Check if the program counter is correctly updated after a JAL operation
            // The specific jump target needs to be set before this test
            logic [31:0] expected_pc_after_jump = 0; // Set appropriate jump target
            if (dut.ProgramCounter.PC_outputAddress != expected_pc_after_jump) begin
                $display("J-type JAL test failed. Expected PC: %d, Got PC: %d",
                        expected_pc_after_jump, dut.ProgramCounter.PC_outputAddress);
            end else begin
                $display("J-type JAL test passed.");
            end
        end
    end

    if (round_count == required_count) begin
        $display("Test completed.");
        $finish;
    end

    // Monitor and display internal states and outputs
    initial begin
        $monitor("Time = %0t, Reset = %b, Switches = %h, LEDs = %h",
                 $time, rst, placeholderSwitches, placeholderLEDs);
    end
endmodule