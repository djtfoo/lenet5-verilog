module ReLU #(parameter BIT_WIDTH = 32)(
	input signed[BIT_WIDTH-1:0] in,
	output signed[BIT_WIDTH-1:0] out
);

// check MSB = 1 (-ve)
assign out = (in[BIT_WIDTH-1]) ? 0 : in;

endmodule
