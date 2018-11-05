`timescale 1ns/1ns

module RAM_TOP (SW, KEY, HEX0, HEX2, HEX4, HEX5);
	input [9:0] SW;
	input [0:0] KEY;
	output [6:0] HEX0, HEX2, HEX4, HEX5;
	
	wire [3:0] DataOut;
	
	ram32x4 ram (.data(SW[3:0]), .address(SW[8:4]), .wren(SW[9]), .clock(~KEY[0]), .q(DataOut));
	
	HEX_Decoder h5({3'b0, SW[8]}, HEX5);
	HEX_Decoder h4(SW[7:4], HEX4);
	HEX_Decoder h2(SW[3:0], HEX2);
	HEX_Decoder h0(DataOut, HEX0);

endmodule
