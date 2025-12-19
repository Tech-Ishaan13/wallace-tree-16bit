// =======================================================
// 32-bit Brent-Kung Adder
// Parallel-prefix adder with O(log N) carry delay
// Vivado-compatible syntax
// =======================================================
module brent_kung_32bit (
    input  [31:0] x, y,
    input         cin,
    output [31:0] sum,
    output        cout
);
    wire [31:0] g, p;
    wire [31:0] c;

    assign g = x & y;
    assign p = x ^ y;

    // Prefix tree stage signals
    wire [31:0] G_stage[5:0];
    wire [31:0] P_stage[5:0];

    assign G_stage[0] = g;
    assign P_stage[0] = p;

    // =======================================================
    // Generate block for Brent-Kung prefix computation
    // =======================================================
    genvar i, k;
    generate
        for (i = 0; i < 5; i = i + 1) begin : prefix_level
            for (k = 0; k < 32; k = k + 1) begin : prefix_cell
                if (k < (1 << i)) begin
                    assign G_stage[i+1][k] = G_stage[i][k];
                    assign P_stage[i+1][k] = P_stage[i][k];
                end else begin
                    assign G_stage[i+1][k] = G_stage[i][k] |
                                             (P_stage[i][k] & G_stage[i][k-(1<<i)]);
                    assign P_stage[i+1][k] = P_stage[i][k] &
                                             P_stage[i][k-(1<<i)];
                end
            end
        end
    endgenerate

    // =======================================================
    // Carry generation and final sum computation
    // =======================================================
    assign c[0] = cin;
    genvar j;
    generate
        for (j = 1; j < 32; j = j + 1) begin : carry_gen
            assign c[j] = G_stage[5][j-1] | (P_stage[5][j-1] & cin);
        end
    endgenerate

    assign sum  = p ^ c;
    assign cout = G_stage[5][31] | (P_stage[5][31] & cin);

endmodule

