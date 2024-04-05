`ifndef __MAC_LOG_V__
`define __MAC_LOG_V__

`include "signMagnitude_to_2sComplement.v"
`include "accumulator.v"

module mac_log_pure
#(
    parameter DATA_WIDTH = 4,
    parameter ACC_WIDTH  = 2**DATA_WIDTH + 6
) (
  input   logic                      clk,
  input   logic                      reset,
  input   logic                      en,

  input   logic   [DATA_WIDTH-1:0]   weight,
  input   logic   [DATA_WIDTH-1:0]   act,
  output  logic signed [ACC_WIDTH-1:0]    out
);
  logic [DATA_WIDTH-1:0] a, b;
  logic [DATA_WIDTH-1:0] sum;
  logic [2**DATA_WIDTH-2:0] shifted_value;
  logic signed [2**DATA_WIDTH-1:0] product;

  assign sum = a[DATA_WIDTH-2:0] + b[DATA_WIDTH-2:0];

  assign shifted_value = 1'b1 << sum;
  assign product = {a[DATA_WIDTH-1] ^ b[DATA_WIDTH-1], shifted_value};

  logic [2**DATA_WIDTH-1:0] acc_in;
  signMagnitude_to_2sComplement #(2**DATA_WIDTH) convert (.in(product), .out(acc_in));

  always_ff @(posedge clk) begin
    if (reset) begin
        a   <= 0;
        b   <= 0;
    end else if (en) begin
        a   <= weight;
        b   <= act;        
    end
  end

  accumulator #(
    .ACC_WIDTH (ACC_WIDTH),
    .IN_WIDTH  (2**DATA_WIDTH),
    .IS_SIGNED (1'b1)
  ) adder (.acc_out(out), .acc_in(acc_in), .*);

endmodule

`endif