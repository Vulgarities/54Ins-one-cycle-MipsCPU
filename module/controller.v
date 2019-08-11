`timescale 1ns / 1ps          
module controller(
    input  [31:0] inst,
    input  [31:0] pc,
    input  [31:0] npc,
    output reg [31:0] pc_next,
    //alu
    input  [31:0] alu_result,
    output reg [3 :0] aluc,
    output reg [31:0] alu_a,
    output reg [31:0] alu_b,
    //regfile
    output reg rf_w,
    output [4 :0] rf_waddr,
    output reg [31:0] rf_wdata,
    input  [31:0] rf_rdata1,
    input  [31:0] rf_rdata2,
    //dmem
    input  [31:0] dm_rdata,
    output [31:0] dm_addr,
    output reg [31:0] dm_wdata,
    output dm_wena,
    //cp0
    input [31:0] cp0_rdata,
    input [31:0] exc_addr,
    output mtc0,
    output eret,
    output teq_exc,
    output reg [3:0] cause,
    //muldiv
    input [31:0] mul_result,
    input [31:0] hi,
    input [31:0] lo,
    output reg [2:0] mdc,
    //
    input [31:0]zero_num
    );
    wire [4:0] rs,rt,rd;
    wire [5:0] op     =  inst[31:26];
    wire [5:0] func   =  inst[5 : 0];
    wire [25:0] addr  =  inst[25 :0];
    wire [31:0] shamt = {27'b0,inst[10:6]};         //zero-extend
    wire [31:0] imm   = (op==6'b001100||op ==6'b001101||op==6'b001110)?
                        {16'b0,inst[15:0]}:{ {16{inst[15]}}, inst[15:0]};
                        //andi ori xori => zero-extend , other => sign-extend
    assign        rs = inst[25:21];
    assign        rt = inst[20:16];
    assign        rd = inst[15:11];
    reg  [31:0] load_data;
    wire [31:0] pc_jmp = {npc[31:28], addr, 2'b00};
    wire [31:0] pc_branch = npc + (imm<<2);
    //sw\sb\sh  dmem write enable                    
    assign dm_wena  = (op==6'b101011||op ==6'b101000||op==6'b101001)?1:0;            
    assign dm_addr  = rf_rdata1 + imm;
    //R-type||clz->save to rd ; jal save to $31 ; other save to rt;                   
    assign rf_waddr = (op==6'b000000||op==6'b011100)?rd:((op ==6'b000011)?5'b11111:rt);                
    assign eret = ({op,func}==12'b010000_011000) ? 1 : 0;    //eret
    assign mtc0 = ({op,  rs}==11'b010000_00100 ) ? 1 : 0;    //mtc0
    assign teq_exc = (rf_rdata1 == rf_rdata2)    ? 1 : 0;
    wire   mfc0 = ({op,  rs}==11'b010000_00000 ) ? 1 : 0;    //mfc0
    
    always @(*)//pc
    begin
        casex ({op,func})
            12'b000000_001000:  pc_next <= rf_rdata1;   //jr PC<-rs
            12'b000000_001001:  pc_next <= rf_rdata1;   //jalr PC<-rs
            12'b000000_001100,12'b000000_001101,12'b000000_110100://syscall, break,teq
                                pc_next <= exc_addr;    //PC <- default excaddr
            12'b000010_xxxxxx,12'b000011_xxxxxx:          //j,jal pc<-npc[31:28],addr,00
                                pc_next <= pc_jmp;
            12'b000100_xxxxxx:  pc_next <= (rf_rdata1==rf_rdata2) ?pc_branch : npc;//beq
            12'b000101_xxxxxx:  pc_next <= (rf_rdata1!=rf_rdata2) ?pc_branch : npc;//bne     
            12'b010000_011000:  pc_next <= exc_addr;    //eret
            12'b000001_xxxxxx:  pc_next <= (rf_rdata1[31] == 0)   ?pc_branch : npc;//bgez
            default: pc_next <= npc;
        endcase
    end
    always @(*) begin//muldiv
        case ({op,func})
            12'b000000_011001: mdc <= 3'h2;//multu
            12'b000000_011010: mdc <= 3'h3;//div
            12'b000000_011011: mdc <= 3'h4;//divu
            12'b000000_010001: mdc <= 3'h5;//mthi
            12'b000000_010011: mdc <= 3'h6;//mtlo
                default: begin 
                mdc <= 0;
            end
        endcase
    end
    always @(*) begin//cp0
        case ({op,func})
            12'b000000_001100:  cause <= 4'b1000;//syscall
            12'b000000_110100:  cause <= 4'b1101;//teq
            12'b000000_001101:  cause <= 4'b1001;//break
            default: begin 
                cause <= 4'b0000;
            end
        endcase
    end
    always @(*) begin//DMEM
        case (op)
            6'b100011: load_data <= dm_rdata;                               //lw
            6'b100000: load_data <= {{24{dm_rdata[ 7]}}, dm_rdata[7 :0]};   //lb
            6'b100001: load_data <= {{16{dm_rdata[15]}}, dm_rdata[15:0]};   //lh
            6'b100100: load_data <= {24'b0, dm_rdata[7 :0]};                //lbu
            6'b100101: load_data <= {16'b0, dm_rdata[15:0]};                //lhu
                default: begin
                load_data <= dm_rdata;
            end
        endcase
    end
    always @(*) begin//DMEM
        case (op)
            6'b101011: dm_wdata <= rf_rdata2;                   //sw
            6'b101000: dm_wdata <= {24'b0, rf_rdata2[7:0]};     //sb
            6'b101001: dm_wdata <= {16'b0, rf_rdata2[15:0]};    //sh
            default: begin
                dm_wdata <= rf_rdata2;
            end
        endcase
    end
    
    always @(*)//ALU
    begin
        casex ({op,func})
            12'b000000_000000,12'b000000_000010,12'b000000_000011: begin    //sll\srl\sra
                alu_a <= shamt;                     //these three ins
                alu_b <= rf_rdata2;                 //caculate shamt and rt
            end
            /*addi, addiu,andi, ori, xori,slti, sltiu,lui*/
            12'b001000_xxxxxx,12'b001001_xxxxxx,12'b001100_xxxxxx,12'b001101_xxxxxx,
            12'b001110_xxxxxx,12'b001010_xxxxxx,12'b001011_xxxxxx,12'b001111_xxxxxx:begin
                alu_a <= rf_rdata1;
                alu_b <= imm;
            end
            default:begin
                alu_a <= rf_rdata1;
                alu_b <= rf_rdata2;
            end
        endcase
    end
    always @(*)//ALU
    begin
        casex ({op,func})
            12'b000000_100000:  aluc <= 4'b0010;    //add
            12'b000000_100001:  aluc <= 4'b0000;    //addu
            12'b000000_100010:  aluc <= 4'b0011;    //sub
            12'b000000_100011:  aluc <= 4'b0001;    //subu
            12'b000000_100100:  aluc <= 4'b0100;    //and
            12'b000000_100101:  aluc <= 4'b0101;    //or
            12'b000000_100110:  aluc <= 4'b0110;    //xor
            12'b000000_100111:  aluc <= 4'b0111;    //nor
            12'b000000_101010:  aluc <= 4'b1011;    //slt
            12'b000000_101011:  aluc <= 4'b1010;    //sltu
            12'b000000_000000,12'b000000_000100:    //sll\sllv
                                aluc <= 4'b1111;
            12'b000000_000010,12'b000000_000110:    //srl\srlv
                                aluc <= 4'b1101;
            12'b000000_000011,12'b000000_000111:    //sra\srav
                                aluc <= 4'b1100;
            12'b001000_xxxxxx:  aluc <= 4'b0010;    //addi
            12'b001001_xxxxxx:  aluc <= 4'b0000;    //addiu
            12'b001100_xxxxxx:  aluc <= 4'b0100;    //andi
            12'b001101_xxxxxx:  aluc <= 4'b0101;    //ori
            12'b001110_xxxxxx:  aluc <= 4'b0110;    //xori
            12'b001010_xxxxxx:  aluc <= 4'b1011;    //slti
            12'b001011_xxxxxx:  aluc <= 4'b1010;    //sltiu
            12'b001111_xxxxxx:  aluc <= 4'b1000;    //lui
            default:   aluc <= 0000;
        endcase
    end

    always @(*)//rf_w
    begin
        case (op)
            6'b00000:begin
                case(func)
                    6'b001000,
                    6'b001100,
                    6'b001101,
                    6'b011001,
                    6'b011010,
                    6'b011011,
                    6'b010001,
                    6'b010011:
                    /*jr,syscall, break:multu,div, divu,mthi, mtlo:*/
                        rf_w <= 0;
                    default: rf_w <= 1; //alu_op
                endcase
            end
            6'b001000,
            6'b001001,
            6'b001100,
            6'b001101,
            6'b001110,
            6'b100011,
            6'b001010,
            6'b001011,
            6'b001111,
            6'b000011,
            6'b100000,
            6'b100100,
            6'b100001,
            6'b100101:
            /*addi, addiu,andi, ori, xori,lw,slti, sltiu,
            lui,jal:lb, lbu,lh, lhu:*/      
                rf_w <= 1;         
            6'b010000:        
                rf_w <= (rs ==5'b000000) ? 1 : 0;   //mfc0
            6'b011100:        rf_w <= 1;    // clz && mul
            default:        rf_w <= 0;
        endcase
    end
    always @(*)//rf_wdata
    begin
        case (op)
            6'b000011: 
                rf_wdata <= npc;         //jal
            6'b100011,6'b100000,
            6'b100100,6'b100001,
            6'b100101: 
                rf_wdata <= load_data;   //lw,lb,lbu,lh,lhu
            6'b000000:begin
                case (func)
                    6'b001001: rf_wdata <= npc; //jalr
                    6'b010000: rf_wdata <= hi;  //mfhi
                    6'b010010: rf_wdata <= lo;  //mflo
                    default: rf_wdata <= alu_result; //alu_op
                endcase
            end
            6'b010000: 
                rf_wdata <= (rs == 5'b00000) ? cp0_rdata : alu_result;
            6'b011100 :begin //clz & mul
                case (func)
                    6'b000010: rf_wdata <= mul_result;  //mul
                    6'b100000: rf_wdata <= zero_num;
                    default: rf_wdata <= 32'h0;
                endcase
            end
            default: rf_wdata <= alu_result;
        endcase
    end
endmodule
