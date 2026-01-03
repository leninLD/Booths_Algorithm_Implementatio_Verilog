`timescale 1ns/1ps
module tb;
    parameter WIDTH = 8;

    // Clock / control
    reg clk = 0;
    reg start = 0;
    reg reset = 0;

    // Inputs to datapath
    reg signed [WIDTH-1:0] multiplicand;
    reg signed [WIDTH-1:0] multiplier;

    // Wires between control and datapath
    wire ld_all, add_sub, shift, dec_cnt;
    wire q0, q_minus, cnt_zero;

    // Done / product
    wire done;
    wire signed [2*WIDTH-1:0] product;

    // Instantiate datapath
    booth_datapath #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .ld_all(ld_all),
        .add_sub(add_sub),
        .shift(shift),
        .dec_cnt(dec_cnt),
        .q0(q0),
        .q_minus(q_minus),
        .cnt_zero(cnt_zero),
        .done(done),
        .product(product)
    );

    // Instantiate control
    control_path #(.WIDTH(WIDTH)) ctrl (
        .clk(clk),
        .reset(reset),
        .start(start),
        .q0(q0),
        .q_minus(q_minus),
        .cnt_zero(cnt_zero),
        .ld_all(ld_all),
        .add_sub(add_sub),
        .shift(shift),
        .dec_cnt(dec_cnt)
    );

    // Clock generator
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // VCD dump for GTKWave
        $dumpfile("test.vcd");
        $dumpvars(0, tb.dut, tb.ctrl);

        // Initialize signals
        reset = 0;  // Assert reset (active low)
        start = 0;
        multiplicand = 0;
        multiplier = 0;

        // Release reset after two clock cycles
        #20; reset = 1;  // Deassert reset
        #10;

        // Test: 5 * 3
        multiplicand = 5;
        multiplier   = 3;
        #10; // wait a cycle
        start = 1; // assert start for two cycles so initial load samples start==1
        #20; start = 0;
        // Wait for datapath to assert done
        @(posedge done);
        @(posedge clk); #1;
        $display("Done: %0d * %0d = %0d (expected %0d)", multiplicand, multiplier, $signed(product), multiplicand*multiplier);

        // Wait longer between tests
        #100;
        
        // Test: -5 * 3
        multiplicand = -5;
        multiplier   = 3;
        #10;
        start = 1;
        #20; start = 0;
        @(posedge done);
        @(posedge clk); #1;
        $display("Done: %0d * %0d = %0d (expected %0d)", multiplicand, multiplier, $signed(product), multiplicand*multiplier);
        
        // Wait much longer at the end before finishing
        #500;
        $dumpflush;  // Add this to flush VCD data
        $finish;
    end

endmodule