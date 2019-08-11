`timescale 1ns / 1ps
module cpu(
    input clk_in,
    input reset,
    input [31:0] inst,
    output [31:0] pc,
    input  [31:0] dm_rdata,
    output [31:0] dm_addr,
    output [31:0] dm_wdata,
    output dm_wena,
    
    output [3 :0] aluc,
    output [31:0] alu_a, alu_b, alu_result,

    output rf_w,
    output [4 :0] rf_waddr,
    output [31:0] rf_rdata1, rf_rdata2, rf_wdata,
    
    
    output [2 :0] mdc,
    output [63:0] mul_result,
    output [31:0] hi, lo,
    output [31:0] zero_num
    );    
    wire [31:0] pc_next;

    // wire [3 :0] aluc;
    // wire [31:0] alu_a, alu_b, alu_result;

    // wire rf_w;
    // wire [4 :0] rf_waddr;
    // wire [31:0] rf_rdata1, rf_rdata2, rf_wdata;
    
    wire [31:0] cp0_rdata;
    wire [31:0] exc_addr;
    wire [3 :0] cause;
    wire mtc0, eret, teq_exc;
    
    // wire [2 :0] mdc;
    // wire [63:0] mul_result;
    // wire [31:0] hi, lo;
    // wire [31:0] zero_num;

    pcreg cpu_pc (
        .clk(clk_in), .reset(reset),
        .pc_in(pc_next),.pc(pc)
        );
    
    zero_num counter(.data(rf_rdata1),.zero_num(zero_num));

    controller cpu_control (
        .inst(inst), .pc(pc),.npc(pc+4),.pc_next(pc_next),
        
        .alu_result(alu_result),.aluc(aluc), .alu_a(alu_a), .alu_b(alu_b),

        .rf_w(rf_w), .rf_waddr(rf_waddr), .rf_wdata(rf_wdata),
        .rf_rdata1(rf_rdata1), .rf_rdata2(rf_rdata2),
        
        .dm_rdata(dm_rdata),.dm_addr(dm_addr),.dm_wdata(dm_wdata),
        .dm_wena(dm_wena),

        .cp0_rdata(cp0_rdata),.exc_addr(exc_addr),
        .mtc0(mtc0), .eret(eret), .teq_exc(teq_exc),.cause(cause),

        .mul_result(mul_result[31:0]),.hi(hi), .lo(lo),.mdc(mdc),
        .zero_num(zero_num)
    );
    
    cp0 cpu_cp0 (
        .clk(clk_in), .reset(reset),
        .mtc0(mtc0),
        .pc(pc), 
        .addr(inst[15:11]),/*rd*/  .wdata(rf_rdata2),
        .eret(eret), .teq_exc(teq_exc), .cause(cause),
        .rdata(cp0_rdata), .exc_addr(exc_addr)
        );
    
    regfile cpu_ref (
        .clk(clk_in), .reset(reset),
        .rf_w(rf_w), .waddr(rf_waddr), .wdata(rf_wdata),
        .raddr1(inst[25:21]), .raddr2(inst[20:16]),
        .rdata1(rf_rdata1),.rdata2(rf_rdata2)
        );
    
    alu cpu_alu (.aluc(aluc), .a(alu_a), .b(alu_b),.r(alu_result));
                  
    md_hilo cpu_muldiv(
        .clk(clk_in), .reset(reset),
        .mdc(mdc),.a(rf_rdata1), .b(rf_rdata2),.mul_result(mul_result),
        .hi(hi), .lo(lo));
endmodule
