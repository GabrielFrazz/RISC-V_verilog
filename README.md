# Processador RISC-V - TP1 OAC-II

## Visão Geral

Este projeto implementa um **processador RISC-V com pipeline de 5 estágios** em Verilog, desenvolvido como Trabalho Prático 1 da disciplina de Organização e Arquitetura de Computadores II. O processador inclui tratamento completo de hazards, forwarding de dados e um assembler personalizado em Python. O projeto foi realizado pelos alunos Carlos Gabriel de Oliveira Frazão (22.1.8100) e Patrick Peres Nicolini (22.1.8103).

### Objetivos do Projeto

- Implementar pipeline de 5 estágios (IF, ID, EX, MEM, WB)
- Resolver hazards de dados através de forwarding
- Detectar e tratar hazards de controle (branches)
- Implementar stalls para hazards load-use
- Criar ferramentas de desenvolvimento (assembler, testbenches)

## Arquitetura do Processador

### Pipeline de 5 Estágios

```
┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐
│ IF  │ -> │ ID  │ -> │ EX  │ -> │ MEM │ -> │ WB  │
└─────┘    └─────┘    └─────┘    └─────┘    └─────┘
```

1. **IF (Instruction Fetch)**: Busca instrução da memória
2. **ID (Instruction Decode)**: Decodifica instrução e lê registradores
3. **EX (Execute)**: Executa operação na ALU
4. **MEM (Memory Access)**: Acessa memória de dados
5. **WB (Write Back)**: Escreve resultado no banco de registradores

### Tratamento de Hazards

#### Data Hazards

- **Forwarding EX→EX**: Dados do estágio EX/MEM para entrada da ALU
- **Forwarding MEM→EX**: Dados do estágio MEM/WB para entrada da ALU
- **Prioridade**: EX forwarding tem prioridade sobre MEM forwarding

#### Load-Use Hazards

- **Detecção**: Quando instrução load é seguida por instrução que usa o mesmo registrador
- **Solução**: Stall de 1 ciclo no pipeline

#### Control Hazards

- **Detecção**: Branches tomados invalidam instruções já buscadas
- **Solução**: Flush dos estágios IF/ID e ID/EX quando branch é tomado

## Estrutura do Projeto

```
  /
├──  Módulos Principais
│   ├── processor.v              # Processador pipelined principal
│   ├── alu.v                   # Unidade Lógica Aritmética
│   ├── control_unit.v          # Unidade de controle
│   ├── register_file.v         # Banco de registradores (32x32 bits)
│   ├── data_memory.v           # Memória de dados
│   └── instruction_memory.v    # Memória de instruções
│
├──  Unidades de Hazard
│   ├── forwarding_unit.v       # Unidade de forwarding
│   ├── hazard_detection_unit.v # Detecção de hazards
│   └── immediate_generator.v   # Gerador de imediatos
│
├──  Testbenches
│   ├── processor_tb.v          # Testbench principal
│   ├── alu_tb.v               # Teste da ALU
│   ├── control_unit_tb.v      # Teste da unidade de controle
│   ├── data_memory_tb.v       # Teste da memória de dados
│   └── datapath_tb.v          # Teste do datapath
│
├──  Ferramentas
│   ├── riscv_assembler.py     # Assembler RISC-V em Python
│   ├── test_program.s         # Programa de teste em assembly
│   ├── instruction.mem        # Código de máquina gerado
│   └── Makefile              # Automação de build e testes
│
└──  Documentação
    ├── README.md             # Este arquivo
```

## Instruções Suportadas

### R-Type (Registrador-Registrador)

| Instrução | Descrição          | Exemplo          |
| --------- | ------------------ | ---------------- |
| `add`     | Adição             | `add x1, x2, x3` |
| `sub`     | Subtração          | `sub x1, x2, x3` |
| `or`      | OR lógico          | `or x1, x2, x3`  |
| `and`     | AND lógico         | `and x1, x2, x3` |
| `srl`     | Shift right lógico | `srl x1, x2, x3` |

### I-Type (Imediato)

| Instrução | Descrição           | Exemplo            |
| --------- | ------------------- | ------------------ |
| `addi`    | Adição com imediato | `addi x1, x2, 100` |
| `andi`    | AND com imediato    | `andi x1, x2, 15`  |
| `lh`      | Load halfword       | `lh x1, 4(x2)`     |

### S-Type (Store)

| Instrução | Descrição      | Exemplo        |
| --------- | -------------- | -------------- |
| `sh`      | Store halfword | `sh x1, 4(x2)` |

### B-Type (Branch)

| Instrução | Descrição       | Exemplo             |
| --------- | --------------- | ------------------- |
| `beq`     | Branch if equal | `beq x1, x2, LABEL` |

## Assembler Python

### Características

- **Linguagem**: Python 3
- **Entrada**: Arquivo assembly (.s)
- **Saída**: Arquivo hexadecimal (.mem)
- **Suporte**: Todas as instruções implementadas no processador
- **Labels**: Suporte a labels para branches

### Uso do Assembler

```bash
# Sintaxe básica
python3 riscv_assembler.py <arquivo_entrada.s> <arquivo_saida.mem>

# Exemplo prático
python3 riscv_assembler.py test_program.s instruction.mem
```

### Exemplo de Programa Assembly

```assembly
# test_program.s - Programa de exemplo
addi x2, x0, 7      # x2 = 7
sh x2, 4(x0)        # Armazena x2 no endereço 4
lh x1, 4(x0)        # Carrega valor do endereço 4 para x1
add x2, x1, x0      # x2 = x1 + 0
add x1, x1, x2      # x1 = x1 + x2 (hazard de dados)
sub x1, x1, x2      # x1 = x1 - x2
beq x1, x2, SAIDA   # Branch se x1 == x2 (hazard de controle)
add x1, x1, x1      # Esta instrução será pulada
SAIDA:
and x1, x1, x2      # x1 = x1 & x2
or x1, x1, x0       # x1 = x1 | 0
sh x1, 0(x0)        # Armazena resultado final
```

## Makefile

### Targets Principais

```bash
# Compilar e executar processador pipelined
make pipelined

# Executar todos os testes de componentes
make test-alu          # Testa ALU
make test-control      # Testa unidade de controle
make test-memory       # Testa memória de dados
make test-datapath     # Testa datapath

# Visualizar formas de onda (requer GTKWave)
make wave-pipelined

# Assemblar programa de teste
make assemble

# Limpar arquivos gerados
make clean

# Mostrar ajuda
make help
```

### Fluxo de Desenvolvimento

```bash
# 1. Editar programa assembly
nano test_program.s

# 2. Assemblar para código de máquina
make assemble

# 3. Executar simulação
make pipelined

# 4. Visualizar resultados
make wave-pipelined
```

## Como Executar

### Pré-requisitos

- **Icarus Verilog** (`iverilog`) - Compilador Verilog
- **VVP** - Simulador Verilog
- **Python 3** - Para o assembler
- **GTKWave** (opcional) - Visualizador de formas de onda
- **Make** - Automação de build

### Instalação no Ubuntu/Debian

```bash
sudo apt update
sudo apt install iverilog gtkwave python3 make
```

### Execução Passo a Passo

1. **Clone/Navegue para o diretório do projeto**

```bash
git clone https://github.com/GabrielFrazz/RISC-V_verilog.git
```

```bash
cd RISC-V_verilog/
```

2. **Assemble o programa de teste**

```bash
make assemble
```

3. **Execute o processador**

```bash
make pipelined
```

4. **Visualize as formas de onda (opcional)**

```bash
make wave-pipelined
```

### Saída Esperada

```
=== Processador RISC-V Pipelined ===
Tempo   Ciclo   PC      IF/ID_Inst  Stall   Flush_IF    Flush_ID    Forward_A   Forward_B
-----   -----   --      ----------  -----   --------    --------    ---------   ---------
10      1       00000000 00700113   0       0           0           0           0
20      2       00000004 00201223   0       0           0           0           0
*** STALL detectado no ciclo 3 - Hazard Load-Use ***
*** FORWARDING no ciclo 5 - A:10 B:00 ***
*** FLUSH detectado no ciclo 8 - Branch tomado ***

=== Estado final dos registradores ===
x0 = 00000000 (0)
x1 = 00000007 (7)
x2 = 00000007 (7)
...

=== Análise de Desempenho ===
Total de ciclos executados: 25
CPI (Ciclos Por Instrução): ~2.50
```

## Testes e Verificação

### Testbenches Disponíveis

- **processor_tb.v**: Teste completo do processador com monitoramento detalhado
- **alu_tb.v**: Verificação de todas as operações da ALU
- **control_unit_tb.v**: Teste dos sinais de controle para cada tipo de instrução
- **data_memory_tb.v**: Teste de operações de load/store
- **datapath_tb.v**: Teste do fluxo de dados

### Executar Testes Individuais

```bash
make test-alu      # Testa operações: ADD, SUB, OR, AND, SRL
make test-control  # Testa sinais: RegWrite, MemRead, ALUOp, etc.
make test-memory   # Testa load/store de halfwords
```
