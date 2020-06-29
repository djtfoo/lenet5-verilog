module max_index_10 #(parameter BIT_WIDTH = 8, INDEX_WIDTH = 4)(
	input signed[BIT_WIDTH*10-1:0] in,
	output signed[INDEX_WIDTH-1:0] max
);

// convert flattened input vector into array
wire signed[BIT_WIDTH-1:0] inputs_arr[0:9];
genvar i;
generate
	for (i = 0; i < 10; i = i+1) begin : genbit
		assign inputs_arr[i] = in[BIT_WIDTH*(i+1)-1:BIT_WIDTH*i];
	end
endgenerate

// comparisons: 9 total
// 1. compare [0] to [1], [2] to [3], ... [8] to [9] (5 comparisons)
// 2. compare results of (1), leaving 1 remainder value (2 comparisons)
// 3. compare results of (2) (1 comparison)
// 4. compare result of (3) with the remainder of (2) (1 comparison)

// store intermediate larger index found for each 1-to-1 comparison
wire signed[INDEX_WIDTH-1:0] larger_idxs [0:7];	// 9 comparisons, 8 intermediate comparison outputs
wire signed[BIT_WIDTH-1:0] larger_vals [0:8];	// 9 comparisons, 8 intermediate comparison outputs

// 1. compare [0] to [1], [2] to [3], ... [8] to [9] (5 comparisons)
genvar gen;
generate
	for (gen = 0; gen < 5; gen = gen+1) begin : larger_comp1
		larger_index #(.BIT_WIDTH(BIT_WIDTH), .INDEX_WIDTH(INDEX_WIDTH)) FIND_LARGER_1 (
			.in1(inputs_arr[gen*2]), .in2(inputs_arr[gen*2+1]),
			.idx1(gen*2), .idx2(gen*2+1),
			.larger_val(larger_vals[gen]), .larger_idx(larger_idxs[gen])	// save to [0] to [4]
		);
	end
endgenerate

// 2. compare results of (1), leaving 1 remainder value (2 comparisons)
generate
	for (gen = 0; gen < 2; gen = gen+1) begin : larger_comp2
		larger_index #(.BIT_WIDTH(BIT_WIDTH), .INDEX_WIDTH(INDEX_WIDTH)) FIND_LARGER_2 (
			.in1(larger_vals[gen*2]), .in2(larger_vals[gen*2+1]),	// compare [0] to [1], [2] to [3]
			.idx1(larger_idxs[gen*2]), .idx2(larger_idxs[gen*2+1]),	// compare [0] to [1], [2] to [3]
			.larger_val(larger_vals[gen+5]), .larger_idx(larger_idxs[gen+5])	// save to [5] and [6]
		);
	end
endgenerate

// 3. compare results of (2) (1 comparison)
larger_index #(.BIT_WIDTH(BIT_WIDTH), .INDEX_WIDTH(INDEX_WIDTH)) FIND_LARGER_3 (
	.in1(larger_vals[5]), .in2(larger_vals[6]),
	.idx1(larger_idxs[5]), .idx2(larger_idxs[6]),
	.larger_val(larger_vals[7]), .larger_idx(larger_idxs[7])	// comparison #8; save to [7]
);

// 4. (final) compare result of (3) with the remainder of (2) (1 comparison)
larger_index #(.BIT_WIDTH(BIT_WIDTH), .INDEX_WIDTH(INDEX_WIDTH)) FIND_LARGER_4 (
	.in1(larger_vals[7]), .in2(larger_vals[4]),	// compare [7] to [4]
	.idx1(larger_idxs[7]), .idx2(larger_idxs[4]),	// compare [7] to [4]
	.larger_val(larger_vals[8]), .larger_idx(max)	// comparison #9; save to [8] and out
);

endmodule
