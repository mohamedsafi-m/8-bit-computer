`timescale 1ns / 1ps
module flag_reg(flag_c,flag_z,clk,rst,carry,zero,FE);
input clk,rst,carry,zero,FE;
output reg flag_c,flag_z;

always @ (posedge clk or posedge rst) begin
if(rst)
begin
flag_c <= 1'b0;
flag_z <= 1'b0;
end
else if(FE)
begin
flag_c <= carry;
flag_z <= zero;
end
end
endmodule
