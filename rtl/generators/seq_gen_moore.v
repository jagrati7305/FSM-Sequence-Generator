// Generate 1011 sequence
// enable input - en. When en = 0 the FSM hold its state so the output holds state also
module seq_gen_moore (
    input clk,rst,en,
    output reg out
);
    localparam S0 = 2'd0;
    localparam S1 = 2'd1;
    localparam S2 = 2'd2;
    localparam S3 = 2'd3;

    reg [1:0] state, next_state;

    // 1. State Register
    always @(posedge clk or posedge rst) begin
        if(rst) state <= S0;
        else state <= next_state;
    end

    // 2. Next-State Logic
    always @(*) begin
        next_state = state;
        if(en) begin
            case(state)
                S0: next_state = S1;
                S1: next_state = S2;
                S2: next_state = S3;
                S3: next_state = S0;
                default: next_state = S0;
            endcase         
        end
    end

    // 3. Output Logic
    always @(*) begin
        case (state)
            S0: out = 1'b1;
            S1: out = 1'b0;
            S2: out = 1'b1;
            S3: out = 1'b1;
            default: out = 1'b0;
        endcase
    end
    
endmodule