
module Datapath (clk, reset, turn, spot, ld_dp, x_inc, y_inc,
						x_out, y_out, c_out, draw_win,
						frc, frc_x, frc_y,
						draw_dice, dice_clr, dice_num,
						digit, ld_dp_p, sc_clr);
	input clk, reset, ld_dp, ld_dp_p, sc_clr;
	input draw_dice, dice_clr, dice_num;
	input frc, draw_win;
	input [8:0] frc_x;
	input [7:0] frc_y;
	input [1:0] digit;
	input [2:0] turn;
	input [4:0] spot;
	input [7:0] x_inc, y_inc;
	
	output [8:0] x_out;
	output [7:0] y_out;
	output [11:0] c_out;
	
	reg [8:0] x;
	reg [7:0] y;
	reg [11:0] c;
	
	always @(posedge clk)
	begin
		if (reset) begin
			x <= 0;
			y <= 0;
			c <= 0;
		end else if (ld_dp) begin
			if (ld_dp_p) begin
				case (spot)
					5'd1: begin
						x <= 9'd259;
						y <= 8'd47;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd3: begin
						x <= 9'd267;
						y <= 8'd47;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd5: begin
						x <= 9'd285;
						y <= 8'd47;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd6: begin
						x <= 9'd292;
						y <= 8'd47;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd7: begin
						x <= 9'd299;
						y <= 8'd47;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd9: begin
						x <= 9'd256;
						y <= 8'd54;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd10: begin
						x <= 9'd263;
						y <= 8'd54;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd11: begin
						x <= 9'd270;
						y <= 8'd54;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd13: begin
						x <= 9'd285;
						y <= 8'd54;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd14: begin
						x <= 9'd292;
						y <= 8'd54;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd15: begin
						x <= 9'd299;
						y <= 8'd54;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd16: begin // ESIP
						x <= 9'd263;
						y <= 8'd75;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd17: begin
						x <= 9'd256;
						y <= 8'd61;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd18: begin
						x <= 9'd263;
						y <= 8'd61;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd19: begin
						x <= 9'd270;
						y <= 8'd61;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd21: begin
						x <= 9'd285;
						y <= 8'd61;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd22: begin
						x <= 9'd292;
						y <= 8'd61;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd23: begin
						x <= 9'd299;
						y <= 8'd61;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd24: begin // PEY
						x <= 9'd292;
						y <= 8'd75;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd25: begin
						x <= 9'd256;
						y <= 8'd68;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd26: begin
						x <= 9'd263;
						y <= 8'd68;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd27: begin
						x <= 9'd270;
						y <= 8'd68;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd29: begin
						x <= 9'd288;
						y <= 8'd68;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					5'd31: begin
						x <= 9'd296;
						y <= 8'd68;
						c <= { 4'b0, 4'b1111, 4'b0 };
					end
					default: begin
						x <= 9'b0;
						y <= 8'b0;
						c <= 12'b0;
					end
				endcase
			end else if (draw_dice) begin
				y <= 8'd164;
				if (dice_num == 0)
					x <= 9'd123;//x <= 9'd99;
				else
					x <= 9'd147;//x <= 9'd123;
				if (dice_clr)
					c <= ~(12'b0);
				else
					c <= 12'b0;
			end else if (draw_win) begin
				x <= 51;
				y <= 51;
			end else if (sc_clr) begin
				x <= 9'd279;
				y <= 8'd33;
				c <= ~(12'b0);
			end else begin
				y <= 8'd33;
				c <= 12'b0;
				case (digit)
					2'b00: x <= 9'd279;
					2'b01: x <= 9'd286;
					2'b10: x <= 9'd293;
					2'b11: x <= 9'd300;
				endcase
			end
			
		end
	end
	
	wire [7:0] y_offset = (draw_dice || draw_win) ? 0 :  turn * 6'd52;
	
	assign x_out = frc ? frc_x : (x + x_inc);
	assign y_out = frc ? frc_y : (y + y_offset + y_inc);
	assign c_out = c;

endmodule
