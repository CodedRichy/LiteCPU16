module dmem(input clk,
            input we,
            input [15:0] addr,
            input [15:0] wd,
            output [15:0] rd);

    reg [15:0] memory [0:15];

    assign rd = memory[addr[3:0]];

        integer i;

        initial begin
        for (i = 0; i < 16; i = i + 1)
                memory[i] = 0;
        end
    always @(posedge clk)
        if (we) memory[addr[3:0]] <= wd;
endmodule