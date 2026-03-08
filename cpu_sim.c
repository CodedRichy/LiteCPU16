#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

#define MEM_SIZE 256
#define NUM_REGS 16

// Opcodes corresponding to menu choices
#define OP_ADD  1
#define OP_ADDI 2
#define OP_SUB  3
#define OP_AND  4
#define OP_OR   5
#define OP_EXIT 6

// Internal ALU Operation Codes
#define ALU_ADD 0
#define ALU_SUB 1
#define ALU_AND 2
#define ALU_OR  3

// CPU State Structure
typedef struct {
    uint16_t pc;
    uint16_t regs[NUM_REGS];
    uint16_t memory[MEM_SIZE];
    
    // Control Signals
    bool regwrite, memwrite, alusrc, memtoreg, branch;
    uint8_t aluop;
} CPU;

// Control Unit: Sets control signals based on opcode
void control_unit(CPU *cpu, uint8_t opcode) {
    // Default all signals to 0
    cpu->regwrite = 0;
    cpu->memwrite = 0;
    cpu->alusrc   = 0;
    cpu->memtoreg = 0;
    cpu->branch   = 0;
    cpu->aluop    = 0;
    
    switch(opcode) {
        case OP_ADD:  
            cpu->regwrite = 1; 
            cpu->aluop = ALU_ADD; 
            break;
        case OP_SUB:  
            cpu->regwrite = 1; 
            cpu->aluop = ALU_SUB; 
            break;
        case OP_AND:  
            cpu->regwrite = 1; 
            cpu->aluop = ALU_AND; 
            break;
        case OP_OR:   
            cpu->regwrite = 1; 
            cpu->aluop = ALU_OR;  
            break;
        case OP_ADDI: 
            cpu->regwrite = 1; 
            cpu->alusrc = 1; // Use immediate value instead of register
            cpu->aluop = ALU_ADD; 
            break;
        default:
            break;
    }
}

// ALU: Performs arithmetic/logic operations and sets zero flag
uint16_t alu(uint16_t a, uint16_t b, uint8_t aluop, bool *zero_flag) {
    uint16_t result = 0;
    switch(aluop) {
        case ALU_ADD: result = a + b; break;
        case ALU_SUB: result = a - b; break;
        case ALU_AND: result = a & b; break;
        case ALU_OR:  result = a | b; break;
    }
    *zero_flag = (result == 0);
    return result;
}

// Utility function to print the current state of the CPU
void display_state(CPU *cpu) {
    printf("\n========================================\n");
    printf("              CPU STATE\n");
    printf("========================================\n");
    printf("PC: %04d\n", cpu->pc);
    printf("Registers:\n");
    printf("R0 : %04d | R1 : %04d | R2 : %04d | R3 : %04d\n", 
            cpu->regs[0], cpu->regs[1], cpu->regs[2], cpu->regs[3]);
    printf("R4 : %04d | R5 : %04d | R6 : %04d | R7 : %04d\n", 
            cpu->regs[4], cpu->regs[5], cpu->regs[6], cpu->regs[7]);
    printf("----------------------------------------\n");
}

int main() {
    CPU cpu = {0}; // Initialize CPU state to 0
    int choice;
    
    printf("Single Cycle Processor Interactive Simulation\n");
    
    while(1) {
        display_state(&cpu);
        
        printf("\nSelect Instruction:\n");
        printf("1. ADD  (rd = rs1 + rs2)\n");
        printf("2. ADDI (rd = rs1 + imm)\n");
        printf("3. SUB  (rd = rs1 - rs2)\n");
        printf("4. AND  (rd = rs1 & rs2)\n");
        printf("5. OR   (rd = rs1 | rs2)\n");
        printf("6. EXIT\n");
        printf("Choice: ");
        
        if (scanf("%d", &choice) != 1) {
            printf("Invalid input. Exiting...\n");
            break;
        }
        
        uint8_t opcode = choice;
        if(opcode == OP_EXIT) {
            printf("Exiting simulation...\n");
            break;
        }
        
        if (opcode < 1 || opcode > 5) {
            printf("Invalid choice. Please try again.\n");
            continue;
        }

        // --- INSTRUCTION FETCH / DECODE (Interactive) ---
        uint16_t rd = 0, rs1 = 0, rs2 = 0, imm = 0;
        
        printf("Enter Destination Register index (rd) [0-15]: ");
        scanf("%hd", &rd);
        
        printf("Enter Source Register 1 index (rs1) [0-15]: ");
        scanf("%hd", &rs1);
        
        if (opcode == OP_ADDI) {
            printf("Enter Immediate value: ");
            scanf("%hd", &imm);
            printf("\n=> Instruction: ADDI R%d, R%d, %d\n", rd, rs1, imm);
        } else {
            printf("Enter Source Register 2 index (rs2) [0-15]: ");
            scanf("%hd", &rs2);
            
            const char* op_name = "";
            switch(opcode) {
                case OP_ADD: op_name = "ADD"; break;
                case OP_SUB: op_name = "SUB"; break;
                case OP_AND: op_name = "AND"; break;
                case OP_OR:  op_name = "OR"; break;
            }
            printf("\n=> Instruction: %s R%d, R%d, R%d\n", op_name, rd, rs1, rs2);
        }

        // Validate register bounds
        if (rd >= NUM_REGS || rs1 >= NUM_REGS || rs2 >= NUM_REGS) {
            printf("Error: Register index out of bounds. Must be 0-15. Aborting instruction.\n");
            continue;
        }

        // --- EXECUTION PHASE ---
        
        // 1. Run Control Unit
        control_unit(&cpu, opcode);
        
        // 2. Register Read (Fetch Operands)
        uint16_t val1 = cpu.regs[rs1];
        uint16_t val2 = cpu.regs[rs2];
        
        // 3. ALU Source Mux (Selects between rs2 or immediate)
        uint16_t alu_b = cpu.alusrc ? imm : val2;
        
        // 4. Execute ALU
        bool zero_flag = false;
        uint16_t alu_result = alu(val1, alu_b, cpu.aluop, &zero_flag);
        
        // 5. Writeback (Register File)
        if (cpu.regwrite) {
            if (rd != 0) { // Enforce Register 0 is hardwired to 0
                cpu.regs[rd] = alu_result;
                printf(">> Action: Wrote value %d to R%d\n", alu_result, rd);
            } else {
                printf(">> Action: Attempted write to R0 ignored (hardwired to 0).\n");
            }
        }
        
        // 6. PC Update
        cpu.pc++;
        
        // Clear input buffer for cleanliness
        int c;
        while ((c = getchar()) != '\n' && c != EOF);
    }

    printf("CPU Halted.\n");
    return 0;
}
