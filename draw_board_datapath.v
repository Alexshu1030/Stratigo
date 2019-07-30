module draw_board_datapath(
    input clk,
	input write,
	input update_x_y,
	output reg [2:0] colour,
    output reg [7:0] x,
    output reg [6:0] y, 
    output reg plot,
	output reg [14:0] long_counter,
	output reg [7:0] counter,
	inout reg [5:0] x_y_pos, // [5:3] is y, and [2:0] is x
	input [5:0] draw_value,
	input turn_player
    );
    
	wire [255:0] unit_pixels;
	
	char_decoder c_d1(
		.OUT(unit_pixels[255:0]),
		.IN(draw_value[4:0])
	);
	
    always@(posedge clk) begin
		if (update_x_y) begin
			x_y_pos = x_y_pos + 1'b1; 
		end
		else if (write) begin
			case(draw_value[4:0])
				5'b11000: begin // Draw board (White)
					x <= long_counter[7:0];
					y <= long_counter[14:8];
					colour <= 3'b111;
					plot <= 1'b1;
					long_counter <= long_counter + 1'b1;
				end
				5'b11100: begin // Draw player turn indicator
					x <= 8'd138 + counter[3:0];
					y <= 4'd30 + counter[7:4];
					colour <= turn_player ? 3'b100 : 3'b001;
					plot <= 1'b1;
					counter <= counter + 1'b1;
				end
				5'b00000: begin // Draw Empty Block (Black)
					x <= 1'b1 + x_y_pos[2:0]*5'd17 + counter[3:0];
					y <= 1'b1 + x_y_pos[5:3]*5'd17 + counter[7:4];
					colour <= 3'b000;
					plot <= 1'b1;
					counter <= counter + 1'b1;
				end
				5'b11111: begin // Draw unvisitable Block (White)
					x <= 1'b1 + x_y_pos[2:0]*5'd17 + counter[3:0];
					y <= 1'b1 + x_y_pos[5:3]*5'd17 + counter[7:4];
					colour <= 3'b111;
					plot <= 1'b1;
					counter <= counter + 1'b1;
				end
				// REPEATED CODE HERE, can just put in default
				5'b00001: begin // Draw Flag
					x <= 1'b1 + x_y_pos[2:0]*5'd17 + counter[3:0];
					y <= 1'b1 + x_y_pos[5:3]*5'd17 + counter[7:4];
					colour <= (unit_pixels[counter[3:0]+16*counter[7:4] +: 1] && draw_value[5:5] == turn_player) ? 3'b111 : (draw_value[5:5] ? 3'b100 : 3'b001);
					plot <= 1'b1; 
					counter <= counter + 1'b1;
				end
				5'b00010: begin // Draw Bomb
					x <= 1'b1 + x_y_pos[2:0]*5'd17 + counter[3:0];
					y <= 1'b1 + x_y_pos[5:3]*5'd17 + counter[7:4];
					colour <= (unit_pixels[counter[3:0]+16*counter[7:4] +: 1] && draw_value[5:5] == turn_player) ? 3'b111 : (draw_value[5:5] ? 3'b100 : 3'b001);
					plot <= 1'b1;
					counter <= counter + 1'b1;
				end
				5'b00011: begin // Draw Spy
					x <= 1'b1 + x_y_pos[2:0]*5'd17 + counter[3:0];
					y <= 1'b1 + x_y_pos[5:3]*5'd17 + counter[7:4];
					colour <= (unit_pixels[counter[3:0]+16*counter[7:4] +: 1] && draw_value[5:5] == turn_player) ? 3'b111 : (draw_value[5:5] ? 3'b100 : 3'b001);
					plot <= 1'b1;
					counter <= counter + 1'b1;
				end
				5'b00100: begin // Draw 2
					x <= 1'b1 + x_y_pos[2:0]*5'd17 + counter[3:0];
					y <= 1'b1 + x_y_pos[5:3]*5'd17 + counter[7:4];
					colour <= (unit_pixels[counter[3:0]+16*counter[7:4] +: 1] && draw_value[5:5] == turn_player) ? 3'b111 : (draw_value[5:5] ? 3'b100 : 3'b001);
					plot <= 1'b1;
					counter <= counter + 1'b1;
				end
				5'b00101: begin // Draw 3
					x <= 1'b1 + x_y_pos[2:0]*5'd17 + counter[3:0];
					y <= 1'b1 + x_y_pos[5:3]*5'd17 + counter[7:4];
					colour <= (unit_pixels[counter[3:0]+16*counter[7:4] +: 1] && draw_value[5:5] == turn_player) ? 3'b111 : (draw_value[5:5] ? 3'b100 : 3'b001);
					plot <= 1'b1;
					counter <= counter + 1'b1;
				end
				5'b00110: begin // Draw 9
					x <= 1'b1 + x_y_pos[2:0]*5'd17 + counter[3:0];
					y <= 1'b1 + x_y_pos[5:3]*5'd17 + counter[7:4];
					colour <= (unit_pixels[counter[3:0]+16*counter[7:4] +: 1] && draw_value[5:5] == turn_player) ? 3'b111 : (draw_value[5:5] ? 3'b100 : 3'b001);
					plot <= 1'b1;
					counter <= counter + 1'b1;
				end
				5'b00111: begin // Draw 10
					x <= 1'b1 + x_y_pos[2:0]*5'd17 + counter[3:0];
					y <= 1'b1 + x_y_pos[5:3]*5'd17 + counter[7:4];
					colour <= (unit_pixels[counter[3:0]+16*counter[7:4] +: 1] && draw_value[5:5] == turn_player) ? 3'b111 : (draw_value[5:5] ? 3'b100 : 3'b001);
					plot <= 1'b1;
					counter <= counter + 1'b1;
				end
				// default: begin
					// // Copy paste the draw_piece code here
					// if (highlight_signal && (selected_x == x_y_pos) && (selected_y == x_y_pos) begin
						// if (colour != 3'b111)
							// colour <= turn_player ? 3'b110 : 3'b011; // Draw a highlight colour depending on the player turn
					// end
				// end
			endcase
		end
	end
endmodule
