// instr_mem.v
`timescale 1ns/1ps

module instr_mem (
    input  wire [15:0] addr,  // Memory address requested by the PC
    output wire [15:0] instr  // The 16-bit instruction at that address
);

    // 256 words of memory to hold the program
    reg [15:0] memory [0:255];

    // This block runs once at startup to load the test program into memory
    initial begin
        memory[0] = 16'h4080; // LW R1, 0(R0)
        memory[1] = 16'h4101; // LW R2, 1(R0)
        memory[2] = 16'h2530; // ADD R3, R1, R2
        memory[3] = 16'h6182; // SW R3, 2(R0)
        memory[4] = 16'h8002; // BEQ R0, R0, 2
        memory[5] = 16'h0000; // NOP (Skipped by branching over it)
        memory[6] = 16'h0000; // NOP
        memory[7] = 16'h4202; // LW R4, 2(R0)
    end

    // Asynchronously output the requested instruction
    assign instr = memory[addr[7:0]];

endmodule
