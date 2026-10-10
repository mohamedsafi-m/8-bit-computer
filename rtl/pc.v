`timescale 1ns / 1ps
module pc(bus,clk,rst,CO,CL,CE);
input clk,rst,CO,CL,CE;
inout  [7:0]bus;
reg [3:0]pc;
always @ (posedge clk or posedge rst) begin
if(rst)
pc <= 4'b0000;
else if(CL)
pc <= bus[3:0];
else if (CE)
pc <= pc + 4'b0001;
end
assign bus = CO ? {4'b0000,pc} : 8'bz;
endmodule
