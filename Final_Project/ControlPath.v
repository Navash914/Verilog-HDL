module ControlPath (clk, Input, bd_addr, bd_read, bd_write, bback_addr, //bback_read,
							d1, d2, x, y, c, plot, hex, hex2, hex3, hex4, hex5, hex6,
							index, ld_bback);
	input clk, Input;
	input [91:0] bd_read;
	//input [191:0] bback_read;
	input [2:0] d1, d2;
	
	output [2:0] index;
	output ld_bback;
	output [6:0] hex, hex2, hex3, hex4, hex5, hex6;
	output reg [8:0] x;
	output reg [7:0] y;
	output reg [23:0] c;
	output  plot;
	output [5:0] bd_addr;
	output reg [15:0] bback_addr;
	//output reg [12:0] bback_addr;
	output bd_write;
	
	wire [4:0] spot [4];
	wire ld_x, ld_y, ld_back, ld_spot, x_mv, y_mv;
	wire reset;
	wire Right, Down;
	wire [2:0] x_inc, y_inc;
	wire [2:0] turn;
	wire plotRequest;
	wire [5:0] moveSpaces [4];
	
	assign plot = plotRequest;
	
	ControlFSM ctrl (.clk(clk), .Input(Input), .playerSpot(spot[turn]), .d1_val(d1), .d2_val(d2),
							.Right(Right), .Down(Down), .reset(reset), .plot_to_vga(plotRequest),
							.ld_x(ld_x), .ld_y(ld_y), .ld_back(ld_back), .ld_spot(ld_spot),
							.x_mv(x_mv), .y_mv(y_mv), .playerTurn(turn), .moveSpaces(moveSpaces[turn]),
							.x_inc(x_inc), .y_inc(y_inc), .hex(hex), .hex2(hex2)
							);
							
	wire p0_turn = turn == 3'd0;
	wire p1_turn = turn == 3'd1;
	wire p2_turn = turn == 3'd2;
	wire p3_turn = turn == 3'd3;
	
	wire [23:0] p0_color = {8'b11111111, 16'b0}; // Red
	wire [23:0] p1_color = {8'b0, 8'b11111111, 8'b0}; // Green
	wire [23:0] p2_color = {16'b0, 8'b11111111}; // Blue
	wire [23:0] p3_color = {8'b11111111, 8'b11111111, 8'b0}; // Yellow
	
	wire [23:0] c_out [4];
	wire [8:0] x_out [4];
	wire [7:0] y_out [4];
							
	Player p0 (.clk(clk), .turn(p0_turn), .reset(reset), .Right(Right), .Down(Down), .C_In(p0_color),
					.ld_x(ld_x), .ld_y(ld_y), .ld_spot(ld_spot),
					.x_mv(x_mv), .y_mv(y_mv), .x_inc(x_inc), .y_inc(y_inc), .moveSpaces(moveSpaces[0]),
					.X_Out(x_out[0]), .Y_Out(y_out[0]), .C_Out(c_out[0]), .spot(spot[0]), .hex(hex3)
					);
	defparam p0.player = 0;
					
	Player p1 (.clk(clk), .turn(p1_turn), .reset(reset), .Right(Right), .Down(Down), .C_In(p1_color),
					.ld_x(ld_x), .ld_y(ld_y), .ld_spot(ld_spot),
					.x_mv(x_mv), .y_mv(y_mv), .x_inc(x_inc), .y_inc(y_inc), .moveSpaces(moveSpaces[1]),
					.X_Out(x_out[1]), .Y_Out(y_out[1]), .C_Out(c_out[1]), .spot(spot[1]), .hex(hex4)
					);
	defparam p1.player = 1;
	
	Player p2 (.clk(clk), .turn(p2_turn), .reset(reset), .Right(Right), .Down(Down), .C_In(p2_color),
					.ld_x(ld_x), .ld_y(ld_y), .ld_spot(ld_spot),
					.x_mv(x_mv), .y_mv(y_mv), .x_inc(x_inc), .y_inc(y_inc), .moveSpaces(moveSpaces[2]),
					.X_Out(x_out[2]), .Y_Out(y_out[2]), .C_Out(c_out[2]), .spot(spot[2]), .hex(hex5)
					);
	defparam p2.player = 2;
				
	Player p3 (.clk(clk), .turn(p3_turn), .reset(reset), .Right(Right), .Down(Down), .C_In(p3_color),
					.ld_x(ld_x), .ld_y(ld_y), .ld_spot(ld_spot),
					.x_mv(x_mv), .y_mv(y_mv), .x_inc(x_inc), .y_inc(y_inc), .moveSpaces(moveSpaces[3]),
					.X_Out(x_out[3]), .Y_Out(y_out[3]), .C_Out(c_out[3]), .spot(spot[3]), .hex(hex6)
					);	
	defparam p3.player = 3;
	
	//reg [2:0] i;
	//reg [7:0] j;
	/*wire [23:0] bback [8];
	assign bback[0] = bback_read[23:0];
	assign bback[1] = bback_read[47:24];
	assign bback[2] = bback_read[71:48];
	assign bback[3] = bback_read[95:72];
	assign bback[4] = bback_read[119:96];
	assign bback[5] = bback_read[143:120];
	assign bback[6] = bback_read[167:144];
	assign bback[7] = bback_read[191:168];*/
	
	always @(clk)
	begin
		//if (ld_back) begin
			/*if (y_out[turn] < 8'd30) begin
				i = 3'd0;
				j = y_out[turn];
			end else if (y_out[turn] < 8'd60) begin
				i = 3'd1;
				j = y_out[turn] - 8'd30;
			end else if (y_out[turn] < 8'd90) begin
				i = 3'd2;
				j = y_out[turn] - 8'd60;
			end else if (y_out[turn] < 8'd120) begin
				i = 3'd3;
				j = y_out[turn] - 8'd90;
			end else if (y_out[turn] < 8'd150) begin
				i = 3'd4;
				j = y_out[turn] - 8'd120;
			end else if (y_out[turn] < 8'd180) begin
				i = 3'd5;
				j = y_out[turn] - 8'd150;
			end else if (y_out[turn] < 8'd210) begin
				i = 3'd6;
				j = y_out[turn] - 8'd180;
			end else begin
				i = 3'd7;
				j = y_out[turn] - 8'd210;
			end */
			//bback_addr = j * 8'd240 + x_out[turn];
			bback_addr = y_out[turn] * 8'd240 + x_out[turn];
			//c = bback[i];
		//end
		
		x = x_out[turn];
		y = y_out[turn];
		c = c_out[turn];
		
		/*if (plotRequest)
			plot = 1;
		else
			plot = 0;*/
		//plot = 1;
		//else
			//c = c_out[turn];
		
	end
	
	assign index = 0;
	assign ld_bback = ld_back;

endmodule
