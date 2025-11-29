#ifndef MATRIX_H
#define MATRIX_H

#include <stdint.h>

#define MATRIX_SIZE 8

typedef int data_t;
typedef data_t matrix_t[MATRIX_SIZE][MATRIX_SIZE];

void calc(
    data_t A[MATRIX_SIZE * MATRIX_SIZE],
    data_t B[MATRIX_SIZE * MATRIX_SIZE],
    data_t result[MATRIX_SIZE * MATRIX_SIZE]
);

#endif
