module stack_tb8;
  parameter DEPTH = 256;
  parameter WIDTH = 8;

  logic clk;
  logic rst_n;
  logic [2:0] opcode;
  logic [WIDTH-1:0] input_data;
  logic [WIDTH-1:0] output_data;
  logic empty;
  logic full;
  logic overflow;

  // Instantiate the stack module
  stack #(
      .DEPTH(DEPTH),
      .WIDTH(WIDTH)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .opcode(opcode),
      .input_data(input_data),
      .output_data(output_data),
      .empty(empty),
      .full(full),
      .overflow(overflow)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    opcode = 3'b000;
    input_data = 0;

    #10 rst_n = 1;

    for (int i = 1; i <= DEPTH; i++) begin
      #10 opcode = 3'b110;
      input_data = i;
    end

    #10 opcode = 3'b110;
    input_data = DEPTH + 1;

    for (int i = 1; i <= DEPTH; i++) begin
      #10 opcode = 3'b111;
    end

    #10 opcode = 3'b111;

    #10 opcode = 3'b110;
    input_data = 8'sh01;
    #10 opcode = 3'b110;
    input_data = -8'sh02;
    #10 opcode = 3'b100;

    #10 opcode = 3'b110;
    input_data = -8'sh03;
    #10 opcode = 3'b110;
    input_data = 8'sh04;
    #10 opcode = 3'b101;

    #10 opcode = 3'b110;
    input_data = 8'sh7F;
    #10 opcode = 3'b110;
    input_data = 8'sh01;
    #10 opcode = 3'b100;

    #10 opcode = 3'b110;
    input_data = -8'sh7F;
    #10 opcode = 3'b110;
    input_data = -8'sh02;
    #10 opcode = 3'b101;

    #10 $finish;
  end

  initial begin
    $monitor("Time=%0t, Opcode=%b, Input=%d, Output=%d, Empty=%b, Full=%b", $time, opcode,
             input_data, output_data, empty, full);
  end

endmodule
