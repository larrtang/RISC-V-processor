import rv32i_types::*;

module write_buffer
(
	input clk,
	input rv32i_word pmem_address_in,
	input [255:0] pmem_wdata_in, pmem_rdata_in,
	input logic pmem_read_in,
	input logic pmem_write_in,
	input logic pmem_resp,
	input logic l2_ready,


	output logic [255:0] pmem_wdata, pmem_rdata,
	output rv32i_word pmem_address,
	output logic ewb_resp,
	output logic pmem_write, pmem_read,
	output logic ewb_stall
);

logic pmem_write_;

rv32i_word stored_address;
logic rdatamux_sel;
register #(.width(256)) data
(
	.clk,
	.load(pmem_write_in),
	.reset(1'b0),
	.in (pmem_wdata_in),
	.out(pmem_wdata)
);

register #(.width(32)) address
(
	.clk,
	.load(pmem_write_in),
	.reset(1'b0),
	.in(pmem_address_in),
	.out(stored_address)
);

mux2 #(.width(256)) rdatamux
(
	.sel(rdatamux_sel),
	.a(pmem_wdata),			// data to be read in write buffer
	.b(pmem_rdata_in),
	.f(pmem_rdata)
);

register #(.width(1)) pmem_write_reg
(
	.clk,
	.load(pmem_write_in),
	.reset(pmem_resp & ~pmem_read_in),
	.in(pmem_write_in),
	.out(pmem_write_)
);


always_comb begin
	pmem_address = pmem_address_in;
	pmem_read = 0;
	pmem_write = 0;
	ewb_resp = 0;
	rdatamux_sel = 1;
	ewb_stall = 0;
	
	
	if (pmem_read_in) begin
		if (pmem_address_in == stored_address)
			rdatamux_sel = 0;
		else rdatamux_sel = 1;
		ewb_resp = pmem_resp;
		pmem_read = 1;
	end

	if (pmem_write_ & l2_ready) begin
		pmem_address = stored_address;
		pmem_write = 1;
		ewb_stall = 1;
	end else if(pmem_write_ & ~pmem_read_in) begin
		ewb_resp = pmem_write_in;
	end
end

always_ff @(posedge clk) begin

end

endmodule : write_buffer
