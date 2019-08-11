`timescale 1ns / 1ps
module cp0(
    input clk,
    input reset,
    input mtc0,
    input [31:0] pc,
    input [4:0] addr,
    input [31:0] wdata,       // data from GP register
    input eret,
    input teq_exc,
    input [3:0] cause,
    output [31:0] rdata,      // data for GP register
    output [31:0] exc_addr
    );
    parameter status_num = 12;
    parameter cause_num  = 13;
    parameter epc_num    = 14;
    parameter SYSCALL = 4'b1000;
    parameter BREAK   = 4'b1001;
    parameter TEQ     = 4'b1101;

    reg [31:0] cp0[32 - 1 : 0];
    integer i;
    
    wire [31:0]status = cp0[status_num]; // status register
    wire exception = (status[0] == 1)&&(
                (status[1] == 1 && cause == SYSCALL)||
                (status[2] == 1 && cause == BREAK)||
                (status[3] == 1 && cause == TEQ && teq_exc == 1)
                );
    assign rdata = cp0[addr];
    assign exc_addr = (eret == 1) ? cp0[epc_num] : 32'h00400004;//DefaultErrAddr
    
    always @(posedge clk or posedge reset)
    begin
        if(reset == 1)
        begin
            for (i = 0; i < 32; i = i + 1)
                cp0[i] <= 0;
        end
        else
        begin
            if(mtc0 == 1)
                cp0[addr] <= wdata;
            else if(exception)
            begin
                cp0[status_num] <= status << 5;
                cp0[cause_num] <= {24'b0, cause, 2'b0};
                cp0[epc_num] <= pc;
            end
            else if(eret == 1)
            begin
                cp0[status_num] <= status >> 5;
            end
        end
    end
endmodule
    