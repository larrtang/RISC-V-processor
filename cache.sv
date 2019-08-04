import rv32i_types::*;


module cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
	input clk,
	input logic [3:0] mem_byte_enable,
	input rv32i_word mem_address, next_mem_address, mem_wdata,
	input logic mem_read, mem_write,
	input logic pmem_resp,
	input logic [255:0] pmem_rdata,
	
	output rv32i_word pmem_address, mem_rdata,
	output logic mem_resp, pmem_read, pmem_write,
	output logic [255:0] pmem_wdata,
	output logic stall
);

logic load_data0, load_data1;
logic load_valid0, load_valid1;
logic load_dirty0, load_dirty1;
logic load_tag0, load_tag1;
logic load_lru;

logic valid0_in, valid1_in;
logic valid0_out, valid1_out;

logic dirty0_in, dirty1_in;
logic dirty0_out, dirty1_out;
logic lru_in, lru_out;
logic hit0, hit1;
logic hit0_, hit1_;
logic datamux_sel;
logic [1:0] addrmux_sel;
logic mem_read_, mem_write_;

cache_control control
(
	.clk(clk),
	.mem_byte_enable(mem_byte_enable),
	.load_data0(load_data0),
	.load_data1(load_data1),
	.load_valid0(load_valid0),
	.load_valid1(load_valid1),
	.load_tag0(load_tag0),
	.load_tag1(load_tag1),
	.load_dirty0(load_dirty0),
	.load_dirty1(load_dirty1),
	
	.hit0(hit0),
	.hit1(hit1),
	.hit0_(hit0_),
	.hit1_(hit1_),

	
	.valid0(valid0_out),
	.valid1(valid1_out),
	.valid0_out(valid0_in),
	.valid1_out(valid1_in),
	
	.dirty0(dirty0_out),
	.dirty1(dirty1_out),
	.dirty0_out(dirty0_in),
	.dirty1_out(dirty1_in),
	
	.lru( lru_out),
	.lru_out(lru_in),
	.load_lru(load_lru),
	
	.addrmux_sel(addrmux_sel),
	.datamux_sel(datamux_sel),
	
	.mem_read(mem_read),
	.mem_write(mem_write),
	.mem_resp(mem_resp),
	.pmem_read(pmem_read),
	.pmem_write(pmem_write),
	.pmem_resp(pmem_resp),
	.stall
);


cache_datapath #(.s_index(s_index)) datapath
(
	.clk(clk),
	
	.mem_byte_enable(mem_byte_enable),
	.mem_rdata(mem_rdata),
	.mem_wdata(mem_wdata),
	.pmem_wdata(pmem_wdata),
	.pmem_rdata(pmem_rdata),
	.mem_address(mem_address),
	.next_mem_address(next_mem_address),

	.pmem_address(pmem_address),
	
	.load_data0(load_data0),
	.load_data1(load_data1),
	.load_valid0(load_valid0),
	.load_valid1(load_valid1),
	.load_tag0(load_tag0),
	.load_tag1(load_tag1),
	.load_dirty0(load_dirty0),
	.load_dirty1(load_dirty1),
	
	.hit0(hit0),
	.hit1(hit1),
	
	.valid0_out(valid0_out),
	.valid1_out(valid1_out),
	.valid0_in(valid0_in),
	.valid1_in(valid1_in),
	
	.dirty0_out(dirty0_out),
	.dirty1_out(dirty1_out),
	.dirty0_in(dirty0_in),
	.dirty1_in(dirty1_in),
	
	.lru_out(lru_out),
	.lru_in(lru_in),
	.load_lru(load_lru),
	
	.addrmux_sel(addrmux_sel),
	.datamux_sel(datamux_sel)

);

register #(.width(1)) hit_register [2]
(
	.clk(clk),
	.load(1'b1),
	.reset(),
	.in({hit0,hit1}),
	.out({hit0_, hit1_})
);
 

endmodule : cache
