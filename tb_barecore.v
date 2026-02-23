// tb_barecore.v
`timescale 1ns/1ps

module tb_barecore;

    reg clk;
    reg rst_n;

    // CPU interfaces
    wire [15:0] imem_addr;
    wire [15:0] imem_rdata;

    wire [15:0] dmem_addr;
    wire [15:0] dmem_wdata;
    wire        dmem_we;
    wire [15:0] dmem_rdata;

    // Instantiate CPU
    barecore cpu_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),
        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_we    (dmem_we),
        .dmem_rdata (dmem_rdata)
    );

    // Instantiate IMEM
    imem imem_inst (
        .addr  (imem_addr),
        .instr (imem_rdata)
    );

    // Instantiate DMEM
    dmem dmem_inst (
        .clk   (clk),
        .addr  (dmem_addr),
        .wdata (dmem_wdata),
        .we    (dmem_we),
        .rdata (dmem_rdata)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Test sequence
    initial begin
        $dumpfile("barecore.vcd");
        $dumpvars(0, tb_barecore);

        // Reset system
        rst_n = 0;
        #15;
        rst_n = 1;

        // Run for enough cycles to hit the branch and fetch R4
        #100;

        // Display results
        $display("--------------------------------");
        $display("Test Execution Complete.");
        $display("Inputs: DMEM[0] = %0d, DMEM[1] = %0d", dmem_inst.memory[0], dmem_inst.memory[1]);
        $display("Output: DMEM[2] = %0d (Expected 15)", dmem_inst.memory[2]);
        $display("R1 = %0d", cpu_inst.rf.regs[1]);
        $display("R2 = %0d", cpu_inst.rf.regs[2]);
        $display("R3 = %0d", cpu_inst.rf.regs[3]);
        $display("R4 = %0d (Expected 15 from branch target loading)", cpu_inst.rf.regs[4]);
        
        if (dmem_inst.memory[2] == 15 && cpu_inst.rf.regs[4] == 15) begin
            $display("STATUS: PASS");
        end else begin
            $display("STATUS: FAIL");
        end
        $display("--------------------------------");
        
        $finish;
    end

endmodule
