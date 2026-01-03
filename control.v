module control_path #(
    parameter WIDTH = 8
) (
    input  clk,
    input  reset,         // asynchronous reset (active low)
    input  start,         // initiate multiplication
    input  q0,            // LSB of Q (current multiplier bit)
    input  q_minus,       // Q-1 bit (previous multiplier bit)
    input  cnt_zero,      // counter has reached zero
    
    // control signals to datapath
    output reg ld_all,    // load A, Q, counter, M registers
    output reg add_sub,   // 0=add, 1=subtract
    output reg shift,     // perform arithmetic right shift
    output reg dec_cnt 
);
    
    // FSM State Definition
    localparam [2:0] 
        S0_IDLE   = 3'b000,
        S1_LOAD   = 3'b001,
        S2_DECODE = 3'b010,
        S3_ADD    = 3'b011,
        S4_SUB    = 3'b100,
        S5_SHIFT  = 3'b101,
        S6_DONE   = 3'b110;

    reg [2:0] current_state, next_state;
    
    // State Register
    always @(posedge clk or negedge reset) begin
        if (~reset)
            current_state <= S0_IDLE;
        else
            current_state <= next_state;
    end
    
    // Next State Logic and Output Logic
    always @(*) begin
        // Default outputs
        ld_all    = 1'b0;
        add_sub   = 1'b0;
        shift     = 1'b0;
        dec_cnt   = 1'b0;
        next_state = current_state;
        
        case (current_state)
            S0_IDLE: begin
                if (start)
                    next_state = S1_LOAD;
            end
            
            S1_LOAD: begin
                ld_all = 1'b1;
                next_state = S2_DECODE;
            end
            
            S2_DECODE: begin
                if (cnt_zero) begin
                    next_state = S6_DONE;
                end else begin
                    case ({q0, q_minus})
                        2'b01: next_state = S3_ADD;      // Add
                        2'b10: next_state = S4_SUB;      // Subtract
                        default: next_state = S5_SHIFT;  // No operation
                    endcase
                end
            end
            
            S3_ADD: begin
                ld_all = 1'b1;
                add_sub = 1'b0;  // Add
                next_state = S5_SHIFT;
            end
            
            S4_SUB: begin
                ld_all = 1'b1;
                add_sub = 1'b1;  // Subtract
                next_state = S5_SHIFT;
            end
            
            S5_SHIFT: begin
                shift = 1'b1;
                dec_cnt = 1'b1;
                next_state = S2_DECODE;
            end
            
            S6_DONE: begin
                if (start)
                    next_state = S1_LOAD;
                else
                    next_state = S0_IDLE;
            end
            
            default: next_state = S0_IDLE;
        endcase
    end
    
endmodule