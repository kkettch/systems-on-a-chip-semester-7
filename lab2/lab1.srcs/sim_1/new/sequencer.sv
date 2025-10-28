`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2025 14:28:56
// Design Name: 
// Module Name: sequencer
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


module sequencer(
    input clk_i,
    input rst_i,
    output logic [15:0] sequence_o[9], //у нас будет 81
    output logic sequence_valid_o, // сигнал что мы хотим отправить 
    input sequence_send_i // сигнал о том что мы все передали
);

    localparam SEND_A = 0;
    localparam SEND_B = 2;
    localparam WAIT = 1;
    
    logic [15:0] matrix_a[9] = '{
        16'h0001,
        16'h0002,
        16'h0003,
        16'h0004,
        16'h0005,
        16'h0006,
        16'h0007,
        16'h0008,
        16'h0009
    };
    
    logic [15:0] matrix_b[9] = '{
        16'h0002,
        16'h0003,
        16'h0004,
        16'h0005,
        16'h0006,
        16'h0007,
        16'h0008,
        16'h0009,
        16'h000A
    };
    
        logic [1:0] state;
        
        always_ff @( posedge clk_i ) begin
            if (rst_i) begin
                state <= SEND_A;
                for (int i = 0; i < 9; i++) begin
                    sequence_o[i] <= '0;
                end
                sequence_valid_o <= '0;
            end else begin
                case (state)
                    SEND_A: begin
                        sequence_o <= matrix_a;
                        sequence_valid_o <= 1;
                        state <= WAIT;
                    end
                    WAIT: begin
                        if (sequence_send_i) begin
                            state <= SEND_B;
                        end
                        sequence_valid_o <= 0;
                    end
                    SEND_B: begin
                        sequence_o <= matrix_b;
                        sequence_valid_o <= 1;
                    end
                 endcase
            end
        end
endmodule
