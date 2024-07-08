; This version has variable speed ball movement for playability and adds lives after finishing levels


;; TODO ADD LIVES ON NEW LEVEL UP TO MAX_LIVES
; CONSTANTS
RASTER=$9004

GAME_STATE_BALL_LAUNCH = 1
GAME_STATE_BALL_FREE = 2
GAME_STATE_FIRE = 3
GAME_STATE_GAME_OVER = 4

; POSSIBLE COLOURS
BLACK=0
WHITE=1
RED=2
CYAN=3
PURPLE=4
GREEN=5
BLUE=6
YELLOW=7

; SOUND CONSTANTS
VOLUME=36878
VOLUME_VALUE=15
BOUNCE_SOUND=36876
BOUNCE_SOUND_VERTICAL=220
BOUNCE_SOUND_HORIZONTAL=230
BOUNCE_SOUND_LENGTH=2
LASER_SOUND_START=233
NOISE_SOUND=36877
BOOM_SOUND=128

; KEYCODES
RIGHT_KC=$1D
DOWN_KC=$11
SPACE_KC=$20
RETURN_KC=13

; GAME ASSETS
PADDLE_Y=22
SCORE_POS=$1E03     
SCORE_COL_POS=$9603 ; NEEDS TO MATCH SCORE_POS
FIRE_CHARACTER=30 ; ^ CHARACTER
LIVES_POS=$1E0D ; NEED TO REVISE
LIVES_COL_POS=$960D ; NEEDS TO MATCH ABOVE
TITLE_COL_POS=$962C ; COULD BE REVISED
GAME_OVER_COL_POS=$96E1; COULD BE REVISED
MAX_LIVES=9
MAX_BALL_SPEED=2 ; THE SLOWEST THE BALL CAN MOVE (LARGER NUMBER IS SLOWER)
SPEED_UP_COUNT=10; HOW MANY SUCCESSFUL COUNT DOES THE BALL START SPEEDING UP


*=828 ; MAKE USE OF 190 EXTRA BYTES BY USING UP THE CASETTE BUFFER

START                   
        LDA #235
        STA 36879
        JSR CLEAR_SCREEN
TITLE_SCREEN
        LDA #>TITLE_TEXT ; hi byte
        STA $FC
        LDA #<TITLE_TEXT ;low byte
        STA $FB
        JSR PRINT_TEXT
        LDA #>PRESS_RETURN_TEXT ; hi byte
        STA $FC
        LDA #<PRESS_RETURN_TEXT ;low byte
        STA $FB
        JSR PRINT_TEXT
        LDA #0
        STA LEVEL
TITLE_WAIT
        LDX #0
        LDY #0
TITLE_POLL
        LDA COLOUR_CYCLE,X
        STA TITLE_COL_POS,Y
        INX
        CPX #7
        BNE TITLE_NEXT_CHARACTER
        LDX #0
TITLE_NEXT_CHARACTER
        INY
        CPY #8
        BNE TITLE_POLL_KEYBOARD
        LDY #0
TITLE_POLL_KEYBOARD
        JSR MONITOR_START_KEY
        CMP #RETURN_KC
        BNE TITLE_POLL
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



INIT_GAME               ; WHEN STARTING A NEW GAME
        LDA #0
        STA SCORE       ; SET ALL OF THE SCORE BYTES TO 0
        STA SCORE+1
        STA SCORE+2
        LDA #3
        STA LIVES
INIT_LEVEL                              ; WHEN STARTING A NEW LEVEL
        LDA #GAME_STATE_BALL_LAUNCH     ; RESET THE BALL TO LAUNCH MODE
        STA GAME_STATE              
        LDA #VOLUME_VALUE               ; CLEAR ALL OF THE SOUNDS
        STA VOLUME
        LDA #MAX_BALL_SPEED
        STA BALL_SPEED
        LDA #0
        STA SOUND_LENGTH
        STA SOUND_NOTE
        STA LOOP
        STA BALL_HIT_COUNT
        LDA #9          ; RESET PADDLE POSITION
        STA PADDLE_X
        STA OLD_PADDLE_X
        LDA #10         ; SET BALL X POSITION
        STA REAL_BALL_X
        STA OLD_BALL_X
        LDA #20         ; SET BALL Y POSITION
        STA REAL_BALL_Y
        STA OLD_BALL_Y
        LDA #2          ; SET BALL DIRECTION
        STA BALL_DIRECTION
        LDA #1          ; SET GAME STARTED BUT BALL NOT LAUNCH
        STA GAME_STATE
        JSR CLEAR_SCREEN
        LDX LEVEL
        CPX #0
        BEQ DRAW_LEVEL_1
        CPX #1
        BEQ DRAW_LEVEL_2
        CPX #2
        BEQ DRAW_LEVEL_3
        CPX #3
        BEQ DRAW_LEVEL_4
        CPX #4
        BEQ DRAW_LEVEL_5
        CPX #5
        BEQ DRAW_LEVEL_6
        CPX #6
        BEQ DRAW_LEVEL_7
        CPX #7
        BEQ DRAW_LEVEL_8
        LDX #0
        STX LEVEL
        JMP INIT_LEVEL
DRAW_LEVEL_1
        LDA #>LEVEL_1
        STA $FC
        LDA #<LEVEL_1
        STA $FB
        JSR PRINT_TEXT
        JMP SETUP_LEVEL
DRAW_LEVEL_2
        LDA #>LEVEL_2
        STA $FC
        LDA #<LEVEL_2
        STA $FB
        JSR PRINT_TEXT
        JMP SETUP_LEVEL
DRAW_LEVEL_3
        LDA #>LEVEL_3
        STA $FC
        LDA #<LEVEL_3
        STA $FB
        JSR PRINT_TEXT
        JMP SETUP_LEVEL
DRAW_LEVEL_4
        LDA #>LEVEL_4
        STA $FC
        LDA #<LEVEL_4
        STA $FB
        JSR PRINT_TEXT
        JMP SETUP_LEVEL
DRAW_LEVEL_5
        LDA #>LEVEL_5
        STA $FC
        LDA #<LEVEL_5
        STA $FB
        JSR PRINT_TEXT
        JMP SETUP_LEVEL
DRAW_LEVEL_6
        LDA #>LEVEL_6
        STA $FC
        LDA #<LEVEL_6
        STA $FB
        JSR PRINT_TEXT
        JMP SETUP_LEVEL
DRAW_LEVEL_7
        LDA #>LEVEL_7
        STA $FC
        LDA #<LEVEL_7
        STA $FB
        JSR PRINT_TEXT
        JMP SETUP_LEVEL
DRAW_LEVEL_8
        LDA #>LEVEL_8
        STA $FC
        LDA #<LEVEL_8
        STA $FB
        JSR PRINT_TEXT
        JMP SETUP_LEVEL
SETUP_LEVEL
        LDA LEVELS_BLOCKS,X  ; SET AMOUNT OF BLOCKS TO KNOCK DOWN
        STA LEVEL_BLOCKS
DRAW_SC_TEXT
        LDA #>SCORE_TEXT
        STA $FC
        LDA #<SCORE_TEXT
        STA $FB
        JSR PRINT_TEXT
        RTS


MAIN_LOOP
        JSR DRAW               ; DRAW EVERYTHING
        LDA GAME_STATE
        CMP #GAME_STATE_GAME_OVER
        BNE CHECK_NEXT_STATE
        JMP GAME_OVER
CHECK_NEXT_STATE
        CMP #GAME_STATE_BALL_LAUNCH
        BNE MAIN_LOOP_MOVE_BALL
        JSR MOVE_BALL_TO_LAUNCH
        JMP MAIN_LOOP_BALL_MOVED
MAIN_LOOP_MOVE_BALL
        LDX LOOP
        INX
        STX LOOP
        CPX BALL_SPEED
        BNE MAIN_LOOP_BALL_MOVED
        LDX #0
        STX LOOP
        JSR MOVE_FREE_BALL     ; MOVE BALL
        JSR CHECK_COLLISION    ; CHECK TO SEE IF THE BALL HIT ANYTHING IN NEW LOCATION
        LDX LEVEL_BLOCKS       ; ARE ALL BLOCKS GONE?
        CPX #0                  
        BNE MAIN_LOOP_BALL_MOVED  ; Still have blocks remaining ignore the rest    
        LDX LEVEL                ; increase the level 
        INX
        STX LEVEL
        CPX #9                  ; are we at the last level?
        BNE GO_TO_NEXT_LEVEL
        LDX #0                  ; loop to first
        STX LEVEL
GO_TO_NEXT_LEVEL
        JSR ADD_SCORE_100
        CLC
        LDA LIVES
        ADC #3
        STA LIVES
        SEC
        SBC #MAX_LIVES
        SBC #1
        BMI LIVES_NUMBER_OKAY
        LDA #MAX_LIVES
        STA LIVES
LIVES_NUMBER_OKAY
        JSR INIT_LEVEL
MAIN_LOOP_BALL_MOVED
        JSR CHECK_FOR_CONTROLS ; CHECK FOR THE CONTROLS
        JSR SOUND_MANAGE       ; MANAGE THE SOUND
        JMP MAIN_LOOP


SOUND_MANAGE
        LDX SOUND_LENGTH        ; CHECK TO SEE IF THE SOUND LENGTH IS ALREADY 0
        CPX #0
        BEQ CLEAR_SOUND         ; IF IT IS CLEAR EVERYTHING.
        DEX                     ; IF IT ISN'T DECREASE THE COUNTER
        STX SOUND_LENGTH        
        LDA SOUND_NOTE          ; PLAY THE NOTE
        STA BOUNCE_SOUND
        JMP FINISH_SOUND        
CLEAR_SOUND
        LDA #0                  ; CLEAR THE SOUND COUNTER, NOTE AND CHARACTER
        STA SOUND_LENGTH        
        STA SOUND_NOTE
        STA BOUNCE_SOUND
FINISH_SOUND                   
        RTS


MOVE_BALL_TO_LAUNCH
        LDA REAL_BALL_Y
        STA OLD_BALL_Y
        SEC
        LDA #PADDLE_Y
        SBC #1
        STA REAL_BALL_Y
        CLC
        ROL
        CLC
        ADC #1
        STA BALL_Y
        LDA REAL_BALL_X
        STA OLD_BALL_X
        CLC
        LDA PADDLE_X
        ADC #1
        STA REAL_BALL_X
        CLC
        ROL
        STA BALL_X
        LDX #$2
        LDA BALL_CHARS,X
        STA BALL_CHAR
        RTS


MOVE_FREE_BALL
        LDA REAL_BALL_X
        STA OLD_BALL_X
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
        LDA #BOUNCE_SOUND_HORIZONTAL
        STA SOUND_NOTE
        LDA #BOUNCE_SOUND_LENGTH
        STA SOUND_LENGTH
        RTS

CHANGE_BALL_DIRECTION_Y
        LDA BALL_DIRECTION
        EOR #2
        STA BALL_DIRECTION
        LDA #BOUNCE_SOUND_VERTICAL
        STA SOUND_NOTE
        LDA #BOUNCE_SOUND_LENGTH
        STA SOUND_LENGTH
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
DISPLAY_LIVES
        LDX #MAX_LIVES
        LDY #0
        LDA #32
LIVES_LOOP
        CPX LIVES
        BNE CONTINUE_LIVES
        LDA #81
CONTINUE_LIVES
        STA LIVES_POS,Y
        PHA
        LDA #BLACK
        STA LIVES_COL_POS,Y
        PLA
        INY
        DEX
        CPX #0
        BNE LIVES_LOOP
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
        BEQ FINISHED_CHECK_FOR_CONTROLS ; IF PADDLE IS AT RIGHT EDGE LEAVE
        INX             ; INCREASE POSITION BY 1
        CPX #20
        BNE CHECK_STORE_X
        LDX #19
CHECK_STORE_X
        STX PADDLE_X    ; STASH
        RTS
CHECK_DOWN
        CMP #DOWN_KC  
        BNE CHECK_SPACE ; IF HERE AND NOT DOWN KEYCODE LEAVE
        LDX PADDLE_X   
        DEX               ; DECREASE PADDLE
        BMI FINISHED_CHECK_FOR_CONTROLS ; IF PAST LEFT EDGE DON'T SAVE
        DEX
        BPL CHECK_STORE_X
        LDX #0
        STX PADDLE_X
        RTS
CHECK_SPACE
        CMP #SPACE_KC
        BNE FINISHED_CHECK_FOR_CONTROLS ; TODO NEXT CONTROL?
        LDX GAME_STATE
        CPX #GAME_STATE_BALL_LAUNCH      
        BNE FINISHED_CHECK_FOR_CONTROLS ; OTHER STATES? I.E. FIRE?
        LDX #GAME_STATE_BALL_FREE
        STX GAME_STATE
        LDA BALL_DIRECTION ; FORCE BALL TO GO UP. MAY NOT BE OKAY
        AND #1
        STA BALL_DIRECTION
        LDA #BOUNCE_SOUND_VERTICAL
        STA SOUND_NOTE
        LDA #BOUNCE_SOUND_LENGTH
        STA SOUND_LENGTH
        RTS
FINISHED_CHECK_FOR_CONTROLS
        RTS


BALL_MISSED_DELAY
        LDX #4
BALL_MISSED_DELAY_LOOP
        DEX
        BMI BALL_MISSED_LEAVE_DELAY
        TXA
        PHA
        JSR WAITFORBLANK
        JSR WAITFORNOTBLANK
        PLA
        TAX
        JMP BALL_MISSED_DELAY_LOOP
BALL_MISSED_LEAVE_DELAY
        RTS

CHECK_COLLISION
        LDA REAL_BALL_Y
        CMP #PADDLE_Y
        BEQ DID_BALL_HIT_PADDLE
        JMP DID_BALL_HIT_A_BLOCK ;; TODO: WILL NEED TO HANDLE HITTING A BLOCK
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
        JSR CHANGE_BALL_DIRECTION_Y
        JSR MOVE_BALL_Y
        LDX BALL_HIT_COUNT
        INX
        STX BALL_HIT_COUNT
        CPX #SPEED_UP_COUNT
        BNE END_BALL_HIT_PADDLE
        LDX #0
        STX BALL_HIT_COUNT
        LDX BALL_SPEED
        DEX
        STX BALL_SPEED
        CPX #0
        BNE END_BALL_HIT_PADDLE
        LDX #1
        STX BALL_SPEED
END_BALL_HIT_PADDLE
        RTS
BALL_MISSED ;; NOTE: WE SHOULD LOSE A LIFE HERE
        LDA #GAME_STATE_BALL_LAUNCH
        STA GAME_STATE
        LDA #MAX_BALL_SPEED
        STA BALL_SPEED
        LDA #0
        STA BALL_HIT_COUNT
        JSR DRAW
        LDX REAL_BALL_Y
        LDA YPOS_HI,X
        STA $FC
        LDA YPOS_LOW,X 
        STA $FB
        LDY REAL_BALL_X
        LDA #BLACK
        STA ($FB),Y
        LDA #32
        STA ($FB),Y
        LDA #135
        STA BOUNCE_SOUND
        JSR BALL_MISSED_DELAY
        LDA BALL_CHAR
        STA ($FB),Y
        LDA #143
        STA BOUNCE_SOUND
        JSR BALL_MISSED_DELAY
        LDA #32
        STA ($FB),Y
        LDA #135
        STA BOUNCE_SOUND
        JSR BALL_MISSED_DELAY
        LDA BALL_CHAR
        STA ($FB),Y
        LDA #0
        STA BOUNCE_SOUND
        LDX LIVES
        DEX
        STX LIVES
        CPX #0
        BNE EXIT_COLLISION
        LDA #GAME_STATE_GAME_OVER
        STA GAME_STATE
DID_BALL_HIT_A_BLOCK
        LDX REAL_BALL_Y
        LDA YPOS_HI,X 
        STA $FC
        LDA YPOS_LOW,X 
        STA $FB
        LDY REAL_BALL_X
        LDA ($FB),Y
        CMP #32         
        BEQ EXIT_COLLISION  ; HIT EMPTY SPACE IGNORE THE REST
        CMP #126
        BEQ EXIT_COLLISION  ; BALL GRAPHIC IGNORE
        CMP #124
        BEQ EXIT_COLLISION  ; BALL GRAPHIC IGNORE
        CMP #123
        BEQ EXIT_COLLISION  ; BALL GRAPHIC IGNORE
        CMP #108
        BEQ EXIT_COLLISION  ; BALL GRAPHIC IGNORE
        PHA                 ; STASH ACCUMULATOR IN STACK
        JSR BLOCK_HIT
        JSR CHANGE_BALL_DIRECTION_Y
        PLA                     ; FETCH ACCUMULATOR FROM STACK.
        CMP #$90                ; HIT THE "P" BLOCK?
        BNE CHECK_CHECKED
        JSR ADD_SCORE_100
        JMP EXIT_COLLISION
CHECK_CHECKED
        CMP #102                ; HIT THE CHECKED BLOCKS
        BNE CHECK_EXPLOSION
        JSR CHANGE_BALL_DIRECTION_X
        JMP EXIT_COLLISION
CHECK_EXPLOSION
        CMP #$85                ; HIT THE EXPLOSION SPOT?
        BNE CHECK_FIRE
        JSR EXPLOSION
        JMP EXIT_COLLISION
CHECK_FIRE        
        CMP #$86 ; Fire
        BNE EXIT_COLLISION
        JSR FIRE
        JMP EXIT_COLLISION
EXIT_COLLISION
        RTS


EXPLOSION       ; TODO ADD ANIMATION AND NOISE
        LDA #0
        STA EXPLOSION_GRID
        LDX REAL_BALL_Y
        DEX
CHECK_EXPLOSION_ROW
        LDY REAL_BALL_X
        DEY
        LDA YPOS_HI,X ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA YPOS_LOW,X 
        STA $FB
CHECK_EXPLOSION_SQUARE
        CPY OLD_BALL_X  ; SKIP OLD BALL LOCATION (WHERE ball is displayed)
        BNE CHECK_EXPLOSION_BALL_POS
        CPX OLD_BALL_Y
        BEQ NEXT_EXPLOSION_SPOT
CHECK_EXPLOSION_BALL_POS
        CPY REAL_BALL_X      ; SKIP BALL LOCATION (WHERE block is)
        BNE HANDLE_EXPLOSION
        CPX REAL_BALL_Y
        BEQ NEXT_EXPLOSION_SPOT
HANDLE_EXPLOSION
        LDA ($FB),Y
        CMP #32
        BEQ NEXT_EXPLOSION_SPOT
        TXA                     ; SAVE X AND Y REGISTERS IN STACK
        PHA
        TYA
        PHA
        JSR BLOCK_HIT
        PLA                     ; GET X AND Y REGISTERS FROM STACK
        TAY
        PLA
        TAX
NEXT_EXPLOSION_SPOT
        INY
        CLC
        LDA EXPLOSION_GRID
        ADC #1
        STA EXPLOSION_GRID
        CMP #3
        BEQ NEW_EXPLOSION_ROW
        CMP #6
        BEQ NEW_EXPLOSION_ROW
        CMP #9
        BEQ DONE_EXPLOSION
        JMP CHECK_EXPLOSION_SQUARE
NEW_EXPLOSION_ROW
        INX
        JMP CHECK_EXPLOSION_ROW
DONE_EXPLOSION
        JSR ANIMATE_EXPLOSION
        RTS


ANIMATE_EXPLOSION
        LDX #0
        STX EXPLOSION_ANIMATION
        LDA #BOOM_SOUND
        STA NOISE_SOUND
ANIMATE_EXPLOSION_CHARACTERS
        LDX #0
        STX EXPLOSION_GRID
        LDX EXPLOSION_ANIMATION
        CPX #3
        BEQ DONE_ANIMATION
        LDA EXPLOSION_CHARS,X
        STA EXPLOSION_CHAR
        INX
        STX EXPLOSION_ANIMATION
        LDX REAL_BALL_Y
        DEX
ANIMATE_EXPLOSION_ROW
        LDY REAL_BALL_X
        DEY
        LDA YPOS_LOW,X 
        STA $FB
ANIMATE_EXPLOSION_SQUARE
        LDA YPOS_HI,X ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA EXPLOSION_CHAR
        STA ($FB),Y
        LDA YCOL_HI,X
        STA $FC
        LDA RED
        STA ($FB),Y
        INY
        CLC
        LDA EXPLOSION_GRID
        ADC #1
        STA EXPLOSION_GRID
        CMP #3
        BEQ NEW_ANIMATE_EXPLOSION_ROW
        CMP #6
        BEQ NEW_ANIMATE_EXPLOSION_ROW
        CMP #9
        BNE ANIMATE_EXPLOSION_SQUARE
        JSR WAITFORBLANK
        JSR WAITFORNOTBLANK
        JMP ANIMATE_EXPLOSION_CHARACTERS
NEW_ANIMATE_EXPLOSION_ROW
        INX
        JMP ANIMATE_EXPLOSION_ROW        
DONE_ANIMATION
        LDA #0
        STA NOISE_SOUND
        RTS


FIRE
        LDA #GAME_STATE_FIRE
        STA GAME_STATE
        LDA #0          ; SHUT OFF BOUNCE SOUND FROM HITTING "F" BLOCK
        STA BOUNCE_SOUND
FIRE_ERASE_BALL
        LDX REAL_BALL_Y ; ERASE BALL AND OLD SPACE
        LDA YPOS_HI,X  ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDY REAL_BALL_X
        LDA #32      
        STA ($FB),Y
        LDX OLD_BALL_Y ; OLD BALL LOCATION
        LDA YPOS_HI,X  
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDY OLD_BALL_X
        LDA #32
        STA ($FB),Y
FIRE_ERASE_PADDLE      ; ERASE THE PADDLE SO CAN REPLACE WITH ^
        LDX #PADDLE_Y
        LDA YPOS_HI,X  ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDA #32        ; LOAD THE SPACE CHARACTER IN THE ACCUMULATOR
        LDY PADDLE_X
        STA ($FB),Y
        INY
        STA ($FB),Y
        INY
        STA ($FB),Y
        LDY OLD_PADDLE_X
        STA ($FB),Y
        INY
        STA ($FB),Y
        INY
        STA ($FB),Y
INIT_FIRE              ; SET NEW PADDLE POSITION SINCE ONLY 1 CHAR
        LDY PADDLE_X
        INY
        STY PADDLE_X
        STY OLD_PADDLE_X
FIRE_MAIN_LOOP 
        JSR DRAW_FIRE_PADDLE
        JSR FIRE_CHECK_FOR_CONTROLS
        LDA GAME_STATE
        CMP #GAME_STATE_FIRE
        BEQ FIRE_MAIN_LOOP
EXIT_FIRE
        LDX #PADDLE_Y   ; ERASE FIRE PADDLE
        LDA YPOS_HI,X  
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDA #32        
        LDY OLD_PADDLE_X
        STA ($FB),Y
        
        LDX PADDLE_X      ; SEE IF WE NEED TO ADJUST PADDLE_X 
        CPX #0  
        BEQ FIRE_DONE
FIRE_ADJUST_PADDLE
        DEX               ; OTHERWISE NEED TO BUMP AT LEAST ONE SO PADDLE GROWS TO 3 SPACES FROM THIS MIDDLE
        STX PADDLE_X      
        SEC
        LDA PADDLE_X      ; NEED TO CHECK THAT PADDLE ISN'T STILL TOO CLOSE TO RIGHT EDGE
        SBC #20
        BMI FIRE_DONE   
        DEX               ; PADDLE IS TOO CLOSE TO EDGE SO PUSH IT AGAIN.
        STX PADDLE_X
FIRE_DONE
        STX OLD_PADDLE_X
        RTS

FIRE_CHECK_FOR_CONTROLS
        JSR $FFE4       ;SCAN KEYBOARD AND PUT KEYCODE IN ACCUMULATOR
        CMP #RIGHT_KC   ;CHECK FOR RIGHT KEYCODE
        BNE FIRE_CHECK_DOWN
        LDX PADDLE_X    ; MOVE PADDLE RIGHT
        INX             ; INCREASE POSITION BY 1
        CPX #22      
        BEQ FIRE_FINISHED_CHECK_FOR_CONTROLS ; IF PADDLE IS AT RIGHT EDGE LEAVE
        STX PADDLE_X    ; STASH
        RTS
FIRE_CHECK_DOWN
        CMP #DOWN_KC  
        BNE FIRE_CHECK_SPACE ; IF HERE AND NOT DOWN KEYCODE LEAVE
        LDX PADDLE_X   
        DEX               ; DECREASE PADDLE
        BMI FIRE_FINISHED_CHECK_FOR_CONTROLS ; IF PAST LEFT EDGE DON'T SAVE
        STX PADDLE_X
        RTS
FIRE_CHECK_SPACE
        CMP #SPACE_KC
        BNE FIRE_FINISHED_CHECK_FOR_CONTROLS ; TODO NEXT CONTROL?
        JSR SHOOT
        LDA GAME_STATE_BALL_FREE
        STA GAME_STATE
        RTS
FIRE_FINISHED_CHECK_FOR_CONTROLS
        RTS


SHOOT
        LDX #PADDLE_Y
SHOOT_LOOP_CHECK
        DEX
        CPX #0
        BEQ SHOOT_LOOP_CHECK_DONE
        LDA YPOS_HI,X  
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDY PADDLE_X
        LDA ($FB),Y
        CMP #32
        BEQ SHOOT_LOOP_CHECK
        TXA                     ; SAVE X AND Y REGISTERS IN STACK
        PHA
        TYA
        PHA
        JSR BLOCK_HIT
        PLA                     ; GET X AND Y REGISTERS FROM STACK
        TAY
        PLA
        TAX
        JMP SHOOT_LOOP_CHECK
SHOOT_LOOP_CHECK_DONE
        LDA #LASER_SOUND_START
        STA SOUND_NOTE
        LDX #PADDLE_Y
SHOOT_LASER_BEAM
        DEX
        CPX #0
        BEQ SHOOT_LASER_BEAM_DONE
        LDA YPOS_HI,X  
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDY PADDLE_X
        LDA #93         ; DRAW THE LASER CHARACTER (HORIZONTAL LINE)
        STA $(FB),Y
        LDA YCOL_HI,X
        STA $FC
        LDA #RED
        STA $(FB),Y
        TXA
        LDX SOUND_NOTE
        STX BOUNCE_SOUND
        INX
        STX SOUND_NOTE
        TAX
        ROR     
        BCC SHOOT_LASER_BEAM ; ONLY WAIT FOR BLANK HALF THE TIME
        JSR WAITFORBLANK
        JSR WAITFORNOTBLANK
        JMP SHOOT_LASER_BEAM
SHOOT_LASER_BEAM_DONE
        LDX #PADDLE_Y
SHOOT_LASER_BEAM_ERASE
        DEX
        CPX #0
        BEQ SHOOT_DONE
        LDA YPOS_HI,X  
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDY PADDLE_X
        LDA #32
        STA $(FB),Y
        TXA
        LDX SOUND_NOTE
        STX BOUNCE_SOUND
        DEX
        STX SOUND_NOTE
        TAX
        ROR
        BCC SHOOT_LASER_BEAM_ERASE ; ONLY WAIT FOR BLANK HALF THE TIME
        JSR WAITFORBLANK        
        JSR WAITFORNOTBLANK
        JMP SHOOT_LASER_BEAM_ERASE
SHOOT_DONE
        LDA #0
        STA SOUND_NOTE
        RTS

DRAW_FIRE_PADDLE
        JSR WAITFORBLANK
        LDX #PADDLE_Y
        LDA YPOS_HI,X  ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA YPOS_LOW,X
        STA $FB
        LDY OLD_PADDLE_X
        CPY PADDLE_X
        BEQ DRAW_FIRE_CHAR
        LDA #32
        STA ($FB),Y
DRAW_FIRE_CHAR
        LDY PADDLE_X
        LDA #FIRE_CHARACTER ; LOAD THE SPACE CHARACTER IN THE ACCUMULATOR
        STA ($FB),Y
        LDA YCOL_HI,X
        STA $FC
        LDA #BLUE
        STA ($FB),Y
        STY OLD_PADDLE_X
        JSR WAITFORNOTBLANK
        RTS


BLOCK_HIT
        JSR ADD_SCORE_10
        LDX LEVEL_BLOCKS 
        DEX
        STX LEVEL_BLOCKS ;since we're ignoring the block that activated this, we shouldn't have to worry about checking if we have finished the level
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

MONITOR_START_KEY
        JSR $FFE4
        CMP #RETURN_KC
        BEQ EXIT_MONITOR
        PHA
        SEC
        SBC #$30
        BMI RESTORE_LDA_MONITOR ;BUTTON PRESSED UNDER 0
        SBC #9
        BPL RESTORE_LDA_MONITOR ;BUTTON PRESSED HIGHER THEN 8
        CLC
        ADC #8
        STA LEVEL
RESTORE_LDA_MONITOR        
        CLC
        PLA
EXIT_MONITOR
        RTS


GAME_OVER
        JSR DRAW
        LDA #>GAME_OVER_TEXT
        STA $FC
        LDA #<GAME_OVER_TEXT
        STA $FB
        JSR PRINT_TEXT
        LDA #>PRESS_RETURN_TEXT ; hi byte
        STA $FC
        LDA #<PRESS_RETURN_TEXT ;low byte
        STA $FB
        JSR PRINT_TEXT
        LDA #0
        STA LEVEL
        LDX #0
        LDY #0
GAME_OVER_POLL
        LDA COLOUR_CYCLE,X
GAME_OVER_NEXT_CHARACTER
        STA GAME_OVER_COL_POS,Y
        INY
        CPY #9
        BNE GAME_OVER_NEXT_CHARACTER
        LDY #0
        INX
        CPX #8
        BNE GAME_OVER_MONITOR_KEY
        LDX #0
GAME_OVER_MONITOR_KEY
        JSR MONITOR_START_KEY
        CMP #RETURN_KC
        BNE GAME_OVER_POLL
        JSR INIT_GAME
        JMP MAIN_LOOP

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
BALL_CHAR BYTE 123
; ARRAY OF POSSIBLE BALL CHARACTORS
BALL_CHARS BYTE 126, 124, 123, 108; upper left, upper right, lower left, lower right
; PREVIOUS BALL X and Y ON SCREEN
OLD_BALL_X BYTE 10
OLD_BALL_Y BYTE 21
; BALL DIRECTION BIT 1 X, Bit 2 Y ?0-right ?1-left, 0? up, 1?-down
BALL_DIRECTION BITS %11
; PADDLE X POSITION (LEFT MOST)
PADDLE_X BYTE 9 
; PREVIOUS PADDLE X POSITION
OLD_PADDLE_X BYTE 9
; SCORE
SCORE BYTE 0,0,0
; GAME STATE
GAME_STATE BYTE GAME_STATE_BALL_LAUNCH
; SOUND
SOUND_LENGTH BYTE 0
SOUND_NOTE BYTE 0
; LEVEL
LEVEL BYTE 0
LEVEL_BLOCKS BYTE 0
LEVELS_BLOCKS BYTE LEVEL_1_BLOCKS,LEVEL_2_BLOCKS,LEVEL_3_BLOCKS,LEVEL_4_BLOCKS,LEVEL_5_BLOCKS,LEVEL_6_BLOCKS,LEVEL_7_BLOCKS,LEVEL_8_BLOCKS
; LIVES
LIVES BYTE 0
; LOOP COUNT
LOOP BYTE 0
; LOOP
BALL_SPEED BYTE MAX_BALL_SPEED
BALL_HIT_COUNT BYTE 0

; EXPLOSION GRID
EXPLOSION_GRID BYTE 0
EXPLOSION_ANIMATION BYTE 0
EXPLOSION_CHARS BYTE 43,42,32
EXPLOSION_CHAR BYTE 43

COLOUR_CYCLE BYTE BLACK,RED,CYAN,PURPLE,GREEN,BLUE,YELLOW,WHITE
; TEXT
SCORE_TEXT TEXT "{home}{black}{reverse off}sc:"
           byte 0


;SCREEN 1 - level 1 (60 blocks) 
LEVEL_1_BLOCKS=60
LEVEL_1 TEXT "{home}{down}{right}{reverse on}{cyan} {blue} {purple} {red} {purple} {blue} {cyan} {green}  {yellow}  {green}  {cyan} {blue} {purple} {red} {purple} {blue} {cyan} {reverse off}{return}"
        TEXT "{right}{reverse on} {blue} {purple} {red}e{purple} {blue} {cyan} {green} {yellow}    {green} {cyan} {blue} {purple} {red}e{purple} {blue} {cyan} {reverse off}{return}"
        TEXT "{right}{reverse on} {blue} {purple} {red} {purple} {blue} {cyan} {green}  {yellow}  {green}  {cyan} {blue} {purple} {red} {purple} {blue} {cyan} {reverse off}{return}"
        byte 0
;SCREEN 2 - level 2 (88 blocks)
LEVEL_2_BLOCKS=88
LEVEL_2 TEXT "{home}{down}{reverse on}{black}                      {reverse off}"
        TEXT "{reverse on}{blue}    f    ff     f     {reverse off}"
        TEXT "{reverse on}{purple}   e             e    {reverse off}"
        TEXT "{black}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}"
        byte 0
;SCREEN 3 - Level 3 (48blocks)
LEVEL_3_BLOCKS=48
LEVEL_3 TEXT "{home}{down}         {reverse on}{red}{169}{127}{reverse off}{return}"
        TEXT "        {reverse on}{169}{160}{160}{127}{reverse off}{return}"
        TEXT "       {reverse on}{169}{160}ee{160}{127}{reverse off}{return}"
        TEXT "      {reverse on}{169}{160}{160}{172}{187}{160}{160}{127}{reverse off} {reverse on}{169}{127}{reverse off}{return}"
        TEXT "     {reverse on}{169}{160}{160}p{reverse off}{161}{reverse on}{161}p{160}{160}{127}{reverse off}{127}{reverse on} {127}{127}{reverse off}{return}"
        TEXT "    {reverse on}{169}{160}{160}ep{reverse off}{161}{reverse on}{161}pe{160}{160}{127}{reverse off}"
        byte 0
;SCREEN 4 - Level 4 (88 blocks)
LEVEL_4_BLOCKS=88
LEVEL_4 TEXT "{home}{down}{reverse on}{black}   {185}{185}            .  p {reverse off}"
        TEXT "{reverse on}  {reverse off}{191}{reverse on}HQ{191}{171}Q{179}  {125} {125}        {reverse off}"
        TEXT "{reverse on}  {191}eC{reverse off}{191}{reverse on}  .  {171}Q{179}   f  . {reverse off}"
        TEXT "{reverse on}   {184}{184}      {125} {125}        {reverse off}"
        byte 0
;SCREEN 5 - level 5 (77 blocks)
LEVEL_5_BLOCKS=71
LEVEL_5 TEXT "{home}{down}{reverse on}{yellow}{160}{160}{reverse off}{181}C       {red}{185}{reverse on}{184}{183}{184}{reverse off}{return}"
        TEXT "{reverse on}{yellow} {172}{reverse off}    {185}     {reverse on}{172}  {reverse off}{return}"
        TEXT "{184} M  {170}{reverse on}p{reverse off}{181}   {188}{reverse on}   {reverse off}   {172}{reverse on}{184}{184}{reverse off}{187}"
        TEXT "H     {184}      {reverse on}{red}  {reverse off}   {reverse on}{yellow}{181}fe{182}{reverse off}"
        TEXT "            {reverse on}{red}{190}{172} {188}{reverse off}  {reverse on}{yellow}{181}ee{182}{reverse off}"
        TEXT "   {reverse on}{green}{184}{184}{reverse off} {reverse on}{184}{reverse off}    {reverse on}{yellow}{187}{red}{172}{blue}{190}{184}{red}{187}{reverse off}{yellow}{187} {188}{reverse on}{185}{185}{reverse off}{190}"
        TEXT "  {reverse on}{green}{190}  {188}{172}{reverse off}     {reverse on}{blue}{190}{172} {reverse off}{return}"
        TEXT "  {reverse on}{green}{190}{reverse off}  {reverse on}{190}{reverse off}      {reverse on}{blue} {reverse off} {reverse on} {reverse off}{return}"
        TEXT "  {reverse off}{green}{166}{166}{166}{166}{reverse off}      {reverse on}{black}{162}{reverse off} {reverse on}{162}{reverse off}{return}"
        TEXT "            {reverse off}{green}{166}{166}{166}{reverse off}"
        byte 0
;SCREEN 6 - Level 6 (52 blocks)
LEVEL_6_BLOCKS=52
LEVEL_6 TEXT "{home}{down}    {reverse on}{purple}p            p{reverse off}{return}"
        TEXT "     {reverse on}            {reverse off}{return}"
        TEXT "       {reverse on}e  ff  e{reverse off}{return}"
        TEXT "         {reverse on}    {reverse off}   {cyan}{166}{return}"
        TEXT "   {reverse on}f{reverse off}  {166}      {166}{return}"
        TEXT "   {166}             {166}{return}"
        TEXT "        {166}{return}"
        TEXT " {166}           {166}{return}"
        TEXT "    {166}    {166}   {reverse on}e{reverse off}{return}"
        TEXT "                   {166}{return}"
        TEXT "   {166}{return}"
        byte 0
;SCREEN 7 - Level 7 (62 blocks)
LEVEL_7_BLOCKS=60
LEVEL_7 TEXT "{home}{down}   {yellow}{165}{return}"
        TEXT " {191}  {reverse on}{191}{reverse off}  {reverse on}{black}{162}{162}{162}{162}{187}{172}{162}{162}{162}{162}{reverse off}{return}"
        TEXT "{yellow}{164} {reverse on}{red}{190}{188}{reverse off} {yellow}{164}     {reverse on}{black}{184}{184}{reverse off}{return}"
        TEXT "  {reverse on}{red}{187}{172}{reverse off}{black}{164}{164}{185}{185}{162}{162}{reverse on}{190}{reverse off}{190}{188}{reverse on}{188}{reverse off}{162}{162}{185}{185}{164}{164}{return}"
        TEXT " {reverse on}{yellow}{191}{reverse off}  {191}{reverse on}{black}e{reverse off}{183}{reverse on}f{reverse off}{184}{184}{reverse on}{187}{reverse off}{purple}{188}{190}{reverse on}{black}{172}{reverse off}{184}{184}{reverse on}f{reverse off}{183}{reverse on}e{reverse off}{return}"
        TEXT "  {yellow}{167}       {reverse on}{black}{161}{188}{190}{reverse off}{161}{return}"
        TEXT "           {reverse on}{187}{172}{reverse off}{return}"
        TEXT "           {167}{165}{return}"
        TEXT "           {167}{165}{return}"
        byte 0
;SCREEN 8 - Level 8 77 blocks
LEVEL_8_BLOCKS=71
LEVEL_8 TEXT "{home}{down} {purple}UI    {162}{187}{reverse on}{184}{184}{reverse off}{172}{162}     CQC{return}"
        TEXT "EEEE  {reverse on}{190}{172}{190}ee{188}{187}{188}{reverse off}{return}"
        TEXT "      {188}{reverse on}{188}{162}{162}{162}{162}{190}{reverse off}{190}{return}"
        TEXT "{yellow}{166}{166}{166}{166}{166}  {purple}{188}{reverse on}{162}{185}{185}{162}{reverse off}{190}   {yellow}{166}{166}{166}{166}{166}{166}"
        TEXT "    {reverse on}{cyan}f{reverse off}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{166}{reverse on}f{reverse off}{return}"
        TEXT "{blue}{166}{166}{166}{166}{166}{166}{166}{166}      {166}{166}{166}{166}{166}{166}{166}{166}{return}"
        byte 0

TITLE_TEXT TEXT "{clear}{home}{down*2}{blue}vikanoid 2{home}{return}{return}{return}{reverse on}e{reverse off} - explosion{return}{reverse on}p{reverse off} - points{return}{reverse on}f{reverse off} - fire{return}{return}space to launch ball"
           byte 0

GAME_OVER_TEXT TEXT "{home}{down*10}{right*5}game over"
               byte 0 
PRESS_RETURN_TEXT TEXT "{return}{return}press return to start"
                 byte 0


