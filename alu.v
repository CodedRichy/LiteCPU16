// alu.v
`timescale 1ns/1ps

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
    assign zero = (in1 == in2); // Zero flag
endmodule
