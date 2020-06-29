// 120 inputs
module fc_120 #(parameter BIT_WIDTH = 32, OUT_WIDTH = 64) (
		input signed[BIT_WIDTH*120-1:0] in,
		input signed[BIT_WIDTH*120-1:0] in_weights,
		input signed[BIT_WIDTH-1:0] bias,
		output signed[OUT_WIDTH-1:0] out	// size should increase to hold the sum of products
);

// convert flattened input vector into array
wire signed[BIT_WIDTH-1:0] inputs_arr[0:119];
wire signed[BIT_WIDTH-1:0] weights[0:119];
genvar i;
generate
	for (i = 0; i < 120; i = i+1) begin : genbit
		assign inputs_arr[i] = in[BIT_WIDTH*(i+1)-1:BIT_WIDTH*i];
		assign weights[i] = in_weights[BIT_WIDTH*(i+1)-1:BIT_WIDTH*i];
	end
endgenerate

// multiplications
wire signed[OUT_WIDTH-1:0] mult[0:119];
generate
	for (i = 0; i < 120; i = i+1) begin : mult_120	// each input
		assign mult[i] = inputs_arr[i] * weights[i];
	end
endgenerate

// adder tree
wire signed[OUT_WIDTH-1:0] sums[0:117];	// 120-2 intermediate sums
genvar x;
generate
	// sums[0] to sums[59]
	for (x = 0; x < 60; x = x+1) begin : addertree_nodes0
		assign sums[x] = mult[x*2] + mult[x*2+1];
	end
	// sums[60] to sums[89]
	for (x = 0; x < 30; x = x+1) begin : addertree_nodes1
		assign sums[x+60] = sums[x*2] + sums[x*2];
	end
	// sums[90] to sums[104]
	for (x = 0; x < 15; x = x+1) begin : addertree_nodes2
		assign sums[x+90] = sums[x*2+60] + sums[x*2+61];
	end
	// sums[105] to sums[111]
	for (x = 0; x < 7; x = x+1) begin : addertree_nodes3
		assign sums[x+105] = sums[x*2+90] + sums[x*2+91];
	end
	// sums[112] to sums[114]
	for (x = 0; x < 3; x = x+1) begin : addertree_nodes4
		assign sums[x+112] = sums[x*2+105] + sums[x*2+106];
	end
	// sums[115] = sums[111] + sums[104]
	assign sums[115] = sums[111] + sums[104];
	// sums[116] to sums[117]
	for (x = 0; x < 2; x = x+1) begin : addertree_nodes5
		assign sums[x+116] = sums[x*2+112] + sums[x*2+113];
	end
endgenerate

// final sum
assign out = sums[116] + sums[117] + bias;

endmodule
