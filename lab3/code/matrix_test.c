#include <stdio.h>
#include <stdlib.h>
#include "matrix.h"

void init_ones(data_t *A) {
    for (int i = 0; i < MATRIX_SIZE; i++)
        for (int j = 0; j < MATRIX_SIZE; j++)
            A[i * MATRIX_SIZE + j] = 1;
}

void init_sequence(data_t *B) {
    for (int i = 0; i < MATRIX_SIZE; i++)
        for (int j = 0; j < MATRIX_SIZE; j++)
            B[i * MATRIX_SIZE + j] = j + 1;
}

int main() {
    int i, j;

    data_t A[MATRIX_SIZE * MATRIX_SIZE];
    data_t B[MATRIX_SIZE * MATRIX_SIZE];
    data_t result[MATRIX_SIZE * MATRIX_SIZE];

    init_ones(A);
    init_sequence(B);

    calc(A, B, result);

    FILE *fp = fopen("out.dat", "w");
    if (!fp) {
        perror("Cannot open out.dat");
        return 1;
    }

    for (i = 0; i < MATRIX_SIZE; i++) {
        for (j = 0; j < MATRIX_SIZE; j++) {
            fprintf(fp, "%d %d %d\n",
                    i, j, result[i * MATRIX_SIZE + j]);
        }
    }

    fclose(fp);

    printf("Comparing against out.golden.dat\n");

    if (system("diff -w out.dat out.golden.dat")) {
        printf("*******************************************\n");
        printf("FAIL: Output DOES NOT match the golden output\n");
        printf("*******************************************\n");
        return 1;
    } else {
        printf("*******************************************\n");
        printf("PASS: The output matches the golden output!\n");
        printf("*******************************************\n");
        return 0;
    }
}
