// control.v
`timescale 1ns/1ps

module control (
    input  wire [2:0] opcode,
    output reg        reg_write,  // 1 to write output to the register file
    output reg        alu_src,    // 0 uses register 2 value, 1 uses immediate value
    output reg        mem_write,  // 1 to allow writing to memory
    output reg        mem_to_reg, // 0 saves ALU result, 1 saves Memory result to register
    output reg        branch,     // 1 indicates this is a branch instruction
    output reg        reg_dst     // 0 destination is Rt register, 1 destination is Rd register
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
            3'b000: begin 
                // NOP (No Operation). All flags stay 0.
            end
            3'b001: begin 
                // ADD (R-Type). Saves ALU math result into Rd register.
                reg_write = 1'b1;
                reg_dst   = 1'b1;
            end
            3'b010: begin 
                // LW (Load Word). Reads Memory and saves into Rt register.
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                reg_dst    = 1'b0;
            end
            3'b011: begin 
                // SW (Store Word). Writes Rt register value into Memory.
                mem_write = 1'b1;
                alu_src   = 1'b1;
            end
            3'b100: begin 
                // BEQ (Branch on Equal). Triggers branch if ALU calculates zero difference.
                branch  = 1'b1;
            end
            default: begin
                // Invalid ops default to NOP safety
            end
        endcase
    end
endmodule
