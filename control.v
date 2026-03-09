module control(input [3:0] opcode,
               output reg regwrite, memwrite,
               output reg alusrc, memtoreg,
               output reg branch,
               output reg [2:0] aluop);

    always @(*) begin
        regwrite = 0;
        memwrite = 0;
        alusrc   = 0;
        memtoreg = 0;
        branch   = 0;
        aluop    = 0;
        case(opcode)
            4'h1: begin // add
                regwrite=1; alusrc=0; memtoreg=0; memwrite=0; branch=0; aluop=3'b000;
            end
            4'h2: begin // addi
                regwrite=1; alusrc=1; memtoreg=0; memwrite=0; branch=0; aluop=3'b000;
            end
            4'h3: begin // sub
                regwrite=1; alusrc=0; memtoreg=0; memwrite=0; branch=0; aluop=3'b001;
            end
            4'h4: begin // and
                regwrite=1; alusrc=0; memtoreg=0; memwrite=0; branch=0; aluop=3'b010;
            end
            4'h5: begin // or
                regwrite=1; alusrc=0; memtoreg=0; memwrite=0; branch=0; aluop=3'b011;
            end
            default: begin // nop
                regwrite = 0;
                memwrite = 0;
                alusrc   = 0;
                memtoreg = 0;
                branch   = 0;
                aluop    = 0;
            end
        endcase
    end
endmodule