`timescale 1ns / 1ps
module alu(
    input [3:0] aluc,
    input [31:0] a,
    input [31:0] b,
    output [31:0] r/*,
    output zero,
    output carry,
    output negative,
    output overflow*/
    );
    parameter Addu   =    4'b0000;    //r=a+b unsigned
    parameter Add    =    4'b0010;    //r=a+b signed
    parameter Subu   =    4'b0001;    //r=a-b unsigned
    parameter Sub    =    4'b0011;    //r=a-b signed
    parameter And    =    4'b0100;    //r=a&b
    parameter Or     =    4'b0101;    //r=a|b
    parameter Xor    =    4'b0110;    //r=a^b
    parameter Nor    =    4'b0111;    //r=~(a|b)
    // parameter Lui1   =    4'b1000;    //r={b[15:0],16'b0}
    // parameter Lui2   =    4'b1001;    //r={b[15:0],16'b0}
    parameter Lui    =    4'b1000;
    parameter Slt    =    4'b1011;    //r=(a-b<0)?1:0 signed
    parameter Sltu   =    4'b1010;    //r=(a-b<0)?1:0 unsigned
    parameter Sra    =    4'b1100;    //r=b>>>a 
    parameter Sll    =    4'b1111;    //r=b<<a
    parameter Srl    =    4'b1101;    //r=b>>a
    
    wire signed [31:0] sa = a;
    wire signed [31:0] sb = b;
    reg [32:0] sr;
    
    always @(a or b or aluc)
    begin
        case (aluc)
            Addu: begin sr <= a + b; end
            Add:  begin sr <= sa + sb; end
            Subu: begin sr <= a - b; end
            Sub:  begin sr <= sa - sb; end
            And:  begin sr <= a & b; end
            Or:   begin sr <= a | b; end
            Xor:  begin sr <= a ^ b; end
            Nor:  begin sr <= ~(a | b); end
            Sltu: begin sr <= a < b ?1: 0; end
            Slt:  begin sr <= sa < sb ? 1 :0; end
            Lui:  begin sr <= {1'b0,b[15:0], 16'b0}; end
            Sra:begin
                if(a ==0)
                    {sr[31:0], sr[32]} <= {sb, 1'b0};
                else
                    {sr[31:0], sr[32]} <= sb >>> (a-1);
            end 
            Srl: begin 
                if(a == 0)
                    {sr[31:0], sr[32]} <= {b, 1'b0};
                else 
                    {sr[31:0], sr[32]} <= b >> (a - 1);
            end
            Sll: begin sr <= b << a; end
            default: sr <= 0;
        endcase
    end
    assign r = sr[31:0];
endmodule
