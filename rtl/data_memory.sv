//------------------------------------------------------------------------------
// data_memory.sv  —  Data memory for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: Read is combinational and write is synchonous
//------------------------------------------------------------------------------
module data_memory import riscv_pkg::*; #(
localparam MEM_SIZE = 128
)(
input logic clk,
input logic wr_nrd,
input logic [1:0] size,
input logic sign,
input logic [31:0] data_in,
input logic [31:0] addr,
output logic [31:0] data_out
);

// -- signal declaration --
logic [31:0] ram [0:MEM_SIZE-1];
logic [31:0] out_word;

// -- include initial data --
initial begin
    $readmemh("data.hex", ram);
end

// -- combinational logic --
always_comb begin
    data_out = 32'b0;
    out_word = 32'b0;
    if (!wr_nrd) begin // read
        out_word = ram[addr[31:2]];
        unique case (size) 
            SIZE_B: begin
                if (sign) begin
                    unique case (addr[1:0])
                        FIRST_BYTE: data_out = { {24{out_word[7]}} , out_word[7:0] };
                        SECOND_BYTE: data_out = { {24{out_word[15]}} , out_word[15:8] };
                        THIRD_BYTE: data_out = { {24{out_word[23]}} , out_word[23:16] };
                        FOURTH_BYTE: data_out = { {24{out_word[31]}} , out_word[31:24] };
                    endcase
                end else begin
                    unique case (addr[1:0])
                        FIRST_BYTE: data_out = { 24'b0 , out_word[7:0] };
                        SECOND_BYTE: data_out = { 24'b0 , out_word[15:8] };
                        THIRD_BYTE: data_out = { 24'b0 , out_word[23:16] };
                        FOURTH_BYTE: data_out = { 24'b0 , out_word[31:24] };
                    endcase
                end
            end
            SIZE_H: begin
                if (sign) begin
                    unique case (addr[1])
                        FIRST_HALF: data_out = { {16{out_word[15]}} , out_word[15:0] };
                        SECOND_HALF: data_out = { {16{out_word[31]}} , out_word[31:16] };
                    endcase
                end else begin
                    unique case (addr[1])
                        FIRST_HALF: data_out = { 16'b0 , out_word[15:0] };
                        SECOND_HALF: data_out = { 16'b0 , out_word[31:16] };
                    endcase
                end
            end
            SIZE_W: begin
                data_out = out_word;
            end
        endcase
    end
end

// -- sequential logic --
always_ff @(posedge clk) begin
    if (wr_nrd) begin // write
        unique case (size) 
            SIZE_B: begin 
                unique case (addr[1:0])
                    FIRST_BYTE: ram[addr[31:2]][7:0] <= data_in[7:0];
                    SECOND_BYTE: ram[addr[31:2]][15:8] <= data_in[7:0];
                    THIRD_BYTE: ram[addr[31:2]][23:16] <= data_in[7:0];
                    FOURTH_BYTE: ram[addr[31:2]][31:24] <= data_in[7:0];
                endcase
            end
            SIZE_H: begin
                unique case (addr[1])
                    FIRST_HALF: ram[addr[31:2]][15:0] <= data_in[15:0];
                    SECOND_HALF: ram[addr[31:2]][31:16] <= data_in[15:0];
                endcase
            end
            SIZE_W: begin
                ram[addr[31:2]] <= data_in;
            end
        endcase
    end
end

endmodule // data_memory
