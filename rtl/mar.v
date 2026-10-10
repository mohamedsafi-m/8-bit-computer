`timescale 1ns / 1ps
module mar(addr,clk,rst,MI,bus);
input clk,rst,MI;
input [7:0]bus;
output [3:0]addr;
reg [3:0] mar;
always @ (posedge clk or posedge rst) begin
if(rst)
mar <= 4'b0000;
else if(MI)
mar <= bus[3:0];
end
assign addr = mar;
endmodule
