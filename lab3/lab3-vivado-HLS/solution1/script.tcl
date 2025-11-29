############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2019 Xilinx, Inc. All Rights Reserved.
############################################################
open_project lab3-vivado-HLS
set_top calc
add_files code/matrix.c
add_files code/matrix.h
add_files -tb code/matrix_test.c -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
add_files -tb code/out.golden.dat -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
open_solution "solution1"
set_part {xc7a100t-csg324-1} -tool vivado
create_clock -period 10 -name default
config_export -format ip_catalog -rtl verilog -version 1.0.0
#source "./lab3-vivado-HLS/solution1/directives.tcl"
csim_design
csynth_design
cosim_design -trace_level port
export_design -rtl verilog -format ip_catalog -version "1.0.0"
