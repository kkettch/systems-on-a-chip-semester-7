#include "matrix.h"

int** create_ones_matrix(void) {
    int** matrix = (int**)malloc(matrix_size * sizeof(int*));
    for (int i = 0; i < matrix_size; i++) {
        matrix[i] = (int*)malloc(matrix_size * sizeof(int));
        for (int j = 0; j < matrix_size; j++) {
            matrix[i][j] = 1;
        }
    }
    return matrix;
}

int** create_sequence_matrix(void) {
    int** matrix = (int**)malloc(matrix_size * sizeof(int*));
    for (int i = 0; i < matrix_size; i++) {
        matrix[i] = (int*)malloc(matrix_size * sizeof(int));
        for (int j = 0; j < matrix_size; j++) {
            matrix[i][j] = j + 1;
        }
    }
    return matrix;
}

int** create_matrix(void) {
    int **matrix = (int**)malloc(matrix_size * sizeof(int*));
    for (int i = 0; i < matrix_size; i++) {
        matrix[i] = (int*)malloc(matrix_size * sizeof(int));
    }
    return matrix;
}

void free_matrix(int** matrix) {
    if (!matrix) return;
    for (int i = 0; i < matrix_size; i++) {
        free(matrix[i]);
    }
    free(matrix);
}

int** multiply_matrices(int **A, int **B) {
    int **result = (int**)malloc(matrix_size * sizeof(int*));
    for (int i = 0; i < matrix_size; i++) {
        result[i] = (int*)malloc(matrix_size * sizeof(int));
    }

    for (int i = 0; i < matrix_size; i++) {
        for (int j = 0; j < matrix_size; j++) {
            result[i][j] = 0;
            for (int k = 0; k < matrix_size; k++) {
                result[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    return result;
}

int** subtract_matrices(int **A, int **B) {
    int **result = (int**)malloc(matrix_size * sizeof(int*));
    for (int i = 0; i < matrix_size; i++) {
        result[i] = (int*)malloc(matrix_size * sizeof(int));
    }

    for (int i = 0; i < matrix_size; i++) {
        for (int j = 0; j < matrix_size; j++) {
            result[i][j] = A[i][j] - B[i][j];
        }
    }

    return result;
}

int** calculate_function_sw(int **A, int **B)
{
    int** A_multiply_B = multiply_matrices(A, B);
    int** result       = subtract_matrices(A_multiply_B, B);
    free_matrix(A_multiply_B);
    return result;
}

static void write_matrix_to_ip(int offset, int **M) {
    for (int i = 0; i < matrix_size; i++)
        for (int j = 0; j < matrix_size; j++)
            Xil_Out32(CALC_BASE + offset + 4*(i*matrix_size + j), M[i][j]);
}

static void read_matrix_from_ip(int offset, int **M) {
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

    while ((Xil_In32(CALC_BASE + 0x00) & 0x2) == 0) {}

    read_matrix_from_ip(R_OFFSET, R);

    return R;
}

void show_matrix_on_led(int **M, int stop_on_sw_value)
{
    for (int i = 0; i < matrix_size; i++) {
        for (int j = 0; j < matrix_size; j++) {
            uint32_t sw = Xil_In32(GPIO_BASE_ADDR + GPIO_DATA2) & 0x1;
            if (sw == (uint32_t)stop_on_sw_value) {
                return;
            }

            uint16_t led_value = (uint16_t)(M[i][j] & 0xFFFF);

            Xil_Out16(GPIO_BASE_ADDR, led_value);
            sleep(1);
            Xil_Out16(GPIO_BASE_ADDR, 0x0000);
            sleep(1);
        }
    }
}
