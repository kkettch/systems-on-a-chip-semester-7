#include "matrix.h"

int** create_ones_matrix() {
    int** matrix = (int**)malloc(matrix_size * sizeof(int*));
    for (int i = 0; i < matrix_size; i++) {
        matrix[i] = (int*)malloc(matrix_size * sizeof(int));
        for (int j = 0; j < matrix_size; j++) {
            matrix[i][j] = 1;
        }
    }
    return matrix;
}

int** create_sequence_matrix() {
    int** matrix = (int**)malloc(matrix_size * sizeof(int*));
    for (int i = 0; i < matrix_size; i++) {
        matrix[i] = (int*)malloc(matrix_size * sizeof(int));
        for (int j = 0; j < matrix_size; j++) {
            matrix[i][j] = j + 1;  
        }
    }
    return matrix;
}

int execute()
{
	int** result;
    int** A = create_ones_matrix();
    int** B = create_sequence_matrix();

	Xil_Out16(GPIO_BASE_ADDR, LD0);
	result = calculate_function(A, B);
	Xil_Out16(GPIO_BASE_ADDR, LD1);

    // вывод результитрующей матрицы на светодиоды
    for (int i = 0; i < matrix_size; i++) {
    	for (int j = 0; j < matrix_size; j++) {
    		uint16_t led_value = (uint16_t)(result[i][j] & 0xFFFF);

    		Xil_Out16(GPIO_BASE_ADDR, led_value);

    		xil_printf("LEDs show result[%d][%d] = 0x%04X\r\n", i, j, led_value);

    		sleep(1);

    		Xil_Out16(GPIO_BASE_ADDR, 0x0000);

    		sleep(0.5);
    	}
    }


	free(A);
    free(B);
    free(result);

    return 0;
}

int** calculate_function(int **A, int **B)
{
	int** A_multiply_B = multiply_matrices(A, B);
	int** result = subtract_matrices(A_multiply_B, B);
	free_matrix(A_multiply_B);
	return result;
}

int** create_matrix() {
    int **matrix = (int**)malloc(matrix_size * sizeof(int*));
    for (int i = 0; i < matrix_size; i++) {
        matrix[i] = (int*)malloc(matrix_size * sizeof(int));
    }
    return matrix;
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

void free_matrix(int** matrix) {
    for (int i = 0; i < matrix_size; i++) {
        free(matrix[i]);
    }
    free(matrix);
}
