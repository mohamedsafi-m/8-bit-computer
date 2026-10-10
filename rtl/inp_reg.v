`timescale 1ns / 1ps
module inp_reg(bus,ext_inp,INPI);
input INPI;
input [7:0]ext_inp;
inout [7:0]bus;

assign bus = INPI ? ext_inp : 8'bz;

endmodule
