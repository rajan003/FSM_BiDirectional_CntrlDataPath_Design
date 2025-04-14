///This module inhouse all the control FSM//
// Control Path: Master  FSM + 3 Slave FSM.
// This will send control signals to all the Data Path Components///

module #(parameter DATA_WIDTH=4) control_path (

                                input logic clk;
                                input logic rst;

                                //// Level-1 control// Serial Data Sample//
                               output logic en_a, en_b, en_c, en_d;

                              // Level-2 control signal/// Selecting sigbal to Multiply// Single Multiplier present//
                              output logic [1:0] mux_sel_0;  // Selecting between A,B,C // BC Common inboth MUX
                              output logic [1:0] mux_sel_1; // // Selecting between B,C,D
                                //Controlling the Register to hold all multiplication values
                              output logic en_ab, en_ac, en_ad, en_bc, en_bd, en_cd ;
                                // Level-3//Control Signal// final MUX to send values
                              output logic [1:0]mux_sel_3 );

  ///MASTER FSM-1// Enum type
  typedef logic [2:0] enum(SM_0, 
                           SM_1, // Send request to FSM-1
                           SM_2,
                           SM_3, 
                           SM_4,
                             
                                
                                
