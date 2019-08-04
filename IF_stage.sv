import rv32i_types::*;

module IF_stage
(
	input clk,
	input logic load_pc, 			
	input rv32i_control_word EX_control_rom_out, 	
	//for alu_out for jal/jalr
	input rv32i_word alu_out, //from EX stage
	input rv32i_word pcnext_out, //from EX stage
	input rv32i_word mdr_out, //from WB stage
	input logic br_en,
	input logic jump_en,
	input logic mispredict,

	output rv32i_word pc_out,
	output rv32i_word pc_plus4_out,
	output rv32i_word pc_current
);

rv32i_word pcmux_out;

logic [1:0] pcmux_sel;
rv32i_opcode opcode;

assign pc_current = pcmux_out;
//get default next PC value
assign pc_plus4_out = pc_out+32'd4; 

rv32i_word pc_maskZero_out;
assign pc_maskZero_out = alu_out & 32'hFFFFFFFE; 

always_comb
if (mispredict & jump_en)
	pcmux_sel = 1;
else if (br_en | mispredict)
	pcmux_sel = 2;
else
	pcmux_sel = EX_control_rom_out.pcmux_sel;

/**PC**/

mux4 pc_mux
(
//inputs
	.sel(pcmux_sel),
	.a(pc_plus4_out),
	.b(alu_out), //from EX stage for jal/jalr
	.c(pcnext_out), //from EX stage (pc+offset) for branching
	.d(pc_maskZero_out), //originally WB_mdr_out but idk why
//output
	.f(pcmux_out)

);


pc_register #(.width(32)) pc
(
//inputs
	.clk(clk),
	.load(load_pc),
	.in(pcmux_out),
//output
	.out(pc_out)
);	


endmodule : IF_stage