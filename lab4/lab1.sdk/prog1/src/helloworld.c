/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

//#include <stdio.h>
//
//#include "matrix.h"
//
//void main(
//	int** A,
//	int** B,
//	int** result
//	) {
//#pragma HLS INTERFACE s_axilite port=return
//#pragma HLS INTERFACE s_axilite port=A
//#pragma HLS INTERFACE s_axilite port=B
//#pragma HLS INTERFACE s_axilite port=result
//	result = calculate_function(A, B);
//}


#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "matrix.h"

#define matrix_size 8

#define CALC_BASE 0x44A00000
#define A_OFFSET  0x100
#define B_OFFSET  0x200
#define R_OFFSET  0x300

#define GPIO_BASE_ADDR 0x40000000
#define GPIO_DATA2 0x8
#define LD0 0x0001
#define LD1 0x0002


void write_matrix_to_ip(int offset, int **M) {
    for (int i = 0; i < matrix_size; i++)
        for (int j = 0; j < matrix_size; j++)
            Xil_Out32(CALC_BASE + offset + 4*(i*matrix_size + j), M[i][j]);
}

void read_matrix_from_ip(int offset, int **M) {
    for (int i = 0; i < matrix_size; i++)
        for (int j = 0; j < matrix_size; j++)
            M[i][j] = Xil_In32(CALC_BASE + offset + 4*(i*matrix_size + j));
}

int** calculate_function_hw(int **A, int **B)
{
    int **R = create_matrix();

    write_matrix_to_ip(A_OFFSET, A);
    write_matrix_to_ip(B_OFFSET, B);

    Xil_Out32(CALC_BASE + 0x00, 1);

    while ((Xil_In32(CALC_BASE + 0x00) & 0x2) == 0);

    read_matrix_from_ip(R_OFFSET, R);

    return R;
}

void show_matrix_on_led(int **R) {
    for (int i = 0; i < matrix_size; i++) {
        for (int j = 0; j < matrix_size; j++) {
        	uint32_t sw = Xil_In32(GPIO_BASE_ADDR + GPIO_DATA2);
        	if (!(sw & 0x1))
        		return;

            uint16_t led_value = (uint16_t)(R[i][j] & 0xFFFF);

            Xil_Out16(GPIO_BASE_ADDR, led_value);
            sleep(1);
            Xil_Out16(GPIO_BASE_ADDR, 0x0000);
            sleep(1);
        }
    }
}

int main()
{
    init_platform();

    int **A = create_ones_matrix();
    int **B = create_sequence_matrix();

    while (1) {

        uint32_t sw = Xil_In32(GPIO_BASE_ADDR + GPIO_DATA2);
        if (sw & 0x1) {
            int **R = calculate_function_hw(A, B);
            show_matrix_on_led(R);
            free_matrix(R);
        }
        uint32_t sw2 = Xil_In32(GPIO_BASE_ADDR + GPIO_DATA2);
        if (!(sw2 & 0x1)) {
        	execute();
        }

        usleep(200000);
    }


    cleanup_platform();
    return 0;
}


