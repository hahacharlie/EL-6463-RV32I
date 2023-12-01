# GY-6463 Advanced Hardware Design Final Project

## Charlie (qw2246)
### PC 
#### Description
The program counter is simple a 32-bit register that contains the address of the next instruction to be executed by the processor. Upon reset this will be reset to the start address. 
#### Testbench
The testbench will first test the reset, then test three normal operations to ensure correct functionality. 
### Control Unit
#### Description
Control Unit is the central control for the entire processor, which decodes a 32-bit instruction and generates control signals like `branch`, `mem_read`, `mem_write`, and specific ALU operations, corresponding to different instruction types (R-type, I-type, S-type, B-type, U-type, J-type). The module serves as the central part of the instruction execution process, determining how the CPU's components should respond to each instruction. 
#### Testbench
The testbench tested each type of instructions. It systematically tests the 'control_unit' by applying various types of instructions (R-type, I-type, S-type, B-type, U-type, J-type, FENCE, ECALL, and EBREAK) and checking the output signals against expected values. The testbench ensures that the 'control_unit' correctly interprets each instruction and generates appropriate control signals, crucial for validating the correct operation of the control unit in a CPU or similar digital system. Corner cases were also added, like `EBREAK`, `ECALL`, `FENCE`. 

## Heng (hw3200)
### Instruction Memory 
#### Module Description
* The Instruction Memory module is implemented in System Verilog.
* It is designed to simulate a read-only memory (ROM) segment that stores the processor's instruction set.
* The module fetches instructions based on the input address and provides them to the processor for execution.
##### Key Features
* **Parameterized Design**: The module allows for flexible memory size and data width settings.
* **Memory Initialization**: The ROM is preloaded with a set of instructions from an external memory file.
* **Instruction Fetch**: On receiving a read instruction signal, the module fetches the instruction at the given address.
#### Memory File
* The memory file (`instruction.mem`) contains the preloaded instructions for the processor.
* Each line in the file represents a 32-bit instruction in hexadecimal format, as per the RV32I instruction set.
##### Instructions Overview
* The instructions in the file are a subset of the RISC-V RV32I instruction set.
* Examples include:
  - **ADD**: Adds the contents of two registers and stores the result in a destination register.
  - **SLL**: Performs a logical left shift on a register value.
  - **SLT**: Sets the destination register to 1 if the first source register is less than the second (signed comparison).
  - **SLTU**: Unsigned version of SLT.
  - **XOR**: Performs a bitwise exclusive OR between two registers.
  - **OR**: Performs a bitwise OR between two registers.
  - **AND**: Performs a bitwise AND between two registers.
  - **ADDI**: Adds an immediate value to a register.
  - **BEQ**: Branches to an address if two registers are equal.
  - **ECALL/EBREAK**: System call or breakpoint instructions for special operations.
### Data Memory
#### Module Implementation
* The `Data` module is a System Verilog implementation designed to emulate the processor's data memory.
* It incorporates multiple memory arrays and supports various modes of operation for both reading and writing data.
##### Key Features
* **Multiple Memory Arrays**: Comprises four separate arrays (`dmem1`, `dmem2`, `dmem3`, `dmem4`), each 8-bit wide and 1024 elements long.
* **Memory Initialization**: On module startup, all memory arrays are initialized to zero.
* **Flexible Addressing**: Addressing logic allows for byte-aligned access to 32-bit wide memory, accommodating different read and write operations.
#### Data Access and Manipulation
* **Address Calculation**: 
  - The `addr_in` input is masked and adjusted to calculate the actual memory address (`addr_dmem`) for data access.
  - Addresses are further processed to determine the specific row and byte index within the memory arrays.
* **Read Operations**:
  - The module supports reading data in various sizes (byte, half-word, word) based on the `r_mode` signal.
  - Data read from the memory arrays is combined and outputted through `dout`.
* **Write Operations**:
  - Write operations are contingent on the `w_mode` signal.
  - Data (`din`) can be written in different sizes to the memory arrays depending on the operational mode and the address.
#### Testbench (`Testbench_DM`)
* The testbench is designed to extensively verify the module's functionality under various scenarios.
* It includes a clock generation process and simulates different read/write operations.
##### Testing Scenarios
* **Initial Conditions**: Verifies the memory's initial state post-reset.
* **Byte, Half-Word, and Word Access**: Tests reading and writing of different data sizes.
* **Boundary Cases**: Assesses module behavior at the edges of the memory space.
* **Failure Checks**: Includes assertions to confirm the module's correct response to various inputs and conditions.

## Jessy (yc7080)
### ALU (Arithmetic Logic Unit)
#### Description
The ALU performs various arithmetic and logical operations, determined by the alu_ctrl input. It supports a range of operations including addition, subtraction, bitwise operations (XOR, OR, AND), logical and arithmetic shifts, as well as signed/unsigned comparisons. The ALU takes two 32-bit operands as input and produces a 32-bit output based on the selected operation.
#### Testbench
The ALU testbench verifies each operation by applying different control signals and operands. It checks for correct functionality in arithmetic calculations, bitwise operations, shifts, and comparisons. The test results are displayed, ensuring the ALU operates correctly under various scenarios.
### RegisterFile
#### Description
The RegisterFile module simulates a 32x32-bit register file. It includes read and write operations, controlled by the input signals. The module ensures that Register 0 always reads zero and is unaffected by write operations. It responds to the positive clock edge and includes a reset functionality.
#### Testbench
The RegisterFile testbench validates functionality including reset behavior, write operations, read operations, and the behavior of Register 0. It ensures data integrity in read/write operations and that Register 0 always reads zero. The testbench also checks the write enable control, confirming that no data is written when the write enable is low.
