`timescale 1ns / 1ps
module b_reg(b_out,clk,rst,bus,BI);
input clk,rst,BI;
input [7:0]bus;
output [7:0]b_out;
reg [7:0]breg;
always @ (posedge clk or posedge rst) begin
if(rst)
breg <= 8'b00000000;
else if(BI)
breg <= bus;
end
assign b_out = breg;
endmodule
