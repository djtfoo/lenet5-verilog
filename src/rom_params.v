module rom_params #(parameter BIT_WIDTH = 8, SIZE = 26, FILE = "kernel_c1.list") (
	input clk,
	input read,
	output reg[BIT_WIDTH*SIZE-1:0] read_out
);

reg [BIT_WIDTH-1:0] weights [0:SIZE-1];

// simple way to read weights from memory
initial begin
	$readmemh(FILE, weights); // read 5x5 filter + 1 bias
end

reg[15:0] i;	// 2^16 = 65536
always @ (posedge clk) begin
	for (i = 0; i < SIZE; i = i+1) begin
		if (read)
			//read_out[BIT_WIDTH*(i+1)-1 : BIT_WIDTH*i] <= weights[i];
			read_out[i*BIT_WIDTH +: BIT_WIDTH] <= weights[i];
	end
end

endmodule

