#include "matrix.h"

void calc(
    data_t A[MATRIX_SIZE * MATRIX_SIZE],
    data_t B[MATRIX_SIZE * MATRIX_SIZE],
    data_t result[MATRIX_SIZE * MATRIX_SIZE]
) {
#pragma HLS INTERFACE s_axilite port=return
#pragma HLS INTERFACE s_axilite port=A
#pragma HLS INTERFACE s_axilite port=B
#pragma HLS INTERFACE s_axilite port=result

    data_t tmp[MATRIX_SIZE * MATRIX_SIZE];

    for (int i = 0; i < MATRIX_SIZE; i++) {
#pragma HLS PIPELINE
        for (int j = 0; j < MATRIX_SIZE; j++) {
            data_t sum = 0;
            for (int k = 0; k < MATRIX_SIZE; k++) {
                sum += A[i * MATRIX_SIZE + k] *
                       B[k * MATRIX_SIZE + j];
            }

            tmp[i * MATRIX_SIZE + j] = sum;
        }
    }

    for (int k = 0; k < MATRIX_SIZE; k++) {
#pragma HLS PIPELINE
        for (int l = 0; l < MATRIX_SIZE; l++) {
            result[k * MATRIX_SIZE + l] =
                tmp[k * MATRIX_SIZE + l] -
                B[k * MATRIX_SIZE + l];
        }
    }
}
