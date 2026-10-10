`timescale 1ns / 1ps
module disp_ctrl(clk,rst,value,D0_AN,D0_SEG);

input clk,rst;
input [7:0]value;
output reg [3:0]D0_AN;
output [7:0]D0_SEG;

reg [16:0]refresh;
wire [1:0]sel;
wire [3:0]hund,tens,ones;
wire [3:0]digit;
wire [7:0]seg;

assign sel = refresh[16:15];

assign hund = (value / 8'd100);
assign tens = (value / 8'd10) % 8'd10;
assign ones = value % 8'd10;

reg [3:0]display_bcd;

assign digit = display_bcd;
assign D0_SEG = seg;

always @(posedge clk or posedge rst) begin
if(rst)
refresh <= 17'd0;
else
refresh <= refresh + 1'b1;
end

always @(*) begin
D0_AN = 4'b1111;
display_bcd = 4'hF;

case(sel)
2'd0: begin
display_bcd = ones;
D0_AN = 4'b1110;
end

2'd1: begin
display_bcd = (hund == 4'd0 && tens == 4'd0) ? 4'hF : tens;
D0_AN = 4'b1101;
end

2'd2: begin
display_bcd = (hund == 4'd0) ? 4'hF : hund;
D0_AN = 4'b1011;
end

default: begin
display_bcd = 4'hF;
D0_AN = 4'b1111;
end
endcase
end

segment_7 decoder(
.seg(seg),
.bcd(digit),
.dp(1'b0)
);

endmodule
