// imem.v
`timescale 1ns/1ps

module imem (
    input  wire [15:0] addr,
    output wire [15:0] instr
);

    reg [15:0] memory [0:255]; // 256 words = 512 bytes instruction memory

    // Initialize with test program
    initial begin
        // R-Type logic: Opcode(3)|Rs(3)|Rt(3)|Rd(3)|Ignored(4)
        // I-Type logic: Opcode(3)|Rs(3)|Rt(3)|Imm(7)

        // Addr 0: LW R1, R0, 0    => Op(010)|Rs(000)|Rt(001)|Imm(0000000) => 010_000_001_0000000 = 16'b0100_0000_1000_0000 = 16'h4080
        // Addr 1: LW R2, R0, 1    => Op(010)|Rs(000)|Rt(010)|Imm(0000001) => 010_000_010_0000001 = 16'b0100_0001_0000_0001 = 16'h4101
        // Addr 2: ADD R3, R1, R2  => Op(001)|Rs(001)|Rt(010)|Rd(011)|0000 => 001_001_010_011_0000 = 16'b0010_0101_0011_0000 = 16'h2530
        // Addr 3: SW R3, R0, 2    => Op(011)|Rs(000)|Rt(011)|Imm(0000010) => 011_000_011_0000010 = 16'b0110_0001_1000_0010 = 16'h6182
        // Addr 4: BEQ R0, R0, 2   => Op(100)|Rs(000)|Rt(000)|Imm(0000010) => 100_000_000_0000010 = 16'b1000_0000_0000_0010 = 16'h8002
        // Addr 5: NOP             => Op(000)............................. => 16'h0000
        // Addr 6: NOP             => Op(000)............................. => 16'h0000
        // Addr 7: LW R4, R0, 2    => (Branch Target) Loads saved result back to R4
        //         Op(010)|Rs(000)|Rt(100)|Imm(0000010) => 010_000_100_0000010 = 16'b0100_0010_0000_0010 = 16'h4202

        memory[0] = 16'h4080; // LW R1, 0(R0)
        memory[1] = 16'h4101; // LW R2, 1(R0)
        memory[2] = 16'h2530; // ADD R3, R1, R2
        memory[3] = 16'h6182; // SW R3, 2(R0)
        memory[4] = 16'h8002; // BEQ R0, R0, 2 -> jumps to PC 4 + 1 + 2 = PC 7
        memory[5] = 16'h0000; // NOP (skipped)
        memory[6] = 16'h0000; // NOP (skipped)
        memory[7] = 16'h4202; // LW R4, 2(R0) -> R4 should get R1+R2
    end

    assign instr = memory[addr[7:0]];

endmodule
