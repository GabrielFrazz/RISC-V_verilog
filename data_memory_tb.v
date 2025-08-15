module data_memory_tb;

    reg clk_tb;
    reg MemWrite_tb;
    reg MemRead_tb;
    reg [31:0] addr_tb;
    reg [31:0] write_data_tb;
    wire [31:0] read_data_tb;

    data_memory uut (
        .clk(clk_tb),
        .MemWrite(MemWrite_tb),
        .MemRead(MemRead_tb),
        .addr(addr_tb),
        .write_data(write_data_tb),
        .read_data(read_data_tb)
    );

    always #5 clk_tb = ~clk_tb;

    initial begin
        clk_tb = 1'b0;
        MemWrite_tb = 1'b0;
        MemRead_tb = 1'b0;
        addr_tb = 32'b0;
        write_data_tb = 32'b0;

        $display("Tempo\tEndereço\tDadosEscrita\tMemWrite\tMemRead\tDadosLeitura");
        $monitor("%0d\t%h\t%h\t%b\t%b\t%h",
                 $time, addr_tb, write_data_tb, MemWrite_tb, MemRead_tb, read_data_tb);

        addr_tb = 32'h00000000;
        write_data_tb = 32'h0000ABCD;
        MemWrite_tb = 1'b1;
        #10;
        MemWrite_tb = 1'b0;

        addr_tb = 32'h00000000;
        MemRead_tb = 1'b1;
        #10;
        MemRead_tb = 1'b0;

        addr_tb = 32'h00000002;
        write_data_tb = 32'h0000EF12;
        MemWrite_tb = 1'b1;
        #10;
        MemWrite_tb = 1'b0;

        addr_tb = 32'h00000002;
        MemRead_tb = 1'b1;
        #10;
        MemRead_tb = 1'b0;

        $finish;
    end

endmodule
