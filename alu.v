// alu.v
`timescale 1ns/1ps

module alu (
    input  wire [15:0] in1,    // First operand (usually from Register 1)
    input  wire [15:0] in2,    // Second operand (Register 2 or Immediate)
    input  wire        is_add, // 1 for Add operations, 0 for Subtract (used in BEQ)
    output wire [15:0] out,    // Math result
    output wire        zero    // 1 if in1 and in2 are completely equal 
);
    // Continuous math calculations
    wire [15:0] result_sub = in1 - in2;
    wire [15:0] result_add = in1 + in2;

    // Output routing based on the operation requested
    assign out  = is_add ? result_add : result_sub;
    
    // Zero flag used heavily by BEQ to determine equality
    assign zero = (in1 == in2); 
endmodule
