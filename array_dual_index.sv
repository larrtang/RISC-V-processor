module array_dual_index #(
    parameter s_index = 3,
    parameter width = 1,
    parameter num_sets = 2**s_index
)
(
    input clk,
    input logic load,
    input logic [s_index-1:0] read_index,
    input logic [s_index-1:0] write_index,
    input [width-1:0] datain,
    output logic [width-1:0] dataout
);

logic [width-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;

assign dataout = data[read_index];


/* Initialize array */
initial
begin
    for (int i = 0; i < num_sets; i++)
    begin
        data[i] = 0;
    end
end

always_ff @(posedge clk)
begin
  
    if(load)
        data[write_index] <= datain;
end

endmodule : array_dual_index
