module pc(
	input clk,
	input rst,
	input inc,
	input load, // for jumping
	input bus[15:0],

	output[15:0] out
);
	
	reg[15:0] pc;
	
	always @ (posedge clk, posedge rst)
	begin
		if (rst)
		begin
			pc <= 16'b0;
		end else if (inc)
		begin
			pc <= pc + 1;
		end
	end

	assign out = pc;

endmodule
