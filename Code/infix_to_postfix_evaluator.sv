module infix_to_postfix_evaluator #(
    parameter MAXEXPR = 256,
    parameter WIDTH   = 32
) (
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [7:0] infix_input[0:MAXEXPR-1],
    output logic ready,
    output logic [WIDTH-1:0] result
);

  typedef enum {
    IDLE,
    PARSE,
    EVAL,
    DONE
  } state_t;
  state_t state, next_state;
  logic [$clog2(MAXEXPR)-1:0] infix_index;
  logic [WIDTH-1:0] num, estack_input, estack_output, ostack_input, ostack_output, temp_num;
  logic is_negative, estack_opcode, ostack_opcode, estack_empty, ostack_empty, reading_number;
  logic [1:0] evalcnt;

  stack #(
      .DEPTH(MAXEXPR),
      .WIDTH(WIDTH)
  ) eval_stack (
      .clk(clk),
      .rst_n(rst_n),
      .opcode(estack_opcode),
      .input_data(estack_input),
      .output_data(estack_output),
      .overflow(0),
      .empty(estack_empty),
      .full(0)
  );
  stack #(
      .DEPTH(MAXEXPR),
      .WIDTH(8)
  ) opr_stack (
      .clk(clk),
      .rst_n(rst_n),
      .opcode(ostack_opcode),
      .input_data(ostack_input),
      .output_data(ostack_output),
      .overflow(0),
      .empty(ostack_empty),
      .full(0)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin
    next_state = state;
    case (state)
      IDLE: if (start) next_state = PARSE;
      PARSE: begin
        if (evalcnt) next_state = EVAL;
        else if (infix_input[infix_index] == 0 && ostack_empty) next_state = DONE;
      end
      EVAL: if (!evalcnt) next_state = PARSE;
      DONE: next_state = IDLE;
    endcase
  end

  always_ff @(posedge clk) begin
    case (state)
      IDLE: begin
        infix_index <= 0;
        ready <= 0;
        is_negative <= 0;
        num <= 0;
        ostack_opcode <= 0;
        estack_opcode <= 0;
        evalcnt <= 0;
      end

      PARSE: begin
        ostack_opcode <= 0;
        estack_opcode <= 0;
        if ((infix_input[infix_index] < "0" || infix_input[infix_index] > "9") && reading_number) begin
          if (is_negative) begin
            num <= -num;
            is_negative <= 0;
          end
          estack_input <= num;
          estack_opcode <= 3'b110;
          reading_number <= 0;
          num <= 0;
        end else begin
          case (infix_input[infix_index])
            "+", "*": begin
              if (!ostack_empty && ostack_output != "(" &&
                    ((infix_input[infix_index] == "+" && ostack_output == "*") ||
                    (infix_input[infix_index] == ostack_output))) begin
                evalcnt <= 1;
                estack_opcode <= ostack_output == "+" ? 3'b100 : 3'b101;
                ostack_opcode <= 3'b111;
              end else begin
                ostack_input  <= infix_input[infix_index];
                ostack_opcode <= 3'b110;
                infix_index   <= infix_index + 1;
              end
            end
            "(": begin
              ostack_input  <= infix_input[infix_index];
              ostack_opcode <= 3'b110;
              infix_index   <= infix_index + 1;
            end
            ")": begin
              if (!ostack_empty && ostack_output != "(") begin
                evalcnt <= 1;
                estack_opcode <= ostack_output == "+" ? 3'b100 : 3'b101;
                ostack_opcode <= 3'b111;
              end else if (!ostack_empty > 0 && ostack_output == "(") begin
                ostack_opcode <= 3'b111;
                infix_index   <= infix_index + 1;
              end
            end
            "-": begin
              is_negative <= 1;
              infix_index <= infix_index + 1;
            end
            0: begin
              if (!ostack_empty) begin
                evalcnt <= 1;
                estack_opcode <= ostack_output == "+" ? 3'b100 : 3'b101;
                ostack_opcode <= 3'b111;
              end
            end
            default: begin  // Number
              reading_number <= 1;
              if (infix_input[infix_index] >= "0" && infix_input[infix_index] <= "9") begin
                num = num * 10 + (infix_input[infix_index] - "0");
                infix_index <= infix_index + 1;
              end
            end
          endcase
        end
      end

      EVAL: begin
        case (evalcnt)
          1: begin
            temp_num <= estack_output;
            estack_opcode <= 3'b111;
            evalcnt <= 2;
          end
          2: begin
            estack_opcode <= 3'b111;
            evalcnt <= 3;
          end
          3: begin
            estack_input <= temp_num;
            estack_opcode <= 3'b101;
            evalcnt <= 0;
          end
        endcase
      end

      DONE: begin
        result <= estack_output;
        ready  <= 1;
      end
    endcase
  end

endmodule
