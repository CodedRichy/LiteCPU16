module imem(input [15:0] addr, output [15:0] instr);

    reg [15:0] memory [0:15];

    initial begin
        memory[0] = 16'h2105;   // addi r1, r0, 5  (r1 = 5)
        memory[1] = 16'h2203;   // addi r2, r0, 3  (r2 = 3)
        memory[2] = 16'h1312;   // add r3, r1, r2  (r3 = 8)
        memory[3] = 16'h3432;   // sub r4, r3, r2  (r4 = 5)
        memory[4] = 16'h4531;   // and r5, r3, r1  (r5 = 8 & 5 = 1000 & 0101 = 0)
        memory[5] = 16'h5654;   // or r6, r5, r4   (r6 = 0 | 5 = 5)
        memory[6] = 16'h0000;   // nop
    end

    assign instr = memory[addr];
endmodule