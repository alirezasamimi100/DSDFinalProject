module infix_to_postfix_evaluator_tb;

  logic clk;
  logic rst_n;
  logic start;
  logic [7:0] infix_input[0:255];
  logic ready;
  logic [31:0] result;

  infix_to_postfix_evaluator #(
      .MAXEXPR(256),
      .WIDTH  (32)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .start(start),
      .infix_input(infix_input),
      .ready(ready),
      .result(result)
  );

  initial begin
    clk   = 0;
    rst_n = 0;
    start = 0;
    #10 rst_n = 1;
    infix_input[0:4] = "2 * 4";
    infix_input[5]   = 8'b0;
    #10 start = 1;
    #10 start = 0;
    @(ready);
    #10 rst_n = 0;
    #10 rst_n = 1;
    infix_input[0:16] = "2 * 3 + 5 * 4 + 3";
    infix_input[17]   = 8'b0;
    #10 start = 1;
    #10 start = 0;
    @(ready);
    #10 rst_n = 0;
    #10 rst_n = 1;
    infix_input[0:35] = "2 * 3 + 5 * 4 + 3 + -5 * (1 + 2 + 3)";
    infix_input[36]   = 8'b0;
    #10 start = 1;
    #10 start = 0;
    @(ready);
    #10 rst_n = 0;
    #10 rst_n = 1;
    infix_input[0:35] = "2 * 3 + (10 + 4 + 3) * -20 + (6 + 5)";
    infix_input[36]   = 8'b0;
    #10 start = 1;
    #10 start = 0;
    @(ready);
    #10 $finish;
  end

  always #5 clk = ~clk;

endmodule
