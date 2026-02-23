// instr_mem.v
`timescale 1ns/1ps

module instr_mem (
    input  wire [15:0] addr,
    output wire [15:0] instr
);

    reg [15:0] memory [0:255];

    initial begin
        memory[0] = 16'h4080; // LW R1, 0(R0)
        memory[1] = 16'h4101; // LW R2, 1(R0)
        memory[2] = 16'h2530; // ADD R3, R1, R2
        memory[3] = 16'h6182; // SW R3, 2(R0)
        memory[4] = 16'h8002; // BEQ R0, R0, 2
        memory[5] = 16'h0000; // NOP
        memory[6] = 16'h0000; // NOP
        memory[7] = 16'h4202; // LW R4, 2(R0)
    end

    assign instr = memory[addr[7:0]];

endmodule
