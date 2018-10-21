`timescale 1ns/1ns

module MorseEncoderTOP (SW, KEY, CLOCK_50, LEDR);

	input [2:0] SW;
	input [1:0] KEY;
	input CLOCK_50;
	output [0:0] LEDR;
	
	wire [25:0] ClockFrequency = 26'b10111110101111000010000000;
	
	wire [12:0] S = 13'b1010100000000;
	wire [12:0] T = 13'b1110000000000;
	wire [12:0] U = 13'b1010111000000;
	wire [12:0] V = 13'b1010101110000;
	wire [12:0] W = 13'b1011101110000;
	wire [12:0] X = 13'b1110101011100;
	wire [12:0] Y = 13'b1110101110111;
	wire [12:0] Z = 13'b1110111010100;
	wire [12:0] Letter;
	
	wire [25:0] Frequency = {24'b0, 2'b10};
	wire [25:0] Max = (ClockFrequency / Frequency) - 1'b1;
	wire [25:0] RateDivider;
	
	Mux8to1 letterSelector (S, T, U, V, W, X, Y, Z, SW, Letter);
	
	RateController rateControl (.Clock(CLOCK_50), .Enable(1), .Clear_b(1), 
										.ParLoad(0), .D(26'b0), .MaxValue(Max), .Q(RateDivider));
	
	wire EnableRotate = RateDivider == 26'b0 ? 1 : 0;
	
	wire [12:0] Qout;
	
	Shifter_13b_LSLeft shifter (.Clock(CLOCK_50), .D(Letter), .Enable(EnableRotate),
										.ParallelLoad(~KEY[1]), .Clear_b(~KEY[0]), .Q(Qout));
	
	assign LEDR[0] = Qout[12];

endmodule 

module Mux8to1 (input [12:0] x0, x1, x2, x3, x4, x5, x6, x7, input [2:0] select, output reg [12:0] out);
	
	always @(*)
	begin
		case (select)
		3'b000: out = x0;
		3'b001: out = x1;
		3'b010: out = x2;
		3'b011: out = x3;
		3'b100: out = x4;
		3'b101: out = x5;
		3'b110: out = x6;
		3'b111: out = x7;
		default: out = x0;
		endcase
	end

endmodule 

module Shifter_13b_LSLeft (input [12:0] D, input Clock, Enable, ParallelLoad, Clear_b, output reg [12:0] Q);

	always @(posedge Clock, posedge Clear_b)
	begin
		if (Clear_b == 1'b1)
			Q <= 0;
		else if (ParallelLoad == 1'b1)
			Q <= D;
		else if (Enable == 1'b1)
			Q <= Q * 2;
	end

endmodule
