#ifndef MATRIX_H
#define MATRIX_H

#include <stdio.h>
#include <stdlib.h>
#include "xil_printf.h"
#include "xil_io.h"
#include "matrix.h"
#include "sleep.h"

#define matrix_size 	8
#define GPIO_BASE_ADDR 	0x40000000
#define NO_LD 			0x0000
#define LD0 			0x0001
#define LD1 			0x0002

int execute();
int** multiply_matrices(int **A, int **B);
int** subtract_matrices(int **A, int **B);
void free_matrix(int **matrix);
int** create_matrix();
int** calculate_function(int **A, int **B);


#endif
