module top(input clk);

    wire [15:0] pc, instr, rd1, rd2, alu_out, mem_out, next_pc;
    wire [3:0] opcode = instr[15:12];
    wire [3:0] rd = instr[11:8];
    wire [3:0] rs1 = instr[7:4];
    wire [3:0] rs2 = instr[3:0];

    wire regwrite, memwrite, alusrc, memtoreg, branch;
    wire [2:0] aluop;
    wire zero;

    pc PC(clk, next_pc, pc);
    imem IM(pc, instr);
    regfile RF(clk, regwrite, rs1, rs2, rd, memtoreg ? mem_out : alu_out, rd1, rd2);
    alu ALU(rd1, alusrc ? {12'b0, rs2} : rd2, aluop, alu_out, zero);
    dmem DM(clk, memwrite, alu_out, rd2, mem_out);
    control CU(opcode, regwrite, memwrite, alusrc, memtoreg, branch, aluop);

    assign next_pc = branch && zero ? pc + 2 : pc + 1;

endmodule