`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2025 14:31:11
// Design Name: 
// Module Name: driver
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


module driver(
    input clk,
    input rst,
    
    input [15:0] sequence_i[9],
    input sequence_valid,
    output logic sequence_send,
    
    output logic [15:0] gpio_switch,
    input [15:0] gpio_led
    );
    
    localparam WAIT_SEQ = 0;
    localparam SEND_SEQ = 1;
    
    logic state;
    logic recieve;
    
    logic [15:0] temp_matrix [9];
    logic [3:0] temp_idx;
    
    wire send_vld = gpio_switch[15]; // если усспешно отправили, то выставится на лампочку
    wire recieve_vld = gpio_led[15]; // входной ACK от Data 
    
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 9; i++) begin
                temp_matrix[i] <= '0;
            end
            temp_idx <= '0;
            state <= WAIT_SEQ;
            sequence_send <= '0;
            recieve <= '0;
        end else begin
            case (state)
                WAIT_SEQ: begin
                    if (sequence_valid) begin
                        temp_matrix <= sequence_i;
                        state <= SEND_SEQ;
                    end
                    recieve <= '0;
                    temp_idx <= '0;
                    sequence_send <= '0;
                end
                SEND_SEQ: begin
                    if (temp_idx == 9) begin
                        state <= WAIT_SEQ;
                        sequence_send <= '1;
                    end else begin
                        if (send_vld) begin
                            if (recieve && !recieve_vld) begin // Факт окончания приема от DUT
                                temp_idx <= temp_idx + 1'b1;
                                gpio_switch <= '0;
                                recieve <= '0;
                            end else if (recieve_vld) begin
                                recieve <= 1;
                            end 
                        end else begin
                                gpio_switch <= temp_matrix[temp_idx] | 16'h8000;
                        end
                    end
                end
            endcase
        end
    end
endmodule
