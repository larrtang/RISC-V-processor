module counter2bit_array_di #(
	parameter s_index = 3,
	parameter num_sets = 2**s_index
)
(
	input logic clk,
	input logic reset,
	input logic increment,
	input logic decrement,
	input logic [s_index-1:0] read_index,
	input logic [s_index-1:0] write_index,

	output logic [1:0] out
);

logic [1:0] data [num_sets-1:0];
//logic [1:0] _out;

assign out = data[read_index];

initial
begin
	for(int i = 0; i < num_sets; i++) begin
		data[i] = 2'b01;
	end
end

always_ff @(posedge clk)
begin

if (reset) begin
  data[write_index] <= 2'b01;

end 
	
else if(increment) begin
	if(data[write_index] == 2'b11)
		data[write_index] <= 2'b11;
	else
		data[write_index] <= data[write_index] + 1'b1;
end else if(decrement) begin
	if(data[write_index] == 2'b00)
		data[write_index] <= 2'b00;
	else
		data[write_index] <= data[write_index] - 1'b1;
end

end
 
endmodule : counter2bit_array_di
