`timescale 1ns/1ns

module fourBitAdderTOP(SW, LEDR); // Top Level Module

	input [8:0] SW;
	output [9:0] LEDR;
	
	fourBitAdder fba(SW[7:4], SW[3:0], SW[8], { LEDR[9], LEDR[3:0] });

endmodule // fourBitAdderTOP

module fourBitAdder(A, B, Cin, Output);

	input [3:0] A, B; // Two four bit inputs
	input Cin; // Initial Carry
	output [4:0] Output; // 5 bit output
	
	wire c1, c2, c3; // Carry from each addition
	
	adder a1 (A[0], B[0], Cin, Output[0], c1);
	adder a2 (A[1], B[1], c1, Output[1], c2);
	adder a3 (A[2], B[2], c2, Output[2], c3);
	adder a4 (A[3], B[3], c3, Output[3], Output[4]);

endmodule // fourBitAdder

module adder(input a, b, cin,
				 output s, cout);

	wire w;
	assign w = a ^ b;
	
	assign s = w ^ cin;
	assign cout = (w & cin) | (!w & b);
				 
endmodule // adder
