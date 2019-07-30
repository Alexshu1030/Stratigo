module control(
	input clk, 
	input resetn,
	input go, 
	//to go back 1 state sometimes
	input back,
	output [11:0]ledr,// FOR DEBUGGING
	
	//gameplay
		input [5:0] piece,
		//moving states
		output reg [2:0]current_phase,
		output reg [1:0]command,
		input win_flag,
		output reg turn_player,
		input [384:0] board,
		input [2:0] raw_x,
		input [2:0] raw_y,
		input [2:0] mouse_x,
		input [2:0] mouse_y
	);		
	
	
	//drawing states	
	reg [3:0] current_state;
	//moving states
	reg [2:0] next_phase;
	reg temp; // DEBUGGING
	reg [384:0] pos;
	
	//for command when moving
	localparam
		C_CAPTURE = 2'b00,
		C_DIE	= 2'b01,
		C_TRADE= 2'b10;
	localparam
		//units use {1'bx,y} where x = {0,1} (the team) and y is one of the following excluding the last 2
		U_F	=5'b00001,
		U_B	=5'b00010,
		U_S	=5'b00011,
		U_2 =5'b00100,
		U_3	=5'b00101,
		U_9	=5'b00110,
		U_10=5'b00111,
		U_P = 5'b01000,
		U_1 = 5'b01001,
		U_W = 5'b01010,
		U_I = 5'b01011,
		U_N = 5'b01100,
		U_BLANK = 6'b000000,
		U_NMOVE = 6'b111111;
	localparam
			//moving states
			S_P1_START = 3'd0,
			S_P2_START = 3'd1,
			S_TURN =  3'd2,
			S_MOVE =  3'd3,
			S_CAP =   3'd4,
			S_CAP2 =  3'd5,
			S_STATE1 =  3'd6,
			S_DEAD =   3'd7,
			
			
			//drawing states
			S_LOAD_X = 			4'd7,
			S_LOAD_X_WAIT = 	4'd1,
			S_LOAD_Y = 			4'd2,
			S_LOAD_Y_WAIT = 	4'd3,
			S_LOAD_COLOUR = 	4'd4,
			S_LOAD_COLOUR_WAIT =4'd5,
			S_LOAD_COLOUR2 = 	4'd6,
			S_LOAD_COLOUR2_WAIT=4'd7,
			S_CYCLE_0 = 		4'd8,
			S_START =			4'd0;
			   
	// State logic AKA State table
	assign ledr[2:0] = current_phase;
	assign ledr[9:3] = mouse_y;
	assign ledr[9:3] = mouse_y;
	always @(posedge clk)
	begin
		pos <= (raw_x[2:0] + raw_y[2:0] * 4'd8) * 4'd6;
		//moving states
		case (current_phase)
			S_P1_START: 
			begin
				next_phase <= (piece >= 6'b001010) ? S_P2_START : S_P1_START;//count up then....
			end
			S_P2_START: 
			begin
				next_phase <= (piece >= 6'b010100) ? S_STATE1 : S_P2_START;//count up for piece
				turn_player	<= 1'b1;
			end
			S_STATE1:
			begin
				turn_player <= 1'b0;
				next_phase<=S_TURN
			end
			S_TURN: 	
			begin
				next_phase <= S_TURN;
				if (go && board[ pos+:6] != 6'b000000 && board[ pos+:6] != 6'b111111)
					//check if it is your unit
					if (board[pos+:1]  == turn_player)
					//check if it is a movable unit
						if (board[ pos+1 +:5] != U_B && board[ pos+1 +:5] != U_F)			
							begin
							next_phase <= S_MOVE;		
							end
			end
			S_MOVE: begin	
				next_phase <= S_MOVE;		
				if (back)
					next_phase <= S__TURN;
				if (go) begin
					//check if in range
					//checks the absolute value of the diffrence of x adds it to the abs of y and check if it equals 1
					if ((raw_x[2:0] > mouse_x ? raw_x[2:0] - mouse_x : mouse_x - raw_x[2:0]) + (raw_y[2:0] > mouse_y ? raw_y[2:0] - mouse_y : mouse_y - raw_y[2:0]) == 1'b1)
					begin	
						//checks if moving to a blank spot
						if (board[ pos+:6] == 6'b000000) begin
							command <= C_CAPTURE;
							next_phase <=S_CAP;
						end
						//checks if capturing check if not 111111 and the last most digit is not the same as  turn player
						else if (board[ pos+:6] != 6'b111111 && board[ pos+:1] != turn_player) begin
							next_phase <=S_CAP;
							//checks if they are the same piece
							if (board[ (mouse_x + mouse_y * 4'd8) * 4'd6+1 +:5] == board[ pos+1 +:5])
							begin
								//both dies
								command <= C_TRADE;
							end
							// bomb
							else if (board[ pos+1 +:5] == U_B)
								command <= C_DIE;
							//flag
							else if (board[ pos+1 +:5] == U_F) begin
								command <= C_CAPTURE;
							end
							//spy (it always dies from an attack)
							else if (board[ pos+1 +:5] == U_S)begin
								command <= C_CAPTURE;
							end
							//if you are a 3 check for bomb
							else if (board[ (mouse_x + mouse_y * 4'd8) * 4'd6+1 +:5] == U_3 && board[ pos+1 +:5] == U_B)
							begin
								//destroy bomb
								command <= C_CAPTURE;
							end
							//if you are a spy check for 10
							else if (board[ (mouse_x + mouse_y * 4'd8) * 4'd6+1 +:5] == U_S && board[ pos+1 +:5] == U_10)
							begin
								//destroy 10
								command <= C_CAPTURE;
							end
							//check if you are greater
							if (board[ (mouse_x + mouse_y * 4'd8) * 4'd6+1 +:5] > board[ pos+ 1 +:5])
							begin
								//destroy target
								command <= C_CAPTURE;
							end
							//else you die
							else
								command <= C_DIE;
						end
					end
				end
			end
			S_CAP: next_phase <= S_CAP2;
			S_CAP2: 
				begin 
				next_phase <= S_TURN;
				turn_player <= ~turn_player;
				end
			
		endcase
		if (!resetn) begin
			current_phase <= S_TURN;
			next_phase <= S_TURN;
			end
		else begin
			current_phase <= next_phase;
			end
	end
endmodule
