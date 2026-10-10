`timescale 1ns / 1ps
module out_reg(out,bus,clk,rst,OI);
input clk,rst,OI;
input [7:0]bus;
output [7:0]out;
reg [7:0]o_reg;
always @ (posedge clk or posedge rst) begin
if(rst)
o_reg <= 8'b00000000;
else if(OI)
o_reg <= bus;
end
assign out = o_reg;
endmodule
