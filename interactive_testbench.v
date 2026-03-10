module interactive_testbench;

    // CPU component signals
    reg clk = 0;
    wire [15:0] pc, instr, rd1, rd2, alu_out, mem_out, next_pc;
    wire [3:0] opcode, rd, rs1, rs2;

    // Registers to hold user input
    integer choice;
    integer status;
    integer rd_idx, rs1_idx, rs2_idx, imm_val;
    reg [15:0] manual_instr;
    reg use_manual_instr = 0;

    // Instantiate original TOP module components manually for interactivity
    // (Note: We use the same signals but bypass imem when manually injecting)
    assign instr = use_manual_instr ? manual_instr : 16'h0000;
    
    assign opcode = instr[15:12];
    assign rd     = instr[11:8];
    assign rs1    = instr[7:4];
    assign rs2    = instr[3:0];

    wire regwrite, memwrite, alusrc, memtoreg, branch;
    wire [2:0] aluop;
    wire zero;
    wire [15:0] rd_val;

    // Connect CPU components
    regfile RF(clk, regwrite, rs1, rs2, rd, memtoreg ? mem_out : alu_out, rd1, rd2, rd_val);
    alu ALU(rd1, alusrc ? {12'b0, rs2} : rd2, aluop, alu_out, zero);
    control CU(opcode, regwrite, memwrite, alusrc, memtoreg, branch, aluop);
    dmem DM(clk, memwrite, alu_out, rd_val, mem_out); // Explicitly connect memory here for simulation display

    // Clock generator
    always #5 clk = ~clk;

    // Standard I/O handles for Icarus
    integer STDIN = 32'h8000_0000;
    integer STDOUT = 32'h8000_0001;

    initial begin
        $display("===============================================");
        $display("   VERILOG INTERACTIVE CPU SIMULATION          ");
        $display("===============================================");
        
        forever begin
            // Display Register and Memory State
            $display("\n================ [ CPU STATE ] ================");
            $display("Registers:");
            $display("R0 : %d | R1 : %d | R2 : %d | R3 : %d", RF.regs[0], RF.regs[1], RF.regs[2], RF.regs[3]);
            $display("R4 : %d | R5 : %d | R6 : %d | R7 : %d", RF.regs[4], RF.regs[5], RF.regs[6], RF.regs[7]);
            $display("R8 : %d | R9 : %d | R10: %d | R11: %d", RF.regs[8], RF.regs[9], RF.regs[10], RF.regs[11]);
            $display("R12: %d | R13: %d | R14: %d | R15: %d", RF.regs[12], RF.regs[13], RF.regs[14], RF.regs[15]);
            $display("\nData Memory:");
            $display("[0]: %d | [1]: %d | [2]: %d | [3]: %d", DM.memory[0], DM.memory[1], DM.memory[2], DM.memory[3]);
            $display("[4]: %d | [5]: %d | [6]: %d | [7]: %d", DM.memory[4], DM.memory[5], DM.memory[6], DM.memory[7]);
            $display("[8]: %d | [9]: %d | [10]:%d | [11]:%d", DM.memory[8], DM.memory[9], DM.memory[10], DM.memory[11]);
            $display("[12]:%d | [13]:%d | [14]:%d | [15]:%d", DM.memory[12], DM.memory[13], DM.memory[14], DM.memory[15]);
            $display("===============================================");
            
            $display("\nSelect Instruction:");
            $display("1. ADD  (rd = rs1 + rs2)");
            $display("2. ADDI (rd = rs1 + imm)");
            $display("3. SUB  (rd = rs1 - rs2)");
            $display("4. AND  (rd = rs1 & rs2)");
            $display("5. OR   (rd = rs1 | rs2)");
            $display("6. LW   (rd = mem[rs1+imm])");
            $display("7. SW   (mem[rs1+imm] = rd)");
            $display("8. EXIT");
            $write("Choice: ");
            $fflush(STDOUT);
            
            status=$fscanf(STDIN, "%d", choice);
            $display(""); 

            if (choice == 8) begin
                $display("Exiting simulation...");
                $finish;
            end

            if (choice < 1 || choice > 7) begin
                $display("Invalid choice. Try again.");
            end else begin
                if (choice == 6 || choice == 7) begin
                    $write("Enter Destination Register (rd) [0-15]: ");
                end else begin
                    $write("Enter Destination/Source Register (rd) [0-15]: ");
                end
                $fflush(STDOUT);
                status=$fscanf(STDIN, "%d", rd_idx);
                $display("");

                $write("Enter Source Register 1 (Base Address Register) [0-15]: ");
                $fflush(STDOUT);
                status=$fscanf(STDIN, "%d", rs1_idx);
                $display("");

                if (choice == 2 || choice == 6 || choice == 7) begin
                    $write("Enter Immediate/Offset [0-15]: ");
                    $fflush(STDOUT);
                    status=$fscanf(STDIN, "%d", imm_val);
                    $display("");
                    manual_instr = {choice[3:0], rd_idx[3:0], rs1_idx[3:0], imm_val[3:0]};
                end else begin
                    $write("Enter Source Register 2 (rs2) [0-15]: ");
                    $fflush(STDOUT);
                    status=$fscanf(STDIN, "%d", rs2_idx);
                    $display("");
                    manual_instr = {choice[3:0], rd_idx[3:0], rs1_idx[3:0], rs2_idx[3:0]};
                end

                // Execute the instruction
                use_manual_instr = 1;
                #1; // Allow combinational logic to settle
                clk = 1; #5; // Trigger positive edge
                clk = 0; #5; // Reset clock
                use_manual_instr = 0;
                
                $display(">> Action: Executed Instruction.");
                #10; 
            end
        end
    end

endmodule
