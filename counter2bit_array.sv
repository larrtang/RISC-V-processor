module counter2bit_array #(
	parameter s_index = 3,
	parameter num_sets = 2**s_index
)
(
	input logic clk,
	input logic reset,
	input logic increment,
	input logic decrement,
	input logic [s_index-1:0] index,

	output logic [1:0] out
);

logic [1:0] data [num_sets-1:0];
//logic [1:0] _out;

assign out = data[index];

initial
begin
	for(int i = 0; i < num_sets; i++) begin
		data[i] = 2'b01
	end
end

always_ff @(posedge clk)

if (reset) begin
  data[index] <= 2'b01;

end 
	
else if(increment) begin
	if(data[index] == 2'b11)
		data[index] <= 2'b11;
	else
		data[index] <= data[index] + 1'b1;
end else if(decrement) begin
	if(data[index] == 2'b00)
		data[index] <= 2'b00;
	else
		data[index] <= data[index] - 1'b1;
end

end
 
endmodule : counter2bit_array