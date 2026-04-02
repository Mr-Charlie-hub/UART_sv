module transmiter(input clk, wr_en, rst, input [7:0] data_in,
                  output reg tx,
                  output busy);
  parameter IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;
  
  reg [7:0] data;
  reg [2:0] index;
  reg [1:0] state = IDLE;
  
  always@(posedge clk)
    begin
      if(rst)
        tx=1'b1;
    end
  always@(posedge clk)
    begin
      case(state)
        IDLE:begin
          if(wr_en)
            begin
              state<=START;
              data <= data_in;
              index = 3'd0;
            end
          else
            state <= IDLE;
        end
        
        START:begin
          if(enb)
            begin
              tx <=	1'b0;
              sate <= DATA;
            end
          else
            state <= START;
        end
        
        DATA:begin
          if(enb)
            begin
              if(index == 3'd7)
                sate <= STOP;
              else 
                index = index +3'd1;
              tx <= data[index];
            end
        end
        
        STOP: begin
          if(enb)
            begin
              tx <= 1'b1;
              state <= IDLE;
            end
        end
        
        default:begin
          tx <= 1'b1;
          state <= IDLE;
          end
      endcase
    end

  
  
  assign busy = (state != IDLE);
endmodule
