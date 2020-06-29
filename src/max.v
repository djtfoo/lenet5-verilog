module max #(parameter BIT_WIDTH = 8)(
	input signed[BIT_WIDTH-1:0] in1, in2,
	output signed[BIT_WIDTH-1:0] max
);

// signed comparison
assign max = (in1 > in2) ? in1 : in2;

endmodule
