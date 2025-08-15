import sys

def parse_instruction(line):
    line = line.split('#')[0].strip()
    if not line: return None
    parts = line.split()
    mnemonic = parts[0]
    operands = [op.replace(',', '').strip() for op in parts[1:]]
    return mnemonic, operands

def reg_to_bin(reg_name):
    return format(int(reg_name[1:]), '05b')

def imm_to_bin(imm_val, bits):
    val = int(imm_val)
    if val < 0:
        val = (1 << bits) + val
    return format(val, '0' + str(bits) + 'b')

def assemble_r_type(mnemonic, rd, rs1, rs2):
    opcode = '0110011'
    funct3 = ''
    funct7 = ''

    if mnemonic == 'add':
        funct3 = '000'
        funct7 = '0000000'
    elif mnemonic == 'sub':
        funct3 = '000'
        funct7 = '0100000'
    elif mnemonic == 'or':
        funct3 = '110'
        funct7 = '0000000'
    elif mnemonic == 'and':
        funct3 = '111'
        funct7 = '0000000'
    elif mnemonic == 'srl':
        funct3 = '101'
        funct7 = '0000000'
    else:
        raise ValueError(f"Unknown R-type instruction: {mnemonic}")

    return funct7 + reg_to_bin(rs2) + reg_to_bin(rs1) + funct3 + reg_to_bin(rd) + opcode

def assemble_i_type_load(mnemonic, rd, offset_rs1):
    opcode = '0000011'
    funct3 = ''

    offset_str, base_reg_str = offset_rs1.split('(')
    offset = offset_str
    rs1 = base_reg_str[:-1]

    if mnemonic == 'lh':
        funct3 = '001'
    else:
        raise ValueError(f"Unknown I-type load instruction: {mnemonic}")

    return imm_to_bin(offset, 12) + reg_to_bin(rs1) + funct3 + reg_to_bin(rd) + opcode

def assemble_i_type_alu(mnemonic, rd, rs1, imm):
    opcode = '0010011'
    funct3 = ''

    if mnemonic == 'andi':
        funct3 = '111'
    else:
        raise ValueError(f"Unknown I-type ALU instruction: {mnemonic}")

    return imm_to_bin(imm, 12) + reg_to_bin(rs1) + funct3 + reg_to_bin(rd) + opcode

def assemble_s_type(mnemonic, rs2, offset_rs1):
    opcode = '0100011'
    funct3 = ''

    offset_str, base_reg_str = offset_rs1.split('(')
    offset = int(offset_str)
    rs1 = base_reg_str[:-1]

    if mnemonic == 'sh':
        funct3 = '001'
    else:
        raise ValueError(f"Unknown S-type instruction: {mnemonic}")

    imm_bin = imm_to_bin(offset, 12)
    imm_11_5 = imm_bin[0:7]
    imm_4_0 = imm_bin[7:12]

    return imm_11_5 + reg_to_bin(rs2) + reg_to_bin(rs1) + funct3 + imm_4_0 + opcode

def assemble_b_type(mnemonic, rs1, rs2, label, current_address, labels):
    opcode = '1100011'
    funct3 = ''

    if mnemonic == 'beq':
        funct3 = '000'
    else:
        raise ValueError(f"Unknown B-type instruction: {mnemonic}")

    target_address = labels[label]
    offset = target_address - current_address

    imm_bin = imm_to_bin(offset // 2, 12)

    imm_12 = imm_bin[0]
    imm_10_5 = imm_bin[2:8]
    imm_4_1 = imm_bin[8:12]
    imm_11 = imm_bin[1]

    return imm_12 + imm_10_5 + reg_to_bin(rs2) + reg_to_bin(rs1) + funct3 + imm_4_1 + imm_11 + opcode

def assemble_instruction(mnemonic, operands, current_address, labels):
    if mnemonic in ['addi']:
        rd, rs1, imm = operands
        return imm_to_bin(imm, 12) + reg_to_bin(rs1) + '000' + reg_to_bin(rd) + '0010011'
    elif mnemonic in ['add', 'sub', 'or', 'and', 'srl']:
        rd, rs1, rs2 = operands
        return assemble_r_type(mnemonic, rd, rs1, rs2)
    elif mnemonic in ['lh']:
        rd, offset_rs1 = operands
        return assemble_i_type_load(mnemonic, rd, offset_rs1)
    elif mnemonic in ['andi']:
        rd, rs1, imm = operands
        return assemble_i_type_alu(mnemonic, rd, rs1, imm)
    elif mnemonic in ['sh']:
        rs2, offset_rs1 = operands
        return assemble_s_type(mnemonic, rs2, offset_rs1)
    elif mnemonic in ['beq']:
        rs1, rs2, label = operands
        return assemble_b_type(mnemonic, rs1, rs2, label, current_address, labels)
    else:
        raise ValueError(f"Unsupported instruction: {mnemonic}")

def main(input_file, output_file):
    lines = []
    with open(input_file, 'r') as f:
        for line in f:
            lines.append(line.strip())

    labels = {}
    current_address = 0
    for line in lines:
        stripped_line = line.split('#')[0].strip()
        if not stripped_line: continue
        if stripped_line.endswith(':'):
            label = stripped_line[:-1]
            labels[label] = current_address
        else:
            current_address += 4

    assembled_instructions = []
    current_address = 0
    for line in lines:
        stripped_line = line.split('#')[0].strip()
        if not stripped_line: continue
        if stripped_line.endswith(':'):
            continue
        
        mnemonic, operands = parse_instruction(line)
        if mnemonic:
            try:
                binary_instruction = assemble_instruction(mnemonic, operands, current_address, labels)
                assembled_instructions.append(binary_instruction)
                current_address += 4
            except ValueError as e:
                print(f"Error assembling line '{line.strip()}': {e}", file=sys.stderr)
                sys.exit(1)

    with open(output_file, 'w') as f:
        for instr_bin in assembled_instructions:
            f.write(format(int(instr_bin, 2), '08x') + '\n')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python3 riscv_assembler.py <input_assembly_file> <output_hex_file>", file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
