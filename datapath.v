module datapath(
    input clk,
    input resetn,
	//mouse
	input [2:0] raw_x,
	input [2:0] raw_y,
	//gameplay
		//for to place pieces
		output reg [5:0] piece,
		
		//what phase you are on
		input [2:0] current_phase,
		
		input [1:0]command, //tells the controler that you will capture a piece or you have just moved your piece.		
		//tells the game someone one
		output reg win_flag,
	
		input go, //like an enter button
		output reg [2:0] mouse_x,
		output reg [2:0] mouse_y,
				
	//debuging 
		output [11:0] ledr,

//board registers size is 8x8 x 6
	output reg [384:0] board//to access the board memory, do (x + y*8 ) * 6
    );
    
	
    // input registers
	reg [2:0] c_r;
	reg [7:0] x_r;
	reg [6:0] y_r;

	
	/*
		information on the pieces
		000000 - Empty
		111111 - Cannot move to
		first bit is 0 or 1, red or blue team respectivly
		 00001 - (2) x2
		 00010 - (3) x2 begin
		 00011 - (9) x1 
		 00100 - (10)x1 
		 00101 - (s) x1 
		 00111 - (b) x2 
		 01000 - (f) x1
	*/
	
	
	//score tracker
	reg [50:0] score;
	
	
	//Save positions
	reg [384:0] pos;
	
	// Mouses should be inputs?
	// mouse_y should be SW[7:4]
	// mouse_x should be SW[3:0]
	
	//turn counter
	reg turn;
	
	//for capturing
	localparam
	C_CAPTURE = 2'b00,
	C_DIE	= 2'b01,
	C_TRADE= 2'b10;
	
	localparam
		//drawing states
		REMOVE_SQUARE = 2'd0, // Change a square to be Black
		DRAW_SQUARE = 2'd1,
		DRAW_LETTER = 2'd2,
		DRAW_CURSOR = 2'd3;
		
	localparam
		//moving states
		S_P1_START = 3'd0,
		S_P2_START = 3'd1,
		S_TURN =  3'd2,
		S_MOVE =  3'd3,
		S_CAP =   3'd4,
		S_CAP2 =  3'd5,
		S_STATE1 =  3'd6,
		S_DEAD =   3'd7;
		
	
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
		
	assign ledr[11:6] = board[ pos+:6];
	assign ledr[2:0] = mouse_y;
	assign ledr[5:3] = mouse_x;
	//assign ledr[5:0] = board[ (mouse_x[2:0] + mouse_y[2:0] * 4'd8) * 4'd6 +:6];
	//GAME LOGIC! including placing pieces down
	always@(posedge clk) begin
		if(!resetn) begin
			board = 1'b0;
			pos <= 1'b0;
		end 
		else begin
			//if (go)
			pos <= (raw_x[2:0] + raw_y[2:0] * 4'd8) * 4'd6;
			
			case (current_phase)
				S_P1_START: begin
					//check if button is pressed, your x value is in the left side, and you are choosing an empty spot
					
					// if (go ...) pos <= 1'b1;
					//
					
					if (go  && (raw_x[2:0] < 3'd4) && board[ pos+:6] == 1'b0 && (raw_y[2:0]<4'd7)) begin
						//add pieces to the game board memory
						//loads scout then 3 then 9 and so on...
						if (piece < 2'd2)
						begin
							board[ pos+:6] <= {1'b0,U_2};
						end
						else if (piece < 4'd4) board[ pos+:6] <= {1'b0,U_3};//(3)
						else if (piece < 4'd5) board[ pos+:6] <= {1'b0,U_9}; //(9)
						else if (piece < 4'd6) board[ pos+:6] <= {1'b0,U_10}; //(10)
						else if (piece < 4'd7) board[ pos+:6] <= {1'b0,U_S}; //(s)
						else if (piece < 4'd9) board[ pos+:6] <= {1'b0,U_B}; //(b)
						else				board[ pos+:6] <= {1'b0,U_F}; //(f)
						piece <= piece + 1'b1;
					end
				end
				S_P2_START: begin
					//check if button is pressed, your x value is in the right side, and you are choosing an empty spot
					if (go && raw_x[2:0] >= 3'd4 && board[ pos+:6] == 1'b0&&raw_y[2:0]<4'd7) begin
						//add pieces to the game board memory
						//loads scout then 3 then 9 and so on...
						if (piece < 5'd12) 		board[ pos+:6] <= {1'b1,U_2}; //(2)
						else if (piece < 5'd14) board[ pos+:6] <= {1'b1,U_3}; //(3)
						else if (piece < 5'd15) board[ pos+:6] <= {1'b1,U_9}; //(9)
						else if (piece < 5'd16) board[ pos+:6] <= {1'b1,U_10}; //(10)
						else if (piece < 5'd17) board[ pos+:6] <= {1'b1,U_S}; //(s)
						else if (piece < 5'd19) board[ pos+:6] <= {1'b1,U_B}; //(b)
						else				board[ pos+:6] <= {1'b1,U_F}; //(f)
						piece <= piece + 1'b1;
					end
				end
				//S_STATE1: not used here
				S_TURN: begin	
					mouse_y[2:0] <= raw_y[2:0];				
					mouse_x[2:0] <= raw_x[2:0];
				end	
					//updates target space first
				S_CAP:
				begin
					case (command)
						//overwrite the target spot
						C_CAPTURE:
						begin
							board[ pos+:6] <= board[ (mouse_x + mouse_y * 4'd8) * 4'd6 +: 6];
						end
						//your unit dies
						C_DIE: board[ (mouse_x + mouse_y * 4'd8) * 4'd6 +:6] <= 6'b000000;
						//both unit dies
						C_TRADE:
						begin
							board[ (mouse_x + mouse_y * 4'd8) * 4'd6+:6] <= 6'b000000;
							board[ pos+:6] <= 6'b000000;
						end
					endcase
				end
				//updates your last position
				S_CAP2:
				begin
					case (command)
						//overwrite the target spot for capture
						C_CAPTURE:
						begin
							board[ (mouse_x + mouse_y * 4'd8) * 4'd6+: 6] <= 6'b000000;
						end
					endcase
				end
			endcase
		end
	
    // Registers a, b, c, x with respective input logic
        if(!resetn) begin
				piece <= 1'd0;
				board <= 336'b100001_100010_000000_000000_000000_000000_000000_000000_100010_100011_000000_000000_000000_000000_000000_000000_100100_100100_000000_111111_111111_000000_000111_000110_100101_100111_000000_000000_000000_000000_000101_000101_100000_100000_000000_111111_111111_000000_000100_000100_000000_000000_000000_000000_000000_000000_000011_000010_000000_000000_000000_000000_000000_000000_000010_000001;
        end
      end
    
endmodule
