import rv32i_types::*;

module MEM_stage
(
	input clk,
	input load,
	input rv32i_word pc_in, pc_plus4_in, alu_in, rs1_in, rs2_in,
	input rv32i_reg rd_addr_in, rs1_addr_in, rs2_addr_in,
	input rv32i_control_word control_rom_in,
	input rv32i_word u_imm_in, ir_in, 
	input logic forwardC, forwardD,
	input rv32i_word WB_regfilemux_out,

	output rv32i_word pc_out, pc_plus4_out, rs1_out, rs2_out, alu_out,
	output rv32i_reg rd_addr_out, rs1_addr_out, rs2_addr_out,
	output rv32i_control_word control_rom_out,
	output rv32i_word u_imm_out, ir_out,
	output logic [3:0] mem_byte_enable //for store 
);


rv32i_word rs1_data, rs2_data;

//EX/MEM Latch_____________________________________________________________________________________
register #(.width(32)) pc
(
	.clk,
	.load,
	.reset(),
	.in(pc_in),
	.out(pc_out)
);
register #(.width(32)) ir_reg
(
	.clk,
	.load,
	.reset(),
	.in(ir_in),
	.out(ir_out)
);

register #(.width(32)) PC_PLUS4
(
	.clk,
	.load,
	.reset(),
	.in(pc_plus4_in),
	.out(pc_plus4_out)
);

register #(.width($bits(rv32i_control_word))) control_rom
(
	.clk,
	.load,
	.reset(),
	.in(control_rom_in),
	.out(control_rom_out)
);


register #(.width(32)) alu
(
	.clk,
	.load,
	.reset(),
	.in(alu_in),
	.out(alu_out)
);

register #(.width(32)) rs1
(
	.clk,
	.load,
	.reset(),
	.in(rs1_in),
	.out(rs1_data)
);
register #(.width(32)) rs2
(
	.clk,
	.load,
	.reset(),
	.in(rs2_in),
	.out(rs2_data)
);

register #(.width(5)) rd
(
	.clk,
	.load,
	.reset(),
	.in(rd_addr_in),
	.out(rd_addr_out)
);

register #(.width(5)) rs1_reg
(
	.clk,
	.load,
	.reset(),
	.in(rs1_addr_in),
	.out(rs1_addr_out)
);

register #(.width(5)) rs2_reg
(
	.clk,
	.load,
	.reset(),
	.in(rs2_addr_in),
	.out(rs2_addr_out)
);

register #(.width(32)) U_IMM
(
	.clk,
	.load,
	.reset(),
	.in(u_imm_in),
	.out(u_imm_out)
);

//END EX/MEM Latch_________________________________________________________________________________


mux2 rs1writeData
(
	.sel(forwardC),
	.a(rs1_data),
	.b(WB_regfilemux_out),

	.f(rs1_out)
);

mux2 rs2writeData
(
	.sel(forwardD),
	.a(rs2_data),
	.b(WB_regfilemux_out),

	.f(rs2_out)
);

//write data = rs2_out
//address is alu_out
always_comb
begin
	if (control_rom_out.store_half)
	begin
		mem_byte_enable = control_rom_out.mem_byte_enable << alu_out[1:0];
	end
	//could combine
	else if (control_rom_out.store_byte)
	begin
		mem_byte_enable = control_rom_out.mem_byte_enable << alu_out[1:0];
	end
	else //store word
	begin
		mem_byte_enable = control_rom_out.mem_byte_enable;
	end
end




endmodule : MEM_stage
