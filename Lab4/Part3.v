`timescale 1ns/1ns

module Part3Top(SW, KEY, LEDR);

	input [9:0] SW;
	input [3:0] KEY;
	output [7:0] LEDR;
	
	wire [7:0] DATA_RESET = SW[7:0];
	wire [7:0] DATA_IN;
	wire Reset = SW[9];
	wire ParallelLoadn = ~KEY[1];
	wire RotateRight = ~KEY[2];
	wire LSRight = ~KEY[3];
	wire Clock = ~KEY[0];
	
	wire w; // Whether left bit of left-most bit is 0 or right-most bit
	mux2to1 M0 (.x(0), .y(DATA_IN[0]), .s(LSRight), .m(w));
	
	// Shifter module for each bit
	shifter s7 (.left(w), .right(DATA_IN[6]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[7]), .DReset(DATA_RESET[7]), .clock(Clock), .reset(Reset), .Q(DATA_IN[7]));
					
	shifter s6 (.left(DATA_IN[7]), .right(DATA_IN[5]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[6]), .DReset(DATA_RESET[6]), .clock(Clock), .reset(Reset), .Q(DATA_IN[6]));
				
	shifter s5 (.left(DATA_IN[6]), .right(DATA_IN[4]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[5]), .DReset(DATA_RESET[5]), .clock(Clock), .reset(Reset), .Q(DATA_IN[5]));
					
	shifter s4 (.left(DATA_IN[5]), .right(DATA_IN[3]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[4]), .DReset(DATA_RESET[4]), .clock(Clock), .reset(Reset), .Q(DATA_IN[4]));
					
	shifter s3 (.left(DATA_IN[4]), .right(DATA_IN[2]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[3]), .DReset(DATA_RESET[3]), .clock(Clock), .reset(Reset), .Q(DATA_IN[3]));
					
	shifter s2 (.left(DATA_IN[3]), .right(DATA_IN[1]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[2]), .DReset(DATA_RESET[2]), .clock(Clock), .reset(Reset), .Q(DATA_IN[2]));
					
	shifter s1 (.left(DATA_IN[2]), .right(DATA_IN[0]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[1]), .DReset(DATA_RESET[1]), .clock(Clock), .reset(Reset), .Q(DATA_IN[1]));
					
	shifter s0 (.left(DATA_IN[1]), .right(DATA_IN[7]), .loadLeft(RotateRight), .loadn(ParallelLoadn), 
					.D(DATA_IN[0]), .DReset(DATA_RESET[0]), .clock(Clock), .reset(Reset), .Q(DATA_IN[0]));
	
	assign LEDR = DATA_IN; // Display on LEDR

endmodule // Part3Top

module shifter(input left, right, loadLeft, loadn, D, DReset, clock, reset, output Q);

	wire rotateData, data_to_dff;
	
	mux2to1 M1 (.x(left), .y(right), .s(loadLeft), .m(rotateData)); // Rotate left or right
	mux2to1 M2 (.x(rotateData), .y(D), .s(loadn), .m(data_to_dff)); // Rotate or keep data
	
	// D flip flop
	DposEdgeFF_1bit dff (.Clock(clock), .Reset_b(reset), .d(data_to_dff), .dReset(DReset), .q(Q));

endmodule // shifter

module mux2to1(input x,y,s, output m);

	assign m = x & s | y & ~s;

endmodule // mux2to1

module DposEdgeFF_1bit (Clock, Reset_b, d, dReset, q);

	input Clock, Reset_b;
	input d, dReset;
	output reg q;
	
	always @(posedge Clock)
	begin
		if (Reset_b == 1'b1)
			q <= dReset; // Reset to switch values
		else
			q <= d;
	end

endmodule // DposEdgeFF_1bit
