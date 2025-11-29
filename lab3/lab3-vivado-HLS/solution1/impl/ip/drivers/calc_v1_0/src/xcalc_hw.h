// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.1 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
// AXILiteS
// 0x000 : Control signals
//         bit 0  - ap_start (Read/Write/COH)
//         bit 1  - ap_done (Read/COR)
//         bit 2  - ap_idle (Read)
//         bit 3  - ap_ready (Read)
//         bit 7  - auto_restart (Read/Write)
//         others - reserved
// 0x004 : Global Interrupt Enable Register
//         bit 0  - Global Interrupt Enable (Read/Write)
//         others - reserved
// 0x008 : IP Interrupt Enable Register (Read/Write)
//         bit 0  - Channel 0 (ap_done)
//         bit 1  - Channel 1 (ap_ready)
//         others - reserved
// 0x00c : IP Interrupt Status Register (Read/TOW)
//         bit 0  - Channel 0 (ap_done)
//         bit 1  - Channel 1 (ap_ready)
//         others - reserved
// 0x100 ~
// 0x1ff : Memory 'A' (64 * 32b)
//         Word n : bit [31:0] - A[n]
// 0x200 ~
// 0x2ff : Memory 'B' (64 * 32b)
//         Word n : bit [31:0] - B[n]
// 0x300 ~
// 0x3ff : Memory 'result' (64 * 32b)
//         Word n : bit [31:0] - result[n]
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XCALC_AXILITES_ADDR_AP_CTRL     0x000
#define XCALC_AXILITES_ADDR_GIE         0x004
#define XCALC_AXILITES_ADDR_IER         0x008
#define XCALC_AXILITES_ADDR_ISR         0x00c
#define XCALC_AXILITES_ADDR_A_BASE      0x100
#define XCALC_AXILITES_ADDR_A_HIGH      0x1ff
#define XCALC_AXILITES_WIDTH_A          32
#define XCALC_AXILITES_DEPTH_A          64
#define XCALC_AXILITES_ADDR_B_BASE      0x200
#define XCALC_AXILITES_ADDR_B_HIGH      0x2ff
#define XCALC_AXILITES_WIDTH_B          32
#define XCALC_AXILITES_DEPTH_B          64
#define XCALC_AXILITES_ADDR_RESULT_BASE 0x300
#define XCALC_AXILITES_ADDR_RESULT_HIGH 0x3ff
#define XCALC_AXILITES_WIDTH_RESULT     32
#define XCALC_AXILITES_DEPTH_RESULT     64

