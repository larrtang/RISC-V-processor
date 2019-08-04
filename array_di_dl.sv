module array_di_dl #(
    parameter s_index = 3,
    parameter width = 1,
    parameter num_sets = 2**s_index
)
(
    input clk,
    input logic load_a,
    input logic load_b,
    input logic [s_index-1:0] index_a,
    input logic [s_index-1:0] index_b,
    input [width-1:0] datain,
    output logic [width-1:0] dataout
);

logic [width-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;

assign dataout = data[index_a];


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
    if(load_a)
        data[index_a] <= 0;
  
    if(load_b)
        data[index_b] <= datain;
end

endmodule : array_di_dl
