module pc(input clk, input [15:0] next_pc, output reg [15:0] pc);
    initial pc = 0;
    always @(posedge clk)
        pc <= next_pc;
endmodule