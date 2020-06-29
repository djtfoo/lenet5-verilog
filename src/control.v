module control #(parameter COLS = 32) (
	input clk,
	output read,	// whether rom is allowed to read
	output reg S2_en, C3_en, S4_en, C5_en	// whether to latch values for S2/C3/S4/C5 (pool/conv/pool/conv)
);

parameter C1_LEN = 28;
parameter S2_LEN = 14;
parameter C3_LEN = 10;
parameter S4_LEN = 5;

// determine if layer output should be read
reg[4:0] c1_count = C1_LEN;	// 28, ends at 32 (range: 0 to 31) - skip 4 cycles
reg[4:0] s2_count = C1_LEN-2;	// counts entire C1 row but takes alternate outputs
reg s2_dontskip = 1;	// whether to skip reading a row or not

reg[3:0] c3_count = 0;	// count no. C3 outputs produced thus far (range: 0 to 13 to skip 4 cycles)
reg[3:0] s4_count = 0;	// count no. C3 outputs encountered thus far (takes alternate outputs)
reg s4_dontskip = 1;	// whether to skip reading a row or not

// determine if layer to begin reading input
reg[7:0] enable_s2_count = 5 + 4*COLS - 1;	// start at 133th clock cycle; count down to 0
reg s2_begin = 0;

reg enable_c3_bit = 0, enable_c3_bit2 = 0, enable_c3_bit3 = 0;
reg c3_begin = 0;

reg[8:0] enable_s4_count = 431;	// start at 432th clock cycle; count down to 0
reg s4_begin = 0;

reg[8:0] enable_c5_count = 499;	// start at 500th clock cycle; count down to 0
reg c5_begin = 0;

reg first_cycle = 1;

assign read = first_cycle;

always @ (posedge clk) begin
	// whether to read from rom
	first_cycle <= 0;

	// count outputs of layer C1
	if (c1_count == COLS - 1)
		c1_count <= 0;	// wrap counter
	else	c1_count <= c1_count + 1;

	// check if layer S2 can begin
	enable_s2_count <= enable_s2_count - 1;
	s2_begin <= s2_begin | (enable_s2_count == 8'b1);	// calculate condition one cycle before

	// determine if layer S2 should read inputs of layer C1
	S2_en = s2_begin & (c1_count < C1_LEN);

	// count inputs to layer S2
	if (S2_en) begin
		if (s2_count == C1_LEN-1) begin
			s2_count <= 0;
			s2_dontskip <= ~s2_dontskip;
		end
		else	s2_count <= s2_count + 1;
	end

	// check if layer C3 can begin
	enable_c3_bit <= enable_c3_bit | S2_en;
	enable_c3_bit2 <= enable_c3_bit & ~S2_en;	// when it goes low for the first time
	enable_c3_bit3 <= enable_c3_bit2;	// delay by 1 cycle
	c3_begin <= c3_begin | (enable_c3_bit3 & S2_en);	// already begun or meets the condition for begin

	// determine if layer C3 should read inputs of layer S2
	C3_en = c3_begin & S2_en & (s2_count < C1_LEN-1) & s2_dontskip & ~s2_count[0];

	// check if layer S4 can begin
	enable_s4_count <= enable_s4_count - 1;
	s4_begin <= s4_begin | (enable_s4_count == 8'b1);	// calculate condition one cycle before

	// count outputs of layer C3
	if (C3_en & s4_begin) begin	// when C3 should read in value
		if (c3_count == S2_LEN-1) begin
			c3_count <= 0;
		end
		else	c3_count <= c3_count + 1;
	end

	// determine if layer S4 should read inputs of layer C3
	S4_en = s4_begin & C3_en & (c3_count < C3_LEN);

	// check if layer C5 can begin
	enable_c5_count <= enable_c5_count - 1;
	c5_begin <= c5_begin | (enable_c5_count == 8'b1);	// calculate condition one cycle before

	// count inputs to layer S4
	if (S4_en & c5_begin) begin	// when S4 reads in a value
		if (s4_count == C3_LEN-1) begin
			s4_count <= 0;
			s4_dontskip <= ~s4_dontskip;
		end
		else	s4_count <= s4_count + 1;
	end

	// determine if layer C5 should read inputs of layer S4
	C5_en = c5_begin & S4_en & s4_dontskip & ~s4_count[0];
end

endmodule
