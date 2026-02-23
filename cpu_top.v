// cpu_top.v
`timescale 1ns/1ps

module cpu_top (
    input wire clk,
    input wire rst_n, // Active-low reset

    // Instruction Memory Interface (Harvard Architecture)
    output wire [15:0] imem_addr,
    input  wire [15:0] imem_rdata,

    // Data Memory Interface (Harvard Architecture)
    output wire [15:0] dmem_addr,
    output wire [15:0] dmem_wdata,
    output wire        dmem_we, // Write Enable
    input  wire [15:0] dmem_rdata
);

    // Wires
    wire [15:0] pc_current;
    wire [15:0] next_pc;
    
    wire [2:0]  opcode;
    wire [2:0]  rs;
    wire [2:0]  rt;
    wire [2:0]  rd;
    wire [6:0]  imm_raw;
    wire [15:0] imm_ext;
    
    wire reg_write, alu_src, mem_write, mem_to_reg, branch, reg_dst;
    
    wire [15:0] rdata1, rdata2;
    wire [2:0]  write_reg;
    wire [15:0] write_data;
    
    wire [15:0] alu_in2, alu_result;
    wire zero;

    // --- Instruction Fetch ---
    assign imem_addr = pc_current;
    assign opcode   = imem_rdata[15:13];
    assign rs       = imem_rdata[12:10];
    assign rt       = imem_rdata[9:7];
    assign rd       = imem_rdata[6:4];
    assign imm_raw  = imem_rdata[6:0];

    // --- PC Module ---
    // Holds and updates the memory address of the current instruction
    pc pc_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .next_pc (next_pc),
        .pc_out  (pc_current)
    );

    // --- Control Unit ---
    // Translates the 3-bit opcode into control signals for the datapath
    control cu (
        .opcode     (opcode),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .reg_dst    (reg_dst)
    );

    // --- Sign Extension ---
    // Converts 7-bit immediate values into 16-bit values for math
    sign_ext se (
        .in  (imm_raw),
        .out (imm_ext)
    );

    // --- Register File ---
    // Fast internal memory (R0-R7). R0 is always 0.
    assign write_reg = reg_dst ? rd : rt;
    
    regfile rf (
        .clk    (clk),
        .rst_n  (rst_n),
        .we     (reg_write),
        .raddr1 (rs),
        .raddr2 (rt),
        .waddr  (write_reg),
        .wdata  (write_data),
        .rdata1 (rdata1),
        .rdata2 (rdata2)
    );

    // --- ALU ---
    // Performs addition for ADD/LW/SW. Performs subtraction for BEQ comparison.
    assign alu_in2 = alu_src ? imm_ext : rdata2;

    alu core_alu (
        .in1    (rdata1),
        .in2    (alu_in2),
        .is_add (opcode != 3'b100), // Opcode 100 is BEQ, which relies on subtraction
        .out    (alu_result),
        .zero   (zero)
    );

    // --- Branch Unit ---
    // Calculates where to jump if a BEQ condition is met.
    branch_unit branch_calc (
        .pc      (pc_current),
        .imm_ext (imm_ext),
        .branch  (branch),
        .zero    (zero),
        .next_pc (next_pc)
    );

    // --- Data Memory Interface ---
    // Connect to external Data RAM.
    assign dmem_addr  = alu_result;
    assign dmem_wdata = rdata2;
    assign dmem_we    = mem_write;

    // --- Writeback ---
    // Decide what gets saved back to the Register File (Memory Data vs ALU Math Data).
    assign write_data = mem_to_reg ? dmem_rdata : alu_result;

endmodule
