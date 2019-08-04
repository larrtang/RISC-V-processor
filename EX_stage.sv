import rv32i_types::*;

module EX_stage
(
	input clk,
	input load,
	input reset,
	input logic [2:0] forwardA,
	input logic [2:0] forwardB,

	input rv32i_word pc_in, pc_plus4_in, rs1_in, rs2_in,
	input rv32i_reg rd_addr_in, rs1_addr_in, rs2_addr_in, 
	input rv32i_control_word control_rom_in,
	input rv32i_word i_imm_in, j_imm_in, b_imm_in, u_imm_in, s_imm_in, ir_in,
	input rv32i_word WB_regfilemux_out,
	input rv32i_word MEM_alu_out,
	input rv32i_word imm_value,
	input rv32i_word mem_rdata,
	input logic br_predict_in,
	input logic br_predictor_in,
	input rv32i_word tgtaddr_in,

	output rv32i_word pc_out, pc_plus4_out, pc_next, rs2_out, alu_out,
	output rv32i_reg rd_addr_out, rs1_addr_out, rs2_addr_out,
	output rv32i_control_word control_rom_out,
	output logic br_en, jump_en,
	output rv32i_word rs1_out,
	output rv32i_word u_imm_out, ir_out,
	output logic br_predict_out,
	output logic br_predictor_out,
	output rv32i_word tgtaddr_out
);

rv32i_word i_imm, j_imm, s_imm, b_imm;
rv32i_word alumux1_out, alumux2_out, addermux_out;
rv32i_word cmpmux_out;
rv32i_word imm_value_out;


//TODO: make load = 1 for now since there is no stall logic

logic [2:0] alumux1_sel;
logic [2:0] alumux2_sel;
logic [1:0] rs1mux_sel, rs2mux_sel;
rv32i_word rs1mux_out, rs2mux_out;
logic rs2outmux_sel;
rv32i_word rs2_data;

always_comb
begin
rs1mux_sel = 0;
if(forwardA == 1)
	begin
	alumux1_sel = 2;
	if(control_rom_out.opcode == op_br) rs1mux_sel = 2;
	else rs1mux_sel = 0;
	end
else if (forwardA == 2)
	begin
		alumux1_sel = 3;
		if(control_rom_out.opcode == op_br) rs1mux_sel = 1;
		else rs1mux_sel = 0;
	end
else if (forwardA == 3)
	begin
		alumux1_sel = 4;
		if(control_rom_out.opcode == op_br) rs1mux_sel = 3;
		else rs1mux_sel = 0;
	end
else
	begin
	alumux1_sel = control_rom_out.alumux1_sel;
	end
end

always_comb
begin
rs2mux_sel = 0;
rs2outmux_sel = 0;
if(control_rom_out.opcode == op_imm) alumux2_sel = control_rom_out.alumux2_sel;
else if(forwardB == 1)
	begin
	alumux2_sel = 4;
	if(control_rom_out.opcode == op_br) rs2mux_sel = 2;
	else rs2mux_sel = 0;
	end
else if (forwardB == 2)
	begin
	alumux2_sel = 5;
	if(control_rom_out.opcode == op_br) rs2mux_sel = 1;
	else rs2mux_sel = 0;
	end
else if (forwardB == 3)
	begin
		if(control_rom_out.opcode == op_br) rs2mux_sel = 3;
		else rs2mux_sel = 0;

		alumux2_sel = 6;
	end
else if(forwardB == 4) begin
	alumux2_sel = control_rom_out.alumux2_sel;
	rs2outmux_sel = 1;
end
else
	begin
	alumux2_sel = control_rom_out.alumux2_sel;
	end
end

//to flush for jal/jalr
always_comb
begin
	if (control_rom_out.opcode == op_jal || 
		control_rom_out.opcode == op_jalr)
		begin
			jump_en = 1;
		end
	else
		begin
			jump_en = 0;
		end
end


//ID/EX Latch______________________________________________________________________________________
register #(.width(32)) pc

(
	.clk,
	.load,
	.reset(),
	.in(pc_in),
	.out(pc_out)
);

register #(.width(32)) PC_PLUS4
(
//inputs
	.clk,
	.load,
	.in(pc_plus4_in),
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

register #(.width($bits(rv32i_control_word))) control_rom
(
	.clk,
	.load,
	.reset,
	.in(control_rom_in),
	.out(control_rom_out)
);


register #(.width(32)) rs1
(
	.clk,
	.load,
	.reset,
	.in(rs1_in),
	.out(rs1_out)
);

register #(.width(32)) rs2
(
	.clk,
	.load,
	.reset,
	.in(rs2_in),
	.out(rs2_data)
);

register #(.width(5)) rd 	
(
	.clk,
	.load,
	.reset,
	.in(rd_addr_in),
	.out(rd_addr_out)
);

register #(.width(5)) rs1_reg 	
(
	.clk,
	.load,
	.reset,
	.in(rs1_addr_in),
	.out(rs1_addr_out)
);

register #(.width(5)) rs2_reg 	
(
	.clk,
	.load,
	.reset,
	.in(rs2_addr_in),
	.out(rs2_addr_out)
);



register #(.width(32)) I_IMM
(
	.clk,
	.load,
	.reset,
	.in(i_imm_in),
	.out(i_imm)
);
register #(.width(32)) U_IMM
(
	.clk,
	.load,
	.reset,
	.in(u_imm_in),
	.out(u_imm_out)			//we need this one in WB stage
);
register #(.width(32)) J_IMM
(
	.clk,
	.load,
	.reset,
	.in(j_imm_in),
	.out(j_imm)
);
register #(.width(32)) B_IMM
(
	.clk,
	.load,
	.reset,
	.in(b_imm_in),
	.out(b_imm)
);
register #(.width(32)) S_IMM
(
	.clk,
	.load,
	.reset,
	.in(s_imm_in),
	.out(s_imm)
);

register #(.width(32)) IMM_VALUE
(
	.clk,
	.load,
	.reset,
	.in(imm_value),
	.out(imm_value_out)
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

//END ID/EX Latch__________________________________________________________________________________



mux8 #(.width(32)) alumux1
(
//inputs
	.sel(alumux1_sel),
	.a(rs1_out),
	.b(pc_out),
	.c(WB_regfilemux_out), //fromWB
	.d(MEM_alu_out), //from EX&MEM
	.e(mem_rdata),
	.f(),
	.h(),
	.i(),
//output
	.g(alumux1_out)
);

mux8 #(.width(32)) alumux2
(
//inputs
	.sel(alumux2_sel),
	.a(imm_value_out),
	.b(rs2_out), //6
	.c(rs2_out & 32'h0000001F), //7
	.d(i_imm & 32'h0000001F), //8
	.e(WB_regfilemux_out),
	.f(MEM_alu_out),
	.h(mem_rdata),
	.i(),
//output
	.g(alumux2_out)
);


alu ALU
(
//inputs
	.aluop(control_rom_out.aluop),
	.a(alumux1_out),
	.b(alumux2_out),
//output
	.f(alu_out)
);

mux4 #(.width(32)) rs1mux
(
	.sel(rs1mux_sel),
	.a(rs1_out),
	.b(MEM_alu_out),
	.c(WB_regfilemux_out),
	.d(mem_rdata),
	.f(rs1mux_out)
);
mux4 #(.width(32)) rs2mux
(
	.sel(rs2mux_sel),
	.a(rs2_out),
	.b(MEM_alu_out),
	.c(WB_regfilemux_out),
	.d(mem_rdata),
	.f(rs2mux_out)
);

mux2 #(.width(32)) rs2outmux (
	.sel(rs2outmux_sel),
	.a(rs2_data),
	.b(WB_regfilemux_out),
	.f(rs2_out)
);


mux2 #(.width(32)) cmpmux
(
//inputs
	.sel(control_rom_out.cmpmux_sel),
	.a(rs2mux_out),
	.b(i_imm),
//output
	.f(cmpmux_out)
);

cmp CMP
(
//inputs
	.cmpop(control_rom_out.cmpop),
	.a(rs1mux_out),
	.b(cmpmux_out),
	.read(control_rom_out.read_cmp),
//output
	.out(br_en)
);

mux4 addermux
(
//inputs
	.sel(control_rom_out.addermux_sel),
	.a(32'b100),
	.b(j_imm),
	.c(b_imm),
	.d(u_imm_out),
//output
	.f(addermux_out)
);

//branch logic
assign pc_next = pc_out+addermux_out;
//replaced with above line
/*alu adder
(
//inputs
	.aluop(alu_add),
	.a(pc_out),
	.b(addermux_out),
//output
	.f(pc_next)
);*/

endmodule : EX_stage
