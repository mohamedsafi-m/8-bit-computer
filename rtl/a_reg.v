`timescale 1ns / 1ps
module a_reg(a_out,bus,clk,rst,AI,AO);
input clk,rst,AI,AO;
inout [7:0]bus;
output [7:0]a_out;
reg [7:0]areg;
always @(posedge clk or posedge rst) begin
if(rst)
areg <= 8'b00000000;
else if (AI)
areg <= bus[7:0];
end
assign bus = AO ? areg : 8'bz;
assign a_out = areg;
endmodule
