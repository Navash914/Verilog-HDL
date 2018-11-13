

module Monopoly (
		CLOCK_50,						//	On Board 50 MHz
		SW,// Your inputs and outputs here
		KEY,							// On Board Keys
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
		LEDR,
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
	
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;
	
	wire resetn;
	assign resetn = KEY[3];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [23:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire vga_wren;
	
	// ============================================================================
	//
	//  Dice Roll Logic
	//
	// ============================================================================
	
	wire [25:0] d1_freq = 26'd20000000;
	wire [25:0] d2_freq = 26'd30000000;
	wire d1_clk, d2_clk;
	
	GenerateClock d1_c (.inclk(CLOCK_50), .freq(d1_freq), .outclk(d1_clk));
	GenerateClock d2_c (.inclk(CLOCK_50), .freq(d2_freq), .outclk(d2_clk));
	
	wire [2:0] d1_val, d2_val;
	RollDice d1 (.clk(d1_clk), .q(d1_val));
	RollDice d2 (.clk(d2_clk), .q(d2_val));
	
	//HEX_Decoder d1_h ({2'b00, d1_val}, HEX1);
	//HEX_Decoder d2_h ({2'b00, d2_val}, HEX0);
	
	// ============================================================================
	//
	//  RAMs and ROMs
	//
	// ============================================================================
	
	wire [5:0] bd_addr;
	wire [91:0] bd_in, bd_out;
	wire bd_wren;
	
	ram40x92 board_data (
					.address		(bd_addr),
					.clock		(CLOCK_50),
					.data			(bd_in),
					.wren			(bd_wren),
					.q				(bd_out)
				);
				
	wire [15:0] bback_addr;
	//wire [12:0] bback_addr;
	wire [23:0] bback_out;// [8];
	//wire [191:0] bback_out;
	//wire [2:0] bback_out;
	
	/*rom240x240 board_back0(
					.address		(bback_addr),
					.clock		(CLOCK_50),
					.q				(bback_out[0])
				);
	defparam board_back0.load_filename = "Board_back0.mif";
	
	rom240x240 board_back1(
					.address		(bback_addr),
					.clock		(CLOCK_50),
					.q				(bback_out[1])
				);
	defparam board_back1.load_filename = "Board_back1.mif";
	
	rom240x240 board_back2(
					.address		(bback_addr),
					.clock		(CLOCK_50),
					.q				(bback_out[2])
				);
	defparam board_back2.load_filename = "Board_back2.mif";
	
	rom240x240 board_back3(
					.address		(bback_addr),
					.clock		(CLOCK_50),
					.q				(bback_out[3])
				);
	defparam board_back3.load_filename = "Board_back3.mif";
	
	rom240x240 board_back4(
					.address		(bback_addr),
					.clock		(CLOCK_50),
					.q				(bback_out[4])
				);
	defparam board_back4.load_filename = "Board_back4.mif";
	
	
	rom240x240 board_back5(
					.address		(bback_addr),
					.clock		(CLOCK_50),
					//.q				(bback_out[143:120])
					.q				(bback_out[5])
				);
	defparam board_back5.load_filename = "Board_back5.mif";
	
	rom240x240 board_back6(
					.address		(bback_addr),
					.clock		(CLOCK_50),
					//.q				(bback_out[167:144])
					.q				(bback_out[6])
				);
	defparam board_back6.load_filename = "Board_back6.mif";
	
	rom240x240 board_back7(
					.address		(bback_addr),
					.clock		(CLOCK_50),
					//.q				(bback_out[191:168])
					.q				(bback_out[7])
				);
	defparam board_back7.load_filename = "Board_back7.mif";*/
	
	rom_back background (
					.address		(bback_addr),
					.clock		(CLOCK_50),
					.q				(bback_out)
				);
	
	// ============================================================================
	//
	//  Movement Logic
	//
	// ============================================================================
	
	wire [2:0] index;
	wire ld_back;
	wire [23:0] c;
	
	ControlPath cp (.clk(CLOCK_50), .Input(~KEY[0]), .bd_addr(bd_addr), .bd_read(bd_out), .bd_write(bd_in),
							.bback_addr(bback_addr), /*.bback_read(bback_out),*/ .d1(d1_val), .d2(d2_val), 
							.x(x), .y(y), .c(c), .plot(vga_wren), .index(index), .ld_bback(ld_back),
							.hex(HEX0), .hex2(HEX1), .hex3(HEX2), .hex4(HEX3), .hex5(HEX4), .hex6(HEX5)
							);
	
	assign colour = ld_back ? bback_out/*[index]*/ : c;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(vga_wren),
			// Signals for the DAC to drive the monitor.
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "VGA_Background.mif";
		
	

endmodule
