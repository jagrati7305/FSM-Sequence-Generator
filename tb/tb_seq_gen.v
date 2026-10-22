module tb_seq_gen;
    reg clk = 0;
    reg rst = 1;
    reg en = 0;

    wire out;
    integer errors = 0,i;

    // DUT
    seq_gen_moore moore_dut(.clk(clk),.rst(rst),.en(en),.out(out));

    // CLOCK
    always #5 clk = ~clk;

    // Reference Model
    reg [3:0] pattern = 4'b1011;
    reg [1:0] idx = 0;

    always @(posedge clk) begin
        if(rst) idx <= 0;
        else if(en) idx <= idx + 1; // 2 bit counter wraps 3 -> 0 
    end
    wire expected = pattern[3-idx];

    // Checker Task
    task check;
        begin
            if(out != expected) begin
                errors = errors + 1;
                $display("ERROR at %0t; out = %b expected = %b (idx = %0d, en=%b)",$time,out,expected,idx,en);
            end
        end
    endtask

    // Stimulus - Drive the inputs
    initial begin
        
        repeat(2) @(negedge clk);
        check;
        rst = 0;

        en = 1; // en held high for 12 cycles (3 full pattern)
        for(i=0;i<12;i = i+1)begin
            @(negedge clk);
            check;
        end

        en = 0;
        for(i=0;i<6;i = i+1)begin
            @(negedge clk);
            check;
        end

        for (i = 0; i < 300; i = i + 1) begin
            en = ($random % 4) != 0;      // enabled about 75% of the time
            if (i == 150) rst = 1;        // reset in the middle
            if (i == 153) rst = 0;
            @(negedge clk);
            check;
        end

        if (errors == 0) $display("PASS: seq_gen_moore all checks OK");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end

    initial begin
        $dumpfile("seq_gen.vcd");
        $dumpvars(0, tb_seq_gen);
    end
    
endmodule