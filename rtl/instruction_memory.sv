module instruction_memory #(
localparam INSTRUCTION_COUNT = 1024
)(
input logic [31:0] addr,
output logic [31:0] instr
);

// -- signal declaration --
logic [31:0] rom [0:INSTRUCTION_COUNT-1];

// -- combinational logic --
assign instr = rom[addr[31:2]];

// -- include machine code --
initial begin
    $readmemh("code.hex", rom);
end

endmodule
