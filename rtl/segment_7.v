`timescale 1ns / 1ps
module segment_7(seg,bcd,dp);
output reg [7:0]seg;
input [3:0]bcd;
input dp;
always @(*)
begin
case(bcd)
4'd0:
begin
seg[6:0] = 7'b1000000;
end
4'd1:
begin
seg[6:0] = 7'b1111001;
end
4'd2:
begin
seg[6:0] = 7'b0100100;
end
4'd3:
begin
seg[6:0] = 7'b0110000;
end
4'd4:
begin
seg[6:0] = 7'b0011001;
end
4'd5:
begin
seg[6:0] = 7'b0010010;
end
4'd6:
begin
seg[6:0] = 7'b0000010;
end
4'd7:
begin
seg[6:0] = 7'b1111000;
end
4'd8:
begin
seg[6:0] = 7'b0000000;
end
4'd9:
begin
seg[6:0] = 7'b0010000;
end
default:
begin
seg[6:0] = 7'b1111111;
end
endcase    
if(dp)
seg[7] = 1'b0;
else
seg[7] = 1'b1;    
end
endmodule
