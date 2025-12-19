`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: -
// Engineer: (Your Name)
// 
// Create Date: 12.11.2025
// Design Name: 16-bit Array Multiplier
// Module Name: array_multiplier_16bit
// Description: Simple combinational 16x16 array multiplier (baseline design)
//
// Dependencies: None
//
//////////////////////////////////////////////////////////////////////////////////

module array_multiplier_16bit(
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [31:0] product
);

    // Generate partial products
    wire [15:0] pp [15:0];
    genvar i, j;

    // Each bit of b generates a partial product
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_partial
            for (j = 0; j < 16; j = j + 1) begin : gen_bit
                assign pp[i][j] = a[j] & b[i];
            end
        end
    endgenerate

    // Combine partial products (simple ripple addition)
    wire [31:0] temp_sum [15:0];
    assign temp_sum[0] = {16'b0, pp[0]};

    generate
        for (i = 1; i < 16; i = i + 1) begin : add_stage
            assign temp_sum[i] = temp_sum[i-1] + ({ {15-i{1'b0}}, pp[i], {i{1'b0}} });
        end
    endgenerate

    assign product = temp_sum[15];

endmodule
