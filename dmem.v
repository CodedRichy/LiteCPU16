// dmem.v
`timescale 1ns/1ps

module dmem (
    input  wire        clk,
    input  wire [15:0] addr,
    input  wire [15:0] wdata,
    input  wire        we,
    output wire [15:0] rdata
);

    reg [15:0] memory [0:255]; // 256 words

    // Initialize with some constants
    initial begin
        memory[0] = 16'h0005; // 5
        memory[1] = 16'h000A; // 10
        memory[2] = 16'h0000; // Result placeholder
    end

    // Asynchronous read
    assign rdata = memory[addr[7:0]];

    // Synchronous write
    always @(posedge clk) begin
        if (we) begin
            memory[addr[7:0]] <= wdata;
        end
    end

endmodule
