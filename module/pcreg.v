`timescale 1ns / 1ps
module pcreg(
    input clk,
    input reset,
    input [31:0] pc_in,
    output reg [31:0] pc
    );
    always @(negedge clk or posedge reset)
    begin
        if(reset)
            pc <= 32'h00400000;
        else
            pc <= pc_in;
    end
endmodule
