// Part 2 skeleton

module fill
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,// Your inputs and outputs here
		KEY,							// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input [9:0] SW;
	input	[3:0]	KEY;					
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	ControlPath cp (.Clock(CLOCK_50), .Reset_n(KEY[0]), .Clear(~KEY[2]), .LoadX(~KEY[3]), 
							.Data_In(SW[6:0]), .C_In(SW[9:7]), .X_Out(x), .Y_Out(y),
							.C_Out(colour), .Plot(~KEY[1]), .PlotToVGA(writeEn));
	
endmodule

module ControlPath (Clock, Reset_n, Clear, LoadX, Data_In, C_In, X_Out, Y_Out, C_Out, Plot, PlotToVGA);
	input Clock, Reset_n, Plot, Clear, LoadX;
	input [6:0] Data_In;
	input [2:0] C_In;
	
	output PlotToVGA;
	output [7:0] X_Out;
	output [6:0] Y_Out;
	output [2:0] C_Out;
	
	wire ld_x, ld_y, ld_c, frc;
	wire [1:0] x_inc, y_inc;
	wire [7:0] frc_x;
	wire [6:0] frc_y;
	wire [2:0] frc_c;
	
	Control ctrl (.Clock(Clock), .Plot(Plot), .Clear(Clear), .Reset_n(Reset_n), .LoadX(LoadX), 
							.plot_to_vga(PlotToVGA), .ld_x(ld_x), .ld_y(ld_y), .ld_c(ld_c),
							.x_inc(x_inc), .y_inc(y_inc), .frc(frc), 
							.frc_x(frc_x), .frc_y(frc_y), .frc_c(frc_c)
					 );
					 
	DataPath dp (.Clock(Clock), .Reset_n(Reset_n), .Data_In(Data_In), .C_In(C_In),
							.ld_x(ld_x), .ld_y(ld_y), .ld_c(ld_c), .x_inc(x_inc), .y_inc(y_inc),
							.frc(frc), .frc_x(frc_x), .frc_y(frc_y), .frc_c(frc_c),
							.X_Out(X_Out), .Y_Out(Y_Out), .C_Out(C_Out)
					 );

endmodule

module Control (Clock, Plot, Clear, Reset_n, LoadX, plot_to_vga,
						ld_x, ld_y, ld_c, x_inc, y_inc, frc, frc_x, frc_y, frc_c);
	input Clock, Plot, Clear, Reset_n, LoadX;
	output reg ld_x, ld_y, ld_c, frc, plot_to_vga;
	output reg [2:0] x_inc, y_inc;
	output reg [7:0] frc_x;
	output reg [6:0] frc_y;
	output reg [2:0] frc_c;
	
	localparam  S_REST        	= 4'd0,
               S_LOAD_X   		= 4'd1,
               S_LOAD_X_WAIT  = 4'd2,
               S_LOAD_DATA   	= 4'd3,
               S_PLOT        	= 4'd4,
					S_PLOT_INCR		= 4'd5,
					S_PLOT_END		= 4'd6,
               S_CLEAR   		= 4'd7,
					S_CLEAR_INCR	= 4'd8,
					S_CLEAR_END		= 4'd9;
               
	 reg [3:0] current_state, next_state;
	 reg [1:0] x_inc_count, y_inc_count;
	 reg [7:0] x_clr_count;
	 reg [6:0] y_clr_count;
	 
    
    // Next state logic aka our state table
    always@(posedge Clock)
    begin
		case (current_state)
			 S_REST: next_state = Clear ? S_CLEAR : Plot ? S_LOAD_DATA : LoadX ? S_LOAD_X : S_REST;
			 S_LOAD_X: next_state = S_LOAD_X_WAIT;
			 S_LOAD_X_WAIT: next_state = LoadX ? S_LOAD_X_WAIT : S_REST;
			 S_LOAD_DATA: next_state = S_PLOT;
			 S_PLOT: next_state = S_PLOT_INCR;
			 S_PLOT_INCR: next_state = S_PLOT_END;
			 S_PLOT_END: next_state = (x_inc_count == 2'b0 && y_inc_count == 2'b0) ? S_REST : S_PLOT_INCR;
			 S_CLEAR: next_state = S_CLEAR_INCR;
			 S_CLEAR_INCR: next_state = S_CLEAR_END;
			 S_CLEAR_END: next_state = x_clr_count >= 8'd160 ? S_REST : S_CLEAR_INCR;
		default: next_state = S_REST;
		endcase
	 // End of State Table
		
		ld_x = 0;
		ld_y = 0;
		ld_c = 0;
		plot_to_vga = 0;
		x_inc = 2'b0;
		y_inc = 2'b0;
		frc = 0;
		frc_x = 8'b0;
		frc_y = 7'b0;
		case (current_state)
			S_LOAD_X: ld_x = 1;
			S_LOAD_DATA: begin
				ld_y = 1;
				ld_c = 1;
			end
			S_PLOT: begin
				x_inc_count <= 0;
				y_inc_count <= 0;
			end
			S_PLOT_INCR: begin
				plot_to_vga = 1;
				x_inc = x_inc_count;
				y_inc = y_inc_count;
				y_inc_count = y_inc_count + 1;
				if (y_inc_count == 2'b0)
					x_inc_count = x_inc_count + 1;
			end
			S_CLEAR: begin
				x_clr_count = 8'd0;
				y_clr_count = 7'd0;
			end
			S_CLEAR_INCR: begin
				plot_to_vga = 1;
				frc = 1;
				frc_x = x_clr_count;
				frc_y = y_clr_count;
				frc_c = 3'b0;
				y_clr_count = y_clr_count + 1;
				if (y_clr_count >= 7'd120) begin
					y_clr_count = 0;
					x_clr_count = x_clr_count + 1;
				end
			end
		endcase
		
	// End of signal control
	
		if (~Reset_n)
			current_state = S_REST;
		else
			current_state = next_state;
    end

endmodule

module DataPath (Clock, Reset_n, Data_In, C_In, ld_x, ld_y, ld_c, x_inc, y_inc, 
						frc, frc_x, frc_y, frc_c, X_Out, Y_Out, C_Out);
	input Clock, Reset_n, ld_x, ld_y, ld_c, frc;
	input [1:0] x_inc, y_inc;
	input [2:0] C_In, frc_c;
	input [6:0] Data_In, frc_y;
	input [7:0] frc_x;
	
	output [2:0] C_Out;
	output [6:0] Y_Out;
	output [7:0] X_Out;
	
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] c;
	
	always @(posedge Clock)
	begin
		if (~Reset_n) begin
			x = 8'b0;
			y = 7'b0;
			c = 3'b0;
		end
		else begin
			if (ld_x)
				x = {1'b0, Data_In};
			if (ld_y)
				y = Data_In;
			if (ld_c)
				c = C_In;
		end
	end

	assign X_Out = frc ? frc_x : (x + x_inc);
	assign Y_Out = frc ? frc_y : (y + y_inc);
	assign C_Out = frc ? frc_c : c;

endmodule
