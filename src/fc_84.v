// 84 inputs
module fc_84 #(parameter BIT_WIDTH = 32, OUT_WIDTH = 64) (
		input signed[BIT_WIDTH*84-1:0] in,
		input signed[BIT_WIDTH*84-1:0] in_weights,
		input signed[BIT_WIDTH-1:0] bias,
		output signed[OUT_WIDTH-1:0] out	// size should increase to hold the sum of products
);

// convert flattened input vector into array
wire signed[BIT_WIDTH-1:0] inputs_arr[0:83];
wire signed[BIT_WIDTH-1:0] weights[0:83];
genvar i;
generate
	for (i = 0; i < 84; i = i+1) begin : genbit
		assign inputs_arr[i] = in[BIT_WIDTH*(i+1)-1:BIT_WIDTH*i];
		assign weights[i] = in_weights[BIT_WIDTH*(i+1)-1:BIT_WIDTH*i];
	end
endgenerate

// multiplications
wire signed[OUT_WIDTH-1:0] mult[0:83];
generate
	for (i = 0; i < 84; i = i+1) begin : mult_84	// each input
		assign mult[i] = inputs_arr[i] * weights[i];
	end
endgenerate

// adder tree
wire signed[OUT_WIDTH-1:0] sums[0:81];	// 84-2 intermediate sums
genvar x;
generate
	// sums[0] to sums[41]
	for (x = 0; x < 42; x = x+1) begin : addertree_nodes0
		assign sums[x] = mult[x*2] + mult[x*2+1];
	end
	// sums[42] to sums[62]
	for (x = 0; x < 21; x = x+1) begin : addertree_nodes1
		assign sums[x+42] = sums[x*2] + sums[x*2];
	end
	// sums[63] to sums[72]
	for (x = 0; x < 10; x = x+1) begin : addertree_nodes2
		assign sums[x+63] = sums[x*2+42] + sums[x*2+43];
	end
	// sums[73] to sums[77]
	for (x = 0; x < 5; x = x+1) begin : addertree_nodes3
		assign sums[x+73] = sums[x*2+63] + sums[x*2+64];
	end
	// sums[78] to sums[79]
	for (x = 0; x < 2; x = x+1) begin : addertree_nodes4
		assign sums[x+78] = sums[x*2+73] + sums[x*2+74];
	end
	// sums[80] = sums[77] + sums[62]
	assign sums[80] = sums[77] + sums[62];
	// sums[81] = sums[78] + sums[79]
	assign sums[81] = sums[78] + sums[79];
endgenerate

// final sum
assign out = sums[80] + sums[81] + bias;

endmodule
