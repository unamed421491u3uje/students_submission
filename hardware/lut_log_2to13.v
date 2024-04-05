`ifndef __lut_log_2to13_V__
`define __lut_log_2to13_V__

module lut_log_2to13
(
  input   logic        in,
  output  logic [12:0] out
);

  always_comb begin
    case (in)
      1'b0:    out = 13'b0000000000000;
      1'b1:    out = 13'b0110101000001;
      default: out = 13'bxxxxxxxxxxxxx;
    endcase
  end

endmodule

`endif