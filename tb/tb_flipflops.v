// FLIP FLOP TESTBENCH

`timescale 1ns/1ps
module tb_flipflops;

    // clock
    reg clk = 0;

    // reset
    reg rst = 1;

    // Inputs
    reg d = 0, t = 0, j = 0, k = 0, s = 0, r = 0;

    // Outputs
    wire q_d, q_t, q_jk, q_sr;

    // Expected Values
    reg e_d = 0, e_t = 0, e_jk = 0, e_sr = 0;

    // Errors
    integer errors = 0, i;

    dff u_d(.clk(clk), .rst(rst), .d(d), .q(q_d));
    tff u_t(.clk(clk), .rst(rst), .t(t), .q(q_t));
    jkff u_jk(.clk(clk), .rst(rst), .j(j), .k(k), .q(q_jk));
    srff u_sr(.clk(clk), .rst(rst), .s(s), .r(r), .q(q_sr));

    always #5 clk = ~clk;

    // Reference Model using Characteristic Equations
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            e_d <= 0;
            e_t <= 0;
            e_jk <= 0;
            e_sr <= 0;
        end else begin
            e_d <= d;
            e_t <= t ^ e_t;
            e_jk <= (j & ~e_jk) | (~k & e_jk);
            e_sr <= s | (~r & e_sr);
        end
    end

    initial begin
        repeat (2) @(negedge clk);
        rst = 0;
        
        for(i = 0 ; i < 300; i = i + 1)begin
            @(negedge clk);

            if( q_d !== e_d)begin
                errors = errors + 1; 
                $display("D ERROR at %0t",$time);
            end
            if( q_t !== e_t)begin
                errors = errors + 1; 
                $display("T ERROR at %0t",$time);
            end
            if( q_jk !== e_jk)begin
                errors = errors + 1; 
                $display("JK ERROR at %0t",$time);
            end
            if( q_sr !== e_sr)begin
                errors = errors + 1; 
                $display("SR ERROR at %0t",$time);
            end

            // RANDOM INPUTS
            d = $random;
            t = $random;
            j = $random;
            k = $random;
            s = $random;
            r = $random;

            // Invalid State s = 1; r = 1;
            if(s & r) r = 0;

            // Reset in middle of Operation
            if(i == 150) begin 
                #2 rst = 1;
                #1 rst = 0;
            end
        end
        
        if (errors == 0) $display("PASS: all flip flops OK");
        else $display("FAIL: %0d errors",errors);

        $finish;
    end

    initial begin
        $dumpfile("FF.vcd");
        $dumpvars(0, tb_flipflops);
    end
endmodule