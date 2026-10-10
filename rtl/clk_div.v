`timescale 1ns / 1ps

module clk_div(clkf, rst, clk);
input clk, rst;
output reg clkf;
reg [22:0] counter;
always @(posedge clk or posedge rst) begin
if (rst) begin
counter <= 23'd0;
clkf <= 1'b0;
end
else if (counter == 23'd8333332) begin
counter <= 23'd0;
clkf <= ~clkf;
end
else begin
counter <= counter + 1'b1;
end
end
endmodule
