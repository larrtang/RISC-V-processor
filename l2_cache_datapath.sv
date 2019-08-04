import rv32i_types::*;

module l2_cache_datapath 
#(
   parameter s_offset = 5,
   parameter s_index  = 3,
   parameter s_tag    = 32 - s_offset - s_index,
   parameter s_mask   = 2**s_offset,
   parameter s_line   = 8*s_mask,
   parameter num_sets = 2**s_index
)
(
	input clk,
	input rv32i_word mem_address, next_mem_address,
	input logic [255:0] mem_wdata, 
	output logic [255:0] mem_rdata,
	input logic [3:0] mem_byte_enable,
	
	input logic [255:0] pmem_rdata,
	output logic [255:0] pmem_wdata,
	
	input logic load_data0, load_data1,
	input logic load_tag0, load_tag1,
	input logic load_valid0, load_valid1,
	input logic load_dirty0, load_dirty1,
	input logic load_lru,
	
	output logic hit0, hit1,
	
	input logic datamux_sel,
	input logic [1:0] addrmux_sel,
	
	input logic valid0_in, valid1_in,
	output logic valid0_out, valid1_out,
	
	input logic dirty0_in, dirty1_in,
	output logic dirty0_out, dirty1_out,
	
	input logic lru_in,
	output logic lru_out,
	
	output rv32i_word pmem_address
	
);

//logic [s_offset-1:0] offset;
logic [s_index-1:0] index;
logic [s_tag-1:0] _tag;
//assign offset = mem_address[s_offset-1:0];
assign index = mem_address[s_index+s_offset-1:5];
assign _tag = mem_address[31:s_index+s_offset];


logic [s_tag-1:0] tag0_out, tag1_out;
logic [255:0] data_in, data0_out, data1_out;
logic [255:0] mem_rdata_mux_in, data_decoder_out;


array #(.width(256), .s_index(s_index)) line [2]
(
	.clk(clk),
	.read(1'b1),
	.load({load_data0, load_data1}),
	.index(index),
	.datain(data_in),
	.dataout({data0_out, data1_out})
);


array #(.s_index(s_index))  valid [2]
(
	.clk(clk),
	.read(1'b1),
	.load({load_valid0, load_valid1}),
	.index(index),
	.datain({valid0_in, valid1_in}),
	.dataout({valid0_out, valid1_out})
);


array #(.s_index(s_index)) dirty [2]
(
	.clk(clk),
	.read(1'b1),
	.load({load_dirty0, load_dirty1}),
	.index(index),
	.datain({dirty0_in, dirty1_in}),
	.dataout({dirty0_out, dirty1_out})
);


array #(.width(s_tag), .s_index(s_index))  tag [2]
(
	.clk(clk),
	.read(1'b1),
	.load({load_tag0, load_tag1}),
	.index(index),
	.datain(_tag),
	.dataout({tag0_out, tag1_out})
);


array #(.width(1), .s_index(s_index)) lru
(
	.clk(clk),
	.read(1'b1),
	.load(load_lru),
	.index(index),
	.datain(lru_in),
	.dataout(lru_out)
);

mux4 addrmux
(
	.sel(addrmux_sel),
	.a(mem_address),
	.b({tag0_out, index, 5'h0}),
	.c({tag1_out, index, 5'h0}),
	.d(next_mem_address),
	.f(pmem_address)
);


mux2 #(.width(256)) pmem_wdata_mux
(
	.sel(lru_out),
	.a(data0_out),
	.b(data1_out),
	.f(pmem_wdata)
);


mux2 #(.width(256)) mem_rdata_mux1
(
	.sel(hit1),
	.a(data0_out),
	.b(data1_out),
	.f(mem_rdata)
);


mux2 #(.width(256)) datamux
(
	.sel(datamux_sel),
	.a(pmem_rdata),
	.b(mem_wdata),
	.f(data_in)
);


hit_cmp #(.s_index(s_index)) hit0_cmp
(
	.addr_tag(_tag),
	.cache_tag(tag0_out),
	.valid(valid0_out),
	.hit(hit0)
);

hit_cmp #(.s_index(s_index)) hit1_cmp
(
	.addr_tag(_tag),
	.cache_tag(tag1_out),
	.valid(valid1_out),
	.hit(hit1)
);

endmodule : l2_cache_datapath
