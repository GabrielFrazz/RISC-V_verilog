module data_memory (
    input clk,
    input MemWrite,
    input MemRead,
    input [31:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    reg [7:0] mem [0:1023];
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            mem[i] = 8'b0;
        end
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            mem[addr] <= write_data[7:0];
            mem[addr + 1] <= write_data[15:8];
        end
    end

    always @(*) begin
        if (MemRead) begin
            read_data = { {16{mem[addr+1][7]}}, mem[addr+1], mem[addr] };
        end else begin
            read_data = 32'b0;
        end
    end

endmodule
