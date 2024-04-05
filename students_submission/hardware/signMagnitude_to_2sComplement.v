`ifndef __SIGNMAGNITUDE_TO_2SCOMPLEMENT__
`define __SIGNMAGNITUDE_TO_2SCOMPLEMENT__

module signMagnitude_to_2sComplement
#(
    parameter DATA_WIDTH = 4
) (
  input   logic   [DATA_WIDTH-1:0]   in,
  output  logic   [DATA_WIDTH-1:0]   out
);
  logic [DATA_WIDTH-1:0] magnitude; 
  assign magnitude = {1'b0, in[DATA_WIDTH-2:0]};

  always_comb begin
    if (in[DATA_WIDTH-1]) begin
        out <= ~magnitude + 1'b1;
    end else begin
        out <= magnitude;
    end
  end

endmodule

`endif