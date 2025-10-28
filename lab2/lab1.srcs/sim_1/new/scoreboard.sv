`timescale 1ns / 1ps

module scoreboard(
    input  logic        clk_i,
    input  logic        rst_i,
    input  logic [15:0] matrix_input [9],
    input  logic        matrix_vld,
    input  logic [15:0] result_matrix [9],
    input  logic        result_vld
);

    // Состояния автомата
    typedef enum logic [1:0] {
        WAIT_A      = 2'd0,
        WAIT_B      = 2'd1,
        WAIT_RESULT = 2'd2,
        CHECK       = 2'd3
    } state_t;

    state_t state;

    // Храним матрицы A и B
    logic [15:0] matrix_a [9];
    logic [15:0] matrix_b [9];
    logic [31:0] product_matrix [9];

    // Переменные для внутреннего подсчёта
    integer i, j, k;
    integer sum;
    integer errors;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state <= WAIT_A;
            for (i = 0; i < 9; i++) begin
                matrix_a[i] <= '0;
                matrix_b[i] <= '0;
                product_matrix[i] <= '0;
            end
        end
        else begin
            case (state)
                WAIT_A: begin
                    if (matrix_vld) begin
                        matrix_a <= matrix_input;
                        state <= WAIT_B;
                    end
                end

                WAIT_B: begin
                    if (matrix_vld) begin
                        matrix_b <= matrix_input;
                        state <= WAIT_RESULT;
                    end
                end

                WAIT_RESULT: begin
                    if (result_vld)
                        state <= CHECK;
                end

                CHECK: begin
                    errors = 0;

                    // ---- Вычисляем A*B - B ----
                    for (i = 0; i < 3; i++) begin
                        for (j = 0; j < 3; j++) begin
                            sum = 0;
                            for (k = 0; k < 3; k++) begin
                                sum += matrix_a[i*3 + k] * matrix_b[k*3 + j];
                            end
                            product_matrix[i*3 + j] = sum - matrix_b[i*3 + j];
                        end
                    end

                    // ---- Проверяем ----
                    for (i = 0; i < 9; i++) begin
                        if (product_matrix[i][15:0] !== result_matrix[i]) begin
                            $display("? Incorrect result at index %0d: expected=%0h, got=%0h",
                                     i, product_matrix[i][15:0], result_matrix[i]);
                            errors++;
                        end
                    end

                    if (errors == 0)
                        $display("? RESULT CORRECT (A*B - B = result)");
                    else
                        $display("?? Total mismatches: %0d", errors);

                    $finish;
                end
            endcase
        end
    end
endmodule
