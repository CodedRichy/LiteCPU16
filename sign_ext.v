// sign_ext.v
`timescale 1ns/1ps

module sign_ext (
    input  wire [6:0]  in,
    output wire [15:0] out
);

    // Sign extend 7-bit immediate to 16 bits
    assign out = {{9{in[6]}}, in};

endmodule
