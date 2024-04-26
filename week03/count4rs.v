module count4rs(out, ck, res);

  output [3:0] out;
  input ck, res;
  reg [3:0] q;

  always @(posedge ck or negedge res) begin
    if (!res) q <= 4'b0000;
    else q <= q - 1;
  end

  assign out = q;

endmodule
