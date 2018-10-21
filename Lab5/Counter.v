`timescale 1ns/1ns

module CounterTOP (SW, KEY, HEX0, HEX1);

	input [1:0] SW;
	input [0:0] KEY;
	output [6:0] HEX0, HEX1;
	
	Counter_8b counter (.Clock(~KEY[0]), .Enable(SW[1]), .Clear_b(SW[0]), .Display0(HEX0), .Display1(HEX1));

endmodule

module Counter_8b (input Clock, Enable, Clear_b, output[6:0] Display0, Display1);

	wire [7:0] q;
	wire [7:0] t;
	
	assign t[0] = Enable;
	assign t[7:1] = q[6:0] & t[6:0];

	TFF_1b tff0 (.T(t[0]), .Clock(Clock), .Clear(Clear_b), .Q(q[0]));
	TFF_1b tff1 (.T(t[1]), .Clock(Clock), .Clear(Clear_b), .Q(q[1]));
	TFF_1b tff2 (.T(t[2]), .Clock(Clock), .Clear(Clear_b), .Q(q[2]));
	TFF_1b tff3 (.T(t[3]), .Clock(Clock), .Clear(Clear_b), .Q(q[3]));
	TFF_1b tff4 (.T(t[4]), .Clock(Clock), .Clear(Clear_b), .Q(q[4]));
	TFF_1b tff5 (.T(t[5]), .Clock(Clock), .Clear(Clear_b), .Q(q[5]));
	TFF_1b tff6 (.T(t[6]), .Clock(Clock), .Clear(Clear_b), .Q(q[6]));
	TFF_1b tff7 (.T(t[7]), .Clock(Clock), .Clear(Clear_b), .Q(q[7]));
	
	HEX_Decoder h0 (q[3:0], Display0);
	HEX_Decoder h1 (q[7:4], Display1);

endmodule 

module TFF_1b (input T, Clock, Clear, output reg Q);

	always @(posedge Clock)
	begin
		if (!Clear)
			Q <= 0;
		else if (T)
			Q <= ~Q;
	end

endmodule 