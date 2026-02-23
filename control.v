module control(input [3:0] opcode,
               output reg regwrite, memwrite,
               output reg alusrc, memtoreg,
               output reg branch,
               output reg [2:0] aluop);

    always @(*) begin
        case(opcode)
            4'h1: begin // addi
                regwrite=1; alusrc=1; memtoreg=0; memwrite=0; branch=0; aluop=0;
            end
            4'h2: begin // add
                regwrite=1; alusrc=0; memtoreg=0; memwrite=0; branch=0; aluop=0;
            end
            4'h3: begin // sw
                regwrite=0; alusrc=1; memwrite=1; branch=0; aluop=0;
            end
            4'h4: begin // lw
                regwrite=1; alusrc=1; memtoreg=1; memwrite=0; branch=0; aluop=0;
            end
            4'h5: begin // beq
                regwrite=0; branch=1; aluop=1;
            end
            default: begin // nop
                regwrite=0; memwrite=0; branch=0;
            end
        endcase
    end
endmodule