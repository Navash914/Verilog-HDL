

module Monopoly (
		CLOCK_50,						//	On Board 50 MHz
		SW,// Your inputs and outputs here
		KEY,							// On Board Keys
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
		LEDR,
		PS2_CLK,
		PS2_DAT,
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
	inout				PS2_CLK;
	inout				PS2_DAT;
	
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;
	
	wire resetn;
	assign resetn = KEY[3];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [11:0] colour;
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
	RollDice d1_module (.clk(d1_clk), .q(d1_val));
	RollDice d2_module (.clk(d2_clk), .q(d2_val));
	wire [2:0] d1 = SW[8] ? SW[5:3] : d1_val;
	wire [2:0] d2 = SW[8] ? SW[2:0] : d2_val;
	
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
	
	/*ram40x92 board_data (
					.address		(bd_addr),
					.clock		(CLOCK_50),
					.data			(bd_in),
					.wren			(bd_wren),
					.q				(bd_out)
				);*/
				
	wire [16:0] bback_addr;
	wire [14:0] w_addr;
	wire [7:0] p_addr;
	//wire [12:0] bback_addr;
	wire [11:0] bback_out [4];// [8];
	//wire [191:0] bback_out;
	//wire [2:0] bback_out;
	
	/*rom_back background (
					.address		(bback_addr),
					.clock		(CLOCK_50),
					.q				(bback_out)
				);*/
	rom_gameBoard game_board (
					.address		(bback_addr),
					.clock		(CLOCK_50),
					.q				(bback_out[1])
				);
	
	rom_gameTitle title_screen (
					.address		(bback_addr),
					.clock		(CLOCK_50),
					.q				(bback_out[0])
				);
				
	rom_winText win_text (
					.address		(w_addr),
					.clock		(CLOCK_50),
					.q				(bback_out[3])
				);
				
	rom_player players (
					.address		(p_addr),
					.clock		(CLOCK_50),
					.q				(bback_out[2])
				);
				
	// ============================================================================
	//
	//  Input Handling
	//
	// ============================================================================
	
	reg start, play, cancel;
	
	wire [7:0] ps2_key_data;
	wire ps2_key_pressed;
	wire ps2_reset = ~KEY[1];
	wire playInput, startInput, cancelInput;
	
	assign playInput = SW[7] ? ~KEY[0] : play;
	assign startInput = SW[7] ? ~KEY[1] : start;
	assign cancelInput = SW[7] ? ~KEY[2] : cancel;
	
	PS2_Controller PS2 (
		// Inputs
		.CLOCK_50			(CLOCK_50),
		.reset				(ps2_reset),

		// Bidirectionals
		.PS2_CLK				(PS2_CLK),
		.PS2_DAT				(PS2_DAT),

		// Outputs
		.received_data		(ps2_key_data),
		.received_data_en	(ps2_key_pressed)
	);
	
	always @(posedge CLOCK_50)
	begin
		if (ps2_reset) begin
			play <= 0;
			start <= 0;
			cancel <= 0;
		end else if (ps2_key_pressed) begin
			case (ps2_key_data)
				8'h29: play <= 1;
				8'h5A: start <= 1;
				8'h76: cancel <= 1;
			endcase
		end else begin
			play <= 0;
			start <= 0;
			cancel <= 0;
		end
	end
	
	// ============================================================================
	//
	//  Game Logic
	//
	// ============================================================================
	
	wire [2:0] index;
	wire ld_back;
	wire [11:0] c;
	wire [1:0] select_rom;
	
	ControlPath cp (.clk(CLOCK_50), .Input(playInput), .start(startInput), .cancel(cancelInput),
							.w_addr(w_addr), .p_addr(p_addr), .bback_addr(bback_addr), .d1(d1), .d2(d2), 
							.x(x), .y(y), .c(c), .plot(vga_wren), .index(index), .ld_bback(ld_back),
							.fast_fwd(SW[9]), .select_rom(select_rom),
							.hex(HEX0), .hex2(HEX1), .hex3(HEX2), .hex4(HEX3), .hex5(HEX4), .hex6(HEX5)
							);
	
	assign colour = ld_back ? bback_out[select_rom] : c;

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
		//defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 4;
		//defparam VGA.BACKGROUND_IMAGE = "VGA_Background.mif";
		defparam VGA.BACKGROUND_IMAGE = "Title_Screen.mif";
		
	

endmodule
