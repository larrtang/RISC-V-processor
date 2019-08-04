/*
 * Dual-port magic memory
 *
 */

module magic_memory_dp
(
    input clk,

    /* Port A */
    input read_a,
    input [31:0] address_a,
    output logic resp_a,
    output logic [31:0] rdata_a,

    /* Port B */
    input read_b,
    input write,
    input [3:0] wmask,
    input [31:0] address_b,
    input [31:0] wdata,
    output logic resp_b,
    output logic [31:0] rdata_b
);

timeunit 1ns;
timeprecision 1ns;

logic [7:0] mem [2**(27)];
logic [26:0] internal_address_a;
logic [26:0] internal_address_b;

initial
begin
    $readmemh("memory.lst", mem);
end

assign internal_address_a = address_a[26:0];
assign internal_address_b = address_b[26:0];

always @(posedge clk)
begin : response
    if (read_a) begin
        resp_a <= 1'b1;
        for (int i = 0; i < 4; i++) begin
            rdata_a[i*8 +: 8] <= mem[internal_address_a+i];
        end
    end else begin
        resp_a <= 1'b0;
    end

    if (read_b) begin
        resp_b <= 1'b1;
        for (int i = 0; i < 4; i++) begin
            rdata_b[i*8 +: 8] <= mem[internal_address_b+i];
        end
    end else if (write) begin
        resp_b <= 1'b1;
        for (int i = 0; i < 4; i++) begin
            if (wmask[i])
            begin
                mem[internal_address_b+i] <= wdata[i*8 +: 8];
            end
        end
    end else begin
        resp_b <= 1'b0;
    end
end : response

endmodule : magic_memory_dp

