//===================================================================================
//                                                            
//  Title         : I2C Sequence Item Class                          
//  Description   : This is Sequence item Class for I2C VIP      
//                                                           
//===================================================================================

`ifndef I2C_SEQ_ITEM
`define I2C_SEQ_ITEM

class I2C_seq_item extends uvm_sequence_item;

  //-------------------------------------------------------
  // Data Memebers
  //-------------------------------------------------------

  //variable for specifying speed mode
  typedef enum {SM,FM} speed_mode;
  rand speed_mode sm_e;
  
  //variable for operation
  typedef enum {ADDR_7_BIT,ADDR_10_BIT,START_BYTE,GEN_CALL,
                MASTER_CODE,DEVICE_ID} operation;
  rand operation op_e;

  //variable for rd or wr mode selection for master
  rand bit R_W_mode;

  //variable for no of data byte
  rand int no_of_data_byte;

  //queue for data bytes
  rand bit [7:0] data_q[$];

  //variable for specifying address
  rand bit [9:0] address;

  //queue for ack and nack 
  rand bit ack_nack_q[$];

  //variable for specifying bit level clk stretching
  rand bit clk_stretching_bit_level;

  //variable for specifying byte level clk stretching
  rand bit clk_stretching_byte_level;

  //variable for specifying clk stretching time
  rand integer clk_stretching_time;

  //variable to decide whether to generate STOP or not
  rand bit stop_gen;

  //-------------------------------------------------------
  // Constraints 
  //-------------------------------------------------------  

  constraint addr_c { 
             (op_e==ADDR_7_BIT) -> (address inside {[10'b00_0000_1000:10'b00_0111_0111]});
	     (op_e==MASTER_CODE) -> (address inside {[10'b00_0000_1000:10'b00_0000_1111]}); 
             (op_e==CBUS_ADDR) -> (address inside {[10'b00_0000_0010:10'b00_0000_0011]});
             (op_e==START_BYTE) -> (address==10'b00_0000_0001);
             (op_e==GEN_CALL) -> (address==10'b00_0000_0000);
	     solve op_e before address;
	       }
  
  constraint no_of_data_byte_c {
             if((op_e==START_BYTE)||(op_e==MASTER_CODE)||(op_e==CBUS_ADDR)) {
	       no_of_data_byte==0;
	       R_W_mode==0;
	         }
             else {
	       no_of_data_byte inside {[1:10]};
	         }
	     solve op_e before no_of_data_byte;
	       }

  constraint R_W_mode_c {
             (op_e==GEN_CALL) -> (R_W_mode==0);
	       }

  constraint data_c {
             data_q.size() == no_of_data_byte;
	     solve no_of_data_byte before data_q;      
	       }

  constraint ack_nack_c {
             ack_nack_q.size() == no_of_data_byte;
	     solve no_of_data_byte before ack_nack_q;
	     foreach(ack_nack_q[i])
	       soft ack_nack_q[i]==0;
	       }

  constraint ufm_r_w_mode_c {
             (sm_e==UFM) -> (R_W_mode==0);
             solve sm_e before R_W_mode;
	       }

  constraint dev_id_R_W_mode_c {
             (op_e==DEVICE_ID) -> (R_W_mode==1);
	       }

  constraint clk_stretching_c {
          soft clk_stretching_bit_level dist {0:=9,1:=0};
	  soft clk_stretching_byte_level dist {0:=9,1:=0};
          soft clk_stretching_time inside {[5:10]};
               } 

  constraint ufm_clk_stretching_c {
             (sm_e==UFM) -> ((clk_stretching_bit_level==0) && (clk_stretching_byte_level==0));
             solve sm_e before clk_stretching_byte_level;
             solve sm_e before clk_stretching_bit_level;
               }

  constraint hs_clk_stretching_c  {
             (sm_e==HS) -> clk_stretching_bit_level==0;
               }

  constraint ufm_operation_c {
             (sm_e==UFM) -> ((op_e!=MASTER_CODE) && (op_e!=DEVICE_ID));
             solve sm_e before op_e;        
              }

  constraint hs_operation_c {
             (sm_e==HS) -> (op_e!=MASTER_CODE);
             }

  constraint gen_call_2nd_byte_c {
             if((op_e==GEN_CALL)&&(no_of_data_byte!=0)) {
	       if(data_q[0][0]==0) {
	         data_q[0] inside {8'h04,8'h06};
		     }
		   }
		 }

  constraint op_dist_c {
             op_e dist {ADDR_7_BIT:=20,ADDR_10_BIT:=20,[START_BYTE:DEVICE_ID]:/10};
	        }

  //-------------------------------------------------------
  // Factory Registeration
  //-------------------------------------------------------

  `uvm_object_utils_begin(I2C_seq_item)
     `uvm_field_enum(speed_mode, sm_e, UVM_ALL_ON)
     `uvm_field_enum(operation, op_e, UVM_ALL_ON)
     `uvm_field_int(R_W_mode, UVM_ALL_ON)
     `uvm_field_int(no_of_data_byte, UVM_ALL_ON)
     `uvm_field_queue_int(data_q, UVM_ALL_ON)
     `uvm_field_int(address, UVM_ALL_ON)
     `uvm_field_queue_int(ack_nack_q, UVM_ALL_ON)
     `uvm_field_int(clk_stretching_bit_level, UVM_ALL_ON | UVM_NOCOMPARE)
     `uvm_field_int(clk_stretching_byte_level, UVM_ALL_ON | UVM_NOCOMPARE)
     `uvm_field_int(clk_stretching_time, UVM_ALL_ON | UVM_NOCOMPARE)
     `uvm_field_int(stop_gen, UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_object_utils_end

  //-------------------------------------------------------
  // default constructor override
  //-------------------------------------------------------

  function new (string name = "I2C_seq_item");
    super.new(name);
  endfunction : new

  function string convert2string();
    return($sformatf("sm_e=%0s \nop_e=%0s \nR_W_mode=%0d \naddress=%0h \nno_of_data_byte=%0d \ndata_q=%0p \nack_nack_q=%0p\n",sm_e.name(),op_e.name(),
		      R_W_mode,address,no_of_data_byte,data_q,ack_nack_q));
  endfunction : convert2string

endclass : I2C_seq_item

`endif



