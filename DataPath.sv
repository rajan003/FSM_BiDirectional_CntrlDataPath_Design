  //This is DATAPath model for AnyType of Control Model///
/// The Data Path is also devided into 3 parts as control.

module #parameter(DATA_WIDTH=4) data_path (

      input logic clk,
      input logic rst,

      /// Serial Input-output///
  input logic [3:0] serial_in;
  input logic [3:0] serial_out;
    
      ///First Block control signal// FSM-1
      input logic en_a, en_b,en_c,en_d;

      // Second Block Control SIgnal// FSM-2
    input logic [1:0] mux_sel1, mux_sel2;
    input logic en_ab, en_ac, en_ad,en_bc,en_bd,en_cd;

      // Third Control signal/// FSM-3
  input logic [1:0] mux_sel3 );

  logic A,B,C,D; /// Rsgiter to sample initial Values///
  ///DataPath-1// FSM-1 Control// Dat Path// Initial Sampling Flops//
      logic 
      always@(posedge clk or posedge rst)
        if(rst)  begin 
            A <='0;
            B <= '0;
            C <= '0;
            D <= '0;
        end 
        else begin 
            if(en_a) A <= serial_in;
            if(en_b) B <= serial_in;
            if(en_c) C <= serial_in;
            if(en_d) D <= serial_in;
        end

//DataPath-2/// FSM-Control-2/// Muxing logic 
  logic [3:0] mul_1, mul_2;
  logic [3:0] mul;  /// Overflow in some scenarios//
  always_comb begin : Data_2_mux_line
      case(mux_sel1)
        2'b00: mul_1=A;
        2'b00: mul_1=B;
        2'b00: mul_1=C;
        default: mul_1= 'x;
      endcase

    case(mux_sel2)
        2'b00: mul_2=B;
        2'b00: mul_2=C;
        2'b00: mul_2=D;
        default: mul_2= 'x;
      endcase
    mul = mul1*mul2;
  end 

  logic [3:0] ab,ac,ad,bc,bc,cd;
  always@(posedge clk or posedge rst)
    if(rst) begin 
        ab <= '0;
        ac <= '0;
        ad <= '0;
        bc <= '0;
        bd <= '0;
        cd <= '0;
    end 
  else begin 
    if(en_ab) ab <= mul;
    if(en_ac) ac <= mul;
    if(en_ac) ad <= mul;
    if(en_ac) bc <= mul;
    if(en_ac) bc <= mul;
    if(en_ac) cd <= mul;
  end 

  logic [3:0] sum1, sum2, sum3, nosum;

  assign sum1= ab+ac;
  assign sum2= ad+bc;
  assign sum3=bd+cd;
  assign nosum= bc;

  ///DataPath-3// FSM-3 Control Signal ////
  always_comb begin 
    case(mux_sel3)
      2'b00: serial_out=sum1;
      2'b01: serial_out=sum2;
      2'b10: serial_out=sum3;
      2'b11: serial_out=nosum;
      default: serial_out='x;
    endcase
  end

endmodule
    


  
  
