module row5buffer #(parameter COLS = 28, BIT_WIDTH = 8)(
	input clk, rst,
	input [BIT_WIDTH-1:0] rb_in,
	input en,	// whether to latch or not
	output [BIT_WIDTH-1:0] rb_out0, rb_out1, rb_out2, rb_out3, rb_out4
);

// first row to receive input
rowbuffer #(.COLS(COLS), .BIT_WIDTH(BIT_WIDTH)) RB0(  .clk(clk),
							.rst(rst),
							.rb_in(rb_in),
							.en(en),
							.rb_out(rb_out0)
);

rowbuffer #(.COLS(COLS), .BIT_WIDTH(BIT_WIDTH)) RB1(  .clk(clk),
							.rst(rst),
							.rb_in(rb_out0),
							.en(en),
							.rb_out(rb_out1)
);

rowbuffer #(.COLS(COLS), .BIT_WIDTH(BIT_WIDTH)) RB2(  .clk(clk),
							.rst(rst),
							.rb_in(rb_out1),
							.en(en),
							.rb_out(rb_out2)
);

rowbuffer #(.COLS(COLS), .BIT_WIDTH(BIT_WIDTH)) RB3(  .clk(clk),
							.rst(rst),
							.rb_in(rb_out2),
							.en(en),
							.rb_out(rb_out3)
);

// last row to receive input
rowbuffer #(.COLS(COLS), .BIT_WIDTH(BIT_WIDTH)) RB4(  .clk(clk),
							.rst(rst),
							.rb_in(rb_out3),
							.en(en),
							.rb_out(rb_out4)
);

endmodule
