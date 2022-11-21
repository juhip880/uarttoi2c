//====================================================================================
//                                                                                   
//  Title         : Top Module                                                
//  Description   : This is the top module for UART to I2C bridge.
//                                                                                      
//====================================================================================
//currently having instance of one I2C slave and one UART instance
`
`ifndef TB__TOP
`define TB__TOP

`timescale 1us / 1ns

//include design files here

`include "uvm_macros.svh"
import uvm_pkg::*;
import tb_pkg::*;
import test_pkg::*;

module top;

  bit clk;
  logic reset_n;

  wand scl,sda;
  wire rx,tx;

  always
  #5 clk=~clk;

  pullup (strong1) p1 (scl);
  pullup (strong1) p2 (sda);

  I2C_intf vif (.clk(clk),
                .scl(scl),
		.sda(sda));

  uart_if intf(.reset(reset_n));
  //Take instance of DUT here
  /*abc t1 (.scl(scl),
          .sda(sda));*/

  //I2C_ms_dri_bfm ms(.clk(vif.clk),
                    .scl(vif.scl),
		    .sda(vif.sda));

  I2C_sl_dri_bfm sl(.scl(vif.scl),
		    .sda(vif.sda));

  //I2C_mon_bfm ms_mon(.clk(vif.clk),
                     .scl(vif.scl),
		     .sda(vif.sda));

  I2C_mon_bfm sl_mon(.clk(vif.clk),
                     .scl(vif.scl),
		     .sda(vif.sda));

  initial begin
    //uvm_config_db #(virtual I2C_ms_dri_bfm)::set(null,"uvm_test_top.I2C_ms_env_h.ms_agent_h[0].ms_dri_h","ms_bfm",ms);

    uvm_config_db #(virtual I2C_sl_dri_bfm)::set(null,"uvm_test_top.I2C_sl_env_h.sl_agent_h[0].sl_dri_h","sl_bfm",sl);
    
    //uvm_config_db #(virtual I2C_mon_bfm)::set(null,"uvm_test_top.I2C_ms_env_h.I2C_mon_h","mon_bfm",ms_mon);

    uvm_config_db #(virtual I2C_mon_bfm)::set(null,"uvm_test_top.I2C_sl_env_h.I2C_mon_h","mon_bfm",sl_mon);
    
	uvm_config_db #(virtual uart_if)::set(null,"*","vif_0",intf);

    run_test();
  end

  initial begin
    $dumpfile("top.vcd");
    $dumpvars(0,top);
  end
  
 initial begin
   reset_n = 0;
   #10 reset_n = ~reset_n;
 end

endmodule : top

`endif
