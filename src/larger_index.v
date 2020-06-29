module larger_index #(parameter BIT_WIDTH = 8, NUM_INPUTS = 10, INDEX_WIDTH = 4)(
	input signed[BIT_WIDTH-1:0] in1, in2,
	input signed[INDEX_WIDTH-1:0] idx1, idx2,
	output signed[BIT_WIDTH-1:0] larger_val,
	output signed[INDEX_WIDTH-1:0] larger_idx
);

// signed comparison due to adding 'signed' keyword
assign larger_idx = (in1 > in2) ? idx1 : idx2;
assign larger_val = (in1 > in2) ? in1 : in2;

endmodule
