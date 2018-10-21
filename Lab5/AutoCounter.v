`timescale 1ns/1ns

module AutoCounterTOP (SW, CLOCK_50, HEX0);

	input [1:0] SW;
	input CLOCK_50;
	output [6:0] HEX0;
	
	wire [25:0] Frequency, RateDivider, Max, ClockFrequency;
	assign ClockFrequency = 26'b10111110101111000010000000;
	
	Mux4to1 mux (.zero(ClockFrequency), .one({23'b0, 3'b100}), .two({24'b0, 2'b10}), .three({25'b0, 1'b1}), .select(SW[1:0]), .out(Frequency));
	
	assign Max = (ClockFrequency / Frequency) - 1'b1;
	
	wire clr1, clr2;
	
	RateController rc (.Clock(CLOCK_50), .Enable(1), .Clear_b(1), .ParLoad(0), .D(26'b0), .MaxValue(Max), .Q(RateDivider));
	
	wire CountEnable = RateDivider == 26'b0 ? 1 : 0;
	
	Counter_4b counter (.Clock(CLOCK_50), .Enable(CountEnable), .Clear_b(1), .Display(HEX0));

endmodule

module Counter_4b (input Clock, Enable, Clear_b, output[6:0] Display);

	wire [3:0] q;
	wire [3:0] t;
	
	assign t[0] = Enable;
	assign t[3:1] = q[2:0] & t[2:0];

	TFF_1b tff0 (.T(t[0]), .Clock(Clock), .Clear(Clear_b), .Q(q[0]));
	TFF_1b tff1 (.T(t[1]), .Clock(Clock), .Clear(Clear_b), .Q(q[1]));
	TFF_1b tff2 (.T(t[2]), .Clock(Clock), .Clear(Clear_b), .Q(q[2]));
	TFF_1b tff3 (.T(t[3]), .Clock(Clock), .Clear(Clear_b), .Q(q[3]));
	
	HEX_Decoder h0 (q, Display);

endmodule 

module RateController (input Clock, Enable, Clear_b, ParLoad, input [25:0] D, MaxValue, output reg [25:0] Q);

	always @(posedge Clock)
	begin
		if (Clear_b == 1'b0)
			Q <= 0;
		else if (ParLoad == 1'b1)
			Q <= D;
		else if (Q >= MaxValue)
			Q <= 0;
		else if (Enable == 1'b1)
			Q <= Q + 1;
	end

endmodule 

module Mux4to1 (input [25:0] zero, one, two, three, input [1:0] select, output reg [25:0] out);
	
	always @(*)
	begin
		case (select)
		2'b00: out = zero;
		2'b01: out = one;
		2'b10: out = two;
		2'b11: out = three;
		endcase
	end

endmodule 