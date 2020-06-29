module row2buffer #(parameter COLS = 28, BIT_WIDTH = 8)(
	input clk, rst,
	input [BIT_WIDTH-1:0] rb_in,
	input en,	// whether to latch or not
	output [BIT_WIDTH-1:0] rb_out0, rb_out1
);

// first row to receive input
rowbuffer #(.COLS(COLS), .BIT_WIDTH(BIT_WIDTH)) RB0(  .clk(clk),
							.rst(rst),
							.rb_in(rb_in),
							.en(en),
							.rb_out(rb_out0)
);

// last row to receive input
rowbuffer #(.COLS(COLS), .BIT_WIDTH(BIT_WIDTH)) RB1(  .clk(clk),
							.rst(rst),
							.rb_in(rb_out0),
							.en(en),
							.rb_out(rb_out1)
);

endmodule
