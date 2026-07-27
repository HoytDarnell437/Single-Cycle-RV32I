module alu #(

)(
input logic [3:0] alu_ctrl,
input logic [31:0] data1,
input logic [31:0] data2,
output logic [31:0] alu_res,
output logic branch
);

// -- combinational logic --
always_comb begin
    // default values
    alu_res = 32'b0;
    branch = 1'b0;
    
    // case logic
    unique case (alu_ctrl)
        4'b0000: begin // addition : alu_res = data1 + data2
            alu_res = data1 + data2;
        end
        4'b0001: begin // set less than : alu_res = data1 < data2
            alu_res = ($signed(data1) < $signed(data2)) ? 32'b1 : 32'b0;
        end
        4'b0010: begin // set less than unsigned : alu_res = |data1| < |data2|
            alu_res = (data1 < data2) ? 32'b1 : 32'b0;
        end
        4'b0011: begin // xor : alu_res = data1 ^ data2
            alu_res = data1 ^ data2;
        end
        4'b0100: begin // or : alu_res = data1 | data2
            alu_res = data1 | data2;
        end
        4'b0101: begin // and : alu_res = data1 & data2
            alu_res = data1 & data2;
        end
        4'b0110: begin // logical Left Shift : alu_res = data1 << data2
            alu_res = data1 << data2[4:0];
        end
        4'b0111: begin // logical right shift : alu_res = data1 >> data2
            alu_res = data1 >> data2[4:0];
        end
        4'b1000: begin // arithmetic right shift : alu_res = data1 >>> data2
            alu_res = $signed(data1) >>> data2[4:0];
        end
        4'b1001: begin // subtraction : alu_res = data1 - data2
            alu_res = data1 - data2;
        end
        4'b1010: begin // branch if eq : (data1 == data2) ? pc + imm : pc + 4
            branch = (data1 == data2) ? 1'b1 : 1'b0;
        end
        4'b1011: begin // branch if not eq : (data1 != data2) ? pc + imm : pc + 4
            branch = (data1 != data2) ? 1'b1 : 1'b0;
        end
        4'b1100: begin // branch if less than : (data1 < data2) ? pc + imm : pc + 4
            branch = ($signed(data1) < $signed(data2)) ? 1'b1 : 1'b0;
        end
        4'b1101: begin // branch if greater or eq : (data1 >= data2) ? pc + imm : pc + 4
            branch = ($signed(data1) >= $signed(data2)) ? 1'b1 : 1'b0;
        end
        4'b1110: begin // branch if less than unsigned : (|data1| < |data2|) ? pc + imm : pc + 4
            branch = (data1 < data2) ? 1'b1 : 1'b0;
        end
        4'b1111: begin // branch if greater than or eq unsigned : (|data1| >= |data2|) ? pc + imm : pc + 4
            branch = (data1 >= data2) ? 1'b1 : 1'b0;
        end
    endcase
end

endmodule
