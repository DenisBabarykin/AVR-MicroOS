;
; AssemblerApplication1.asm
;
; Created: 01.11.2015 22:12:35
; Author : Den
;


; Replace with your application code
	.include "m16def.inc"   ; ���������� ATMega16
 
;= ������� ========================================
   	.macro    OUTI          	
      	LDI    R16,@1
   	.if @0 < 0x40
      	OUT    @0,R16       
   	.else
      	STS      @0,R16
   	.endif
   	.endm
 
   	.macro    UOUT        
   	.if	@0 < 0x40
      	OUT	@0,@1         
	.else
      	STS	@0,@1
   	.endif
   	.endm

	.macro StartTimer
		OUTI TIMSK, 1
		OUTI TCCR0, 1
		SEI
	.endm

	.macro ClrRegs
		CLR	ZL			
		CLR	ZH
		CLR	R0
		CLR	R1
		CLR	R2
		CLR	R3
		CLR	R4
		CLR	R5
		CLR	R6
		CLR	R7
		CLR	R8
		CLR	R9
		CLR	R10
		CLR	R11
		CLR	R12
		CLR	R13
		CLR	R14
		CLR	R15
		CLR	R16
		CLR	R17
		CLR	R18
		CLR	R19
		CLR	R20
		CLR	R21
		CLR	R22
		CLR	R23
		CLR	R24
		CLR	R25
		CLR	R26
		CLR	R27
		CLR	R28
		CLR	R29
	.endm


	.macro Init
		LDI R16,Low(RAMEND)	
	  	OUT SPL,R16			
 
	  	LDI R16,High(RAMEND)
	  	OUT SPH,R16
 
RAM_Flush:	
		LDI	ZL,Low(SRAM_START)
		LDI	ZH,High(SRAM_START)
		CLR	R16		
Flush:		
		ST 	Z+,R16			
		CPI	ZH,High(RAMEND)		
		BRNE	Flush			
 
		CPI	ZL,Low(RAMEND)		
		BRNE	Flush

		ClrRegs
	.endm


	.macro GoToNextProcess
			CLI
			RCALL TM0_OVF
	.endm

; ������ ���������� ��������� ��������--------------------
	.macro SaveRegs
		STS  ZLT, ZL		; ������� ��������
		STS  ZHT, ZH		; ��������� ��� ����� ������ ������������ ����
		STS  R16T, R16
		IN	 R16, SREG
		STS  SREGT, R16

		LDS  R16, TempProc  			; ����������, ��� ���� ������ ��������
		CPI	 R16, $FF					; � SuspendProcess ��� � ������������
		BRNE NoLoadNum
				
			LDI ZL, low(TaskQueue)		; �������� ����� �������� �� �������
			LDI ZH, High(TaskQueue)
			LDS R16, @0
			ADD ZL, R16
			LDI R16, 0
			ADC ZH, R16
			LD  R16, Z
		
		NoLoadNum:	
		STS TCurP, R16					; � ��������� � ����������			

		LDI ZL, low(Procdata)			; ������� ����� ������ ����������:
		LDI ZH, High(Procdata)
		
		Push R17						; ����� ������� ��������
		Push R0
		Push R1
		LDS R16, TCurP					; 
		LDI R17, ProcDataSize
		MUL R16, R17
		ADD ZL, R0
		ADC ZH, R1
		Pop R1							; ������ ��������
		Pop R0
		Pop R17
		LDS R16, R16T
		
		ST	Z+,R0						;
		ST	Z+,R1
		ST	Z+,R2
		ST	Z+,R3
		ST	Z+,R4
		ST	Z+,R5
		ST	Z+,R6
		ST	Z+,R7
		ST	Z+,R8
		ST	Z+,R9
		ST	Z+,R10
		ST	Z+,R11
		ST	Z+,R12
		ST	Z+,R13
		ST	Z+,R14
		ST	Z+,R15
		ST	Z+,R16
		ST	Z+,R17
		ST	Z+,R18
		ST	Z+,R19
		ST	Z+,R20
		ST	Z+,R21
		ST	Z+,R22
		ST	Z+,R23
		ST	Z+,R24
		ST	Z+,R25
		ST	Z+,R26
		ST	Z+,R27
		ST	Z+,R28
		ST	Z+,R29

		MOV YL, ZL						; ������������ ����� � Y ����
		MOV YH, ZH
		LDS ZH, ZHT						; ������� Z
		LDS ZL, ZLT
		ST  Y+, R30						; � ������ ���
		ST	Y+, R31

		LDS R16, SREGT					; ������ SREG
		ST  Y+, R16
		IN	R16, SPL					; � Stack Pointer
		ST	Y+, R16
		IN	R16, SPH
		ST	Y+, R16
	.endm


; ������ �������� ��������� �������� -----------------------------

	.macro LoadRegs
		LDI ZL, low(TaskQueue)			; ������ ����� �������� �� �������:
		LDI ZH, High(TaskQueue)			; � Z - ����� ������� ���������
		LDS R16, CurProc				; � R16 - ����� �������� �������� � �������
		ADD ZL, R16						; ���������� ��� � ������
		CLR R16
		ADC ZH, R16						; � ������ �������� �����
		LD  R16, Z						

		LDI ZL, low(Procdata)			; ��������� ����� ������ ��������
		LDI ZH, High(ProcData)
		
		LDI R17, ProcDataSize			; Address = ProcData + ProcDataSize*N
		MUL R16, R17					; ��� N = R16, ������ ��� �������
		ADD ZL, R0						
		ADC ZH, R1
		
		LD	R0, Z+						; ������ ��������
		LD	R1, Z+
		LD	R2, Z+
		LD	R3, Z+
		LD	R4, Z+
		LD	R5, Z+
		LD	R6, Z+
		LD	R7, Z+
		LD	R8, Z+
		LD	R9, Z+
		LD	R10, Z+
		LD	R11, Z+
		LD	R12, Z+
		LD	R13, Z+
		LD	R14, Z+
		LD	R15, Z+
		LD	R16, Z+
		LD	R17, Z+
		LD	R18, Z+
		LD	R19, Z+
		LD	R20, Z+
		LD	R21, Z+
		LD	R22, Z+
		LD	R23, Z+
		LD	R24, Z+
		LD	R25, Z+
		LD	R26, Z+
		LD	R27, Z+
		LD	R28, Z+
		LD	R29, Z+

		
		PUSH YL							; ������ Y ����
		PUSH YH
		MOV YL, ZL						; ������������ ���� Z
		MOV YH, ZH
		LD	R30, Y+						; � ��������������� Z
		LD	R31, Y+

		PUSH R16						; ������ R16
		LD  R16, Y+						
		STS SREGT, R16					; ������ SREG
		LD	R16, Y+						; ��������, ������!
		STS	SPTL, R16					; ��������� SP � ����������
		LD	R16, Y+						; ��� ����� �������������� �����
		STS  SPTH, R16					; �������� ������, ��� ������ �����
										; ������ SP - � ����� ���� ��������

		POP R16							; ���������� � ����� ���������

		POP YH
		POP YL

		STS R16T, R16				    ; ������ R16 � ����������
		LDS R16, SPTL
		OUT SPL, R16					; �� ���������� ��� SP ������ SP
		LDS R16, SPTH
		OUT SPH, R16
		LDS R16, R16T					; � ���������� R16
										; ��, ������ ����������.
	.endm								; ����: ������������ ��� �������� � SP

; ������ ��������� ����. �������� �� �������-------------------

	.macro GetNextProc
		LDI R16, $FF
		STS TempProc, R16				; � TempProc ����� $FF

		LDS R16, CurProc				; ������� CurProc
		INC R16
		
		LDS R17, LastItem				; ���������� � ���������
		INC R17
		CP  R16, R17
		BRCS NoDec						; ���� ������ - ����� 0
	 				
			LDI R16, 0

	NoDec:
		STS CurProc, R16				; ��������� � CurProc

		LDI ZL, low(taskQueue)			; ������ ����� �� �������...
		LDI ZH, High(taskQueue)			; (���� ����)

		ADD ZL, R16
		LDI R16, 0
		ADC ZH, R16
		
		LD  R16, Z

		LDI ZL, low(ProcTable)			; ����� �� ������� ����� ��������...
		LDI ZH, High(ProcTable)
		
		LSL R16
		ADD ZL, R16
		LDI R16, 0
		ADC ZH, R16
	
		LD R16, Z+
		LD R17, Z+
	
		MOV ZL, R16						; � ��������� ��� � Z!
		MOV ZH, R17						; ��� ������ ��������� ��������
	.endm

; ������ ��������� ��������---------------------------------
	.macro DecTimers
		LDI ZL, Low(TimerQueue)			; �������� ������ ������� ��������
		LDI ZH, High(TimerQueue)		; 
										
		LDI R16, 0
	Decrease:							; ���� ���������� ��������
		LD  R17, Z+						; ������� 2�-�������
		LD	R18, Z
		CPI R17, 0						; ���������� ���������
		BRNE Decr						; ���� 0 - �� �� ���� ���������
		CPI R18, 0
		BREQ NoDecrease
	Decr:
		 SUBI R17, 1					; ��������� �� 1
		 SBCI R18, 0
		 LD R0, -Z						
		 ST Z+, R17
		 ST Z,  R18
  		 CPI R17, 0						; ���� ����� ����� ���� - ����
		 BRNE NoDecrease				; ��������� �������
		 CPI R18, 0
		 BRNE NoDecrease
	
		  MOV R17, R16					; � R17 ����� ��������
		  RCALL StartProcess			; API StartProcess

	NoDecrease:
		LD R0, Z+						; ������� � ��������� ������
		INC R16							; Inc R16; ���� ���� ����� ���-��
		CPI R16, QueueSize				; ��������� - ������ �����.
		BRNE Decrease	
	.endm

; ������ ���������� ������ �������� � ������� --------------------------
	.macro SaveAddr
		LDS  R16, TempProc					; ���������, ������ �������
		CPI	 R16, $FF						; �� �������, ��� ����� ������������
		BRNE NoLoadNumA						; ��������� �������

			LDS R16, @0							
	
			LDI ZL, low(taskQueue)			; ����� ����� �������� �� �������
			LDI ZH, High(taskQueue)
				
			ADD ZL, R16
			LDI R16, 0
			ADC ZH, R16	
	
			LD R16, Z
	  NoLoadNumA:

		LDS YL, ADDRL					; ������ ����������� �����
		LDS YH, ADDRH

		LDI ZL, low(Proctable)			; � ������ ���
		LDI ZH, High(ProcTable)
		
		LSL R16
		ADD ZL, R16
		LDI R16, 0
		ADC ZH, R16
	
		ST Z+, YH
		ST Z+, YL
	.endm

  ; ������ ��������� ����� �� 8
  ; @0 - ��. ����, @1 - �������
	.macro MulWordOn8
			LSL @0   
			ROL @1  
			LSL @0   
			ROL @1  
			LSL @0   
			ROL @1  
	.endm

  ; ������ ������� ����� �� 8
  ; @0 - ��. ����, @1 - �������
	.macro DivWordOn8
			LSR  @1   
			ROR  @0 
			LSR  @1   
			ROR  @0 
			LSR  @1   
			ROR  @0          
	.endm

  ; ������ ������� ����� �� ����
  ; ����:  @0, @1 - ������� ��. � ��. �����
  ;		 @2 - ��������
  ; �����: @0, @1 - ������� ��. � ��. �����
  ;        @3 - �������
	.macro DivWordOnByte
			PUSH XL
			LDI XL, 17             ; ���������� �������� + ��� C
			CLR @3                 ; �������
			CLC
		S_Div_WordByte_Loop:
			ROL @3
			SUB @3, @2             ; ������� ����� ��������
			BRCC S_Div_WordByte_1
			ADD @3, @2
		S_Div_WordByte_1:
			ROL @0
			ROL @1
			DEC XL
			BRNE S_Div_WordByte_Loop
			COM @0
			COM @1
			POP XL
	.endm

  ; ������ �������� ����� �� ����� � �������� � ��������� ������� ----
  ; @0 - ���, ���� ����� ������� ���������
  ; @1 - ������� ������� (������ ������), �������� 0 - 7
	.macro CreateMask
			LDI @0, $01			
			CPI @1, 0			; ��������� � �����
			BREQ ExitCreateMask ; ���� �����, �������
		ShiftLoop:
			LSL @0				; ����� �����
			DEC @1
			BRNE ShiftLoop
		ExitCreateMask:
	.endm

  ; ������ ������� ������ ����� ������ -----------------------------
  ; @0 - ������� � Low ������ ��������� ������
  ; @1 - ������� � High ������ ��������� ������
  ; @2 - ������� � ����������� ��������� ������
	.macro CaptureSharedMemory
		CaptureStart:
			CLI		; ��������� ����������

			; ������ �������� ������ ������

			; ���������� ���������
			STS ZLT, ZL			
			STS ZHT, ZH
			STS YLT, YL			
			STS YHT, YH
			STS R16T, R16				
			STS R17T, R17				
			STS R18T, R18				
			STS R19T, R19				
			STS R20T, R20				
			STS R21T, R21				
			
			MOV ZL, @0
			MOV ZH, @1 
			
			; ���� �� ���������� ����������� ����
			STS ZLT2, ZL
			STS ZHT2, ZH
			MOV R16, @2
			STS R16T2, R16
		LoopCheck:
			MOV R18, ZL
			MOV R19, ZH
			LDI R20, Low(SharedMem)
			LDI R21, High(SharedMem)

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  
			
			MOV R21, R19  ; �������� R19:R18 � R21:R20
			MOV R20, R18

			DivWordOn8 R20, R21   ; ����� R21:R20 �� 8 ��� �������

			LDI YL, Low(MutexBits)
			LDI YH, High(MutexBits)

			ADD YL, R20  ; Y = Y + R21:R20
			ADC YH, R21  ; �������� � Y ����� ������� ����� �� ����������� ������

			MulWordOn8 R20, R21   ; �������� R21:R20 �� 8

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  ; �������� � R19:R18 ������� ������� ���� (���������� �� � R18)

			CreateMask R17, R18  ; ������ ����� � R17 � ������ �������� 1 �� R18

			LD R18, Y     ; ��������� ������ ���� �� ����������� ������
			AND R18, R17  ; ��������� ���� ���� ������ ��� ��������� ��������� ����

			BREQ ContinueChecking ; ���� 0, ������ ������ ��� ���� � SharedMem ��������
			; ����������� �����, ���� ���� �����
			LDI ZL, Low(CaptureStart)
			LDI ZH, High(CaptureStart)
			PUSH ZL  ; ����� � ���� ����� ��������
			PUSH ZH 

			LDS ZL, ZLT		; �������������� ���������
			LDS ZH, ZHT
			LDS YL, YLT		
			LDS YH, YHT
			LDS R16, R16T	
			LDS R17, R17T	
			LDS R18, R18T	
			LDS R19, R19T	
			LDS R20, R20T	
			LDS R21, R21T	
			
			RJMP TM0_OVF			; ������ � ��������� (������ �����)

		ContinueChecking:
			ADIW ZL, 1 ; ���������
			DEC R16
			BRNE LoopCheck 

			LDS R16, R16T2
			LDS ZL, ZLT2		
			LDS ZH, ZHT2
			; ����� �������� ������ ������

			; ������:
		LoopCapture:
			MOV R18, ZL
			MOV R19, ZH
			LDI R20, Low(SharedMem)
			LDI R21, High(SharedMem)

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  
			
			MOV R21, R19  ; �������� R19:R18 � R21:R20
			MOV R20, R18

			DivWordOn8 R20, R21   ; ����� R21:R20 �� 8 ��� �������

			LDI YL, Low(MutexBits)
			LDI YH, High(MutexBits)

			ADD YL, R20  ; Y = Y + R21:R20
			ADC YH, R21  ; �������� � Y ����� ������� ����� �� ����������� ������

			MulWordOn8 R20, R21   ; �������� R21:R20 �� 8

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  ; �������� � R19:R18 ������� ������� ���� (���������� �� � R18)

			CreateMask R17, R18  ; ������ ����� � R17 � ������ �������� 1 �� R18

			LD R18, Y     ; ��������� ������ ���� �� ����������� ������
			OR R18, R17   ; ������������� ������ ��� � 1
			ST Y, R18	  ; ��������� ���������� ���� � ������

			ADIW ZL, 1 ; ���������
			DEC R16
			BRNE LoopCapture 
			; ����� �������

			LDS ZL, ZLT		 ; �������������� ���������
			LDS ZH, ZHT
			LDS YL, YLT		
			LDS YH, YHT
			LDS R16, R16T	
			LDS R17, R17T	
			LDS R18, R18T	
			LDS R19, R19T	
			LDS R20, R20T	
			LDS R21, R21T	
			SEI				 ; ��������� ����������

			
	.endm

  ; ������ ������������ ����� ������ -------------------------------
	.macro FreeSharedMemory
			CLI
			STS ZLT, ZL			
			STS ZHT, ZH
			STS YLT, YL			
			STS YHT, YH
			STS R16T, R16				
			STS R17T, R17				
			STS R18T, R18				
			STS R19T, R19				
			STS R20T, R20				
			STS R21T, R21				
			
			MOV ZL, @0
			MOV ZH, @1 
			MOV R16, @2

		LoopFree:
			MOV R18, ZL
			MOV R19, ZH
			LDI R20, Low(SharedMem)
			LDI R21, High(SharedMem)

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  
			
			MOV R21, R19  ; �������� R19:R18 � R21:R20
			MOV R20, R18

			DivWordOn8 R20, R21   ; ����� R21:R20 �� 8 ��� �������

			LDI YL, Low(MutexBits)
			LDI YH, High(MutexBits)

			ADD YL, R20  ; Y = Y + R21:R20
			ADC YH, R21  ; �������� � Y ����� ������� ����� �� ����������� ������

			MulWordOn8 R20, R21   ; �������� R21:R20 �� 8

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  ; �������� � R19:R18 ������� ������� ���� (���������� �� � R18)

			CreateMask R17, R18  ; ������ ����� � R17 � ������ �������� 1 �� R18
			COM R17				 ; ���������� �����

			LD R18, Y     ; ��������� ������ ���� �� ����������� ������
			AND R18, R17   ; ������������� ������ ��� � 0
			ST Y, R18	  ; ��������� ���������� ���� � ������

			ADIW ZL, 1 ; ���������
			DEC R16
			BRNE LoopFree 
			; ����� �������

			LDS ZL, ZLT		 ; �������������� ���������
			LDS ZH, ZHT
			LDS YL, YLT		
			LDS YH, YHT
			LDS R16, R16T	
			LDS R17, R17T	
			LDS R18, R18T	
			LDS R19, R19T	
			LDS R20, R20T	
			LDS R21, R21T	
			SEI
	.endm

;= End 	macro.inc =======================================
; RAM ===================================================
; ����������  ---------------------
		.DSEG
.equ ProcDataSize = 64	; ������ ��������
.equ ProcNum = 8		; ���������� ���������
.equ QueueSize = 16		; ������������ ���������� ����� � �������

TempProc:	.byte 1		; ��� �����������
SREGT:		.byte 1		; ��������� ���������� ��� SREG
SPTL:		.byte 1		; ��� SPL
SPTH:		.byte 1		; ��� SPH
R16T:		.byte 1		; ��� R16 
ZLT:		.byte 1		; ZL
ZHT:		.byte 1		; ZH
ADDRL:		.byte 1		; �����
ADDRH:		.byte 1
TCurp:		.byte 1		; ��������� CurProc (��. ����)

; ������� � ���, ��� � ��� �������
CurProc:	.byte 1			; ��������� ����������, ������ ����� ��������
LastItem:	.Byte 1			; ����� ���������� �������� ������� (��� ��������)
TaskQueue:	.byte QueueSize+1 ; ������� ���������
TimerQueue: .byte QueueSize*2 ; ������� ��������

Proctable: 	.byte ProcNum*2	; ������� ������� ���������
			
.ORG $AD ; ����������� ������� ������
MutexBits:  .byte 41    

.ORG $D6 ; ����� ������. � 8 ��� ������ �����������
SharedMem: ; �������� 328 ����

BufSize:	.byte 2 ; ���������� � ����������� � ������� ������ � ����� ������

; ����� ������: ����� ��� ���� � ��������. -----------
; ������� ��������� - ������� � ���� �������
.ORG $21E
ProcData:	.byte ProcDataSize*ProcNum


R17T:       .byte 1
R18T:       .byte 1
R19T:       .byte 1
R20T:       .byte 1
R21T:       .byte 1
YLT:		.byte 1		
YHT:		.byte 1
ZLT2:		.byte 1		
ZHT2:		.byte 1
R16T2:      .byte 1		

; END RAM ====================================================
; FLASH ======================================================
; �� ��� ��� ����...
         .CSEG
         .ORG $000      ; (RESET) 
         RJMP   Reset
         .ORG $002
         RETI             ; (INT0) External Interrupt Request 0
         .ORG $004
         RETI             ; (INT1) External Interrupt Request 1
         .ORG $006
         RETI	    	  ; (TIMER2 COMP) Timer/Counter2 Compare Match
         .ORG $008
         RETI             ; (TIMER2 OVF) Timer/Counter2 Overflow
         .ORG $00A
         RETI	     	  ; (TIMER1 CAPT) Timer/Counter1 Capture Event
         .ORG $00C 
         RETI             ; (TIMER1 COMPA) Timer/Counter1 Compare Match A
         .ORG $00E
         RETI             ; (TIMER1 COMPB) Timer/Counter1 Compare Match B
         .ORG $010
         RETI             ; (TIMER1 OVF) Timer/Counter1 Overflow
         .ORG $012
         RJMP TM0_OVF     ; (TIMER0 OVF) Timer/Counter0 Overflow
         .ORG $014
         RETI             ; (SPI,STC) Serial Transfer Complete
         .ORG $016
         RETI    	      ; (USART,RXC) USART, Rx Complete
         .ORG $018
         RETI             ; (USART,UDRE) USART Data Register Empty
         .ORG $01A
         RETI             ; (USART,TXC) USART, Tx Complete
         .ORG $01C
         RETI	     	  ; (ADC) ADC Conversion Complete
         .ORG $01E
         RETI             ; (EE_RDY) EEPROM Ready
         .ORG $020
         RETI             ; (ANA_COMP) Analog Comparator
         .ORG $022
         RETI             ; (TWI) 2-wire Serial Interface
         .ORG $024
         RETI             ; (INT2) External Interrupt Request 2
         .ORG $026
         RETI             ; (TIMER0 COMP) Timer/Counter0 Compare Match
         .ORG $028
         RETI             ; (SPM_RDY) Store Program Memory Ready
 
	 .ORG   INT_VECTORS_SIZE      	; ����� �������
; End Vectors Table =======================================
; Interrupts ==============================================
TM0_OVF:		
	STS R16T, R16			; �������� �� ����� ������
	POP R16					; � ���������� ADDRx
	STS ADDRL, R16			; �������������� �������� ������� R16
	POP R16
	STS ADDRH, R16
	LDS R16, R16T

	SaveRegs CurProc	; ���������� ���������

	SaveAddr CurProc	; ���������� ������ ��������

	DecTimers			; ����� ������ ��������
	
	GetNextProc			; ��������� ������ ���������� ��������

	STS ADDRL, ZL		; ���������� ������ � ADDRx
	STS ADDRH, ZH	
	
	loadRegs			; �������� ���������

	STS ZLT, ZL			; ���������� Z
	STS ZHT, ZH
	LDS ZL, ADDRL		; ADDRx � Z
	LDS ZH, ADDRH
	PUSH ZL				; ������ � ���� ������ ��������
	PUSH ZH
	LDS ZL, ZLT			; �������������� �������� Z
	LDS ZH, ZHT

	STS R16T,R16		
	LDS R16, SREGT		; �������������� SREG.
	OUT SREG, R16		
	OUTI TCNT0, 0		; ��������� �������
	OUTI TIFR, 1		; � ��� ����� ����������
	LDS R16, R16T		
	RETI				; ����� �� ����������

; End Interrupts ===============================================

Reset:  
; Internal Hardware Init  ======================================
	Init
; End Internal Hardware Init ===================================
 
; External Hardware Init  ======================================
 
; End Internal Hardware Init ===================================
 
; Run ==========================================================
	LDI R16, $FF
	STS TempProc, R16

 	LDI ZL, low(ProcTable);
	LDI ZH, High(ProcTable);

	LDI R16, low(Main)			; ����� ������ ��������� � �������
	ST  Z+, R16					; ��������� ����� ������ � ���������
	LDI R16, High(Main)			; Main, �.�. ������� �� �����, ������� 
	ST  Z+, R16					; ������, ��������� � �.�. ��� ��������
								; � ����� ������� 
	
	LDI R16, low(Proc1)  ; ��������� �������-�������������
	ST  Z+, R16
	LDI R16, High(Proc1)
	ST  Z+, R16

	LDI R16, low(Proc2) ; ��������� ��� ��������-����������� � ���������
	ST  Z+, R16
	LDI R16, High(Proc2)
	ST  Z+, R16

	LDI R16, low(Proc3) 
	ST  Z+, R16
	LDI R16, High(Proc3)
	ST  Z+, R16

	LDI R16, low(Proc4) ; ��������� �������-����������� ��� ��������
	ST  Z+, R16
	LDI R16, High(Proc4)
	ST  Z+, R16

	LDI R17, 1					; � ������� �� (���, ����� Main).
	LDI R18, 3					; ������������� ���������
	RCALL CreateProcess
	
	LDI R17, 2					; ����� �������� �� �������
	LDI R18, 1					; ������������� ���������
	RCALL CreateProcess

	LDI R17, 4					
	LDI R18, 2					
	RCALL CreateProcess

	LDI R17, 3					
	LDI R18, 1						
	RCALL CreateProcess
	

; End Run ======================================================

; Main =========================================================
	StartTimer		; ������ �������
	ClrRegs			; ������� ��������

	LDI ZL, low(BufSize)   ; �������� ����������
	LDI ZH, High(BufSize)
	CLR R16
	ST Z+, R16
	ST Z+, R16

Main:				
  	Nop
	Nop
	Nop
	Nop
	Nop
	Nop
RJMP	Main
; End Main =====================================================

; ��������  ===================
; ������������� ----------------------
 Proc1:
	LDI ZL, low(BufSize)
	LDI ZH, High(BufSize)
	LDI R16, 2
	CaptureSharedMemory ZL, ZH, R16
  	LD XL, Z+
	LD XH, Z
	ADIW XL, 1
	ST Z, XH
	ST -Z, XL 
	FreeSharedMemory ZL, ZH, R16
	GoToNextProcess
  RJMP Proc1

; 1�� ����������� � ��������� ��������� ----------------------------------
 Proc2:
	LDI R17, 2
	LDI R18, 100
	LDI R19, 0
	CLI
	RCALL SetTimer  ; API
	LDI R17, 2
	RCALL SuspendProcess ; API
	SEI
  Consuming1:
	LDI ZL, low(BufSize)
	LDI ZH, High(BufSize)
	LDI R16, 2
	CaptureSharedMemory ZL, ZH, R16
  	LD XL, Z+
	LD XH, Z
	CPI XL, 0						; ���������� ���������
	BRNE Decrem1					; ���� 0 - �� �� ���� ���������
	CPI XH, 0
	BREQ NoDecrem1
Decrem1:
	SBIW XL, 1
	ST Z, XH
	ST -Z, XL 
NoDecrem1:
	FreeSharedMemory ZL, ZH, R16
	GoToNextProcess
	RJMP Consuming1

; 2�� ����������� � ��������� ��������� ----------------------------------
 Proc3:
	LDI R17, 3
	LDI R18, 150
	LDI R19, 0
	CLI
	RCALL SetTimer  ; API
	LDI R17, 3
	RCALL SuspendProcess ; API
	SEI
  Consuming2:
	LDI ZL, low(BufSize)
	LDI ZH, High(BufSize)
	LDI R16, 2
	CaptureSharedMemory ZL, ZH, R16
  	LD XL, Z+
	LD XH, Z
	CPI XL, 0						; ���������� ���������
	BRNE Decrem2					; ���� 0 - �� �� ���� ���������
	CPI XH, 0
	BREQ NoDecrem2
Decrem2:
	SBIW XL, 1
	ST Z, XH
	ST -Z, XL 
NoDecrem2:
	FreeSharedMemory ZL, ZH, R16
	GoToNextProcess
	RJMP Consuming2

; ����������� ��� �������������� �������� ----------------------------------
 Proc4:
	LDI ZL, low(BufSize)
	LDI ZH, High(BufSize)
	LDI R16, 2
	CaptureSharedMemory ZL, ZH, R16
  	LD XL, Z+
	LD XH, Z
	CPI XL, 0						; ���������� ���������
	BRNE Decrem3					; ���� 0 - �� �� ���� ���������
	CPI XH, 0
	BREQ NoDecrem3
Decrem3:
	SBIW XL, 1
	ST Z, XH
	ST -Z, XL 
NoDecrem3:
	FreeSharedMemory ZL, ZH, R16
	GoToNextProcess
	RJMP Proc4


; ��������� ==========================================================



; ������ �������� ����� �����
 StartProcess:					; R17 - ����� ��������
	 PUSH ZL
	 PUSH ZH
     PUSH R16
 	 LDS R16, LastItem			; �������� ����� ���������� ��������
	 INC R16
	 CPI R16, QueueSize			; ���� ������ ������� ������� - �������
	 BREQ ExitS

	 Push R17

	 STS LastItem, R16
	 LDI ZL, Low(TaskQueue)		; ����� ���� �������� �������
	 LDI ZH, High(TaskQueue)	; ��� �� � ������
		
	 ADD ZL, R16				; �������� ����� ����� �������
	 CLR R17
	 ADC ZH, R17
		
	 MOV R17, R16				; �������� ���� �� ����� � �� ��������		
 	 LDS R18, CurProc			; �.�. ��������� ������� ����� ��������
	 SUB R17, R18				; � R17 - ��������� �������
 ShellS:							; ��������
	 	 LD R18, Z+				
		 ST Z, R18
		 LD R0, -Z
		 LD R0, -Z
		 DEC R17
		 BRNE ShellS
	 
	 LD R0, Z+					; ����� � �������������� ����� ������������
	 POP R17					; ����� ��������
	 ST  Z, R17
ExitS:
	POP R16
	POP ZH
	POP ZL
 	RET


;�������� ������ ��������-----------------------------------------------
 CreateProcess:		             
	 							; R18 - ���������, �.�. ������� ��� ���� ��������� � �������
 	 LDS R16, LastItem			; R17 - ����� �������� � ������� �������.
								; �������� ����� ���������� ��������
	 INC R16
	 CPI R16, QueueSize			; ���� ������ ������� ������� - �������
	 BREQ Exit
	 STS LastItem, R16			; �������� ����� �������

; ������������� ������ �������� ----------------------------
	 LDI YL, Low(ProcData)		; ������ ������� ������
	 LDI YH, High(ProcData)

	 INC R17
 	 LDI R16, ProcDataSize		; �������� ������ ������ ����. ��������
	 MUL R16, R17
	 ADD YL, R0
	 ADC YH, R1
	 DEC R17
	 LD  R16, -Y				; �������� �� 1 - ����� ������ ������� 
	 							; � Y ���� ��������� ���� ����� - 
	 							; ��� ����� ����

	 LDI ZL, Low(ProcData)		; ������ ������� ������
	 LDI ZH, High(ProcData)

 	 LDI R16, ProcDataSize		; �������� ������ ������ ������� ��������
	 MUL R16, R17
	 ADD ZL, R0
	 ADC ZH, R1
	 
	 LDI R16, 33				; ������� ����� ��������� - 32 ��������,
	 LDI R19, 0					; ���� ��������� => ����� 33 ����
 Clear:
 	 ST  Z+, R19
	 DEC R16
	 BRNE Clear

	 ST  Z+, YL					; ����� ����� �����
	 ST	 Z+, YH
	 
; ������ ��������  - ������ � �������-------------------------------------

	 LDS R16, LastItem
	 LDI ZL, Low(TaskQueue)		; ���������  ����� � �������
	 LDI ZH, High(TaskQueue)	; ������ �� ������ ���������� ��������

	 ADD ZL, R16
	 LDI R16, 0
	 ADC ZH, R16

	 ST Z+, R17					; � ����� ���� ��� ����� ��������,
	 LDI R16, $FF				
	 ST Z+, R16

	 DEC R18					; ���������, ������� ��� ��� ���� ��������� ���� ������� � �������
	 BRNE CreateProcess
Exit:
 	RET



;��������� ������� �� ����� ----------------------------------------------
/*
 ��������! ����� �������� ����������� ���������� ��������� ����������,
 � ����� - ���������. ����� �������� ����� �����.
 ������� ����������.
*/ 
 SuspendProcess:		;R17 - ����� ��������
	 LDI ZL, Low(TaskQueue)		; ������ �������
	 LDI ZH, High(TaskQueue)

	 LDI R16, 0
 Seek:					; ���� ������� � ����� ������� � �������
 		LD R18, Z+
		CP R18, R17
		BREQ EOSeek		; ����� - ���� ������
		INC R16
		CPI R16, LastItem
		BRNE Seek
		
		RJMP NotFound	; � ���� ��� ������ - �������
 EOSeek:

	 LDI R19, 0			; ��� ����������� � �������
	 STS TempProc, R17		
	 MOV R17, R16		; ��������� ����� � �������
	 LDS R16, CurProc	; 
	 CP	 R16, R17		; ���� �� ����� �������� - 
	 BRNE TNoSave		; �� �� ��������� ��������	
 TSave:
		 LDI R19, 1		
		 RJMP NoDec		

 TNoSave:			
 		 CP R16, R17		; ���� ������ �������� - 
	 	 BRCS NoDec			; �� ��������� ����� �������� � �������
		 	LDS R16, CurProc 
		 	DEC R16
		 	STS CurProc, R16

 NoDec:
 	 LDI ZL, Low(TaskQueue)		; ����� ���� �������� �������
	 LDI ZH, High(TaskQueue)	
		
     INC R17					; �� �������� � �� �����
	 ADD ZL, R17
	 LDI R16, 0
	 ADC ZH, R16
	 DEC R17
		
 	 LDS R16, LastItem
	 SUB R16, R17
	 INC R16
 Shell:							; �������� (��, �����, � ����)
	 	 LD R18, Z
		 ST -Z, R18
		 LD R0, Z+
		 LD R0, Z+
		 DEC R16
		 BRNE Shell

	 LDS R16, LastItem			; ��������� ����� ���������� ��������
	 DEC R16
	 STS LastItem, R16
 		
	 CPI R19, 0
	 BREQ NotFound				; � ���� ������ ������� ������� - �� ����������
	   RJMP TM0_OVF

 NotFound:	 					; ����� - �������
	RET



;��������� ������ -------------------------------------------------------
/*
 ��������! ������ ������� ������ �������������� ������ � Suspend porcess
 ����� ����� ������������� �������� ���������� ������ ��������� ��������,
 ������� ��� �� �����, �� �� ������ � ��� �� ����, �� ���������� ����� -
 ������ �������, �������������� �� �������� ����� �������� ���� � ������,
 ��������� ����� ����� ������� ����-����

 �������� ���:
 ...
 CLI
  Rcall SetTimer
  Rcall Suspend process
 STI
 ...
*/
 SetTimer:				 ;R17 - ����� ��������, R18(L), R19(H)-��������
 	 PUSH R16
	 PUSH R17
	 LDI ZL, Low(TimerQueue)	; ������ ������� ��������
	 LDI ZH, High(TimerQueue)	

	 LDI R16, 0 				; 
	 ROL R17					; ������� ����� �� ��� - ������� �����������
	 ROL R16					; � ����� ���-�� 129 ��������� �������
	 ADD ZL, R17				; �������� �����
	 ADC ZH, R16				; 

	 ST	 Z+, R18				; ������ ������
	 ST  Z+, R19				; ������ ������
	 POP R17
	 POP R16
	RET							; �����

; ��������� "������� � ����. ��������" ------------------------------
/*
Usage:
  
  ...
  LDI R18, 1			   ; ���� �������� = 1 - ������� ����������
  LDI R19, 0			   ; ��� �������� ������������. ��� ��� � ����.
  CLI
  RCALL SetTimer		   ; ������ ������
  RCALL SuspendProcess	   ; �������� �������
  RCALL GoToNextProc	    
*/
 GoToNextProc:
 	CLI						; ������ (�� ������)
	RJMP TM0_OVF			; ���� �� ���������� ������� 
 RET						;
							
; End Procedure ================================================

