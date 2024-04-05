`ifndef __lut_log_4to13_V__
`define __lut_log_4to13_V__

module lut_log_4to13
(
  input   logic [1:0]  in,
  output  logic [12:0] out
);

  always_comb begin
    case (in)
      2'b00:   out = 13'b0000000000000;
      2'b01:   out = 13'b0011000001101;
      2'b10:   out = 13'b0110101000001;
      2'b11:   out = 13'b1010111010001;
      default: out = 13'bxxxxxxxxxxxxx;
    endcase
  end

endmodule

`endif