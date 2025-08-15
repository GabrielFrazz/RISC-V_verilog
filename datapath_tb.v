module datapath_tb;

    reg clk_tb;
    reg rst_tb;
    reg [31:0] instruction_tb;
    reg [31:0] read_data_mem_tb;

    wire [31:0] pc_out_tb;
    wire [31:0] alu_result_out_tb;
    wire [31:0] write_data_mem_tb;
    wire [4:0] rs2_addr_out_tb;
    wire MemRead_out_tb;
    wire MemWrite_out_tb;
    wire Branch_out_tb;
    wire RegWrite_out_tb;
    wire MemtoReg_out_tb;
    wire ALUSrc_out_tb;
    wire [3:0] ALUOp_out_tb;

    datapath uut (
        .clk(clk_tb),
        .rst(rst_tb),
        .instruction(instruction_tb),
        .read_data_mem(read_data_mem_tb),
        .pc_out(pc_out_tb),
        .alu_result_out(alu_result_out_tb),
        .write_data_mem(write_data_mem_tb),
        .rs2_addr_out(rs2_addr_out_tb),
        .MemRead_out(MemRead_out_tb),
        .MemWrite_out(MemWrite_out_tb),
        .Branch_out(Branch_out_tb),
        .RegWrite_out(RegWrite_out_tb),
        .MemtoReg_out(MemtoReg_out_tb),
        .ALUSrc_out(ALUSrc_out_tb),
        .ALUOp_out(ALUOp_out_tb)
    );

    always #5 clk_tb = ~clk_tb;

    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b1;
        read_data_mem_tb = 32'b0;

        $monitor("Tempo=%0d PC=%h Instrução=%h RegWrite=%b MemtoReg=%b MemRead=%b MemWrite=%b ALUOp=%b ALUSrc=%b Branch=%b Resultado_ALU=%h",
                 $time, pc_out_tb, instruction_tb, RegWrite_out_tb, MemtoReg_out_tb, MemRead_out_tb, MemWrite_out_tb, ALUOp_out_tb, ALUSrc_out_tb, Branch_out_tb, alu_result_out_tb);

        #10 rst_tb = 1'b0;

        instruction_tb = 32'h00a00093;
        #10;

        instruction_tb = 32'h00500113;
        #10;

        instruction_tb = 32'h402081B3;
        #10;

        instruction_tb = 32'h00F1F213;
        #10;

        instruction_tb = 32'h00418463;
        #10;

        $finish;
    end

endmodule
