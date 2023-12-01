# GY-6463 Advanced Hardware Design Final Project

## Charlie
### PC 
### Control Unit

## Heng
### Instruction 
### Data Memory

## Jessy
1. ALU (Arithmetic Logic Unit)
Description
The ALU performs various arithmetic and logical operations, determined by the alu_ctrl input. It supports a range of operations including addition, subtraction, bitwise operations (XOR, OR, AND), logical and arithmetic shifts, as well as signed/unsigned comparisons. The ALU takes two 32-bit operands as input and produces a 32-bit output based on the selected operation.

Testbench (ALU_tb)
The ALU testbench verifies each operation by applying different control signals and operands. It checks for correct functionality in arithmetic calculations, bitwise operations, shifts, and comparisons. The test results are displayed, ensuring the ALU operates correctly under various scenarios.

2. RegisterFile
Description
The RegisterFile module simulates a 32x32-bit register file. It includes read and write operations, controlled by the input signals. The module ensures that Register 0 always reads zero and is unaffected by write operations. It responds to the positive clock edge and includes a reset functionality.

Testbench (RegisterFile_tb)
The RegisterFile testbench validates functionality including reset behavior, write operations, read operations, and the behavior of Register 0. It ensures data integrity in read/write operations and that Register 0 always reads zero. The testbench also checks the write enable control, confirming that no data is written when the write enable is low.
