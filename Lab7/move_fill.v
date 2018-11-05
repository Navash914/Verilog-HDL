
module move_fill
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,// Your inputs and outputs here
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
	input [9:7] SW;
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
	
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire WriteEn;
	
	ControlPath2 cp2 (.Clock(CLOCK_50), .C_In(SW[9:7]), .X_Out(x), .Y_Out(y),
							.C_Out(colour), .PlotToVGA(WriteEn));
	
	vga_adapter VGA2(
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
		defparam VGA2.RESOLUTION = "160x120";
		defparam VGA2.MONOCHROME = "FALSE";
		defparam VGA2.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA2.BACKGROUND_IMAGE = "black.mif";

endmodule

module RateController (input Clock, Enable, Clear_b, ParLoad, input [25:0] D, MaxValue, output reg [25:0] Q);

	always @(posedge Clock)
	begin
		if (Clear_b == 1'b1)
			Q <= 0;
		else if (ParLoad == 1'b1)
			Q <= D;
		else if (Q >= MaxValue)
			Q <= 0;
		else if (Enable == 1'b1)
			Q <= Q + 1;
	end

endmodule

module ControlPath2 (Clock, C_In, X_Out, Y_Out, C_Out, PlotToVGA);
	input Clock;
	input [2:0] C_In;
	
	output PlotToVGA;
	output [7:0] X_Out;
	output [6:0] Y_Out;
	output [2:0] C_Out;
	
	wire ld_x, ld_y, ld_c, frc;
	wire [1:0] x_inc, y_inc;
	wire [2:0] frc_c;
	
	wire [25:0] ClockFrequency, Frequency, RateDivider, Max;
	wire [3:0] FrameDivider;
	wire Update, Clear, Reset, FrameEnable;
	assign ClockFrequency = 26'd50000000;
	assign Frequency = 26'd60;
	assign Max = (ClockFrequency / Frequency) - 1'b1;
	
	RateController rc (.Clock(CLOCK_50), .Enable(1), .Clear_b(Clear), .ParLoad(0), .D(26'b0), .MaxValue(Max), .Q(RateDivider));
	assign FrameEnable = RateDivider == 26'b0 ? 1 : 0;
	RateController fc (.Clock(CLOCK_50), .Enable(FrameEnable), .Clear_b(Clear), .ParLoad(0), .D(26'b0), .MaxValue(4'b1111), .Q(FrameDivider));
	assign Update = FrameDivider == 4'b1111 ? 1 : 0;
	
	wire [7:0] X_Pos;
	wire [6:0] Y_Pos;
	wire Right, Down;
	
	Control2 ctrl2 (.Clock(Clock), .Update(Update), .X_Pos(X_Pos), .Y_Pos(Y_Pos), .Right(Right),
							.Down(Down), .clr(Clear), .plot_to_vga(PlotToVGA), .ld_x(ld_x), .ld_y(ld_y), 
							.ld_c(ld_c), .x_inc(x_inc), .y_inc(y_inc), .frc(frc), .frc_c(frc_c), .reset(Reset)
					 );
					 
	DataPath2 dp2 (.Clock(Clock), .Reset(Reset), .C_In(C_In), .Right(Right), .Down(Down),
							.X_Pos(X_Pos), .Y_Pos(Y_Pos), .ld_x(ld_x), .ld_y(ld_y), .ld_c(ld_c), 
							.x_inc(x_inc), .y_inc(y_inc), .frc(frc), .frc_c(frc_c),
							.X_Out(X_Out), .Y_Out(Y_Out), .C_Out(C_Out)
					 );

endmodule

module Control2 (Clock, Update, X_Pos, Y_Pos, Right, Down,
						clr, plot_to_vga, ld_x, ld_y, ld_c, 
						x_inc, y_inc, frc, frc_c, reset);
	input Clock, Update;
	input [7:0] X_Pos;
	input [6:0] Y_Pos;
	output Right, Down;
	output reg reset;
	output reg ld_x, ld_y, ld_c, frc, clr, plot_to_vga;
	output reg [2:0] x_inc, y_inc;
	output reg [2:0] frc_c;
	
	localparam  S_RESET_ALL		= 4'd0,
					S_REST        	= 4'd1,
					S_CLEAR   		= 4'd2,
					S_CLEAR_INCR	= 4'd3,
					S_CLEAR_END		= 4'd4,
					S_UPDATE_DIR	= 4'd5,
					S_UPDATE_POS	= 4'd6,
               S_PLOT        	= 4'd7,
					S_PLOT_INCR		= 4'd8,
					S_PLOT_END		= 4'd9,
					S_RESET_COUNT	= 4'd10;
               
	 reg [3:0] current_state, next_state;
	 reg [3:0] inc_count;
	 reg right, down;
	 
    
    // Next state logic aka our state table
    always@(posedge Clock)
    begin
		case (current_state)
			 S_RESET_ALL: next_state = S_REST;
			 S_REST: next_state = Update ? S_CLEAR : S_REST;
			 S_CLEAR: next_state = S_CLEAR_INCR;
			 S_CLEAR_INCR: next_state = S_CLEAR_END;
			 S_CLEAR_END: next_state = inc_count == 4'b0 ? S_UPDATE_DIR : S_CLEAR_INCR;
			 S_UPDATE_DIR: next_state = S_UPDATE_POS;
			 S_UPDATE_POS: next_state = S_PLOT;
			 S_PLOT: next_state = S_PLOT_INCR;
			 S_PLOT_INCR: next_state = S_PLOT_END;
			 S_PLOT_END: next_state = inc_count == 4'b0 ? S_RESET_COUNT : S_PLOT_INCR;
			 S_RESET_COUNT: next_state = S_REST;
			 
		default: next_state = S_RESET_ALL;
		endcase
	 // End of State Table
		
		ld_x = 0;
		ld_y = 0;
		plot_to_vga = 0;
		x_inc = 2'b0;
		y_inc = 2'b0;
		frc = 0;
		clr = 1;
		reset = 0;
		case (current_state)
			S_RESET_ALL: begin
				reset = 1;
				right <= 0;
				down <= 1;
			end
			S_CLEAR: inc_count = 4'd0;
			S_CLEAR_INCR: begin
				plot_to_vga = 1;
				frc = 1;
				frc_c = 3'b0;
				x_inc = inc_count[3:2];
				y_inc = inc_count[1:0];
				inc_count = inc_count + 1;
			end
			S_UPDATE_DIR: begin
				if (right == 1 && (X_Pos + 8'd4) >= 8'd160)
					right <= 0;
				else if (right == 0 && X_Pos == 8'b0)
					right <= 1;
				if (down == 1 && (Y_Pos + 7'd4) >= 7'd120)
					down <= 0;
				else if (down == 0 && Y_Pos == 7'd0)
					down <= 1;
			end
			S_UPDATE_POS: begin
				ld_x = 1;
				ld_y = 1;
				ld_c = 1;
			end
			S_PLOT: inc_count = 4'd0;
			S_PLOT_INCR: begin
				plot_to_vga = 1;
				x_inc = inc_count[3:2];
				y_inc = inc_count[1:0];
				inc_count = inc_count + 1;
			end
			S_RESET_COUNT: clr = 1;
		endcase
		
	// End of signal control
	
		current_state = next_state;
    end // End of Always Block
	 
	 assign Right = right;
	 assign Down = down;

endmodule

module DataPath2 (Clock, Reset, C_In, Right, Down, X_Pos, Y_Pos,
						ld_x, ld_y, ld_c, x_inc, y_inc, 
						frc, frc_c, X_Out, Y_Out, C_Out);
	input Clock, Reset, Right, Down;
	input ld_x, ld_y, ld_c, frc;
	input [1:0] x_inc, y_inc;
	input [2:0] C_In, frc_c;
	
	output [2:0] C_Out;
	output [6:0] Y_Out, Y_Pos;
	output [7:0] X_Out, X_Pos;
	
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] c;
	
	always @(posedge Clock)
	begin
		if (Reset) begin
			x <= 8'd160;
			y <= 7'b0;
			c <= 3'b0;
		end
		else begin
			if (ld_x) begin
				if (Right)
					x <= x + 1'b1;
				else
					x <= x - 1'b1;
			end
			if (ld_y) begin
				if (Down)
					y <= y + 1'b1;
				else
					y <= y - 1'b1;
			end
			if (ld_c)
				c <= C_In;
		end
	end

	assign X_Pos = x;
	assign Y_Pos = y;
	
	assign X_Out = x + x_inc;
	assign Y_Out = y + y_inc;
	assign C_Out = frc ? frc_c : c;

endmodule
