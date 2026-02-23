// pc.v
`timescale 1ns/1ps

module pc (
    input  wire        clk,
    input  wire        rst_n,   // Active-low system reset
    input  wire [15:0] next_pc, // The calculated next address from datapath
    output reg  [15:0] pc_out   // The current address emitting to Instruction Memory
);

    // Evaluates strictly on the positive edge of the clock (Synchronous)
    // or when reset hits 0 (Asynchronous).
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 16'd0; // Reset jumping straight to code start
        end else begin
            pc_out <= next_pc; // Latch in the next sequence step
        end
    end

endmodule
