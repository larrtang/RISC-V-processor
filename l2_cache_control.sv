
module l2_cache_control 
(
	input clk,
	
	input logic mem_read, mem_write,
	input logic[3:0] mem_byte_enable,
	input logic pmem_resp,
	
	input logic hit0, hit1,hit0_, hit1_,
	input logic valid0, valid1,
	input logic dirty0, dirty1,
	input logic lru,

	input logic ewb_stall,
	
	output logic load_data0, load_data1,
	output logic load_dirty0, load_dirty1,
	output logic load_tag0, load_tag1,
	output logic load_valid0, load_valid1,
	output logic load_lru,
	
	output logic valid0_out, valid1_out,
	output logic dirty0_out, dirty1_out, 
	output logic lru_out,
	
	output logic [1:0] addrmux_sel,
	output logic datamux_sel,
	
	output logic mem_resp,
	output logic pmem_read, pmem_write, stall, ready
	
);

enum int unsigned 
{
	start,
	hit_detect,
	write_back,
	allocate

	} state, next_state;

always_comb
begin : state_actions
	load_data0 = 1'b0;
	load_data1 = 1'b0;
	lru_out = 1'b0;
	load_tag0 = 1'b0;
	load_tag1 = 1'b0;
	load_valid0 = 1'b0;
	load_valid1 = 1'b0;
	load_dirty0 = 1'b0;
	load_dirty1 = 1'b0;
	load_lru = 1'b0;
	

	dirty0_out = 1'b0;
	dirty1_out = 1'b0;
	valid0_out = 1'b1;
	valid1_out = 1'b1;
	
	addrmux_sel = 2'b00;
	datamux_sel = 1'b0;
	
	mem_resp = 1'b0;
	pmem_write = 1'b0;
	pmem_read = 1'b0;
	stall = 1'b0;	
	ready = 1'b0;
	
	case(state)
		start: begin
			ready = 1'b1;
			if (hit0 || hit1) begin
				if (mem_read) begin
					mem_resp = 1'b1;
					load_lru = 1'b1;				
					if (hit0) lru_out = 1'b1;
					if (hit1) lru_out = 1'b0;
				end
				if (mem_write) begin
					if (hit0) begin
						load_lru = 1'b1;
						load_dirty0 = 1'b1;
						dirty0_out = 1'b1;
						
						if (valid0) begin
							load_data0 = 1'b1;
							load_valid0 = 1'b1;
							load_tag0 = 1'b1;
							mem_resp = 1'b1;
							datamux_sel = 1'b1;
						end
					end 
					if (hit1) begin
						load_lru = 1'b1;
						load_dirty1 = 1'b1;
						dirty1_out = 1'b1;
						
						if (valid1) begin
							load_data1 = 1'b1;
							load_valid1 = 1'b1;
							load_tag1 = 1'b1;
							mem_resp = 1'b1;
							datamux_sel = 1'b1;
						end
					end
				end
			end
//			if (mem_read) begin
//				mem_resp = 1'b1;
//			end
//			if (mem_write) begin
//				mem_resp = 1'b1;
//				
//			end
		end
		
		
		hit_detect: begin 
			if (hit0 || hit1) begin
				if (mem_read) begin
					mem_resp = 1'b1;
					load_lru = 1'b1;				
					if (hit0) lru_out = 1'b1;
					if (hit1) lru_out = 1'b0;
				end
				if (mem_write) begin
					if (hit0) begin
						load_lru = 1'b1;
						load_dirty0 = 1'b1;
						dirty0_out = 1'b1;
						
						if (valid0) begin
							load_data0 = 1'b1;
							load_valid0 = 1'b1;
							load_tag0 = 1'b1;
							mem_resp = 1'b1;
							datamux_sel = 1'b1;
						end
					end 
					if (hit1) begin
						load_lru = 1'b1;
						load_dirty1 = 1'b1;
						dirty1_out = 1'b1;
						
						if (valid1) begin
							load_data1 = 1'b1;
							load_valid1 = 1'b1;
							load_tag1 = 1'b1;
							mem_resp = 1'b1;
							datamux_sel = 1'b1;
						end
					end
				end
			end
		end 
		write_back: begin					
			pmem_write = 1'b1;
			stall = 1'b1;
			case(lru)
				1'b0: begin
					addrmux_sel = 2'b01;
				end
				1'b1: begin
					addrmux_sel = 2'b10;
				end
			endcase
		end
		
		allocate: begin
			//mem_resp = 1'b0;
			stall = 1'b1;
			pmem_read = 1'b1;
			//if (hit0 == 1 || hit1 == 1) addrmux_sel = 2'b11;
			//else 
				addrmux_sel = 2'b00;
			if (lru) begin
				load_valid1 = pmem_resp;
				load_data1 = pmem_resp;
				load_tag1 = pmem_resp;
				load_dirty1 = pmem_resp;
				dirty1_out = 1'b0;
				valid1_out = 1'b1;
			end
			if (!lru) begin
				load_valid0 = pmem_resp;
				load_data0 = pmem_resp;
				load_tag0 = pmem_resp;
				load_dirty0 = pmem_resp;
				dirty0_out = 1'b0;
				valid0_out = 1'b1;
			end
		end
	endcase
end

always_comb
begin: next_state_logic
	next_state = state;
	
	case(state)
		start: begin
			if((!hit0 && !hit1) && (!dirty0 && !dirty1) && (mem_read || mem_write) && !ewb_stall) next_state = allocate;
			//if(mem_read || mem_write) next_state = hit_detect;
			else if ((!hit0 && !hit1) && (dirty0 || dirty1) && (mem_read || mem_write) && !ewb_stall) next_state = write_back;
			//else next_state = start;
		end
		hit_detect: begin
			if ((!hit0 && !hit1) && (!dirty0 && !dirty1)) next_state = allocate;
			else if ((!hit0 && !hit1) && (dirty0 || dirty1)) next_state = write_back;
			else next_state = start;
		end
		write_back: begin
			if(pmem_resp) next_state = allocate;
			else next_state = write_back;
		end
		allocate: begin
			if(pmem_resp) next_state = start;
			else next_state = allocate;
		end
		
		default: next_state = start;
	endcase
end


always_ff @(posedge clk)
begin: next_state_assignment
	state <= next_state;
end

endmodule : l2_cache_control

