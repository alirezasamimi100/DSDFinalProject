module stack #(
    parameter DEPTH = 256,
    parameter WIDTH = 32
) (
    input logic clk,
    input logic rst_n,
    input logic [2:0] opcode,
    input logic [WIDTH-1:0] input_data,
    output logic [WIDTH-1:0] output_data,
    output logic overflow,
    output logic empty,
    output logic full
);

  logic [WIDTH-1:0] stack_mem[0:DEPTH-1];
  logic [$clog2(DEPTH):0] top;

  assign empty = (top == 0);
  assign full  = (top == DEPTH);

  logic [WIDTH-1:0] top_element, second_element;
  logic [WIDTH:0] add_result;
  logic [2*WIDTH-1:0] mult_result;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      top <= 0;
      for (int i = 0; i < DEPTH; i++) begin
        stack_mem[i] <= '0;
      end
    end else begin
      if (opcode == 3'b110 && !full) begin
        stack_mem[top] <= input_data;
        top <= top + 1;
      end else if (opcode == 3'b111 && !empty) begin
        top <= top - 1;
      end
    end
  end

  always_comb begin
    top_element = (top > 0) ? stack_mem[top-1] : 0;
    second_element = (top > 1) ? stack_mem[top-2] : 0;

    add_result = {1'b0, top_element} + {1'b0, second_element};
    mult_result = top_element * second_element;
  end

  always_comb begin
    if (opcode == 3'b100 && top > 1) begin
      output_data = add_result;
      overflow = add_result[WIDTH];
    end else if (opcode == 3'b101 && top > 1) begin
      output_data = mult_result;
      overflow = |mult_result[2*WIDTH-1:WIDTH];
    end else begin
      output_data = top_element;
    end
  end
endmodule
