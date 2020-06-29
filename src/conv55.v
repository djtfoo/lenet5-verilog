module conv55 #(parameter BIT_WIDTH = 8, OUT_WIDTH = 32) (
		input clk, //rst,
		input en,	// whether to latch or not
		input signed[BIT_WIDTH-1:0] in1, in2, in3, in4, in5,
		input signed[(BIT_WIDTH*25)-1:0] filter,	// 5x5 filter
		//input [BIT_WIDTH-1:0] bias,
		output signed[OUT_WIDTH-1:0] convValue	// size should increase to hold the sum of products
);

reg signed [BIT_WIDTH-1:0] rows[0:4][0:4];
integer i;

always @ (posedge clk) begin
	if (en) begin
		for (i = 4; i > 0; i = i-1) begin
			rows[0][i] <= rows[0][i-1];
			rows[1][i] <= rows[1][i-1];
			rows[2][i] <= rows[2][i-1];
			rows[3][i] <= rows[3][i-1];
			rows[4][i] <= rows[4][i-1];
		end
		rows[0][0] <= in1;
		rows[1][0] <= in2;
		rows[2][0] <= in3;
		rows[3][0] <= in4;
		rows[4][0] <= in5;
	end
end

// multiply & accumulate in 1 clock cycle
wire signed[OUT_WIDTH-1:0] mult55[0:24];
genvar x, y;

// multiplication
generate
	for (x = 0; x < 5; x = x+1) begin : sum_rows	// each row
		for (y = 0; y < 5; y = y+1) begin : sum_columns	// each item in a row
			assign mult55[5*x+y] = rows[x][4-y] * filter[BIT_WIDTH*(5*x+y+1)-1 : BIT_WIDTH*(5*x+y)];
		end
	end
endgenerate

// adder tree
wire signed[OUT_WIDTH-1:0] sums[0:22];	// 25-2 intermediate sums
generate
	// sums[0] to sums[11]
	for (x = 0; x < 12; x = x+1) begin : addertree_nodes0
		assign sums[x] = mult55[x*2] + mult55[x*2+1];
	end
	// sums[12] to sums[17]
	for (x = 0; x < 6; x = x+1) begin : addertree_nodes1
		assign sums[x+12] = sums[x*2] + sums[x*2+1];
	end
	// sums[18] to sums[20]
	for (x = 0; x < 3; x = x+1) begin : addertree_nodes2
		assign sums[x+18] = sums[x*2+12] + sums[x*2+13];
	end
	// sums[21] = sums[18] + sums[19]
	assign sums[21] = sums[18] + sums[19];
	// sums[22] = sums[20] + mult55[24]
	assign sums[22] = sums[20] + mult55[24];
endgenerate

// final sum
assign convValue = sums[21] + sums[22];

endmodule
