module arbiter (
//inputs
	input logic dstall,
	input logic istall,

//outputs
	output logic l1cache_sel
);


always_comb
begin

if(istall)
	l1cache_sel = 0;
else if(dstall)
	l1cache_sel = 1;
else
	l1cache_sel = 0;

end


endmodule : arbiter
