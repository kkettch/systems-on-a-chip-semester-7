module monitor(
    input clk,
    input rst,
    input [15:0] gpio_led,

    input [15:0] input_matrix_i[9],
    input        input_valid_i,

    output logic [15:0] result_matrix_o[9],
    output logic result_valid
    );

    integer file;
    time start_time, end_time;

    logic [15:0] saved_matrix_a[9];
    logic [15:0] saved_matrix_b[9];
    logic [3:0] temp_idx;
    logic [1:0] state;
    logic [1:0] phase;

    localparam RECIEVE = 0;
    localparam DELAY   = 1;

    initial begin
        file = $fopen("monitor_log.txt", "w");
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            temp_idx <= 0;
            state <= RECIEVE;
            phase <= 0;
            start_time <= $time;
        end
        else begin
            if (input_valid_i) begin
                if (phase == 0) begin
                    saved_matrix_a <= input_matrix_i;
                    $fwrite(file, "\n=== Matrix A captured at %0t ns ===\n", $time);
                    for (int i = 0; i < 9; i++)
                        $fwrite(file, "A[%0d] = %h\n", i, input_matrix_i[i]);
                    phase <= 1;
                end else if (phase == 1) begin
                    saved_matrix_b <= input_matrix_i;
                    $fwrite(file, "\n=== Matrix B captured at %0t ns ===\n", $time);
                    for (int i = 0; i < 9; i++)
                        $fwrite(file, "B[%0d] = %h\n", i, input_matrix_i[i]);
                    phase <= 2;
                end
            end
            if (state == RECIEVE) begin
                if (gpio_led[14]) begin
                    result_matrix_o[temp_idx] <= gpio_led[7:0];
                    $fwrite(file, "Time %0t ns | Result[%0d]=%h\n",
                            $time, temp_idx, gpio_led[7:0]);
                    temp_idx <= temp_idx + 1'b1;
                    state <= DELAY;
                end
            end else begin
                if (!gpio_led[14]) begin
                    state <= RECIEVE;
                end
            end
            if (temp_idx == 9) begin
                result_valid <= 1;
                end_time = $time;
                $fwrite(file, "\n=== Algorithm finished ===\n");
                $fwrite(file, "Execution time: %0t ns\n", end_time - start_time);
                $fclose(file);
            end else begin
                result_valid <= 0;
            end
        end
    end
endmodule
