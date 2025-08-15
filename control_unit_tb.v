module control_unit_tb;

    reg [6:0] opcode_tb;
    reg [2:0] funct3_tb;
    reg [6:0] funct7_tb;
    wire RegWrite_tb;
    wire MemtoReg_tb;
    wire MemRead_tb;
    wire MemWrite_tb;
    wire [3:0] ALUOp_tb;
    wire ALUSrc_tb;
    wire Branch_tb;

    control_unit uut (
        .opcode(opcode_tb),
        .funct3(funct3_tb),
        .funct7(funct7_tb),
        .RegWrite(RegWrite_tb),
        .MemtoReg(MemtoReg_tb),
        .MemRead(MemRead_tb),
        .MemWrite(MemWrite_tb),
        .ALUOp(ALUOp_tb),
        .ALUSrc(ALUSrc_tb),
        .Branch(Branch_tb)
    );

    initial begin
        $display("Tempo\tOpcode\tFunct3\tFunct7\tRegWrite\tMemtoReg\tMemRead\tMemWrite\tALUOp\tALUSrc\tBranch");
        $monitor("%0d\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b",
                 $time, opcode_tb, funct3_tb, funct7_tb, RegWrite_tb, MemtoReg_tb, MemRead_tb, MemWrite_tb, ALUOp_tb, ALUSrc_tb, Branch_tb);

        opcode_tb = 7'b0110011;
        funct3_tb = 3'b000;
        funct7_tb = 7'b0100000;
        #10;

        opcode_tb = 7'b0110011;
        funct3_tb = 3'b110;
        funct7_tb = 7'b0000000;
        #10;

        opcode_tb = 7'b0110011;
        funct3_tb = 3'b101;
        funct7_tb = 7'b0000000;
        #10;

        opcode_tb = 7'b0000011;
        funct3_tb = 3'b001;
        funct7_tb = 7'b0000000;
        #10;

        opcode_tb = 7'b0010011;
        funct3_tb = 3'b111;
        funct7_tb = 7'b0000000;
        #10;

        opcode_tb = 7'b0100011;
        funct3_tb = 3'b001;
        funct7_tb = 7'b0000000;
        #10;

        opcode_tb = 7'b1100011;
        funct3_tb = 3'b000;
        funct7_tb = 7'b0000000;
        #10;

        $finish;
    end

endmodule
