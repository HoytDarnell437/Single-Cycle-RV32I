`timescale 1ns/1ps 

module processor_tb;

    logic clk, rst, out;    

    processor processor_inst (
        .clk_100(clk),
        .rst(rst),
        .out_check(out)
    );

    always #5 clk = !clk;

    initial begin
        clk = 0;
        rst = 1;

        #50;

        rst = 0;

        repeat (300) @(posedge clk);

        $finish;
    end

endmodule // processor_tb
