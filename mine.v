// =======================================================
// 16-bit Pipelined Wallace Tree Multiplier
// with Brent-Kung Adder as final stage
// -------------------------------------------------------
// Latency: 4 cycles
// Throughput: 1 result per clock (after pipeline fills)
// =======================================================
module pipelined_wallace_16bit (
    input  wire        clk,
    input  wire [15:0] a, b,
    output reg  [31:0] product
);

    // -------------------------------------------------------
    // Stage 1: Partial Product Generation
    // -------------------------------------------------------
    reg [31:0] pp[15:0];
    integer i;
    always @(posedge clk) begin
        for (i = 0; i < 16; i = i + 1)
            pp[i] <= b[i] ? (a << i) : 32'b0;
    end

    // -------------------------------------------------------
    // Stage 2: First Reduction Layer (Add pairs of PP)
    // -------------------------------------------------------
    reg [31:0] sum_stage2 [7:0];
    reg [31:0] carry_stage2 [7:0];
    integer j;
    always @(posedge clk) begin
        for (j = 0; j < 8; j = j + 1) begin
            {carry_stage2[j], sum_stage2[j]} <= pp[2*j] + pp[2*j+1];
        end
    end

    // -------------------------------------------------------
    // Stage 3: Second Reduction Layer
    // -------------------------------------------------------
    reg [31:0] sum_stage3 [3:0];
    reg [31:0] carry_stage3 [3:0];
    always @(posedge clk) begin
        for (j = 0; j < 4; j = j + 1) begin
            {carry_stage3[j], sum_stage3[j]} <= sum_stage2[2*j] + sum_stage2[2*j+1]
                                               + (carry_stage2[2*j] << 1);
        end
    end

    // -------------------------------------------------------
    // Stage 4: Final Addition using Brent-Kung Adder
    // -------------------------------------------------------
    wire [31:0] x_final, y_final, final_sum;
    wire final_cout;

    assign x_final = sum_stage3[0] + (carry_stage3[0] << 1)
                   + sum_stage3[1] + (carry_stage3[1] << 1);

    assign y_final = sum_stage3[2] + (carry_stage3[2] << 1)
                   + sum_stage3[3] + (carry_stage3[3] << 1);

     brent_kung_32bit bka (
    .x(x_final),
    .y(y_final),
    .cin(1'b0),
    .sum(final_sum),
    .cout(final_cout)
);


    // Output Register
    always @(posedge clk)
        product <= final_sum;

endmodule
