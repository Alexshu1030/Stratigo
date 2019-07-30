module draw_board_control(clk, board, long_counter, counter, x_y_pos, write, update_x_y, draw_value);
	input clk;
	input [384:0] board;
	input [14:0] long_counter;
	input [7:0] counter;              
	input [5:0] x_y_pos; // [5:3] is y, [2:0] is x
	output reg write;
	output reg update_x_y;
	output reg [5:0] draw_value;
	
	reg [2:0] current_state, next_state;
	
	localparam S_START = 3'd0,
			   S_DRAW_BOARD = 3'd1,
			   S_DRAW_PIECE = 3'd2,
			   S_UPDATE_X_Y = 3'd3,
			   S_DRAW_PLAYER_TURN = 3'd4;
			   
	// State logic AKA State table
	always @(posedge clk)
	begin
		case (current_state)
			S_START: next_state = clk ? S_DRAW_BOARD : S_START;
			S_DRAW_BOARD: begin
				if (long_counter == 15'b1111111_10001000)
					next_state = S_DRAW_PIECE;
				else
					next_state = S_DRAW_BOARD;
			end
			S_DRAW_PIECE: begin
				if (counter == 8'b11111111)
					next_state = S_UPDATE_X_Y;
				else
					next_state = S_DRAW_PIECE;
			end
			S_UPDATE_X_Y: next_state = S_DRAW_PIECE;
//			S_DRAW_PLAYER_TURN: begin
//				if (counter == 8'b11111111)
//					next_state = S_DRAW_PIECE;
//				else
//					next_state = S_DRAW_PLAYER_TURN;
//			end
		endcase
	end
	
	// Output Logic (i.e. Datapath control signals)
	always @(posedge clk)
	begin
		// By default make all our signals 0
		write = 1'b0;
		draw_value = 6'd0;
		update_x_y = 1'b0;
		case (current_state)
			S_DRAW_BOARD: begin
				write = 1'b1;
				draw_value = 6'b011000; // Some value that is different from piece values;
			end
			S_DRAW_PIECE: begin
				write = 1'b1;
				draw_value = board[(x_y_pos[2:0] + x_y_pos[5:3]*8)*6 +: 6];
			end
			S_UPDATE_X_Y: begin
				update_x_y = 1'b1;
			end
			S_DRAW_PLAYER_TURN: begin
				write = 1'b1;
				draw_value = 6'b011100;
			end
		endcase
	end
	
	// current_state register
	always @(posedge clk)
	begin
		current_state <= next_state; // No reset button
	end
endmodule
