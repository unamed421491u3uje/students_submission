`ifndef __MAC_DINT4_V__
`define __MAC_DINT4_V__

`include "signMagnitude_to_2sComplement.v"
`include "accumulator.v"

(* multstyle = "logic" *)
module mac_dint4
#(
    parameter DATA_WIDTH = 4,
    parameter ACC_WIDTH  = 17
) (
  input   logic                           clk,
  input   logic                           reset,
  input   logic                           en,

  input   logic         [DATA_WIDTH-1:0]  weight,
  input   logic         [DATA_WIDTH-1:0]  act,
  output  logic  signed [ACC_WIDTH-1:0]   out
);
  logic [DATA_WIDTH-1:0] a, b;
  always_ff @(posedge clk) begin
    if (reset) begin
        a   <= 0;
        b   <= 0;
    end else if (en) begin
        a   <= act;
        b   <= weight;
    end
  end

  logic prod_sign;
  assign prod_sign = a[3] ^ b[3];

  logic       a_frac, b_frac; // factional part
  logic [2:0] a_int, b_int; // integer part
  always_comb begin
    if ( a == 4'b1000 ) begin
      a_int  = 3'b000;
      a_frac = 1'b1;
    end else if ( a == 4'b0111 ) begin
      a_int  = 3'b000;
      a_frac = 1'b1;
    end else begin
      a_int  = a[2:0];
      a_frac = 1'b0;
    end

    if ( b == 4'b1000 ) begin
      b_int  = 3'b000;
      b_frac = 1'b1;
    end else if ( b == 4'b0111 ) begin
      b_int  = 3'b000;
      b_frac = 1'b1;
    end else begin
      b_int  = b[2:0];
      b_frac = 1'b0;
    end
  end

  parameter PROD_WIDTH = DATA_WIDTH * 2;
  logic [PROD_WIDTH-1:0] prod_magnitude;
  logic [PROD_WIDTH:0] signed_product, acc_in;
  assign prod_magnitude = {a_int, a_frac} * {b_int, b_frac};
  assign signed_product = {prod_sign, prod_magnitude};
  signMagnitude_to_2sComplement #(PROD_WIDTH+1) convert (.in(signed_product), .out(acc_in));

  accumulator #(
    .ACC_WIDTH (ACC_WIDTH),
    .IN_WIDTH  (PROD_WIDTH+1),
    .IS_SIGNED (1'b1)
  ) adder (.acc_out(out), .acc_in(acc_in), .*);

endmodule

`endif