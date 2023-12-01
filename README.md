# Instruction Memory  

## Module Description
* The Instruction Memory module is implemented in System Verilog.
* It is designed to simulate a read-only memory (ROM) segment that stores the processor's instruction set.
* The module fetches instructions based on the input address and provides them to the processor for execution.

### Key Features
* **Parameterized Design**: The module allows for flexible memory size and data width settings.
* **Memory Initialization**: The ROM is preloaded with a set of instructions from an external memory file.
* **Instruction Fetch**: On receiving a read instruction signal, the module fetches the instruction at the given address.

## Memory File
* The memory file (`instruction.mem`) contains the preloaded instructions for the processor.
* Each line in the file represents a 32-bit instruction in hexadecimal format, as per the RV32I instruction set.

### Instructions Overview
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


# Data Memory


## Module Implementation
* The `Data` module is a System Verilog implementation designed to emulate the processor's data memory.
* It incorporates multiple memory arrays and supports various modes of operation for both reading and writing data.

### Key Features
* **Multiple Memory Arrays**: Comprises four separate arrays (`dmem1`, `dmem2`, `dmem3`, `dmem4`), each 8-bit wide and 1024 elements long.
* **Memory Initialization**: On module startup, all memory arrays are initialized to zero.
* **Flexible Addressing**: Addressing logic allows for byte-aligned access to 32-bit wide memory, accommodating different read and write operations.

## Data Access and Manipulation
* **Address Calculation**: 
  - The `addr_in` input is masked and adjusted to calculate the actual memory address (`addr_dmem`) for data access.
  - Addresses are further processed to determine the specific row and byte index within the memory arrays.
* **Read Operations**:
  - The module supports reading data in various sizes (byte, half-word, word) based on the `r_mode` signal.
  - Data read from the memory arrays is combined and outputted through `dout`.
* **Write Operations**:
  - Write operations are contingent on the `w_mode` signal.
  - Data (`din`) can be written in different sizes to the memory arrays depending on the operational mode and the address.

## Testbench (`Testbench_DM`)
* The testbench is designed to extensively verify the module's functionality under various scenarios.
* It includes a clock generation process and simulates different read/write operations.

### Testing Scenarios
* **Initial Conditions**: Verifies the memory's initial state post-reset.
* **Byte, Half-Word, and Word Access**: Tests reading and writing of different data sizes.
* **Boundary Cases**: Assesses module behavior at the edges of the memory space.
* **Failure Checks**: Includes assertions to confirm the module's correct response to various inputs and conditions.
