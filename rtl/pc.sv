module pc #(

)(
input logic clk,
input logic rst_n,
input logic [1:0] pc_src,
input logic [31:0] imm,
input logic [31:0] alu_res,
output logic [31:0] addr,
output logic [31:0] pc_plus_4
);

// -- signal declaration --
logic [31:0] pc_plus_imm;
logic [31:0] next_addr;

// -- combinational logic --
always_comb begin
    pc_plus_4 = addr + 4;
    pc_plus_imm = addr + imm;
    next_addr = 0;
    unique case (pc_src)
            // normal increment
            2'b00: next_addr = pc_plus_4;
            // add immediate
            2'b01: next_addr = pc_plus_imm;
            // jump to alu_res
            2'b10: next_addr = alu_res;
    endcase
end

// -- sequential logic --
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr <= 32'b0;
    end else begin
        addr <= next_addr;
    end
end

endmodule
