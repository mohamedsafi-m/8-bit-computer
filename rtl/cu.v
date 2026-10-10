`timescale 1ns / 1ps
module cu(CO,CL,CE,OI,BI,SUB1,ALO,AO,AI,IO,II,RO,RI,MI,HLT1,FE,XRAE,ANAE,INPI,INPO,SFL1,SFR1,
clk,rst,opcode,flag_c,flag_z,start);

input clk,rst,flag_c,flag_z,start;
input [3:0]opcode;

output reg CO,CL,CE,OI,BI,SUB1,ALO,AO,AI,IO,II,RO,RI,MI,HLT1,FE,XRAE,ANAE,INPI,INPO,SFL1,SFR1;

parameter NOP = 4'd0,
          LDA = 4'd1,
          STA = 4'd2,
          ADD = 4'd3,
          SUB = 4'd4,
          LDI = 4'd5,
          ANA = 4'd6,
          XRA = 4'd7,
          SFL = 4'd8,
          SFR = 4'd9,
          JMP = 4'd10,
          JC = 4'd11,
          JZ = 4'd12,
          INP = 4'd13,
          OUT = 4'd14,
          HLT = 4'd15;

localparam IDLE = 4'd0,
           T0 = 4'd1,
           T1 = 4'd2,
           T2 = 4'd3,
           T3 = 4'd4,
           T4 = 4'd5,
           T5 = 4'd6,
           HALT = 4'd7,
           WAIT_INP = 4'd8;

reg [3:0] state,next_state;

always @(posedge clk or posedge rst) begin
if(rst)
state <= IDLE;
else
state <= next_state;
end

always @(*) begin
next_state = state;
case(state)
IDLE: begin
if(start)
next_state = T0;
else
next_state = IDLE;
end

T0: next_state = T1;
T1: next_state = T2;

T2: begin
case(opcode)
HLT: next_state = HALT;
default: next_state = T3;
endcase
end

T3: begin
case(opcode)
LDA: next_state = T4;
STA: next_state = T4;
ADD: next_state = T4;
SUB: next_state = T4;
ANA: next_state = T4;
XRA: next_state = T4;
INP: next_state = WAIT_INP;
default: next_state = T0;
endcase
end

WAIT_INP: begin
if(start)
next_state = T0;
else
next_state = WAIT_INP;
end

T4: begin
case(opcode)
ADD: next_state = T5;
SUB: next_state = T5;
ANA: next_state = T5;
XRA: next_state = T5;
default: next_state = T0;
endcase
end

T5: next_state = T0;
HALT: next_state = HALT;
default: next_state = IDLE;
endcase
end

always @(*) begin
CO = 1'b0;CL = 1'b0;CE = 1'b0;OI = 1'b0;BI = 1'b0;
SUB1 = 1'b0;ALO = 1'b0;AO = 1'b0;AI = 1'b0;IO = 1'b0;
II = 1'b0;RO = 1'b0;RI = 1'b0;MI = 1'b0;HLT1 = 1'b0;
FE = 1'b0;XRAE = 1'b0;ANAE = 1'b0;INPI = 1'b0;INPO = 1'b0;
SFL1 = 1'b0;SFR1 = 1'b0;

case(state)
IDLE: begin
end

T0: begin
CO = 1'b1;
MI = 1'b1;
end

T1: begin
RO = 1'b1;
II = 1'b1;
end

T2: begin
CE = 1'b1;
end

T3: begin
case(opcode)
NOP: begin
end

LDA: begin
IO = 1'b1;
MI = 1'b1;
end

STA: begin
IO = 1'b1;
MI = 1'b1;
end

ADD: begin
IO = 1'b1;
MI = 1'b1;
end

SUB: begin
IO = 1'b1;
MI = 1'b1;
end

LDI: begin
IO = 1'b1;
AI = 1'b1;
end

ANA: begin
IO = 1'b1;
MI = 1'b1;
end

XRA: begin
IO = 1'b1;
MI = 1'b1;
end

JMP: begin
IO = 1'b1;
CL = 1'b1;
end

JC: begin
if(flag_c) begin
IO = 1'b1;
CL = 1'b1;
end
end

JZ: begin
if(flag_z) begin
IO = 1'b1;
CL = 1'b1;
end
end

INP: begin
end

OUT: begin
AO = 1'b1;
OI = 1'b1;
end

SFL: begin
SFL1 = 1'b1;
ALO = 1'b1;
AI = 1'b1;
FE = 1'b1;
end

SFR: begin
SFR1 = 1'b1;
ALO = 1'b1;
AI = 1'b1;
FE = 1'b1;
end

HLT: begin
HLT1 = 1'b1;
end
endcase
end

WAIT_INP: begin
if(start) begin
INPI = 1'b1;
AI = 1'b1;
end
end

T4: begin
case(opcode)
LDA: begin
RO = 1'b1;
AI = 1'b1;
end

STA: begin
AO = 1'b1;
RI = 1'b1;
end

ADD: begin
RO = 1'b1;
BI = 1'b1;
end

SUB: begin
RO = 1'b1;
BI = 1'b1;
end

ANA: begin
RO = 1'b1;
BI = 1'b1;
end

XRA: begin
RO = 1'b1;
BI = 1'b1;
end
endcase
end

T5: begin
case(opcode)
ADD: begin
ALO = 1'b1;
AI = 1'b1;
FE = 1'b1;
end

SUB: begin
ALO = 1'b1;
AI = 1'b1;
FE = 1'b1;
SUB1 = 1'b1;
end

ANA: begin
ALO = 1'b1;
AI = 1'b1;
FE = 1'b1;
ANAE = 1'b1;
end

XRA: begin
ALO = 1'b1;
AI = 1'b1;
FE = 1'b1;
XRAE = 1'b1;
end
endcase
end

HALT: begin
HLT1 = 1'b1;
end
endcase
end

endmodule
