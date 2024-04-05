`ifndef __ACCUMULATOR_V__
`define __ACCUMULATOR_V__


module accumulator
# (
  parameter ACC_WIDTH  = 21,
  parameter IN_WIDTH   = 15,
  parameter IS_SIGNED  = 1'b1
) (
  input   logic                        clk,
  input   logic                        reset,
  input   logic                        en,
  input   logic [IN_WIDTH-1:0]         acc_in,
  output  logic signed [ACC_WIDTH-1:0] acc_out
);

  always_ff @(posedge clk) begin
    if (reset) begin
      acc_out  <= 0;
    end else if (en) begin
      if (IS_SIGNED)
        acc_out  <= acc_out + $signed(acc_in);
      else 
        acc_out  <= acc_out + acc_in;
    end
  end

endmodule

`endif