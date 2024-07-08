; This version introduces adds scores. 10 points per hitting the paddle.
; CONSTANTS
RASTER=$9004

; POSSIBLE COLOURS
BLACK=0
WHITE=1
RED=2
CYAN=3
PURPLE=4
GREEN=5
BLUE=6
YELLOW=7

; KEYCODES
RIGHT_KC=$1D
DOWN_KC=$11

; GAME ASSETS
PADDLE_Y=22
SCORE_POS=$1E03 ; NEED TO REVISE
SCORE_COL_POS=$9603 ; NEEDS TO MATCH ABOVE


*=828 ; MAKE USE OF 190 EXTRA BYTES BY USING UP THE CASETTE BUFFER

START                   
        JSR CLEAR_SCREEN
        JSR INIT_GAME
        JMP MAIN_LOOP


PRINT_TEXT
        LDY #0
WRITE_TEXT
        LDA $(FB),Y       ;START AT POINTED ADDRESS
        BEQ TEXT_FINISHED ;IF BYTE IS 0 then we are done
        JSR $FFD2         ;PRINT CHAR IN ACCUMULATOR
        INY               ;INCREASE
        BNE WRITE_TEXT    ;if not passed 255 then we should be able to keep going.
TEXT_FINISHED
        RTS


CLEAR_SCREEN
        LDA #$93      
        JSR $FFD2
        RTS


WAITFORBLANK
        SEC         ; set carry bit (in SBC the borrow bit is !carry bit)
        LDA RASTER ; the top 8 bits of the 9 bits of raster counter (0 to 27 is blanking, ignoring the least significant bit and vb is 0 to 13)
        SBC $E    ; substract 14 from RASTER value
        BPL WAITFORBLANK ; if value is positive then not in blank
        RTS

WAITFORNOTBLANK        
        SEC        ; set carry bit (in SBC the borrow bit is !carry bit)
        LDA RASTER ; the top 8 bits of the 9 bits of raster counter (0 to 27 is blanking, ignoring the least significant bit and vb is 0 to 13)
        SBC $E    ; substract 14 from RASTER value
        BMI WAITFORNOTBLANK ; value is negative in blanking.
        RTS

; 10 SYS (828) ; PUT THIS LINE IN START OF BASIC WHICH INVOKES THE INSTRUCTIONS AT 828-1019

*=$1001

        BYTE    $0E, $10, $0A, $00, $9E, $20, $28,  $38, $32, $38, $29, $00, $00, $00



INIT_GAME
        LDA #0
        STA SCORE
        STA SCORE+1
        STA SCORE+2
DRAW_SC_TEXT
        LDA #>SCORE_TEXT
        STA $FC
        LDA #<SCORE_TEXT
        STA $FB
        JSR PRINT_TEXT
        RTS


MAIN_LOOP
        JSR DRAW               ; DRAW EVERYTHING
        JSR MOVE_BALL          ; MOVE BALL
        JSR CHECK_COLLISION    ; CHECK TO SEE IF THE BALL HIT ANYTHING IN NEW LOCATION
        JSR CHECK_FOR_CONTROLS ; CHECK FOR THE CONTROLS
        JMP MAIN_LOOP


MOVE_BALL
        LDA REAL_BALL_X
        STA OLD_BALL_X
        LDA BALL_X
        LDA BALL_DIRECTION
        AND #1
        BEQ BALL_GO_LEFT        ; NOT GOING RIGHT TO LEFT
BALL_GO_RIGHT
        LDA BALL_X          ; GETTING IT AGAIN BECAUSE REFETCHING IT FOR JUMP FROM LEFT
        CLC             ; CLEAR CARRY NOT TO MESS UP CALCULATION
        ADC #1          ; ADD ONE
        CMP #44          
        BNE BALL_X_POSITION_OK   ;NOT AT EDGE OF THE SCREEN 
        JSR CHANGE_BALL_DIRECTION_X
BALL_GO_LEFT
        SEC             ; set carry bit (in SBC the borrow bit is !carry bit)
        LDA BALL_X      ; LOAD DIRECTION
        SBC #1
        BPL BALL_X_POSITION_OK   ; NOT NEGATIVE WE'RE GOOD
        JSR CHANGE_BALL_DIRECTION_X
        JMP BALL_GO_RIGHT
BALL_X_POSITION_OK
        STA BALL_X
        LDA REAL_BALL_Y
        STA OLD_BALL_Y
MOVE_BALL_Y
        LDA BALL_Y
        LDA BALL_DIRECTION
        AND #2                 ; FETCH Y direction
        BEQ BALL_GO_UP          ; GOING UP
BALL_GO_DOWN
        LDA BALL_Y          ; GETTING IT AGAIN BECAUSE REFETCHING IT FOR JUMP FROM DOWN
        CLC             ; CLEAR CARRY NOT TO MESS UP CALCULATION
        ADC #1          ; ADD ONE
        CMP #46          
        BNE BALL_Y_POSITION_OK   ;NOT AT EDGE OF THE SCREEN 
        JSR CHANGE_BALL_DIRECTION_Y
BALL_GO_UP
        SEC             ; set carry bit (in SBC the borrow bit is !carry bit)
        LDA BALL_Y          ; LOAD POSITION
        SBC #1          ; SUBSTRACT 1
        CMP #1          ; ARE WE ON TOP ROW (SCORE) 
        BNE BALL_Y_POSITION_OK   ; NOT ON TOP ROW
        JSR CHANGE_BALL_DIRECTION_Y
        JMP BALL_GO_DOWN
BALL_Y_POSITION_OK
        STA BALL_Y
CALC_REAL_BALL_Y
        CLC              ; clear carry
        LDA BALL_Y       ; load ball Y
        ROR              ; DIVIDE /2
        STA REAL_BALL_Y  ; store as character location
        BCS LOWER_BALL_CHARS  ; if the carry is set that meant lower significan bit was on the lower 
        LDY #$0          ; set Y register with offset for upper ball chars
        JMP CALC_HORIZONTAL_BALL_CHAR
LOWER_BALL_CHARS
        LDY #$2 ; set y register with offset for lower ball chars
CALC_HORIZONTAL_BALL_CHAR
        CLC             ; clear carry
        LDA BALL_X      ; load BALL_X
        ROR             ; rotate right to divide/2
        STA REAL_BALL_X ; save real character position
        BCC RIGHT_BALL_CHARS ; if carry is not set then we're in the left character set
        INY             ; offset char index by 1
RIGHT_BALL_CHARS
        LDA BALL_CHARS,Y ; load the correct character
        STA BALL_CHAR ; stash it
        RTS


CHANGE_BALL_DIRECTION_X
        LDA BALL_DIRECTION
        EOR #1
        STA BALL_DIRECTION
        RTS

CHANGE_BALL_DIRECTION_Y
        LDA BALL_DIRECTION
        EOR #2
        STA BALL_DIRECTION
        RTS


DRAW
        JSR WAITFORBLANK ; WAIT FOR BLANK SO NOT TO MODIFY SCREEN WHEN BEING DISPLAYED.
        LDA OLD_BALL_X ; load OLD BALL_X
        CMP REAL_BALL_X     ; compare with pseudo position
        BNE ERASEBALL  ; if doesn't match erase the real character.
        LDA OLD_BALL_Y
        CMP REAL_BALL_Y
        BNE ERASEBALL
        JMP DRAWBALL
ERASEBALL
        LDX OLD_BALL_Y
        LDA YPOS_HI,X  ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDA #32        ; NO CAN USE ZERO PAGE INDIEX TO SET SPACE_CHAR TO Y
        LDY OLD_BALL_X
        STA ($FB),Y
DRAWBALL                 ; TODO: MOVE ALL OF THIS CONVERSION OUTSIDE OF THE DRAWING
        LDX REAL_BALL_Y
        LDA YPOS_HI,X ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA YPOS_LOW,X 
        STA $FB
        LDA BALL_CHAR    ; STASH THE BALL CHARACTER USING ZERO PAGE INDEX
        LDY REAL_BALL_X
        STA ($FB),Y
        LDX REAL_BALL_Y        ; NOW DO THE SAME TO STASH THE COLOUR IN THE RIGHT POSITION
        LDA YCOL_HI,X ; DOES IT MAKE SENSE TO MAKE THIS HAPPEN ONLY WHEN ERASE BALL IS CALLED?
        STA $FC
        LDA #BLACK        
        LDY REAL_BALL_X
        STA ($FB),Y
PADDLE
        LDA OLD_PADDLE_X
        CMP PADDLE_X
        BNE ERASEPADDLE
        JMP DRAWPADDLE
ERASEPADDLE
        LDX #PADDLE_Y
        LDA YPOS_HI,X  ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDA #32        ; NO CAN USE ZERO PAGE INDEX TO SET SPACE_CHAR TO Y
        LDY OLD_PADDLE_X
        STA ($FB),Y
        INY
        STA ($FB),Y
        INY
        STA ($FB),Y
DRAWPADDLE
        LDX #PADDLE_Y
        LDA YPOS_HI,X ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA YPOS_LOW,X 
        STA $FB
        LDA #$EC       ; STASH THE PADDLE CHARACTER USING ZERO PAGE INDEX
        LDY PADDLE_X
        STA ($FB),Y
        LDA #$E2
        INY
        STA ($FB),Y
        LDA #$FB
        INY
        STA ($FB),Y
        LDX #PADDLE_Y       ; NOW DO THE SAME TO STASH THE COLOUR IN THE RIGHT POSITION
        LDA YCOL_HI,X 
        STA $FC
        LDA #BLUE
        LDY PADDLE_X
        STA ($FB),Y
        INY
        STA ($FB),Y
        INY
        STA ($FB),Y
        LDX PADDLE_X
        STX OLD_PADDLE_X
DISPLAY_SCORE
        LDX #0
        LDY #5
SCORE_LOOP
        LDA SCORE,X
        PHA             ; Copy score on stack for later
        AND #$0F        ; Get the 4 least significant bit
        JSR DRAW_DIGIT
        PLA             ; Get the score on the stack
        LSR A           ; Shift 4 times to shift the 4 most significant bits down to conver to number
        LSR A   
        LSR A
        LSR A
        JSR DRAW_DIGIT 
        INX             
        CPX #3
        BNE SCORE_LOOP ; Did we do all 3 score Binary Coded Decimal bytes?
        JMP SCORE_DRAWN
DRAW_DIGIT
        CLC
        ADC #$30
        STA SCORE_POS,Y
        LDA #BLACK
        STA SCORE_COL_POS,Y
        DEY
        RTS
SCORE_DRAWN
DRAWFINISH
        JSR WAITFORNOTBLANK ; FINISHED DRAW, WAIT TO MAKE SURE NO LONGER IN BLANK.
        RTS


CHECK_FOR_CONTROLS
        JSR $FFE4       ;SCAN KEYBOARD AND PUT KEYCODE IN ACCUMULATOR
        CMP #RIGHT_KC   ;CHECK FOR RIGHT KEYCODE
        BNE CHECK_DOWN
        LDX PADDLE_X    ; MOVE PADDLE RIGHT
        INX             ; INCREASE POSITION BY 1
        CPX #20         
        BEQ FINISHED_RIGHT ; IF PADDLE IS AT RIGHT EDGE LEAVE
        STX PADDLE_X    ; STASH
FINISHED_RIGHT
        RTS
CHECK_DOWN
        CMP #DOWN_KC  
        BNE FINISHED_LEFT ; IF HERE AND NOT DOWN KEYCODE LEAVE
        LDX PADDLE_X   
        DEX               ; DECREASE PADDLE
        BMI FINISHED_LEFT ; IF PAST LEFT EDGE DON'T SAVE
        STX PADDLE_X
FINISHED_LEFT
        RTS


CHECK_COLLISION
        LDA REAL_BALL_Y
        CMP #PADDLE_Y
        BEQ DID_BALL_HIT_PADDLE
        JMP EXIT_COLLISION ;; TODO: WILL NEED TO HANDLE HITTING A BLOCK
DID_BALL_HIT_PADDLE
        LDX PADDLE_X
        CPX REAL_BALL_X
        BEQ BALL_HIT_PADDLE
        INX 
        CPX REAL_BALL_X
        BEQ BALL_HIT_PADDLE
        INX
        CPX REAL_BALL_X
        BEQ BALL_HIT_PADDLE
        JMP BALL_MISSED
BALL_HIT_PADDLE
        JSR ADD_SCORE_10
        JSR CHANGE_BALL_DIRECTION_Y
        JSR MOVE_BALL_Y
BALL_MISSED ;; NOTE: WE SHOULD LOSE A LIFE HERE
EXIT_COLLISION
        RTS


ADD_SCORE_10
        SED             ; SWITCH TO BINARY CODED DECIMAL
        CLC             ; CLEAR CARRY
        LDA SCORE       ; GET CURRENT SCORE
        ADC #10         ; ADD 10
        STA SCORE       ; STASH SCORE
        LDA SCORE+1     ; GET 2ND BYTE
        ADC #0          ; ADD WITH CARRY IN CASE THERE'S A CARRY BIT
        STA SCORE+1     ; STASH 2ND SCORE BIT
        LDA SCORE+2     ; GET HIGHEST BYTE
        ADC #0          ; ADD WITH CARRY IN CASE THERE'S A CARRY BIT
        STA SCORE+2     ; STASH HIGHEST BYTE
        CLD             ; CLEAR BINARY CODED DECIMAL
        RTS


ADD_SCORE_100 
        SED             ; SWITCH TO BINARY CODED DECIMAL
        CLC             ; CLEAR CARRY BIT
        LDA SCORE+1     ; 2ND SCORE BYTE IS FOR THE 1000 AND 100 VALUES
        ADC #01         ; ADD 1 TO THE 2ND BYTE = 100
        STA SCORE+1     ; STASH 2ND BYTE
        LDA SCORE+2     ; GET HIGHTEST BYTE
        ADC #0          ; ADD WITH CARRY IN CASE THERE'S A CARRY BIT
        STA SCORE+2     ; STASH HIGHEST BYTE
        CLD             ; CLEAR BINARY CODED DECIMAL
        RTS


; ADDRESS FOR EACH SCREEN ROW (COLOUR AND POSITIONAL ADDRESS SHARE SAME LOW BYTE)
YPOS_HI BYTE $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F 
YPOS_LOW BYTE $00, $16, $2C, $42, $58, $6E, $84, $9A, $B0, $C6, $DC, $F2, $08, $1E, $34, $4A, $60, $76, $8C, $A2, $B8, $CE, $E4 
YCOL_HI BYTE $96, $96, $96, $96, $96, $96, $96, $96, $96, $96, $96, $96, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97

; BALL X and Y (VIRTUAL)
BALL_X BYTE 20
BALL_Y BYTE 43
; BALL X AND Y ON SCREEN
REAL_BALL_X BYTE 10
REAL_BALL_Y BYTE 21
; BALL CHARACTER TO DISPLAY
BALL_CHAR BYTE 0;
; ARRAY OF POSSIBLE BALL CHARACTORS
BALL_CHARS BYTE 126, 124, 123, 108; upper left, upper right, lower left, lower right
; PREVIOUS BALL X and Y ON SCREEN
OLD_BALL_X BYTE 10
OLD_BALL_Y BYTE 21
; BALL DIRECTION BIT 1 X, Bit 2 Y ?0-right ?1-left, 1? up, 0?-down
BALL_DIRECTION BITS %11
; PADDLE X POSITION (LEFT MOST)
PADDLE_X BYTE 9 
; PREVIOUS PADDLE X POSITION
OLD_PADDLE_X BYTE 9
; SCORE
SCORE BYTE 0,0,0

; TEXT
SCORE_TEXT TEXT "{home}{black}{reverse off}sc:"
           byte 0
