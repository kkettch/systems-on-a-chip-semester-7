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
wire [14:0] gpio_switch_bus;
wire [15:0] gpio_led;
wire test_done;
reg rst_n;
reg mode_sw;

agent agent_impl (
    .clk_i(clk),
    .rst_i(!rst_n),
    .gpio_switch(gpio_switch_bus),
    .gpio_led(gpio_led),
    .test_done(test_done)
);

assign gpio_switch = {mode_sw, gpio_switch_bus};

design_1_wrapper DUT (
    .dip_switches_16bits_tri_i(gpio_switch),
    .sys_clock(clk),
    .gpio_rtl_tri_o(gpio_led),
    .reset(rst_n)
);



initial begin
    rst_n = 0;
    mode_sw= 1'b1;
    #200
    rst_n = 1;
    
    @(posedge test_done);
    $display("=== FIRST RUN (mode_sw = 1) DONE ===");
    
    #100
    rst_n = 0;
    mode_sw = 1'b0;
    #200
    rst_n = 1;
    
    @(posedge test_done);
    $display("=== SECOND RUN (mode_sw = 0) DONE ===");
    
    #100
    $finish;
    
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
    
endmodule
