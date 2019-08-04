
module regfile
(
    input clk,
    input load,
    input [31:0] in,
    input [4:0] src_a, src_b, dest,
    output logic [31:0] reg_a, reg_b
);

logic [31:0] data [32] /* synthesis ramstyle = "logic" */;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 32'b0;
    end
end

always_ff @(posedge clk)
begin
    if (load && dest)
    begin
        data[dest] = in;
    end
end

always_comb
begin
    reg_a = src_a ? data[src_a] : 0;
    reg_b = src_b ? data[src_b] : 0;
    //dest = rd ? rd : 0;

end

endmodule : regfile
