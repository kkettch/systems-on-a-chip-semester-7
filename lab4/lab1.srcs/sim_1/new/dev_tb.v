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

wire [15:0] gpio_rtl_tri_o;
reg reset;
reg sys_clock;
reg usb_uart_rxd;
wire usb_uart_txd;

design_1_wrapper uut
   (.gpio_rtl_tri_o(gpio_rtl_tri_o),
    .reset(reset),
    .sys_clock(sys_clock),
    .usb_uart_rxd(usb_uart_rxd),
    .usb_uart_txd(usb_uart_txd));
    
initial begin
    reset = 0;
    sys_clock = 0;
    usb_uart_rxd = 0;
    
    #200
    reset = 1;
end

always #5 sys_clock = ~sys_clock;

    
endmodule
