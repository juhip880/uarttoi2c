//====================================================================================
//                                                                                   
//  Title         : I2C Agent Class                                                 
//  Description   : This file contains definition of Agent Class of I2C VIP.This class 
//                  instantiates Master/Slave Driver based on configuration, Sequencer and Monitor component.
//                                                                                      
//====================================================================================

`ifndef I2C_AGENT
`define I2C_AGENT

class I2C_agent extends uvm_agent;

  //-------------------------------------------------------
  // Factory Registration
  //-------------------------------------------------------

  `uvm_component_utils(I2C_agent);

  //-------------------------------------------------------
  // Data Members
  //-------------------------------------------------------

  typedef uvm_sequencer #(I2C_seq_item) I2C_sequencer;

  //handle for  sequencer
  I2C_sequencer i2c_sequencer_h;

  //handle for  driver
  I2C_dri i2c_dri_h;

  //analysis port declaration
  //uvm_analysis_port #(I2C_seq_item) ms_aport;

  //-------------------------------------------------------
  // Methods
  //-------------------------------------------------------

  extern function new(string name="I2C_agent",uvm_component parent=null);

  extern function void build_phase(uvm_phase phase);

  extern function void connect_phase(uvm_phase phase);

endclass : I2C_agent

//---------------------------------------------------------
// definitions of functions and tasks of I2C_agent class
//---------------------------------------------------------

  //-------------------------------------------------------
  // Default Constructor
  //-------------------------------------------------------

  function I2C_agent::new(string name="I2C_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //-------------------------------------------------------
  // Build Phase
  //-------------------------------------------------------

  function void I2C_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    i2c_sequencer_h = I2C_sequencer::type_id::create("i2c_sequencer_h",this);
    i2c_dri_h = I2C_dri::type_id::create("i2c_dri_h",this);

    //ms_aport=new("ms_aport",this);

  endfunction : build_phase

  //-------------------------------------------------------
  // Connect Phase
  //-------------------------------------------------------

  function void I2C_ms_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    //connect driver and sequencer
    i2c_dri_h.seq_item_port.connect(
             i2c_sequencer_h.seq_item_export);
    
    //connect driver and env
   // ms_dri_h.ms_aport.connect(this.ms_aport);
  endfunction : connect_phase

`endif

