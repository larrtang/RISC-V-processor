import rv32i_types::*;

module decoder
(
	input logic [3:0] mem_byte_enable,
	input rv32i_word mem_wdata,
	input logic [2:0] offset4_2,
	input logic [255:0] in,
	output logic [255:0] out
);

always_comb
begin 
	out = in;
	case(offset4_2)
		3'b000: begin
			if (mem_byte_enable[0]) out[7:0] = mem_wdata[7:0];
			if (mem_byte_enable[1]) out[15:8] = mem_wdata[15:8];
			if (mem_byte_enable[2]) out[23:16] = mem_wdata[23:16];
			if (mem_byte_enable[3]) out[31:24] = mem_wdata[31:24];
		end
		3'b001: begin
			if (mem_byte_enable[0]) out[39:32] = mem_wdata[7:0];
			if (mem_byte_enable[1]) out[47:40] = mem_wdata[15:8];
			if (mem_byte_enable[2]) out[55:48] = mem_wdata[23:16];
			if (mem_byte_enable[3]) out[63:56] = mem_wdata[31:24];
		end
		3'b010: begin	
			if (mem_byte_enable[0]) out[71:64] = mem_wdata[7:0];
			if (mem_byte_enable[1]) out[79:72] = mem_wdata[15:8];
			if (mem_byte_enable[2]) out[87:80] = mem_wdata[23:16];
			if (mem_byte_enable[3]) out[95:88] = mem_wdata[31:24];
		end
		3'b011: begin
			if (mem_byte_enable[0]) out[103:96] = mem_wdata[7:0];
			if (mem_byte_enable[1]) out[111:104] = mem_wdata[15:8];
			if (mem_byte_enable[2]) out[119:112] = mem_wdata[23:16];
			if (mem_byte_enable[3]) out[127:120] = mem_wdata[31:24];
		end
		3'b100: begin
			if (mem_byte_enable[0]) out[135:128] = mem_wdata[7:0];
			if (mem_byte_enable[1]) out[143:136] = mem_wdata[15:8];
			if (mem_byte_enable[2]) out[151:144] = mem_wdata[23:16];
			if (mem_byte_enable[3]) out[159:152] = mem_wdata[31:24];
		end
		3'b101: begin
			if (mem_byte_enable[0]) out[167:160] = mem_wdata[7:0];
			if (mem_byte_enable[1]) out[175:168] = mem_wdata[15:8];
			if (mem_byte_enable[2]) out[183:176] = mem_wdata[23:16];
			if (mem_byte_enable[3]) out[191:184] = mem_wdata[31:24];
		end
		3'b110: begin
			if (mem_byte_enable[0]) out[199:192] = mem_wdata[7:0];
			if (mem_byte_enable[1]) out[207:200] = mem_wdata[15:8];
			if (mem_byte_enable[2]) out[215:208] = mem_wdata[23:16];
			if (mem_byte_enable[3]) out[223:216] = mem_wdata[31:24];
		end
		3'b111: begin
			if (mem_byte_enable[0]) out[231:224] = mem_wdata[7:0];
			if (mem_byte_enable[1]) out[239:232] = mem_wdata[15:8];
			if (mem_byte_enable[2]) out[247:240] = mem_wdata[23:16];
			if (mem_byte_enable[3]) out[255:248] = mem_wdata[31:24];
		end
	endcase
end


endmodule : decoder
