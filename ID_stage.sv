import rv32i_types::*;

module ID_stage 
(
	input clk,
	input load,
	input reset,
	input rv32i_word pc, pc_plus4,
	input rv32i_word ir_in, 		//comes from dual port magic memory
	input rv32i_reg rd_addr_in, 	//comes from WB stage
	input logic wb_ld_regfile, 		//comes from WB stage
	input rv32i_word WB_regfilemux_out, //comes from WB stage
	input logic forwardE, forwardF,
	input logic br_predict_in,
	input logic br_predictor_in,
	input rv32i_word tgtaddr_in,

	output rv32i_word pc_out, pc_plus4_out,
	output rv32i_control_word control_rom_out,
	output rv32i_reg rd_addr_out,
	output rv32i_reg rs1_addr_out,
	output rv32i_reg rs2_addr_out,
	output rv32i_word rs1_out,
	output rv32i_word rs2_out,
	output rv32i_word i_imm_out,
	output rv32i_word u_imm_out,
	output rv32i_word b_imm_out,
	output rv32i_word s_imm_out,
	output rv32i_word j_imm_out,
	output rv32i_word ir_out,
	output rv32i_word imm_value, //for alumux2
	output logic br_predict_out,
	output logic br_predictor_out,
	output rv32i_word tgtaddr_out
);

logic [2:0] funct3;
logic [6:0] funct7;
rv32i_opcode opcode;

rv32i_reg rs1;
rv32i_reg rs2;

rv32i_word rs1_rf_out, rs2_rf_out;

rv32i_word pc_original;

assign rs1_addr_out = rs1;
assign rs2_addr_out = rs2;

//IF/ID Latch______________________________________________________________________________________
register #(.width(32)) PC
(
//inputs
	.clk,
	.load,
	.in(pc),
	.reset(),
//output
	.out(pc_out)
);

register #(.width(32)) PC_PLUS4
(
//inputs
	.clk,
	.load,
	.in(pc_plus4),
	.reset(),
//output
	.out(pc_plus4_out)
);

register #(.width(32)) ir_reg
(
	.clk,
	.load,
	.reset,
	.in(ir_in),
	.out(ir_out)
);

ir IR
(
//inputs
    .clk,
    .load,
    .reset,
    .in(ir_in),
//outputs
    .funct3,
    .funct7,
    .opcode,
    .i_imm(i_imm_out),
    .s_imm(s_imm_out),
    .b_imm(b_imm_out),
    .u_imm(u_imm_out),
    .j_imm(j_imm_out),
    .rs1,
    .rs2,
    .rd(rd_addr_out)		//send to next stage and not to the regfile
);

register #(.width(1)) br_predict_latch (
	.clk,
	.load,
	.reset(),
	.in(br_predict_in),
	.out(br_predict_out)
);

register #(.width(1)) br_predictor_latch (
	.clk,
	.load,
	.reset(),
	.in(br_predictor_in),
	.out(br_predictor_out)
);

register #(.width(32)) tgtaddr_latch (
	.clk,
	.load,
	.reset(),
	.in(tgtaddr_in),
	.out(tgtaddr_out)
);

//END IF/ID Latch__________________________________________________________________________________




control_rom control_rom
(
//inputs
	.opcode,
	.funct3,
	.funct7,
//outputs
	.ctrl(control_rom_out)
);

regfile reg_file
(
//inputs
	.clk,
	.load(wb_ld_regfile),	//comes from WB stage
	.in(WB_regfilemux_out), 	//comes from WB stage
	.src_a(rs1),
	.src_b(rs2),
	.dest(rd_addr_in),		//comes from WB stage (we don't want to put the one from IR directly in here)
//outputs
	.reg_a(rs1_rf_out),
	.reg_b(rs2_rf_out)
);

mux8 immmux
(
	.sel(control_rom_out.immmux_sel),
	.a(i_imm_out),
	.b(u_imm_out),
	.c(b_imm_out),
	.d(s_imm_out),
	.e(j_imm_out),
	.f(),
	.h(),
	.i(),
	.g(imm_value)
);

mux2 rs1_mux (
	.sel(forwardE),
	.a(rs1_rf_out),
	.b(WB_regfilemux_out),

	.f(rs1_out)
);

mux2 rs2_mux (
	.sel(forwardF),
	.a(rs2_rf_out),
	.b(WB_regfilemux_out),

	.f(rs2_out)
);

endmodule : ID_stage


