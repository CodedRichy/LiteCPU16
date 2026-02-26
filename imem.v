module imem(input [15:0] addr, output [15:0] instr);

    reg [15:0] memory [0:15];

    initial begin
        memory[0] = 16'h1121;   // addi x1, x0, 1
        memory[1] = 16'h1222;   // addi x2, x0, 2
        memory[2] = 16'h2312;   // add x3, x1, x2
        memory[3] = 16'h3400;   // sw x3, 0(x0)
        memory[4] = 16'h4500;   // lw x4, 0(x0)
        memory[5] = 16'h5600;   // beq x4, x3
        memory[6] = 16'h0000;   // nop
    end

    assign instr = memory[addr];
endmodule