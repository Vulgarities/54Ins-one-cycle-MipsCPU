`timescale 1ns / 1ps
module zero_num(
    input [31:0] data,
    output reg [31:0] zero_num
    );
    always @ (*) begin
        casex (data)
            32'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h00;
            32'b01xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h01;
            32'b001xxxxxxxxxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h02;
            32'b0001xxxxxxxxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h03;
            32'b00001xxxxxxxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h04;
            32'b000001xxxxxxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h05;
            32'b0000001xxxxxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h06;
            32'b00000001xxxxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h07;
            32'b000000001xxxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h08;
            32'b0000000001xxxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h09;
            32'b00000000001xxxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h0a;
            32'b000000000001xxxxxxxxxxxxxxxxxxxx: zero_num <= 32'h0b;
            32'b0000000000001xxxxxxxxxxxxxxxxxxx: zero_num <= 32'h0c;
            32'b00000000000001xxxxxxxxxxxxxxxxxx: zero_num <= 32'h0d;
            32'b000000000000001xxxxxxxxxxxxxxxxx: zero_num <= 32'h0e;
            32'b0000000000000001xxxxxxxxxxxxxxxx: zero_num <= 32'h0f;
            32'b00000000000000001xxxxxxxxxxxxxxx: zero_num <= 32'h10;
            32'b000000000000000001xxxxxxxxxxxxxx: zero_num <= 32'h11;
            32'b0000000000000000001xxxxxxxxxxxxx: zero_num <= 32'h12;
            32'b00000000000000000001xxxxxxxxxxxx: zero_num <= 32'h13;
            32'b000000000000000000001xxxxxxxxxxx: zero_num <= 32'h14;
            32'b0000000000000000000001xxxxxxxxxx: zero_num <= 32'h15;
            32'b00000000000000000000001xxxxxxxxx: zero_num <= 32'h16;
            32'b000000000000000000000001xxxxxxxx: zero_num <= 32'h17;
            32'b0000000000000000000000001xxxxxxx: zero_num <= 32'h18;
            32'b00000000000000000000000001xxxxxx: zero_num <= 32'h19;
            32'b000000000000000000000000001xxxxx: zero_num <= 32'h1a;
            32'b0000000000000000000000000001xxxx: zero_num <= 32'h1b;
            32'b00000000000000000000000000001xxx: zero_num <= 32'h1c;
            32'b000000000000000000000000000001xx: zero_num <= 32'h1d;
            32'b0000000000000000000000000000001x: zero_num <= 32'h1e;
            32'b00000000000000000000000000000001: zero_num <= 32'h1f;
            32'b00000000000000000000000000000000: zero_num <= 32'h20;
        endcase
    end
endmodule
