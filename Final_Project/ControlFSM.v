module ControlFSM (clk, Input, start, cancel, playerSpot, d1_val, d2_val, Right, Down, reset, plot_to_vga,
							ld_x, ld_y, ld_back, ld_spot, x_mv, y_mv, playerTurn, x_inc, y_inc,
							moveSpaces, scoreChange, ld_score, ld_progress, sc_neg, playerProgress,
							ld_dp, sc_clr, dp_x_inc, dp_y_inc, playerScore, dg, ld_dp_p, draw_win,
							sc_dg_0, sc_dg_1, sc_dg_2, sc_dg_3, fast_fwd, draw_dice, dice_clr, dice_num,
							frc, frc_x, frc_y, select_rom,
							hex, hex2
							);
	input clk, Input, start, cancel, fast_fwd;
	
	input [31:0] playerProgress;
	input [12:0] playerScore;
	input [5:0] moveSpaces;
	input [4:0] playerSpot;
	input [2:0] d1_val, d2_val;
	input [3:0] sc_dg_0, sc_dg_1, sc_dg_2, sc_dg_3;
	
	output [6:0] hex, hex2;
	output Right, Down;
	output reg reset, plot_to_vga, ld_dp_p, draw_win;
	output reg ld_x, ld_y, ld_back, ld_spot, ld_score, ld_progress, ld_dp;
	output reg x_mv, y_mv, sc_neg, sc_clr;
	output reg [8:0] scoreChange;
	output reg [2:0] playerTurn;
	output reg [2:0] x_inc, y_inc;
	output reg [7:0] dp_x_inc, dp_y_inc;
	output reg [1:0] dg;
	output reg draw_dice, dice_clr, dice_num;
	output reg frc;
	output reg [1:0] select_rom;
	output reg [8:0] frc_x;
	output reg [7:0] frc_y;
	
	reg [3:0] finished;
	reg frc_change_turn;
	reg ffwd;
	wire [4:0] scorePos = 5'd20;
	wire [4:0] scoreNeg = 5'd20;
	wire [2:0] max = d1 > d2 ? d1 : d2;
	
	wire [48:0] digit [10];
	
	assign digit[0] = 49'b0011100_0100010_0100010_0100010_0100010_0100010_0011100;
	assign digit[1] = 49'b0001000_0011000_0001000_0001000_0001000_0001000_0111110;
	assign digit[2] = 49'b0011100_0100010_0000010_0000100_0011000_0100000_0111110;
	assign digit[3] = 49'b0011100_0100010_0000010_0001100_0000010_0100010_0011100;
	assign digit[4] = 49'b0000100_0001100_0010100_0100100_0111110_0000100_0000100;
	assign digit[5] = 49'b0111110_0100000_0100000_0111100_0000010_0100010_0011100;
	assign digit[6] = 49'b0011100_0100010_0100000_0111100_0100010_0100010_0011100;
	assign digit[7] = 49'b0111110_0000010_0000010_0000100_0001000_0001000_0001000;
	assign digit[8] = 49'b0011100_0100010_0100010_0011100_0100010_0100010_0011100;
	assign digit[9] = 49'b0011100_0100010_0100010_0011110_0000010_0100010_0011100;
	
	wire [288:0] dice [7];
	
	assign dice[1] = { {17{1'b1}}, 
							 {6{1'b1, {15{1'b0}}, 1'b1}}, 
							 {3{1'b1, {6{1'b0}}, {3{1'b1}}, {6{1'b0}}, 1'b1}}, 
							 {6{1'b1, {15{1'b0}}, 1'b1}}, 
							 {17{1'b1}} };
	assign dice[2] = { {17{1'b1}}, 
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {3{1'b1, {2{1'b0}}, {3{1'b1}}, {10{1'b0}}, 1'b1}}, 
							 {5{1'b1, {15{1'b0}}, 1'b1}}, 
							 {3{1'b1, {10{1'b0}}, {3{1'b1}}, {2{1'b0}}, 1'b1}}, 
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {17{1'b1}} };
	assign dice[3] = { {17{1'b1}}, 
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {3{1'b1, {10{1'b0}}, {3{1'b1}}, {2{1'b0}}, 1'b1}}, 
							 {1'b1, {15{1'b0}}, 1'b1}, 
							 {3{1'b1, {6{1'b0}}, {3{1'b1}}, {6{1'b0}}, 1'b1}}, 
							 {1'b1, {15{1'b0}}, 1'b1}, 
							 {3{1'b1, {2{1'b0}}, {3{1'b1}}, {10{1'b0}}, 1'b1}}, 
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {17{1'b1}} };
	assign dice[4] = { {17{1'b1}}, 
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {3{1'b1, {2{1'b0}}, {3{1'b1}}, {5{1'b0}}, {3{1'b1}}, {2{1'b0}}, 1'b1}}, 
							 {5{1'b1, {15{1'b0}}, 1'b1}}, 
							 {3{1'b1, {2{1'b0}}, {3{1'b1}}, {5{1'b0}}, {3{1'b1}}, {2{1'b0}}, 1'b1}}, 
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {17{1'b1}} };
	assign dice[5] = { {17{1'b1}}, 
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {3{1'b1, {2{1'b0}}, {3{1'b1}}, {5{1'b0}}, {3{1'b1}}, {2{1'b0}}, 1'b1}}, 
							 {1'b1, {15{1'b0}}, 1'b1},
							 {3{1'b1, {6{1'b0}}, {3{1'b1}}, {6{1'b0}}, 1'b1}}, 
							 {1'b1, {15{1'b0}}, 1'b1}, 
							 {3{1'b1, {2{1'b0}}, {3{1'b1}}, {5{1'b0}}, {3{1'b1}}, {2{1'b0}}, 1'b1}}, 
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {17{1'b1}} };
	assign dice[6] = { {17{1'b1}}, 
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {3{1'b1, {2{1'b0}}, {3{1'b1}}, 1'b0, {3{1'b1}}, 1'b0, {3{1'b1}}, {2{1'b0}}, 1'b1}}, 
							 {5{1'b1, {15{1'b0}}, 1'b1}}, 
							 {3{1'b1, {2{1'b0}}, {3{1'b1}}, 1'b0, {3{1'b1}}, 1'b0, {3{1'b1}}, {2{1'b0}}, 1'b1}},
							 {2{1'b1, {15{1'b0}}, 1'b1}}, 
							 {17{1'b1}} };
	
	wire [8:0] spotScores [32];
	
	assign spotScores[1] = 9'd5;
	assign spotScores[3] = 9'd15;
	assign spotScores[5] = 9'd15;
	assign spotScores[6] = 9'd10;
	assign spotScores[7] = 9'd20;
	assign spotScores[9] = 9'd20;
	assign spotScores[10] = 9'd30;
	assign spotScores[11] = 9'd30;
	assign spotScores[13] = 9'd40;
	assign spotScores[14] = 9'd40;
	assign spotScores[15] = 9'd50;
	assign spotScores[16] = 9'd150;
	assign spotScores[17] = 9'd40;
	assign spotScores[18] = 9'd40;
	assign spotScores[19] = 9'd40;
	assign spotScores[21] = 9'd10;
	assign spotScores[22] = 9'd60;
	assign spotScores[23] = 9'd60;
	assign spotScores[24] = 9'd300;
	assign spotScores[25] = 9'd10;
	assign spotScores[26] = 9'd30;
	assign spotScores[27] = 9'd60;
	assign spotScores[29] = 9'd80;
	assign spotScores[31] = 9'd80;
	
	
	reg f_clk_en, f_clk_reset;
	wire frameClkEnable, frameClkReset, frameDivider;
	assign frameClkEnable = f_clk_en;
	assign frameClkReset = f_clk_reset | reset;
	
	wire [25:0] ClockFrequency = 26'd50000000;
	wire [25:0] Frequency = ffwd ? 26'd600 : 26'd60;
	wire [25:0] Max = (ClockFrequency / Frequency);
	wire [25:0] RateDivider;
	
	
	//GenerateClock frame_clk (.inclk(clk), .freq(26'd60), .enable(frameClkEnable), .reset(frameClkReset), .outclk(frameClk));
	RateController fc (.Clock(clk), .Enable(frameClkEnable), .Clear_b(frameClkReset), .ParLoad(0), .D(26'b0),
								.MaxValue(Max), .Q(RateDivider));
								
	assign frameDivider = (frameClkEnable && RateDivider == Max) ? 1 : 0;

	localparam  S_TITLE						= 6'd0,
					S_DRAW_BOARD				= 6'd51,
					S_DRAW_BOARD_INCR			= 6'd52,
					S_DRAW_BOARD_END			= 6'd53,
					S_DRAW_TITLE				= 6'd54,
					S_DRAW_TITLE_INCR			= 6'd55,
					S_DRAW_TITLE_END			= 6'd56,
					S_RESET_ALL					= 6'd50,
					S_DRAW_ALL_PLAYERS		= 6'd57,
					S_WAIT_FOR_INPUT     	= 6'd1,
					S_WAIT_FOR_INPUT_OFF		= 6'd17,
					S_ROLL_DICE					= 6'd2,
					S_PLOT_D1					= 6'd40,
					S_PLOT_D_INCR				= 6'd41,
					S_PLOT_D_END				= 6'd42,
					S_PLOT_D2					= 6'd43,
					S_CLEAR_D1					= 6'd46,
					S_CLEAR_D_INCR				= 6'd47,
					S_CLEAR_D_END				= 6'd48,
					S_CLEAR_D2					= 6'd49,
					S_START_MOVE				= 6'd3,
					S_CLEAR	   				= 6'd4,
					S_CLEAR_INCR				= 6'd5,
					S_CLEAR_END					= 6'd6,
					S_UPDATE_DIR				= 6'd7,
					S_START_FRAME_CLK			= 6'd16,
					S_WAIT_0						= 6'd18,
					S_WAIT_1						= 6'd19,
					S_WAIT_2						= 6'd20,
					S_UPDATE_POS				= 6'd8,
               S_PLOT	        			= 6'd9,
					S_PLOT_INCR					= 6'd10,
					S_PLOT_END					= 6'd11,
					S_RESET_COUNT				= 6'd12,
					S_END_MOVE					= 6'd13,
					S_WAIT_FOR_CHANGES		= 6'd34,
					S_ACTION_AT_STOP			= 6'd14,
					S_WAIT_FOR_CHANGES_2		= 6'd35,
					S_LOAD_SCORE				= 6'd33,
					S_LOAD_PROGRESS			= 6'd36,
					S_PLOT_PROGRESS			= 6'd21,
					S_PLOT_PROGRESS_INCR		= 6'd22,
					S_PLOT_PROGRESS_END		= 6'd23,
					S_CLEAR_SCORE				= 6'd24,
					S_CLEAR_SCORE_INCR		= 6'd25,
					S_CLEAR_SCORE_END			= 6'd26,
					S_PLOT_SC_DIG_0			= 6'd27,
					S_PLOT_SC_DIG_1			= 6'd28,
					S_PLOT_SC_DIG_2			= 6'd29,
					S_PLOT_SC_DIG_3			= 6'd30,
					S_PLOT_SC_INCR				= 6'd31,
					S_PLOT_SC_END				= 6'd32,
					S_CHANGE_PLAYER			= 6'd15,
					S_CHECK_CHANGE_PLAYER	= 6'd39,
					S_CHECK_GAME_END			= 6'd37,
					S_DRAW_WIN_TEXT			= 6'd58,
					S_DRAW_WIN_TEXT_INCR		= 6'd59,
					S_DRAW_WIN_TEXT_END		= 6'd60,
					S_GAME_END					= 6'd38;
					
	 wire [4:0] cs = current_state;
	 wire [3:0] mc = moveCount;
	 HEX_Decoder h (d1, hex);
	 HEX_Decoder h2 (d2, hex2);
               
	 reg [5:0] current_state, next_state;
	 reg [5:0] inc_count;
	 reg [4:0] clr_inc_count_x;
	 reg [2:0] clr_inc_count_y;
	 reg [8:0] frc_inc_count_x;
	 reg [7:0] frc_inc_count_y;
	 reg [7:0] win_inc_count_x;
	 reg [5:0] win_inc_count_y;
	 reg [4:0] dice_inc_count_x, dice_inc_count_y;
	 reg [2:0] sc_inc_count_x, sc_inc_count_y;
	 reg [2:0] prog_inc_count;
	 reg [2:0] d1, d2;
	 reg [3:0] moveCount;
	 reg [5:0] pixelsMoved;
	 reg right, down;
	 reg player_draw_start;
	 reg [5:0] stored_state;
	 reg drawProgress;
	 reg [48:0] sc_digit;
	 reg [288:0] dice_digit;
    
    // Next state logic aka our state table
    always@(posedge clk)
    begin
		case (current_state)
			 S_TITLE: next_state = start ? S_DRAW_BOARD : S_TITLE;
			 S_DRAW_BOARD: next_state = S_DRAW_BOARD_INCR;
			 S_DRAW_BOARD_INCR: next_state = S_WAIT_0;
			 S_DRAW_BOARD_END: next_state = frc_inc_count_x == 0 && frc_inc_count_y == 0 ? S_RESET_ALL : S_DRAW_BOARD_INCR;
			 S_DRAW_TITLE: next_state = S_DRAW_TITLE_INCR;
			 S_DRAW_TITLE_INCR: next_state = S_WAIT_0;
			 S_DRAW_TITLE_END: next_state = frc_inc_count_x == 0 && frc_inc_count_y == 0 ? S_TITLE : S_DRAW_TITLE_INCR;
			 //S_RESET_ALL: next_state = S_PLOT;
			 S_RESET_ALL: next_state = S_DRAW_ALL_PLAYERS;
			 S_DRAW_ALL_PLAYERS: next_state = player_draw_start && playerTurn == 0 ? S_WAIT_FOR_INPUT : S_PLOT;
			 S_WAIT_FOR_INPUT: next_state = ffwd ? S_ROLL_DICE : cancel ? S_DRAW_TITLE : Input ? S_WAIT_FOR_INPUT_OFF : S_WAIT_FOR_INPUT;
			 S_WAIT_FOR_INPUT_OFF: next_state = Input ? S_WAIT_FOR_INPUT_OFF : S_ROLL_DICE;
			 S_ROLL_DICE: next_state = S_CLEAR_D1;
			 
			 S_PLOT_D1: next_state = S_PLOT_D_INCR;
			 S_PLOT_D2: next_state = S_PLOT_D_INCR;
			 S_PLOT_D_INCR: next_state = S_PLOT_D_END;
			 S_PLOT_D_END: next_state = dice_inc_count_x != 0 || dice_inc_count_y != 0 ? S_PLOT_D_INCR : dice_num == 0 ? S_PLOT_D2 : S_START_MOVE;
			 
			 S_CLEAR_D1: next_state = S_CLEAR_D_INCR;
			 S_CLEAR_D2: next_state = S_CLEAR_D_INCR;
			 S_CLEAR_D_INCR: next_state = S_CLEAR_D_END;
			 S_CLEAR_D_END: next_state = dice_inc_count_x != 0 || dice_inc_count_y != 0 ? S_CLEAR_D_INCR : dice_num == 0 ? S_CLEAR_D2 : S_PLOT_D1;
			 
			 
			 /*S_START_MOVE: next_state = S_CLEAR;
			 S_CLEAR: next_state = S_CLEAR_INCR;
			 S_CLEAR_INCR: next_state = S_CLEAR_END;
			 S_CLEAR_END: next_state = inc_count == 4'b0 ? S_UPDATE_DIR : S_CLEAR_INCR;
			 S_UPDATE_DIR: next_state = S_START_FRAME_CLK;
			 S_START_FRAME_CLK: next_state = frameDivider ? S_UPDATE_POS : S_START_FRAME_CLK;
			 S_UPDATE_POS: next_state = S_PLOT;*/
			 S_START_MOVE: next_state = S_START_FRAME_CLK;
			 S_START_FRAME_CLK: next_state = frameDivider ? S_CLEAR : S_START_FRAME_CLK;
			 S_CLEAR: next_state = S_CLEAR_INCR;
			 //S_CLEAR_INCR: next_state = S_CLEAR_END;
			 S_CLEAR_INCR: next_state = S_WAIT_0;
			 S_CLEAR_END: next_state = inc_count == 6'b0 ? S_UPDATE_DIR : S_CLEAR_INCR;
			 S_UPDATE_DIR: next_state = S_UPDATE_POS;
			 S_UPDATE_POS: next_state = S_PLOT;
			 S_PLOT: next_state = S_PLOT_INCR;
			 //S_PLOT_INCR: next_state = S_PLOT_END;
			 S_PLOT_INCR: next_state = S_WAIT_0;
			 S_PLOT_END: next_state = inc_count == 6'b0 ? S_RESET_COUNT : S_PLOT_INCR;
			 S_WAIT_0: next_state = S_WAIT_1;
			 S_WAIT_1: next_state = S_WAIT_2;
			 S_WAIT_2: next_state = /*isClear ? S_CLEAR_END : S_PLOT_END*/ stored_state;
			 S_RESET_COUNT: next_state = reset ? S_CHANGE_PLAYER : pixelsMoved >= (moveSpaces - 1'b1) ? S_END_MOVE : S_START_FRAME_CLK;
			 //S_END_MOVE: next_state = moveCount > 4'b0 ? S_START_MOVE : S_WAIT_FOR_CHANGES;
			 S_END_MOVE: begin
				if (playerSpot == 5'd31 && &{playerProgress[1], playerProgress[3], playerProgress[7:5], playerProgress[11:9],
						playerProgress[15:13], playerProgress[19:17], playerProgress[23:21], 
						playerProgress[27:25], playerProgress[29], playerProgress[31]})
				begin
					finished[playerTurn] <= 1;
					next_state = S_CHECK_GAME_END;
				end else next_state = moveCount > 4'b0 ? S_START_MOVE : S_WAIT_FOR_CHANGES;
			 end
			 S_WAIT_FOR_CHANGES: next_state = S_ACTION_AT_STOP;
			 //S_ACTION_AT_STOP: next_state = S_CHANGE_PLAYER;
			 //S_ACTION_AT_STOP: next_state = S_PLOT_PROGRESS;
			 //S_ACTION_AT_STOP: next_state = S_LOAD_SCORE;
			 S_ACTION_AT_STOP: next_state = S_WAIT_FOR_CHANGES_2;
			 S_WAIT_FOR_CHANGES_2: next_state = S_LOAD_SCORE;
			 S_LOAD_SCORE: next_state = S_PLOT_PROGRESS;
			 //S_LOAD_SCORE: next_state = S_LOAD_PROGRESS;
			 //S_LOAD_PROGRESS: next_state = S_PLOT_PROGRESS;
			 S_LOAD_PROGRESS: next_state = S_CLEAR_SCORE;
			 S_PLOT_PROGRESS: next_state = S_PLOT_PROGRESS_INCR;
			 S_PLOT_PROGRESS_INCR: next_state = S_PLOT_PROGRESS_END;
			 S_PLOT_PROGRESS_END: next_state = prog_inc_count == 3'b0 ? S_CLEAR_SCORE : S_PLOT_PROGRESS_INCR;
			 //S_PLOT_PROGRESS_END: next_state = prog_inc_count == 3'b0 ? S_LOAD_PROGRESS : S_PLOT_PROGRESS_INCR;
			 
			 S_CLEAR_SCORE: next_state = S_CLEAR_SCORE_INCR;
			 S_CLEAR_SCORE_INCR: next_state = S_CLEAR_SCORE_END;
			 S_CLEAR_SCORE_END: next_state = clr_inc_count_x == 0 && clr_inc_count_y == 0 ? S_PLOT_SC_DIG_0 : S_CLEAR_SCORE_INCR;
			 S_PLOT_SC_DIG_0: next_state = playerScore > 13'd999 ? S_PLOT_SC_INCR : S_PLOT_SC_DIG_1;
			 S_PLOT_SC_DIG_1: next_state = playerScore > 13'd99 ? S_PLOT_SC_INCR : S_PLOT_SC_DIG_2;
			 S_PLOT_SC_DIG_2: next_state = playerScore > 13'd9 ? S_PLOT_SC_INCR : S_PLOT_SC_DIG_3;
			 S_PLOT_SC_DIG_3: next_state = S_PLOT_SC_INCR;
			 S_PLOT_SC_INCR: next_state = S_PLOT_SC_END;
			 S_PLOT_SC_END: begin
				if (sc_inc_count_x == 0 && sc_inc_count_y == 0) begin
					if (dg == 2'd0)
						next_state = S_PLOT_SC_DIG_1;
					else if (dg == 2'd1)
						next_state = S_PLOT_SC_DIG_2;
					else if (dg == 2'd2)
						next_state = S_PLOT_SC_DIG_3;
					else
						next_state = S_CHANGE_PLAYER;
				end else
					next_state = S_PLOT_SC_INCR;
			 end
			 //next_state = sc_inc_count_x == 0 && sc_inc_count_y == 0 ? S_CHANGE_PLAYER : S_PLOT_SC_INCR;
			 
			 S_CHANGE_PLAYER: next_state = reset ? /*S_RESET_ALL*/ S_DRAW_ALL_PLAYERS : S_CHECK_CHANGE_PLAYER;
			 S_CHECK_CHANGE_PLAYER: next_state = finished[playerTurn] ? S_CHANGE_PLAYER : S_WAIT_FOR_INPUT;
			 
			 S_CHECK_GAME_END: next_state = &finished ? S_DRAW_WIN_TEXT : S_CHANGE_PLAYER;
			 S_DRAW_WIN_TEXT: next_state = S_DRAW_WIN_TEXT_INCR;
			 S_DRAW_WIN_TEXT_INCR: next_state = S_WAIT_0;
			 S_DRAW_WIN_TEXT_END: next_state = win_inc_count_x == 0 && win_inc_count_y == 0 ? S_GAME_END : S_DRAW_WIN_TEXT_INCR;
			 S_GAME_END: next_state = cancel ? S_DRAW_TITLE : S_GAME_END;
			 
		default: next_state = S_TITLE;
		endcase
	 // End of State Table
		
		ld_x = 0;
		ld_y = 0;
		ld_score = 0;
		ld_progress = 0;
		//ld_back = 0;
		ld_spot = 0;
		plot_to_vga = 0;
		case (current_state)
			S_TITLE: begin
				playerTurn <= 0;
				//reset <= 1;
			end
			S_DRAW_BOARD: begin
				frc <= 1;
				ld_back <= 1;
				ld_dp <= 1;
				//reset <= 0;
				select_rom <= 1;
				stored_state <= S_DRAW_BOARD_END;
				frc_inc_count_x <= 0;
				frc_inc_count_y <= 0;
			end
			S_DRAW_BOARD_INCR: begin
				frc_x <= frc_inc_count_x;
				frc_y <= frc_inc_count_y;
				plot_to_vga <= 1;
				frc_inc_count_x = frc_inc_count_x + 1;
				if (frc_inc_count_x >= 320) begin
					frc_inc_count_x = 0;
					frc_inc_count_y = frc_inc_count_y + 1;
					if (frc_inc_count_y >= 240)
						frc_inc_count_y = 0;
				end
			end
			S_DRAW_TITLE: begin
				frc <= 1;
				ld_back <= 1;
				ld_dp <= 1;
				select_rom <= 0;
				stored_state <= S_DRAW_TITLE_END;
				frc_inc_count_x <= 0;
				frc_inc_count_y <= 0;
			end
			S_DRAW_TITLE_INCR: begin
				frc_x <= frc_inc_count_x;
				frc_y <= frc_inc_count_y;
				plot_to_vga <= 1;
				frc_inc_count_x = frc_inc_count_x + 1;
				if (frc_inc_count_x >= 320) begin
					frc_inc_count_x = 0;
					frc_inc_count_y = frc_inc_count_y + 1;
					if (frc_inc_count_y >= 240)
						frc_inc_count_y = 0;
				end
			end
			S_RESET_ALL: begin
				//reset = 1;
				frc <= 0;
				right <= 0;
				down <= 0;
				x_mv = 1;
				y_mv = 0;
				ld_dp <= 0;
				ld_back <= 0;
				drawProgress <= 0;
				draw_win <= 0;
				finished <= 0;
				ffwd <= 0;
				frc_change_turn <= 0;
				player_draw_start <= 0;
				reset <= 1;
				/*
				if (playerTurn == 3'd0 && ~reset)
					reset = 1;
				else if (playerTurn == 3'd0 && reset)
					next_state = S_WAIT_FOR_INPUT;
				*/
			end
			S_DRAW_ALL_PLAYERS: player_draw_start <= 1;
			S_WAIT_FOR_INPUT: begin
				reset <= 0;
				ld_back <= 0;
				f_clk_en <= 1;
				f_clk_reset <= 0;
				frc_change_turn <= 0;
				ffwd <= fast_fwd;
				ld_dp <= 0;
				draw_dice <= 0;
			end
			S_ROLL_DICE: begin
				d1 <= d1_val;
				d2 <= d2_val;
				//d2 <= 0;
				moveCount <= d1_val + d2_val;
			end
			
			S_PLOT_D1: begin
				dice_inc_count_x <= 0;
				dice_inc_count_y <= 0;
				dp_x_inc <= 0;
				dp_y_inc <= 0;
				dice_digit <= dice[d1];
				dice_clr <= 0;
				dice_num <= 0;
				ld_dp <= 1;
				draw_dice <= 1;
			end
			S_PLOT_D2: begin
				dice_inc_count_x <= 0;
				dice_inc_count_y <= 0;
				dp_x_inc <= 0;
				dp_y_inc <= 0;
				dice_digit <= dice[d2];
				dice_clr <= 0;
				dice_num <= 1;
			end
			S_PLOT_D_INCR: begin
				dp_x_inc = dice_inc_count_x;
				dp_y_inc = dice_inc_count_y;
				plot_to_vga = dice_digit[288];
				dice_digit = dice_digit << 1;
				dice_inc_count_x = dice_inc_count_x + 1;
				if (dice_inc_count_x > 16) begin
					dice_inc_count_x = 0;
					dice_inc_count_y = dice_inc_count_y + 1;
					if (dice_inc_count_y > 16)
						dice_inc_count_y = 0;
				end
			end
			S_CLEAR_D1: begin
				dice_inc_count_x <= 0;
				dice_inc_count_y <= 0;
				dp_x_inc <= 0;
				dp_y_inc <= 0;
				dice_clr <= 1;
				dice_num <= 0;
				ld_dp <= 1;
				draw_dice <= 1;
			end
			S_CLEAR_D2: begin
				dice_inc_count_x <= 0;
				dice_inc_count_y <= 0;
				dp_x_inc <= 0;
				dp_y_inc <= 0;
				dice_clr <= 1;
				dice_num <= 1;
			end
			S_CLEAR_D_INCR: begin
				dp_x_inc = dice_inc_count_x;
				dp_y_inc = dice_inc_count_y;
				dice_inc_count_x = dice_inc_count_x + 1;
				if (dice_inc_count_x > 16) begin
					dice_inc_count_x = 0;
					dice_inc_count_y = dice_inc_count_y + 1;
					if (dice_inc_count_y > 16)
						dice_inc_count_y = 0;
				end
				plot_to_vga = 1;
			end
			
			S_START_MOVE: begin
				/*if (moveCount == 4'b0) begin
					d1 = d1_val;
					d2 = d2_val;
					moveCount = d1 + d2;
					readDice = 0;
				end*/
				ld_dp <= 0;
				draw_dice <= 0;
				pixelsMoved <= 0;
				moveCount = moveCount - 1'b1;
			end
			S_CLEAR: begin
				inc_count = 6'd0;
				//isClear <= 1;
				ld_dp <= 0;
				stored_state <= S_CLEAR_END;
				select_rom <= 1;
				ld_back = 1;
				x_inc = 3'b0;
				y_inc = 3'b0;
			end
			S_CLEAR_INCR: begin
				//ld_back = 1;
				x_inc = inc_count[5:3];
				y_inc = inc_count[2:0];
				//plot_to_vga = 1;
				inc_count = inc_count + 1;
			end
			/*S_UPDATE_DIR: begin
				if (playerSpot == 5'd0) begin
					y_mv <= 0;
					x_mv <= 1;
					right <= 0;
					down <= 0;
				end
				if (playerSpot == 5'd8) begin
					y_mv <= 1;
					x_mv <= 0;
					right <= 0;
					down <= 0;
				end
				if (playerSpot == 5'd16) begin
					y_mv <= 0;
					x_mv <= 1;
					right <= 1;
					down <= 0;
				end
				if (playerSpot == 5'd24) begin
					y_mv <= 1;
					x_mv <= 0;
					right <= 0;
					down <= 1;
				end
				ld_back = 0;
			end*/
			S_UPDATE_DIR: begin
				if (playerSpot < 5'd8) begin
					y_mv <= 0;
					x_mv <= 1;
					right <= 0;
					down <= 0;
				end
				else if (playerSpot < 5'd16) begin
					y_mv <= 1;
					x_mv <= 0;
					right <= 0;
					down <= 0;
				end
				else if (playerSpot < 5'd24) begin
					y_mv <= 0;
					x_mv <= 1;
					right <= 1;
					down <= 0;
				end
				else begin
					y_mv <= 1;
					x_mv <= 0;
					right <= 0;
					down <= 1;
				end
				ld_back = 0;
			end
			S_START_FRAME_CLK: begin
				f_clk_en <= 1;
				f_clk_reset <= 0;
			end
			S_UPDATE_POS: begin
				ld_x = 1;
				ld_y = 1;
			end
			S_PLOT: begin
				inc_count = 6'd0;
				//isClear = 0;
				ld_dp <= 0;
				ld_back <= 1;
				select_rom <= 2;
				stored_state <= S_PLOT_END;
				x_inc = 3'b0;
				y_inc = 3'b0;
			end
			S_PLOT_INCR: begin
				x_inc = inc_count[5:3];
				y_inc = inc_count[2:0];
				//plot_to_vga = 1;
				inc_count = inc_count + 1;
			end
			S_RESET_COUNT: begin
				f_clk_en <= 0;
				f_clk_reset <= 1;
				ld_back <= 0;
				pixelsMoved <= pixelsMoved + 1;
			end
			S_WAIT_1: plot_to_vga = 1;
			S_END_MOVE: 
				if (~reset)
					ld_spot = 1;
					
			S_ACTION_AT_STOP: begin
				sc_neg <= 0;
				ld_dp <= 1;
				case (playerSpot)
					5'd0: scoreChange <= 0;
					5'd2: begin
						sc_neg <= 1;
						scoreChange <= max * scoreNeg;
					end
					5'd4: scoreChange <= max * scorePos;
					5'd8: scoreChange <= 0;
					5'd12: scoreChange <= max * scorePos;
					5'd20: scoreChange <= max * scorePos;
					5'd28: scoreChange <= max * scorePos;
					5'd30: begin
						sc_neg <= 1;
						scoreChange <= max * scoreNeg;
					end
					default: begin
						if (playerProgress[playerSpot])
							scoreChange <= 0;
						else if (playerSpot == 5'd16 || playerSpot == 5'd24)
							scoreChange <= spotScores[playerSpot];
						else
							scoreChange <= spotScores[playerSpot] * max;
					end
				endcase
				
				/*if (playerSpot == 5'd2 || playerSpot == 5'd30) begin
					scoreChange = max * scoreNeg;
					sc_neg = 1;
				end else if (playerSpot == 5'd4 || playerSpot == 5'd12 ||
				playerSpot == 5'd20 || playerSpot == 5'd28) begin
					scoreChange = max * scorePos;
				end else if (playerSpot == 5'd0 || playerSpot == 5'd8)
					scoreChange = 0;
				else begin
					drawProgress <= 1;
					if (playerProgress[playerSpot])
						scoreChange = 0;
					else begin
						ld_progress = 1;
						if (playerSpot == 5'd16 || playerSpot == 5'd24)
							scoreChange = spotScores[playerSpot];
						else
							scoreChange = spotScores[playerSpot] * max;
						//next_state = S_PLOT_PROGRESS;
					end
				end*/
				//ld_score = 1;
				//if (!ld_progress)
					//next_state = S_CHANGE_PLAYER;
			end
			
			S_LOAD_SCORE: begin
				ld_progress <= 1;
				ld_score <= 1;
			end
			//S_LOAD_PROGRESS: begin
			//	ld_progress <= 1;
			//end
			
			S_PLOT_PROGRESS: begin
				ld_dp_p = 1;
				prog_inc_count = 3'd0;
				dp_x_inc = 5'b0;
				dp_y_inc = 5'b0;
			end
			S_PLOT_PROGRESS_INCR: begin
				dp_x_inc[1:0] = prog_inc_count[2:1];
				dp_y_inc[0] = prog_inc_count[0];
				plot_to_vga = 1;
				prog_inc_count = prog_inc_count + 1;
			end
			
			S_CLEAR_SCORE: begin
				ld_dp_p <= 0;
				clr_inc_count_x <= 0;
				clr_inc_count_y <= 0;
				dp_x_inc <= 0;
				dp_y_inc <= 0;
				sc_clr <= 1;
			end
			S_CLEAR_SCORE_INCR: begin
				dp_x_inc = clr_inc_count_x;
				dp_y_inc = clr_inc_count_y;
				plot_to_vga = 1;
				clr_inc_count_y = clr_inc_count_y + 1;
				if (clr_inc_count_y > 5'd6) begin
					clr_inc_count_y = 0;
					clr_inc_count_x = clr_inc_count_x + 1;
					if (clr_inc_count_x > 5'd27)
						clr_inc_count_x = 0;
				end
			end
			//S_CLEAR_SCORE_END: begin
			//	if (clr_inc_count_x == 0 && clr_inc_count_y == 0)
			//		sc_clr = 0;
			//end
			
			S_PLOT_SC_DIG_0: begin
				sc_inc_count_x = 0;
				sc_inc_count_y = 0;
				dp_x_inc = 0;
				dp_y_inc = 0;
				sc_digit = digit[sc_dg_0];
				sc_clr = 0;
				dg = 2'd0;
			end
			S_PLOT_SC_DIG_1: begin
				sc_inc_count_x = 0;
				sc_inc_count_y = 0;
				dp_x_inc = 0;
				dp_y_inc = 0;
				sc_digit = digit[sc_dg_1];
				dg = 2'd1;
			end
			S_PLOT_SC_DIG_2: begin
				sc_inc_count_x = 0;
				sc_inc_count_y = 0;
				dp_x_inc = 0;
				dp_y_inc = 0;
				sc_digit = digit[sc_dg_2];
				dg = 2'd2;
			end
			S_PLOT_SC_DIG_3: begin
				sc_inc_count_x = 0;
				sc_inc_count_y = 0;
				dp_x_inc = 0;
				dp_y_inc = 0;
				sc_digit = digit[sc_dg_3];
				dg = 2'd3;
			end
			S_PLOT_SC_INCR: begin
				dp_x_inc = sc_inc_count_x;
				dp_y_inc = sc_inc_count_y;
				plot_to_vga = sc_digit[48];
				sc_digit = sc_digit << 1;
				sc_inc_count_x = sc_inc_count_x + 1;
				if (sc_inc_count_x > 3'd6) begin
					sc_inc_count_x = 0;
					sc_inc_count_y = sc_inc_count_y + 1;
					if (sc_inc_count_y > 3'd6)
						sc_inc_count_y = 0;
				end
			end
			
			S_CHANGE_PLAYER: begin
				ld_dp = 0;
				drawProgress = 0;
				if (d1 != d2 || reset || frc_change_turn) begin
					if (playerTurn == 3'd3)
						playerTurn <= 0;
					else
						playerTurn <= playerTurn + 1'b1;
				end
			end
			
			S_CHECK_CHANGE_PLAYER: frc_change_turn = 1;
			
			S_DRAW_WIN_TEXT: begin
				dp_x_inc <= 0;
				dp_y_inc <= 0;
				win_inc_count_x <= 0;
				win_inc_count_y <= 0;
				ld_dp <= 1;
				ld_back <= 1;
				draw_win <= 1;
				select_rom <= 2'd3;
				stored_state <= S_DRAW_WIN_TEXT_END;
			end
			
			S_DRAW_WIN_TEXT_INCR: begin
				dp_x_inc <= win_inc_count_x;
				dp_y_inc <= win_inc_count_y;
				plot_to_vga <= 1;
				win_inc_count_x = win_inc_count_x + 1;
				if (win_inc_count_x >= 137) begin
					win_inc_count_x = 0;
					win_inc_count_y = win_inc_count_y + 1;
					if (win_inc_count_y >= 31)
						win_inc_count_y = 0;
				end
			end
			
			S_GAME_END: begin
				ld_dp <= 0;
				ld_back <= 0;
				draw_win <= 0;
			end
			
		endcase
		
	// End of signal control
	
		current_state = next_state;
    end // End of Always Block
	 
	 assign Right = right;
	 assign Down = down;

endmodule
