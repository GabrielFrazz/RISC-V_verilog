module hazard_detection_unit (
    input ID_EX_MemRead,
    input [4:0] ID_EX_rd_addr,
    input [4:0] IF_ID_rs1_addr,
    input [4:0] IF_ID_rs2_addr,
    input EX_MEM_Branch,
    input EX_MEM_zero,
    output reg stall,
    output reg flush_IF_ID,
    output reg flush_ID_EX
);

    always @(*) begin
        stall = 1'b0;
        flush_IF_ID = 1'b0;
        flush_ID_EX = 1'b0;

        if (ID_EX_MemRead && (ID_EX_rd_addr != 5'b00000)) begin
            if ((ID_EX_rd_addr == IF_ID_rs1_addr) || (ID_EX_rd_addr == IF_ID_rs2_addr)) begin
                stall = 1'b1;
            end
        end

        if (EX_MEM_Branch && EX_MEM_zero) begin
            flush_IF_ID = 1'b1;
            flush_ID_EX = 1'b1;
        end
    end

endmodule
