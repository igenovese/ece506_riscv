/**
            PORTLAND STATE UNIVERSITY
    ECE 506: RISC-V RV32I in SystemVerilog

@author: Genovese, R. Ignacio
@date: Fall 2019    
@description: this file contains parameters and typedefs 
definitions used along the whole ISA implementation
**/

package riscv_defs;

    parameter       NB_WORD     = 32;
    parameter       NB_BYTE     = 8;
    parameter       N_REGISTERS = 32;
    parameter       NB_OPCODE   = 7;
    parameter       NB_OPERAND  = 5;
    
    parameter       NB_FUNCT7   = 7;
    parameter       NB_FUNCT3   = 3;
    parameter       NB_I_IMM    = 12;
    parameter       NB_S_UIMM   = 7;
    parameter       NB_S_LIMM   = 5;

    parameter       NB_B_UUIMM  = 1;
    parameter       NB_B_ULIMM  = 6;
    parameter       NB_B_LUIMM  = 4;
    parameter       NB_B_LLIMM  = 1;

    parameter       NB_U_IMM    = 20;

    parameter       NB_J_UUIMM  = 1;
    parameter       NB_J_ULIMM  = 9;
    parameter       NB_J_LUIMM  = 1;
    parameter       NB_J_LLIMM  = 8;

    parameter       MEM_SIZE    = 65536; //16K words (memories are byte addressed)
    parameter       NB_ADDR     = $clog2(MEM_SIZE);

    typedef struct{
        logic   [NB_WORD - 1 : 0] R[N_REGISTERS - 1 : 0];
    } register_file_t;


    typedef struct packed{
        logic   [NB_FUNCT7  - 1 : 0]    funct7;
        logic   [NB_OPERAND - 1 : 0]    rs2;
        logic   [NB_OPERAND - 1 : 0]    rs1;
        logic   [NB_FUNCT3  - 1 : 0]    funct3;
        logic   [NB_OPERAND - 1 : 0]    rd;
        logic   [NB_OPCODE  - 1 : 0]    opcode;
    } r_type_t;

    typedef struct packed{
        logic   [NB_I_IMM   - 1 : 0]    imm;        
        logic   [NB_OPERAND - 1 : 0]    rs1;
        logic   [NB_FUNCT3  - 1 : 0]    funct3;
        logic   [NB_OPERAND - 1 : 0]    rd;
        logic   [NB_OPCODE  - 1 : 0]    opcode;
    } i_type_t;

    typedef struct packed{
        logic   [NB_S_UIMM  - 1 : 0]    upper_imm;
        logic   [NB_OPERAND - 1 : 0]    rs2;
        logic   [NB_OPERAND - 1 : 0]    rs1;
        logic   [NB_FUNCT3  - 1 : 0]    funct3;
        logic   [NB_S_LIMM  - 1 : 0]    lower_imm;
        logic   [NB_OPCODE  - 1 : 0]    opcode;
    } s_type_t;

    typedef struct packed{
        logic   [NB_B_UUIMM - 1 : 0]    imm12;
        logic   [NB_B_ULIMM - 1 : 0]    imm10_5;
        logic   [NB_OPERAND - 1 : 0]    rs2;
        logic   [NB_OPERAND - 1 : 0]    rs1;
        logic   [NB_FUNCT3  - 1 : 0]    funct3;
        logic   [NB_B_LUIMM - 1 : 0]    imm4_1;
        logic   [NB_B_LLIMM - 1 : 0]    imm11;
        logic   [NB_OPCODE  - 1 : 0]    opcode;
    } b_type_t;

    typedef struct packed{
        logic   [NB_U_IMM   - 1 : 0]    imm;
        logic   [NB_OPERAND - 1 : 0]    rd;
        logic   [NB_OPCODE  - 1 : 0]    opcode;
    } u_type_t;

    typedef struct packed{
        logic   [NB_J_UUIMM - 1 : 0]    imm20;
        logic   [NB_J_ULIMM - 1 : 0]    imm10_1;
        logic   [NB_J_LUIMM - 1 : 0]    imm11;
        logic   [NB_J_LLIMM - 1 : 0]    imm19_12;
        logic   [NB_OPERAND - 1 : 0]    rd;
        logic   [NB_OPCODE  - 1 : 0]    opcode;
    } j_type_t;

    typedef union packed{
        logic   [NB_WORD    - 1 : 0]    instruction;
        r_type_t                        r_type;
        i_type_t                        i_type;
        s_type_t                        s_type;
        b_type_t                        b_type;
        u_type_t                        u_type;
        j_type_t                        j_type;
    } instruction_t;

    typedef struct packed{
        logic                           alu_src1;       //ex stage - selects between pc or rs1
        logic                           alu_src2;       //ex stage - selects between immediate or rs2
        logic   [NB_FUNCT3  - 1 : 0]    alu_op;         //ex stage - controls operation done by ALU
        logic                           arith_logic;    //ex stage - operation is arithmetic or logic
        logic   [NB_OPERAND - 1 : 0]    rd;             //ex stage - destination register
        logic                           dmem_rd;        //mem stage - load instruction
        logic                           dmem_wr;        //mem stage - store instruction
        logic   [NB_FUNCT3  - 1 : 0]    ld_st_funct3;   //mem stage - load/store size
        logic                           rf_wr;          //wb stage  - write to register
        logic                           wb_to_rf;       //wb stage  - write to rf from mem or alu
    } control_bus_t;

    typedef enum logic[NB_OPCODE - 1 : 0]{
        LUI         = 7'b0110111,
        AUIPC       = 7'b0010111,
        JAL         = 7'b1101111,
        JALR        = 7'b1100111,
        BRANCH      = 7'b1100011,
        //BEQ         = 7'b1100011,
        //BNE         = 7'b1100011,
        //BLT         = 7'b1100011,
        //BGE         = 7'b1100011,
        //BLTU        = 7'b1100011,
        //BGEU        = 7'b1100011,
        LOAD        = 7'b0000011,
        //LB          = 7'b0000011,
        //LH          = 7'b0000011,
        //LW          = 7'b0000011,
        //LBU         = 7'b0000011,
        //LHU         = 7'b0000011,
        STORE       = 7'b0100011
        //SB          = 7'b0100011,
        //SH          = 7'b0100011,
        //SW          = 7'b0100011,
        IMMEDIATE   = 7'b0010011,
        //ADDI        = 7'b0010011,
        //SLTI        = 7'b0010011,
        //SLTIU       = 7'b0010011,
        //XORI        = 7'b0010011,
        //ORI         = 7'b0010011,
        //ANDI        = 7'b0010011,
        //SLLI        = 7'b0010011,
        //SRLI        = 7'b0010011,
        //SRAI        = 7'b0010011,
        R_R         =  7'b0110011
        //ADD         = 7'b0110011,
        //SUB         = 7'b0110011,
        //SLL         = 7'b0110011,
        //SLT         = 7'b0110011,
        //SLTU        = 7'b0110011,
        //XOR         = 7'b0110011,
        //SRL         = 7'b0110011,
        //SRA         = 7'b0110011,
        //OR          = 7'b0110011,
        //AND         = 7'b0110011
    } opcodes;

    typedef enum logic[NB_FUNCT3 - 1 : 0]{
        F3_BEQ      = 3'b000,
        F3_BNE      = 3'b001,
        F3_BLT      = 3'b100,
        F3_BGE      = 3'b101,
        F3_BLTU     = 3'b110,
        F3_BGEU     = 3'b111
    } branch_funct3;

    typedef enum logic[NB_FUNCT3 - 1 : 0]{
        F3_LB       = 3'b000,
        F3_LH       = 3'b001,
        F3_LW       = 3'b010,
        F3_LBU      = 3'b100,
        F3_LHU      = 3'b101
    } load_funct3;

    typedef enum logic[NB_FUNCT3 - 1 : 0]{
        F3_SB       = 3'b000,
        F3_SH       = 3'b001,
        F3_SW       = 3'b010
    } store_funct3;

    typedef enum logic[NB_FUNCT3 - 1 : 0]{
        F3_ADDI     = 3'b000,
        F3_SLLI     = 3'b001,
        F3_SLTI     = 3'b010,
        F3_SLTIU    = 3'b011,
        F3_XORI     = 3'b100,
        F3_SRLI_SRAI= 3'b101,        
        F3_ORI      = 3'b110,
        F3_ANDI     = 3'b111        
    } i_funct3;

    typedef enum logic[NB_FUNCT3 - 1 : 0]{
        F3_ADD_SUB  = 3'b000,        
        F3_SLL      = 3'b001,
        F3_SLT      = 3'b010,
        F3_SLTU     = 3'b011,
        F3_XOR      = 3'b100,
        F3_SRL_SRA  = 3'b101,        
        F3_OR       = 3'b110,
        F3_AND      = 3'b111
    
    } r_funct3;

    typedef enum logic[NB_FUNCT3 - 1 : 0]{
        F3_JALR     = 3'b000                
    } funct3;

    typedef enum logic[NB_FUNCT7 - 1 : 0]{
        F7_SLLI     = 7'b0000000,
        F7_SRLI     = 7'b0000000,
        F7_SRAI     = 7'b0100000,
        F7_ADD      = 7'b0000000,
        F7_SUB      = 7'b0100000,
        F7_SLL      = 7'b0000000,
        F7_SLT      = 7'b0000000,
        F7_SLTU     = 7'b0000000,
        F7_XOR      = 7'b0000000,
        F7_SRL      = 7'b0000000,
        F7_SRA      = 7'b0100000,
        F7_OR       = 7'b0000000,
        F7_AND      = 7'b0000000
    } funct7;

endpackage