*-----------------------------------------------------------
* Title      :Test Program
* Written by :Cerburse
* Date       :11/17/15 start date
* Description:Project test file
*-----------------------------------------------------------
RNUM1    EQU        $10             *First number
RNUM2    EQU        $20             *Second number
RNUM3    EQU        $3000           *Third number
PNUM1    EQU        $AA
PNUM2    EQU        $832
PNUM3    EQU        $7000
PNUM4    EQU        $AAAA
SNUM1    EQU         $09             *Byte Size Number
SNUM2    EQU         $009F00B2       *Long Word Size Number
SNUM3    EQU         $AAAA           *Memory variable   
       
        ORG         $7000             *Starting address
                
start   *NOP
         
**---------------MOVE--------------------------------------------------------------------------------
        
        MOVE.B      #$BB,D1         *Load BB to D1
        MOVE.B      #RNUM1,D1       *Load D1 with value in RNUM1
        MOVE.W      #RNUM2,D0       *Load D0 with value in RNUM2
        MOVEA.W     D0,A1           *Load contents of D0 to A1
    
        MOVE        #$123,(A0)      *Point A0 to the value 123
        MOVE        (A0),D2         *Copy the item pointed at by A0 to D2 

        SWAP        D0
        ORI.L       #$EFFF,D4 
         AND         #$45, D0        

        
         MOVEM.L    (A6)+,D2-D4
         MOVEM.L    (A6)+,D2
         MOVEM.L    (A6)+,A1-A2/D1-D3
         MOVEM.L    A1-A2/D1-D3,-(A6)

         MOVEM.L    (A6)+,D2-D4
         MOVEM.L    (A6)+,D2
         MOVEM.L    (A6)+,A1-A2/D1-D3
         MOVEM.L    A1-A2/D1-D3,-(A6) 
         MOVEM.L    A1,-(A6)
         MOVEM.L    D1,-(A6)
         MOVEM.L    A1-A3,-(A6)
         MOVEM.L    D1-D3,-(A6)      
*---------------ADD-----------------------------------------------------------------------------------
        ADD.B       #$05, D0        *Add byte 05 to the byte in D0
                                    *D0 value becomes 25 after ADD
        MOVE.W      #$1357,D3       *Load D3 with the data
        ADDA.W      D3,A3           *Add the data in D3 to the dest. address register A3
        ADDQ.L      #%1000,A2       *ADDQ: Add immediate value 1 to 8. Add 8 to the data in A2        
*--------------SUB------------------------------------------------------------------------------------
        MOVE.L      #RNUM3,D1       *Overload D1 with data in RNUM3
        SUB.L       D0,D1           *Subtracts D0 data from D1 (D1-D0), store result in D1.
        SUBA.W      A2,A1           *Subtracts source from dest. addr. register. Stores the result in the address register            
        SUBI        #1,D0           *Loads effective address into specified address register        
*-------------MULS--------------------------------------------------------------------------------------
        MULS        D2,D0           *Multiply data in D0 and D2         
*-------------DIVS--------------------------------------------------------------------------------------
        DIVS        D2,D0           *Divide data in D0 by D2        
*-------------LEA---------------------------------------------------------------------------------------
        LEA.L       (A2),A3         *
*-------------AND----------------------------------------------------------------------------------------
        *AND         D3, ea          *Logical AND
       
*--- ----------ORI----------------------------------------------------------------------------------------
           
*-----------------------------NEG------------------------------------------------------------------------        
        NEG.W      PNUM2         *NEGATE IMMEDIATE DATA
        MOVEA.W    #$834,A3      *MOVE TO ADDRESS REGISTER A3
        NEG.B     (A3)           *NEGATE ADDRESS REGISTER INDIRECT  
        NEG.W     (a2)+          *NEGATE ADDRESS REGISTER INDIRECT WITH POST INCREMENTING
        NEG.B    -(a2)           *NEGATE ADDRESS REGISTER INDIRECT WITH PRE DECREMENTING
        MOVE.B   #PNUM1, D3      *MOVE BYTE DATA TO D3
        NEG.W     D3             *NEGATE DATA REGISTER D3

*-----------------------------EOR-----------------------------------------------------------------------         
        MOVE.W   #$1234,D4      *MOVE WORD DATA tO D4
        EOR.B    #$42,D4        *EXCLUSIVE OR ON BYTE DATA
        EOR.B    D3,D4          *EOR ONE DATA REGISTER WITH ANOTHER
        EOR.B    D4,(a3)        *EOR USING ADDRESS REGISSTER INDIRECT
        EORI.B   #$44,(a4)      *EORI USING ADDRESS REGISTER INDIRECT
*-----------------------------NOT----------------------------------------------------------------------- 
        NOT.B       D4            *NOT ON DATA REGISTER
        NOT.B       $839           *NOT ON MEMORY
        NOT.B       (A3)           *NOT ON INDIRECT ADDRESS
        NOT.B       (A4)+          *NOT ADDRESS REGISTER INDIRECT WITH POST INCREMENTING
        NOT.B       -(A2)          *NOT ADDRESS REGISTER INDIRECT WITH PRE DECREMENTINg
*-----------------------------LSL,LSR,ASL,ASR----------------------------------------------------------------------- 

        LSL.B       #$02,D3        *LSL BY 02 BITS ON DATA REGISTER
        LSL.B       D3,D4          *LSL BY 02 BITS ON TWO DATA REGISTERS
        LSL.W       (A3)           *LSL BY 01 BITS ON ADDRESS REGISTER INDIRECT
        MOVEA.W     #$834,A4      *MOVE TO ADDRESS REGISTER A4
        LSL.W       (A3)+          *LSL BY 01 BITS ON ADDRESS REGISTER INDIRECT WITH POST INCREMENTING
        LSL.W       -(A2)          *LSL BY 01 BITS ON ADDRESS REGISTER INDIRECT WITH PRE DECREMENTING
        LSL.W       $434           *LSL ON MEMORY
        
        LSR.B       #$02,D4        *LSR BY 02 BITS ON DATA REGISTER
        LSR.B       D3,D4          *LSR BY 02 BITS ON TWO DATA REGISTERS
        LSR.W       (A4)           *LSR BY 01 BITS ON ADDRESS REGISTER INDIRECT
        LSR.W       (A3)+          *LSR BY 01 BITS ON ADDRESS REGISTER INDIRECT WITH POST INCREMENTING
        LSR.W       -(A4)          *LSR BY 01 BITS ON ADDRESS REGISTER INDIRECT WITH PRE DECREMENTING
        LSR.W       $444           *LSR ON MEMORY
        
        ASL.B       #$02,D3        *ASL BY 02 BITS ON DATA REGISTER
        ASL.B       D3,D4          *ASL BY 02 BITS ON TWO DATA REGISTERS
        ASL.W       (A3)           *ASL BY 01 BITS ON ADDRESS REGISTER INDIRECT
        ASL.W       (A4)+          *ASL BY 01 BITS ON ADDRESS REGISTER INDIRECT WITH POST INCREMENTING
        ASL.W       -(A2)          *ASL BY 01 BITS ON ADDRESS REGISTER INDIRECT WITH PRE DECREMENTING
        ASL.W       $434           *ASL ON MEMORY
        
        ASR.B       #$02,D4        *ASR BY 02 BITS ON DATA REGISTER
        ASR.B       D3,D4          *ASR BY 02 BITS ON TWO DATA REGISTERS
        ASR.W       (A4)           *ASR BY 01 BITS ON ADDRESS REGISTER INDIRECT
        ASR.W       (A3)+          *ASR BY 01 BITS ON ADDRESS REGISTER INDIRECT WITH POST INCREMENTING
        ASR.W       -(A4)          *ASR BY 01 BITS ON ADDRESS REGISTER INDIRECT WITH PRE DECREMENTING
        ASR.W       $444           *ASR ON MEMORY
*--------------------------S-----------------------------------------
        MOVEA.L     #SNUM2,A1       *Load SNUM2 in A1
        MOVEA.L     #SNUM2,A2       *Load SNUM2 in A2
        MOVE.L      #SNUM2,D5       *Load SNUM2 in D5
        MOVE.B      #SNUM1,D6       *Load SNUM1 in D6
        MOVE.W      #$9800,D7       *Load immediate date in D7
*---------------------------ROL,ROR----------------------------------
        ROL.B       #6,D5           *Rotate the byte in D0, 6 bits to the left
        ROR.B       #6,D5           *Rotate the byte in D0, AA bits to the right
        ROL.W       #1,D3

*--------------------------BTST-------------------------------------
        BTST        D6,#$1234           *Test(bit value inside of D6 of destination D5) and store in Z
        BTST        D6,$1234          *Test(bit value inside of D6 of destination D5) and store in 
        BTST        D6,(A6)          *Test(bit value inside of D6 of destination D5) and store in       
        BTST        D6,(A6)+           *Test(bit number 6 of destination D5) and store in Z
        BTST        #6,(A5)           *Test(bit number 6 of destination D5) and store in Z
        BTST        #5,-(A5)          *Test(bit value inside of D6 of destination D5) and store in Z
        BTST        D6,-(A6)           *Test(bit value inside of D6 of destination D5) and store in 
        BTST        D6,D5           *Test(bit value inside of D6 of destination D5) and store in 
        
        BTST        #6,D5           *Test(bit number 6 of destination D5) and store in Z
        BTST        #32,D5           *Test(bit value inside of D6 of destination D5) and store in Z
        BTST        #0,D5           *Test(bit value inside of D6 of destination D5) and store in 
        BTST        #8,D5           *Test(bit value inside of D6 of destination D5) and store in 
   
*--------------------------CMP-------------------------------------
        CMP         D6,D5           *Compare's the content of D6 and D5 and sets Z if true
        CMPA.L      D5,A1           *Compare's the content of A1 and D5 and sets Z if true
        CMPA.L      (A2),A1         *Compare the contants of A2 with A1 and set Z if true
        CMPA.L      (A2)+,A1        *Compares content and then increments A2 by one
        CMPA.L      -(A2),A1        *Decreses content and then compares cocntent and set Z if true
        CMPI.L      #$009F00B2,D5   *Compare's immediate data to D5 and sets Z if true
*-----------------------BCC(BEQ,BLT,BHI)-----------------------------
        CMPI.W      #$0020,D7       *Compare if immediate data is higher than contents of D7
        *BCC         CRYCLR          *If it is higher branch to CRYCLR looking at C
ISSAME  MOVE.B      #$11,D6
        MOVE.W      #$1000,D7       *If it wasn't higher carry this out
CRYCLR  MOVE.W      #$0000,D7       *If it was higher move 0000 to D7

        CMPI.B      #SNUM1,D6       *Compare if immediat data is higher than contents of D6
        BHI         ISHIGH          *If it is higher branch to ISHIGH looking at Z and C
        CMPI.B      #SNUM1,D6       *Compare if immediat data is higher than contents of D6
        BEQ         ISSAME          *If the number is the same move to is the same
ISHIGH  MOVE.B      #$00,D6         *If it wasn't higher 

*------------------------BRA,JSR,RTS------------------------------------- 
        ADD.B       D6,D6           *Add D6 content to D6 content
        BRA         SKIP            *Skip to SKIP part
        MOVE.B      #$23,D6         *Load immediate data into D6
SKIP    MOVE.B      #$12,D6         *Load immediate data into D6 

        ADD.B       D6,D6           *ADD D6 content to itself
        JSR         SKIP2            *Move to skip and then continue here
        JSR         (A2)
        BRA         CONT            *Skip to CONT
        
SKIP2   ADD.B       D6,D6           *ADD D6 content to itself
        RTS                         *Return back to JRS
        
CONT    ADD.B       #$10,D6         *ADD immediat data to D6


    END             $400






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
