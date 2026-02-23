// barecore.v
`timescale 1ns/1ps

module barecore (
    input wire clk,
    input wire rst_n,

    // Instruction Memory Interface (Harvard)
    output wire [15:0] imem_addr,
    input  wire [15:0] imem_rdata,

    // Data Memory Interface (Harvard)
    output wire [15:0] dmem_addr,
    output wire [15:0] dmem_wdata,
    output wire        dmem_we,
    input  wire [15:0] dmem_rdata
);

    // --- PC and Instruction Fetch ---
    reg [15:0] pc;
    wire [15:0] next_pc;
    wire [15:0] pc_plus_1 = pc + 16'd1;

    assign imem_addr = pc;

    // --- Instruction Decoding ---
    wire [15:0] instr = imem_rdata;
    wire [2:0]  opcode = instr[15:13];
    wire [2:0]  rs = instr[12:10];
    wire [2:0]  rt = instr[9:7];
    wire [2:0]  rd = instr[6:4];
    wire [6:0]  imm_raw = instr[6:0];
    
    // Sign extend immediate
    wire [15:0] imm_ext = {{9{imm_raw[6]}}, imm_raw};

    // --- Control Unit ---
    wire reg_write;
    wire alu_src;
    wire mem_write;
    wire mem_to_reg;
    wire branch;
    wire reg_dst; // 1 for Rd (R-type), 0 for Rt (I-type LW)

    control cu (
        .opcode     (opcode),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .reg_dst    (reg_dst)
    );

    // --- Register File ---
    wire [15:0] rdata1;
    wire [15:0] rdata2;
    wire [2:0]  write_reg = reg_dst ? rd : rt;
    wire [15:0] write_data;

    regfile rf (
        .clk        (clk),
        .rst_n      (rst_n),
        .we         (reg_write),
        .raddr1     (rs),
        .raddr2     (rt),
        .waddr      (write_reg),
        .wdata      (write_data),
        .rdata1     (rdata1),
        .rdata2     (rdata2)
    );

    // --- ALU ---
    wire [15:0] alu_in2 = alu_src ? imm_ext : rdata2;
    wire [15:0] alu_result;
    wire        zero;

    alu core_alu (
        .in1    (rdata1),
        .in2    (alu_in2),
        .is_add (opcode != 3'b100), // BEQ uses subtraction for comparison
        .out    (alu_result),
        .zero   (zero)
    );

    // --- Data Memory Interface ---
    assign dmem_addr  = alu_result;
    assign dmem_wdata = rdata2;
    assign dmem_we    = mem_write;

    // --- Writeback ---
    assign write_data = mem_to_reg ? dmem_rdata : alu_result;

    // --- Branch Resolution ---
    wire [15:0] branch_target = pc_plus_1 + imm_ext;
    wire do_branch = branch & zero;
    assign next_pc = do_branch ? branch_target : pc_plus_1;

    // --- PC Update ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 16'd0;
        end else begin
            pc <= next_pc;
        end
    end

endmodule

// --- Control Unit Module ---
module control (
    input  wire [2:0] opcode,
    output reg        reg_write,
    output reg        alu_src,    // 0: rdata2, 1: imm
    output reg        mem_write,
    output reg        mem_to_reg, // 0: alu_res, 1: dmem_rdata
    output reg        branch,
    output reg        reg_dst     // 0: Rt, 1: Rd
);

    always @(*) begin
        // Default to safe values (NOP)
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        reg_dst    = 1'b0;

        case(opcode)
            3'b000: begin // NOP
            end
            3'b001: begin // ADD
                reg_write = 1'b1;
                reg_dst   = 1'b1; // Write to Rd
                // alu_src = 0 (rdata2)
                // mem_to_reg = 0 (alu_result)
            end
            3'b010: begin // LW
                reg_write  = 1'b1;
                alu_src    = 1'b1; // Imm
                mem_to_reg = 1'b1; // From Mem
                reg_dst    = 1'b0; // Write to Rt
            end
            3'b011: begin // SW
                mem_write = 1'b1;
                alu_src   = 1'b1; // Imm
            end
            3'b100: begin // BEQ
                branch  = 1'b1;
                // alu_src = 0 (rdata2 for comparison)
            end
            default: begin
                // Invalid opcodes map cleanly to NOP hardware-wise via defaults
            end
        endcase
    end
endmodule

// --- Register File Module ---
module regfile (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        we,
    input  wire [2:0]  raddr1,
    input  wire [2:0]  raddr2,
    input  wire [2:0]  waddr,
    input  wire [15:0] wdata,
    output wire [15:0] rdata1,
    output wire [15:0] rdata2
);

    reg [15:0] regs [0:7];
    integer i;

    // Async read. R0 is hardwired to 0.
    assign rdata1 = (raddr1 == 3'd0) ? 16'd0 : regs[raddr1];
    assign rdata2 = (raddr2 == 3'd0) ? 16'd0 : regs[raddr2];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 8; i = i + 1) begin
                regs[i] <= 16'd0;
            end
        end else if (we && waddr != 3'd0) begin
            regs[waddr] <= wdata;
        end
    end
endmodule

// --- ALU Module ---
module alu (
    input  wire [15:0] in1,
    input  wire [15:0] in2,
    input  wire        is_add, // 1 for ADD/LW/SW, 0 for BEQ (sub)
    output wire [15:0] out,
    output wire        zero
);
    wire [15:0] result_sub = in1 - in2;
    wire [15:0] result_add = in1 + in2;

    assign out  = is_add ? result_add : result_sub;
    assign zero = (in1 == in2); // Zero flag driven by pure equality check
endmodule
