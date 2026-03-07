module alu(input [15:0] a, b,
           input [2:0] op,
           output reg [15:0] result,
           output zero);

    always @(*) begin
        case(op)
            3'b000: result = a + b;
            3'b001: result = a - b;
            default: result = 0;
        endcase
    end

    assign zero = (result == 0);
endmodule