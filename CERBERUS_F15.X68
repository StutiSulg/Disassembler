*-------------------------------------------------------------------------------------------------
* Title      : Disassembler code by team CERBERUS
* Written by : Pallakh, Stuti, Ruzanna
* Date       : 11/22/2015
* Description: Disassembler
*--------------------------------------------------------------------------------------------------
                ORG         $1000
START:          NOP                     ; first instruction of program

*---------------------THIS IS I/O CODE-------------------------------------------------------------
*---------------------Code for output--------------------------------------------------------------
                LEA     WELCOME,A1
                MOVE.B  #14,D0          
                TRAP    #15         *DISPLAY WELCOME MESSAGE
            
ACC_INP         LEA     MESSAGE1,A1
                MOVE.B  #14,D0          
                TRAP    #15         *DISPLAY MESSAGE TO ENTER STARTING ADDRESS   
                JSR     GET_INPUT

*----------------Store Range Start in D4 -----------------------------------------------------------
                MOVE.L  D2,A6       *STORE STARTING ADDRESS
                MOVE.L  A6,A4       *A4 STORES STARTING ADDRESS OF EACH INSTRUCTION, HENCE MOVED
            
*-----------------------Get End---------------------------------------------------------------------
                LEA     MESSAGE2,A1
                MOVE.B  #14,D0          
                TRAP    #15         *DISPLAY MESSAGE TO STORE ENDING ADDRESS
                JSR     GET_INPUT
                LEA     ENTR,A1     *DISPLAY ENTER TO START INSTRUCTION ON NEXT LINE
                MOVE.B  #14,D0  
                TRAP    #15
            
*--------------------------check error--------------------------------------------------------------
                CMP.L   A6,D2               *CHECK IF ENDING ADDRESS IS SMALLER THAN STARTING ADDRESS
                BLT     ERR_RAN             *IN ENDING < STARTING -- GO TO ERROR
                MOVE.B  #$0,(INST_COUNT)    *SET THE COUNT TO 0 FOR NUMBER OF INSTRUCTIONS TO BE PRINTED
                BRA     ADDR_DISP
        
*--------------------Code for input------------------------------------------------------------------
GET_INPUT       MOVEA.W #$5000,A1
                MOVE.B  #2,D0           
                TRAP    #15 
                
                JSR     STORE_INPUT
                RTS
            
CHECK_ERR       CMP.W   #7000,(A1)     
                BLT     ERR_LOW 
                RTS
            
*-------------------DISPLAY AT CHARACTER--------------------------------------------------------------
ADDR_DISP       CMP.B   #$A,(INST_COUNT) *COMPARE TO CHECK IF 10 INSTRUCTIONS ARE DISPLAYED

PRINT_INST      BEQ     PRES_ENTR        
                CMP.L   D2,A4            *CHECK IF REACHED ENDING ADDRESS 
                BEQ     ASK_MORE         *IF REACHED ASK USER             
                BGT     ASK_MORE
                MOVE.L  #$0,D5
                MOVE.L  A4,D1            *MOVE ADDRESS FOR PRINTING
                MOVE.L  #$F0000000,D3    *MASK
                MOVE.L  #$6900,A1
                MOVE.L  #$1C,D7         *SET AT 28 BITS IN THE BEGINGING
            
NEXT            MOVE.L  D1,D6
                AND.L   D3,D6
                LSR.L   D7,D6         
                ADD.L   #$1,D5
                LSR.L   #$4,D3          *LSR THE MASK BY 4 BITS TO READ THE NEXT BYTE
                SUB.L   #$4,D7          *SUBRACT BY 4 IN EVERY LOOP TO READ THE NEXT BYTE
                CMP.B   #$8,D5          *CHECK IF REACHED THE 8TH BYTE
                BGT     DISP_ADD        *IF REACHED PREPARE FOR DISPLAY
                CMP.B   #10,D6
            
                BLT     ZER0_NIN        *FOR NUMBERS BELOW 10
                BRA     ALPHA_RANG      *FOR BOVE 10
            
ZER0_NIN        ADD.B   #$30,D6         
                MOVE.B  D6,(A1)+
                BRA     NEXT
           
ALPHA_RANG      SUB.B   #10,D6
                ADD.B   #$41,D6
                MOVE.B  D6,(A1)+
                BRA     NEXT

DISP_ADD        MOVE.B  #$0,(A1)
                MOVE.L  #$6900,A1
                MOVE.B  #1,D0           *Put required TRAP #15 selector (3) in D0
                TRAP    #15             *Display D0 in decimal
                BGT     PRNT_TAB

DISP_W          MOVE.B  #$0,(A1)
                MOVE.L  #$6900,A1
                MOVE.B  #1,D0           *Put required TRAP #15 selector (3) in D0
                TRAP    #15             *Display D0 in decimal
                BGT     BEGIN
    
PRNT_TAB        LEA     TAB,A1          *PRINT TAB 
                MOVE.B  #14,D0  
                TRAP    #15

                BRA     DECODER
                      
*-------------------CODE TO DIPLAY THE HEXA VALUE------------------------------------------------------          
DISPLAY         SUB.L   D5,A5           *GO TO STARTING POINT OF INSTRUCTION
                MOVE.L  #$00000000,D4   *USE D6 TO KNOW IF REACHED END OF INSTRUCTION
            
DSP_INST        MOVE.B  (A5),D4
                CMP.B   #$FF,D4         *CHECK IF REACHED END
                BEQ     STR_BK          *START PRINTING FROM FIRST BIT
                MOVE.B  (A5),D1         *DISPLAY THE INSTRUCTION
                MOVE.B  #6,D0  
                TRAP    #15
                ADD.L   #$1,A5          *ADD 1 TO A5 TO PRINT THE NEXT BYTE
                SUB.L   #$1,D5
                CMP.L   #$0,D5          *COMPARE TO KNOW IF REACHED THE END OF CURRENT INSTRUCTION
                BEQ     BEGIN  
                BGT     DSP_INST
            
STR_BK          BRA     BEGIN           *DONE PRINTING INSTRUCTION

PRES_ENTR       LEA     NEXT_INS,A1
                MOVE.B  #14,D0          
                TRAP    #15             *DISPLAY ASKING TO PRESS ENTER 
                MOVE.L  #$5556,A1  
                MOVE.B  #2,D0           
                TRAP    #15             *STORE INPUT ENTERED BY USER
                MOVE.L  (A1),D6
            
                MOVE.B  (A1),D6         *MOVE VALUE INSIDE A1 T0 COMPARE
                CMP.B   #$0,D6          *CHECK FOR ENTER 
                BEQ     NEW_IN
            
NEW_IN          MOVE.B  #$0,(INST_COUNT) *IF ENTER PRESSED - SET COUNT TO 0 AGAIN
                BRA     ADDR_DISP
  
ASK_MORE        JSR     NEWLIN
                LEA     CONT_MES,A1
                MOVE.B  #14,D0          
                TRAP    #15             *DISPLAY      
                MOVE.L  #$5558,A1
                MOVE.B  #2,D0           
                TRAP    #15             *STORE INPUT ENTERED BY USER
           
                MOVE.B  (A1),D6         *MOVE IT TO SEPERATE DATA REGISTER TO CALCULATE VALUE
                CMP.B   #$4E,D6         *CHECK IF N
                BEQ     DONE            *END PROGRAM
                CMP.B   #$6E,D6         *CHECK IF Y
                BEQ     DONE            *END PROGRAM
                CMP.B   #$59,D6         *CHECK IF Y
                BEQ     CONT1
                CMP.B   #$79,D6         
                BEQ     CONT1
                BRA     ASK_MORE        *IF ANYTHING ELSE ENTERED - ASK AGAIN
            
CONT1           JSR     NEWLIN
                BRA     ACC_INP         *G0 TO START OF PROGRAM
            
BAD_SEC         LEA     BADCOD,A1
                MOVE.B  #14,D0          
                TRAP    #15
            
CHK_DIFF        MOVE.L  A6,A3           *MOVE TO DIFFERENT ADDRESS LOCATION TO NOT DISTROY THE VALUE
                SUB.L   A4,A3           *SUBTRACT TO SEE IF ITS EQUAL TO 2
                CMP.L   #$2,A3
                BEQ     PRINT_HEX
                BLT     ADD_W           *ADD 1 TO READ A WORD VALUE 
            
ADD_W           ADD.L   #$1,A6
                BRA     CHK_DIFF

PRINT_HEX       MOVE.L  #$0,D5
                MOVE.W  (A4),D1          *MOVE ADDRESS FOR PRINTING
                MOVE.L  #$F000,D3        *MASK
                MOVE.L  #$6900,A1
                MOVE.L  #$C,D7
            
NEXT_W          MOVE.L  D1,D6
                AND.L   D3,D6
                LSR.L   D7,D6
                ADD.L   #$1,D5
                LSR.L   #$4,D3
                SUB.L   #$4,D7
                CMP.B   #$4,D5
                BGT     DISP_W
                CMP.B   #10,D6
            
                BLT     ZER0_NIN2
                BRA     ALPHA_RANG2  
            
ZER0_NIN2       ADD.B   #$30,D6
                MOVE.B  D6, (A1)+
                BRA     NEXT_W
           
ALPHA_RANG2     SUB.B   #10,D6
                ADD.B   #$41,D6
                MOVE.B  D6,(A1)+
                BRA     NEXT_W
 
*---------------------SUBROUTINE------------------------------------------------------------------
*------------------STORE INPUT AS HEXA------------------------------------------------------------
*THIS SUBROUTINE ACCEPTS THE INPUT FROM THE USER AND STORES EACH BYTE OF THE INPUT AS A CHARACTER
*IT THEN STORES THE INPUT BY TAKING EACH CHARACTERS RESPECTIVE HEXA VALUE. BOTH LOWER AND UPPER 
*CASE INPUTS ARE ACCEPTABLE AND WOULD STORE IT WITH THE RIGHT HEXA VALUE. ANY INVALID HEXA VALUE
*ENTERED BY THE USER IS DETECTED AND TAKES IT TO THE ERROR MESSAGE
*-------------------------------------------------------------------------------------------------
STORE_INPUT     MOVE.L  #$00000000,D2
                MOVE.L  #$00000000,D3
                MOVE.L  #$00000000,D5       
                
LOOP            ADD.W   D5,A1           *TO WORK FROM THE LOWEST POSITION OF THE STRING 
                ADD.B   #$1,D5
                CMP.B   D1,D5           *CHECK IF REACHED THE LAST BIT
                BGT     DONE_STORING
                LSL.L   #$4,D2
                MOVE.B  (A1),D6         *MOVE IT TO SEPERATE DATA REGISTER TO CALCULATE VALUE
        
                CMP.B   #$30,D6         *COMPARE IF VALUE IS LESS THAT $30        
                BLT     INVALID         *IF VALUE IS LESS THAN 30, GIVE INVALID ENTRY ERROR MESSAGE
                CMP.B   #$40,D6         *COMPARE WITH $40
                BLT     ZERONINE_RAN    *IF LESS THAN $40 IT WILL CALCULATE VALUE FOR 0-9 RANGE
                BGT     NINE_ABOV_RAN   *IF ABOVE $40, IT WILL GO TO ABOVE 9 RANGE
ZERONINE_RAN    CMP.B   #$39,D6         *COMPARE TO SEE IF ANY SPECIAL CHARACTERS ARE ENTERED
                BGT     INVALID         *IF VALUE IS GREATER THAN 39, GIVE INVALID ENTRY ERROR MESSAGE   
                SUB.B   #$30,D6         *IF LESS THAN $40, SUBTRACE $30 FROM THE INPUT
                BRA     CONV_DONE       *BRANCH TO CONV_DONE      
NINE_ABOV_RAN   CMP.B   #$60,D6         *COMPARE IF ITS GREATER THAN/LESS THAN $60
                BGT     SIXTY_ABOVE
                BLT     SIXTY_BELOW
SIXTY_ABOVE     CMP.B   #$66,D6    
                BGT     INVALID         *IF VALUE IS GREATER THAN 66, GIVE INVALID ENTRY ERROR MESSAGE
                SUB.B   #$61,D6         *IF GREATER THAN 60, SUBTRACT $61
                JMP     ADD             *JUMP TO ADD TO ADD 10 TO THE VALUE
SIXTY_BELOW     CMP.B   #$46,D6    
                BGT     INVALID         *IF VALUE IS GREATER THAN 46, GIVE INVALID ENTRY ERROR MESSAGE
                SUB.B   #$41,D6         *IF LESS THAN 60, subtract $41
ADD             ADD.B   #10,D6          *ADD 10 T0 D6
CONV_DONE       MOVE.B  D6,D3           *MOVE DATA FROM D6 TO D3 FOR MULTIPLICATION WITH POWERS OF 16   
                ADD.L   D3,D2
                
                MOVEA.W #$5000,A1       *SET VALUE IN A1 TO $5000 TO GET THE RIGHT BYTE DATA IN THE NEXT LOOP
                BRA     LOOP
                
DONE_STORING    RTS                     *JUMPS TO PROGRAM

*--------------SUB ROUTINE END----------------------------------------------------------------------------
BEGIN       JSR         NEWLIN
            ADD.B       #$1,(INST_COUNT) *TRACK IF 10 INSTRUCTIONS ARE PRINTED
            MOVE.L      #$00000000,D4   *SET THE LENGTH TO ZERO AGAIN TO STORE THE LENGTH OF THE NEXT INSTRUCTIOn
            MOVE.L      A6,A4
            BRA         ADDR_DISP

*------------------If here, No error----------------------------------------------------------------------
NEWLIN      LEA         ENTR,A1         *GO TO NEW LINE TO SEE NEW INSTRUCTION
            MOVE.B      #14,D0  
            TRAP        #15
            RTS
        
INVALID     LEA         INV_Hex,A1
            MOVE.B      #14,D0  
            TRAP        #15
            BRA         DONE

BREAK       MOVE.B      #2,D1

ERR_LOW     LEA         INV_LOW,A1
            MOVE.B      #14,D0  
            TRAP        #15
            BRA         DONE

ERR_RAN     LEA         INV_RAN,A1
            MOVE.B      #14,D0  
            TRAP        #15
        
            MOVEA.W     #$D4,A7 
        
DONE        MOVE.B      #9,D0
            TRAP        #15     *Halt Simulator

TB          EQU         $09
CR          EQU         $0D         
LF          EQU         $0A 

WELCOME     DC.B    '  .-----------------------------------------------------------------.',CR,LF
            DC.B    ' /  .-.                                                         .-.  \',CR,LF
            DC.B    '|  /   \     Welcome to the Cerberus Disassembler Program      /   \  |',CR,LF
            DC.B    '| |\_.  |                                                     |    /| |',CR,LF
            DC.B    '|\|  | /|    Please start test program after address $7000    |\  | |/|',CR,LF
            DC.B    '| `---. |                                                     | `---. |',CR,LF
            DC.B    '|       |                        ENJOY!                       |       |',CR,LF
            DC.B    '|       |-----------------------------------------------------|       |',CR,LF
            DC.B    '\       |                                                     |       /',CR,LF
            DC.B    ' \     /                                                       \     /',CR,LF
            DC.B    '  `---.                                                         `---.',CR,LF,0
MESSAGE1    DC.B    'Enter starting address In Hex: ',0
MESSAGE2    DC.B    'Enter ending address In Hex: ',0
INV_LOW     DC.B    'INVALID ENTRY Starting address too low',CR,LF,0
NEXT_INS    DC.B    'Press enter to see the next 10 instructions',CR,LF,0
INV_RAN     DC.B    'Range Invalid Starting Address Higher than Ending Address',CR,LF,0
CONT_MES    DC.B    'Would you like to enter another starting & ending address?',CR,LF
CONT_M      DC.B    'Press Y to continue or N to end!',CR,LF,0
INV_Hex     DC.B    'Invalid hexa value',CR,LF,0
BADCOD      DC.B    'DATA      $',0
TAB         DC.B   '',TB,0
ENTR        DC.B    '',CR,LF,0

INST_COUNT  DS.B    1

  
*-----------------------------Decoder-----------------------------------------------
* This begins the decoding section which will call on the compare table so check 
* out the first four bits of the instruction. 
*-----------------------------------------------------------------------------------
TEMPSTOR    EQU         $6900

DECODER     MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5     *Move the content to D5
            MOVEA.L     #0,A3
            LSR.L       #HEXNUM1,D5 *Shift the content of D5 to the right by 4 bits
            JMP         COMP_TABLE  *Jump to the COMP_TABLE section            
            
*--------------------------Comparision Table-------------------------------------------
* This section decodes the first 4 bits of the assembled code and figures out which 
* section it should go into next. 
*-------------------------------------------------------------------------------------
COMP_TABLE  CMP.B       #%0000,D5    *Compare the binary to the content of D5
            BEQ         SECT0000    *If equal go to this section 
            CMP.B       #%0001,D5    *Compare the binary to the content of D5
            BEQ         SECT0001    *If equal go to this section
            CMP.B       #%0010,D5    *Compare the binary to the content of D5
            BEQ         SECT0010    *If equal go to this section
            CMP.B       #%0011,D5    *Compare the binary to the content of D5
            BEQ         SECT0011    *If equal go to this section
            CMP.B       #%0100,D5    *Compare the binary to the content of D5
            BEQ         SECT0100    *If equal go to this section
            CMP.B       #%0101,D5    *Compare the binary to the content of D5
            BEQ         SECT0101    *If equal go to this section
            CMP.B       #%0110,D5    *Compare the binary to the content of D5
            BEQ         SECT0110    *If equal go to this section
            CMP.B       #%1000,D5    *Compare the binary to the content of D5
            BEQ         SECT1000    *If equal go to this section
            CMP.B       #%1001,D5    *Compare the binary to the content of D5
            BEQ         SECT1001    *If equal go to this section
            CMP.B       #%1011,D5    *Compare the binary to the content of D5
            BEQ         SECT1011    *If equal go to this section
            CMP.B       #%1100,D5    *Compare the binary to the content of D5
            BEQ         SECT1100    *If equal go to this section
            CMP.B       #%1101,D5    *Compare the binary to the content of D5
            BEQ         SECT1101    *If equal go to this section
            CMP.B       #%1110,D5    *Compare the binary to the content of D5
            BEQ         SECT1110    *If equal go to this section
            BRA         BAD_SEC     *If there was no match then it's bad code  
         
*------------------------------Sections----------------------------------------------
* This section contains all the sections the first four bits can go into and then 
* then each section looks at the next 4 bits to go into the right opcode section
*------------------------------------------------------------------------------------
SECT0000    JSR         SECHEX      *Get the second hexdecimal using method SECHEX
            CMP.B       #%0000,D5   *Compare the second hex to the ORI pattern
            BEQ         ORI_SEC     *If they match go to that pattern section
            
            CMP.B       #%0100,D5   *Compare the second hex to the SUBI pattern
            BEQ         SUBI_SEC    *If they match go to that pattern section
            
            CMP.B       #%1000,D5   *Compare the second hex to the BTST immediate section
            BEQ         BTSTI_SEC   *If they match go to that pattern section
            
            CMP.B       #%1010,D5   *Compare the second hex to the EORI section
            BEQ         EORI_SEC    *If they match go to that pattern section
            
            CMP.B       #%1100,D5   *Compare the second hex to the EORI section
            BEQ         CMPI_SEC    *IF they match go to that pattern section
            
            CMP.B       #%0110,D5   *Compare the second hex to the EORI section
            BEQ         ANDI_SEC    *IF they match go to that pattern section
              
            BTST        #0,D5       *Compare the second hex to the BTST register section
            BNE         BTSTR_SEC   *If they match go to that pattern section
            
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code                            

SECT0001    BRA         MOVEB_SEC   *Branch to MOVE.B section
       
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code  

SECT0010    JSR         SECHEX      *Get the second hexdecimal using method SECHEX
            LSL         #8,D5       *Code below prepares D5 to read only the Mode
            JSR         QUICKMOD    *Get the mode of this opcode to compare which opcode this instruction is
            CMPI.L      #%001,D5
            BEQ         MOVEAL_SEC
            BRA         MOVEL_SEC

            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code  

SECT0011    JSR         SECHEX      *Get the second hexdecimal using method SECHEX
            LSL         #8,D5       *Code below prepares D5 to read only the Mode
            JSR         QUICKMOD    *Get the mode of this opcode to compare which opcode this instruction is
            CMPI.L      #%001,D5
            BEQ         MOVEAW_SEC
            BRA         MOVEW_SEC
   
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code        
           
SECT0100    JSR         SECHEX      *Get the second hexdecimal using method SECHEX
            CMP.B       #%0100,D5   *Compare the second hex to the NEG pattern
            BEQ         NEG_SEC     *If they match go to that pattern section
            
            CMP.B       #%0110,D5   *Compare the second hex to the NOT pattern
            BEQ         NOT_SEC     *If they match go to that pattern section
            
            CMP.B       #%1000,D5   *Compare the second hex to the MOVEM pattern
            BEQ         MOVEM0_SEC  *If they match go to that pattern section
            
            CMP.B       #%1100,D5   *Compare the second hex to the MOVEM pattern
            BEQ         MOVEM1_SEC  *If they match go to that pattern section
                       
            LSL         #8,D5       *Code below prepares D5 to read only the Mode
            JSR         QUICKMOD    *Get the mode of this opcode to compare which opcode this instruction is
            
            CMPI.L      #%001,D5    
            BEQ         RTS_SEC     * Is this a RTS section?
            
            CMPI.L      #%010,D5            
            BEQ         JSR_SEC     * Is this an JSR section?
            
            CMPI.L      #%111,D5
            BEQ         LEA_SEC     * Is this a LEA section?
                                   
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code   
            
SECT0101    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5       * Store D5 to compare      
            LSR.L       #1,D5         * Shift to get only one bit in the C   
            BCC         ADDQ_SEC      * Is the carry bit clear?
            BRA         SUBQ_SEC      * Is the carry bit set?

SECT0110    JSR         SECHEX      *Get the second number to compare to
            CMP.B       #%0000,D5   *Check if this parttern fits certian opcode
            BEQ         BRA_SEC     *Yes go to BRA if not continue comparing
            
            CMP.B       #%0010,D5   
            BEQ         BHI_SEC     *Equal to? 
            
            CMP.B       #%0110,D5
            BEQ         BNE_SEC     *Equal to?
            
            CMP.B       #%0111,D5
            BEQ         BEQ_SEC     *Equal to?
            
            CMP.B       #%1101,D5
            BEQ         BLT_SEC     *Equal to?
            
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code

SECT1000    BRA         DIVS_SEC    *Brach out to DIVS only this section works

SECT1001    JSR         SECHEX      *Get the second hexdecimal using method SECHEX
            LSL         #8,D5       *Code below prepares D5 to read only the Mode
            JSR         QUICKMOD    *Get the mode of this opcode to compare which opcode this instruction is
            
            CMPI.L      #%011,D5
            BEQ         SUBA_SEC
                                    *If equal to brach to this section.
            
            CMPI.L      #%111,D5
            BEQ         SUBA_SEC    *if equal to brach to this section.
            
            BRA         SUB_SEC     *If nothing else it is equal to this brach to this section. 
   
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code
    
SECT1011    JSR         SECHEX      *Get the second hexdecimal using method SECHEX
            LSL         #8,D5       *Code below prepares D5 to read only the Mode
            JSR         QUICKMOD    *Get the mode of this opcode to compare which opcode this instruction is
            
            CMPI.L      #%010,D5
            BLE         CMP_SEC     *If equal to brach to this section.
            
            CMPI.L      #%011,D5
            BEQ         CMPA_SEC    *If equal to brach to this seciton
            
            CMPI.L      #%110,D5
            BLE         EOR_SEC     *If equal to brach to this section
            
            CMPI.L      #%111,D5    
            BLE         CMPA_SEC    *If equal to brach to this section
            
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code
            
SECT1100    JSR         SECHEX      *Get the second hexdecimal using method SECHEX
            LSL         #8,D5       *Code below prepares D5 to read only the Mode
            JSR         QUICKMOD    *Get the mode of this opcode to compare which opcode this instruction is
            
            CMPI.L      #%111,D5
            BEQ         MULS_SEC    *Brach to this section if equal to. 
            
            
            BRA         AND_SEC     *If not brach to this section if equal to. 
            
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code

SECT1101    JSR         SECHEX      *Get the second hexdecimal using method SECHEX
            LSL         #8,D5       *Code below prepares D5 to read only the Mode
            JSR         QUICKMOD    *Get the mode of this opcode to compare which opcode this instruction is
            
            CMPI.L      #%111,D5    
            BEQ         ADDA_SEC    *If equal to brach to this section. 
            
            CMPI.L      #%011,D5
            BEQ         ADDA_SEC    *If equal to brach to this section
                
            BRA         ADD_SEC
            
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code
            
SECT1110    MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5         
            ANDI.B      #%00000001,D5   *You just want to look at one bit 
            CMP.B       #1,D5           *if this bit is equal to one
            BEQ         LEFT_TURN       *Then it's a left turn rotation
            CMP.B       #0,D5
            BEQ         RIGHT_TURN      *No? it's a right turn rotation
            
            CLR         D5            *Clear out D5 for EA section to use this register 
            BRA         BAD_SEC     *If there was no match then it's bad code
            
*-------------------ROTATION SECTION--------------------------------------------------
*   If it's a rotation these functions help the instruction decode it furture to 
*   see which section this code matchs to. 
*-------------------------------------------------------------------------------------
RIGHT_TURN  ADDA.L      #1,A6       *Increment the instruction pointer A6                 
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
                
            LSR.L       #6,D5
            CMPI.B      #%11,D5
            BEQ         R_ADDR
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            
            ANDI.B      #%11000,D5
            LSR.L       #3,D5
            
            CMPI.B      #%00,D5
            BEQ         ASR_SEC
            
            CMPI.B      #%01,D5
            BEQ         LSR_SEC
            
            CMPI.B      #%11,D5
            BEQ         ROR_SEC
            
            BRA         BAD_SEC     *If there was no match then it's bad code
            
R_ADDR      MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            ANDI.L      #$0F,D5
            LSR.L       #1,D5
            
            CMPI.B      #%1,D5
            BEQ         LSRA_SEC
            
            CMPI.B      #%0,D5
            BEQ         ASRA_SEC
            
            CLR         D5            *Clear out D5 for EA section to use this register             
            BRA         BAD_SEC     *If there was no match then it's bad code

LEFT_TURN   ADDA.L      #1,A6       *Increment the instruction pointer A6
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
                
            LSR.L       #6,D5
            CMPI.B      #%11,D5
            BEQ         L_ADDR
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            
            ANDI.B      #%00011000,D5
            LSR.L       #3,D5
            
            CMPI.B      #%00,D5
            BEQ         ASL_SEC
            
            CMPI.B      #%01,D5
            BEQ         LSL_SEC
            
            CMPI.B      #%11,D5
            BEQ         ROL_SEC
            BRA         BAD_SEC     *If there was no match then it's bad code
            
L_ADDR      MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            ANDI.L      #$0F,D5
            LSR.L       #1,D5
            
            CMPI.B      #%1,D5
            BEQ         LSLA_SEC
            
            CMPI.B      #%0,D5
            BEQ         ASLA_SEC
            
            CLR         D5            *Clear out D5 for EA section to use this register             
            BRA         BAD_SEC     *If there was no match then it's bad code
               
*-------------------OPCODES Pattern Setion-------------------------------------------------
*
*
*------------------------------------------------------------------------------------------
ORI_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'O',(A5)+
            MOVE.B      #'R',(A5)+
            MOVE.B      #'I',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer            

*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read
                       
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         EXTRA_DATA
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       * Make sure the pointer has been incremented
            BRA         DISPLAY     *Brach to display since the instruction has been completed           
            
SUBI_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'S',(A5)+
            MOVE.B      #'U',(A5)+
            MOVE.B      #'B',(A5)+
            MOVE.B      #'I',(A5)+
            MOVE.B      #'.',(A5)+                        
            ADD.L       #5,D5
            
*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         EXTRA_DATA
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            
            MOVE.L      A2,A6       *Make sure the pointer has been incremented    
            BRA         DISPLAY     *Brach to display since the instruction has been completed   

SUBQ_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'S',(A5)+
            MOVE.B      #'U',(A5)+
            MOVE.B      #'B',(A5)+
            MOVE.B      #'I',(A5)+
            MOVE.B      #'.',(A5)+
            ADD.L       #5,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read            
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5

            SUBA.L      #1,A6         *Deincrement instruction pointer A6            
            JSR         SPEC_ADDQ
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5

            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out        

            MOVE.L      A2,A6       *Make sure the pointer has been incremented  
            BRA         DISPLAY     *Brach to display since the instruction has been completed
       
BTSTI_SEC   CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'B',(A5)+
            MOVE.B      #'T',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'T',(A5)+ 
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            
*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read            
           
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         EXTRA_DATA
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented             
            BRA         DISPLAY     *Brach to display since the instruction has been completed                       
            
BTSTR_SEC   CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'B',(A5)+
            MOVE.B      #'T',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'T',(A5)+ 
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            
*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read            
            
            JSR         JUST_REG
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented                 
            BRA         DISPLAY
            
EORI_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'E',(A5)+
            MOVE.B      #'O',(A5)+
            MOVE.B      #'R',(A5)+
            MOVE.B      #'I',(A5)+
            MOVE.B      #'.',(A5)+
            ADD.L       #5,D5
            
*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         EXTRA_DATA
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented
            BRA         DISPLAY

CMPI_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'C',(A5)+
            MOVE.B      #'M',(A5)+
            MOVE.B      #'P',(A5)+
            MOVE.B      #'I',(A5)+
            MOVE.B      #'.',(A5)+                    
            ADD.L       #5,D5

*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read            

            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         EXTRA_DATA
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY

MOVEB_SEC   CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'M',(A5)+  *Store letters into memory address to be read later
            MOVE.B      #'O',(A5)+
            MOVE.B      #'V',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'.',(A5)+
            MOVE.B      #'B',(A5)+            
            ADD.L       #6,D5       *Increment the amount of letters that need to be read
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5

*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6           
            JSR         REG_MODE    *Check if it's bad code

            MOVE.L      A2,A6       *Make sure the pointer has been incremented
            BRA         DISPLAY
            
MOVEAL_SEC  CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'M',(A5)+  *Store letters into memory address to be read later
            MOVE.B      #'O',(A5)+
            MOVE.B      #'V',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'A',(A5)+
            MOVE.B      #'.',(A5)+
            MOVE.B      #'L',(A5)+                        
            ADD.L       #7,D5       *Increment the amount of letters that need to be read
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5

*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            MOVE.L      #1,A3       *If it's immediate data EA needs to know that it's a long
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6           
            JSR         REG_MODE    *Check if it's bad code

            MOVE.L      A2,A6       *Make sure the pointer has been incremented                                                                        
            BRA         DISPLAY
            
MOVEL_SEC   CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'M',(A5)+  *Store letters into memory address to be read later
            MOVE.B      #'O',(A5)+
            MOVE.B      #'V',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'.',(A5)+
            MOVE.B      #'L',(A5)+            
            ADD.L       #6,D5       *Increment the amount of letters that need to be read
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            
*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            MOVE.L      #1,A3       *If it's immediate data EA needs to know that it's a long
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            
            MOVE.B      #',',(A5)+            
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6           
            JSR         REG_MODE    *Check if it's bad code

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY
            
MOVEAW_SEC  CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'M',(A5)+  *Store letters into memory address to be read later
            MOVE.B      #'O',(A5)+
            MOVE.B      #'V',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'A',(A5)+
            MOVE.B      #'.',(A5)+
            MOVE.B      #'W',(A5)+
            ADD.L       #7,D5       *Increment the amount of letters that need to be read
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5

*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read             
           
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6           
            JSR         REG_MODE    *Check if it's bad code

            MOVE.L      A2,A6       *Make sure the pointer has been incremented                                                                         
            BRA         DISPLAY
            
MOVEW_SEC   CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'M',(A5)+  *Store letters into memory address to be read later
            MOVE.B      #'O',(A5)+
            MOVE.B      #'V',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'.',(A5)+
            MOVE.B      #'W',(A5)+
            ADD.L       #6,D5       *Increment the amount of letters that need to be read
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
           
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
                       
            SUBA.L      #1,A6         *Deincrement instruction pointer A6           
            JSR         REG_MODE    *Check if it's bad code
            
            MOVE.L      A2,A6       *Make sure the pointer has been incremented                                      
            BRA         DISPLAY
            
NEG_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'N',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'G',(A5)+
            MOVE.B      #'.',(A5)+
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented                                      
            BRA         DISPLAY

NOT_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'N',(A5)+
            MOVE.B      #'O',(A5)+
            MOVE.B      #'T',(A5)+
            MOVE.B      #'.',(A5)+
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 

            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented  
            BRA         DISPLAY     *Brach to display since the instruction has been completed   
        
MOVEM0_SEC  CLR         D5            *Clear out D5 for EA section to use this register 
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            LSR.L       #8,D5
            BCC         BAD_SEC
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            CLR         D5            *Clear out D5 for EA section to use this register             
            
            MOVE.B      #'M',(A5)+
            MOVE.B      #'O',(A5)+
            MOVE.B      #'V',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'M',(A5)+
            MOVE.B      #'.',(A5)+
            ADD.L       #6,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 

            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE_M        *Get the size of this opcode_M
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         PRE_DEC
            
            MOVE.B      #',',(A5)+                     
            ADD.L       #1,D5
            
            CLR         D1
            ADDA.L      #2,A2
            
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            
            MOVE.L      A2,A6       *Make sure the pointer has been incremented  
            BRA         DISPLAY     *Brach to display since the instruction has been completed
            
MOVEM1_SEC  CLR         D5            *Clear out D5 for EA section to use this register 
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            LSR.L       #8,D5
            BCC         BAD_SEC
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            CLR         D5            *Clear out D5 for EA section to use this register          
            
            MOVE.B      #'M',(A5)+
            MOVE.B      #'O',(A5)+
            MOVE.B      #'V',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'M',(A5)+
            MOVE.B      #'.',(A5)+
            ADD.L       #6,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 

            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE_M        *Get the size of this opcode_M
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            
            MOVE.B      #',',(A5)+                     
            ADD.L       #1,D5
            
            JSR         POST_INC
            
            CLR         D1
            ADDA.L      #2,A2
            
            MOVE.L      A2,A6       *Make sure the pointer has been incremented  
            BRA         DISPLAY     *Brach to display since the instruction has been completed 
            
JSR_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'J',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'R',(A5)+            
            ADD.L       #3,D5

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read      
             
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
             
            MOVE.L      A2,A6       *Make sure the pointer has been incremented              
            BRA         DISPLAY     *Brach to display since the instruction has been completed 
    
RTS_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            CMPI.B      #$75,D5
            BNE         BAD_SEC
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            
            CLR         D5            *Clear out D5 for EA section to use this register             
            MOVE.B      #'R',(A5)+
            MOVE.B      #'T',(A5)+
            MOVE.B      #'S',(A5)+            
            ADD.L       #3,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read      

            MOVE.L      A2,A6       *Make sure the pointer has been incremented              
            BRA         DISPLAY     *Brach to display since the instruction has been completed           
       
LEA_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'L',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'A',(A5)+           
            ADD.L       #3,D5
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 

            ADDA.L      #1, A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            MOVE.B      #',',(A5)+
            MOVE.B      #'A',(A5)+            
            ADD.L       #2,D5

            SUBA.L      #1,A6         *Deincrement instruction pointer A6 
            MOVE.B      (A6),D6
            JSR         STORE_REG
            JSR         NUM_COMP

            MOVE.L      A2,A6       *Make sure the pointer has been incremented              
            BRA         DISPLAY

BRA_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'B',(A5)+
            MOVE.B      #'R',(A5)+
            MOVE.B      #'A',(A5)+            
            ADD.L       #3,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read
           
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         DISPLACE            
            BRA         DISPLAY     *Brach to display since the instruction has been completed           
            
BHI_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'B',(A5)+
            MOVE.B      #'H',(A5)+
            MOVE.B      #'I',(A5)+            
            ADD.L       #3,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read    
         
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         DISPLACE        
            BRA         DISPLAY     *Brach to display since the instruction has been completed
            
BNE_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'B',(A5)+
            MOVE.B      #'N',(A5)+
            MOVE.B      #'E',(A5)+            
            ADD.L       #3,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
                     
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         DISPLACE        
            BRA         DISPLAY     *Brach to display since the instruction has been completed
            
BEQ_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'B',(A5)+
            MOVE.B      #'E',(A5)+
            MOVE.B      #'Q',(A5)+            
            ADD.L       #3,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         DISPLACE              
            BRA         DISPLAY     *Brach to display since the instruction has been completed
            
BLT_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'B',(A5)+
            MOVE.B      #'L',(A5)+
            MOVE.B      #'T',(A5)+            
            ADD.L       #3,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         DISPLACE
            BRA         DISPLAY     *Brach to display since the instruction has been completed

ADDQ_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'A',(A5)+
            MOVE.B      #'D',(A5)+
            MOVE.B      #'D',(A5)+
            MOVE.B      #'Q',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #5,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read            
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5

            SUBA.L      #1,A6         *Deincrement instruction pointer A6            
            JSR         SPEC_ADDQ
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5

            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out        

            MOVE.L      A2,A6       *Make sure the pointer has been incremented  
            BRA         DISPLAY     *Brach to display since the instruction has been completed

DIVS_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'D',(A5)+
            MOVE.B      #'I',(A5)+
            MOVE.B      #'V',(A5)+
            MOVE.B      #'S',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer
            
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5 
           
*Add where data would be added A2
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read            
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6            
            JSR         JUST_REG

            MOVE.L      A2,A6       *Make sure the pointer has been incremented  
            BRA         DISPLAY     *Brach to display since the instruction has been completed           
            
SUB_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'S',(A5)+
            MOVE.B      #'U',(A5)+
            MOVE.B      #'B',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 

            JSR         OPMODE_SIZE *Get the size of this opmode opcode which is different form regular size
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5             
            MOVE.B      (A6),D1
            LSR.L       #1,D1
            BCC         OPMODE_C
            BRA         OPMODE_S
            
SUBA_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'S',(A5)+
            MOVE.B      #'U',(A5)+
            MOVE.B      #'B',(A5)+
            MOVE.B      #'A',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #5,D5

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            JSR         OPMODE_SIZE *Get the size of this opmode opcode which is different form regular size
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5            
            ADD.L       #1,A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out            
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            JSR         REG_OPMODEA   *Get the register infomraiton for this address register

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY     *Brach to display since the instruction has been completed       

CMP_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'C',(A5)+
            MOVE.B      #'M',(A5)+
            MOVE.B      #'P',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            JSR         OPMODE_SIZE *Get the size of this opmode opcode which is different form regular size
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            ADD.L       #1,A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            JSR         REG_OPMODE

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY     *Brach to display since the instruction has been completed
          
CMPA_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'C',(A5)+
            MOVE.B      #'M',(A5)+
            MOVE.B      #'P',(A5)+
            MOVE.B      #'A',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #5,D5  
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            JSR         OPMODE_SIZE *Get the size of this opmode opcode which is different form regular size
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            ADD.L       #1,A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            JSR         REG_OPMODEA   *Get the register infomraiton for this address register

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY     *Brach to display since the instruction has been completed
        
EOR_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'E',(A5)+
            MOVE.B      #'O',(A5)+
            MOVE.B      #'R',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            JSR         OPMODE_SIZE *Get the size of this opmode opcode which is different form regular size
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         REG_OPMODE
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5

            ADD.L       #1,A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY     *Brach to display since the instruction has been completed

AND_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'A',(A5)+
            MOVE.B      #'N',(A5)+
            MOVE.B      #'D',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 

            JSR         OPMODE_SIZE *Get the size of this opmode opcode which is different form regular size
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5             
            MOVE.B      (A6),D1
            LSR.L       #1,D1
            BCC         OPMODE_C
            BRA         OPMODE_S
             
ANDI_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'A',(A5)+
            MOVE.B      #'N',(A5)+
            MOVE.B      #'D',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         EXTRA_DATA
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented
            BRA         DISPLAY

ADD_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'A',(A5)+
            MOVE.B      #'D',(A5)+
            MOVE.B      #'D',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 

            JSR         OPMODE_SIZE *Get the size of this opmode opcode which is different form regular size
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5             
            MOVE.B      (A6),D1
            LSR.L       #1,D1
            BCC         OPMODE_C
            BRA         OPMODE_S
            
ADDA_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'A',(A5)+
            MOVE.B      #'D',(A5)+
            MOVE.B      #'D',(A5)+
            MOVE.B      #'A',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #5,D5

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read 
            
            JSR         OPMODE_SIZE *Get the size of this opmode opcode which is different form regular size
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            ADD.L       #1,A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            JSR         REG_OPMODEA   *Get the register infomraiton for this address register

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY

ASR_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'A',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'R',(A5)+            
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         ROT_SOURCE  *The rotation is stored in the source go get the register
            MOVE.B      #',',(A5)+  *Print out a , to repersent the next EA is going to be placed
            ADD.L       #1,D5       *Increment D5 so that I/O person knows how much as been printed     
            JSR         ROT_DESTIN  * Go print out the the destination register of rotation

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY
            
ASL_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'A',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'L',(A5)+   
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5

            JSR         ROT_SOURCE  *The rotation is stored in the source go get the register
            MOVE.B      #',',(A5)+  *Print out a , to repersent the next EA is going to be placed
            ADD.L       #1,D5       *Increment D5 so that I/O person knows how much as been printed     
            JSR         ROT_DESTIN  * Go print out the the destination register of rotation

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY

ASRA_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'A',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'R',(A5)+            
            MOVE.B      #'.',(A5)+
            MOVE.B      #'W',(A5)+            
            ADD.L       #5,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY
            
ASLA_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'A',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'L',(A5)+   
            MOVE.B      #'.',(A5)+
            MOVE.B      #'W',(A5)+            
            ADD.L       #5,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5            
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY
            
LSR_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'L',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'R',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         ROT_SOURCE  *The rotation is stored in the source go get the register
            
            MOVE.B      #',',(A5)+  *Print out a , to repersent the next EA is going to be placed
            ADD.L       #1,D5       *Increment D5 so that I/O person knows how much as been printed     
            JSR         ROT_DESTIN  * Go print out the the destination register of rotation

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY
            
LSL_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'L',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'L',(A5)+            
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         ROT_SOURCE  *The rotation is stored in the source go get the register
            
            MOVE.B      #',',(A5)+  *Print out a , to repersent the next EA is going to be placed
            ADD.L       #1,D5       *Increment D5 so that I/O person knows how much as been printed     
            JSR         ROT_DESTIN  * Go print out the the destination register of rotation

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY

LSRA_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'L',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'R',(A5)+
            MOVE.B      #'.',(A5)+
            MOVE.B      #'W',(A5)+            
            ADD.L       #5,D5
            
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY
            
LSLA_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'L',(A5)+
            MOVE.B      #'S',(A5)+
            MOVE.B      #'L',(A5)+            
            MOVE.B      #'.',(A5)+
            MOVE.B      #'W',(A5)+            
            ADD.L       #5,D5

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         MODE_REG    *Jumps to get the correct EA data to print out

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY
            
ROL_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'R',(A5)+
            MOVE.B      #'O',(A5)+
            MOVE.B      #'L',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5
            JSR         ROT_SOURCE  *The rotation is stored in the source go get the register
            
            MOVE.B      #',',(A5)+  *Print out a , to repersent the next EA is going to be placed
            ADD.L       #1,D5       *Increment D5 so that I/O person knows how much as been printed     
            JSR         ROT_DESTIN  * Go print out the the destination register of rotation

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY

ROR_SEC     CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'R',(A5)+
            MOVE.B      #'O',(A5)+
            MOVE.B      #'R',(A5)+
            MOVE.B      #'.',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer

            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read  
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         SIZE        *Get the size of this opcode
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5

            JSR         ROT_SOURCE  *The rotation is stored in the source go get the register
            MOVE.B      #',',(A5)+  *Print out a , to repersent the next EA is going to be placed
            ADD.L       #1,D5       *Increment D5 so that I/O person knows how much as been printed     
            JSR         ROT_DESTIN  * Go print out the the destination register of rotation

            MOVE.L      A2,A6       *Make sure the pointer has been incremented 
            BRA         DISPLAY
            
MULS_SEC    CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      #'M',(A5)+
            MOVE.B      #'U',(A5)+
            MOVE.B      #'L',(A5)+
            MOVE.B      #'S',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer 
 
            JSR         TABPRINT    *Prints out a tab into the print buffer pointed to by A5           
          
            MOVE.L      A6,A2       *Make a copy of where the pointer is in the memory address
            ADD.L       #2,A2       *Location where extra data would be stored that EA would need to read            
            
            ADDA.L      #1,A6       *Increment the instruction pointer A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6            
            JSR         JUST_REG

            MOVE.L      A2,A6          *Make sure the pointer has been incremented            
            BRA         DISPLAY     *Brach to display since the instruction has been completed 
         
*-----------------------------------OPCODE METHODS-------------------------------------------------------
* Helpful function used to decode the opcode. 
*
*--------------------------------------------------------------------------------------------------------

*| This function gets the second hexadecmial that is used to decode the second 4 bits

SECHEX      CLR         D5            *Clear out D5 for EA section to use this register 
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            ANDI.B      #HEXNUM2,D5
            RTS

*| This function is used to quickly grab the mode of a instruction to decode the opcode

QUICKMOD    ADDA.L      #1,A6       *Increment the instruction pointer A6
            MOVE.B      (A6),D5      *Move the contants of what A6 is pointing to into D5
            LSR         #6,D5
            ANDI.B      #%111,D5
            SUBA.L      #1,A6         *Deincrement instruction pointer A6  
            RTS

*| This function is used to print out a tab into the print buffer
            
TABPRINT    MOVE.B      #' ',(A5)+     * Stores enough spaces to create a tab into the print buffer
            MOVE.B      #' ',(A5)+
            MOVE.B      #' ',(A5)+
            MOVE.B      #' ',(A5)+            
            ADD.L       #4,D5       *Increment D5 so that I/O person knows how much has been stored in the print buffer  
            RTS

*| This function is used when there is an opmode that needs to be decoded
*| This is used when the combination is a mode register and then reg opmode that needs to be printed

OPMODE_C    CLR         D1
            ADD.L       #1,A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            SUBA.L      #1,A6         *Deincrement instruction pointer A6
            JSR         REG_OPMODE

            MOVE.L      A2,A6       *Make sure the pointer has been incremented  
            BRA         DISPLAY     *Brach to display since the instruction has been completed 

*| This function is used when there is an opmode that needs to be decoded when the combination is
*| register mode and then mode register that needs to be printed

OPMODE_S    CLR         D1
            JSR         REG_OPMODE
            MOVE.B      #',',(A5)+
            ADD.L       #1,D5
            
            ADD.L       #1,A6
            JSR         MODE_REG    *Jumps to get the correct EA data to print out
            
            MOVE.L      A2,A6       *Make sure the pointer has been incremented  
            BRA         DISPLAY     *Brach to display since the instruction has been completed  

*| This function is used when ADDQ needs to be decoded because some special cases are used such as the
*| combination immediate data and then a 8 bit register 

SPEC_ADDQ   MOVE.B      (A6),D6
            LSR.L       #1,D6
            ANDI.B      #%111,D6
            MOVE.B      #'#',(A5)+
            MOVE.B      #'$',(A5)+
            ADD.L       #2,D5
            CMPI.B      #0,D6       *CHECK IF 000 BECAUSE THAT EQUALS 8 BIT
            BEQ         BIT8_REG
            JSR         NUM_COMP
            RTS

*| This 8 bit register is used when there is an 000 which represents an 8 for some functions
           
BIT8_REG    MOVE.B      #'8',(A5)+
            ADD.L       #1,D5
            RTS 
                            
*------------------- OPMODE Variables------------------------------------------------------
HEXNUM1     EQU         4           *Number of bits needed to be shited 
HEXNUM2     EQU         $0F         *Number to mask and get first hex 

*---------------------EA SECTION----------------------------------------------------------
*-----------------------SIZE--------------------------------------------------------------
SIZE        MOVE.B      (A6),D6     *copy contents of A6 to D6
            MOVE.B      #24,D1      *to shift left by 24 bits
            LSL.L       D1,D6
            MOVE.B      #30,D1      *to shift right 30 bits
            LSR.L       D1,D6       *separate 2 bits for size
            CLR         D1          *clear D1
            JMP         OPER_SIZE   *jump to operation size
            
*-------------------IDENTIFY_SIZE----------------------------------------------------------            
OPER_SIZE   CMP.B       #%00,D6     *idetify the size by comparing the 2 bits
            BEQ         BYTE_S      *if equals 00 go to byte size

            CMP.B       #%01,D6
            MOVEA.L     #0,A3
            BEQ         WORD_S
        
            CMP.B       #%10,D6
            MOVEA.L     #1,A3
            BEQ         LONG_S 
            
            CMP.B       #%11,D6
            MOVEA.L     #1,A3
            BEQ         WORD_S 
      
*---------------------Register------------------------------------------------------------
REG_OPMODE  MOVE.B      (A6),D6
            ANDI.B      #$0F,D6
            LSR.L       #1,D6
            
            MOVE.B      #'D',(A5)+
            ADD.L       #1,D5
            JSR         NUM_COMP
            RTS
            
REG_OPMODEA MOVE.B      (A6),D6
            ANDI.B      #$0F,D6
            LSR.L       #1,D6
            
            MOVE.B      #'A',(A5)+
            ADD.L       #1,D5
            JSR         NUM_COMP
            RTS
            
DISPLACE    MOVE.W      (A6),D6                     
            ANDI.W      #$00FF,D6
            
            CMPI.L      #0,D6
            BEQ         DIS_POS
            BRA         DIS_NEG

DIS_NEG     MOVE.L      A4,D1
            NEG         D6
            ANDI.L      #$FF,D6
            SUB.L       D6,D1
            MOVE.L      D1,D6
            CLR         D1
           
            MOVEA.L     #TEMPSTOR,A1
            MOVE.L      D1,(A1)
            ADDA.L      #4,A1
            ADD.L       #2,D6 
            MOVE.L      D6,(A1)
            
            CLR         D6
            JSR         WHOLEADD
            ADDA.L      #2,A6
            RTS

DIS_POS     MOVEA.L     #TEMPSTOR,A1
            CLR         D6
            MOVE.L      D6,(A1)
            ADDA.L      #4,A1
            MOVE.W      (A2),D6
            ADD.L       A4,D6
            ADD.L       #2,D6            
            MOVE.L      D6,(A1)
            
            CLR         D6
            JSR         WHOLEADD
            
            ADDA.L      #4,A6
            RTS
            
ROT_SOURCE  MOVE.B      (A6),D6
            LSR.L       #5,D6
            LSR.L       #1,D6
            BCC         ROT_IMM
            BRA         ROT_REG
 
ROT_IMM     JSR         ROT_FUN
            
            MOVE.B      #'#',(A5)+
            ADD.L       #1,D5
            
            CMPI.B      #0,D6       *CHECK IF 000 BECAUSE THAT EQUALS 8 BIT
            BEQ         BIT8_REG
            JSR         NUM_COMP
            RTS

ROT_REG     JSR         ROT_FUN
            
            MOVE.B      #'D',(A5)+
            ADD.L       #1,D5
            
            CMPI.B      #0,D6       *CHECK IF 000 BECAUSE THAT EQUALS 8 BIT
            BEQ         BIT8_REG
            JSR         NUM_COMP
            RTS     
            
ROT_FUN     SUBA.L      #1,A6         *Deincrement instruction pointer A6
            MOVE.B      (A6),D6
            ANDI.B      #$0F,D6
            LSR.L       #1,D6
            RTS 

ROT_DESTIN  ADDA.L      #1,A6       *Increment the instruction pointer A6
            MOVE.B      (A6),D6
            ANDI.B      #$0F,D6
            ANDI.B      #%111,D6
            MOVE.B      #'D',(A5)+
            ADD.L       #1,D5
            
            JSR         NUM_COMP
            RTS         
*---------------------------------------------------------------------------------------------            
BYTE_S      MOVE.B      #'B',(A5)+
            ADD.L       #1,D5
            RTS
            
WORD_S      MOVE.B      #'W',(A5)+
            ADD.L       #1,D5
            RTS
            
LONG_S      MOVE.B      #'L',(A5)+
            ADD.L       #1,D5  
            RTS
            
*---------------------MODE_REG---------------------------------------------------------------
*receive A6 pointing to the correct location from OP code
MODE_REG    MOVE.B      (A6),D6         *Load D6 with content in A6 to edit
            MOVE.B      #26,D1          *To shift to the left by 26 bits         
            LSL.L       D1,D6           *Shift content of D6 to the left by 26 bits
            MOVE.B      #29,D1          *Shift to the right by 29 bits
            LSR.L       D1,D6           *only recieving now the 3 bits for mode
            MOVE.L      #0,D1           *Clear out D1 since it is used for print
            MOVE.B      (A6),D1         *Going to get the register information now
            ANDI.B      #%00000111,D1   *Taking out everything in front and leaving only the 3 bits of register
                        
            JMP         MODEDECODER 
            
*---------------------REG_MODE--------------------------------------------------------------
REG_MODE    MOVE.B      (A6),D6
            ANDI.B      #$0F,D6
            MOVE.B      #$8,D1
            LSL.L       D1,D6  
            ADD.L       #1,A6        *pointing to the next byte
            MOVE.B      (A6),D6      *store the next byte into D6
            LSR.L       #6,D6
            SUBA.L      #1,A6         *Deincrement instruction pointer A6        *A6 points back to the original
            MOVE.L      #0,D1        *Clear out D1   
         
* To decode the mode we need D6 to contain only the last 3 bits
            ANDI.B      #%00000111,D6 *D6 contains the Mode
            
            MOVE.B      (A6),D1       *D1 contains the Address
            ANDI.B      #$0F,D1
            LSR.L       #1,D1
            
            JMP        MODEDECODER            
                        
*-------------------------------JUST-REGISTER-----------------------------------------------
JUST_REG    MOVE.B      (A6),D6
            JSR         STORE_REG
            
            MOVE.B      #'D',(A5)+
            ADD.L       #1,D5
            
            JMP         NUM_COMP
            
*------------------------------STORE_REG------------------------------------------------------
STORE_REG   LSR.L       #1,D6
            ANDI.B      #%00000111,D6
            RTS
            
*-------------------------------EXTRA---------------------------------------------------------- 
EXTRA_DATA  JSR         DATA
            RTS

*-------------------------------OPMode----------------------------------------------------------    
OPMODE_SIZE MOVE.B      (A6),D6
            ANDI.B      #$0F,D6
            MOVE.B      #8,D1
            LSL.L       D1,D6
            ADD.L       #1,A6       *pointing to the next byte
            MOVE.B      (A6),D6     *Storing the next byte into D6
            LSR.L       #6,D6
            SUBA.L      #1,A6         *Deincrement instruction pointer A6        *Subract 1 from A6 so the pointer is back to the original
            MOVE.L      #0,D1        *Clear out D1
            
                                       *To decode the mode we need D6 to contain only the last 3 bits
            ANDI.B      #%00000111,D6  *D6 contains the Mode            
            
            CMP.B       #%000,D6
            BEQ         BYTE_OP
            
            CMP.B       #%100,D6
            BEQ         BYTE_OP

            CMP.B       #%001,D6
            BEQ         WORD_OP
            
            CMP.B       #%101,D6
            BEQ         WORD_OP
            
            CMP.B       #%011,D6
            BEQ         WORD_OP
        
            CMP.B       #%010,D6
            BEQ         LONG_OP
 
            CMP.B       #%110,D6
            BEQ         LONG_OP 
            
            CMP.B       #%111,D6
            BEQ         LONG_OP  
*---------------------------------------------------------------------------------------------            
BYTE_OP     MOVE.B      #'B',(A5)+
            ADD.L       #1,D5
            RTS
            
WORD_OP     MOVE.B      #'W',(A5)+
            ADD.L       #1,D5
            RTS
            
LONG_OP     MOVE.B      #'L',(A5)+
            ADD.L       #1,D5
            ADDA.L      #1,A3       *Increment A3 by one so that it's known that it is a long  
            RTS 
 
*-----------------------MOVEM------------------------------------------------------------------   
*-------------------SIZE_MOVEM-----------------------------------------------------------------
SIZE_M      MOVE.B      (A6),D6
            MOVE.B      #25,D1          *to shift left by 25 bits
            LSL.L       D1,D6
            MOVE.B      #31,D1          *to shift right 31 bits
            LSR.L       D1,D6           *separate 1 bit for size
            CLR         D1              *clear D1
            JMP         OPER_SIZEM
           
**-------------------IDENTIFY_SIZE--------------------------------------------------------------           
OPER_SIZEM  CMP.B       #%0,D6
            BEQ         WORD_M
                       
            CMP.B       #%1,D6
            BEQ         LONG_M
            
WORD_M      MOVE.B      #'W',(A5)+
            ADD.L       #1,D5
            RTS
                        
LONG_M      MOVE.B      #'L',(A5)+
            ADD.L       #1,D5         
            RTS
            
*---------------------PRE DECREMENT--------------------------------------------------------------
PRE_DEC     MOVE.W      (A2),D6        * Look at A2 which points at the word value of extra data
            MOVE.W      D6,D1
                      
            BRA         CORDIR
            
*---------------------POST INCREMENT--------------------------------------------------------------            
*----------------------CORDIRECTION---------------------------------------------------------------
CORDIR      ANDI.W      #$FF00,D1
            CMPI.W      #0,D1
            BEQ         MASKA_CALC
            
            JSR         MASKD_CALC
            MOVE.W      D6,D1
            ANDI.W      #$00FF,D1
            CMPI.W      #0,D1
            BNE         ADD_SLASH
            RTS

ADD_SLASH   MOVE.B      #'/',(A5)+               
            ADD.L       #1,D5             
            BRA         MASKA_CALC            
*------------------------------------------------------------------------------------------------
POST_INC    MOVE.W      (A2),D6
            MOVE.L      #31,D1
            
HELP_LOOP   LSR.W       #1,D6      *This section of code will rearranged the masked bit to match the predecrement formate
            BCS         ADD_SECM            

CONT_HELP   BRA         CHECK_D1
          
ADD_SECM    BSET        D1,D6           
            BRA         CONT_HELP
                      
CHECK_D1    SUB.L       #1,D1
            CMPI.L      #15,D1
            BEQ         CONT_DONE
            BRA         HELP_LOOP
           
CONT_DONE   LSR.L       #8,D6
            LSR.L       #8,D6
            MOVE.W      D6,D1
            MOVEA.L     #0,A1
            BRA         CORDIR 
             
*----------------------Figure out the mask----------------------------------------------------------
MASKD_CALC  CLR         D1
            MOVE.L      #15,D1      *Start D1 at 15 which is the first bit to look at
           
            MOVE.B      #'D',(A5)+  *Put in D into A5
            ADD.L       #1,D5 
           
            MOVEA.L     #0,A1
            JSR         MOVEM_LP1
           
            MOVE.B      #'-',(A5)+  *Add a - to A5 for syntax reasons
            ADD.L       #1,D5       *Increment D5 since we added to print  
           
            MOVE.B      #'D',(A5)+  *Stor D into the printer
            ADD.L       #1,D5 
           
            MOVEA.L     #0,A1
            
*This is the loop to find the largest register the register list contained
MOVEM_LOOP  JSR         MOVEM_DATA  *Test the bit D1 is storing
            SUB.L       #1,D1       *Deincrement D1 
            BRA         CHECK_END   *Check if this is the end of where data registers list are held
           
CHECK_END   CMPI.L      #7,D1       *Check if D1 has reached the end of the data register list bit
            BEQ         MOVEM_DONE  *YES? then you are done in finding the largest
            BRA         MOVEM_LOOP  *NO? then do the loop again
           
MOVEM_DONE  CMPA.L      #0,A1
            BEQ         NORANGE
            ADDA.L      #1,A5       *Increment A5 now so that it's printer is pointing to the next section
            ADD.L       #1,D5       *Increment D5 so that I/O knows how much to read
           
            RTS
*--------------------------NO------------------------------------------------------------------
*Figures out the A register range
MOVEM_LP1   JSR         MOVEM_DATA  *Check if this bit is set
            SUB.L       #1,D1       *Deincrement which bit to look at
            BRA         CHECK_END1  *Branch to checking if it has found a set bit which is stored in A1
           
CHECK_END1  CMPA.L      #1,A1       *If A1 is set that means a the starting register was found  
            BEQ         MOVEM_DO1   *YES? Move on to done
            BRA         MOVEM_LP1   *NO? Then do the loop again
           
MOVEM_DO1   ADDA.L      #1,A5       *Increment A5 since we added to print
            ADD.L       #1,D5       *Increment D5 since we added to print
            RTS
            
* WHEN THERE WAS NO RANGE FOUND
NORANGE     MOVE.B      #$FF,-(A5)
            MOVE.B      #$FF,-(A5)
            SUB.L       #2,D5
           
            RTS 
*----------------------------------------------------------------------------------------------------                     
MASKA_CALC  MOVE.L      #7,D1
            MOVE.B      #'A',(A5)+
            ADD.L       #1,D5
           
            MOVEA.L     #0,A1          
            JSR         MOVEM_LP1 
           
            MOVEA.L     #0,A1
            MOVE.B      #'-',(A5)+  *Add a - to A5 for syntax reasons
            ADD.L       #1,D5       *Increment D5 since we added to print                                              
                              
            MOVE.B      #'A',(A5)+
            ADD.L       #1,D5 
          
MOVEMA_LOOP JSR         MOVEM_DATA
            SUB.L       #1,D1
            BRA         CHECKA_END            
           
CHECKA_END  CMPI.L      #-1,D1
            BEQ         MOVEMA_DONE
            BRA         MOVEMA_LOOP
           
MOVEMA_DONE CMPA.L      #0,A1
            BEQ         NORANGE
            ADDA.L      #1,A5
            ADD.L       #1,D5           
            CLR         D1                   
            RTS
            
*---------------------MOVEM__DATA----------------------------------------------------------------
MOVEM_DATA  CMPI.L      #15,D1
            BEQ         DATA_R0     *if they are not equal meaning the bit is 1 go to DATA_R0
           
            CMPI.L      #14,D1
            BEQ         DATA_R1
           
            CMPI.L      #13,D1
            BEQ         DATA_R2
   
            CMPI.L      #12,D1
            BEQ         DATA_R3          
                
            CMPI.L      #11,D1
            BEQ         DATA_R4            
               
            CMPI.L      #10,D1
            BEQ         DATA_R5            
   
            CMPI.L      #9,D1
            BEQ         DATA_R6
                             
            CMPI.L      #8,D1 
            BEQ         DATA_R7
                           
            CMPI.L      #7,D1 
            BEQ         ADDR_R0
                            
            CMPI.L      #6,D1 
            BEQ         ADDR_R1
                
            CMPI.L      #5,D1 
            BEQ         ADDR_R2
          
            CMPI.L      #4,D1 
            BEQ         ADDR_R3
               
            CMPI.L      #3,D1 
            BEQ         ADDR_R4
                
            CMPI.L      #2,D1 
            BEQ         ADDR_R5
                 
            CMPI.L      #1,D1 
            BEQ         ADDR_R6
             
            CMPI.L      #0,D1 
            BEQ         ADDR_R7
            
            RTS

DATA_R0     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'0',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                    
            RTS
            
DATA_R1     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'1',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                                   
            RTS
            
DATA_R2     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'2',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                                  
            RTS
            
DATA_R3     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'3',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1   
                                   
            RTS
            
DATA_R4     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'4',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                                 
            RTS
            
DATA_R5     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'5',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                               
            RTS
            
DATA_R6     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'6',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                                 
            RTS
            
DATA_R7     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'7',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                                     
            RTS

*-----------------------------------------------------------------------          
ADDR_R0     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'0',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                         
            RTS
            
ADDR_R1     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'1',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                                  
            RTS
            
ADDR_R2     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'2',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                               
            RTS
            
ADDR_R3     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'3',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                               
            RTS
            
ADDR_R4     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'4',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                              
            RTS
            
ADDR_R5     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'5',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                                
            RTS
            
ADDR_R6     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'6',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                               
            RTS
            
ADDR_R7     BTST        D1,D6
            BEQ         GOTORTS     *IF IT IS NOT SET GO BACK
            MOVE.B      #'7',(A5)   *IF IT IS SET THEN STORE THE 1
            ADD.L       #1,A1                                  
            RTS

GOTORTS     RTS
        
*------------------------COMPARISON------------------------------------------------------------
*---------------------------MODE---------------------------------------------------------------
MODEDECODER CMP.B       #%000,D6    *compare
            BEQ         SECTDataR   *if equal branch to the specified section        
            CMP.B       #%001,D6
            BEQ         SECTAddrR
            CMP.B       #%010,D6
            BEQ         SECTIndirA
            CMP.B       #%011,D6
            BEQ         SECTIncr
            CMP.B       #%100,D6
            BEQ         SECTDecr
            CMP.B       #%111,D6
            BEQ         SECT111

            BRA         BAD_SEC     *If there was no match then it's bad code     *If none of the combinations match its bad code
            
*-------------------------------------------------------------------------------------------------
SECTDataR   JSR        REG_BIT
            MOVE.B     #'D',(A5)+   *Load D to print
            ADD.L      #1,D5        *increment D5 for print
            JSR        NUM_COMP     *Go to compare numbers
            RTS 

SECTAddrR   JSR        REG_BIT
            MOVE.B     #'A',(A5)+   
            ADD.L      #1,D5 
            JSR        NUM_COMP
            RTS
  
SECTIndirA  JSR        REG_BIT
            MOVE.B     #'(',(A5)+
            MOVE.B     #'A',(A5)+
            ADD.L      #2,D5 
            JSR        NUM_COMP
            MOVE.B     #')',(A5)+
            ADD.L      #1,D5
            RTS

SECTIncr    JSR        REG_BIT
            MOVE.B     #'(',(A5)+
            MOVE.B     #'A',(A5)+
            ADD.L      #2,D5 
            JSR        NUM_COMP
            MOVE.B     #')',(A5)+
            MOVE.B     #'+',(A5)+
            ADD.L      #2,D5     
            RTS        
            
SECTDecr    JSR        REG_BIT
            MOVE.B     #'-',(A5)+
            MOVE.B     #'(',(A5)+
            MOVE.B     #'A',(A5)+
            ADD.L      #3,D5 
            JSR        NUM_COMP
            MOVE.B     #')',(A5)+
            ADD.L      #1,D5
            RTS
            
SECT111     JSR        REG_BIT
            CMP.B      #%000,D6
            BEQ        WORD
            CMP.B      #%001,D6
            BEQ        LONG
            CMP.B      #%100,D6
            BEQ        DATA
            RTS

*---------------------------EXTRA DAT($_#)--------------------------------------------------------------
WORD        MOVE.B     #'$',(A5)+
            ADD.L      #1,D5
            MOVE.B     #2,D1
            JSR        CHECKEMPTY
                            
ED_READ     MOVE.B     (A2),D6            
            LSR.L      #4,D6    *only the first hex is remaining
            CMP.B      #10,D6
            BLT        ADDN
            JSR        ADDL  
 
CONT        MOVE.B     (A2)+,D6
            ANDI.B     #$0F,D6
            CMP.B      #10,D6
            BLT        ADDN2
            JSR        ADDL

CONT2       SUBI.B     #1,D1
            CMP.B      #0,D1
            BEQ        EXT_DONE
            BRA        ED_READ 
            
EXT_DONE    CLR        D1
            RTS    
            
LONG        MOVE.B     #'$',(A5)+
            ADD.L      #1,D5
            MOVE.B     #4,D1
            JSR        CHECKEMPTY                            
            JMP        ED_READ
           
DATA        MOVE.B     #'#',(A5)+
            ADD.L      #1,D5 
            
            CMPA.L     #0,A3    
            BEQ        WORD     *if A3 points to 0, jump to word
            BRA        LONG     *if A3 points to 1, jump to long         

CHECKEMPTY  MOVE.B     (A2),D6
            CMPI.B     #0,D6
            BEQ        CHGEMPTY
            RTS
            
CHGEMPTY    ADDA.L      #1,A2
            SUBI.B      #1,D1
            RTS
            
*-----------------------DISPLACMENTS SPECIAL to PRINT OUT ADDRESSS-----------------------------------------------------
EDS_READ    MOVE.B      (A1),D6
            LSR.L       #4,D6        *only the first hex is remaining
            CMP.B       #10,D6
            BLT         ADDNS
            JSR         ADDLS  
 
CONTS       MOVE.B      (A1)+,D6
            ANDI.B      #$0F,D6
            CMP.B       #10,D6
            BLT         ADDN2S
            JSR         ADDLS

CONT2S      SUBI.B      #1,D1
            CMP.B       #0,D1
            BEQ         EXTS_DONE
            BRA         EDS_READ 
            
EXTS_DONE   CLR         D1
            RTS    
            
WHOLEADD    MOVE.B      #4,D1                                        
            JMP         EDS_READ
            
ADDNS       ADD.B       #$30,D6
            MOVE.B      D6,(A5)+
            ADD.L       #1,D5
            BRA         CONTS

ADDN2S      ADD.B       #$30,D6
            MOVE.B      D6,(A5)+
            ADD.L       #1,D5
            BRA         CONT2S
           
ADDLS       SUB.B       #9,D6
            ADD.B       #$40,D6
            MOVE.B      D6,(A5)+
            ADD.L       #1,D5
            RTS

*-----------------------FunctionS-----------------------------------------------------------------
REG_BIT     MOVE.L      D1,D6
            MOVE.L      #0,D1       *Clear out D1 so I/O can use it     
          
            RTS            
            
ADDN        ADD.B       #$30,D6
            MOVE.B      D6,(A5)+
            ADD.L       #1,D5
            BRA         CONT

ADDN2       ADD.B       #$30,D6
            MOVE.B      D6,(A5)+
            ADD.L       #1,D5
            BRA         CONT2
           
ADDL        SUB.B       #9,D6
            ADD.B       #$40,D6
            MOVE.B      D6,(A5)+
            ADD.L       #1,D5
            RTS

*-----------------Print_Numbers---------------------------------------------------------------------
NUM_ZERO    MOVE.B      #'0',(A5)+  *print 0 after D
            ADD.L       #1,D5
            RTS
NUM_ONE     MOVE.B      #'1',(A5)+
            ADD.L       #1,D5
            RTS
NUM_TWO     MOVE.B      #'2',(A5)+
            ADD.L       #1,D5
            RTS
NUM_THREE   MOVE.B      #'3',(A5)+
            ADD.L       #1,D5
            RTS
NUM_FOUR    MOVE.B      #'4',(A5)+
            ADD.L       #1,D5
            RTS
NUM_FIVE    MOVE.B      #'5',(A5)+
            ADD.L       #1,D5
            RTS
NUM_SIX     MOVE.B      #'6',(A5)+
            ADD.L       #1,D5
            RTS
NUM_SEVEN   MOVE.B      #'7',(A5)+
            ADD.L       #1,D5
            RTS

*----------------Compare_Numbers--------------------------------------------------------------------------
NUM_COMP    CMP.B      #%000,D6     *If 0
            BEQ        NUM_ZERO     *Go to print 0
            CMP.B      #%001,D6
            BEQ        NUM_ONE
            CMP.B      #%010,D6
            BEQ        NUM_TWO
            CMP.B      #%011,D6
            BEQ        NUM_THREE
            CMP.B      #%100,D6
            BEQ        NUM_FOUR 
            CMP.B      #%101,D6
            BEQ        NUM_FIVE
            CMP.B      #%110,D6
            BEQ        NUM_SIX
            CMP.B      #%111,D6
            BEQ        NUM_SEVEN
            
            RTS

            END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
