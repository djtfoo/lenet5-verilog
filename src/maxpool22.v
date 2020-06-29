module maxpool22 #(parameter BIT_WIDTH = 32) (
	input clk, //rst,
	input en,	// whether to latch or not
	input signed[BIT_WIDTH-1:0] in1, in2,
	output signed[BIT_WIDTH-1:0] maxOut
);

parameter SIZE = 2;	// 2x2 max pool

reg signed[BIT_WIDTH-1:0] row1[0:1];	// 1st row of layer
reg signed[BIT_WIDTH-1:0] row2[0:1];	// 2nd row of layer
integer i;

always @ (posedge clk) begin
	if (en) begin
		for (i = SIZE-1; i > 0; i = i-1) begin
			row1[i] <= row1[i-1];
			row2[i] <= row2[i-1];
		end
		row1[0] <= in1;
		row2[0] <= in2;
	end
end

// find max
wire signed[BIT_WIDTH-1:0] maxR1, maxR2;
max #(.BIT_WIDTH(BIT_WIDTH)) M1 (
	.in1(row1[0]), .in2(row1[1]),
	.max(maxR1)
);

max #(.BIT_WIDTH(BIT_WIDTH)) M2 (
	.in1(row2[0]), .in2(row2[1]),
	.max(maxR2)
);

max #(.BIT_WIDTH(BIT_WIDTH)) M0 (
	.in1(maxR1), .in2(maxR2),
	.max(maxOut)
);

endmodule
