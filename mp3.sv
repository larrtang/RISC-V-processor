import rv32i_types::*;

module mp3
(
	input clk,
	input logic [255:0] pmem_rdata,
	input logic pmem_resp,
 
	output rv32i_word pmem_address,
	output logic [255:0] pmem_wdata,
	output logic pmem_write, pmem_read
);

rv32i_word mem_rdata, mem_wdata, mem_address, next_mem_address, ir_in, pc_out;
logic [3:0] mem_byte_enable;
logic mem_read, mem_write, mem_resp, mem_read_data, mem_read_instr;
logic mem_resp_instr, mem_resp_data;
logic l1cache_sel;
logic istall, dstall, stall;

//L2 cache stuff
rv32i_word l2_mem_address;
logic dcache_l2_write;
logic dcache_l2_read, icache_l2_read;
logic l2stall;
rv32i_word dcache_l2_address, icache_l2_address;
logic [255:0] l2_wdata, l2_rdata;
logic l2_resp;
logic dcache_l2_resp, icache_l2_resp;
logic dwrite;
rv32i_word pmem_address_in; 
logic [255:0] pmem_wdata_in, ewb_pmem_rdata; 
logic pmem_write_in, pmem_read_in;
logic allocate_pmem_resp;
logic ewb_resp, ewb_stall, l2_ready;



always_comb 
begin
	stall = 0;

	if(!mem_resp_instr || (!mem_resp_data && (mem_read_data || mem_write))) stall = 1;
end 



cpu cpu
(
//inputs
	.clk,
	.mem_resp_data, 
	.mem_resp_instr,
	.mem_rdata, 
	.ir_in,
	.stall,
//outputs
	.mem_byte_enable,
	.pc_out,
	.mem_address,
	.next_mem_address,
	.mem_wdata,
	.mem_read_instr, 
	.mem_read_data,
	.mem_write
);

cache #(.s_index(5)) instr_cache
(
	.clk(clk),
	.mem_byte_enable(mem_byte_enable),
	.mem_address(pc_out), 
	.next_mem_address(pc_out + 32'h4),
	.mem_wdata(),
	.mem_read(mem_read_instr), 
	.mem_write(),
	.pmem_resp(icache_l2_resp),
	.pmem_rdata(l2_rdata),
	
	.pmem_address(icache_l2_address), 
	.mem_rdata(ir_in),
	.mem_resp(mem_resp_instr), 
	.pmem_read(icache_l2_read), 
	.pmem_write(), 						//icache will never write to pmem
	.pmem_wdata(),
	.stall(istall)
);

cache #(.s_index(5)) data_cache
(
	.clk(clk),
	.mem_byte_enable(mem_byte_enable),
	.mem_address(mem_address), 
	.next_mem_address(mem_address+32'h4),
	.mem_wdata(mem_wdata),
	.mem_read(mem_read_data), 
	.mem_write(mem_write),
	.pmem_resp(dcache_l2_resp),
	.pmem_rdata(l2_rdata),
	
	.pmem_address(dcache_l2_address), 
	.mem_rdata(mem_rdata),
	.mem_resp(mem_resp_data), 
	.pmem_read(dcache_l2_read), 
	.pmem_write(dwrite),
	.pmem_wdata(l2_wdata),
	.stall(dstall)
);


// l2_cache #(.s_index(4)) l2_cache
// (
// 	.clk(clk),
// 	.mem_byte_enable(mem_byte_enable),
// 	.mem_address(l2_mem_address), 
// 	.next_mem_address(mem_address+32'h4),
// 	.mem_wdata(l2_wdata),
// 	.mem_read(dcache_l2_read | icache_l2_read), 
// 	.mem_write(dcache_l2_write),
// 	.pmem_resp,
// 	.pmem_rdata,
	
// 	.pmem_address, 
// 	.mem_rdata(l2_rdata),
// 	.mem_resp(l2_resp), 
// 	.pmem_read, 
// 	.pmem_write,
// 	.pmem_wdata,
// 	.stall(l2stall)
// );

l2_cache #(.s_index(6)) l2_cache
(
	.clk(clk),
	.mem_byte_enable(mem_byte_enable),
	.mem_address(l2_mem_address), 
	.next_mem_address(mem_address+32'h4),
	.mem_wdata(l2_wdata),
	.mem_read(dcache_l2_read | icache_l2_read), 
	.mem_write(dcache_l2_write),
	.pmem_resp(ewb_resp),
	.pmem_rdata(ewb_pmem_rdata),
	.ewb_stall,
	
	.pmem_address(pmem_address_in), 
	.mem_rdata(l2_rdata),
	.mem_resp(l2_resp), 
	.pmem_read(pmem_read_in), 
	.pmem_write(pmem_write_in),
	.pmem_wdata(pmem_wdata_in),
	.stall(l2stall),
	.ready(l2_ready)
);

write_buffer ewb
(
	.clk,
	.pmem_address_in,
	.pmem_wdata_in, 
	.pmem_rdata_in(pmem_rdata),
	.pmem_read_in,
	.pmem_write_in,
	.pmem_resp,
	.l2_ready,

	.pmem_wdata,
	.pmem_rdata(ewb_pmem_rdata),
	.pmem_address,
	.ewb_resp,
	.pmem_write, 
	.pmem_read,
	.ewb_stall
);


assign dcache_l2_write = dwrite & ~istall;

arbiter arbiter
(
	.dstall,
	.istall,

	.l1cache_sel
);

dmux2 #(.width(1)) l2_resp_dmux
(
	.sel(l1cache_sel),
	.a(l2_resp),

	.f(icache_l2_resp),
	.g(dcache_l2_resp)
);

mux2 #(.width(32)) l2_addr_mux
(
	.sel(l1cache_sel),
	.a(icache_l2_address),
	.b(dcache_l2_address),

	.f(l2_mem_address)
);


endmodule : mp3