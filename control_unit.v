module control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg RegWrite,
    output reg MemtoReg,
    output reg MemRead,
    output reg MemWrite,
    output reg [3:0] ALUOp,
    output reg ALUSrc,
    output reg Branch
);

    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE_LOAD = 7'b0000011;
    localparam I_TYPE_ALU = 7'b0010011;
    localparam S_TYPE = 7'b0100011;
    localparam B_TYPE = 7'b1100011;

    always @(*) begin
        RegWrite = 1'b0;
        MemtoReg = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ALUOp = 4'b0000;
        ALUSrc = 1'b0;
        Branch = 1'b0;

        case (opcode)
            R_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
                case ({funct7, funct3})
                    10'b0000000_000: ALUOp = 4'b0000;
                    10'b0100000_000: ALUOp = 4'b0001;
                    10'b0000000_110: ALUOp = 4'b0011;
                    10'b0000000_111: ALUOp = 4'b0010;
                    10'b0000000_101: ALUOp = 4'b0110;
                    default: ALUOp = 4'b0000;
                endcase
            end

            I_TYPE_LOAD: begin
                RegWrite = 1'b1;
                MemtoReg = 1'b1;
                MemRead = 1'b1;
                ALUSrc = 1'b1;
                ALUOp = 4'b0000;
            end

            I_TYPE_ALU: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                case (funct3)
                    3'b111: ALUOp = 4'b1010;
                    3'b000: ALUOp = 4'b0000;
                    default: begin end
                endcase
            end

            S_TYPE: begin
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUOp = 4'b0000;
            end

            B_TYPE: begin
                Branch = 1'b1;
                ALUSrc = 1'b0;
                ALUOp = 4'b0001;
            end

            default: begin
            end
        endcase
    end

endmodule
