import rv32i_types::*;

module cpu
(
	input clk,
	input logic mem_resp_data, mem_resp_instr,
	input rv32i_word mem_rdata, ir_in,
	input logic stall,

	output logic [3:0] mem_byte_enable,
	output rv32i_word pc_out,
	output rv32i_word mem_address,
	output rv32i_word next_mem_address,
	output rv32i_word mem_wdata,
	output logic mem_read_instr, mem_read_data,
	output logic mem_write
);


logic load_pc; //from STALL CONTROL


/*IF STAGE*/
rv32i_word IF_pc_out;
rv32i_word IF_pc_plus4_out;
logic IF_br_en_in;
rv32i_word IF_pc_current;
rv32i_word IF_pcnext_in;


/*ID STAGE*/
rv32i_word ID_pc_in;
rv32i_word ID_pc_out;
rv32i_word ID_pc_plus4_out;
rv32i_control_word ID_control_rom_out;
rv32i_reg ID_rd_addr_out;
rv32i_reg ID_rs1_addr_out;
rv32i_reg ID_rs2_addr_out;
rv32i_word ID_rs1_out;
rv32i_word ID_rs2_out;
rv32i_word ID_imm_value;
rv32i_word ID_i_imm_out;
rv32i_word ID_u_imm_out;
rv32i_word ID_b_imm_out;
rv32i_word ID_s_imm_out;
rv32i_word ID_j_imm_out;
logic ID_br_predict_out;
logic ID_br_predictor_out;
rv32i_word ID_tgtaddr_out;


/* EX STAGE */
rv32i_word EX_pc_out;
rv32i_word EX_pc_plus4_out;
rv32i_word EX_pc_next_out; //for branching
rv32i_word EX_rs2_out;
rv32i_word EX_alu_out;
rv32i_reg EX_rd_addr_out;
rv32i_reg EX_rs1_addr_out;
rv32i_reg EX_rs2_addr_out;
rv32i_control_word EX_control_rom_out;
logic EX_br_en;
logic EX_jump_en;
rv32i_word EX_rs1_out; //for IF stage ** not needed anymore
rv32i_word EX_u_imm_out;
logic EX_br_predict_out;
logic EX_br_predictor_out;
rv32i_word EX_tgtaddr_out;



/* MEM STAGE */
rv32i_word MEM_pc_out;
rv32i_word MEM_pc_plus4_out;
rv32i_word MEM_rs1_out,MEM_rs2_out;	
rv32i_word MEM_alu_out;
rv32i_reg MEM_rd_addr_out;
rv32i_reg MEM_rs1_addr_out;
rv32i_reg MEM_rs2_addr_out;
rv32i_control_word MEM_control_rom_out;
//rv32i_word MEM_mdr_out;
rv32i_word MEM_u_imm_out;
logic [3:0] MEM_mem_byte_enable;


/* WB STAGE */
rv32i_control_word WB_control_rom_out;
rv32i_word WB_regfilemux_out;
rv32i_reg WB_rd_addr_out;
rv32i_reg WB_rs1_addr_out;
rv32i_reg WB_rs2_addr_out;
rv32i_word WB_mdr_out;
rv32i_word WB_alu_out;

/*Branch Predictor signals*/
logic bp_prediction_out;
logic bp_predictor_out;
rv32i_word bp_target_address_out;
logic bp_mispredict_out;

rv32i_word ID_ir_in, ID_ir_out, EX_ir_in, EX_ir_out, MEM_ir_in, MEM_ir_out, WB_ir_out;

assign load_pc = ~stall;
assign pc_out = IF_pc_out;
assign mem_read_instr = 1'b1; // & with something? or use load_pc?
assign mem_read_data = MEM_control_rom_out.mem_read_data;
assign mem_write = MEM_control_rom_out.mem_write;
//assign mem_byte_enable = MEM_control_rom_out.mem_byte_enable;
assign mem_byte_enable = MEM_mem_byte_enable;
assign mem_address = MEM_alu_out;
assign next_mem_address = EX_alu_out;

assign mem_wdata = MEM_rs2_out;


logic [9:0] count_misspredict;
logic [9:0] count_branchess;
initial begin
	count_misspredict = 0;
	count_branchess = 0;
end
always_ff @(posedge clk) begin
	if(bp_mispredict_out & ~stall)
		count_misspredict = count_misspredict + 1;
	if(EX_br_en & ~stall)
		count_branchess = count_branchess + 1;
end
always_comb begin
	if(bp_mispredict_out && !(EX_br_en || EX_jump_en)) begin	//branch not taken but predicted taken
		IF_pcnext_in = EX_pc_plus4_out;
		IF_br_en_in = 1'b0;
	end else if(bp_mispredict_out && (EX_br_en || EX_jump_en)) begin	//branch taken but predicted not taken
		IF_pcnext_in = EX_pc_next_out;
		IF_br_en_in = 1'b1;
	end else begin
		IF_pcnext_in = bp_target_address_out;
		IF_br_en_in = bp_prediction_out;
	end
end


logic [2:0] forwardA;
logic [2:0] forwardB;
logic forwardC, forwardD, forwardE, forwardF;

always_comb
begin
	/*FORWARD A LOGIC*/												
	if ((WB_control_rom_out.load_regfile == 1) && 
		(WB_rd_addr_out == EX_rs1_addr_out) && 
		((MEM_rd_addr_out != EX_rs1_addr_out) || 
			(MEM_control_rom_out.load_regfile == 0)) &&
		!(MEM_control_rom_out.opcode == op_auipc && 
			MEM_rs1_addr_out == 0) &&
		(EX_control_rom_out.opcode != op_jal) &&
		WB_rd_addr_out != 0)								//2a		//WB-->EX
			forwardA = 1;

	else if ((MEM_control_rom_out.load_regfile == 1) && 
		(MEM_control_rom_out.opcode == op_load) &&
		(MEM_rd_addr_out == EX_rs1_addr_out) &&
		(EX_control_rom_out.opcode != op_jal) &&
		MEM_rd_addr_out != 0)								//3a		//MEM-->EX 		load then another instruction
			forwardA = 3;

	else if ((MEM_control_rom_out.load_regfile == 1) && 
		(MEM_rd_addr_out == EX_rs1_addr_out) &&
		(EX_control_rom_out.opcode != op_jal) &&
		MEM_rd_addr_out != 0)								//1a		//MEM-->EX 		all other combinations
			forwardA = 2;
	
	else forwardA = 0;
	
	/*FORWARD B LOGIC */	
	if ((WB_control_rom_out.load_regfile == 1) && 
		(WB_rd_addr_out == EX_rs2_addr_out) && 
		((MEM_rd_addr_out != EX_rs2_addr_out) || 
		(MEM_control_rom_out.load_regfile == 0)) &&
		(EX_control_rom_out.opcode == op_store) &&
		//(MEM_control_rom_out.opcode != op_auipc) &&
		WB_rd_addr_out != 0)								//4b		//WB-->EX 		for stores
			forwardB = 4;
											
	else if ((WB_control_rom_out.load_regfile == 1) && 
		(WB_rd_addr_out == EX_rs2_addr_out) && 
		((MEM_rd_addr_out != EX_rs2_addr_out) || 
		(MEM_control_rom_out.load_regfile == 0)) &&
		(EX_control_rom_out.opcode != op_load) &&
		(EX_control_rom_out.opcode != op_jal) &&
		(EX_control_rom_out.opcode != op_jalr) &&
		(EX_control_rom_out.opcode != op_store) &&
		//(MEM_control_rom_out.opcode != op_auipc) &&
		WB_rd_addr_out != 0)								//2b		//WB-->EX
			forwardB = 1;
	
	else if ((MEM_rd_addr_out == EX_rs2_addr_out) && 
		(MEM_control_rom_out.opcode == op_load) &&
		(MEM_control_rom_out.load_regfile == 1) &&
		(EX_control_rom_out.opcode != op_load) &&
		(EX_control_rom_out.opcode != op_jal) &&
		(EX_control_rom_out.opcode != op_jalr) &&
		(EX_control_rom_out.opcode != op_store) &&
		MEM_rd_addr_out != 0)								//3b		//MEM-->EX 		load then another instruction
			forwardB = 3;

	else if ((MEM_rd_addr_out == EX_rs2_addr_out) && 
		(MEM_control_rom_out.load_regfile == 1) &&
		(EX_control_rom_out.opcode != op_load) &&
		(EX_control_rom_out.opcode != op_jal) &&
		(EX_control_rom_out.opcode != op_jalr) &&
		(EX_control_rom_out.opcode != op_store) &&
		MEM_rd_addr_out != 0)								//1b		//MEM-->EX 		all other combinations
			forwardB = 2;
	
	else forwardB = 0;

	/*FORWARD C LOGIC */												//WB-->MEM								
	// lw then sw
	if (MEM_control_rom_out.mem_write == 1 && 
		WB_rd_addr_out == MEM_rs1_addr_out && 
		MEM_control_rom_out.opcode != op_jal) 
			forwardC = 1; 
	else forwardC = 0;
	

	/*FORWARD D LOGIC*/													//WB-->MEM
	if (MEM_control_rom_out.mem_write == 1 && 
		WB_rd_addr_out == MEM_rs2_addr_out &&
		MEM_control_rom_out.opcode != op_load &&
		MEM_control_rom_out.opcode != op_jal &&
		MEM_control_rom_out.opcode != op_jalr) 
			forwardD = 1; 
	else forwardD = 0;

	/*FORWARD E LOGIC*/													//WB-->ID
	if (WB_control_rom_out.load_regfile == 1 && 
		WB_rd_addr_out == ID_rs1_addr_out &&
		WB_rd_addr_out != 0 &&
		(ID_control_rom_out.opcode != op_jal) &&
		!(EX_control_rom_out.opcode == op_auipc && 
			EX_rs1_addr_out == 0))
		 forwardE = 1;

	else forwardE = 0;


	/*FORWARD F LOGIC*/													//WB-->ID
	if (WB_control_rom_out.load_regfile == 1 && 
		WB_rd_addr_out == ID_rs2_addr_out &&
		(ID_control_rom_out.opcode != op_load) &&
		(ID_control_rom_out.opcode != op_jal) &&
		(ID_control_rom_out.opcode != op_jalr) &&
		WB_rd_addr_out != 0)
		 forwardF = 1;

	else forwardF = 0;
end

branch_predict #(.s_pc(4), .s_bh(4)) b_p (
//inputs
	.clk,
	.IF_pc(IF_pc_out),
	.EX_pcnext(EX_pc_next_out),
	.EX_alu(EX_alu_out),
	.EX_pc(EX_pc_out),
	.IF_opcode(rv32i_opcode'(ir_in[6:0])),
	.EX_opcode(EX_control_rom_out.opcode),
	.EX_br_en(EX_br_en),
	.EX_jump_en(EX_jump_en),
	.EX_br_prediction(EX_br_predict_out),
	.EX_predictor(EX_br_predictor_out),
	.EX_tgtaddr(EX_tgtaddr_out),
	.stall,
//outputs
	.prediction(bp_prediction_out),
	.predictor(bp_predictor_out),
	.target_address_out(bp_target_address_out),
	.mispredict(bp_mispredict_out)
);

IF_stage IF_stage
(
//inputs
	.clk,
	.load_pc(load_pc), //stall control 
	.pcnext_out(IF_pcnext_in), //from EX stage ****changed this
	.mdr_out(WB_mdr_out), //from WB stage
	.alu_out(EX_alu_out), //from EX stage
	.EX_control_rom_out(EX_control_rom_out), //branch control
	.br_en(IF_br_en_in),
	.jump_en(EX_jump_en),
	.mispredict(bp_mispredict_out),
//outputs
	.pc_out(IF_pc_out),
	.pc_plus4_out(IF_pc_plus4_out),
	.pc_current(IF_pc_current)
);

//assign ID_pc_in = IF_pc_out + 32'h4;
ID_stage ID_stage
(
//inputs
	.clk,
	.load(load_pc ), //1'b1
	.reset(bp_mispredict_out & load_pc),
	.pc(IF_pc_out),
	.pc_plus4(IF_pc_plus4_out),
	.ir_in(ir_in),
	.rd_addr_in(WB_rd_addr_out), //from WB
	.wb_ld_regfile(WB_control_rom_out.load_regfile), //from WB
	.WB_regfilemux_out(WB_regfilemux_out), //from WB
	.forwardE,
	.forwardF,
	.br_predict_in(bp_prediction_out),
	.br_predictor_in(bp_predictor_out),
	.tgtaddr_in(bp_target_address_out),

//outputs
	.pc_out(ID_pc_out),
	.pc_plus4_out(ID_pc_plus4_out),
	.control_rom_out(ID_control_rom_out),
	.rd_addr_out(ID_rd_addr_out),
	.rs1_addr_out(ID_rs1_addr_out),
	.rs2_addr_out(ID_rs2_addr_out),
	.rs1_out(ID_rs1_out),
	.rs2_out(ID_rs2_out),
	.i_imm_out(ID_i_imm_out),
	.u_imm_out(ID_u_imm_out),
	.b_imm_out(ID_b_imm_out),
	.s_imm_out(ID_s_imm_out),
	.j_imm_out(ID_j_imm_out),
	.ir_out(ID_ir_out),
	.imm_value(ID_imm_value),
	.br_predict_out(ID_br_predict_out),
	.br_predictor_out(ID_br_predictor_out),
	.tgtaddr_out(ID_tgtaddr_out)
);


EX_stage EX_stage
(
//inputs
	.clk,
	.load(load_pc), //STALL_id_ex //1'b1
	.reset(bp_mispredict_out & load_pc),
	.forwardA(forwardA),
	.forwardB(forwardB),
	.pc_in(ID_pc_out),
	.pc_plus4_in(ID_pc_plus4_out),
	.rs1_in(ID_rs1_out),
	.rs2_in(ID_rs2_out),
	.rd_addr_in(ID_rd_addr_out),
	.rs1_addr_in(ID_rs1_addr_out),
	.rs2_addr_in(ID_rs2_addr_out),
	.control_rom_in(ID_control_rom_out),
	.i_imm_in(ID_i_imm_out),
	.u_imm_in(ID_u_imm_out),
	.b_imm_in(ID_b_imm_out),
	.s_imm_in(ID_s_imm_out),
	.j_imm_in(ID_j_imm_out),
	.WB_regfilemux_out(WB_regfilemux_out),
	.MEM_alu_out(MEM_alu_out),
	.imm_value(ID_imm_value),
	.ir_in(ID_ir_out),
	.mem_rdata(mem_rdata),
	.br_predict_in(ID_br_predict_out),
	.br_predictor_in(ID_br_predictor_out),
	.tgtaddr_in(ID_tgtaddr_out),
//outputs
	.pc_out(EX_pc_out),
	.pc_plus4_out(EX_pc_plus4_out), 
	.pc_next(EX_pc_next_out),
	.rs2_out(EX_rs2_out),
	.alu_out(EX_alu_out),
	.rd_addr_out(EX_rd_addr_out),
	.rs1_addr_out(EX_rs1_addr_out),
	.rs2_addr_out(EX_rs2_addr_out),
	.control_rom_out(EX_control_rom_out),
	.br_en(EX_br_en),
	.jump_en(EX_jump_en),
	.rs1_out(EX_rs1_out),
	.u_imm_out(EX_u_imm_out),
	.ir_out(EX_ir_out),
	.br_predict_out(EX_br_predict_out),
	.br_predictor_out(EX_br_predictor_out),
	.tgtaddr_out(EX_tgtaddr_out)
);


MEM_stage MEM_stage
(
//inputs
	.clk,
	.load(load_pc),	//1'b1
	.pc_in(EX_pc_out),
	.forwardC,
	.forwardD,
	.pc_plus4_in(EX_pc_plus4_out),
	.alu_in(EX_alu_out), 
	.rs1_in(EX_rs1_out),
	.rs2_in(EX_rs2_out), 
	.rd_addr_in(EX_rd_addr_out),
	.rs1_addr_in(EX_rs1_addr_out),
	.rs2_addr_in(EX_rs2_addr_out),
	.control_rom_in(EX_control_rom_out),
	.u_imm_in(EX_u_imm_out),
	.ir_in(EX_ir_out),
	.WB_regfilemux_out(WB_regfilemux_out),
//outputs
	.pc_out(MEM_pc_out), 
	.pc_plus4_out(MEM_pc_plus4_out),
	.rs1_out(MEM_rs1_out),
	.rs2_out(MEM_rs2_out),
	.alu_out(MEM_alu_out),
	.rd_addr_out(MEM_rd_addr_out),
	.rs1_addr_out(MEM_rs1_addr_out),
	.rs2_addr_out(MEM_rs2_addr_out),
	.control_rom_out(MEM_control_rom_out),
	.u_imm_out(MEM_u_imm_out),
	.ir_out(MEM_ir_out),
	.mem_byte_enable(MEM_mem_byte_enable)
);


WB_stage WB_stage
(
//inputs
	.clk,
	.load(load_pc),		//1'b1
	.mdr_in(mem_rdata),
	.pc_in(MEM_pc_out), 
	.pc_plus4_in(MEM_pc_plus4_out), 
	.ir_in(MEM_ir_out),
	.alu_in(MEM_alu_out), 
	.rs2_in(MEM_rs2_out), 
	.rd_addr_in(MEM_rd_addr_out), 
	.rs1_addr_in(MEM_rs1_addr_out),
	.rs2_addr_in(MEM_rs2_addr_out),
	.control_rom_in(MEM_control_rom_out),
	.u_imm_in(MEM_u_imm_out),
//outputs
	.regfilemux_out(WB_regfilemux_out),
	.control_rom_out(WB_control_rom_out),
	.rd_addr_out(WB_rd_addr_out),
	.rs1_addr_out(WB_rs1_addr_out),
	.rs2_addr_out(WB_rs2_addr_out),
	.mdr_out(WB_mdr_out),
	.ir_out(WB_ir_out),
	.alu_out(WB_alu_out)
);


endmodule : cpu
