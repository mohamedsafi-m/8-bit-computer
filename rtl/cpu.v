`timescale 1ns / 1ps
module cpu(ext_inp,start,clk,rst,D0_AN,D0_SEG);
input start,clk,rst;
input [7:0]ext_inp;
output [3:0] D0_AN;
output [7:0] D0_SEG;


wire clkf;
wire [7:0]bus,out;
wire [7:0]a_out,b_out,alu_result;
wire [3:0]opcode,addr;
wire flag_z,flag_c,carry,zero;
wire CO,CL,CE,OI,BI,SUB1,ALO,AO,AI,IO,II,RO,RI,MI,HLT1,FE,XRAE,ANAE,INPI,INPO,SFL1,SFR1;

clk_div div1(.clkf(clkf),
             .clk(clk),
             .rst(rst));
              
pc pc1(.bus(bus),
       .clk(clkf),
       .rst(rst),
       .CO(CO),
       .CL(CL),
       .CE(CE));

mar mar1(.addr(addr),
         .clk(clkf),
         .rst(rst),
         .MI(MI),
         .bus(bus));

ram ram1(.bus(bus),
         .addr(addr),
         .clk(clkf),
         .RI(RI),.RO(RO));
         
 ir ir1(.opcode(opcode),
        .bus(bus),
        .clk(clkf),
        .rst(rst),
        .II(II),
        .IO(IO));

a_reg a1(.bus(bus),
         .a_out(a_out),
         .clk(clkf),
         .rst(rst),
         .AI(AI),.AO(AO));

b_reg b1(.b_out(b_out),
         .clk(clkf),
         .rst(rst),
         .bus(bus),
         .BI(BI));

alu alu1(.res(alu_result),
         .carry(carry),
         .zero(zero),
         .a(a_out),
         .b(b_out),
         .SUB1(SUB1),
         .XRAE(XRAE),
         .ANAE(ANAE),
         .SFL1(SFL1),
         .SFR1(SFR1));

assign bus = ALO ? alu_result : 8'bz;

flag_reg flags1(.flag_c(flag_c),
                .flag_z(flag_z),
                .clk(clkf),.rst(rst),
                .carry(carry),
                .zero(zero),
                .FE(FE));

inp_reg inp1(.bus(bus),
             .ext_inp(ext_inp),
             .INPI(INPI));

out_reg out1(.out(out),
             .bus(bus),
             .clk(clkf),
             .rst(rst),
             .OI(OI));

cu cu1(.CO(CO),.CL(CL),
       .CE(CE),.OI(OI),
       .BI(BI),.SUB1(SUB1),
       .ALO(ALO),.AO(AO),
       .AI(AI),.IO(IO),
       .II(II),.RO(RO),
       .RI(RI),.MI(MI),
       .HLT1(HLT1),.FE(FE),
       .XRAE(XRAE),.ANAE(ANAE),
       .INPI(INPI),.INPO(INPO),
       .SFL1(SFL1),.SFR1(SFR1),
       .clk(clkf),.rst(rst),
       .opcode(opcode),.flag_c(flag_c),
       .flag_z(flag_z),.start(start));       

disp_ctrl disp1 (
    .clk(clk),
    .rst(rst),
    .value(out),
    .D0_AN(D0_AN),
    .D0_SEG(D0_SEG)
);


endmodule
