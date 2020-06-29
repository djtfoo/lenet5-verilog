module conv554 #(parameter BIT_WIDTH = 8, OUT_WIDTH = 32) (
		input clk, //rst,
		input en,	// whether to latch or not
		input signed[BIT_WIDTH-1:0] in01, in02, in03, in04, in05,
		input signed[BIT_WIDTH-1:0] in11, in12, in13, in14, in15,
		input signed[BIT_WIDTH-1:0] in21, in22, in23, in24, in25,
		input signed[BIT_WIDTH-1:0] in31, in32, in33, in34, in35,
		input signed[(BIT_WIDTH*100)-1:0] filter,	// 5x5x4 filter
		input signed[BIT_WIDTH-1:0] bias,
		output signed[OUT_WIDTH-1:0] convValue	// size should increase to hold the sum of products
);

wire signed[OUT_WIDTH-1:0] conv0, conv1, conv2, conv3;

parameter SIZE = 25;	// 5x5 filter

// first feature map
conv55 #(.BIT_WIDTH(BIT_WIDTH), .OUT_WIDTH(OUT_WIDTH)) CONV0 (
	.clk(clk), //.rst(rst),
	.en(en),
	.in1(in01), .in2(in02), .in3(in03), .in4(in04), .in5(in05),
	.filter( filter[BIT_WIDTH*(SIZE)-1 : 0] ),
	//.bias(0),	// only 1 bias per conv
	.convValue(conv0)
);

// second feature map
conv55 #(.BIT_WIDTH(BIT_WIDTH), .OUT_WIDTH(OUT_WIDTH)) CONV1 (
	.clk(clk), //.rst(rst),
	.en(en),
	.in1(in11), .in2(in12), .in3(in13), .in4(in14), .in5(in15),
	.filter( filter[BIT_WIDTH*(2*SIZE)-1 : BIT_WIDTH*SIZE] ),
	//.bias(0),	// only 1 bias per conv
	.convValue(conv1)
);

// third feature map
conv55 #(.BIT_WIDTH(BIT_WIDTH), .OUT_WIDTH(OUT_WIDTH)) CONV2 (
	.clk(clk), //.rst(rst),
	.en(en),
	.in1(in21), .in2(in22), .in3(in23), .in4(in24), .in5(in25),
	.filter( filter[BIT_WIDTH*(3*SIZE)-1 : BIT_WIDTH*2*SIZE] ),
	//.bias(0),	// only 1 bias per conv
	.convValue(conv2)
);

// fourth (last) feature map
conv55 #(.BIT_WIDTH(BIT_WIDTH), .OUT_WIDTH(OUT_WIDTH)) CONV3 (
	.clk(clk), //.rst(rst),
	.en(en),
	.in1(in31), .in2(in32), .in3(in33), .in4(in34), .in5(in35),
	.filter( filter[BIT_WIDTH*(4*SIZE)-1 : BIT_WIDTH*3*SIZE] ),
	//.bias(bias),
	.convValue(conv3)
);

wire signed[OUT_WIDTH-1:0] sum0, sum1;

assign sum0 = conv0 + conv1;
assign sum1 = conv2 + conv3;
assign convValue = sum0 + sum1 + bias;

endmodule
