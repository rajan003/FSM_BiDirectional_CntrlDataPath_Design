///This module inhouse all the control FSM//
// Control Path: Master  FSM + 3 Slave FSM.
// This will send control signals to all the Data Path Components///

module #(parameter DATA_WIDTH=4) control_path (

                                input logic clk;
                                input logic rst;
                                // Serial Data Control SIgnals
                                input logic FirstDataInrdy;
                                output logic FirstDataOutRdy  
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
  typedef logic [2:0] enum(ST0, // Check for the input number control signal
                           ST1, //NotThree// Send request to FSM-1 // FSM 1 will take 1 cycle to complete
                           ST2, //NotThree//  Start FSM-2//
                           ST3, 
                           ST4,
                           ST5,
                           ST6,
                           ST7,
                           ST8, ST9,ST10,
                           ST11, ST12}state_0

      state_0 fsm0_st_nxt, fsm0_st ;
                             
              always_comb 
                begin 
                    start_fsm1= 1'b0;
                    start_fsm2= 1'b0;
                    start_fsm3= 1'b0;
                  FirstDataoutRdy=1'b0;
                  case(fsm0_st)
                    ST0: if(FirstInDataRdy) begin 
                            startfsm_1=1'b1;
                            if(three_only) fsm0_st_nxt = ST7;
                            else fsm0_st_nxt = ST1;
                          end
                          else fsm0_st_nxt = ST0;
                    ST1: fsm0_st_nxt = ST2;
                    ST2: begin 
                          start_fsm2 = 1'b1;
                          fsm0_st_nxt = ST3;
                          end
                    ST3: fsm0_st_nxt = ST4;
                    ST4: fsm0_st_nxt = ST5;
                    ST5: fsm0_st_nxt = ST6;
                    ST6: begin 
                        start_fsm3=1'b1;
                        FirstDataOutRdy=1'b1;
                      if(FirstInDataRdy) begin 
                          start_fsm1=1'b1;
                        fsm0_st_nxt = ST1; end
                      else fsm0_st_nxt = ST0
                        end 
                     ST7: fsm0_st_nxt = ST8;
                     ST8: begin 
                         start_fsm2=1'b1;
                       fsm0_st_nxt = ST9; end
                      ST9: begin 
                        if(FirstInDataRdy) begin 
                          start_fsm1=1'b1;
                          fsm0_st_nxt = ST10; end
                        else fsm0_st_nxt = ST12;
                        end 
                      ST10: begin 
                          start_fsm3=1'b1;
                          FirstDataoutRdy=1'b1;
                          fsm0_st_nxt = ST11;
                      end 
                      ST11:begin 
                         start_fsm2=1'b1;
                       fsm0_st_nxt = ST9; end
                      ST12: begin 
                          start_fsm3=1'b1;
                          FirstDataOutRdy=1'b1;
                          fsm0_st_nxt = ST0;
                      end 
                    default: fsm0_st_nxt = ST0;
              endcase
     end 
   always@(posedge clk or posedge rst) begin 
     if(rst) fsm0_st <= ST0;
                   else fsm0_st <= fsm0_st_nxt;
                    end  
  ///FSM-1// InitiAL SAMPLING fsm//
   typedef enum logic [1:0] { ST_A, ST_B, ST_C, ST_D} state_1;
                            state_1 fsm1_st , fsm1_st_nxt; // FSM1 current and next state.
                           always@(posedge clk or posedge rst) begin 
                             if(rst) fsm1_st <= ST_A;
                             else fsm1_st <= fsm1_st_nxt;
                           end 
                           
                           always_comb begin 
                             ///initlising the enable condition for samplers
                               en_a=1'b0;
                               en_b=1'b0;
                               en_c=1'b0;
                               en_d=1'b0;
                             case(fsm1_st)
                               ST_A : if(startfsm_1) begin 
                                                     en_a=1'b1;
                                                     fsm1_st_nxt = ST_B; end
                                       else fsm1_st_nxt = ST_A;
                               ST_B: begin 
                                                 en_a=1'b1;
                                                 fsm1_st_nxt = ST_C; end 
                               ST_C: begin  en_a=1'b1;
                                             if(three_only) fsm1_st_nxt = ST_A
                                              else fsm1_st_nxt = ST_D; end 
                               ST_D: begin 
                                                 en_a=1'b1;
                                                 fsm1_st_nxt = ST_A; end 
                               default: fsm1_st_nxt = ST_A;
                             endcase
                           end 
                               
// FSM-2// Handling the Muxing and Multiplication and regiustering the Multiplied Values///
                           typedef enum logic [2:0] {ZERO, ONE, TWO, THREE, FOUR, FIVE} state_2;
                           state_2 fsm2_st, fsm2_st_nxt;

                           always@(posedge clk or posedge rst)
                             if(rst) fsm2_st <= '0;
                             else fsm2_st <= fsm2_st_nxt;

                           always_comb 
                             begin 
                               mux_sel1 = 1'b0;
                               mux_sel2 = 1'b0;
                               en_ab = 1'b0;
                               en_ac = 1'b0;
                               en_ad = 1'b0;
                               en_bc = 1'b0;
                               en_bd = 1'b0;
                               en_cd = 1'b0;
                               case(fsm2_st)
                                 ZERO: begin //AB
                                   if(start_fsm2) begin 
                                         fsm2_st_nxt = ONE;
                                         mux_sel1 = 2'b00; // select A
                                         mux_sel2= 2'b00; // select B
                                         // mux1_op * mux2_op = mul_op
                                         en_ab = 1'b1; // Register this multiplication // mul_op
                                   end 
                                   else  fsm2_st_nxt = ZERO;

                                   ONE: begin //AC
                                         mux_sel1 = 2'b00; // select A
                                         mux_sel2= 2'b01; // select B
                                         // mux1_op * mux2_op = mul_op
                                         en_ac = 1'b1; // Register this multiplication // mul_op
                                     if(three_only) fsm2_st_nxt = ONE;
                                     else fsm2_st_nxt = THREE;
                                   end 
                                   TWO:begin //AD
                                         mux_sel1 = 2'b00; // select A
                                         mux_sel2= 2'b10; // select D
                                         // mux1_op * mux2_op = mul_op
                                         en_ad = 1'b1; // Register this multiplication // mul_op
                                        fsm2_st_nxt = THREE;
                                  THREE: begin //BC
                                         mux_sel1 = 2'b01; // select B
                                         mux_sel2= 2'b01; // select C
                                         // mux1_op * mux2_op = mul_op
                                         en_bc = 1'b1; // Register this multiplication // mul_op
                                        if(three_only) fsm2_st_nxt = ZERO;
                                         else fsm2_st_nxt = FOUR;
                                        end
                                  FOUR: begin //BD
                                         mux_sel1 = 2'b01; // select B
                                         mux_sel2= 2'b10; // select D
                                         // mux1_op * mux2_op = mul_op
                                         en_bd = 1'b1; // Register this multiplication // mul_op
                                    fsm2_st_nxt = FIVE;    end 
                                  FIVE: begin //CD
                                         mux_sel1 = 2'b10; // select C
                                         mux_sel2= 2'b10; // select D
                                         // mux1_op * mux2_op = mul_op
                                         en_cd = 1'b1; // Register this multiplication // mul_op
                                        fsm2_st_nxt = ZERO;
                                  end
                                     default:fsm2_st_nxt = ZERO;
                             endcase
                        end

 //FSM-3// Handling the final Output MUX select .

                                   typedef enum logic [1:0] {ST_NUM0, ST_NUM1, ST_NUM2, ST_NONum) state_3;
                                    state_3 fsm3_st,fsm3_st_nxt;

                                    always@(posedge clk or posedge rst)
                                          if(rst) fsm3_st <= ST_NUM0;
                                          else fsm3_st <= fsm3_st_nxt;


                                    always_comb 
                                      begin 
                                          mux_sel3=1'b0;
                                        case(fsm3_st)
                                        ST_NUM0: begin 
                                          if(start_fsm3) begin 
                                                          mux_sel3= 2'b00;
                                            if(three_only) fsm3_st_nxt= ST_NoNum;
                                            else fsm3_st_nxt = ST_NUM1;
                                          end
                                        ST_NUM1: begin 
                                                mux_sel3=2'b01;
                                                fsm3_st_nxt = ST_NUM2;
                                              end 
                                        ST_NUM2: begin 
                                                mux_sel3=2'b10;
                                                fsm3_st_nxt = ST_NUM0;
                                              end 
                                        ST_NoNum: begin 
                                                mux_sel3=2'b11;
                                                fsm3_st_nxt = ST_NUM0;
                                              end 
                                         default:  sm3_st_nxt = ST_NUM0;
                                      endcase   

                                        end 

    endmodule 
                                                          
                                   
            
                                                     
                             
                             
                                
