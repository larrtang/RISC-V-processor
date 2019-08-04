module mux8 #(parameter width = 32)
(
	input [2:0] sel,
	input [width-1:0] a, b, c, d, e, f, h, i,
	output logic [width-1:0] g
);

always_comb
begin
	if (sel == 3'b000)
		g = a;
	else if (sel == 3'b001)
		g = b;
	else if (sel == 3'b010)
		g = c;
	else if (sel == 3'b011)
		g = d;
	else if (sel == 3'b100)
		g = e;
	else if (sel == 3'b101)
		g = f;
	else if (sel == 3'b110)
		g = h;
	else if (sel == 3'b111)
		g = i;
	else
		g = f;

end

endmodule : mux8