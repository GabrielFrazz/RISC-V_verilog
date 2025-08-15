module datapath (
    input clk,
    input rst,
    input [31:0] instruction,
    input [31:0] read_data_mem,
    output [31:0] pc_out,
    output [31:0] alu_result_out,
    output [31:0] write_data_mem,
    output [4:0] rs2_addr_out,
    output MemRead_out,
    output MemWrite_out,
    output Branch_out,
    output RegWrite_out,
    output MemtoReg_out,
    output ALUSrc_out,
    output [3:0] ALUOp_out
);

    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE_LOAD = 7'b0000011;
    localparam I_TYPE_ALU = 7'b0010011;
    localparam S_TYPE = 7'b0100011;
    localparam B_TYPE = 7'b1100011;

    wire [6:0] opcode;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_branch_target;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_src2;
    wire [31:0] alu_result;
    wire zero;
    wire [31:0] write_back_data;
    wire RegWrite, MemtoReg, MemRead, MemWrite, ALUSrc, Branch;
    wire [3:0] ALUOp;
    wire [31:0] immediate;

    reg [31:0] pc;

    assign pc_out = pc;
    assign alu_result_out = alu_result;
    assign write_data_mem = rs2_data;
    assign rs2_addr_out = rs2_addr;
    assign MemRead_out = MemRead;
    assign MemWrite_out = MemWrite;
    assign Branch_out = Branch;
    assign RegWrite_out = RegWrite;
    assign MemtoReg_out = MemtoReg;
    assign ALUSrc_out = ALUSrc;
    assign ALUOp_out = ALUOp;

    assign opcode = instruction[6:0];
    assign rd_addr = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign funct7 = instruction[31:25];

    assign pc_plus_4 = pc + 32'd4;
    assign pc_branch_target = pc + immediate;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;
        end else begin
            if (Branch && zero) begin
                pc <= pc_branch_target;
            end else begin
                pc <= pc_plus_4;
            end
        end
    end

    control_unit cu (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUOp(ALUOp),
        .ALUSrc(ALUSrc),
        .Branch(Branch)
    );

    register_file rf (
        .clk(clk),
        .rst(rst),
        .RegWrite(RegWrite),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .write_data(write_back_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    wire [31:0] i_immediate;
    wire [31:0] s_immediate;
    wire [31:0] b_immediate;

    assign i_immediate = {{20{instruction[31]}}, instruction[31:20]};

    assign s_immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

    assign b_immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

    assign immediate = (opcode == I_TYPE_LOAD || opcode == I_TYPE_ALU) ? i_immediate :
                       (opcode == S_TYPE) ? s_immediate :
                       (opcode == B_TYPE) ? b_immediate : 32'b0;

    assign alu_src2 = ALUSrc ? immediate : rs2_data;

    alu alu_inst (
        .src1(rs1_data),
        .src2(alu_src2),
        .alu_op(ALUOp),
        .alu_result(alu_result),
        .zero(zero)
    );

    assign write_back_data = MemtoReg ? read_data_mem : alu_result;

endmodule
