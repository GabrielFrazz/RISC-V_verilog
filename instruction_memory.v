module instruction_memory (
    input [31:0] addr,
    output [31:0] instruction
);

    reg [31:0] mem [0:255];

    initial begin
        $readmemh("instruction.mem", mem);
    end

    assign instruction = mem[addr[9:2]];

endmodule
