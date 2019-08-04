import rv32i_types::*;

module branch_predict 
#(
	parameter s_pc = 4,
	parameter s_bh = 4,
	parameter s_index = s_pc + s_bh,
	parameter num_sets_pht = 2**s_index,
	parameter num_sets_bht = 2**s_pc 
)
(
//inputs
	input clk,
	input rv32i_word IF_pc,			//PC from IF stage
	input rv32i_word EX_pcnext,		//next PC from EX stage (target address in for br)
	input rv32i_word EX_alu,		//target address in for jump
	input rv32i_word EX_pc,			//PC from EX stage
	input rv32i_opcode IF_opcode,	//opcode from IF stage
	input rv32i_opcode EX_opcode,	//opcode from EX stage
	input logic EX_br_en,			//branch result from EX stage
	input logic EX_jump_en,
	input logic EX_br_prediction,	//branch prediction from EX stage (assigned in b_p)
	input logic EX_predictor,		//0 for local, 1 for global (from EX, assigned in b_p)
	input rv32i_word EX_tgtaddr,
	input logic stall,
//outputs
	output logic prediction,			//1 for taken, 0 for not taken
	output logic predictor,				//0 for local, 1 for global
	output rv32i_word target_address_out,
	output logic mispredict				//if we had a mispredict and need to reset
);

logic load_bh, IF_load_btb, EX_load_btb;
logic [s_index-1:0] IF_global_pht_index, IF_local_pht_index, EX_global_pht_index, EX_local_pht_index;
logic [s_pc-1:0] IF_pc_index, EX_pc_index;
logic [31:0] tag_array_out;
logic [s_bh-1:0] bhr_data, bht_data;
logic [1:0] local_pht_data, global_pht_data, tourney_pht_data;
logic pht_inc, pht_dec, tourney_inc, tourney_dec;
logic local_prediction, global_prediction;
logic tgtaddrmux_sel;
rv32i_word target_address_in;

assign IF_pc_index = IF_pc[s_pc+1:2];
assign EX_pc_index = EX_pc[s_pc+1:2];
assign IF_global_pht_index = {IF_pc[s_pc+1:2], bhr_data};
assign IF_local_pht_index = {IF_pc[s_pc+1:2], bht_data[IF_pc_index]};
assign EX_global_pht_index = {EX_pc[s_pc+1:2], bhr_data};
assign EX_local_pht_index = {EX_pc[s_pc+1:2], bht_data[EX_pc_index]};

assign IF_load_btb = (IF_pc != tag_array_out) && ((IF_opcode == op_jal) || (IF_opcode == op_jalr) || (IF_opcode == op_br));
assign EX_load_btb = ((EX_opcode == op_jal) || (EX_opcode == op_jalr) || (EX_opcode == op_br));
assign load_bh = (EX_opcode == op_br) & ~stall;

assign pht_inc = EX_br_en;
assign pht_dec = ~EX_br_en;

always_comb begin
	mispredict = 1'b0;
	tourney_inc = 1'b0;
	tourney_dec = 1'b0;
	local_prediction = 1'b0;
	global_prediction = 1'b0;
	prediction = 1'b0;
	predictor = 1'b0;
	tgtaddrmux_sel = 1'b0;

	if(EX_jump_en)
		tgtaddrmux_sel = 1'b1;

	if(EX_br_prediction && (EX_tgtaddr != EX_alu) && EX_jump_en)
		mispredict = 1'b1;
	else if((EX_br_en != EX_br_prediction) && (EX_opcode == op_br))
		mispredict = 1'b1;
	else if((EX_jump_en != EX_br_prediction) && ((EX_opcode == op_jal) || (EX_opcode == op_jalr)))
		mispredict = 1'b1;

	if((EX_br_en == EX_br_prediction) && !EX_predictor)		//local was correct
		tourney_dec = 1'b1;
	else if((EX_br_en == EX_br_prediction) && EX_predictor) //global was correct
		tourney_inc = 1'b1;
	else if(mispredict && !EX_predictor)					//local was wrong
		tourney_inc = 1'b1;
	else if(mispredict && EX_predictor)						//global was wrong
		tourney_dec = 1'b1;
	


	if(((IF_opcode == op_jal) || (IF_opcode == op_jalr)) && (target_address_out != 0) && (tag_array_out == IF_pc)) begin
		local_prediction = 1'b1;
		global_prediction = 1'b1;
	end else if((IF_opcode == op_br) && (target_address_out != 0) && (tag_array_out == IF_pc)) begin
		if((local_pht_data == 2'b10) || (local_pht_data == 2'b11))
			local_prediction = 1'b1;

		if((global_pht_data == 2'b10) || (global_pht_data == 2'b11))
			global_prediction = 1'b1;
	end

	if((tourney_pht_data == 2'b00) || (tourney_pht_data == 2'b01))
		prediction = local_prediction;
	else if((tourney_pht_data == 2'b10) || (tourney_pht_data == 2'b11)) begin
		prediction = global_prediction;
		predictor = 1'b1;
	end

end

//==========================================================================================
//----------------------------------------------------Local Branch Predictor----------------
//==========================================================================================
shiftreg_array_di #(.width(s_bh), .s_index(s_pc)) local_bht (
	.clk,
	.load(load_bh),
	.reset(),
	.read_index(IF_pc_index),
	.write_index(EX_pc_index),
	.datain(EX_br_en),

	.dataout(bht_data)
);

counter2bit_array_di #(.s_index(s_index)) local_pht (
	.clk,
	.reset(),
	.increment(pht_inc & load_bh),
	.decrement(pht_dec & load_bh),
	.read_index(IF_local_pht_index),
	.write_index(EX_local_pht_index),

	.out(local_pht_data)
);
//==========================================================================================
//---------------------------------------------------Global Branch Predictor----------------
//==========================================================================================
shiftreg #(.width(s_bh)) global_bhr (
	.clk,
	.load(load_bh),
	.reset(),
	.in(EX_br_en),

	.out(bhr_data)
);

counter2bit_array_di #(.s_index(s_index)) global_pht (
	.clk,
	.reset(),
	.increment(pht_inc & load_bh),
	.decrement(pht_dec & load_bh),
	.read_index(IF_global_pht_index),
	.write_index(EX_global_pht_index),

	.out(global_pht_data)
);
//==========================================================================================
//-----------------------------------------------Tournament Branch Predictor----------------
//==========================================================================================
counter2bit_array_di #(.s_index(s_pc)) tourney_pht (
	.clk,
	.reset(),
	.increment(tourney_inc & load_bh),
	.decrement(tourney_dec & load_bh),
	.read_index(IF_pc_index),
	.write_index(EX_pc_index),

	.out(tourney_pht_data)
);
//==========================================================================================
//-----------------------------------------------------------------------BTB----------------
//==========================================================================================
mux2 #(.width(32)) targetaddrin_mux (
	.sel(tgtaddrmux_sel),
	.a(EX_pcnext),
	.b(EX_alu),
	.f(target_address_in)
);

array #(.width(32), .s_index(s_pc)) tags (
	.clk,
	.read(),
	.load(IF_load_btb),
	.index(IF_pc_index),
	.datain(IF_pc),

	.dataout(tag_array_out)
);

array_di_dl #(.width(32), .s_index(s_pc)) target_addresses (
	.clk,
	.load_a(IF_load_btb),
	.load_b(EX_load_btb & (EX_br_en | EX_jump_en)),
	.index_a(IF_pc_index),
	.index_b(EX_pc_index),
	.datain(target_address_in),

	.dataout(target_address_out)
);
//==========================================================================================

endmodule : branch_predict
