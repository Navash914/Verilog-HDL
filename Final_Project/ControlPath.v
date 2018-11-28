module ControlPath (clk, Input, start, cancel,
							bback_addr, w_addr, p_addr,
							d1, d2, x, y, c, plot, select_rom,
							ld_bback, fast_fwd);
	input clk, Input, start, cancel, fast_fwd;
	input [2:0] d1, d2;
	
	output [1:0] select_rom;
	output ld_bback;
	output reg [8:0] x;
	output reg [7:0] y;
	output reg [11:0] c;
	output plot;
	output reg [16:0] bback_addr;
	output reg [14:0] w_addr;
	output reg [7:0] p_addr;
	
	wire [4:0] spot [4];
	wire ld_x, ld_y, ld_back, ld_spot, ld_progress, ld_score, ld_dp;
	wire x_mv, y_mv, sc_neg;
	wire reset;
	wire Right, Down;
	wire [2:0] x_inc, y_inc;
	wire [2:0] turn;
	wire [5:0] moveSpaces [4];
	
	wire [12:0] score [4];
	wire [8:0] scoreChange;
	wire [31:0] progress [4];
	wire sc_clr, ld_dp_p;
	wire [7:0] dp_x_inc, dp_y_inc;
	wire [1:0] digitNum;
	wire [3:0] sc_dg_0, sc_dg_1, sc_dg_2, sc_dg_3;
	wire draw_dice, dice_clr, dice_num;
	wire draw_win;
	wire frc;
	wire [8:0] frc_x;
	wire [7:0] frc_y;
	wire [1:0] win = score[0] >= score[1] && score[0] >= score[2] && score[0] >= score[3] ? 0 :
							score[1] >= score[0] && score[1] >= score[2] && score[1] >= score[3] ? 1 :
							score[2] >= score[0] && score[2] >= score[1] && score[2] >= score[3] ? 2 : 3;
	
	assign sc_dg_0 = score[turn] / 1000;
	assign sc_dg_1 = (score[turn] / 100) % 10;
	assign sc_dg_2 = (score[turn] / 10) % 10;
	assign sc_dg_3 = score[turn] % 10;
	
	ControlFSM ctrl (.clk(clk), .Input(Input), .start(start), .cancel(cancel),
							.playerSpot(spot[turn]), .d1_val(d1), .d2_val(d2),
							.Right(Right), .Down(Down), .reset(reset), .plot_to_vga(plot),
							.ld_x(ld_x), .ld_y(ld_y), .ld_back(ld_back), .ld_spot(ld_spot),
							.ld_score(ld_score), .ld_progress(ld_progress), .ld_dp(ld_dp),
							.x_mv(x_mv), .y_mv(y_mv), .playerTurn(turn), .moveSpaces(moveSpaces[turn]),
							.x_inc(x_inc), .y_inc(y_inc), .dp_x_inc(dp_x_inc), .dp_y_inc(dp_y_inc),
							.scoreChange(scoreChange), .sc_neg(sc_neg), .playerProgress(progress[turn]),
							.sc_clr(sc_clr), .playerScore(score[turn]), 
							.dg(digitNum), .ld_dp_p(ld_dp_p), .fast_fwd(fast_fwd),
							.sc_dg_0(sc_dg_0), .sc_dg_1(sc_dg_1), .sc_dg_2(sc_dg_2), .sc_dg_3(sc_dg_3),
							.draw_dice(draw_dice), .dice_clr(dice_clr), .dice_num(dice_num),
							.frc(frc), .frc_x(frc_x), .frc_y(frc_y), .select_rom(select_rom),
							.draw_win(draw_win)
							);
							
	wire [8:0] dp_x_out;
	wire [7:0] dp_y_out;
	wire [11:0] dp_c_out;
							
	Datapath dp (.clk(clk), .reset(reset), .turn(turn), .spot(spot[turn]), .ld_dp(ld_dp), .x_inc(dp_x_inc), .y_inc(dp_y_inc),
						.x_out(dp_x_out), .y_out(dp_y_out), .c_out(dp_c_out),
						.draw_dice(draw_dice), .dice_clr(dice_clr), .dice_num(dice_num),
						.frc(frc), .frc_x(frc_x), .frc_y(frc_y), .draw_win(draw_win),
						.digit(digitNum), .ld_dp_p(ld_dp_p), .sc_clr(sc_clr));
							
	wire p0_turn = turn == 3'd0;
	wire p1_turn = turn == 3'd1;
	wire p2_turn = turn == 3'd2;
	wire p3_turn = turn == 3'd3;
	
	wire [11:0] p0_color = {4'b1111, 8'b0}; // Red
	wire [11:0] p1_color = {4'b0, 4'b1111, 4'b0}; // Green
	wire [11:0] p2_color = {8'b0, 4'b1111}; // Blue
	wire [11:0] p3_color = {8'b11111111, 4'b0}; // Yellow
	
	wire [11:0] c_out [4];
	wire [8:0] x_out [4];
	wire [7:0] y_out [4];
							
	Player p0 (.clk(clk), .turn(p0_turn), .reset(reset), .Right(Right), .Down(Down), .C_In(p0_color),
					.ld_x(ld_x), .ld_y(ld_y), .ld_spot(ld_spot),
					.x_mv(x_mv), .y_mv(y_mv), .x_inc(x_inc), .y_inc(y_inc), .moveSpaces(moveSpaces[0]),
					.X_Out(x_out[0]), .Y_Out(y_out[0]), .C_Out(c_out[0]), .spot(spot[0]), 
					.ld_score(ld_score), .ld_progress(ld_progress), .sc_neg(sc_neg), .scoreChange(scoreChange), 
					.score(score[0]), .progress(progress[0])
					);
	defparam p0.player = 0;
					
	Player p1 (.clk(clk), .turn(p1_turn), .reset(reset), .Right(Right), .Down(Down), .C_In(p1_color),
					.ld_x(ld_x), .ld_y(ld_y), .ld_spot(ld_spot),
					.x_mv(x_mv), .y_mv(y_mv), .x_inc(x_inc), .y_inc(y_inc), .moveSpaces(moveSpaces[1]),
					.X_Out(x_out[1]), .Y_Out(y_out[1]), .C_Out(c_out[1]), .spot(spot[1]), 
					.ld_score(ld_score), .ld_progress(ld_progress), .sc_neg(sc_neg), .scoreChange(scoreChange), 
					.score(score[1]), .progress(progress[1])
					);
	defparam p1.player = 1;
	
	Player p2 (.clk(clk), .turn(p2_turn), .reset(reset), .Right(Right), .Down(Down), .C_In(p2_color),
					.ld_x(ld_x), .ld_y(ld_y), .ld_spot(ld_spot),
					.x_mv(x_mv), .y_mv(y_mv), .x_inc(x_inc), .y_inc(y_inc), .moveSpaces(moveSpaces[2]),
					.X_Out(x_out[2]), .Y_Out(y_out[2]), .C_Out(c_out[2]), .spot(spot[2]), 
					.ld_score(ld_score), .ld_progress(ld_progress), .sc_neg(sc_neg), .scoreChange(scoreChange), 
					.score(score[2]), .progress(progress[2])
					);
	defparam p2.player = 2;
				
	Player p3 (.clk(clk), .turn(p3_turn), .reset(reset), .Right(Right), .Down(Down), .C_In(p3_color),
					.ld_x(ld_x), .ld_y(ld_y), .ld_spot(ld_spot),
					.x_mv(x_mv), .y_mv(y_mv), .x_inc(x_inc), .y_inc(y_inc), .moveSpaces(moveSpaces[3]),
					.X_Out(x_out[3]), .Y_Out(y_out[3]), .C_Out(c_out[3]), .spot(spot[3]), 
					.ld_score(ld_score), .ld_progress(ld_progress), .sc_neg(sc_neg), .scoreChange(scoreChange), 
					.score(score[3]), .progress(progress[3])
					);	
	defparam p3.player = 3;
	
	always @(*)
	begin
		if (ld_dp) begin
			x <= dp_x_out;
			y <= dp_y_out;
			c <= dp_c_out;
			bback_addr <= dp_y_out * 9'd320 + dp_x_out;
			w_addr <= dp_x_inc + (dp_y_inc + win * 6'd31) * 8'd137;
		end else begin
			x <= x_out[turn];
			y <= y_out[turn];
			c <= c_out[turn];
			bback_addr <= y_out[turn] * 9'd320 + x_out[turn];
			p_addr <= x_inc + turn * 4'd8 + y_inc * 6'd32;
		end
		
	end
	
	assign ld_bback = ld_back;

endmodule
