`timescale 1ns / 1ns

module HEX_Decoder (SW, HEX0);
	input [3:0] SW;
	output [6:0] HEX0;
	
	hexDecoder hd(SW[3:0], HEX0);

endmodule // HEX_Decoder

module hexDecoder (c, hex);

	input [3:0] c;
	output [6:0] hex;
				 
	assign hex[0] = (c[0] & !c[1] & !c[2] & !c[3])
					  | (!c[0] & !c[1] & c[2] & !c[3])
					  | (c[0] & c[1] & !c[2] & c[3])
					  | (c[0] & !c[1] & c[2] & c[3]);
				
	assign hex[1] = (c[0] & !c[1] & c[2] & !c[3])
					  | (!c[0] & c[1] & c[2] & !c[3])
					  | (c[0] & c[1] & !c[2] & c[3])
					  | (!c[0] & !c[1] & c[2] & c[3])
					  | (c[1] & c[2] & c[3]);
					  
	assign hex[2] = (!c[0] & c[1] & !c[2] & !c[3])
					  | ((!c[0] | c[1]) & c[2] & c[3]);
					  
	assign hex[3] = (c[0] & !c[1] & !c[2] & !c[3])
					  | (!c[0] & !c[1] & c[2] & !c[3])
					  | (c[0] & c[1] & c[2] & !c[3])
					  | (!c[0] & c[1] & !c[2] & c[3])
					  | (c[0] & c[1] & c[2] & c[3]);
					  
	assign hex[4] = (c[0] & !c[1] & !c[2])
					  | (c[0] & c[1] & !c[3])
					  | (!c[1] & c[2] & !c[3]);
					  
	assign hex[5] = ((c[0] | c[1]) & !c[2] & !c[3])
					  | (c[0] & c[1] & c[2] & !c[3])
					  | (c[0] & !c[1] & c[2] & c[3]);
					  
	assign hex[6] = (!c[1] & !c[2] & !c[3])
					  | (c[0] & c[1] & c[2] & !c[3])
					  | (!c[0] & !c[1] & c[2] & c[3]);

endmodule // hexDecoder