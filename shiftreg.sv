module shiftreg #(parameter width = 32)
(
    input clk,
    input load,
    input reset,
    input logic in,
    output logic [width-1:0] out
);

logic [width-1:0] data;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    data = 1'b0;
end

always_ff @(posedge clk)
begin
    if (reset == 1)
    begin
        data = 1'b0;
    end
    else if (load)
    begin
        data = {out[width-2:0], in};
    end
end

always_comb
begin
    out = data;
end

endmodule : shiftreg
