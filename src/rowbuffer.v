module rowbuffer #(parameter COLS, BIT_WIDTH) (
		input clk, rst,
		input [BIT_WIDTH-1:0] rb_in,
		input en,
		output [BIT_WIDTH-1:0] rb_out	// output for next buffer
);

reg [BIT_WIDTH-1:0] rb[0:COLS-1];
integer i;

always @ (posedge clk) begin
	if (en) begin
		for (i = COLS - 1; i > 0; i = i-1) begin
			rb[i] <= rb[i-1];
		end
		rb[0] <= rb_in;
	end
end

//assign rb_out = rb[COLS-1];
assign rb_out = rb[COLS-1];

endmodule
