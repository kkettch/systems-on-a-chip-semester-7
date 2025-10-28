`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2025 14:33:24
// Design Name: 
// Module Name: agent
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

module agent(
    input clk_i,
    input rst_i,
    output [15:0] gpio_switch,
    output [15:0] gpio_led
    );
    
    logic [15:0] tmp_sequence[9];
    logic [15:0] result_sequence[9];
    logic sequence_valid, sequence_send, result_valid;
    
    sequencer sequencer_impl (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .sequence_o(tmp_sequence),
        .sequence_valid_o(sequence_valid),
        .sequence_send_i(sequence_send)
    );
    
    driver driver_impl (
        .clk(clk_i),
        .rst(rst_i),
        
        .sequence_i(tmp_sequence),
        .sequence_valid(sequence_valid),
        .sequence_send(sequence_send),
        
        .gpio_switch(gpio_switch),
        .gpio_led(gpio_led)
    );
    
    monitor monitor_impl (
        .clk(clk_i),
        .rst(rst_i),
        .gpio_led(gpio_led),
        
        .input_matrix_i(tmp_sequence),
        .input_valid_i(sequence_valid),
        
        .result_matrix_o(result_sequence),
        .result_valid(result_valid)
    );
    
    scoreboard scoreboard_impl (
        .clk_i(clk_i),
        .rst_i(rst_i),
        
        .matrix_input(tmp_sequence),
        .matrix_vld(sequence_valid),
        
        .result_matrix(result_sequence),
        .result_vld(result_valid)
    );
    
endmodule
