import rv32i_types::*;

module control_rom
(
	input rv32i_opcode opcode,
	input logic [2:0] funct3,
	input logic [6:0] funct7,
	output rv32i_control_word ctrl

);

branch_funct3_t branch_funct3;
store_funct3_t store_funct3;
load_funct3_t load_funct3;
arith_funct3_t arith_funct3;

assign branch_funct3 = branch_funct3_t'(funct3);
assign store_funct3 = store_funct3_t'(funct3);
assign load_funct3 = load_funct3_t'(funct3);
assign arith_funct3 = arith_funct3_t'(funct3);

always_comb
begin: opcode_logic
	ctrl.opcode = opcode;
	ctrl.aluop = alu_ops'(funct3);
	ctrl.regfilemux_sel = 3'b000;
	ctrl.load_regfile = 1'b0;
	ctrl.cmpop = branch_funct3;
	//ctrl.cmpop = branch_funct3_t'(3'b010);
	ctrl.alumux1_sel = 3'b000;
	ctrl.alumux2_sel = 3'b000;
	ctrl.addermux_sel = 2'b00;
	ctrl.cmpmux_sel = 1'b0;
	ctrl.read_cmp = 1'b0;
	
	ctrl.mem_read_data = 1'b0;
	ctrl.mem_write = 1'b0;
	ctrl.mem_byte_enable = 4'b1111;
	ctrl.mdrmux_sel = 2'b00;
	ctrl.is_signed = 1'b0;
	ctrl.store_half = 1'b0;
	ctrl.store_byte = 1'b0;
	ctrl.pcmux_sel = 2'b00;
	ctrl.immmux_sel = 3'b000;

	case(opcode)
		op_lui: begin
			ctrl.load_regfile = 1;
			ctrl.regfilemux_sel = 0; //u_imm
			ctrl.immmux_sel = 1; //u_imm
		end

		op_auipc: begin
			ctrl.load_regfile = 1;
			ctrl.alumux1_sel = 1; //pc
			ctrl.alumux2_sel = 0; //u_imm
			ctrl.immmux_sel = 1; //u_imm 
			ctrl.aluop = alu_add;
		end

		op_jal: begin
			ctrl.load_regfile = 1;
			ctrl.regfilemux_sel = 3; //pc+4
			ctrl.alumux1_sel = 1;
			ctrl.alumux2_sel = 0; //j_imm
			ctrl.immmux_sel = 4; //j_imm
			ctrl.aluop = alu_add;

			ctrl.pcmux_sel = 1;
			//ctrl.load_pc = 1;
			//ctrl.addermux_sel = 1;

		end

		op_jalr: begin
			ctrl.load_regfile = 1;
			ctrl.regfilemux_sel = 3;
			ctrl.alumux1_sel = 0;
			ctrl.alumux2_sel = 0; //i-type
			ctrl.immmux_sel = 0;
			ctrl.aluop = alu_add;

			ctrl.pcmux_sel = 3; //masked value
			//ctrl.load_pc = 1;
			//ctrl.addermux_sel = 1;

		end

		op_br: begin
			//ctrl.alumux1_sel = 1; //pc
			//ctrl.alumux2_sel = 2; //b_imm
			//ctrl.aluop = alu_add;
			ctrl.addermux_sel = 2;
			ctrl.read_cmp = 1;
		end

		op_load: begin
			ctrl.aluop = alu_add;
			ctrl.load_regfile = 1;
			
			ctrl.mem_read_data = 1;
			case(load_funct3)
				lw: begin
					ctrl.regfilemux_sel = 1; //mdr
				end

				lb: begin
					ctrl.regfilemux_sel = 1; //mdr 
					ctrl.mdrmux_sel = 2;				
					ctrl.is_signed = 1;
				end

				lbu: begin
					ctrl.regfilemux_sel = 1;
					ctrl.mdrmux_sel = 2;
				end

				lh: begin
					ctrl.regfilemux_sel = 1;
					ctrl.is_signed = 1;
					ctrl.mdrmux_sel = 1;
				end

				lhu: begin
					ctrl.regfilemux_sel = 1;
					ctrl.mdrmux_sel = 1;

				end
			endcase
		end

		op_store: begin
			ctrl.aluop = alu_add;
			ctrl.alumux2_sel = 0; //s_imm
			ctrl.immmux_sel = 3;
			
			ctrl.mem_write = 1;
			case(store_funct3)
				sw: begin

				end

				sh: begin
					ctrl.mem_byte_enable = 4'b0011;
					ctrl.store_half = 1;
				end

				sb: begin
					ctrl.mem_byte_enable = 4'b0001;
					ctrl.store_byte = 1;
				end
			endcase
		end

		op_imm: begin
			ctrl.load_regfile = 1;
			ctrl.alumux1_sel = 0; //rs1
			
			case(arith_funct3)
				add: begin
					ctrl.alumux2_sel = 0; //i_imm
					ctrl.immmux_sel = 0;
					ctrl.aluop = alu_add;
				end

				sll: begin
					ctrl.alumux2_sel = 3; //lowest 5 bits of i_imm
					ctrl.aluop = alu_sll;
				end

				slt: begin
					ctrl.cmpop = blt;
					ctrl.cmpmux_sel = 1; //i_imm
				end

				sltu: begin
					ctrl.cmpop = bltu;
					ctrl.cmpmux_sel = 1; //i_imm
				end

				axor: begin
					ctrl.alumux2_sel = 0; //i_imm
					ctrl.immmux_sel = 0;
					ctrl.aluop = alu_xor;
				end

				sr: begin
					ctrl.alumux2_sel = 3; //lowest 5 bits of i_imm

					case(funct7)
						7'b0100000: begin //sra
							ctrl.aluop = alu_sra;
						end

						7'b0000000: begin //srl
							ctrl.aluop = alu_srl;
						end

						default: ;

					endcase
				end

				aor: begin
					ctrl.alumux2_sel = 0; //i_imm
					ctrl.immmux_sel = 0;
					ctrl.aluop = alu_or;
				end

				aand: begin
					ctrl.alumux2_sel = 0; //i_imm
					ctrl.immmux_sel = 0;
					ctrl.aluop = alu_and;
				end
			endcase
		end

		op_reg: begin
			ctrl.load_regfile = 1;
			ctrl.alumux1_sel = 0; //rs1

			case(arith_funct3)
				add: begin
					ctrl.alumux2_sel = 1; //rs2

					case(funct7)
						7'b0100000: begin	//sub
							ctrl.aluop = alu_sub;
						end

						7'b0000000: begin //add
							ctrl.aluop = alu_add;
						end

						default: ;
					endcase
				end

				sll: begin
					ctrl.alumux2_sel = 2; //lowest 5 bits of rs2
					ctrl.aluop = alu_sll;
				end

				slt: begin
					ctrl.cmpop = blt;
					ctrl.cmpmux_sel = 0; //rs2
				end

				sltu: begin
					ctrl.cmpop = bltu;
					ctrl.cmpmux_sel = 0; //rs2
				end

				axor: begin
					ctrl.alumux2_sel = 1; //rs2
					ctrl.aluop = alu_xor;
				end

				sr: begin
					ctrl.alumux2_sel = 2; //lowest 5 bits of rs2

					case(funct7)
						7'b0100000: begin //sra
							ctrl.aluop = alu_sra;
						end

						7'b0000000: begin //srl
							ctrl.aluop = alu_srl;
						end

						default: ;

					endcase
				end

				aor: begin
					ctrl.alumux2_sel = 1; //rs2
					ctrl.aluop = alu_or;
				end

				aand: begin
					ctrl.alumux2_sel = 1; //rs2
					ctrl.aluop = alu_and;
				end
			endcase

		end

		default: ;

	endcase
end

endmodule : control_rom
