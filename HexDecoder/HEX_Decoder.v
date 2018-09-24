`timescale 1ns / 1ns

module HEX_Decoder (SW, HEX0);
	input [3:0] SW;
	output [6:0] HEX0;
	
	hexDecoder hd(SW[0], SW[1], SW[2], SW[3], HEX0);

endmodule // HEX_Decoder

module hexDecoder (c0, c1, c2, c3, hex);

	input c0, c1, c2, c3;
	output [6:0] hex;
				 
	assign hex[0] = (c0 & !c1 & !c2 & !c3)
					  | (!c0 & !c1 & c2 & !c3)
					  | (c0 & c1 & !c2 & c3)
					  | (c0 & !c1 & c2 & c3);
				
	assign hex[1] = (c0 & !c1 & c2 & !c3)
					  | (!c0 & c1 & c2 & !c3)
					  | (c0 & c1 & !c2 & c3)
					  | (!c0 & !c1 & c2 & c3)
					  | (c1 & c2 & c3);
					  
	assign hex[2] = (!c0 & c1 & !c2 & !c3)
					  | ((!c0 | c1) & c2 & c3);
					  
	assign hex[3] = (c0 & !c1 & !c2 & !c3)
					  | (!c0 & !c1 & c2 & !c3)
					  | (c0 & c1 & c2 & !c3)
					  | (!c0 & c1 & !c2 & c3)
					  | (c0 & c1 & c2 & c3);
					  
	assign hex[4] = (c0 & !c1 & !c2)
					  | (c0 & c1 & !c3)
					  | (!c1 & c2 & !c3);
					  
	assign hex[5] = ((c0 | c1) & !c2 & !c3)
					  | (c0 & c1 & c2 & !c3)
					  | (c0 & !c1 & c2 & c3);
					  
	assign hex[6] = (!c1 & !c2 & !c3)
					  | (c0 & c1 & c2 & !c3)
					  | (!c0 & !c1 & c2 & c3);

endmodule // hexDecoder