`timescale 1ns / 1ps
module ram(
    input clk,
    input wena,
    input [31:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
    );
    reg [31:0] memory [0:1023];
    assign data_out = memory[addr];
    
    always @(posedge clk)
    begin
        if(wena)
            memory[addr] <= data_in;
    end
endmodule
