module CPU(ck, rst, ia, id, da, dd, rw);
  input ck, rst;
  input [15:0] id;
  output rw;
  output [15:0] ia, da;
  inout [15:0] dd;

  reg [1:0] stage;
  reg [15:0] inst, pc, pcc, fua, fub, lsua, lsub, lsuc, pci, fuc;
  reg [15:0] rf[0:14];
  reg flag, rw;
  wire [15:0] abus, bbus, cbus;
  wire [3:0] opcode, opr1, opr2, opr3;
  wire [7:0] imm;

  assign ia = pc;
  assign opcode = inst[15:12];
  assign opr1 = inst[11:8];
  assign opr2 = inst[7:4];
  assign opr3 = inst[3:0];
  assign imm = inst[7:0];
  assign abus = (opr2 == 0 ? 0 : rf[opr2]);
  assign bbus = (opr3 == 0 ? 0 : rf[opr3]);
  assign da = lsub;
  assign ia = pc;
  assign dd = (rw == 0 ? lsua : 16'b z);
  assign cbus = (opcode[3] == 0 ? fuc
                  : (opcode[3:1] == 'b 101 ? lsuc
                  : (opcode == 'b 1100 ? {8'b 0, imm}
                  : (opcode == 'b 1000 ? pcc : 'b z))));

  always @(posedge ck) begin
    if (rst == 1) begin
      pc <= 0;
      stage <= 0;
      rw <= 1;
    end
    else begin
      if (stage == 0) begin
        inst <= id;
        stage <= 1;
      end
      else if (stage == 1) begin
        if (opcode[3:0] == 'b1000 || (opcode[3:0] == 'b1001 && flag == 1)) begin
          pci <= bbus;
        end
        else begin
          pci <= pc + 1;
        end
        if (opcode[3] == 0) begin
          fua <= abus;
          fub <= bbus;
        end
        else if (opcode[2:1] == 'b01) begin
          lsua <= abus;
          lsub <= bbus;
        end
        stage <= 2;
      end
      else if (stage == 2) begin
        if (opcode[3] == 0) begin
          case (opcode[2:0])
            'b 000: fuc <= fua + fub;
            'b 001: fuc <= fua - fub;
            'b 010: fuc <= fua >> fub;
            'b 011: fuc <= fua << fub;
            'b 100: fuc <= fua | fub;
            'b 101: fuc <= fua & fub;
            'b 110: fuc <= ~fua;
            'b 111: fuc <= fua ^ fub;
          endcase
        end
        if (opcode[3:1] == 'b 101) begin
          if (opcode[0] == 0) begin
            rw <= 0;
          end
          else begin
            rw <= 1;
            lsuc <= dd;
          end
        end
        if (opcode[3:0] == 'b 1000) begin
          pcc <= pc + 1;
        end
        stage <= 3;
      end
      else if (stage == 3) begin
        rw <= 1;
        if (opcode[3] == 0) begin
          if (cbus == 0) flag <= 1;
          else flag <= 0;
        end
        rf[opr1] <= cbus;
        pc <= pci;
        stage <= 0;
      end
    end
  end
endmodule
