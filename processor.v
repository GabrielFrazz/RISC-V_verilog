module processor (
    input clk,
    input rst
);

    reg [31:0] IF_ID_pc, IF_ID_instruction;
    reg IF_ID_valid;

    reg [31:0] ID_EX_pc, ID_EX_rs1_data, ID_EX_rs2_data, ID_EX_immediate;
    reg [4:0] ID_EX_rs1_addr, ID_EX_rs2_addr, ID_EX_rd_addr;
    reg [6:0] ID_EX_opcode;
    reg [2:0] ID_EX_funct3;
    reg [6:0] ID_EX_funct7;
    reg ID_EX_RegWrite, ID_EX_MemtoReg, ID_EX_MemRead, ID_EX_MemWrite;
    reg ID_EX_ALUSrc, ID_EX_Branch;
    reg [3:0] ID_EX_ALUOp;
    reg ID_EX_valid;

    reg [31:0] EX_MEM_pc, EX_MEM_alu_result, EX_MEM_rs2_data, EX_MEM_immediate;
    reg [4:0] EX_MEM_rd_addr;
    reg EX_MEM_RegWrite, EX_MEM_MemtoReg, EX_MEM_MemRead, EX_MEM_MemWrite;
    reg EX_MEM_Branch, EX_MEM_zero;
    reg EX_MEM_valid;

    reg [31:0] MEM_WB_alu_result, MEM_WB_read_data;
    reg [4:0] MEM_WB_rd_addr;
    reg MEM_WB_RegWrite, MEM_WB_MemtoReg;
    reg MEM_WB_valid;

    wire [31:0] pc_current, pc_next, pc_plus_4, pc_branch_target;
    wire [31:0] instruction_current;
    wire [31:0] rs1_data_raw, rs2_data_raw;
    wire [31:0] rs1_data_forwarded, rs2_data_forwarded;
    wire [31:0] alu_src1, alu_src2;
    wire [31:0] alu_result;
    wire zero_flag;
    wire [31:0] write_back_data;
    wire [31:0] read_data_mem;
    wire branch_taken;

    wire RegWrite, MemtoReg, MemRead, MemWrite, ALUSrc, Branch;
    wire [3:0] ALUOp;

    wire stall_pipeline;
    wire [1:0] forward_A, forward_B;
    wire flush_IF_ID, flush_ID_EX;

    reg [31:0] pc;

    assign pc_current = pc;
    assign pc_plus_4 = pc + 32'd4;
    assign pc_branch_target = EX_MEM_pc + EX_MEM_immediate;
    assign branch_taken = EX_MEM_Branch && EX_MEM_zero;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;
        end else if (!stall_pipeline) begin
            if (branch_taken) begin
                pc <= pc_branch_target;
            end else begin
                pc <= pc_plus_4;
            end
        end
    end

    instruction_memory im (
        .addr(pc_current),
        .instruction(instruction_current)
    );

    data_memory dm (
        .clk(clk),
        .MemWrite(EX_MEM_MemWrite && EX_MEM_valid),
        .MemRead(EX_MEM_MemRead && EX_MEM_valid),
        .addr(EX_MEM_alu_result),
        .write_data(EX_MEM_rs2_data),
        .read_data(read_data_mem)
    );

    register_file rf (
        .clk(clk),
        .rst(rst),
        .RegWrite(MEM_WB_RegWrite && MEM_WB_valid),
        .rs1_addr(IF_ID_instruction[19:15]),
        .rs2_addr(IF_ID_instruction[24:20]),
        .rd_addr(MEM_WB_rd_addr),
        .write_data(write_back_data),
        .rs1_data(rs1_data_raw),
        .rs2_data(rs2_data_raw)
    );

    wire [31:0] rs1_data_bypassed, rs2_data_bypassed;
    assign rs1_data_bypassed = ((MEM_WB_RegWrite && MEM_WB_valid) && 
                               (MEM_WB_rd_addr == IF_ID_instruction[19:15]) && 
                               (MEM_WB_rd_addr != 5'b00000)) ? 
                               write_back_data : rs1_data_raw;
    assign rs2_data_bypassed = ((MEM_WB_RegWrite && MEM_WB_valid) && 
                               (MEM_WB_rd_addr == IF_ID_instruction[24:20]) && 
                               (MEM_WB_rd_addr != 5'b00000)) ? 
                               write_back_data : rs2_data_raw;

    control_unit cu (
        .opcode(IF_ID_instruction[6:0]),
        .funct3(IF_ID_instruction[14:12]),
        .funct7(IF_ID_instruction[31:25]),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUOp(ALUOp),
        .ALUSrc(ALUSrc),
        .Branch(Branch)
    );

    hazard_detection_unit hdu (
        .ID_EX_MemRead(ID_EX_MemRead),
        .ID_EX_rd_addr(ID_EX_rd_addr),
        .IF_ID_rs1_addr(IF_ID_instruction[19:15]),
        .IF_ID_rs2_addr(IF_ID_instruction[24:20]),
        .EX_MEM_Branch(EX_MEM_Branch),
        .EX_MEM_zero(EX_MEM_zero),
        .stall(stall_pipeline),
        .flush_IF_ID(flush_IF_ID),
        .flush_ID_EX(flush_ID_EX)
    );

    forwarding_unit fu (
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .EX_MEM_rd_addr(EX_MEM_rd_addr),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .MEM_WB_rd_addr(MEM_WB_rd_addr),
        .ID_EX_rs1_addr(ID_EX_rs1_addr),
        .ID_EX_rs2_addr(ID_EX_rs2_addr),
        .EX_MEM_valid(EX_MEM_valid),
        .MEM_WB_valid(MEM_WB_valid),
        .forward_A(forward_A),
        .forward_B(forward_B)
    );

    assign rs1_data_forwarded = (forward_A == 2'b10) ? EX_MEM_alu_result :
                               (forward_A == 2'b01) ? write_back_data :
                               ID_EX_rs1_data;

    assign rs2_data_forwarded = (forward_B == 2'b10) ? EX_MEM_alu_result :
                               (forward_B == 2'b01) ? write_back_data :
                               ID_EX_rs2_data;

    assign alu_src1 = rs1_data_forwarded;
    assign alu_src2 = ID_EX_ALUSrc ? ID_EX_immediate : rs2_data_forwarded;

    alu alu_inst (
        .src1(alu_src1),
        .src2(alu_src2),
        .alu_op(ID_EX_ALUOp),
        .alu_result(alu_result),
        .zero(zero_flag)
    );

    assign write_back_data = MEM_WB_MemtoReg ? MEM_WB_read_data : MEM_WB_alu_result;

    wire [31:0] immediate;
    immediate_generator imm_gen (
        .instruction(IF_ID_instruction),
        .immediate(immediate)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            IF_ID_pc <= 32'b0;
            IF_ID_instruction <= 32'b0;
            IF_ID_valid <= 1'b0;

            ID_EX_pc <= 32'b0;
            ID_EX_rs1_data <= 32'b0;
            ID_EX_rs2_data <= 32'b0;
            ID_EX_immediate <= 32'b0;
            ID_EX_rs1_addr <= 5'b0;
            ID_EX_rs2_addr <= 5'b0;
            ID_EX_rd_addr <= 5'b0;
            ID_EX_opcode <= 7'b0;
            ID_EX_funct3 <= 3'b0;
            ID_EX_funct7 <= 7'b0;
            ID_EX_RegWrite <= 1'b0;
            ID_EX_MemtoReg <= 1'b0;
            ID_EX_MemRead <= 1'b0;
            ID_EX_MemWrite <= 1'b0;
            ID_EX_ALUSrc <= 1'b0;
            ID_EX_Branch <= 1'b0;
            ID_EX_ALUOp <= 4'b0;
            ID_EX_valid <= 1'b0;

            EX_MEM_pc <= 32'b0;
            EX_MEM_alu_result <= 32'b0;
            EX_MEM_rs2_data <= 32'b0;
            EX_MEM_immediate <= 32'b0;
            EX_MEM_rd_addr <= 5'b0;
            EX_MEM_RegWrite <= 1'b0;
            EX_MEM_MemtoReg <= 1'b0;
            EX_MEM_MemRead <= 1'b0;
            EX_MEM_MemWrite <= 1'b0;
            EX_MEM_Branch <= 1'b0;
            EX_MEM_zero <= 1'b0;
            EX_MEM_valid <= 1'b0;

            MEM_WB_alu_result <= 32'b0;
            MEM_WB_read_data <= 32'b0;
            MEM_WB_rd_addr <= 5'b0;
            MEM_WB_RegWrite <= 1'b0;
            MEM_WB_MemtoReg <= 1'b0;
            MEM_WB_valid <= 1'b0;
        end else begin
            if (flush_IF_ID) begin
                IF_ID_pc <= 32'b0;
                IF_ID_instruction <= 32'b0;
                IF_ID_valid <= 1'b0;
            end else if (!stall_pipeline) begin
                IF_ID_pc <= pc_current;
                IF_ID_instruction <= instruction_current;
                IF_ID_valid <= 1'b1;
            end

            if (flush_ID_EX || stall_pipeline) begin
                ID_EX_RegWrite <= 1'b0;
                ID_EX_MemtoReg <= 1'b0;
                ID_EX_MemRead <= 1'b0;
                ID_EX_MemWrite <= 1'b0;
                ID_EX_ALUSrc <= 1'b0;
                ID_EX_Branch <= 1'b0;
                ID_EX_ALUOp <= 4'b0;
                ID_EX_valid <= 1'b0;
            end else begin
                ID_EX_pc <= IF_ID_pc;
                ID_EX_rs1_data <= rs1_data_bypassed;
                ID_EX_rs2_data <= rs2_data_bypassed;
                ID_EX_immediate <= immediate;
                ID_EX_rs1_addr <= IF_ID_instruction[19:15];
                ID_EX_rs2_addr <= IF_ID_instruction[24:20];
                ID_EX_rd_addr <= IF_ID_instruction[11:7];
                ID_EX_opcode <= IF_ID_instruction[6:0];
                ID_EX_funct3 <= IF_ID_instruction[14:12];
                ID_EX_funct7 <= IF_ID_instruction[31:25];
                ID_EX_RegWrite <= RegWrite;
                ID_EX_MemtoReg <= MemtoReg;
                ID_EX_MemRead <= MemRead;
                ID_EX_MemWrite <= MemWrite;
                ID_EX_ALUSrc <= ALUSrc;
                ID_EX_Branch <= Branch;
                ID_EX_ALUOp <= ALUOp;
                ID_EX_valid <= IF_ID_valid;
            end

            if (flush_ID_EX) begin
                EX_MEM_RegWrite <= 1'b0;
                EX_MEM_MemtoReg <= 1'b0;
                EX_MEM_MemRead <= 1'b0;
                EX_MEM_MemWrite <= 1'b0;
                EX_MEM_Branch <= 1'b0;
                EX_MEM_valid <= 1'b0;
                EX_MEM_pc <= ID_EX_pc;
                EX_MEM_alu_result <= alu_result;
                EX_MEM_rs2_data <= rs2_data_forwarded;
                EX_MEM_immediate <= ID_EX_immediate;
                EX_MEM_rd_addr <= ID_EX_rd_addr;
                EX_MEM_zero <= zero_flag;
            end else begin
                EX_MEM_pc <= ID_EX_pc;
                EX_MEM_alu_result <= alu_result;
                EX_MEM_rs2_data <= rs2_data_forwarded;
                EX_MEM_immediate <= ID_EX_immediate;
                EX_MEM_rd_addr <= ID_EX_rd_addr;
                EX_MEM_RegWrite <= ID_EX_RegWrite;
                EX_MEM_MemtoReg <= ID_EX_MemtoReg;
                EX_MEM_MemRead <= ID_EX_MemRead;
                EX_MEM_MemWrite <= ID_EX_MemWrite;
                EX_MEM_Branch <= ID_EX_Branch;
                EX_MEM_zero <= zero_flag;
                EX_MEM_valid <= ID_EX_valid;
            end

            MEM_WB_alu_result <= EX_MEM_alu_result;
            MEM_WB_read_data <= read_data_mem;
            MEM_WB_rd_addr <= EX_MEM_rd_addr;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
            MEM_WB_valid <= EX_MEM_valid;
        end
    end

endmodule
