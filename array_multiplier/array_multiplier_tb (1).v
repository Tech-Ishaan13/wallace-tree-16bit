`timescale 1ns/1ps

module tb_array_multiplier_16bit();

    reg  [15:0] a, b;
    wire [31:0] product;
    
    integer i, errors;

    // Instantiate DUT
    array_multiplier_16bit dut (
        .a(a),
        .b(b),
        .product(product)
    );

    task run_test(input [15:0] A, input [15:0] B);
        reg [31:0] expected;
        begin
            a = A;
            b = B;
            #1;   // allow combinational settle

            expected = A * B;

            if (product === expected) begin
                $display("TEST PASSED | a=%d b=%d | product=%d", A, B, product);
            end else begin
                $display("TEST FAILED | a=%d b=%d | expected=%d got=%d",
                         A, B, expected, product);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        $display("==============================================");
        $display("       STARTING ARRAY MULTIPLIER TESTS       ");
        $display("==============================================");

        // Basic tests
        run_test(0, 0);
        run_test(1, 1);
        run_test(5, 10);
        run_test(15, 15);
        run_test(100, 50);

        // Edge cases
        run_test(16'hFFFF, 16'h0001);
        run_test(16'hFFFF, 16'hFFFF);
        run_test(0, 16'hABCD);
        run_test(16'h8000, 2);

        // Random tests
        for (i = 0; i < 20; i = i + 1) begin
            run_test($random, $random);
        end

        $display("==============================================");
        if (errors == 0)
            $display(" ALL TESTS PASSED SUCCESSFULLY 🎉🎉");
        else
            $display(" TOTAL FAILED TESTS = %d ❌", errors);
        $display("==============================================");

        $finish;
    end

endmodule
