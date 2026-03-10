module testbench;

    reg clk = 0;
    top uut(clk);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, testbench);

        #100;

        $display("--- Execution Results ---");
        $display("R1 = %d", uut.RF.regs[1]);
        $display("R2 = %d", uut.RF.regs[2]);
        $display("R3 = %d", uut.RF.regs[3]);
        $display("R4 = %d", uut.RF.regs[4]);
        $display("R5 = %d", uut.RF.regs[5]);
        $display("R6 = %d", uut.RF.regs[6]);
        $display("-------------------------");

        $finish;
    end

endmodule