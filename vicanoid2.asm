; This version pauses on vertical blank.
RASTER=$9004

BLACK=0
WHITE=1
RED=2
CYAN=3
PURPLE=4
GREEN=5
BLUE=6
YELLOW=7

*=828

START                   ; INIT
        JSR CLEAR_SCREEN
        JMP MAIN_LOOP

CLEAR_SCREEN
        LDA #$93      
        JSR $FFD2
        RTS

; 10 SYS (828)

*=$1001

        BYTE    $0E, $10, $0A, $00, $9E, $20, $28,  $38, $32, $38, $29, $00, $00, $00

; NOTE: PROBABLY NOT THE BEST THING, PROBABLY BEST JUST TO CALCULATE Y*21 SINCE THIS WILL TAKE UP 88 BYTES?

MAIN_LOOP
        JSR DRAW            ; DRAW EVERYTHING
        JSR MOVE_BALL       ; MOVE BALL
        JMP MAIN_LOOP

MOVE_BALL
        LDA BALL_X
        STA OLD_BALL_X
        LDA BALL_DIRECTION
        AND #1
        CMP #1          ; FETCH X direction, BIT 0 being OFF is LEFT
        BNE BALL_GO_LEFT        ; NOT GOING RIGHT TO LEFT
BALL_GO_RIGHT
        LDA BALL_X          ; GETTING IT AGAIN BECAUSE REFETCHING IT FOR JUMP FROM LEFT
        CLC             ; CLEAR CARRY NOT TO MESS UP CALCULATION
        ADC #1          ; ADD ONE
        CMP #22          
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
        LDA BALL_Y
        STA OLD_BALL_Y
        LDA BALL_DIRECTION
        AND #2                 ; FETCH Y direction
        CMP #2                 ; bit 1 on is UP
        BEQ BALL_GO_UP          ; GOING UP
BALL_GO_DOWN
        LDA BALL_Y          ; GETTING IT AGAIN BECAUSE REFETCHING IT FOR JUMP FROM DOWN
        CLC             ; CLEAR CARRY NOT TO MESS UP CALCULATION
        ADC #1          ; ADD ONE
        CMP #23          
        BNE BALL_Y_POSITION_OK   ;NOT AT EDGE OF THE SCREEN 
        JSR CHANGE_BALL_DIRECTION_Y
BALL_GO_UP
        SEC             ; set carry bit (in SBC the borrow bit is !carry bit)
        LDA BALL_Y          ; LOAD POSITION
        SBC #1          ; SUBSTRACT 1
        CMP #0          ; ARE WE ON TOP ROW (SCORE) 
        BNE BALL_Y_POSITION_OK   ; NOT ON TOP ROW
        JSR CHANGE_BALL_DIRECTION_Y
        JMP BALL_GO_DOWN
BALL_Y_POSITION_OK
        STA BALL_Y
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
        LDA OLD_BALL_X
        CMP BALL_X
        BNE ERASEBALL
        LDA OLD_BALL_Y
        CMP BALL_Y
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
DRAWBALL
        LDX BALL_Y
        LDA YPOS_HI,X ; SET ZERO PAGE TO ROW BASED ON LOOKUP ARRAY
        STA $FC
        LDA YPOS_LOW,X 
        STA $FB
        LDA #81       ; STASH THE BALL CHARACTER USING ZERO PAGE INDEX
        LDY BALL_X
        STA ($FB),Y
        LDX BALL_Y        ; NOW DO THE SAME TO STASH THE COLOUR IN THE RIGHT POSITION
        LDA YCOL_HI,X 
        STA $FC
        LDA #BLACK        
        LDY BALL_X
        STA ($FB),Y
DRAWFINISH
        JSR WAITFORNOTBLANK ; FINISHED DRAW, WAIT TO MAKE SURE NO LONGER IN BLANK.
        RTS



; PROBABLY NEED TO JUST WAIT FOR 0 in the raster
WAITFORBLANK
        SEC         ; set carry bit (in SBC the borrow bit is !carry bit)
        LDA RASTER ; the top 8 bits of the 9 bits of raster counter (0 to 27 is blanking, shift the least significant bit and vb is 0 to 13)
        SBC $E    ; substract 14 from RASTER value
        BPL WAITFORBLANK ; if value is positive then not in blank
        RTS

; PROBABLY NEED TO JUST WAIT FOR 27 or equivalent in the raster.
WAITFORNOTBLANK        
        SEC        ; set carry bit (in SBC the borrow bit is !carry bit)
        LDA RASTER ; the top 8 bits of the 9 bits of raster counter (0 to 27 is blanking, shift the least significant bit and vb is 0 to 13)
        SBC $E    ; substract 14 from RASTER value
        BMI WAITFORNOTBLANK ; value is negative in blanking.
        RTS


; ADDRESS FOR EACH SCREEN ROW (COLOUR AND POSITIONAL ADDRESS SHARE SAME LOW BYTE)
YPOS_HI BYTE $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F 
YPOS_LOW BYTE $00, $16, $2C, $42, $58, $6E, $84, $9A, $B0, $C6, $DC, $F2, $08, $1E, $34, $4A, $60, $76, $8C, $A2, $B8, $CE, $E4 
YCOL_HI BYTE $96, $96, $96, $96, $96, $96, $96, $96, $96, $96, $96, $96, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97

; BALL X and Y
BALL_X BYTE 10
BALL_Y BYTE 21
; OLD BALL X and Y
OLD_BALL_X BYTE 10
OLD_BALL_Y BYTE 21
; BALL DIRECTION BIT 1 X, Bit 2 Y ?0-right ?1-left, 1? up, 0?-down
BALL_DIRECTION BITS %11
