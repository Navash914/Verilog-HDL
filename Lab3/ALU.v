`timescale 1ns/1ns

module ALUTOP (SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5); // Top Level Module

	input [7:0] SW;
	input [2:0] KEY;
	output [7:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	ALU alu (
		.A(SW[7:4]),
		.B(SW[3:0]),
		.ALUselect(KEY[2:0]),
		.Output(LEDR[7:0]),
		.HexOut1(HEX5),
		.HexOut0(HEX4),
		.HexA1(HEX3),
		.HexA0(HEX2),
		.HexB1(HEX1),
		.HexB0(HEX0)
	);

endmodule // ALUTOP

module ALU (A, B, ALUselect, Output, HexOut1, HexOut0, HexA1, HexA0, HexB1, HexB0);

	input [3:0] A, B; // Two 4-bit inputs
	input [2:0] ALUselect; // 3-bit function selector
	output [7:0] Output; // 8-bit output
	output [6:0] HexOut1, HexOut0; // Hexes to display output
	output [6:0] HexA1, HexA0; // Hexes to display input A
	output [6:0] HexB1, HexB0; // Hexes to display input B
	
	// Set significant hexes of A and B to 0 as not used.
	HEX_Decoder h3(4'b0000, HexA1);
	HEX_Decoder h1(4'b0000, HexB1);
	
	// Display inputs on hexes.
	HEX_Decoder h2(A, HexA0);
	HEX_Decoder h0(B, HexB0);
	
	wire [5:0] sum;
	fourBitAdder fba(A, B, 0, sum);
	
	/*
		0: A + B using adder
		1: A + B using Verilog '+'
		2: A NAND B on lower 4 bits and A NOR B on upper 4 bits
		3: 8'b11000000 at least one 1
		4: 8'b00111111 if A has two 1s and B has three 1s
		5: B on significant bits and !A on lesser bits
		6: XNOR on lower 4 bits and XOR on upper 4 bits
	*/
	
	reg [7:0] ALUout;
	always @(*)
	begin
		case(~ALUselect[2:0])
			3'b000: // Case 0
				ALUout = {3'b000, sum};
			3'b001: // Case 1
				ALUout = A + B;
			3'b010: // Case 2
				ALUout = { ~(A | B), ~(A & B) };
			3'b011: // Case 3
				ALUout = {  {2{(|A) | (|B)}}, 6'b000000};
			3'b100: // Case 4
				ALUout = { 2'b00, {6{ ((|A) & (~&A) & (~^A)) & (&(B + 4'b0001) | &(B + 4'b0010) | &(B + 4'b0100) | &(B + 4'b1000)) }} };
			3'b101: // Case 5
				ALUout = { B[3:0], ~A[3:0] };
			3'b110: // Case 6
				ALUout = { A^B, A ~^B };
			default:
				ALUout = 8'b00000000;
		endcase
	end
	
	// Assign output.
	assign Output = ALUout;
	
	// Display output on hexes.
	HEX_Decoder h5(ALUout[7:4], HexOut1);
	HEX_Decoder h4(ALUout[3:0], HexOut0);
	

endmodule // ALU
