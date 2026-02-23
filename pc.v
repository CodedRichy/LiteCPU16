// pc.v
`timescale 1ns/1ps

module pc (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] next_pc,
    output reg  [15:0] pc_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 16'd0;
        end else begin
            pc_out <= next_pc;
        end
    end

endmodule
