module RollDice (clk, q);
	input clk;
	//output reg [2:0] q;
	output [2:0] q;
	
	reg [2:0] count;
	
	always @(posedge clk)
	begin
		if (count == 3'b110)
			count = 3'b001;
		else
			count = count + 3'b001;
		/*if (readEn) begin
			if (count == 3'd7)
				q <= 3'd6;
			else if (count == 3'd0)
				q <= 3'd1;
			else
				q = count;
		end*/
	end
	assign q = count;
	
	//always @(*)
		//if (readEn)
			//q <= count;

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
			Q <= Q + 1'b1;
	end

endmodule

module GenerateClock(inclk, freq, outclk);
	input inclk;
	input [25:0] freq;
	output reg outclk;
	
	wire [25:0] ClockFrequency = 26'd50000000;
	wire [25:0] Max = (ClockFrequency / freq) - 1'b1;
	
	wire [25:0] RateDivider;
	
	RateController rc (.Clock(inclk), .Enable(1), .Clear_b(0), .ParLoad(0), 
								.D(26'b0), .MaxValue(Max), .Q(RateDivider));
	
	always @(posedge inclk)
		if (RateDivider == 26'b0)
			outclk = ~outclk;

endmodule
