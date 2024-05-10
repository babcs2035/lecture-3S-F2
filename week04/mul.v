module mul(A, B, O, ck, start, fin);
  input [7:0] A, B;
  input ck, start;
  output [16:0] O;
  output fin;

  reg [3:0] st;
  reg [7:0] ain, bin;
  reg [16:0] o, y;
  reg fin;

  assign O = (fin == 1 ? y : 'b0);

  always @(posedge ck) begin
    if (start == 1) begin
      st <= 0;
      fin <= 0;
      ain <= A;
      bin <= B;
      y <= 0;
    end
    else begin
      case (st)
        0: y <= (y << 1) + (bin[7] == 1 ? ain : 0);
        1: y <= (y << 1) + (bin[6] == 1 ? ain : 0);
        2: y <= (y << 1) + (bin[5] == 1 ? ain : 0);
        3: y <= (y << 1) + (bin[4] == 1 ? ain : 0);
        4: y <= (y << 1) + (bin[3] == 1 ? ain : 0);
        5: y <= (y << 1) + (bin[2] == 1 ? ain : 0);
        6: y <= (y << 1) + (bin[1] == 1 ? ain : 0);
        7: begin
          y <= (y << 1) + (bin[0] == 1 ? ain : 0);
          fin <= 1;
        end
        8: fin <= 0;
      endcase
      st <= st + 1;
    end
  end
endmodule
