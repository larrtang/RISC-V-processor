import rv32i_types::*;

module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
logic mem_resp_data, mem_resp_instr, mem_read_instr, mem_read_data;
//logic mem_read;
logic mem_write;
logic [3:0] mem_byte_enable;
logic [15:0] errcode;
logic [31:0] mem_address;
logic [31:0] mem_rdata;
logic [31:0] mem_wdata;
logic [31:0] write_data;
logic [31:0] write_address;
logic write;
logic [31:0] registers [32];
logic halt;
logic [63:0] order;
logic [31:0] pc_out;
logic [31:0] ir_in;

logic dcache_pmem_resp, icache_pmem_resp, pmem_resp;
logic [255:0] pmem_rdata, pmem_wdata;
logic pmem_write, pmem_read;
rv32i_word pmem_address, dcache_pmem_address, icache_pmem_address;
logic pmem_error;

initial
begin
    clk = 0;
    order = 0;
end

/* Clock generator */
always #5 clk = ~clk;

//assign registers = dut.datapath.regfile.data;
//assign halt = dut.load_pc & (dut.datapath.pc_out == dut.datapath.pcmux_out);
assign halt = ~dut.cpu.MEM_control_rom_out.load_regfile & dut.cpu.load_pc & ((dut.cpu.IF_pc_out) == dut.cpu.IF_stage.pcmux_out) & (dut.mem_read_data == 0);

always @(posedge clk)
begin
    if (mem_write & mem_resp_data) begin
        write_address = mem_address;
        write_data = mem_wdata;
        write = 1;
    end else begin
        write_address = 32'hx;
        write_data = 32'hx;
        write = 0;
    end

    if (halt) begin
        if(pmem_error)
            $display("Halting with error");
        else
            $display("Halting without error");

        $finish;
    end
end

mp3 dut
(
    .*
);

physical_memory pmem 
(
    .clk,
    .read(pmem_read),
    .write(pmem_write),
    .address(pmem_address),
    .wdata(pmem_wdata),

    .resp(pmem_resp),
    .error(pmem_error),
    .rdata(pmem_rdata)
);

// magic_memory_dp magic_mem
// (
//     .clk,

//     /* Port A */
//     .read_a(mem_read_instr),
//     .address_a(pc_out),
//     .resp_a(mem_resp_instr),
//     .rdata_a(ir_in),

//     /* Port B */
//     .read_b(mem_read_data),
//     .write(mem_write),
//     .wmask(mem_byte_enable),
//     .address_b(mem_address),
//     .wdata(mem_wdata),
//     .resp_b(mem_resp_data),
//     .rdata_b(mem_rdata)
// );

// memory memory
// (
//     .clk,
//     .read(mem_read),
//     .write(mem_write),
//     .wmask(mem_byte_enable),
//     .address(mem_address),
//     .wdata(mem_wdata),
//     .resp(mem_resp),
//     .rdata(mem_rdata)
// );

// riscv_formal_monitor_rv32i monitor
// (
//   .clock(clk),
//   .reset(1'b0),
//   .rvfi_valid(dut.load_pc),
//   .rvfi_order(order),
//   .rvfi_insn(dut.datapath.IR.data),
//   .rvfi_trap(dut.control.trap),
//   .rvfi_halt(halt),
//   .rvfi_intr(1'b0),
//   .rvfi_rs1_addr(dut.control.rs1_addr),
//   .rvfi_rs2_addr(dut.control.rs2_addr),
//   .rvfi_rs1_rdata(monitor.rvfi_rs1_addr ? dut.datapath.rs1_out : 0),
//   .rvfi_rs2_rdata(monitor.rvfi_rs2_addr ? dut.datapath.rs2_out : 0),
//   .rvfi_rd_addr(dut.load_regfile ? dut.datapath.rd : 5'h0),
//   .rvfi_rd_wdata(monitor.rvfi_rd_addr ? dut.datapath.regfilemux_out : 0),
//   .rvfi_pc_rdata(dut.datapath.pc_out),
//   .rvfi_pc_wdata(dut.datapath.pcmux_out),
//   .rvfi_mem_addr(mem_address),
//   .rvfi_mem_rmask(dut.control.rmask),
//   .rvfi_mem_wmask(dut.control.wmask),
//   .rvfi_mem_rdata(dut.datapath.mdrreg_out),
//   .rvfi_mem_wdata(dut.datapath.mem_wdata),
//   .errcode(errcode)
// );



endmodule : mp3_tb