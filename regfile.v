module regfile(input clk,
               input we,
               input [3:0] rs1, rs2, rd,
               input [15:0] wd,
               output [15:0] rd1, rd2, rd_val);

    reg [15:0] regs [0:15];

    assign rd1 = regs[rs1];
    assign rd2 = regs[rs2];
    assign rd_val = regs[rd];

    integer i;
    initial begin
      for(i=0;i<16;i=i+1)
        regs[i]=0;
    end

    always @(posedge clk)
        if (we && rd != 0) regs[rd] <= wd;
endmodule