//------------------------------------------------------------------------------
// processor.sv  —  RV32 Single-Cycle Processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Description:
//   Single cycle RV32I processor. Instantiates: PC, instruction memory,
//   register file, decoder, immediate generator, ALU, data memory, clock
//   wizard, and synchronous reset generator.
//
// Clocking: 100 MHz board clock (clk_100) => MMCM (clk_core) => 75 MHz system clock (clk_sys).
//
// Reset: Reset is active-high at the pin, inverted internally, and synchronously deasserted in sync_reset.
//
// Target: Digilent Arty A7-100T (XC7A100T)
//------------------------------------------------------------------------------
`timescale 1ns / 1ps

module processor import riscv_pkg::*; (
input logic clk_100,
input logic rst,
output logic locked,
output logic out_check // arbitrary output to stop vivado from "optimizing" away the design
);

// -- signal declaration --
logic invert_rst;
logic [31:0] data1_in;
logic [31:0] data2_in;
logic [31:0] wr_data;
logic [1:0] pc_src;


// -- combinational logic --
always_comb begin
    // unrefined rst invert
    invert_rst = ~rst;

    // out check
    out_check = alu_res[0];
    
    // muxes 
    unique case (branch)
        IGNORE_BRANCH: pc_src = pc_src_sel;
        TAKE_BRANCH: pc_src = PCSRC_BRANCH;
    endcase
    
    unique case (wr_src)
        WRSRC_ALU: wr_data = alu_res;
        WRSRC_READ: wr_data = read_data;
        WRSRC_PC: wr_data = pc_plus_4;
    endcase
    
    unique case (alu_src_a)
        ALUSRC1_PC: data1_in = addr;
        ALUSRC1_RS: data1_in = data1;
    endcase
    
    unique case (alu_src_b)
        ALUSRC2_RS: data2_in = data2;
        ALUSRC2_IMM: data2_in = imm;
    endcase
end

// -- module instances -- 

// clock_core
logic clk_sys;

clk_core clock_core (
    .clk(clk_sys),
    .resetn(invert_rst),
    .locked(locked),
    .clk_in1(clk_100)
);

// synchronous reset generator
logic rst_n;

sync_reset sync_reset_inst (
    .clk(clk_sys),
    .invert_rst(invert_rst),
    .locked(locked),
    .rst_n(rst_n)
);

// program counter
logic [31:0] addr;
logic [31:0] pc_plus_4;

pc pc_inst (
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

instruction_memory instruction_memory_inst (
    .addr(addr),
    .instr(instr)
);


// data memory
logic [31:0] read_data;

data_memory data_memory_inst (
    .clk(clk_sys),
    .wr_nrd(mem_rw),
    .size(mem_size),
    .sign(sign),
    .data_in(data2),
    .addr(alu_res),
    .data_out(read_data)
);

// register file 
logic [31:0] data1;
logic [31:0] data2;

register_file register_file_inst (
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
logic reg_write;
logic [1:0] wr_src;
logic [2:0] imm_sel;
logic mem_rw;
logic [1:0] pc_src_sel;
logic [1:0] mem_size;
logic sign;

decoder decoder_inst (
    .instr(instr),
    .branch(branch),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .alu_ctrl(alu_ctrl),
    .alu_src_a(alu_src_a),
    .alu_src_b(alu_src_b),
    .reg_write(reg_write),
    .wr_src(wr_src),
    .imm_sel(imm_sel),
    .mem_rw(mem_rw),
    .pc_src(pc_src_sel),
    .mem_size(mem_size),
    .sign(sign)
);

// alu
logic [31:0] alu_res;
logic branch;

alu alu_inst (
    .alu_ctrl(alu_ctrl),
    .data1(data1_in),
    .data2(data2_in),
    .alu_res(alu_res),
    .branch(branch)
);

// immediate generator
logic [31:0] imm;

imm_gen imm_gen_inst (
    .instr(instr),
    .imm_sel(imm_sel),
    .imm(imm)
);

endmodule // processor
