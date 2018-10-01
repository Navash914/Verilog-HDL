`timescale 1ns/1ns

module mux(SW, LEDR); // Top Level

	input [9:0] SW;
	output [0:0] LEDR;
	
	mux7to1 m (SW[9:7], SW[6:0], LEDR[0]);

endmodule

module mux7to1(MuxSelect, Input, Output);

	input [2:0] MuxSelect;
	input [6:0] Input;
	output Output;
	
	reg Out;
	
	always @(*)
	begin
		case(MuxSelect[2:0])
			3'b000: Out = Input[0];
			3'b001: Out = Input[1];
			3'b010: Out = Input[2];
			3'b011: Out = Input[3];
			3'b100: Out = Input[4];
			3'b101: Out = Input[5];
			3'b110: Out = Input[6];
			default: Out = 0;
		endcase
	end // end always
	
	assign Output = Out;

endmodule
