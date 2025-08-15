module processor_tb;

    reg clk_tb;
    reg rst_tb;

    processor uut (
        .clk(clk_tb),
        .rst(rst_tb)
    );

    always #5 clk_tb = ~clk_tb;

    integer cycle_count;

    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b1;
        cycle_count = 0;

        $dumpfile("processor.vcd");
        $dumpvars(0, processor_tb);

        #10 rst_tb = 1'b0;

        $display("=== Processador RISC-V Pipelined ===");
        $display("Tempo\tCiclo\tPC\t\tIF/ID_Inst\tStall\tFlush_IF\tFlush_ID\tForward_A\tForward_B");
        $display("-----\t-----\t--\t\t----------\t-----\t--------\t--------\t---------\t---------");

        $monitor("%0d\t    %0d\t%h\t%h\t    %b\t      %b\t         %b\t       %b\t         %b", 
                 $time, cycle_count, uut.pc_current, uut.IF_ID_instruction, 
                 uut.stall_pipeline, uut.flush_IF_ID, uut.flush_ID_EX, 
                 uut.forward_A, uut.forward_B);

        repeat (25) begin
            @(posedge clk_tb);
            cycle_count = cycle_count + 1;
        end

        $display("\n=== Conteúdo dos Estágios do Pipeline no Final ===");
        $display("Estágio IF/ID:");
        $display("  PC: %h, Instrução: %h, Válido: %b", uut.IF_ID_pc, uut.IF_ID_instruction, uut.IF_ID_valid);
        
        $display("Estágio ID/EX:");
        $display("  PC: %h, rd_addr: %d, rs1_addr: %d, rs2_addr: %d", uut.ID_EX_pc, uut.ID_EX_rd_addr, uut.ID_EX_rs1_addr, uut.ID_EX_rs2_addr);
        $display("  rs1_data: %h, rs2_data: %h, imediato: %h", uut.ID_EX_rs1_data, uut.ID_EX_rs2_data, uut.ID_EX_immediate);
        $display("  RegWrite: %b, MemRead: %b, MemWrite: %b, Branch: %b, Válido: %b", 
                 uut.ID_EX_RegWrite, uut.ID_EX_MemRead, uut.ID_EX_MemWrite, uut.ID_EX_Branch, uut.ID_EX_valid);
        
        $display("Estágio EX/MEM:");
        $display("  PC: %h, Resultado_ALU: %h, rd_addr: %d", uut.EX_MEM_pc, uut.EX_MEM_alu_result, uut.EX_MEM_rd_addr);
        $display("  RegWrite: %b, MemRead: %b, MemWrite: %b, Branch: %b, Zero: %b, Válido: %b", 
                 uut.EX_MEM_RegWrite, uut.EX_MEM_MemRead, uut.EX_MEM_MemWrite, uut.EX_MEM_Branch, uut.EX_MEM_zero, uut.EX_MEM_valid);
        
        $display("Estágio MEM/WB:");
        $display("  Resultado_ALU: %h, Dados_lidos: %h, rd_addr: %d", uut.MEM_WB_alu_result, uut.MEM_WB_read_data, uut.MEM_WB_rd_addr);
        $display("  RegWrite: %b, MemtoReg: %b, Válido: %b", uut.MEM_WB_RegWrite, uut.MEM_WB_MemtoReg, uut.MEM_WB_valid);

        $display("\n=== Estado final dos registradores ===");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %h (%0d)", i, uut.rf.registers[i], uut.rf.registers[i]);
        end

        $display("\n=== Conteúdo da memória de dados ===");
        for (integer i = 0; i < 16; i = i + 2) begin
            $display("Endereço %0d: %h%h", i, uut.dm.mem[i+1], uut.dm.mem[i]);
        end

        $display("\n=== Análise de Desempenho ===");
        $display("Total de ciclos executados: %0d", cycle_count);
        $display("Instruções no programa de teste: ~10");
        $display("CPI (Ciclos Por Instrução): ~%0.2f", cycle_count / 10.0);
        $display("Nota: CPI > 1 devido a stalls do pipeline e penalidades de branch");

        $finish;
    end

    always @(posedge clk_tb) begin
        if (!rst_tb) begin
            if (uut.stall_pipeline) begin
                $display("*** STALL detectado no ciclo %0d - Hazard Load-Use ***", cycle_count);
            end
            if (uut.flush_IF_ID || uut.flush_ID_EX) begin
                $display("*** FLUSH detectado no ciclo %0d - Branch tomado ***", cycle_count);
            end
            if (uut.forward_A != 2'b00 || uut.forward_B != 2'b00) begin
                $display("*** FORWARDING no ciclo %0d - A:%b B:%b ***", cycle_count, uut.forward_A, uut.forward_B);
            end
            
            if (uut.ID_EX_valid && (uut.ID_EX_ALUOp != 4'b0000 || uut.ID_EX_opcode == 7'b0110011 || uut.ID_EX_opcode == 7'b1100011)) begin
                $display("*** ALU no ciclo %0d: src1=%h src2=%h op=%b resultado=%h ***", 
                         cycle_count, uut.alu_src1, uut.alu_src2, uut.ID_EX_ALUOp, uut.alu_result);
            end
            
            if (uut.MEM_WB_RegWrite && uut.MEM_WB_valid && uut.MEM_WB_rd_addr != 5'b00000) begin
                $display("*** ESCRITA REG no ciclo %0d: x%0d <= %h (MemtoReg=%b) ***", 
                         cycle_count, uut.MEM_WB_rd_addr, uut.write_back_data, uut.MEM_WB_MemtoReg);
            end
        end
    end

endmodule
