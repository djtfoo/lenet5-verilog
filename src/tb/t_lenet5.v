module t_lenet5();

reg clk = 0;
reg reset = 0;
wire [7:0] pixel;
wire[3:0] out;

always #5 clk = ~clk;

// read the next pixel at every posedge clk
image_reader #(.NUMPIXELS(1024), .PIXELWIDTH(8), .FILE("image32x32.list")) R1 (
 .clk(clk), .rst(reset),
 .nextPixel(pixel)
);

// will store the pixel in the row buffer
//  and perform calculations (convolution/pooling)
//  at every posedge clk
lenet5 #(.IMAGE_COLS(32), .IN_WIDTH(8), .OUT_WIDTH(32)) LeNet5 (
 .clk(clk), .rst(reset),
 .nextPixel(pixel),
 .out(out)
);

endmodule
