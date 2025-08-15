module immediate_generator (
    input [31:0] instruction,
    output reg [31:0] immediate
);

    wire [6:0] opcode = instruction[6:0];

    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE_LOAD = 7'b0000011;
    localparam I_TYPE_ALU = 7'b0010011;
    localparam S_TYPE = 7'b0100011;
    localparam B_TYPE = 7'b1100011;

    always @(*) begin
        case (opcode)
            I_TYPE_LOAD, I_TYPE_ALU: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            
            S_TYPE: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            B_TYPE: begin
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            
            R_TYPE: begin
                immediate = 32'b0;
            end
            
            default: begin
                immediate = 32'b0;
            end
        endcase
    end

endmodule
