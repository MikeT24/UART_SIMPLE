
module ascii_dec_to_7_seg (
input [7:0] ascii,
output seg_a,
output seg_b,
output seg_c,
output seg_d,
output seg_e,
output seg_f,
output seg_g);

reg [6:0] abcdefg;

always @(ascii)
begin
	case (ascii)
		8'd48:  abcdefg = 7'b0000001; //0
		8'd49:  abcdefg = 7'b1001111; //1
		8'd50:  abcdefg = 7'b0010010; //2
		8'd51:  abcdefg = 7'b0000110; //3
		8'd52:  abcdefg = 7'b1001100; //4
		8'd53:  abcdefg = 7'b0100100; //5
		8'd54:  abcdefg = 7'b0100000; //6
		8'd55:  abcdefg = 7'b0001111; //7
		8'd56:  abcdefg = 7'b0000000; //8
		8'd57:  abcdefg = 7'b0001100; //9
		8'd65:  abcdefg = 7'b0001000; //A
		8'd98:  abcdefg = 7'b1100000; //b
		8'd67:  abcdefg = 7'b0110001; //C
		8'd100: abcdefg = 7'b1000010; //d
		8'd69:  abcdefg = 7'b0110000; //E
		8'd70:  abcdefg = 7'b0111000; //F
		8'd72:  abcdefg = 7'b1001000; //H
		8'd73:  abcdefg = 7'b1111001; //I
		8'd74:  abcdefg = 7'b1000011; //J
		8'd76:  abcdefg = 7'b1110001; //L
		8'd80:  abcdefg = 7'b0011000; //P
		8'd85:  abcdefg = 7'b1000001; //U
		8'd121: abcdefg = 7'b1000100; //y
		8'd64:  abcdefg = 7'b0000010; //@
		8'd45:  abcdefg = 7'b1111110; //-
		
		
		default:abcdefg = 7'b1110111;
	endcase

end


assign {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = abcdefg;

endmodule




