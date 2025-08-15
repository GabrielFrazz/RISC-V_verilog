module alu_tb;

    reg [31:0] src1_tb;
    reg [31:0] src2_tb;
    reg [3:0] alu_op_tb;
    wire [31:0] alu_result_tb;
    wire zero_tb;

    alu uut (
        .src1(src1_tb),
        .src2(src2_tb),
        .alu_op(alu_op_tb),
        .alu_result(alu_result_tb),
        .zero(zero_tb)
    );

    initial begin
        src1_tb = 32'd10;
        src2_tb = 32'd5;
        alu_op_tb = 4'b0001;
        #10;
        $display("SUB: %d - %d = %d, Zero = %b", src1_tb, src2_tb, alu_result_tb, zero_tb);
        
        src1_tb = 32'd10;
        src2_tb = 32'd5;
        alu_op_tb = 4'b0011;
        #10;
        $display("OR: %d | %d = %d, Zero = %b", src1_tb, src2_tb, alu_result_tb, zero_tb);

        src1_tb = 32'd5;
        src2_tb = 32'd15;
        alu_op_tb = 4'b1010;
        #10;
        $display("ANDI: %d & %d = %d, Zero = %b", src1_tb, src2_tb, alu_result_tb, zero_tb);

        src1_tb = 32'd15;
        src2_tb = 32'd1;
        alu_op_tb = 4'b0110;
        #10;
        $display("SRL: %d >>> %d = %d, Zero = %b", src1_tb, src2_tb, alu_result_tb, zero_tb);

        $finish;
    end

endmodule
