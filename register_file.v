module register_file (
    input clk,
    input rst,
    input RegWrite,
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd_addr,
    input [31:0] write_data,
    output [31:0] rs1_data,
    output [31:0] rs2_data
);

    reg [31:0] registers[0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    assign rs1_data = (rs1_addr != 5'b00000) ? registers[rs1_addr] : 32'b0;
    assign rs2_data = (rs2_addr != 5'b00000) ? registers[rs2_addr] : 32'b0;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (RegWrite && (rd_addr != 5'b00000)) begin
            registers[rd_addr] <= write_data;
        end
    end

endmodule
