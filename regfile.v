// regfile.v
`timescale 1ns/1ps

module regfile (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        we,
    input  wire [2:0]  raddr1,
    input  wire [2:0]  raddr2,
    input  wire [2:0]  waddr,
    input  wire [15:0] wdata,
    output wire [15:0] rdata1,
    output wire [15:0] rdata2
);

    // Internal storage: 8 registers, each 16-bits wide
    reg [15:0] regs [0:7];
    integer i;

    // Asynchronous read flow. R0 is physically hardwired to 0. 
    // This removes the need for hardware clear logic on R0.
    assign rdata1 = (raddr1 == 3'd0) ? 16'd0 : regs[raddr1];
    assign rdata2 = (raddr2 == 3'd0) ? 16'd0 : regs[raddr2];

    // Synchronous write flow on positive clock edge.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers sequentially to 0
            for (i = 0; i < 8; i = i + 1) begin
                regs[i] <= 16'd0;
            end
        end else if (we && waddr != 3'd0) begin
            // Write data if enabled. Prevent writing to R0.
            regs[waddr] <= wdata;
        end
    end
endmodule
