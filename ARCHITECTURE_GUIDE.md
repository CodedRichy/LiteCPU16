# LiteCPU16 Architecture Guide

This document provides a comprehensive, step-by-step breakdown of how the LiteCPU16 processor executes instructions. It is designed for contributors and students learning computer architecture.

---

## The Execution Cycle

Every processor operates on a continuous cycle. For the LiteCPU16, a single-cycle processor, this involves three overlapping conceptual phases that all complete before the next clock tick:

1.  **Fetch:** Retrieve the instruction from memory.
2.  **Decode:** Determine what the instruction means and read the necessary data.
3.  **Execute & Writeback:** Perform the math/logic and save the result.

Let's trace how data flows through the 8 distinct Verilog modules during this cycle.

---

## 1. Fetching the Instruction

The process begins with figuring out *where* we are in the program.

### `pc.v` (Program Counter)
This module holds a 16-bit address pointing to the current instruction. On every positive edge of the clock (the "tick"), it updates to the `next_pc` value.

### `instr_mem.v` (Instruction Memory)
The address from the Program Counter is routed directly into the Instruction Memory. Think of this as looking up a specific page in a recipe book. The memory instantly (asynchronously) outputs the 16-bit instruction stored at that address to the rest of the processor.

---

## 2. Decoding the Instruction

Now that the processor has a 16-bit instruction (e.g., `001_001_010_011_0000` for an `ADD`), it needs to understand it. The 16 bits are split into specific fields based on the instruction format.

*   **Opcode (Bits [15:13]):** The first 3 bits dictate the operation (`ADD`, `LW`, `SW`, etc.).
*   **Registers (Bits [12:10], [9:7], [6:4]):** These identify which internal storage slots the instruction wants to read from or write to.
*   **Immediate (Bits [6:0]):** A hardcoded number embedded directly in the instruction (used for memory offsets or branching).

### `control.v` (Control Unit)
The Control Unit is the brain's dispatcher. It reads the 3-bit Opcode and orchestrates the entire datapath by throwing a series of conceptual "switches" (control signals). For example, if it sees the opcode for `LW` (Load Word), it asserts `mem_read` and tells the register file to prepare for an incoming write (`reg_write = 1`).

### `sign_ext.v` (Sign Extension)
If the instruction contains a 7-bit Immediate value, it must be padded to a full 16 bits so the ALU can perform math on it. The Sign Extension module ensures that negative numbers remain negative when padded.

### `regfile.v` (Register File)
The instruction specifies up to two source registers to read from. The Register File immediately outputs the values held in those specific slots (e.g., `R1` and `R2`) on wires `rdata1` and `rdata2`. 
*(Note: `R0` is physically hardwired to always return `0`, a common architectural trick useful for negating numbers or absolute memory referencing).*

---

## 3. Execute & Writeback

With the data retrieved and the Control Unit directing traffic, the processor performs the actual work.

### `alu.v` (Arithmetic Logic Unit)
The ALU takes the two data inputs (either two registers, or one register and the extended immediate value, depending on what the Control Unit decided). 
*   If it's an `ADD`, `LW`, or `SW`, it adds them together. (For memory ops, adding a register to an immediate calculates the exact memory address).
*   If it's a `BEQ` (Branch on Equal), it subtracts them. If the result is exactly `0`, the ALU asserts the `zero` flag.

### `dmem.v` (Data Memory)
If the instruction is interacting with RAM (RAM access):
*   **`SW` (Store Word):** The data from the second register is saved into Data Memory at the address calculated by the ALU.
*   **`LW` (Load Word):** Data is read out from the Memory at the address calculated by the ALU.

### Writeback to `regfile.v`
Depending on the instruction, the final result must be saved back into the Register File. 
*   If it was an `ADD`, the ALU's output is routed back to the Register File.
*   If it was an `LW`, the Data Memory's output is routed back instead.
The Control Unit uses the `mem_to_reg` multiplexer signal to choose which wire connects to the register write port. On the next clock tick, this data is saved.

---

## 4. Determining the Next Move

Simultaneously, the processor must calculate where the *next* instruction lives.

### `branch_unit.v` (Branch Unit)
By default, the Branch Unit simply calculates `PC + 1`. 
However, if the current instruction is a `BEQ` **and** the ALU asserted the `zero` flag (meaning the two registers matched), the Branch Unit adds the immediate offset to the PC instead. 

This calculated `next_pc` is routed back to the very absolute beginning—the `pc.v` module. When the clock ticks, the cycle begins entirely anew.
