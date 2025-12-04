#ifndef MATRIX_OLD_H
#define MATRIX_OLD_H

#include <stdlib.h>
#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"

#define matrix_size     8

#define CALC_BASE       0x44A00000
#define A_OFFSET        0x100
#define B_OFFSET        0x200
#define R_OFFSET        0x300

#define GPIO_BASE_ADDR  0x40000000
#define GPIO_DATA2      0x8
#define LD0             0x0001
#define LD1             0x0002

int** create_ones_matrix(void);
int** create_sequence_matrix(void);
int** create_matrix(void);
void  free_matrix(int **matrix);

int** calculate_function_sw(int **A, int **B);
int** calculate_function_hw(int **A, int **B);
void show_matrix_on_led(int **M, int stop_on_sw_value);
int** multiply_matrices(int **A, int **B);
int** subtract_matrices(int **A, int **B);

#endif
