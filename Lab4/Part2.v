`timescale 1ns/1ns

module Part2Top (SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

	input [9:0] SW;
	input [3:0] KEY;
	output [7:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	wire [7:0] out;
	
	ALU alu (SW[3:0], LEDR[3:0], ~KEY[3:1], out, LEDR);
	DposEdgeFF_8bit pff (~KEY[0], SW[9], out, LEDR);
	
	HEX_Decoder data (SW[3:0], HEX0);
	HEX_Decoder highSigBits (LEDR[7:4], HEX5);
	HEX_Decoder lowSigBits (LEDR[3:0], HEX4);
	
	HEX_Decoder empty1 (4'b0000, HEX1);
	HEX_Decoder empty2 (4'b0000, HEX2);
	HEX_Decoder empty3 (4'b0000, HEX3);
	

endmodule // Part2Top

module ALU (A, B, ALUselect, Output, StoredOutput);

	input [3:0] A, B; // Two 4-bit inputs
	input [2:0] ALUselect; // 3-bit function selector
	input [7:0] StoredOutput; // Output stored on register
	output [7:0] Output; // 8-bit output
	
	wire [4:0] sum;
	fourBitAdder fba(A, B, 0, sum);
	
	/*
		0: A + B using adder
		1: A + B using Verilog '+'
		2: A NAND B on lower 4 bits and A NOR B on upper 4 bits
		3: 8'b11000000 at least one 1
		4: 8'b00111111 if A has two 1s and B has three 1s
		5: B on significant bits and !A on lesser bits
		6: XNOR on lower 4 bits and XOR on upper 4 bits
		7: Retain value
	*/
	
	reg [7:0] ALUout;
	always @(*)
	begin
		case(ALUselect[2:0])
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
			3'b111: // Case 7
				ALUout = StoredOutput;
			default:
				ALUout = 8'b00000000;
		endcase
	end
	
	// Assign output.
	assign Output = ALUout;
	

endmodule // ALU


module DposEdgeFF_8bit (Clock, Reset_b, d, q);

	input Clock, Reset_b;
	input [7:0] d;
	output reg [7:0] q;
	
	always @(posedge Clock)
	begin
		if (Reset_b == 1'b0)
			q <= 0;
		else
			q <= d;
	end

endmodule // DposEdgeFF_8bit
