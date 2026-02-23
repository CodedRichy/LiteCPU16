// control.v
`timescale 1ns/1ps

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
            end
            default: begin
            end
        endcase
    end
endmodule
