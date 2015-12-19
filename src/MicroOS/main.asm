;
; AssemblerApplication1.asm
;
; Created: 01.11.2015 22:12:35
; Author : Den
;


; Replace with your application code
	.include "m16def.inc"   ; Используем ATMega16
 
;= Макросы ========================================
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

; Макрос сохранения регистров процесса--------------------
	.macro SaveRegs
		STS  ZLT, ZL		; Спасаем регистры
		STS  ZHT, ZH		; стараемся как можно меньше использовать стек
		STS  R16T, R16
		IN	 R16, SREG
		STS  SREGT, R16

		LDS  R16, TempProc  			; Определяем, где этот макрос применен
		CPI	 R16, $FF					; В SuspendProcess или в переключении
		BRNE NoLoadNum
				
			LDI ZL, low(TaskQueue)		; Получаем номер процесса из очереди
			LDI ZH, High(TaskQueue)
			LDS R16, @0
			ADD ZL, R16
			LDI R16, 0
			ADC ZH, R16
			LD  R16, Z
		
		NoLoadNum:	
		STS TCurP, R16					; И сохраняем в переменную			

		LDI ZL, low(Procdata)			; Получим адрес памяти процессора:
		LDI ZH, High(Procdata)
		
		Push R17						; Снова спасаем регитсры
		Push R0
		Push R1
		LDS R16, TCurP					; 
		LDI R17, ProcDataSize
		MUL R16, R17
		ADD ZL, R0
		ADC ZH, R1
		Pop R1							; Вернем регистры
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

		MOV YL, ZL						; Перекидываем адрес в Y пару
		MOV YH, ZH
		LDS ZH, ZHT						; Достаем Z
		LDS ZL, ZLT
		ST  Y+, R30						; И сейвим его
		ST	Y+, R31

		LDS R16, SREGT					; Сейвим SREG
		ST  Y+, R16
		IN	R16, SPL					; и Stack Pointer
		ST	Y+, R16
		IN	R16, SPH
		ST	Y+, R16
	.endm


; Макрос загрузки регистров процесса -----------------------------

	.macro LoadRegs
		LDI ZL, low(TaskQueue)			; Грузим номер процесса из очереди:
		LDI ZH, High(TaskQueue)			; В Z - адрес очереди процессов
		LDS R16, CurProc				; В R16 - номер текущего процесса в очереди
		ADD ZL, R16						; Прибавляем его к адресу
		CLR R16
		ADC ZH, R16						; и грузим реальный номер
		LD  R16, Z						

		LDI ZL, low(Procdata)			; Вычисляем адрес данных процесса
		LDI ZH, High(ProcData)
		
		LDI R17, ProcDataSize			; Address = ProcData + ProcDataSize*N
		MUL R16, R17					; где N = R16, только что грузили
		ADD ZL, R0						
		ADC ZH, R1
		
		LD	R0, Z+						; Респим регистры
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

		
		PUSH YL							; Сейвим Y пару
		PUSH YH
		MOV YL, ZL						; Перекидываем туды Z
		MOV YH, ZH
		LD	R30, Y+						; И восстанавливаем Z
		LD	R31, Y+

		PUSH R16						; Сейвим R16
		LD  R16, Y+						
		STS SREGT, R16					; Грузим SREG
		LD	R16, Y+						; ВНИМАНИЕ, ИЗВРАТ!
		STS	SPTL, R16					; Сохраняем SP в переменные
		LD	R16, Y+						; это будет использоваться далее
		STS  SPTH, R16					; делается потому, что нельзя здесь
										; менять SP - в стеке наши регистры

		POP R16							; Откапываем в стеке сокровища

		POP YH
		POP YL

		STS R16T, R16				    ; Сейвим R16 в переменную
		LDS R16, SPTL
		OUT SPL, R16					; Из переменных для SP грузим SP
		LDS R16, SPTH
		OUT SPH, R16
		LDS R16, R16T					; И возвращаем R16
										; Всё, изврат закончился.
	.endm								; Итог: восстановили все регистры и SP

; Макрос получения след. процесса по очереди-------------------

	.macro GetNextProc
		LDI R16, $FF
		STS TempProc, R16				; В TempProc пишем $FF

		LDS R16, CurProc				; Инькаем CurProc
		INC R16
		
		LDS R17, LastItem				; Сравниваем с последним
		INC R17
		CP  R16, R17
		BRCS NoDec						; Если больше - пишем 0
	 				
			LDI R16, 0

	NoDec:
		STS CurProc, R16				; сохраняем в CurProc

		LDI ZL, low(taskQueue)			; Грузим номер из очереди...
		LDI ZH, High(taskQueue)			; (было выше)

		ADD ZL, R16
		LDI R16, 0
		ADC ZH, R16
		
		LD  R16, Z

		LDI ZL, low(ProcTable)			; Берем из таблицы адрес процесса...
		LDI ZH, High(ProcTable)
		
		LSL R16
		ADD ZL, R16
		LDI R16, 0
		ADC ZH, R16
	
		LD R16, Z+
		LD R17, Z+
	
		MOV ZL, R16						; И сохраняем его в Z!
		MOV ZH, R17						; для работы остальных макросов
	.endm

; Макрос пересчета таймеров---------------------------------
	.macro DecTimers
		LDI ZL, Low(TimerQueue)			; Загрузка начала очереди таймеров
		LDI ZH, High(TimerQueue)		; 
										
		LDI R16, 0
	Decrease:							; Цикл уменьшения таймеров
		LD  R17, Z+						; Таймеры 2х-байтные
		LD	R18, Z
		CPI R17, 0						; побайтовое сравнение
		BRNE Decr						; Если 0 - то не надо уменьшать
		CPI R18, 0
		BREQ NoDecrease
	Decr:
		 SUBI R17, 1					; декремент на 1
		 SBCI R18, 0
		 LD R0, -Z						
		 ST Z+, R17
		 ST Z,  R18
  		 CPI R17, 0						; если стало равно нулю - надо
		 BRNE NoDecrease				; запускать процесс
		 CPI R18, 0
		 BRNE NoDecrease
	
		  MOV R17, R16					; в R17 номер процесса
		  RCALL StartProcess			; API StartProcess

	NoDecrease:
		LD R0, Z+						; переход к следующей ячейке
		INC R16							; Inc R16; если стал равен кол-ву
		CPI R16, QueueSize				; процессов - значит выход.
		BRNE Decrease	
	.endm

; Макрос сохранения адреса возврата в таблицу --------------------------
	.macro SaveAddr
		LDS  R16, TempProc					; Определим, откуда вызвали
		CPI	 R16, $FF						; Не подумал, что можно использовать
		BRNE NoLoadNumA						; параметры макроса

			LDS R16, @0							
	
			LDI ZL, low(taskQueue)			; берем номер процесса из очереди
			LDI ZH, High(taskQueue)
				
			ADD ZL, R16
			LDI R16, 0
			ADC ZH, R16	
	
			LD R16, Z
	  NoLoadNumA:

		LDS YL, ADDRL					; грузим засейвенный адрес
		LDS YH, ADDRH

		LDI ZL, low(Proctable)			; И сейвим его
		LDI ZH, High(ProcTable)
		
		LSL R16
		ADD ZL, R16
		LDI R16, 0
		ADC ZH, R16
	
		ST Z+, YH
		ST Z+, YL
	.endm

  ; Макрос умножения слова на 8
  ; @0 - мл. байт, @1 - старший
	.macro MulWordOn8
			LSL @0   
			ROL @1  
			LSL @0   
			ROL @1  
			LSL @0   
			ROL @1  
	.endm

  ; Макрос деления слова на 8
  ; @0 - мл. байт, @1 - старший
	.macro DivWordOn8
			LSR  @1   
			ROR  @0 
			LSR  @1   
			ROR  @0 
			LSR  @1   
			ROR  @0          
	.endm

  ; Макрос деления слова на байт
  ; Вход:  @0, @1 - делимое мл. и ст. байты
  ;		 @2 - делитель
  ; Выход: @0, @1 - частное мл. и ст. байты
  ;        @3 - остаток
	.macro DivWordOnByte
			PUSH XL
			LDI XL, 17             ; Количество разрядов + бит C
			CLR @3                 ; Остаток
			CLC
		S_Div_WordByte_Loop:
			ROL @3
			SUB @3, @2             ; Остаток минус делитель
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

  ; Макрос создания маски из нулей с единицей в указанной позиции ----
  ; @0 - РОН, куда будет положен результат
  ; @1 - позиция единицы (отсчёт справа), диапазон 0 - 7
	.macro CreateMask
			LDI @0, $01			
			CPI @1, 0			; сравнение с нулем
			BREQ ExitCreateMask ; если равно, выходим
		ShiftLoop:
			LSL @0				; сдвиг влево
			DEC @1
			BRNE ShiftLoop
		ExitCreateMask:
	.endm

  ; Макрос захвата нужных общих байтов -----------------------------
  ; @0 - регистр с Low адреса требуемых байтов
  ; @1 - регистр с High адреса требуемых байтов
  ; @2 - регистр с количеством требуемых байтов
	.macro CaptureSharedMemory
		CaptureStart:
			CLI		; запрещаем прерывания

			; начало проверки нужных байтов

			; сохранение регистров
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
			
			; цикл по количеству необходимых байт
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
			
			MOV R21, R19  ; копируем R19:R18 в R21:R20
			MOV R20, R18

			DivWordOn8 R20, R21   ; делим R21:R20 на 8 без остатка

			LDI YL, Low(MutexBits)
			LDI YH, High(MutexBits)

			ADD YL, R20  ; Y = Y + R21:R20
			ADC YH, R21  ; получили в Y адрес нужного байта из проверочной памяти

			MulWordOn8 R20, R21   ; умножаем R21:R20 на 8

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  ; получили в R19:R18 позицию нужного бита (фактически он в R18)

			CreateMask R17, R18  ; создаём маску в R17 с нужной позицией 1 из R18

			LD R18, Y     ; загружаем нужный байт из проверочной памяти
			AND R18, R17  ; проверяем этот байт маской для выявления состояния бита

			BREQ ContinueChecking ; если 0, значит нужный нам байт в SharedMem свободен
			; оказываемся здесь, если байт занят
			LDI ZL, Low(CaptureStart)
			LDI ZH, High(CaptureStart)
			PUSH ZL  ; кладём в стек адрес возврата
			PUSH ZH 

			LDS ZL, ZLT		; восстановление регистров
			LDS ZH, ZHT
			LDS YL, YLT		
			LDS YH, YHT
			LDS R16, R16T	
			LDS R17, R17T	
			LDS R18, R18T	
			LDS R19, R19T	
			LDS R20, R20T	
			LDS R21, R21T	
			
			RJMP TM0_OVF			; уходим в диспетчер (отдаем квант)

		ContinueChecking:
			ADIW ZL, 1 ; инкремент
			DEC R16
			BRNE LoopCheck 

			LDS R16, R16T2
			LDS ZL, ZLT2		
			LDS ZH, ZHT2
			; конец проверки нужных байтов

			; захват:
		LoopCapture:
			MOV R18, ZL
			MOV R19, ZH
			LDI R20, Low(SharedMem)
			LDI R21, High(SharedMem)

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  
			
			MOV R21, R19  ; копируем R19:R18 в R21:R20
			MOV R20, R18

			DivWordOn8 R20, R21   ; делим R21:R20 на 8 без остатка

			LDI YL, Low(MutexBits)
			LDI YH, High(MutexBits)

			ADD YL, R20  ; Y = Y + R21:R20
			ADC YH, R21  ; получили в Y адрес нужного байта из проверочной памяти

			MulWordOn8 R20, R21   ; умножаем R21:R20 на 8

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  ; получили в R19:R18 позицию нужного бита (фактически он в R18)

			CreateMask R17, R18  ; создаём маску в R17 с нужной позицией 1 из R18

			LD R18, Y     ; загружаем нужный байт из проверочной памяти
			OR R18, R17   ; устанавливаем нужный бит в 1
			ST Y, R18	  ; сохраняем измененный байт в памяти

			ADIW ZL, 1 ; инкремент
			DEC R16
			BRNE LoopCapture 
			; конец захвата

			LDS ZL, ZLT		 ; восстановление регистров
			LDS ZH, ZHT
			LDS YL, YLT		
			LDS YH, YHT
			LDS R16, R16T	
			LDS R17, R17T	
			LDS R18, R18T	
			LDS R19, R19T	
			LDS R20, R20T	
			LDS R21, R21T	
			SEI				 ; разрешаем прерывания

			
	.endm

  ; Макрос освобождения общих байтов -------------------------------
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
			
			MOV R21, R19  ; копируем R19:R18 в R21:R20
			MOV R20, R18

			DivWordOn8 R20, R21   ; делим R21:R20 на 8 без остатка

			LDI YL, Low(MutexBits)
			LDI YH, High(MutexBits)

			ADD YL, R20  ; Y = Y + R21:R20
			ADC YH, R21  ; получили в Y адрес нужного байта из проверочной памяти

			MulWordOn8 R20, R21   ; умножаем R21:R20 на 8

			SUB R18, R20  ; R19:R18 = R19:R18 - R21:R20
			SBC R19, R21  ; получили в R19:R18 позицию нужного бита (фактически он в R18)

			CreateMask R17, R18  ; создаём маску в R17 с нужной позицией 1 из R18
			COM R17				 ; ивертируем маску

			LD R18, Y     ; загружаем нужный байт из проверочной памяти
			AND R18, R17   ; устанавливаем нужный бит в 0
			ST Y, R18	  ; сохраняем измененный байт в памяти

			ADIW ZL, 1 ; инкремент
			DEC R16
			BRNE LoopFree 
			; конец захвата

			LDS ZL, ZLT		 ; восстановление регистров
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
; Переменные  ---------------------
		.DSEG
.equ ProcDataSize = 64	; память процесса
.equ ProcNum = 8		; колчиество процессов
.equ QueueSize = 16		; Максимальное количество задач в очереди

TempProc:	.byte 1		; для распознания
SREGT:		.byte 1		; временная переменная под SREG
SPTL:		.byte 1		; под SPL
SPTH:		.byte 1		; под SPH
R16T:		.byte 1		; под R16 
ZLT:		.byte 1		; ZL
ZHT:		.byte 1		; ZH
ADDRL:		.byte 1		; адрес
ADDRH:		.byte 1
TCurp:		.byte 1		; временный CurProc (см. ниже)

; Очередь и все, что с ней связано
CurProc:	.byte 1			; Системная переменная, хранит номер процесса
LastItem:	.Byte 1			; Номер последнего элемента очереди (для удобства)
TaskQueue:	.byte QueueSize+1 ; Очередь процессов
TimerQueue: .byte QueueSize*2 ; Очередь таймеров

Proctable: 	.byte ProcNum*2	; Таблица адресов процессов
			
.ORG $AD ; Проверочная область памяти
MutexBits:  .byte 41    

.ORG $D6 ; Общая память. В 8 раз больше проверочной
SharedMem: ; занимает 328 байт

BufSize:	.byte 2 ; переменная с информацией о размере буфера в общей памяти

; Самое важное: место под стек и регистры. -----------
; Сколько процессов - столько и этих записей
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
; Ну тут все ясно...
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
 
	 .ORG   INT_VECTORS_SIZE      	; Конец таблицы
; End Vectors Table =======================================
; Interrupts ==============================================
TM0_OVF:		
	STS R16T, R16			; Загрузка из стека адреса
	POP R16					; в переменные ADDRx
	STS ADDRL, R16			; предварительно сохранив регистр R16
	POP R16
	STS ADDRH, R16
	LDS R16, R16T

	SaveRegs CurProc	; Сохранение регистров

	SaveAddr CurProc	; Сохранение адреса возврата

	DecTimers			; Вызов службы таймеров
	
	GetNextProc			; Получение адреса следующего процесса

	STS ADDRL, ZL		; Сохранение адреса в ADDRx
	STS ADDRH, ZH	
	
	loadRegs			; Загрузка регистров

	STS ZLT, ZL			; сохранение Z
	STS ZHT, ZH
	LDS ZL, ADDRL		; ADDRx в Z
	LDS ZH, ADDRH
	PUSH ZL				; Запись в стек адреса возврата
	PUSH ZH
	LDS ZL, ZLT			; восстановление регистра Z
	LDS ZH, ZHT

	STS R16T,R16		
	LDS R16, SREGT		; восстанавление SREG.
	OUT SREG, R16		
	OUTI TCNT0, 0		; Обнуление таймера
	OUTI TIFR, 1		; и его флага прерывания
	LDS R16, R16T		
	RETI				; Выход из прерывания

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

	LDI R16, low(Main)			; Пишем адреса процессов в таблицу
	ST  Z+, R16					; ЗАПРЕЩЕНА любая работа с процессом
	LDI R16, High(Main)			; Main, т.е. ставить на паузу, ставить 
	ST  Z+, R16					; таймер, запускать и т.п. Это приведет
								; к срыву очереди 
	
	LDI R16, low(Proc1)  ; объявляем процесс-производитель
	ST  Z+, R16
	LDI R16, High(Proc1)
	ST  Z+, R16

	LDI R16, low(Proc2) ; объявляем два процесса-потребителя с задержкой
	ST  Z+, R16
	LDI R16, High(Proc2)
	ST  Z+, R16

	LDI R16, low(Proc3) 
	ST  Z+, R16
	LDI R16, High(Proc3)
	ST  Z+, R16

	LDI R16, low(Proc4) ; объявляем процесс-потребитель без задержки
	ST  Z+, R16
	LDI R16, High(Proc4)
	ST  Z+, R16

	LDI R17, 1					; и создаем их (все, кроме Main).
	LDI R18, 3					; устанавливаем приоритет
	RCALL CreateProcess
	
	LDI R17, 2					; номер процесса из таблицы
	LDI R18, 1					; устанавливаем приоритет
	RCALL CreateProcess

	LDI R17, 4					
	LDI R18, 2					
	RCALL CreateProcess

	LDI R17, 3					
	LDI R18, 1						
	RCALL CreateProcess
	

; End Run ======================================================

; Main =========================================================
	StartTimer		; запуск таймера
	ClrRegs			; очистка регстров

	LDI ZL, low(BufSize)   ; обнуляем переменную
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

; Процессы  ===================
; Производитель ----------------------
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

; 1ый Потребитель с начальной задержкой ----------------------------------
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
	CPI XL, 0						; побайтовое сравнение
	BRNE Decrem1					; Если 0 - то не надо уменьшать
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

; 2ой Потребитель с начальной задержкой ----------------------------------
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
	CPI XL, 0						; побайтовое сравнение
	BRNE Decrem2					; Если 0 - то не надо уменьшать
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

; Потребитель без первоначальной задержки ----------------------------------
 Proc4:
	LDI ZL, low(BufSize)
	LDI ZH, High(BufSize)
	LDI R16, 2
	CaptureSharedMemory ZL, ZH, R16
  	LD XL, Z+
	LD XH, Z
	CPI XL, 0						; побайтовое сравнение
	BRNE Decrem3					; Если 0 - то не надо уменьшать
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


; Процедуры ==========================================================



; Запуск процесса после паузы
 StartProcess:					; R17 - номер процесса
	 PUSH ZL
	 PUSH ZH
     PUSH R16
 	 LDS R16, LastItem			; Увеличим номер последнего элемента
	 INC R16
	 CPI R16, QueueSize			; Если больше размера очереди - выходим
	 BREQ ExitS

	 Push R17

	 STS LastItem, R16
	 LDI ZL, Low(TaskQueue)		; Далее надо сдвинуть очередь
	 LDI ZH, High(TaskQueue)	; что мы и делаем
		
	 ADD ZL, R16				; получаем адрес конца очереди
	 CLR R17
	 ADC ZH, R17
		
	 MOV R17, R16				; сдвигать надо от конца и до текущего		
 	 LDS R18, CurProc			; т.к. вставляем процесс после текущего
	 SUB R17, R18				; В R17 - количесво сдвигов
 ShellS:							; Сдвигаем
	 	 LD R18, Z+				
		 ST Z, R18
		 LD R0, -Z
		 LD R0, -Z
		 DEC R17
		 BRNE ShellS
	 
	 LD R0, Z+					; пишем в освободившееся место интересующий
	 POP R17					; номер процесса
	 ST  Z, R17
ExitS:
	POP R16
	POP ZH
	POP ZL
 	RET


;Создание нового процесса-----------------------------------------------
 CreateProcess:		             
	 							; R18 - приоритет, т.е. сколько раз надо поставить в очередь
 	 LDS R16, LastItem			; R17 - номер процесса в таблице адресов.
								; Увеличим номер последнего элемента
	 INC R16
	 CPI R16, QueueSize			; Если больше размера очереди - выходим
	 BREQ Exit
	 STS LastItem, R16			; увеличим конец очереди

; Инициализация нового процесса ----------------------------
	 LDI YL, Low(ProcData)		; Начало области данных
	 LDI YH, High(ProcData)

	 INC R17
 	 LDI R16, ProcDataSize		; Получаем начало данных след. процесса
	 MUL R16, R17
	 ADD YL, R0
	 ADC YH, R1
	 DEC R17
	 LD  R16, -Y				; Уменьшим на 1 - конец данных нужного 
	 							; В Y пару сохраняем этот адрес - 
	 							; Это будет стек

	 LDI ZL, Low(ProcData)		; Начало области данных
	 LDI ZH, High(ProcData)

 	 LDI R16, ProcDataSize		; Получаем начало данных нужного процесса
	 MUL R16, R17
	 ADD ZL, R0
	 ADC ZH, R1
	 
	 LDI R16, 33				; Очищаем место регистров - 32 регистра,
	 LDI R19, 0					; флаг состояния => пишем 33 нуля
 Clear:
 	 ST  Z+, R19
	 DEC R16
	 BRNE Clear

	 ST  Z+, YL					; Пишем адрес стека
	 ST	 Z+, YH
	 
; Запуск процесса  - ставим в очередь-------------------------------------

	 LDS R16, LastItem
	 LDI ZL, Low(TaskQueue)		; Загружаем  адрес в очереди
	 LDI ZH, High(TaskQueue)	; Исходя из номера последнего элемента

	 ADD ZL, R16
	 LDI R16, 0
	 ADC ZH, R16

	 ST Z+, R17					; И пишем туда наш номер процесса,
	 LDI R16, $FF				
	 ST Z+, R16

	 DEC R18					; Проверяем, сколько ещё раз надо поставить этот процесс в очередь
	 BRNE CreateProcess
Exit:
 	RET



;Поставить процесс на паузу ----------------------------------------------
/*
 Внимание! Перед функцией ОБЯЗАТЕЛЬНО необходимо запретить прерывания,
 а после - разрешить. Иначе возможно будет плохо.
 рестарт процессора.
*/ 
 SuspendProcess:		;R17 - номер процесса
	 LDI ZL, Low(TaskQueue)		; начало очереди
	 LDI ZH, High(TaskQueue)

	 LDI R16, 0
 Seek:					; Ищем процесс с таким номером в очереди
 		LD R18, Z+
		CP R18, R17
		BREQ EOSeek		; Нашли - идем дальше
		INC R16
		CPI R16, LastItem
		BRNE Seek
		
		RJMP NotFound	; А если нет такого - выходим
 EOSeek:

	 LDI R19, 0			; для распознания в макросе
	 STS TempProc, R17		
	 MOV R17, R16		; Сохраняем номер в очереди
	 LDS R16, CurProc	; 
	 CP	 R16, R17		; Если не равен текущему - 
	 BRNE TNoSave		; то не сохраняем регистры	
 TSave:
		 LDI R19, 1		
		 RJMP NoDec		

 TNoSave:			
 		 CP R16, R17		; Если меньше текущего - 
	 	 BRCS NoDec			; То уменьшаем номер текущего в очереди
		 	LDS R16, CurProc 
		 	DEC R16
		 	STS CurProc, R16

 NoDec:
 	 LDI ZL, Low(TaskQueue)		; Далее надо сдвинуть очередь
	 LDI ZH, High(TaskQueue)	
		
     INC R17					; От текущего и до конца
	 ADD ZL, R17
	 LDI R16, 0
	 ADC ZH, R16
	 DEC R17
		
 	 LDS R16, LastItem
	 SUB R16, R17
	 INC R16
 Shell:							; Сдвигаем (да, криво, я знаю)
	 	 LD R18, Z
		 ST -Z, R18
		 LD R0, Z+
		 LD R0, Z+
		 DEC R16
		 BRNE Shell

	 LDS R16, LastItem			; уменьшаем номер последнего элемента
	 DEC R16
	 STS LastItem, R16
 		
	 CPI R19, 0
	 BREQ NotFound				; и если стопим текущий процесс - то переключим
	   RJMP TM0_OVF

 NotFound:	 					; Иначе - выходим
	RET



;Поставить таймер -------------------------------------------------------
/*
 Внимание! данная функция должна использоваться вместе с Suspend porcess
 Иначе через установленную задержку запустится второй экземпляр процесса,
 имеющий тот же адрес, ту же память и тот же стек, НО работающий парал -
 лельно первому, Соответственно их регистры будут мешаться друг с другом,
 указатель стека будет прыгать туда-сюда

 делается так:
 ...
 CLI
  Rcall SetTimer
  Rcall Suspend process
 STI
 ...
*/
 SetTimer:				 ;R17 - номер процесса, R18(L), R19(H)-задержка
 	 PUSH R16
	 PUSH R17
	 LDI ZL, Low(TimerQueue)	; начало очереди таймеров
	 LDI ZH, High(TimerQueue)	

	 LDI R16, 0 				; 
	 ROL R17					; умножим адрес на два - таймеры двухбайтные
	 ROL R16					; а вдруг кто-то 129 процессов сделает
	 ADD ZL, R17				; получаем адрес
	 ADC ZH, R16				; 

	 ST	 Z+, R18				; Ставим таймер
	 ST  Z+, R19				; Ставим таймер
	 POP R17
	 POP R16
	RET							; выход

; Процедура "Перейти к след. процессу" ------------------------------
/*
Usage:
  
  ...
  LDI R18, 1			   ; Если задержка = 1 - процесс запустится
  LDI R19, 0			   ; при следущем переключении. Нам это и надо.
  CLI
  RCALL SetTimer		   ; Ставим таймер
  RCALL SuspendProcess	   ; Отключим процесс
  RCALL GoToNextProc	    
*/
 GoToNextProc:
 	CLI						; Защита (на всякий)
	RJMP TM0_OVF			; идем на прерывание таймера 
 RET						;
							
; End Procedure ================================================

