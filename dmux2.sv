module dmux2 #(parameter width = 32)
(
	input sel,
	input [width-1:0] a,
	output logic [width-1:0] f, g
);

always_comb
begin
	if (sel==0) begin
		f = a;
		g = 0;
	end
	else begin
		f = 0;
		g = a;
	end
end

endmodule : dmux2
