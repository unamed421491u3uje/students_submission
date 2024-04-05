`ifndef __mac_fp4_e2m1_bnb_V__
`define __mac_fp4_e2m1_bnb_V__

`include "signMagnitude_to_2sComplement.v"
`include "accumulator.v"

// fp4 with 2-bit exponent and 1-bit mantissa

interface FpNumberUnpacked #(
  parameter EXP_WIDTH = 2,
  parameter MAN_WIDTH = 1
);
  typedef struct packed {
    logic                  sign;
    logic [EXP_WIDTH-1:0]  exp;
    logic [MAN_WIDTH-1:0]  man;
  } DATA_TYPE;

  DATA_TYPE data;
  modport InputIf(input data);
endinterface

(* multstyle = "logic" *)
module mac_fp4_e2m1_bnb
# (
  parameter EXP_WIDTH  = 2,
  parameter MAN_WIDTH  = 1,
  parameter ACC_WIDTH  = 23
) (
  input   logic                        clk,
  input   logic                        reset,
  input   logic                        en,

  FpNumberUnpacked.InputIf             weight,
  FpNumberUnpacked.InputIf             act,
  output  logic signed [ACC_WIDTH-1:0] out
);
  parameter FRAC_WIDTH = MAN_WIDTH + 4;
  parameter PROD_WIDTH = 2*FRAC_WIDTH + 2**EXP_WIDTH + 2;

  FpNumberUnpacked #(EXP_WIDTH, MAN_WIDTH) x_1(), x_2();

  logic [EXP_WIDTH:0]       sum_exp;
  logic [2*FRAC_WIDTH-1:0]  prod_man;
  logic                     prod_sign;
  logic [FRAC_WIDTH-1:0]    x_1_frac, x_2_frac;
  logic [EXP_WIDTH-1:0]     x_1_exp,  x_2_exp;
  logic                     x_1_sign, x_2_sign;

  always_comb begin
    x_1_exp  = x_1.data.exp;
    x_1_sign = x_1.data.sign;
    if ( x_1.data.exp == 0 ) begin
      x_1_frac = 5'd1;
    end else begin
      x_1_frac = {1'b1, x_1.data.man, 3'd0};
      x_1_exp  = x_1.data.exp;
    end
  end

  always_comb begin
    x_2_exp  = x_2.data.exp;
    x_2_sign = x_2.data.sign;
    if ( x_2.data.exp == 0 ) begin
      x_2_frac = 5'd1;
    end else begin
      x_2_frac = {1'b1, x_2.data.man, 3'd0};
      x_2_exp  = x_2.data.exp;
    end
  end

  assign prod_sign = x_1_sign ^ x_2_sign;
  assign sum_exp   = x_1_exp + x_2_exp;
  assign prod_man  = x_1_frac * x_2_frac;

  logic [PROD_WIDTH-1:0] prod_magnitude; 
  assign prod_magnitude = prod_man << sum_exp;

  logic [PROD_WIDTH:0] signed_product, acc_in; 
  assign signed_product = {prod_sign, prod_magnitude};

  signMagnitude_to_2sComplement #(PROD_WIDTH+1) convert (.in(signed_product), .out(acc_in));

  always_ff @(posedge clk) begin
    if (reset) begin
      x_1.data <= 0;
      x_2.data <= 0;
    end else if (en) begin
      x_1.data <= weight.data;
      x_2.data <= act.data;
    end
  end

  accumulator #(
    .ACC_WIDTH (ACC_WIDTH),
    .IN_WIDTH  (PROD_WIDTH+1),
    .IS_SIGNED (1'b1)
  ) adder (.acc_out(out), .*);

endmodule

`endif