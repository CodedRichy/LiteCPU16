// branch_unit.v
`timescale 1ns/1ps

module branch_unit (
    input  wire [15:0] pc,      // Current Program Counter
    input  wire [15:0] imm_ext, // Sign-extended immediate value
    input  wire        branch,  // True if the current instruction is BEQ
    input  wire        zero,    // True if registers compared in ALU were equal
    output wire [15:0] next_pc  // The memory address for the next instruction
);

    // The default path: Just go to the next chronological instruction
    wire [15:0] pc_plus_1 = pc + 16'd1;
    
    // The jump path: If branching, skip forward/backward by the immediate offset
    wire [15:0] branch_target = pc_plus_1 + imm_ext;
    
    // We only branch if it is a branch instruction AND the condition was met
    wire do_branch = branch & zero;
    
    // Route the final calculation back to the PC module
    assign next_pc = do_branch ? branch_target : pc_plus_1;

endmodule
