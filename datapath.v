module booth_datapath #(
    parameter WIDTH = 8
)(
    input  clk,
    input  start,
    input  signed [WIDTH-1:0] multiplicand, // M
    input  signed [WIDTH-1:0] multiplier,   // Q
    // control signals from FSM
    input  ld_all,        // load A,Q and counter
    input  add_sub,       // 0=add, 1=sub (applies to accumulator A with M)
    input  shift,         // perform arithmetic right shift on {A,Q,Q-1}
    input  dec_cnt,       // decrement counter
    // status outputs to FSM
    output q0,            // current LSB of Q
    output q_minus,       // Q-1 bit
    output cnt_zero,      // counter is zero
    output done,
    // final product output (2*WIDTH bits)
    output reg signed [2*WIDTH-1:0] product
);
    
    // internal signals / registers
    reg [WIDTH-1:0] A, Q;
    reg q_minus_reg;
    wire [WIDTH-1:0] M;
    wire [WIDTH-1:0] addsub_out;
    reg [WIDTH-1:0] counter;
    
    assign M = multiplicand;
    
    // Initialize counter with a WIDTH-sized constant
    localparam [WIDTH-1:0] CNT_INIT = WIDTH;
    
    // M register - stores multiplicand
    always @(posedge clk) begin
        if (ld_all) begin
            // M is combinational, no need to store
        end
    end
    
    // A register (Accumulator)
    always @(posedge clk) begin
        if (ld_all) begin
            if (start) begin
                A <= {WIDTH{1'b0}};  // Initialize with 0 on start
            end else begin
                A <= addsub_out;     // Load add/sub result
            end
        end else if (shift) begin
            // Shift is handled in separate logic
        end
    end
    
    // Q register (Multiplier)
    always @(posedge clk) begin
        if (ld_all && start) begin
            Q <= multiplier;        // Load multiplier on start
        end else if (shift) begin
            // Shift is handled in separate logic
        end
    end
    
    // Q-1 bit register
    always @(posedge clk) begin
        if (ld_all && start) begin
            q_minus_reg <= 1'b0;    // Initialize with 0 on start
        end else if (shift) begin
            // Shift is handled in separate logic
        end
    end
    
    // Adder/Subtractor
    assign addsub_out = add_sub ? (A - M) : (A + M);
    
    // Counter
    always @(posedge clk) begin
        if (ld_all && start) begin
            counter <= CNT_INIT;
        end else if (dec_cnt) begin
            counter <= counter - 1;
        end
    end
    
    // Shift logic
    always @(posedge clk) begin
        if (shift) begin
            // Perform arithmetic right shift on {A, Q, q_minus_reg}
            {A, Q, q_minus_reg} <= {A[WIDTH-1], A[WIDTH-1:0], Q, q_minus_reg} >> 1;
        end
    end
    
    // Output assignments
    assign q0 = Q[0];
    assign q_minus = q_minus_reg;
    assign cnt_zero = (counter == 0);
    assign done = cnt_zero;
    
    // Product output
    always @(posedge clk) begin
        if (cnt_zero) begin
            product <= {A, Q};
        end
    end
    
endmodule

// Simplified PIPO modules (you can keep your original ones if needed)
module PIPO #(parameter WIDTH = 8)(
    input clk,
    input ld,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);
    always @(posedge clk) begin
        if (ld) dout <= din;
    end
endmodule

module ADD_SUB #(parameter WIDTH = 8)(
    output [WIDTH-1:0] out,
    input  [WIDTH-1:0] in1,
    input  [WIDTH-1:0] in2,
    input  sub
);
    assign out = sub ? (in1 - in2) : (in1 + in2);
endmodule

module COUNT_BOOTH #(parameter WIDTH=8)(
    output reg [WIDTH-1:0] dout,
    input  [WIDTH-1:0] din,
    input  ld,
    input  dec,
    input  clk,
    output zero
);
    always @(posedge clk) begin
        if (ld) dout <= din;
        else if (dec) dout <= dout - 1;
    end
    assign zero = (dout == 0);
endmodule