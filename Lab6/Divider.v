`timescale 1ns/1ns

module Divider (SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [7:0] SW;
	input [1:0] KEY;
	input CLOCK_50;
	output [3:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	wire msbA, ld, Out;
	wire [2:0] op;
	wire [3:0] Q;
	wire [4:0] R;

	Control ctrl (.clk(CLOCK_50), .resetp(~KEY[0]), .go(~KEY[1]), .msb_a(msbA), .load(ld), .operation(op), .out(Out));
	DataPath dp (.clk(CLOCK_50), .resetp(~KEY[0]), .load(ld), .operation(op), .out(Out),
					.dividend_in(SW[7:4]), .divisor_in(SW[3:0]), .msb_a(msbA), .quotient(Q), .remainder(R));
	
	HEX_Decoder dvsr (SW[3:0], HEX0);
	HEX_Decoder dvnd (SW[7:4], HEX2);
	HEX_Decoder qout (Q, HEX4);
	HEX_Decoder rem (R[3:0], HEX5);
	
	HEX_Decoder h0 (4'b0, HEX1);
	HEX_Decoder h1 (4'b0, HEX3);
	assign LEDR[3:0] = Q;

endmodule

module Control (
	input clk, resetp, go, msb_a,
	output reg load, out,
	output reg [2:0] operation
	);

	reg [1:0] counter;
	reg [3:0] currentState, nextState;
	
	localparam S_LOAD_DATA			= 5'd0,
				  S_DATA_WAIT			= 5'd1,
				  S_CYCLE_START		= 5'd2,
				  S_CYCLE_SHIFT		= 5'd3,
				  S_CYCLE_SUB			= 5'd4,
				  S_CYCLE_SET			= 5'd5,
				  S_CYCLE_ADD			= 5'd6,
				  S_CYCLE_END			= 5'd7;
				  
	always @(posedge clk)
	begin
		// State Table:
		case (currentState)
			S_LOAD_DATA: nextState = go ? S_DATA_WAIT : S_LOAD_DATA;
			S_DATA_WAIT: nextState = go ? S_DATA_WAIT : S_CYCLE_START;
			S_CYCLE_START: nextState = S_CYCLE_SHIFT;
			S_CYCLE_SHIFT: nextState = S_CYCLE_SUB;
			S_CYCLE_SUB: nextState = S_CYCLE_SET;
			S_CYCLE_SET: nextState = S_CYCLE_ADD;
			S_CYCLE_ADD: nextState = S_CYCLE_END;
			S_CYCLE_END: nextState = counter == 2'b00 ? S_LOAD_DATA : S_CYCLE_START;
			default: nextState = S_LOAD_DATA;
		endcase
		
		// Signal control
		load = 0;
		out = 0;
		operation = 3'b000;
		case (currentState)
			S_DATA_WAIT: begin
				load = 1;
				counter <= 0;
			end
			S_CYCLE_START: counter <= counter + 1;
			S_CYCLE_SHIFT: operation <= 3'b001;
			S_CYCLE_SUB: operation <= 3'b011;
			S_CYCLE_SET: operation <= 3'b100;
			S_CYCLE_ADD: begin
				if (msb_a)
					operation <= 3'b010;
				else
					operation <= 3'b000;
			end
			S_CYCLE_END: out = counter == 2'b00 ? 1 : 0;
		endcase
		
		// State assignment
		if (resetp)
			currentState <= S_LOAD_DATA;
		else
			currentState <= nextState;
	end
	
endmodule

module DataPath (
	input clk, resetp, load, out,
	input [2:0] operation,
	input [3:0] dividend_in, divisor_in,
	output msb_a,
	output reg [3:0] quotient,
	output reg [4:0] remainder
	);
	
	reg [3:0] dividend, dividend_tmp, divisor;
	reg [4:0] A;
	reg [8:0] temp;
	
	
	always @(posedge clk)
	begin
		// Get data
		if (resetp) begin
			A <= 5'b0;
			dividend <= 4'b0;
			divisor <= 4'b0;
		end
		else if (load) begin
			A <= 5'b0;
			dividend <= dividend_in;
			divisor <= divisor_in;
		end
		else begin
			// Perform operation
			temp = {A[3:0], dividend[3:0], 1'b0};
			case (operation)
				3'b001: begin
					A <= temp[8:4];
					dividend <= temp[3:0];
				end
				3'b010: A <= A + divisor;
				3'b011: A <= A - divisor;
				3'b100: dividend[0] = ~A[4];
			endcase
		end
	end
	
	// Assign outputs
	assign msb_a = A[4];
	
	always @(*)
	begin
		if (resetp) begin
			quotient <= 0;
			remainder <= 0;
		end
		else if (out) begin
			quotient <= dividend;
			remainder <= A;
		end
	end
	
endmodule
