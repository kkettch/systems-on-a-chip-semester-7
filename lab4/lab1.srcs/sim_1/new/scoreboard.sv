`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2025 14:31:11
// Design Name: 
// Module Name: scoreboard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module scoreboard#(
    parameter int SIZE = 64,
    parameter int ROW = 8
)(
    input  logic        clk_i,
    input  logic        rst_i,
    input  logic [14:0] matrix_input [SIZE],
    input  logic        matrix_vld,
    input  logic [14:0] result_matrix [SIZE],
    input  logic        result_vld,
    output logic [14:0] expected_matrix[SIZE],
    output logic        test_done
);

    typedef enum logic [1:0] {
        WAIT_A      = 2'd0,
        WAIT_B      = 2'd1,
        WAIT_RESULT = 2'd2,
        CHECK       = 2'd3
    } state_t;

    state_t state;

    logic [14:0] matrix_a [SIZE];
    logic [14:0] matrix_b [SIZE];
    logic [14:0] product_matrix [SIZE];   

    int i, j, k;
    int errors;
    int sum;
    
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state <= WAIT_A;
            errors <= 0;
            test_done <= 1'b0;

            for (i = 0; i < SIZE; i++) begin
                matrix_a[i]       <= '0;
                matrix_b[i]       <= '0;
                product_matrix[i] <= '0;
            end
        end
        else begin
            case (state)
                WAIT_A: begin
                    if (matrix_vld) begin
                        for (i = 0; i < SIZE; i++)
                            matrix_a[i] <= matrix_input[i];
                        state <= WAIT_B;
                    end
                end
                WAIT_B: begin
                    if (matrix_vld) begin
                        for (i = 0; i < SIZE; i++)
                            matrix_b[i] <= matrix_input[i];
                        state <= WAIT_RESULT;
                    end
                end
                WAIT_RESULT: begin
                    for (i = 0; i < ROW; i++) begin
                        for (j = 0; j < ROW; j++) begin
                            sum = 0;
                            for (k = 0; k < ROW; k++) begin
                                sum += matrix_a[i*ROW + k] * matrix_b[k*ROW + j];
                            end
                            product_matrix[i*ROW + j] = (sum - matrix_b[i*ROW + j]) & 15'h1FFF;
                        end
                    end
                    for (i = 0; i < SIZE; i++) begin
                        expected_matrix[i] = product_matrix[i];
                    end
                    if (result_vld)
                        state <= CHECK;
                end
                CHECK: begin
                    errors = 0;
                    for (i = 0; i < SIZE; i++) begin
                        if (product_matrix[i] !== result_matrix[i]) begin
                            $display("Mismatch [%0d]: expected=%0h, got=%0h",
                                     i, product_matrix[i], result_matrix[i]);
                            errors++;
                        end else begin
                            $display("Match [%0d]: %0h", i, result_matrix[i]);
                        end
                    end
                    if (errors == 0)
                        $display("RESULT CORRECT: (A*B - B) mod 16 bits");
                    else
                        $display("Total mismatches: %0d", errors);
                    test_done <= 1'b1;
//                    $finish;
                end
            endcase
        end
    end
endmodule
