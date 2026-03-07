module testbench;

    reg clk = 0;
    top uut(clk);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, testbench);

        #100;

        $display("x1 = %d", uut.RF.regs[1]);
        $display("x2 = %d", uut.RF.regs[2]);
        $display("x3 = %d", uut.RF.regs[3]);
        $display("mem[3] = %d", uut.DM.memory[3]);
        $display("x4 = %d", uut.RF.regs[4]);
        if (uut.RF.regs[4] == uut.RF.regs[3])
            $display("BEQ condition TRUE (x4 == x3)");
        else
            $display("BEQ condition FALSE (x4 != x3)");

        $finish;
    end

endmodule