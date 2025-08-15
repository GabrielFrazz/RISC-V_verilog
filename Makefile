VERILOG_COMPILER = iverilog
VVP = vvp
GTKWAVE = gtkwave

COMMON_SOURCES = alu.v control_unit.v register_file.v instruction_memory.v data_memory.v
PIPELINED_SOURCES = $(COMMON_SOURCES) immediate_generator.v forwarding_unit.v hazard_detection_unit.v processor.v

PIPELINED_TB = processor_tb.v
PIPELINED_OUT = processor


pipelined: $(PIPELINED_OUT)
	@echo "=== Running Pipelined Processor ==="
	$(VVP) $(PIPELINED_OUT)

$(PIPELINED_OUT): $(PIPELINED_SOURCES) $(PIPELINED_TB)
	$(VERILOG_COMPILER) -o $(PIPELINED_OUT) $(PIPELINED_SOURCES) $(PIPELINED_TB)

test-alu: alu.v alu_tb.v
	$(VERILOG_COMPILER) -o test_alu alu.v alu_tb.v
	$(VVP) test_alu

test-control: control_unit.v control_unit_tb.v
	$(VERILOG_COMPILER) -o test_control control_unit.v control_unit_tb.v
	$(VVP) test_control

test-datapath: $(SINGLE_CYCLE_SOURCES) datapath_tb.v
	$(VERILOG_COMPILER) -o test_datapath $(SINGLE_CYCLE_SOURCES) datapath_tb.v
	$(VVP) test_datapath

test-memory: data_memory.v data_memory_tb.v
	$(VERILOG_COMPILER) -o test_memory data_memory.v data_memory_tb.v
	$(VVP) test_memory

wave-pipelined: pipelined
	$(GTKWAVE) processor.vcd &

assemble: test_program.s
	python3 riscv_assembler.py test_program.s instruction.mem
	@echo "Assembly completed. Generated instruction.mem"

clean:
	rm -f  $(PIPELINED_OUT) $(COMPARISON_OUT)
	rm -f test_alu test_control test_datapath test_memory
	rm -f *.vcd
	rm -f instruction.mem

help:
	@echo "Available targets:"
	@echo "  pipelined    - Build and run pipelined processor"
	@echo "  test-*       - Run individual component tests"
	@echo "  wave-*       - View waveforms (requires GTKWave)"
	@echo "  assemble     - Assemble test_program.s to instruction.mem"
	@echo "  clean        - Remove generated files"
	@echo "  help         - Show this help message"

performance: comparison
	@echo ""
	@echo "=== Performance Analysis ==="
	@echo "Single-cycle: 1 CPI, lower latency"
	@echo "Pipelined: ~1 CPI (steady state), higher throughput"
	@echo "Pipeline benefits increase with longer programs"

.PHONY: all single-cycle pipelined comparison clean help performance assemble
.PHONY: test-alu test-control test-datapath test-memory
.PHONY: wave-single wave-pipelined
