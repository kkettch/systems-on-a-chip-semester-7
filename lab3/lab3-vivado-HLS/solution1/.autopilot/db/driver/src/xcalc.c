// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.1 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xcalc.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XCalc_CfgInitialize(XCalc *InstancePtr, XCalc_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Axilites_BaseAddress = ConfigPtr->Axilites_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XCalc_Start(XCalc *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XCalc_ReadReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_AP_CTRL) & 0x80;
    XCalc_WriteReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_AP_CTRL, Data | 0x01);
}

u32 XCalc_IsDone(XCalc *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XCalc_ReadReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XCalc_IsIdle(XCalc *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XCalc_ReadReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XCalc_IsReady(XCalc *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XCalc_ReadReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XCalc_EnableAutoRestart(XCalc *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XCalc_WriteReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_AP_CTRL, 0x80);
}

void XCalc_DisableAutoRestart(XCalc *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XCalc_WriteReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_AP_CTRL, 0);
}

u32 XCalc_Get_A_BaseAddress(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_A_BASE);
}

u32 XCalc_Get_A_HighAddress(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_A_HIGH);
}

u32 XCalc_Get_A_TotalBytes(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (XCALC_AXILITES_ADDR_A_HIGH - XCALC_AXILITES_ADDR_A_BASE + 1);
}

u32 XCalc_Get_A_BitWidth(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XCALC_AXILITES_WIDTH_A;
}

u32 XCalc_Get_A_Depth(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XCALC_AXILITES_DEPTH_A;
}

u32 XCalc_Write_A_Words(XCalc *InstancePtr, int offset, int *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length)*4 > (XCALC_AXILITES_ADDR_A_HIGH - XCALC_AXILITES_ADDR_A_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(int *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_A_BASE + (offset + i)*4) = *(data + i);
    }
    return length;
}

u32 XCalc_Read_A_Words(XCalc *InstancePtr, int offset, int *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length)*4 > (XCALC_AXILITES_ADDR_A_HIGH - XCALC_AXILITES_ADDR_A_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(data + i) = *(int *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_A_BASE + (offset + i)*4);
    }
    return length;
}

u32 XCalc_Write_A_Bytes(XCalc *InstancePtr, int offset, char *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length) > (XCALC_AXILITES_ADDR_A_HIGH - XCALC_AXILITES_ADDR_A_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(char *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_A_BASE + offset + i) = *(data + i);
    }
    return length;
}

u32 XCalc_Read_A_Bytes(XCalc *InstancePtr, int offset, char *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length) > (XCALC_AXILITES_ADDR_A_HIGH - XCALC_AXILITES_ADDR_A_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(data + i) = *(char *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_A_BASE + offset + i);
    }
    return length;
}

u32 XCalc_Get_B_BaseAddress(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_B_BASE);
}

u32 XCalc_Get_B_HighAddress(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_B_HIGH);
}

u32 XCalc_Get_B_TotalBytes(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (XCALC_AXILITES_ADDR_B_HIGH - XCALC_AXILITES_ADDR_B_BASE + 1);
}

u32 XCalc_Get_B_BitWidth(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XCALC_AXILITES_WIDTH_B;
}

u32 XCalc_Get_B_Depth(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XCALC_AXILITES_DEPTH_B;
}

u32 XCalc_Write_B_Words(XCalc *InstancePtr, int offset, int *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length)*4 > (XCALC_AXILITES_ADDR_B_HIGH - XCALC_AXILITES_ADDR_B_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(int *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_B_BASE + (offset + i)*4) = *(data + i);
    }
    return length;
}

u32 XCalc_Read_B_Words(XCalc *InstancePtr, int offset, int *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length)*4 > (XCALC_AXILITES_ADDR_B_HIGH - XCALC_AXILITES_ADDR_B_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(data + i) = *(int *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_B_BASE + (offset + i)*4);
    }
    return length;
}

u32 XCalc_Write_B_Bytes(XCalc *InstancePtr, int offset, char *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length) > (XCALC_AXILITES_ADDR_B_HIGH - XCALC_AXILITES_ADDR_B_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(char *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_B_BASE + offset + i) = *(data + i);
    }
    return length;
}

u32 XCalc_Read_B_Bytes(XCalc *InstancePtr, int offset, char *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length) > (XCALC_AXILITES_ADDR_B_HIGH - XCALC_AXILITES_ADDR_B_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(data + i) = *(char *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_B_BASE + offset + i);
    }
    return length;
}

u32 XCalc_Get_result_BaseAddress(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_RESULT_BASE);
}

u32 XCalc_Get_result_HighAddress(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_RESULT_HIGH);
}

u32 XCalc_Get_result_TotalBytes(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (XCALC_AXILITES_ADDR_RESULT_HIGH - XCALC_AXILITES_ADDR_RESULT_BASE + 1);
}

u32 XCalc_Get_result_BitWidth(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XCALC_AXILITES_WIDTH_RESULT;
}

u32 XCalc_Get_result_Depth(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XCALC_AXILITES_DEPTH_RESULT;
}

u32 XCalc_Write_result_Words(XCalc *InstancePtr, int offset, int *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length)*4 > (XCALC_AXILITES_ADDR_RESULT_HIGH - XCALC_AXILITES_ADDR_RESULT_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(int *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_RESULT_BASE + (offset + i)*4) = *(data + i);
    }
    return length;
}

u32 XCalc_Read_result_Words(XCalc *InstancePtr, int offset, int *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length)*4 > (XCALC_AXILITES_ADDR_RESULT_HIGH - XCALC_AXILITES_ADDR_RESULT_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(data + i) = *(int *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_RESULT_BASE + (offset + i)*4);
    }
    return length;
}

u32 XCalc_Write_result_Bytes(XCalc *InstancePtr, int offset, char *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length) > (XCALC_AXILITES_ADDR_RESULT_HIGH - XCALC_AXILITES_ADDR_RESULT_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(char *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_RESULT_BASE + offset + i) = *(data + i);
    }
    return length;
}

u32 XCalc_Read_result_Bytes(XCalc *InstancePtr, int offset, char *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length) > (XCALC_AXILITES_ADDR_RESULT_HIGH - XCALC_AXILITES_ADDR_RESULT_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(data + i) = *(char *)(InstancePtr->Axilites_BaseAddress + XCALC_AXILITES_ADDR_RESULT_BASE + offset + i);
    }
    return length;
}

void XCalc_InterruptGlobalEnable(XCalc *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XCalc_WriteReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_GIE, 1);
}

void XCalc_InterruptGlobalDisable(XCalc *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XCalc_WriteReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_GIE, 0);
}

void XCalc_InterruptEnable(XCalc *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XCalc_ReadReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_IER);
    XCalc_WriteReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_IER, Register | Mask);
}

void XCalc_InterruptDisable(XCalc *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XCalc_ReadReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_IER);
    XCalc_WriteReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_IER, Register & (~Mask));
}

void XCalc_InterruptClear(XCalc *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XCalc_WriteReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_ISR, Mask);
}

u32 XCalc_InterruptGetEnabled(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XCalc_ReadReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_IER);
}

u32 XCalc_InterruptGetStatus(XCalc *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XCalc_ReadReg(InstancePtr->Axilites_BaseAddress, XCALC_AXILITES_ADDR_ISR);
}

