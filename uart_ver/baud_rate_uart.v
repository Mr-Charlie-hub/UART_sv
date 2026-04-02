module baud_rate(input clk, output tx_en, rx_en);
reg [12:0] tx_counter=12'd0;
reg[9:0] rx_counter=9'd0;

always@(posedge clk)
    begin 
     if(tx_counter == 5208) // 50 mhz clk and 9600 baudrate so
        tx_counter = 0;    // 50*10^6 / 9600 =5208
     else 
        tx_counter += 1'b1; 
    end

always@(posedge clk)
      begin
         if(rx_counter == 325) // same but recevier samples more so 
            rx_counter = 0;    // 50 *10^6 /9600*16 = 325
         else
            rx_counter += 1'b1;
      end
assign tx_en = (tx_counter == 0) ? 1'b1 ; 1'b0;
assign rx_en = (rx_counter == 0) ? 1'b1 : 1'b0;
endmodule
