#ifndef MATRIX_H
#define MATRIX_H

#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "matrix.h"

#define matrix_size 8

#define CALC_BASE 0x44A00000
#define A_OFFSET  0x100
#define B_OFFSET  0x200
#define R_OFFSET  0x300

#define GPIO_BASE_ADDR 0x40000000
#define GPIO_DATA2 0x8
#define LD0 0x0001
#define LD1 0x0002

#endif
