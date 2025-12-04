`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2025 14:15:36
// Design Name: 
// Module Name: sequencer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   
//////////////////////////////////////////////////////////////////////////////////

module sequencer#(
    parameter int SIZE = 64
)(
    input  logic clk_i,
    input  logic rst_i,
    output logic [14:0] sequence_o[SIZE],   
    output logic sequence_valid_o,
    input  logic sequence_send_i
);

    localparam int SEND_A = 0;
    localparam int WAIT   = 1;
    localparam int SEND_B = 2;
    logic [1:0] state;

    function automatic logic [14:0] pick_weighted();
        int sel;
        int rand_val;

        sel = $urandom_range(1, 5); 

        if (sel <= 3) begin
            rand_val = $urandom_range(10, 70);  
        end else begin
            rand_val = $urandom_range(80, 170); 
        end

        return rand_val[14:0]; 
    endfunction

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state <= SEND_A;
            for (int i = 0; i < SIZE; i++) begin
                sequence_o[i] <= '0;
            end
            sequence_valid_o <= 1'b0;
        end
        else begin
            case (state)
                SEND_A: begin
                    for (int i = 0; i < SIZE; i++) begin
                        sequence_o[i] <= pick_weighted();
                    end
                    sequence_valid_o <= 1'b1;
                    state <= WAIT;
                end

                WAIT: begin
                    if (sequence_send_i) begin
                        state <= SEND_B;
                    end
                    sequence_valid_o <= 1'b0;
                end

                SEND_B: begin
                    for (int i = 0; i < SIZE; i++) begin
                        sequence_o[i] <= pick_weighted();
                    end
                    sequence_valid_o <= 1'b1;
                    state <= WAIT; 
                end

                default: begin
                    state <= SEND_A;
                end
            endcase
        end
    end

endmodule