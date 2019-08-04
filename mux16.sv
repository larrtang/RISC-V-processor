module mux16 #(parameter width = 32)
(
input [3:0] sel,
input [width-1:0] a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p,
output logic [width-1:0] z
);
always_comb
begin
if (sel == 4'b0000)
z = a;
else if (sel == 4'b0001)
z = b;
else if (sel == 4'b0010)
z = c;
else if (sel == 4'b0011)
z = d;
else if (sel == 4'b0100)
z = e;
else if (sel == 4'b0101)
z = f;
else if (sel == 4'b0110)
z = g;
else if (sel == 4'b0111)
z = h;
else if (sel == 4'b1000)
z = i;
else if (sel == 4'b1001)
z = j;
else if (sel == 4'b1010)
z = k;
else if (sel == 4'b1011)
z = l;
else if (sel == 4'b1100)
z = m;
else if (sel == 4'b1101)
z = n;
else if (sel == 4'b1110)
z = o;
else
z = p;
end
endmodule : mux16
