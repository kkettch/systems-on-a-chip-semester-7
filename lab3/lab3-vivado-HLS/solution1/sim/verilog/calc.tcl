
log_wave [get_objects -filter {type == in_port || type == out_port || type == inout_port || type == port} /apatb_calc_top/AESL_inst_calc/*]
set designtopgroup [add_wave_group "Design Top Signals"]
set cinoutgroup [add_wave_group "C InOuts" -into $designtopgroup]
set A__B__result__return_group [add_wave_group A__B__result__return(axi_slave) -into $cinoutgroup]
add_wave /apatb_calc_top/AESL_inst_calc/interrupt -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_BRESP -into $A__B__result__return_group -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_BREADY -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_BVALID -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_RRESP -into $A__B__result__return_group -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_RDATA -into $A__B__result__return_group -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_RREADY -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_RVALID -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_ARREADY -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_ARVALID -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_ARADDR -into $A__B__result__return_group -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_WSTRB -into $A__B__result__return_group -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_WDATA -into $A__B__result__return_group -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_WREADY -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_WVALID -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_AWREADY -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_AWVALID -into $A__B__result__return_group -color #ffff00 -radix hex
add_wave /apatb_calc_top/AESL_inst_calc/s_axi_AXILiteS_AWADDR -into $A__B__result__return_group -radix hex
set resetgroup [add_wave_group "Reset" -into $designtopgroup]
add_wave /apatb_calc_top/AESL_inst_calc/ap_rst_n -into $resetgroup
set clockgroup [add_wave_group "Clock" -into $designtopgroup]
add_wave /apatb_calc_top/AESL_inst_calc/ap_clk -into $clockgroup
save_wave_config calc.wcfg
run all
quit

