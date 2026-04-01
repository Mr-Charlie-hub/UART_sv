// Author : Harisha B C
// Date   : 1-Apr-2026

//UART Transmitter code
module uart_tx(
	input logic 		clk, 		// clock 
  	input logic 		rstn,		// active low reset
  	input logic 		tx_start,	// transaction start signal
  	input logic 		tick,		// tick input from baud_rate_gen
  	input logic [7:0]	data_in,	// data input of 8-bit (parallel)
  
  	output logic 		txd,		// tx_data in serial
  	output logic 		tx_done		// tx_done output pin
);
  
  // State encoding for FSM using enum
  typedef enum logic [1:0]{
    IDLE,
    START,
    TRANS,
    STOP
  } state_t;
  
  // variables of state_t type for present and next
  state_t ps, ns;
  
  // Registers defined for data storing purpose
  logic [7:0] 	sbuf_reg, sbuf_next;
  logic [2:0] 	count_reg, count_next;
  logic 		tx_reg, tx_next;
  logic 		tx_done_next;
  
  // Sequential block
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      ps		<= IDLE;	// resetted to IDLE state
      sbuf_reg	<= '0;		// serial buffer register reset to zero
      count_reg <= '0;		// counter register 
      tx_reg	<= 1'b1;	// 
      tx_done	<= 1'b0;
    end else begin
      ps 		<= ns;
      sbuf_reg	<= sbuf_next;
      count_reg	<= count_next;
      tx_reg	<= tx_next;
      tx_done	<= tx_done_next;
    end
  end
  
  // Combinational block
  always_comb begin
    // defaults
    ns				= ps;
    sbuf_next		= sbuf_reg;
    count_next		= count_reg;
    tx_next			= tx_reg;
    tx_done_next	= 1'b0;
    
    case (ps)
      IDLE: begin
        tx_next = 1'b1;
        if (tx_start)
          ns = START;
      end
      
      START: begin
        tx_next = 1'b0;
        if (tick) begin
          sbuf_next 	= data_in;
          count_next	= 0;
          ns			= TRANS;
        end
      end
      
      TRANS: begin
        tx_next = sbuf_reg[0];
        if(tick) begin
          sbuf_next	= {1'b0, sbuf_reg[7:1]};
          
          if(count_reg == 3'd7)
            ns = STOP;
          else
            count_next = count_reg + 1;
        end
      end
      
      STOP: begin
        tx_next = 1'b1;
        if(tick) begin
          tx_done_next = 1'b1;
          ns = IDLE;
        end
      end
    endcase
  end
  
  assign txd = tx_reg;
  
endmodule