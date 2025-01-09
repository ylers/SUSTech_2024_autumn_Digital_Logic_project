
module audio(
input clk,
input wire[4:0] mode, 
output reg[0:0] music = 0
    );

/*
Count for clk to switch
*/

parameter do_low = 190840;
parameter re_low = 170259;
parameter me_low = 151685;
parameter fa_low = 143172;
parameter so_low = 127554;
parameter la_low = 113636;
parameter si_low = 101239;

parameter do = 93941;
parameter re = 85136;
parameter me = 75838;
parameter fa = 71582;
parameter so = 63776;
parameter la = 56818;
parameter si = 50618;

parameter do_high = 47778;
parameter re_high = 42567;
parameter me_high = 37921;
parameter fa_high = 36498;
parameter so_high = 31888;
parameter la_high = 28409;
parameter si_high = 25309;


parameter beat1 = 50 * 500000; // total needed periods for one note
parameter start = 85'b0010100101010000100101010000010011000001000000100101010011000110101101010010011100001;
parameter length1 = 17;

parameter beat2 = 50 * 500000; // total needed periods for one note
parameter clean = 80'b00001000010010100101001100011000101000000010000100000110001100010000100000100000;
parameter length2 = 16;


parameter beat3 = 50 * 500000; // total needed periods for one note
parameter mode1 = 35'b01000010010101001011011000110101110;
parameter length3 = 7;

parameter beat4 = 50 * 500000; // total needed periods for one note
parameter mode2 = 15'b010001111101000;
parameter length4 = 3;

parameter beat5 = 50 * 500000; // total needed periods for one note
parameter mode3 = 25'b0100000000010000000001000;
parameter length5 = 5;

parameter beat6 = 50 * 500000; // total needed periods for one note
parameter modeSilence = 100'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
parameter lengthSilence = 20;
localparam CHANGE = 2'b01,
PLAY = 2'b10;
reg[1:0] state = 0;


integer index = 0;  // melody[index,index+4] stands for current note
integer clkPeriodCount = 0;
integer noteCount = 0;
integer countForcurrentNote = 0;
integer totalPeriodsOneNote = beat1;
parameter silence = beat1<<9;





integer currentLength = 0;
reg [0:0] isSilence = 0;
reg [0:0] isCycle = 0;
reg [5:0] last_mode = 0;
reg[0:0] isEnd = 1;
reg[200:0] melody;
reg [31:0] freq;  // store current needed note(counts for clk to switch)
always @(posedge clk) begin
    if (mode != last_mode) begin
        last_mode <= mode;
        state <= CHANGE;
    end    
    
     else if (state == CHANGE) begin
        music <= 0;

        index <= 0;
        clkPeriodCount <= 0;
        countForcurrentNote <= 0;
        noteCount <= 0;
        state <= PLAY;
        isEnd <= 0;

        if (mode == 2) 
            isCycle <= 1;
        else 
            isCycle <= 0;

        if (mode == 5'b00101) begin // wind1
            currentLength <= length1;
            melody <= start;
            totalPeriodsOneNote <= beat1;
            isSilence <= 0;
        end
        else if (mode == 5'b00110) begin // wind2
            currentLength <= length2;
            melody <= clean;
            totalPeriodsOneNote <= beat2;
                        isSilence <= 0;

        end
        else if (mode == 5'b00111) begin // wind3
            currentLength <= length3;
            melody <= mode1;
            totalPeriodsOneNote <= beat3;
                        isSilence <= 0;

        end
        else begin 
            currentLength <= lengthSilence;
            melody <= modeSilence;
            totalPeriodsOneNote <= beat1;
            isSilence <= 0;
            isEnd <= 0;
        end
    end
    else if (state == PLAY) begin
        if (clkPeriodCount <= freq) begin
            clkPeriodCount <= clkPeriodCount + 1;
        end else begin
            clkPeriodCount <= 0;
            if (!isSilence)  music <= ~music;
            else music <= 0;

        end

        if (countForcurrentNote < totalPeriodsOneNote) begin
            countForcurrentNote <= countForcurrentNote + 1;
        end else begin
            countForcurrentNote <= 0;
            index <= index + 1;
            noteCount <= noteCount + 1;
        end

        if ((noteCount >= currentLength || index >= currentLength) && !isCycle) begin 
            isEnd <= 1;
        end else if ((noteCount >= currentLength || index >= currentLength) && isCycle) begin 
            last_mode <= 0;
            index <= 0;
            noteCount <= 0;
        end
    end


end


always @ * begin
if(isEnd || mode == 3'b000)
freq = silence;
else
case(melody[index * 5 +4 -:5])
5'd0 : freq = silence;
5'd1 : freq = do_low;
5'd2 : freq = re_low;
5'd3 : freq = me_low;
5'd4 : freq = fa_low;
5'd5 : freq = so_low;
5'd6 : freq = la_low;
5'd7 : freq = si_low;
5'd8 : freq = do;
5'd9 : freq = re;
5'd10 : freq = me;
5'd11: freq = fa;
5'd12 : freq = so;
5'd13 : freq = la;
5'd14 : freq = si;
5'd15 : freq = do_high;
5'd16 : freq = re_high;
5'd17 : freq = me_high;
5'd18 : freq = fa_high;
5'd19 : freq = so_high;
5'd20 : freq = la_high;
5'd21 : freq = si_high;
default : freq = silence;
endcase
end


// assign Outstate = state;

endmodule