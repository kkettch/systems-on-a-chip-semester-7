#include "matrix.h"
#include "gpio.h"
#include "xparameters.h"

int main() {
    init_platform();

    int **C;

    int **A = create_matrix();
    for (int i = 0; i < matrix_size; i++) {
        for (int j = 0; j < matrix_size; j++) {
            A[i][j] = get_value();
        }
    }

    int **B = create_matrix();
    for (int i = 0; i < matrix_size; i++) {
        for (int j = 0; j < matrix_size; j++) {
            B[i][j] = get_value();
        }
    }

    uint32_t cur_sw = (Xil_In32(GPIO_BASE_ADDR + GPIO_DATA2) >> 15) & 0x1;
    if (cur_sw == 0) {
    	C = calculate_function_hw(A, B);
    } else {
    	C = calculate_function_sw(A, B);
    }

	for (int i = 0; i < matrix_size; i++) {
		for (int j = 0; j < matrix_size; j++) {
			send_value(C[i][j]);
		}
	}

	free_matrix(A);
	free_matrix(B);
	free_matrix(C);

    cleanup_platform();
    return 0;
}

//int main() {
//    init_platform();
//
//    int **C;
//
//    int **A = create_matrix();
//    for (int i = 0; i < matrix_size; i++) {
//        for (int j = 0; j < matrix_size; j++) {
//            A[i][j] = get_value();
//        }
//    }
//
//    int **B = create_matrix();
//    for (int i = 0; i < matrix_size; i++) {
//        for (int j = 0; j < matrix_size; j++) {
//            B[i][j] = get_value();
//        }
//    }
//
//    uint32_t cur_sw = (Xil_In32(GPIO_BASE_ADDR + GPIO_DATA2) >> 15) & 0x1;
//    if (cur_sw == 0) {
//    	C = calculate_function_hw(A, B);
//    } else {
//    	C = calculate_function_sw(A, B);
//    }
//
//	for (int i = 0; i < matrix_size; i++) {
//		for (int j = 0; j < matrix_size; j++) {
//			send_value(C[i][j]);
//		}
//	}
//
//	free_matrix(A);
//	free_matrix(B);
//	free_matrix(C);
//
//    cleanup_platform();
//    return 0;
//}

//int main()
//{
//    init_platform();
//
//    int **A = create_ones_matrix();
//    int **B = create_sequence_matrix();
//    int is_started = 1;
//
//    uint32_t prev_sw = Xil_In32(GPIO_BASE_ADDR + GPIO_DATA2) & 0x1;
//
//    while (1) {
//        uint32_t cur_sw = Xil_In32(GPIO_BASE_ADDR + GPIO_DATA2) & 0x1;
//
//        if ((cur_sw != prev_sw) || is_started) {
//
//            if (cur_sw == 0) {
//                int **R = calculate_function_sw(A, B);
//                show_matrix_on_led(R, 1);
//                free_matrix(R);
//            } else {
//                int **R = calculate_function_hw(A, B);
//                show_matrix_on_led(R, 0);
//                free_matrix(R);
//            }
//
//            prev_sw = cur_sw;
//            is_started = 0;
//        }
//    }
//    free_matrix(A);
//    free_matrix(B);
//    cleanup_platform();
//    return 0;
//}
