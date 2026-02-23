// branch_unit.v
`timescale 1ns/1ps

module branch_unit (
    input  wire [15:0] pc,
    input  wire [15:0] imm_ext,
    input  wire        branch,
    input  wire        zero,
    output wire [15:0] next_pc
);

    wire [15:0] pc_plus_1 = pc + 16'd1;
    wire [15:0] branch_target = pc_plus_1 + imm_ext;
    
    wire do_branch = branch & zero;
    
    assign next_pc = do_branch ? branch_target : pc_plus_1;

endmodule
