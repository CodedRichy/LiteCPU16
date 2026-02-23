# LiteCPU16 🚀

Welcome to **LiteCPU16**! This is a simple, beginner-friendly 16-bit processor built purely for educational purposes. 

If you've ever wondered **"how does a computer actually think?"**, this project is your front-row ticket to understanding the magic beneath the keyboard! 

---

## 🧐 What is this?
A CPU (Central Processing Unit) is the "brain" of a computer. When you open a web browser, play a game, or type a document, the CPU is the thing doing all the heavy lifting and math in the background.

**LiteCPU16** is a **minimalist, custom-built brain**. We took the complex core of what a CPU is, stripped away all the modern complicated features, and kept only the absolute essentials. 

It is written in a language called **Verilog**, which is a "Hardware Description Language" (HDL). Instead of writing code to create an app or a website, Verilog lets us write code to **design a physical microchip**. 

## 🧠 Core Features 
We built LiteCPU16 to be as simple as possible so you can study how it works!

*   **16-bit Architecture:** It thinks about numbers up to 16 binary digits long (0s and 1s) at a time.
*   **Harvard Architecture:** It has two separate "brains" for memory—one for remembering instructions (what to do) and one for remembering data (the things it's working on). 
*   **5 Instructions Only:** It knows how to do exactly 5 things:
    1.  `ADD`: Add two numbers together.
    2.  `LW` (Load Word): Grab a number from memory.
    3.  `SW` (Store Word): Save a number into memory.
    4.  `BEQ` (Branch if Equal): Skip to a different instruction if two numbers match.
    5.  `NOP` (No Operation): Do absolutely nothing for a second.
*   **Single-Cycle:** It completes one full instruction in a single "tick" or heartbeat of its clock. No waiting!

---

## 📁 How is it Built? (The 8-File Structure)
A real processor is made up of different smaller departments that work together like a factory. We divided LiteCPU16 up into 8 clean files so you can see exactly what each department does:

1.  **`cpu_top.v`**: The Factory Floor Manager. It connects all the other departments together so they can talk.
2.  **`pc.v`** (Program Counter): The Bookmark. It simply remembers which instruction step the CPU is currently on.
3.  **`instr_mem.v`** (Instruction Memory): The Recipe Book. It holds the list of instructions the CPU needs to follow.
4.  **`dmem.v`** (Data Memory): The Filing Cabinet. It holds the data/numbers the CPU is currently working with. 
5.  **`control.v`** (Control Unit): The Traffic Cop. It reads the current instruction and tells all the other departments what they need to do for that specific instruction.
6.  **`regfile.v`** (Register File): The Scratchpad. A tiny, super-fast piece of memory right next to the calculator. It has 8 slots (R0 to R7) to hold numbers it's working on Right Now.
7.  **`alu.v`** (Arithmetic Logic Unit): The Calculator. It does the actual math (like adding two numbers or checking if they are equal). 
8.  **`sign_ext.v` & `branch_unit.v`**: The Navigators. They help the CPU handle negative numbers and figure out where to jump in the recipe book if it needs to skip around.

---

## 🛠️ How to Play with It
Because this is written in Verilog, you can run a **simulation** of it on your computer to watch it tick!

**Prerequisites:** You'll need a program called **Icarus Verilog** (`iverilog`) installed on your computer.

### Running the Simulation
1. Open your terminal or command line.
2. Compile all the factory departments together:
   ```bash
   iverilog -o litecpu16_sim tb_litecpu16.v cpu_top.v pc.v control.v regfile.v alu.v sign_ext.v branch_unit.v instr_mem.v dmem.v
   ```
3. Turn on the power simulator!
   ```bash
   vvp litecpu16_sim
   ```

You will see output showing you exactly how the CPU read its instructions, did the math, and spat out the correct answer! 

---
*Happy tinkering, and welcome to the world of Computer Architecture!* 🏗️💻