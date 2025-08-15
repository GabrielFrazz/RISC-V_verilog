module forwarding_unit (
    input EX_MEM_RegWrite,
    input [4:0] EX_MEM_rd_addr,
    input MEM_WB_RegWrite,
    input [4:0] MEM_WB_rd_addr,
    input [4:0] ID_EX_rs1_addr,
    input [4:0] ID_EX_rs2_addr,
    input EX_MEM_valid,
    input MEM_WB_valid,
    output reg [1:0] forward_A,
    output reg [1:0] forward_B
);

    always @(*) begin
        forward_A = 2'b00;
        forward_B = 2'b00;

        if (EX_MEM_RegWrite && EX_MEM_valid && (EX_MEM_rd_addr != 5'b00000)) begin
            if (EX_MEM_rd_addr == ID_EX_rs1_addr) begin
                forward_A = 2'b10;
            end
            if (EX_MEM_rd_addr == ID_EX_rs2_addr) begin
                forward_B = 2'b10;
            end
        end

        if (MEM_WB_RegWrite && MEM_WB_valid && (MEM_WB_rd_addr != 5'b00000)) begin
            if ((MEM_WB_rd_addr == ID_EX_rs1_addr) && 
                !(EX_MEM_RegWrite && EX_MEM_valid && (EX_MEM_rd_addr != 5'b00000) && (EX_MEM_rd_addr == ID_EX_rs1_addr))) begin
                forward_A = 2'b01;
            end
            
            if ((MEM_WB_rd_addr == ID_EX_rs2_addr) && 
                !(EX_MEM_RegWrite && EX_MEM_valid && (EX_MEM_rd_addr != 5'b00000) && (EX_MEM_rd_addr == ID_EX_rs2_addr))) begin
                forward_B = 2'b01;
            end
        end
    end

endmodule
