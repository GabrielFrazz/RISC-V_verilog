module alu (
    input [31:0] src1,
    input [31:0] src2,
    input [3:0] alu_op,
    output reg [31:0] alu_result,
    output zero
);

    always @(*) begin
        if (alu_op == 4'b0000) begin
            alu_result = src1 + src2;
        end else if (alu_op == 4'b0001) begin
            alu_result = src1 - src2;
        end else if (alu_op == 4'b0010) begin
            alu_result = src1 & src2;
        end else if (alu_op == 4'b0011) begin
            alu_result = src1 | src2;
        end else if (alu_op == 4'b0110) begin
            alu_result = src1 >>> src2[4:0];
        end else if (alu_op == 4'b1010) begin
            alu_result = src1 & src2;
        end else begin
            alu_result = 32'b0;
        end
    end

    assign zero = (alu_result == 32'b0);

endmodule
