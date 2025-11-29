#include <stdlib.h>
#include "matrix.h"

int** create_matrix()
{
    int **matrix = (int**)malloc(MATRIX_SIZE * sizeof(int*));
    for (int i = 0; i < MATRIX_SIZE; i++)
        matrix[i] = (int*)malloc(MATRIX_SIZE * sizeof(int));
    return matrix;
}

void free_matrix(int **matrix)
{
    for (int i = 0; i < MATRIX_SIZE; i++)
        free(matrix[i]);
    free(matrix);
}

int** multiply_matrices(int **A, int **B)
{
    int **result = create_matrix();
    for (int i = 0; i < MATRIX_SIZE; i++)
    {
        for (int j = 0; j < MATRIX_SIZE; j++)
        {
            result[i][j] = 0;
            for (int k = 0; k < MATRIX_SIZE; k++)
                result[i][j] += A[i][k] * B[k][j];
        }
    }
    return result;
}

int** subtract_matrices(int **A, int **B)
{
    int **result = create_matrix();
    for (int i = 0; i < MATRIX_SIZE; i++)
    {
        for (int j = 0; j < MATRIX_SIZE; j++)
            result[i][j] = A[i][j] - B[i][j];
    }
    return result;
}

int** calculate_function(int **A, int **B)
{
    int **A_mul_B = multiply_matrices(A, B);
    int **result = subtract_matrices(A_mul_B, B);
    free_matrix(A_mul_B);
    return result;
}
