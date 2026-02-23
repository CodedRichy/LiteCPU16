// dmem.v
`timescale 1ns/1ps

module dmem (
    input  wire        clk,
    input  wire [15:0] addr,  // The memory address to read/write
    input  wire [15:0] wdata, // The data to write
    input  wire        we,    // Write Enable (1 to save wdata)
    output wire [15:0] rdata  // The data being read out
);

    // 256 words of memory
    reg [15:0] memory [0:255]; 

    // Initialize with some constants for testing
    initial begin
        memory[0] = 16'h0005; // Decimal 5
        memory[1] = 16'h000A; // Decimal 10
        memory[2] = 16'h0000; // Result placeholder
    end

    // Asynchronous read: Always outputs the data at the requested address immediately
    assign rdata = memory[addr[7:0]];

    // Synchronous write: Only saves data exactly when the clock ticks
    always @(posedge clk) begin
        if (we) begin
            memory[addr[7:0]] <= wdata;
        end
    end

endmodule
