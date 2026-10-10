`timescale 1ns / 1ps
module alu(res,carry,zero,a,b,SUB1,XRAE,ANAE,SFL1,SFR1);
input SUB1,XRAE,ANAE,SFL1,SFR1;
input [7:0]a,b;
output reg [7:0]res;
output reg carry,zero;
reg [8:0]temp;

always @(*) begin
res = 8'b00000000;
carry = 1'b0;
zero = 1'b0;
temp = 9'b000000000;
if(SUB1 == 1'b0 && XRAE == 1'b0 && ANAE == 1'b0 && SFL1 == 1'b0 && SFR1 == 1'b0) begin
temp = {1'b0,a} + {1'b0,b};
res = temp[7:0];
carry = temp[8];
end
else if(SUB1 == 1'b1 && XRAE == 1'b0 && ANAE == 1'b0 && SFL1 == 1'b0 && SFR1 == 1'b0) begin
res = a - b;
carry = (a < b);
end
else if(SUB1 == 1'b0 && XRAE == 1'b1 && ANAE == 1'b0 && SFL1 == 1'b0 && SFR1 == 1'b0) begin
res = a ^ b;
carry = 1'b0;
end
else if(SUB1 == 1'b0 && XRAE == 1'b0 && ANAE == 1'b1 && SFL1 == 1'b0 && SFR1 == 1'b0) begin
res = a & b;
carry = 1'b0;
end
else if(SUB1 == 1'b0 && XRAE == 1'b0 && ANAE == 1'b0 && SFL1 == 1'b1 && SFR1 == 1'b0) begin
res = a << 1;
carry = a[7];
end
else if(SUB1 == 1'b0 && XRAE == 1'b0 && ANAE == 1'b0 && SFL1 == 1'b0 && SFR1 == 1'b1) begin
res = a >> 1;
carry = a[0];
end
if(res == 8'b00000000)
zero = 1'b1;
else
zero = 1'b0;
end
endmodule
