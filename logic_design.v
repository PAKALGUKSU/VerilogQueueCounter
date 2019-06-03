module logic_design (input [4:0]SW, input CLOCK_50,output reg [0:6]HEX0, output reg [0:6]HEX1, output reg [0:6]HEX3); 
    wire SW0;						//wire to get enable signal from pulGen module
    reg[2:0] curState;				//register to store current state
    reg[2:0] NextState;				//register to store next state
    reg[2:0] inputNum;				//register to store value to distinguish which switch is turned on
    wire inputWire;					//wire to tie switch
    parameter S0 = 3'b000; parameter S4 = 3'b001; parameter S8 = 3'b010; 		//parameters to distinguish states
    parameter S12 = 3'b011; parameter S16 = 3'b100; parameter S20 = 3'b101;
    
    parameter Seg9 = 7'b000_1100; parameter Seg8 = 7'b000_0000; parameter Seg7 = 7'b000_1111;		//parameters for 7-segment display
    parameter Seg6 = 7'b010_0000; parameter Seg5 = 7'b010_0100;
    parameter Seg4 = 7'b100_1100; parameter Seg3 = 7'b000_0110; parameter Seg2 = 7'b001_0010;
    parameter Seg1 = 7'b100_1111; parameter Seg0 = 7'b000_0001;
   
   parameter sw0 = 2'b00; parameter sw1 = 2'b01; parameter sw2 = 2'b10; parameter sw3 = 2'b11;		//parameters to distinguish input switch
   
   assign inputWire = SW[0]|SW[1]|SW[2]|SW[3];				

   initial
   begin
      curState <= S0;		//initializing
      NextState <= S0;
      inputNum <= 2'b0;
   end

    pulGen(inputWire, CLOCK_50, SW[4], SW0);                //utilizing given pulse generating code
    

    always@(posedge SW[0] or posedge SW[1] or posedge SW[2] or posedge SW[3])		//get data about which switch is turned on
    begin
      if(SW[0] == 1)
         inputNum <= sw0;
      if(SW[1] == 1)
         inputNum <= sw1;
      if(SW[2] == 1)
         inputNum <= sw2;
      if(SW[3] == 1)
         inputNum <= sw3;
    end
    

    
    always@(posedge SW[4], posedge CLOCK_50)
    begin
        if(SW[4])
            curState <= S0;                  //if SW[4] turend on, initialize
        else                    
            curState <= NextState;      	 //if not, change to NextState
    end
   
    always@(*) 
    begin
        case(curState)
        S0: begin 
            if(SW0)			//SW0 is 1 only at negedge of switch(1->0)
            begin 
               case(inputNum)		//decides next state based on curState and input switch
                  sw0 : NextState <= S4;
                  sw1 : NextState <= S8;
                  sw2 : NextState <= S12;
                  sw3 : NextState <= S0;
               endcase
            end
            else NextState = S0; 
        end     
        S4: begin 
            if(SW0) 
            begin 
               case(inputNum)
                  sw0 : NextState <= S8;
                  sw1 : NextState <= S12;
                  sw2 : NextState <= S16;
                  sw3 : NextState <= S4;
               endcase
            end
            else NextState = S4; 
        end  
        S8: begin 
            if(SW0) 
            begin 
               case(inputNum)
                  sw0 : NextState <= S12;
                  sw1 : NextState <= S16;
                  sw2 : NextState <= S20;
                  sw3 : NextState <= S0;
               endcase
            end
            else NextState = S8; 
        end  
        S12: begin 
            if(SW0) 
            begin 
               case(inputNum)
                  sw0 : NextState <= S16;
                  sw1 : NextState <= S20;
                  sw2 : NextState <= S12;
                  sw3 : NextState <= S4;
               endcase
            end
            else NextState = S12; 
        end  
        S16: begin 
            if(SW0) 
            begin 
               case(inputNum)
                  sw0 : NextState <= S20;
                  sw1 : NextState <= S16;
                  sw2 : NextState <= S16;
                  sw3 : NextState <= S8;
               endcase
            end
            else NextState = S16; 
        end  
        S20: begin 
            if(SW0) 
            begin 
               case(inputNum)
                  sw0 : NextState <= S20;
                  sw1 : NextState <= S20;
                  sw2 : NextState <= S20;
                  sw3 : NextState <= S12;
               endcase
            end
            else NextState = S20; 
        end  
      
        default : NextState = S0;
        endcase 
    end 
    
    always@(*) 
    begin
        case(curState)		//displays 7-segment based on current state                                                         
         S0: begin HEX3 = Seg0; HEX1 = Seg0; HEX0 = Seg0; end
         S4: begin HEX3 = Seg0; HEX1 = Seg0; HEX0 = Seg4; end
         S8: begin HEX3 = Seg1; HEX1 = Seg0; HEX0 = Seg8; end
         S12: begin HEX3 = Seg1; HEX1 = Seg1; HEX0 = Seg2; end
         S16: begin HEX3 = Seg2; HEX1 = Seg1; HEX0 = Seg6; end
         S20: begin HEX3 = Seg2; HEX1 = Seg2; HEX0 = Seg0; end
        endcase
    end 

endmodule
    
    
module pulGen(in, clk, rst, out);      //parameters : in = inputWire, clk = CLOCK_50, rst = SW[4], out = SW0
   output reg out;
   input clk, in, rst;
   reg [1:0] currstate0;
   reg [1:0] nextstate0;
   integer cnt;
   integer ncnt;
   parameter out_S0 = 2'b00; parameter out_S1 = 2'b01; parameter out_S2 = 2'b10;

   always @(posedge clk)
   begin
   if(rst)		//reset
      begin
      currstate0 <= out_S0; cnt<=0;
      end
   else
      begin
      currstate0 <= nextstate0; cnt <= ncnt; 
      end
   end
    
   always @(*)
   begin
   case(currstate0)
      out_S0 : begin
         if(in) begin nextstate0 = out_S1; ncnt = 0; end             //if some switch is turned on, go to out_S1
         else   begin nextstate0 = out_S0; ncnt = 0; end
      end
      out_S1 : begin 
         if(in) begin                      //if still turned on, ncnt increases
            nextstate0 = out_S1;
            ncnt = cnt + 1;
         end
         else begin                        //if turned off(negedge) after sufficient time has spent, go to out_S2
            nextstate0 = out_S0; 
            if(cnt >= 100)
               nextstate0 = out_S2;
            end
         end
        out_S2 : begin nextstate0 = out_S0; ncnt = 0; end
            default : nextstate0 = out_S0;
        endcase
    end

   always @(*)
   begin
      if (currstate0 == out_S2) out = 1'b1;		//generates pulse sensitive to negedge of switch
      else out = 1'b0;
   end
      
endmodule