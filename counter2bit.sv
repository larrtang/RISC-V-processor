module counter2bit (
	input logic clk,
	input logic reset,
	input logic increment,
	input logic decrement,

	output logic [1:0] out
);

logic [1:0] data;

always @(posedge clk)

if (reset) begin
  data <= 2'b01;

end 
	
else if(increment) begin
	if(data == 2'b11)
		data = 2'b11;
	else
		data = data + 1'b1;
end else if(decrement) begin
	if(data == 2'b00)
		data = 2'b00;
	else
		data = data - 1'b1;
end

end
 
assign out = data;
 
endmodule : counter2bit
