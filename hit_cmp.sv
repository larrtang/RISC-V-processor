module hit_cmp
#(
   parameter s_offset = 5,
   parameter s_index  = 3,
   parameter s_tag    = 32 - s_offset - s_index,
   parameter s_mask   = 2**s_offset,
   parameter s_line   = 8*s_mask,
   parameter num_sets = 2**s_index
)
(
	input logic [s_tag-1:0] addr_tag,
	input logic [s_tag-1:0] cache_tag,
	input logic valid,
	output logic hit
);

always_comb
begin
	hit = valid && (addr_tag == cache_tag);
end

endmodule: hit_cmp
