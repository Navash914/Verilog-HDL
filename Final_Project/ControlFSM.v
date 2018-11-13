module ControlFSM (clk, Input, playerSpot, d1_val, d2_val, Right, Down, reset, plot_to_vga,
							ld_x, ld_y, ld_back, ld_spot, x_mv, y_mv, playerTurn, x_inc, y_inc,
							hex, hex2, moveSpaces
							);
	input clk, Input;
	input [5:0] moveSpaces;
	input [4:0] playerSpot;
	input [2:0] d1_val, d2_val;
	
	output [6:0] hex, hex2;
	output Right, Down;
	output reg reset, plot_to_vga;
	output reg ld_x, ld_y, ld_back, ld_spot;
	output reg x_mv, y_mv;
	output reg [2:0] playerTurn;
	output reg [2:0] x_inc, y_inc;
	
	reg f_clk_en, f_clk_reset;
	wire frameClkEnable, frameClkReset, frameDivider;
	assign frameClkEnable = f_clk_en;
	assign frameClkReset = f_clk_reset | reset;
	
	wire [25:0] ClockFrequency = 26'd50000000;
	wire [25:0] Frequency = 26'd60;
	wire [25:0] Max = (ClockFrequency / Frequency);
	wire [25:0] RateDivider;
	
	
	//GenerateClock frame_clk (.inclk(clk), .freq(26'd60), .enable(frameClkEnable), .reset(frameClkReset), .outclk(frameClk));
	RateController fc (.Clock(clk), .Enable(frameClkEnable), .Clear_b(frameClkReset), .ParLoad(0), .D(26'b0),
								.MaxValue(Max), .Q(RateDivider));
								
	assign frameDivider = (frameClkEnable && RateDivider == Max) ? 1 : 0;

	localparam  S_RESET_ALL				= 5'd0,
					S_WAIT_FOR_INPUT     = 5'd1,
					S_WAIT_FOR_INPUT_OFF	= 5'd17,
					S_ROLL_DICE				= 5'd2,
					S_START_MOVE			= 5'd3,
					S_CLEAR   				= 5'd4,
					S_CLEAR_INCR			= 5'd5,
					S_CLEAR_END				= 5'd6,
					S_UPDATE_DIR			= 5'd7,
					S_START_FRAME_CLK		= 5'd16,
					S_WAIT_0					= 5'd18,
					S_WAIT_1					= 5'd19,
					S_WAIT_2					= 5'd20,
					S_UPDATE_POS			= 5'd8,
               S_PLOT        			= 5'd9,
					S_PLOT_INCR				= 5'd10,
					S_PLOT_END				= 5'd11,
					S_RESET_COUNT			= 5'd12,
					S_END_MOVE				= 5'd13,
					S_ACTION_AT_STOP		= 5'd14,
					S_CHANGE_PLAYER		= 5'd15;
					
	 wire [4:0] cs = current_state;
	 wire [3:0] mc = moveCount;
	 HEX_Decoder h (d1, hex);
	 HEX_Decoder h2 (d2, hex2);
               
	 reg [4:0] current_state, next_state;
	 reg [5:0] inc_count;
	 reg [2:0] d1, d2;
	 reg [3:0] moveCount;
	 reg [5:0] pixelsMoved;
	 reg right, down;
	 reg isClear;
    
    // Next state logic aka our state table
    always@(posedge clk)
    begin
		case (current_state)
			 S_RESET_ALL: next_state = S_PLOT;
			 S_WAIT_FOR_INPUT: next_state = Input ? S_WAIT_FOR_INPUT_OFF : S_WAIT_FOR_INPUT;
			 S_WAIT_FOR_INPUT_OFF: next_state = Input ? S_WAIT_FOR_INPUT_OFF : S_ROLL_DICE;
			 S_ROLL_DICE: next_state = S_START_MOVE;
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
			 S_WAIT_2: next_state = isClear ? S_CLEAR_END : S_PLOT_END;
			 /*S_RESET_COUNT: begin
				if (reset)
					next_state = S_CHANGE_PLAYER;
				else begin
					if (moveSpaces) begin
						if (pixelsMoved >= 6'd42)
							next_state = S_END_MOVE;
						else
							next_state = S_START_FRAME_CLK;
					end
					else begin
						if (pixelsMoved >= 6'd21)
							next_state = S_END_MOVE;
						else
							next_state = S_START_FRAME_CLK;
					end
				end
				//next_state = reset ? S_CHANGE_PLAYER : pixelsMoved >= 6'd30 ? S_END_MOVE : S_START_FRAME_CLK;
			end*/
			 S_RESET_COUNT: next_state = reset ? S_CHANGE_PLAYER : pixelsMoved >= (moveSpaces - 1'b1) ? S_END_MOVE : S_START_FRAME_CLK;
			 S_END_MOVE: next_state = moveCount > 4'b0 ? S_START_MOVE : S_ACTION_AT_STOP;
			 S_ACTION_AT_STOP: next_state = S_CHANGE_PLAYER;
			 S_CHANGE_PLAYER: next_state = reset ? S_RESET_ALL : S_WAIT_FOR_INPUT;
			 
		default: next_state = S_RESET_ALL;
		endcase
	 // End of State Table
		
		ld_x = 0;
		ld_y = 0;
		//ld_back = 0;
		ld_spot = 0;
		plot_to_vga = 0;
		//x_inc = 2'b0;
		//y_inc = 2'b0;
		//clr = 0;
		//f_clk_reset = 0;
		//reset = 0;
		case (current_state)
			S_RESET_ALL: begin
				//reset = 1;
				right <= 0;
				down <= 0;
				x_mv = 1;
				y_mv = 0;
				if (playerTurn == 3'd0 && ~reset)
					reset = 1;
				else if (playerTurn == 3'd0 && reset)
					next_state = S_WAIT_FOR_INPUT;
				//playerTurn <= 0;
				//clr = 1;
			end
			S_WAIT_FOR_INPUT: begin
				reset = 0;
				f_clk_en = 1;
				f_clk_reset = 0;
			end
			S_ROLL_DICE: begin
				d1 = d1_val;
				d2 = d2_val;
				moveCount = d1 + d2;
			end
			S_START_MOVE: begin
				/*if (moveCount == 4'b0) begin
					d1 = d1_val;
					d2 = d2_val;
					moveCount = d1 + d2;
					readDice = 0;
				end*/
				pixelsMoved <= 0;
				moveCount = moveCount - 1'b1;
			end
			S_CLEAR: begin
				inc_count = 6'd0;
				isClear <= 1;
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
				f_clk_en = 1;
				f_clk_reset = 0;
			end
			S_UPDATE_POS: begin
				ld_x = 1;
				ld_y = 1;
			end
			S_PLOT: begin
				inc_count = 6'd0;
				isClear = 0;
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
				f_clk_en = 0;
				f_clk_reset = 1;
				pixelsMoved <= pixelsMoved + 1;
			end
			S_WAIT_1: plot_to_vga = 1;
			S_END_MOVE: 
				if (~reset)
					ld_spot = 1;
			// S_ACTION_AT_END
			S_CHANGE_PLAYER: begin
				if (d1 != d2 || reset) begin
					if (playerTurn == 3'd3)
						playerTurn <= 0;
					else
						playerTurn <= playerTurn + 1'b1;
				end
			end
		endcase
		
	// End of signal control
	
		current_state = next_state;
    end // End of Always Block
	 
	 assign Right = right;
	 assign Down = down;

endmodule
