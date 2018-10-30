//SW[0] reset when 0
//SW[1] input signal

//KEY[0] clock signal

//LEDR[3:0] displays current state
//LEDR[9] displays output

module sequence_detector(SW, KEY, LEDR);
    input [1:0] SW;
    input [0:0] KEY;
    output [9:0] LEDR;

    wire w, clock, resetn, out_light;
    
    reg [3:0] y_Q, Y_D; // y_Q represents current state, Y_D represents next state
    
    localparam A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100, F = 4'b0101, G = 4'b0110;
    
    assign w = SW[1];
    assign clock = ~KEY[0];
    assign resetn = SW[0];

    //State table
    //The state table should only contain the logic for state transitions
    //Do not mix in any output logic. The output logic should be handled separately.
    //This will make it easier to read, modify and debug the code.
    always@(*)
    begin: state_table
        case (y_Q)
            A: begin
                   if (!w) Y_D = A;
                   else Y_D = B;
               end
            B: begin
                   if(!w) Y_D = A;
                   else Y_D = C;
               end
            C: Y_D = w ? D : E;
            D: Y_D = w ? F : E;
            E: Y_D = w ? G : A;
            F: Y_D = w ? F : E;
            G: Y_D = w ? C : A;
            default: Y_D = A;
        endcase
    end // state_table
    
    // State Registers
    always @(posedge clock)
    begin: state_FFs
        if(resetn == 1'b0)
            y_Q <=  A; // Should set reset state to state A
        else
            y_Q <= Y_D;
    end // state_FFS

    // Output logic
    // Set out_light to 1 to turn on LED when in relevant states
    assign out_light = y_Q == F | y_Q == G;

    assign LEDR[9] = out_light;
    assign LEDR[3:0] = y_Q;
endmodule
