module Player (clk, turn, reset, Right, Down, C_In, ld_x, ld_y, ld_back, ld_spot,
						x_mv, y_mv, x_inc, y_inc, X_Out, Y_Out, C_Out, spot, moveSpaces,
						hex);
	input clk, reset, turn, Right, Down;
	input ld_x, ld_y, ld_back, ld_spot;
	input x_mv, y_mv;
	input [23:0] C_In;
	input [2:0] x_inc, y_inc;
	
	output [6:0] hex;
	output [23:0] C_Out;
	output [7:0] Y_Out;
	output [8:0] X_Out;
	output reg [5:0] moveSpaces;
	output reg [4:0] spot;
	
	reg [8:0] x;
	reg [7:0] y;
	reg [23:0] c;
	
	parameter player = 0;
	/*parameter Color = "Red";
	wire [23:0] color = Color == "Green" ? {8'b0, 8'b11111111, 8'b0} :
								Color == "Blue" ? {16'b0, 8'b11111111} :
								Color == "Yellow" ? {8'b11111111, 8'b11111111, 8'b0} :
								{8'b11111111, 16'b0};*/
								
	/*assign moveDouble = (player == 0 && spot == 5'd7) ? 1 :
								(player == 0 && spot == 5'd15) ? 1 :
								(player == 0 && spot == 5'd16) ? 1 :
								(player == 0 && spot == 5'd24) ? 1 :
								(player == 1 && spot == 5'd0) ? 1 :
								(player == 1 && spot == 5'd15) ? 1 :
								(player == 1 && spot == 5'd22) ? 1 :
								(player == 1 && spot == 5'd23) ? 1 :
								(player == 2 && spot == 5'd7) ? 1 :
								(player == 2 && spot == 5'd8) ? 1 :
								(player == 2 && spot == 5'd16) ? 1 :
								(player == 2 && spot == 5'd31) ? 1 :
								(player == 3 && spot == 5'd0) ? 1 :
								(player == 3 && spot == 5'd8) ? 1 :
								(player == 3 && spot == 5'd23) ? 1 :
								(player == 3 && spot == 5'd31) ? 1 : 0;*/
								
	/*wire [8:0] x_rst = player == 1 ? 9'd313 :
								player == 3 ? 9'd313 :
								9'd303;
								
	wire [7:0] y_rst = player == 2 ? 8'd233 :
								player == 3 ? 8'd233 :
								8'd223;*/
								
	wire [8:0] x_rst = player == 0 ? 9'd203 :
								player == 1 ? 9'd219 :
								player == 2 ? 9'd211 :
								9'd227;
								
	wire [7:0] y_rst = player == 0 ? 8'd203 :
								player == 1 ? 8'd211 :
								player == 2 ? 8'd219 :
								8'd227;
	
	always @(posedge clk)
	begin
		if (reset) begin
			x <= x_rst;
			y <= y_rst;
			c <= C_In;
			spot <= 0;
			if (player == 0)
				moveSpaces = 6'd28;
			else if (player == 1)
				moveSpaces = 6'd36;
			else if (player == 2)
				moveSpaces = 6'd36;
			else
				moveSpaces = 6'd44;
		end
		else if (turn) begin
			if (ld_x && x_mv) begin
				if (Right)
					x <= x + 1'b1;
				else
					x <= x - 1'b1;
			end
			if (ld_y && y_mv) begin
				if (Down)
					y <= y + 1'b1;
				else
					y <= y - 1'b1;
			end
			if (ld_spot) begin
				//if (spot >= 6'd39)
				//	spot <= 0;
				//else
					spot = spot + 1'b1;
			end
			case (spot)
				5'd0: begin
					if (player == 0)
						moveSpaces = 6'd28;
					else if (player == 1)
						moveSpaces = 6'd36;
					else if (player == 2)
						moveSpaces = 6'd36;
					else
						moveSpaces = 6'd44;
				end
				5'd7: begin
					if (player == 0)
						moveSpaces = 6'd41;
					else if (player == 1)
						moveSpaces = 6'd33;
					else if (player == 2)
						moveSpaces = 6'd33;
					else
						moveSpaces = 6'd25;
				end
				5'd8: begin
					if (player == 0)
						moveSpaces = 6'd28;
					else if (player == 1)
						moveSpaces = 6'd36;
					else if (player == 2)
						moveSpaces = 6'd36;
					else
						moveSpaces = 6'd44;
				end
				5'd15: begin
					if (player == 0)
						moveSpaces = 6'd41;
					else if (player == 1)
						moveSpaces = 6'd33;
					else if (player == 2)
						moveSpaces = 6'd33;
					else
						moveSpaces = 6'd25;
				end
				5'd16: begin
					if (player == 0)
						moveSpaces = 6'd41;
					else if (player == 1)
						moveSpaces = 6'd33;
					else if (player == 2)
						moveSpaces = 6'd33;
					else
						moveSpaces = 6'd25;
				end
				5'd23: begin
					if (player == 0)
						moveSpaces = 6'd28;
					else if (player == 1)
						moveSpaces = 6'd36;
					else if (player == 2)
						moveSpaces = 6'd36;
					else
						moveSpaces = 6'd44;
				end
				5'd24: begin
					if (player == 0)
						moveSpaces = 6'd41;
					else if (player == 1)
						moveSpaces = 6'd33;
					else if (player == 2)
						moveSpaces = 6'd33;
					else
						moveSpaces = 6'd25;
				end
				5'd31: begin
					if (player == 0)
						moveSpaces = 6'd28;
					else if (player == 1)
						moveSpaces = 6'd36;
					else if (player == 2)
						moveSpaces = 6'd36;
					else
						moveSpaces = 6'd44;
				end
				default: moveSpaces = 6'd21;
			endcase
		end
	end
	
	HEX_Decoder h (spot[3:0], hex);
	
	assign X_Out = x + x_inc;
	assign Y_Out = y + y_inc;
	assign C_Out = c;

endmodule
