.device ATMega16

.cseg
.org 0x000 ; Reset Handler
	jmp RESET 
.ORG 0x002 ; IRQ0 Handler
	jmp RESET
.ORG 0x004 ; IRQ1 Handler
	jmp RESET 
.ORG 0x006 ; Timer2 Compare Handler
	jmp RESET 
.ORG 0x008 ; Timer2 Overflow Handler
	jmp RESET 
.ORG 0x00A ; Timer1 Capture Handler
	jmp RESET 
.ORG 0x00C ; Timer1 CompareA Handler
	jmp TIM1_COMPA
.ORG 0x00E ; Timer1 CompareB Handler
	jmp RESET
.ORG 0x010 ; Timer1 Overflow Handler
	jmp RESET 
.ORG 0x012 ; Timer0 Overflow Handler
	jmp RESET 
.ORG 0x014 ; SPI Transfer Complete Handler
	jmp RESET 
.ORG 0x016 ; USART RX Complete Handler
	jmp RESET 
.ORG 0x018 ; UDR Empty Handler
	jmp RESET 
.ORG 0x01A ; USART TX Complete Handler
	jmp RESET 
.ORG 0x01C ; ADC Conversion Complete Handler
	jmp RESET 
.ORG 0x01E ; EEPROM Ready Handler
	jmp RESET
.ORG 0x020 ; Analog Comparator Handler
	jmp RESET
.ORG 0x022 ; Two-wire Serial Interface Handler
	jmp RESET
.ORG 0x024 ; IRQ2 Handler
	jmp RESET
.ORG 0x026 ; Timer0 Compare Handler
	jmp RESET
.ORG 0x028 ; Store Program Memory Ready Handler
	jmp RESET 


DATA:
	.db 0b01110111, 0b00010100, 0b01011011, 0b01011110, \
		0b00111100, 0b01101110, 0b01101111, 0b01010100, \
		0b01111111,	0b01111110


RESET:
	;; Direction for pins d
	ldi r16, 0b01111111
	out DDRD, r16

	;; Direction for other pins
	ldi r16, 0x00
	out DDRA, r16
	out DDRB, r16
	out DDRC, r16
	;; out DDRD, r16

	;; Setting pins d state
	ldi r16, 0b10000000
	out PORTD, r16

	;; Setting state for other pins
	ldi r16, 0xFF
	out PORTA, r16
	out PORTB, r16
	out PORTC, r16
	;;out PORTD, r16

	;; Setting stack for function calls
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16

	;; Setting timer:

	ldi r16, 0b00010000 ;Unmask OCR1A interrupt
	out TIMSK, r16

	; Setting TCNT1 TOP to OCR1A value
	;; 31250 = 0x7A12
	ldi r16, 0x7A
	out OCR1AH, r16
	ldi r16, 0x12
	out OCR1AL, r16


	;; Configuring WGM11..10
	ldi r16, 0x00
	out TCCR1A, r16

	;; Configuring WGM13..12 and Prescaler 1/64
	ldi r16, 0b00001100
	out TCCR1B, r16
	;Timer is ticking there

	;; Ten as a constant in r15
	ldi r16, 10
	mov r15, r16

	;; Zero as a constant in r14
	clr r16
	mov r14, r16
	clr r16	;; Just in case

	SEI ;; INTERRUPTS global enable

	rjmp start
; Replace with your application code
start:
		sbrc r17, 0x00
	rcall COUNT
		rjmp start

TIM1_COMPA:
	sbr r17, 0x01
	reti

COUNT:
	;; increment register and index array
	inc r18
	cpse r18, r15
	rjmp COUNT_IF_NOT_ZERO
	clr r18
	COUNT_IF_NOT_ZERO:
	ldi ZH, high(DATA*2)
	ldi ZL, low(DATA*2)
	add ZL, r18
	adc ZH, r14 ;; zero in r14
	lpm r20, Z
	;;in r19, PINA
	in r19, PIND

	;; Mask r19
	andi r19, 0b10000000
	or r19, r20


	;; out PORTA, r19 ;; DISPLAY final result on SEG
	out PORTD, r19
	cbr r17, 1 ;; Clear bit in flag register before returning
	ret
