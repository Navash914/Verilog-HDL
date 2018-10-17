`timescale 1ns/1ns

module Part3Top(SW, KEY, LEDR);

	input [9:0] SW;
	input [3:0] KEY;
	output [7:0] LEDR;
	
	wire [7:0] DATA_IN = SW[7:0];
	wire Reset = SW[9];
	wire ParallelLoadn = ~KEY[1];
	wire RotateRight = ~KEY[2];
	wire LSRight = ~KEY[3];
	wire Clock = ~KEY[0];
	
	wire w; // Whether left bit of left-most bit is 0 or right-most bit
	mux2to1 M0 (.x(0), .y(LEDR[0]), .s(LSRight), .m(w));
	
	// Shifter module for each bit
	shifter s7 (.left(w), .right(LEDR[6]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[7]), .clock(Clock), .reset(Reset), .Q(LEDR[7]));
					
	shifter s6 (.left(LEDR[7]), .right(LEDR[5]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[6]), .clock(Clock), .reset(Reset), .Q(LEDR[6]));
				
	shifter s5 (.left(LEDR[6]), .right(LEDR[4]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[5]), .clock(Clock), .reset(Reset), .Q(LEDR[5]));
					
	shifter s4 (.left(LEDR[5]), .right(LEDR[3]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[4]), .clock(Clock), .reset(Reset), .Q(LEDR[4]));
					
	shifter s3 (.left(LEDR[4]), .right(LEDR[2]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[3]), .clock(Clock), .reset(Reset), .Q(LEDR[3]));
					
	shifter s2 (.left(LEDR[3]), .right(LEDR[1]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[2]), .clock(Clock), .reset(Reset), .Q(LEDR[2]));
					
	shifter s1 (.left(LEDR[2]), .right(LEDR[0]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[1]), .clock(Clock), .reset(Reset), .Q(LEDR[1]));
					
	shifter s0 (.left(LEDR[1]), .right(LEDR[7]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[0]), .clock(Clock), .reset(Reset), .Q(LEDR[0]));

endmodule // Part3Top

module shifter(input left, right, loadLeft, loadn, D, clock, reset, output Q);

	wire rotateData, data_to_dff;
	
	mux2to1 M1 (.x(left), .y(right), .s(loadLeft), .m(rotateData)); // Rotate left or right
	mux2to1 M2 (.x(rotateData), .y(D), .s(loadn), .m(data_to_dff)); // Rotate or keep data
	
	// D flip flop
	DposEdgeFF_1bit dff (.Clock(clock), .Reset_b(reset), .d(data_to_dff), .q(Q));

endmodule // shifter

module mux2to1(input x,y,s, output m);

	assign m = x & s | y & ~s;

endmodule // mux2to1

module DposEdgeFF_1bit (Clock, Reset_b, d, q);

	input Clock, Reset_b;
	input d;
	output reg q;
	
	always @(posedge Clock)
	begin
		if (Reset_b == 1'b1)
			q <= 0;
		else
			q <= d;
	end

endmodule // DposEdgeFF_1bit
