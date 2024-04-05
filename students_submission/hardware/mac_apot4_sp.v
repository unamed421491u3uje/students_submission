`ifndef __mac_apot4_sp_V__
`define __mac_apot4_sp_V__

`include "signMagnitude_to_2sComplement.v"
`include "accumulator.v"

(* multstyle = "logic" *)
module mac_apot4_sp
# (
  parameter T1_WIDTH  = 2,
  parameter T2_WIDTH  = 1,
  parameter ACC_WIDTH  = 16
) (
  input   logic                        clk,
  input   logic                        reset,
  input   logic                        en,

  input   logic [3:0]                  weight,
  input   logic [3:0]                  act,
  output  logic signed [ACC_WIDTH-1:0] out
);
  parameter PROD_WIDTH = 8;

  logic [3:0] a, b;
  logic a_sign, b_sign, prod_sign;

  always_comb begin
    if ( a == 4'b1000 ) begin
      a_sign = 1'b0;
    end else begin
      a_sign = a[3];
    end

    if ( b == 4'b1000 ) begin
      b_sign = 1'b0;
    end else begin
      b_sign = a[3];
    end
  end

  assign prod_sign = a_sign ^ b_sign;

  // decoded weight and activation
  logic [3:0] a_dec_term;
  logic [3:0] b_dec_term;

  always_comb begin
    a_dec_term = 0;

    if ( a == 4'b1000 ) begin 
      a_dec_term = 4'b0101;
    end else begin
      case (a[2:1])
        2'b00:   a_dec_term = 4'b0000;
        2'b01:   a_dec_term = 4'b1000;
        2'b10:   a_dec_term = 4'b0100;
        2'b11:   a_dec_term = 4'b0001;
        default: a_dec_term = 4'bxxxx;
      endcase

      if ( a[0] == 1'b1 ) begin
        a_dec_term[1] = 1'b1;
      end else begin
        a_dec_term[1] = 1'b0;
      end
    end
  end

  always_comb begin
    b_dec_term = 0;

    if ( b == 4'b1000 ) begin 
      b_dec_term = 4'b0101;
    end else begin
      case (b[2:1])
        2'b00:   b_dec_term = 4'b0000;
        2'b01:   b_dec_term = 4'b1000;
        2'b10:   b_dec_term = 4'b0100;
        2'b11:   b_dec_term = 4'b0001;
        default: b_dec_term = 4'bxxxx;
      endcase

      if ( b[0] == 1'b1 ) begin
        b_dec_term[1] = 1'b1;
      end else begin
        b_dec_term[1] = 1'b0;
      end
    end
  end

  logic [PROD_WIDTH-1:0] prod_magnitude; 
  assign prod_magnitude = a_dec_term * b_dec_term;

  logic [PROD_WIDTH:0] signed_product, acc_in; 
  assign signed_product = {prod_sign, prod_magnitude};

  signMagnitude_to_2sComplement #(PROD_WIDTH+1) convert (.in(signed_product), .out(acc_in));

  always_ff @(posedge clk) begin
    if (reset) begin
        a  <= 0;
        b  <= 0;
    end else if (en) begin
        a  <= act;
        b  <= weight;
    end
  end

  accumulator #(
    .ACC_WIDTH (ACC_WIDTH),
    .IN_WIDTH  (PROD_WIDTH+1),
    .IS_SIGNED (1'b1)
  ) adder (.acc_out(out), .*);

endmodule

`endif