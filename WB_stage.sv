import rv32i_types::*;

module WB_stage
(
	input clk,
	input load,
//inputs come from previous stage (MEM) unless otherwise noted
	input rv32i_word mdr_in,	//comes from dual port magic memory
	input rv32i_word pc_in, pc_plus4_in, alu_in, rs2_in,
	input rv32i_reg rd_addr_in, rs1_addr_in, rs2_addr_in,
	
	input rv32i_control_word control_rom_in,
	input rv32i_word u_imm_in, ir_in,

	output rv32i_word regfilemux_out,
	output rv32i_control_word control_rom_out,
	output rv32i_reg rd_addr_out, rs1_addr_out, rs2_addr_out,
	output rv32i_word mdr_out, ir_out, alu_out
);

rv32i_word pc_out, pc_plus4_out, rs2_out, u_imm_out, mdrmux_out;
rv32i_word byte_extension_out, half_extension_out;

//MEM/WB Latch_____________________________________________________________________________________
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
	.clk,
	.load,
	.reset(),
	.in(pc_plus4_in),
	.out(pc_plus4_out)
);
register #(.width(32)) ir_reg
(
	.clk,
	.load,
	.reset(),
	.in(ir_in),
	.out(ir_out)
);
register #(.width($bits(rv32i_control_word))) control_rom
(
	.clk,
	.load,
	.reset(),
	.in(control_rom_in),
	.out(control_rom_out)
);

register #(.width(32)) mdr
(
	.clk,
	.load,
	.reset(),
	.in(mdr_in),
	.out(mdr_out)
);

register #(.width(32)) alu
(
	.clk,
	.load,
	.reset(),
	.in(alu_in),
	.out(alu_out)
);

register #(.width(32)) rs2
(
	.clk,
	.load,
	.reset(),
	.in(rs2_in),
	.out(rs2_out)
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
//END MEM/WB Latch_________________________________________________________________________________

mux4 #(.width(32)) mdrmux
(
	.sel(control_rom_out.mdrmux_sel),
	.a(mdr_out),
	.b(half_extension_out),
	.c(byte_extension_out),
	.d(),
	.f(mdrmux_out)

);

mux8 #(.width(32)) regfilemux
(
	.sel(control_rom_out.regfilemux_sel),
	.a(alu_out),
	.b(mdrmux_out),
	.c(pc_out),
	.d(pc_plus4_out),
	.e(u_imm_out),
	.f(),
	.h(),
	.i(),
	.g(regfilemux_out)
);

/*load logic*/
//for byte extension
always_comb
begin
	//alu_out contains mem_address
	//mdr_out contains mem data
	if (alu_out[1:0] == 2'b00) //2LSB of mem address = 00
	begin
		if (mdr_out[7] == 1 && control_rom_out.is_signed) //signed load byte with 1 msb
			begin
			byte_extension_out = {24'hFFFFFF, mdr_out[7:0]}; //signed extension
			end
		else
			begin
			byte_extension_out = {24'h000000, mdr_out[7:0]}; //unsigned
			end
	end
	else if (alu_out[1:0] == 2'b01) //2LSB = 01
	begin
		if (mdr_out[15] == 1 && control_rom_out.is_signed) //signed load byte with 1 msb
			begin
			byte_extension_out = {24'hFFFFFF, mdr_out[15:8]}; //signed extension
			end
		else
			begin
			byte_extension_out = {24'h000000, mdr_out[15:8]}; 
			end
	end
	else if (alu_out[1:0] == 2'b10) //2LSB = 10
		begin
		if (mdr_out[23] == 1 && control_rom_out.is_signed)
			begin
			byte_extension_out = {24'hFFFFFF, mdr_out[23:16]}; //signed extension
			end
		else
			begin
			byte_extension_out = {24'h000000, mdr_out[23:16]}; 
			end
		end
	else if (alu_out[1:0] == 2'b11) //2LSB = 10
		begin
		if (mdr_out[31] == 1 && control_rom_out.is_signed)
			begin
			byte_extension_out = {24'hFFFFFF, mdr_out[31:24]}; //signed extension
			end
		else
			begin
			byte_extension_out = {24'h000000, mdr_out[31:24]}; //zero extend to right
			end
		end
	else
	begin
		byte_extension_out = {24'h000000, mdr_out[7:0]}; //default unsigned && 2lsb = 00
	end
end

//mem_address

//for half extension
always_comb
begin
	if (alu_out[1] == 1'b0) //2LSB = 00 or 01
	begin
		if (mdr_out[15] == 1 && control_rom_out.is_signed) //signed load byte with 1 msb
			begin
			half_extension_out = {16'hFFFF, mdr_out[15:0]}; //signed extension
			end
		else
			begin
			half_extension_out = {16'h0000, mdr_out[15:0]}; //unsigned extension
			end
	end
	else if (alu_out[1] == 1'b1) //2LSB = 10 or 11
	begin
		if (mdr_out[31] == 1 && control_rom_out.is_signed) //signed load half with 1 msb
			begin
			half_extension_out = {16'hFFFF, mdr_out[31:16]}; //signed extension
			end
		else
			begin
			half_extension_out = {16'h0000, mdr_out[31:16]}; //unsigned extension
			end
	end
		
	else
	begin
		//default
		half_extension_out = $unsigned(mdr_out[15:0]); //unsigned extension & 2nd LSB = 0
	end
end



endmodule : WB_stage
