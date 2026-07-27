module imm_gen #(
    localparam OUTPUT_WIDTH = 32,
    localparam INPUT_WIDTH = 12,
    localparam EXTEND_WIDTH = OUTPUT_WIDTH - INPUT_WIDTH
)(
input logic [31:0] instr,
input logic [2:0] imm_sel,
input logic i_shift,
output logic [31:0] imm
);

always_comb begin
    case (imm_sel)
        // I-type instruction not shift
        3'b000: imm = { {20{instr[31]}} , instr[31:20] };
        // S-type instruction
        3'b001: imm = { {20{instr[31]}} , instr[31:25] , instr[11:7] };
        // B-type instruction
        3'b010: imm = { {19{instr[31]}} , instr[31] ,instr[7] , instr[30:25] , instr[11:8] , 1'b0};
        // U-type instruction
        3'b011: imm = { instr[31:12] , 12'b0 };
        // J-type instruction
        3'b100: imm = { {12{instr[31]}} , instr[19:12] , instr[20] , instr[30:21] , 1'b0 };
        // I-type instruction shift
        3'b101: imm = { 17'b0 , instr[24:20] };
        // else
        default: imm = 32'b0;
    endcase
end

endmodule
