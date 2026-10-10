`timescale 1ns / 1ps
module ir(opcode,bus,clk,rst,II,IO);
input clk,rst,II,IO;
inout [7:0]bus;
output [3:0]opcode;
reg [7:0]ir;
always @ (posedge clk or posedge rst) begin
if(rst)
ir <= 8'b00000000;
else if(II)
ir <= bus;
end
assign opcode[3:0] = ir[7:4];
assign bus [7:0] = IO ? {4'b0000,ir[3:0]}:8'bz;
endmodule
