#ifndef MATRIX_H
#define MATRIX_H

#include <stdio.h>
#include <stdlib.h>
#include "matrix.h"
#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"
#include <unistd.h>
#include <stdint.h>

#define matrix_size 	8
#define GPIO_BASE_ADDR 	0x40000000
#define NO_LD 			0x0000
#define LD0 			0x0001
#define LD1 			0x0002

#define matrix_size 8

#define CALC_BASE 0x44A00000
#define A_OFFSET  0x100
#define B_OFFSET  0x200
#define R_OFFSET  0x300

#define GPIO_DATA2 0x8



void execute(void);
int** create_ones_matrix();
int** create_sequence_matrix();
int** multiply_matrices(int **A, int **B);
int** subtract_matrices(int **A, int **B);
void free_matrix(int **matrix);
int** create_matrix();
int** calculate_function(int **A, int **B);


#endif
