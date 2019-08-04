import rv32i_types::*;

module cmp #(parameter width = 32)
(
	input branch_funct3_t cmpop,
	input rv32i_word a, b,
	input logic read,
	output logic out
);

always_comb
begin
	out = 0;

	case (cmpop)
		beq: out = ($signed(a) == $signed(b)) && read;
		bne: out = ($signed(a) != $signed(b)) && read;
		blt: out = ($signed(a) < $signed(b)) && read;
		bge: out = ($signed(a) >= $signed(b)) && read;
		bltu: out = ($unsigned(a) < $unsigned(b)) && read;
		bgeu: out = ($unsigned(a) >= $unsigned(b)) && read;
		default: out = 0;
	endcase
end 

endmodule : cmp
