module data_memory #(
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

// -- combinational logic --
always_comb begin
    data_out = 32'b0;
    out_word = 32'b0;
    if (!wr_nrd) begin // read
        out_word = ram[addr[31:2]];
        unique case (size) 
            // byte
            2'b00: begin
                if (sign) begin // signed
                    unique case (addr[1:0])
                        // first byte
                        2'b00: data_out = { {24{out_word[7]}} , out_word[7:0] };
                        // second byte
                        2'b01: data_out = { {24{out_word[15]}} , out_word[15:8] };
                        // third byte
                        2'b10: data_out = { {24{out_word[23]}} , out_word[23:16] };
                        // fourth byte
                        2'b11: data_out = { {24{out_word[31]}} , out_word[31:24] };
                    endcase
                end else begin // unsigned
                    unique case (addr[1:0])
                        // first byte
                        2'b00: data_out = { 24'b0 , out_word[7:0] };
                        // second byte
                        2'b01: data_out = { 24'b0 , out_word[15:8] };
                        // third byte
                        2'b10: data_out = { 24'b0 , out_word[23:16] };
                        // fourth byte
                        2'b11: data_out = { 24'b0 , out_word[31:24] };
                    endcase
                end
            end
            // half
            2'b01: begin
                if (sign) begin
                    unique case (addr[1])
                        // lower half
                        1'b0: data_out = { {16{out_word[15]}} , out_word[15:0] };
                        // upper half
                        1'b1: data_out = { {16{out_word[31]}} , out_word[31:16] };
                    endcase
                end else begin
                    unique case (addr[1])
                        // lower half
                        1'b0: data_out = { 16'b0 , out_word[15:0] };
                        // upper half
                        1'b1: data_out = { 16'b0 , out_word[31:16] };
                    endcase
                end
            end
            // whole
            2'b10: begin
                data_out = out_word;
            end
        endcase
    end
end

// -- sequential logic --
always_ff @(posedge clk) begin
    if (wr_nrd) begin // write
        unique case (size) 
            // byte
            2'b00: begin 
                unique case (addr[1:0])
                    // first byte
                    2'b00: ram[addr[31:2]][7:0] <= data_in[7:0];
                    // second byte
                    2'b01: ram[addr[31:2]][15:8] <= data_in[7:0];
                    // third byte
                    2'b10: ram[addr[31:2]][23:16] <= data_in[7:0];
                    // fourth byte
                    2'b11: ram[addr[31:2]][31:24] <= data_in[7:0];
                endcase
            end
            // half
            2'b01: begin
                unique case (addr[1])
                    // lower half
                    1'b0: ram[addr[31:2]][15:0] <= data_in[15:0];
                    // upper half
                    1'b1: ram[addr[31:2]][31:16] <= data_in[15:0];
                endcase
            end
            // whole
            2'b10: begin
                ram[addr[31:2]] <= data_in;
            end
        endcase
    end
end

endmodule