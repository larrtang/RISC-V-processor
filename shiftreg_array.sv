module shiftreg_array #(
    parameter width = 32,
    parameter s_index = 3,
    parameter num_sets = 2**s_index
)
(
    input clk,
    input load,
    input reset,
    input logic [s_index-1:0] index,
    input logic datain,
    output logic [width-1:0] dataout
);

//logic [width-1:0] _dataout;
logic [width-1:0] data [num_sets-1:0];

assign dataout = data[index];

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    for(int i = 0; i < num_sets; i++) begin
        data[i] = 1'b0;
    end
end

always_ff @(posedge clk)
begin
    if (reset == 1)
    begin
        data[index] <= 1'b0;
    end
    else if (load)
    begin
        data[index] <= {dataout[width-2:0], datain};
    end
end

endmodule : shiftreg_array
