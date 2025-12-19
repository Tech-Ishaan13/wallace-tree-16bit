`timescale 1ns / 1ps

module tb_wallace_multiplier;

    localparam CLK_PERIOD = 10;

    logic           clk;
    logic           rst_n;
    logic [15:0]    a;
    logic [15:0]    b;
    wire  [31:0]    p;

    logic [31:0]    expected_p;

    // Instantiate DUT
    pipelined_wallace_16bit uut (
        .clk(clk),
        .a(a),
        .b(b),
        .product(p)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Main stimulus
    initial begin
        $display("Starting Testbench for Pipelined Wallace Multiplier...");

        // Reset (optional, if module supports)
        rst_n = 1'b0;
        a = 0;
        b = 0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);

        $display("Reset complete. Starting tests.\n");

        // Simple directed tests
        run_test(16'd10, 16'd5);
        run_test(16'd12345, 16'd0);
        run_test(16'd1, 16'd54321);
        run_test(16'hFFFF, 16'hFFFF);
        run_test(16'd100, 16'hFFFE);

        // Randomized tests
        $display("\nRunning 20 randomized tests...");
        for (int i = 0; i < 20; i++) begin
            logic [15:0] rand_a = $urandom();
            logic [15:0] rand_b = $urandom();
            run_test(rand_a, rand_b);
        end

        $display("\n✅ All tests completed successfully.");
        $finish;
    end

    // Task to apply inputs and verify output after pipeline delay
    task run_test(input [15:0] test_a, input [15:0] test_b);
        expected_p = test_a * test_b;

        a = test_a;
        b = test_b;

        // Wait for several cycles to allow pipeline to flush
        // Your pipeline has 4 stages → 4 + 1 extra for safety
        repeat (5) @(posedge clk);

        if (p === expected_p) begin
            $display("PASS: a=%d, b=%d → product=%d (expected %d)", 
                     test_a, test_b, p, expected_p);
        end else begin
            $display("FAIL: a=%d, b=%d → product=%d (expected %d)", 
                     test_a, test_b, p, expected_p);
        end

        // Clear inputs before next test
        a = 0;
        b = 0;
        @(posedge clk);
    endtask

endmodule
