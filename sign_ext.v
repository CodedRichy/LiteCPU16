// sign_ext.v
`timescale 1ns/1ps

module sign_ext (
    input  wire [6:0]  in,  // 7-bit immediate value from Instruction Memory
    output wire [15:0] out  // Expanded 16-bit value
);

    // Sign extend the 7-bit immediate to 16 bits.
    // It takes the Most Significant Bit (in[6]) and copies it 9 times
    // across the top bits to accurately preserve negative values. 
    assign out = {{9{in[6]}}, in};

endmodule
