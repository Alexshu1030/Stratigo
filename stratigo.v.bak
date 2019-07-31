module stratigo
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
			LEDR,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output  [17:0] LEDR;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;				//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	// Create the colour, x, y and plot wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire plot;
	wire [14:0] long_counter;
	wire [7:0] counter;
	wire [5:0] x_y_pos;
	wire write;
	wire update_x_y;
	wire [5:0] draw_value;
	wire resetn;
	wire turn_player;
	assign resetn = KEY[2];
	
	wire [384:0] board;
	
		//gameplay wires
	wire [5:0] piece;
	wire [2:0] current_phase;
	wire [1:0] command;
	wire win_flag;
	wire [2:0] mouse_x;
	wire [2:0] mouse_y;
	
	/*always @(*)
	begin
		if (KEY[1]) begin
			board[11:0] = 12'b000001_100011;
			board[53:48] = 6'b000100;
		end
		else begin
			board[11:0] = 12'b000111_100010;
			board[53:48] = 6'b000101;
		end
	end
	
	assign turn_player = (SW[1]);*/
	

	//for colour commands
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(plot),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and plot/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	
		draw_board_datapath board_path(
		.clk(CLOCK_50),
		.write(write),
		.update_x_y(update_x_y),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(plot),
		.long_counter(long_counter),
		.counter(counter),
		.x_y_pos(x_y_pos),
		.draw_value(draw_value),
		.turn_player(turn_player)
		);
	
	draw_board_control board_control(
		.clk(CLOCK_50),
		.board(board),
		.long_counter(long_counter), 
		.counter(counter),
		.x_y_pos(x_y_pos),
		.write(write), 
		.update_x_y(update_x_y), 
		.draw_value(draw_value)
		);
		
	   // Instansiate datapath
	datapath d0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.raw_x(SW[5:3]),
		.raw_y(SW[2:0]),
		
		//gameplay
		.piece(piece),
		.current_phase(current_phase),
		.command(command),
		.win_flag(win_flag),
		.go(~KEY[1]),
		.mouse_x(mouse_x),
		.mouse_y(mouse_y),
		//debugging
		.ledr(LEDR[17:12]),
		.board(board),
		);
	
    // Instansiate FSM control
    control c0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.go(~KEY[1]),
		.back(~KEY[0]),
		.ledr(LEDR[11:0]), // FOR DEBUGGING
		
		//gameplay
		.piece(piece),
		.current_phase(current_phase),
		.command(command),
		.win_flag(win_flag),
		.turn_player(turn_player),
		.board(board),
		.raw_x(SW[5:3]),
		.raw_y(SW[2:0]),
		.mouse_x(mouse_x),
		.mouse_y(mouse_y),
		);
    
endmodule


