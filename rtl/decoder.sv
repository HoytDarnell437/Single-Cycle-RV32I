module decoder #(

)(
input logic [31:0] instr,
input logic branch,
output logic [4:0] rs1,
output logic [4:0] rs2,
output logic [4:0] rd,
output logic [3:0] alu_ctrl,
output logic alu_src_a,
output logic alu_src_b,
output logic i_shift,
output logic reg_write,
output logic [1:0] wr_src,
output logic [2:0] imm_sel,
output logic mem_rw,
output logic [1:0] pc_src,
output logic [1:0] addr_precision,
output logic sign
);
// signal declaration
logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
// combinational logic
always_comb begin
    // default values
    rs1 = instr[19:15];
    rs2 = instr[24:20];
    rd = instr[11:7];
    alu_ctrl = 4'b0000;
    alu_src_a = 1'b1;
    alu_src_b = 1'b1;
    i_shift = 1'b0;
    reg_write = 1'b1;
    wr_src = 2'b00;
    imm_sel = 3'b000;
    mem_rw = 1'b0;
    pc_src = 2'b00;
    addr_precision = 2'b00;
    sign = 1'b1;
    
    // Operation Specifiers
    opcode = instr[6:0];
    funct3 = instr[14:12];
    funct7 = instr[31:25];
    
    unique case (opcode)
    // I-Type Instructions
        // ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI
        7'b0010011: begin
            imm_sel = 3'b000;
            case (funct3)
                // ADDI
                3'b000: begin
                end
                // SLTI
                3'b010: begin
                    alu_ctrl = 4'b0001;
                end
                // SLTIU
                3'b011: begin
                    alu_ctrl = 4'b0010;
                end
                // XORI
                3'b100: begin
                    alu_ctrl = 4'b0011;
                end
                // ORI
                3'b110: begin
                    alu_ctrl = 4'b0100;
                end
                // ANDI
                3'b111: begin
                    alu_ctrl = 4'b0101;
                end
                // SLLI
                3'b001: begin
                    alu_ctrl = 4'b0110;
                    imm_sel = 3'b101;
                    i_shift = 1'b1;
                end
                // SRLI SRAI
                3'b101: begin
                    imm_sel = 3'b101;
                    i_shift = 1'b1;
                    // SRLI
                    if (!instr[30]) begin
                        alu_ctrl = 4'b0111;
                    end 
                    // SRAI
                    else begin
                        alu_ctrl = 4'b1000;
                    end
                end
            endcase
        end
        // JALR
        7'b1100111: begin
            imm_sel = 3'b000;
            pc_src = 2'b10;
            wr_src = 2'b10;
        end
        // FENCE
        7'b0001111: begin
            imm_sel = 3'b000;
            reg_write = 1'b0;
        end
        // ECALL EBREAK
        7'b1110011: begin
            imm_sel = 3'b000;
            reg_write = 1'b0;
            // ECALL
            if (!instr[20]) begin
            end
            // EBREAK
            else begin
            end
        end
        // LB LH LW LBU LHU
        7'b0000011: begin
            imm_sel = 3'b000;
            wr_src = 2'b01;
            case (funct3)
                // LB
                3'b000: begin
                end
                // LH
                3'b001: begin
                    addr_precision = 2'b01;
                end
                // LW
                3'b010: begin
                    addr_precision = 2'b10;
                end
                // LBU
                3'b100: begin
                    sign = 1'b0;
                end
                // LHU
                3'b101: begin
                    addr_precision = 2'b01;
                    sign = 1'b0;
                end
            endcase
        end
    // R-Type Instructions
        // ADD SUB SLL SLT SLTU XOR SRL SRA OR AND
        7'b0110011: begin
            alu_src_b = 1'b0;
            case (funct3)
                // ADD SUB
                3'b000: begin
                    // ADD
                    if (!instr[30]) begin
                    end
                    // SUB
                    else begin
                        alu_ctrl = 4'b1001;
                    end
                end
                // SLL
                3'b001: begin
                    alu_ctrl = 4'b0110;
                end
                // SLT
                3'b010: begin
                    alu_ctrl = 4'b0001;
                end
                // SLTU
                3'b011: begin
                    alu_ctrl = 4'b0010;
                end
                // XOR
                3'b100: begin
                    alu_ctrl = 4'b0011;
                end
                // SRL SRA
                3'b101: begin
                    // SRL
                    if (!instr[30]) begin
                        alu_ctrl = 4'b0111;
                    end
                    // SRA
                    else begin
                        alu_ctrl = 4'b1000;
                    end
                end
                // OR
                3'b110: begin
                     alu_ctrl = 4'b0100;
                end
                // AND
                3'b111: begin
                    alu_ctrl = 4'b0101;
                end
            endcase
        end
    // B-Type Instructions    
        // BEQ BNE BLT BGE BLTU BGEU
        7'b1100011: begin
            alu_src_b = 1'b0;
            imm_sel = 3'b010;
            reg_write = 1'b0;
            pc_src = 2'b00;
            case (funct3)
                // BEQ
                3'b000: begin
                    alu_ctrl = 4'b1010;
                end
                // BNE
                3'b001: begin
                    alu_ctrl = 4'b1011;
                end
                // BLT
                3'b100: begin
                    alu_ctrl = 4'b1100;
                end
                // BGE
                3'b101: begin
                    alu_ctrl = 4'b1101;
                end
                // BLTU
                3'b110: begin
                    alu_ctrl = 4'b1110;
                end
                // BGEU
                3'b111: begin
                    alu_ctrl = 4'b1111;
                end
            endcase
        end
    // S-Type Instructions
        // SB SH SW
        7'b0100011: begin
            imm_sel = 3'b001;
            reg_write = 1'b0;
            mem_rw = 1'b1;
            case (funct3)
                // SB
                3'b000: begin
                end
                // SH
                3'b001: begin
                    addr_precision = 2'b01;
                end
                // SW
                3'b010: begin
                    addr_precision = 2'b10;
                end
            endcase
        end
    // U-Type Instructions
        // LUI
        7'b0110111: begin
            imm_sel = 3'b011;
            rs1 = 5'b00000;
        end 
        // AUIPC
        7'b0010111: begin
            imm_sel = 3'b011;
            alu_src_a = 1'b0;
        end
    // J-Type Instructions
        // JAL
        7'b1101111: begin
            imm_sel = 3'b100;
            alu_src_a = 1'b0;
            pc_src = 2'b01;
            wr_src = 2'b10;
        end
    endcase
end

endmodule
