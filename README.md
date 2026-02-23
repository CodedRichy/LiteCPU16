# LiteCPU16

LiteCPU16 is a minimal 16-bit single-cycle embedded processor designed explicitly for educational purposes. It serves as an accessible introduction to computer architecture, demonstrating how a Central Processing Unit (CPU) functions at the hardware level.

## Introduction to CPUs and Hardware Description Languages

A Central Processing Unit (CPU) acts as the logic center of any computer, executing the mathematical operations and decisions required to run software. 

Unlike typical software written in languages like Python or C++, LiteCPU16 is constructed using Verilog. Verilog is a Hardware Description Language (HDL)—it describes physical logic gates and electrical pathways rather than software routines. By reading this project's code, you are viewing the blueprint of a physical microchip.

## Core Architecture Features

LiteCPU16 strips away the modern complexities of commercial processors (such as pipelining, caching, and interrupts) to focus exclusively on fundamental mechanics:

*   **16-bit Architecture:** The processor handles data and memory addresses in 16-bit segments (binary numbers up to 16 digits long).
*   **Harvard Architecture:** It utilizes separate memory structures for instructions (the program sequence) and data (the variables being processed), preventing structural hazards.
*   **Reduced Instruction Set:** It implements only five essential instructions:
    1.  `ADD`: Performs addition on two registers.
    2.  `LW` (Load Word): Retrieves a value from Data Memory into a register.
    3.  `SW` (Store Word): Saves a value from a register into Data Memory.
    4.  `BEQ` (Branch if Equal): Checks if two registers are equal, and alters the instruction sequence if true.
    5.  `NOP` (No Operation): A safe placeholder instruction that performs no action.
*   **Single-Cycle Execution:** Every instruction completes entirely within one clock cycle. 

## The 8-File Modular Structure

Real processors consist of interconnected functional units. LiteCPU16 is divided into 8 distinct Verilog files to model these units clearly:

1.  **`cpu_top.v`**: The Top-Level Module. It wires all internal components and memory interfaces together into a single cohesive processor.
2.  **`pc.v`** (Program Counter): A register that holds the memory address of the instruction currently being executed.
3.  **`instr_mem.v`** (Instruction Memory): A read-only memory block containing the sequence of commands the CPU must execute.
4.  **`dmem.v`** (Data Memory): A read/write memory block that stores the data values the CPU is actively manipulating.
5.  **`control.v`** (Control Unit): The decoding logic. It evaluates the current instruction opcode and orchestrates control signals to direct the rest of the processor.
6.  **`regfile.v`** (Register File): Fast, internal working memory consisting of 8 slots (`R0` through `R7`). `R0` is physically hardwired to the value 0.
7.  **`alu.v`** (Arithmetic Logic Unit): The computational core. It handles arithmetic operations (addition) and logical evaluations (equality comparisons).
8.  **`sign_ext.v` & `branch_unit.v`**: Auxiliary logic. These modules handle the extension of negative offsets and calculate target addresses for branch instructions, respectively.

## Running the Simulation

Because LiteCPU16 is described in Verilog, you can simulate its electrical behavior directly on your computer to observe instructions executing step-by-step.

**Prerequisites:** You must have a Verilog simulator installed, such as [Icarus Verilog](https://bleyer.org/icarus/) (`iverilog`).

### Simulation Steps
1. Open your system's command line interface.
2. Compile the design modules alongside the test environment:
   ```bash
   iverilog -o litecpu16_sim tb_litecpu16.v cpu_top.v pc.v control.v regfile.v alu.v sign_ext.v branch_unit.v instr_mem.v dmem.v
   ```
3. Execute the resulting simulation binary:
   ```bash
   vvp litecpu16_sim
   ```

Upon execution, the testbench will output the state of the registers and memory to verify that the processor correctly executed its hardcoded instruction sequence.