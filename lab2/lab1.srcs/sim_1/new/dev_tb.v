`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2025 13:05:45
// Design Name: 
// Module Name: dev_tb
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


module dev_tb;

reg clk;
wire [15:0] gpio_switch;
wire [15:0] gpio_led;
reg rst_n;

agent agent_impl (
    .clk_i(clk),
    .rst_i(!rst_n),
    .gpio_switch(gpio_switch),
    .gpio_led(gpio_led)
);
    

design_1_wrapper DUT (
    .sys_clock(clk),
    .gpio_rtl_tri_o(gpio_led),
    .gpio_rtl_0_tri_i(gpio_switch),
    .reset(rst_n)
);


initial begin
    rst_n = 0;
    #200
    rst_n = 1;
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
    
endmodule
