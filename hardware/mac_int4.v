`ifndef __MAC_INT4_V__
`define __MAC_INT4_V__

`include "accumulator.v"

(* multstyle = "logic" *)
module mac_int4
#(
    parameter DATA_WIDTH = 4,
    parameter ACC_WIDTH  = 16
) (
  input   logic                           clk,
  input   logic                           reset,
  input   logic                           en,

  input   logic  signed [DATA_WIDTH-1:0]  weight,
  input   logic  signed [DATA_WIDTH-1:0]  act,
  output  logic  signed [ACC_WIDTH-1:0]   out
);
  logic signed [2*DATA_WIDTH-1:0] product;
  logic signed [DATA_WIDTH-1:0] a, b;
  assign product = a * b;

  always_ff @(posedge clk) begin
    if (reset) begin
        a   <= 0;
        b   <= 0;
    end else if (en) begin
        a   <= act;
        b   <= weight;
    end
  end

  accumulator #(
    .ACC_WIDTH (ACC_WIDTH),
    .IN_WIDTH  (2*DATA_WIDTH),
    .IS_SIGNED (1'b1)
  ) adder (.acc_out(out), .acc_in(product), .*);

endmodule

`endif