`timescale 1ns / 1ps
module ram(bus, addr, clk, RI, RO);
input clk, RI, RO;
input [3:0] addr;
inout [7:0] bus;

reg [7:0] ram [0:15];

initial begin
$readmemb("sram.mem", ram);
end

always @(posedge clk) begin
if (RI)
ram[addr] <= bus;
end

assign bus = RO ? ram[addr] : 8'bz;
endmodule
