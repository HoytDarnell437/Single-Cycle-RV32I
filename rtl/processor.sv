`timescale 1ns / 1ps

module processor #(

)(
input logic clk_100,
input logic rst,
output logic [31:0] out_check
);

// -- signal declaration --
logic rst_n;
logic [31:0] data1_in;
logic [31:0] data2_in;
logic [31:0] wr_data;
logic [1:0] pc_src;


// -- combinational logic --
always_comb begin
    // invert rst
    rst_n = ~rst & locked;
    
    // out check
    out_check = alu_res;
    
    // logic 
    unique case (branch)
        1'b0: pc_src = pc_src_sel;
        1'b1: pc_src = 2'b01;
    endcase
    
    unique case (wr_src)
        2'b00: wr_data = alu_res;
        2'b01: wr_data = read_data;
        2'b10: wr_data = pc_plus_4;
    endcase
    
    unique case (alu_src_a)
        1'b0: data1_in = addr;
        1'b1: data1_in = data1;
    endcase
    
    unique case (alu_src_b)
        1'b0: data2_in = data2;
        1'b1: data2_in = imm;
    endcase
end

// -- module instances -- 

// clock_core
logic clk_sys;
logic locked;

clk_core clock_core (
    .clk(clk_sys),
    .resetn(~rst),
    .locked(locked),
    .clk_in1(clk_100)
);

// program counter
logic [31:0] addr;
logic [31:0] pc_plus_4;

pc #() pc_inst (
    .clk(clk_sys),
    .rst_n(rst_n),
    .pc_src(pc_src),
    .imm(imm),
    .alu_res(alu_res),
    .addr(addr),
    .pc_plus_4(pc_plus_4)
);

// instruction memory
logic [31:0] instr;

instruction_memory #() instruction_memory_inst (
    .addr(addr),
    .instr(instr)
);


// data memory
logic [31:0] read_data;

data_memory #() data_memory_inst (
    .clk(clk_sys),
    .wr_nrd(mem_rw),
    .size(addr_precision),
    .sign(sign),
    .data_in(data2),
    .addr(alu_res),
    .data_out(read_data)
);

// register file 
logic [31:0] data1;
logic [31:0] data2;

register_file #() register_file_inst (
    .clk(clk_sys),
    .rst_n(rst_n),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wr_data(wr_data),
    .reg_write(reg_write),
    .data1(data1),
    .data2(data2)
);

// decoder
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;
logic [3:0] alu_ctrl;
logic alu_src_a;
logic alu_src_b;
logic i_shift;
logic reg_write;
logic [1:0] wr_src;
logic [2:0] imm_sel;
logic mem_rw;
logic [1:0] pc_src_sel;
logic [1:0] addr_precision;
logic sign;

decoder #() decoder_inst (
    .instr(instr),
    .branch(branch),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .alu_ctrl(alu_ctrl),
    .alu_src_a(alu_src_a),
    .alu_src_b(alu_src_b),
    .i_shift(i_shift),
    .reg_write(reg_write),
    .wr_src(wr_src),
    .imm_sel(imm_sel),
    .mem_rw(mem_rw),
    .pc_src(pc_src_sel),
    .addr_precision(addr_precision),
    .sign(sign)
);

// alu
logic [31:0] alu_res;
logic branch;

alu #() alu_inst (
    .alu_ctrl(alu_ctrl),
    .data1(data1_in),
    .data2(data2_in),
    .alu_res(alu_res),
    .branch(branch)
);

// immediate generator
logic [31:0] imm;

imm_gen #() imm_gen_inst (
    .instr(instr),
    .imm_sel(imm_sel),
    .i_shift(i_shift),
    .imm(imm)
);
endmodule
