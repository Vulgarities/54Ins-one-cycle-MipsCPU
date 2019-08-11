`timescale 1ns / 1ps
module md_hilo(
    input clk,
    input reset,
    input [2:0] mdc,
    input [31:0] a,
    input [31:0] b,
    output /*reg*/ [63:0] mul_result,
    output reg [31:0] hi,
    output reg [31:0] lo
    );
    parameter multu = 3'h2;
    parameter div   = 3'h3;
    parameter divu  = 3'h4;
    parameter mthi  = 3'h5;
    parameter mtlo  = 3'h6;

    wire signed [31:0] sa=a,sb=b;
    assign mul_result = a*b;
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            hi <= 0;
            lo <= 0;
        end
        else
        begin
            //mul_result <= a*b;
            case(mdc)
                multu: begin 
                    {hi, lo} <= a*b; 
                    end
                div: begin     
                    lo <= sa/sb;
                    hi <= sa%sb;
                    end
                divu: begin
                    lo <= a/b;
                    hi <= a%b;
                    end
                mthi: hi <= a;
                mtlo: lo <= a;
            endcase
        end
    end
endmodule
