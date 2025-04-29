; RC5 Encryption/Decryption for Arduino UNO
; Complete Implementation with LCD Display
; Plaintext: 0x1C34 0xA2C3

.include "m328pdef.inc"

; === Register Definitions ===
.def temp_reg   = r16
.def word_a_l   = r17
.def word_a_h   = r18
.def word_b_l   = r19
.def word_b_h   = r20
.def counter    = r21
.def index_i    = r22
.def index_j    = r23
.def loop_c     = r24
.def rot_val    = r25
.def zero_reg   = r1

; === Constants ===
.equ P_CONST    = 0xB7E1
.equ Q_CONST    = 0x9E37
.equ ROUNDS     = 12

; === LCD Pins (Arduino UNO) ===
.equ LCD_RS_PORT = PORTD
.equ LCD_RS_BIT  = 7
.equ LCD_RS_DDR  = DDRD

.equ LCD_EN_PORT = PORTD
.equ LCD_EN_BIT  = 6
.equ LCD_EN_DDR  = DDRD

.equ LCD_D4_PORT = PORTD
.equ LCD_D4_BIT  = 5
.equ LCD_D4_DDR  = DDRD

.equ LCD_D5_PORT = PORTD
.equ LCD_D5_BIT  = 4
.equ LCD_D5_DDR  = DDRD

.equ LCD_D6_PORT = PORTD
.equ LCD_D6_BIT  = 3
.equ LCD_D6_DDR  = DDRD

.equ LCD_D7_PORT = PORTD
.equ LCD_D7_BIT  = 2
.equ LCD_D7_DDR  = DDRD

; === SRAM Definitions ===
.dseg
.org 0x0100
key_data:       .byte 12
expanded_key:   .byte 12
s_table:        .byte 36
plaintext_a:    .byte 2    ; Stores 0x1C34 (0x34, 0x1C)
plaintext_b:    .byte 2    ; Stores 0xA2C3 (0xC3, 0xA2)
result_a:       .byte 2
result_b:       .byte 2
lcd_buffer:     .byte 32

; === Code Segment ===
.cseg
.org 0x0000
    rjmp main

.org 0x0034  ; Skip interrupt vectors

; String Constants
msg_test:      .db "RC5 Test", 0
msg_plain:     .db "Plaintext:", 0
msg_encrypted: .db "Encrypted:", 0
msg_decrypted: .db "Decrypted:", 0

; ===== MAIN PROGRAM =====
main:
    ; Initialize stack
    ldi temp_reg, high(RAMEND)
    out SPH, temp_reg
    ldi temp_reg, low(RAMEND)
    out SPL, temp_reg
    
    clr zero_reg
    
    ; Initialize test data with 0x1C34 and 0xA2C3
    rcall initialize_test_data
    
    ; Initialize LCD
    rcall lcd_init
    
    ; Display test message
    rcall lcd_clear
    ldi ZL, low(msg_test*2)
    ldi ZH, high(msg_test*2)
    rcall lcd_print_string
    rcall delay_1s
    
    ; Display plaintext (0x1C34 0xA2C3)
    rcall lcd_clear
    ldi ZL, low(msg_plain*2)
    ldi ZH, high(msg_plain*2)
    rcall lcd_print_string
    rcall display_values
    rcall delay_1s
    
    ; Generate keys
    rcall expand_key
    
    ; Encrypt
    rcall perform_encryption
    
    ; Show encrypted
    rcall lcd_clear
    ldi ZL, low(msg_encrypted*2)
    ldi ZH, high(msg_encrypted*2)
    rcall lcd_print_string
    rcall display_encrypted
    rcall delay_1s
    
    ; Decrypt
    rcall perform_decryption
    
    ; Show decrypted (should match plaintext)
    rcall lcd_clear
    ldi ZL, low(msg_decrypted*2)
    ldi ZH, high(msg_decrypted*2)
    rcall lcd_print_string
    rcall display_values

	;secure_clear values
	rcall secure_clear
    
infinite_loop:
    rjmp infinite_loop

; ===== INITIALIZE TEST DATA =====
initialize_test_data:
    ; Initialize key (12 bytes: 0x01-0x0C)
    ldi XL, low(key_data)
    ldi XH, high(key_data)
    ldi counter, 1
fill_key_loop:
    st X+, counter
    inc counter
    cpi counter, 13
    brne fill_key_loop
    
    ; Set plaintext_a = 0x1C34 (little-endian)
    ldi XL, low(plaintext_a)
    ldi XH, high(plaintext_a)
    ldi temp_reg, 0x34      ; Low byte
    st X+, temp_reg
    ldi temp_reg, 0x1C      ; High byte
    st X, temp_reg
    
    ; Set plaintext_b = 0xA2C3 (little-endian)
    ldi XL, low(plaintext_b)
    ldi XH, high(plaintext_b)
    ldi temp_reg, 0xC3      ; Low byte
    st X+, temp_reg
    ldi temp_reg, 0xA2      ; High byte
    st X, temp_reg
    ret

; ===== KEY EXPANSION =====
expand_key:
    ; Convert key bytes to words
    ldi XL, low(key_data)
    ldi XH, high(key_data)
    ldi YL, low(expanded_key)
    ldi YH, high(expanded_key)
    ldi counter, 6
copy_to_words:
    ld temp_reg, X+
    st Y+, temp_reg
    ld temp_reg, X+
    st Y+, temp_reg
    dec counter
    brne copy_to_words
    
    ; Initialize S array
    ldi ZL, low(s_table)
    ldi ZH, high(s_table)
    ldi temp_reg, low(P_CONST)
    st Z+, temp_reg
    ldi temp_reg, high(P_CONST)
    st Z+, temp_reg
    
    ldi counter, 17
    ldi index_i, 1
fill_s_loop:
    sbiw Z, 2
    ld word_a_l, Z+
    ld word_a_h, Z+
    ldi temp_reg, low(Q_CONST)
    add word_a_l, temp_reg
    ldi temp_reg, high(Q_CONST)
    adc word_a_h, temp_reg
    st Z+, word_a_l
    st Z+, word_a_h
    dec counter
    brne fill_s_loop
    
    ; Mix arrays
    clr index_i
    clr index_j
    clr word_a_l
    clr word_a_h
    clr word_b_l
    clr word_b_h
    ldi loop_c, 54
    
mixing_loop:
    ldi ZL, low(s_table)
    ldi ZH, high(s_table)
    mov temp_reg, index_i
    lsl temp_reg
    add ZL, temp_reg
    adc ZH, zero_reg
    
    ld temp_reg, Z+
    mov word_b_l, temp_reg
    ld temp_reg, Z+
    mov word_b_h, temp_reg
    
    add word_b_l, word_a_l
    adc word_b_h, word_a_h
    
    ldi counter, 3
s_rotate_loop:
    lsl word_b_l
    rol word_b_h
    brcc s_no_carry
    ori word_b_l, 1
s_no_carry:
    dec counter
    brne s_rotate_loop
    
    sbiw Z, 2
    st Z+, word_b_l
    st Z+, word_b_h
    
    mov word_a_l, word_b_l
    mov word_a_h, word_b_h
    
    ldi ZL, low(expanded_key)
    ldi ZH, high(expanded_key)
    mov temp_reg, index_j
    lsl temp_reg
    add ZL, temp_reg
    adc ZH, zero_reg
    
    ld temp_reg, Z+
    mov word_b_l, temp_reg
    ld temp_reg, Z+
    mov word_b_h, temp_reg
    
    add word_b_l, word_a_l
    adc word_b_h, word_a_h
    
    mov rot_val, word_b_l
    andi rot_val, 0x0F
    
    tst rot_val
    breq skip_l_rotation
l_rotate_loop:
    lsl word_b_l
    rol word_b_h
    brcc l_no_carry
    ori word_b_l, 1
l_no_carry:
    dec rot_val
    brne l_rotate_loop
skip_l_rotation:
    
    sbiw Z, 2
    st Z+, word_b_l
    st Z+, word_b_h
    
    mov word_b_l, word_b_l
    mov word_b_h, word_b_h
    
    inc index_i
    cpi index_i, 18
    brne continue_i
    clr index_i
continue_i:
    inc index_j
    cpi index_j, 6
    brne continue_j
    clr index_j
continue_j:
    
    dec loop_c
    brne mixing_loop
    ret

; ===== ENCRYPTION =====
perform_encryption:
    lds word_a_l, plaintext_a
    lds word_a_h, plaintext_a+1
    lds word_b_l, plaintext_b
    lds word_b_h, plaintext_b+1
    
    ldi ZL, low(s_table)
    ldi ZH, high(s_table)
    ld temp_reg, Z+
    add word_a_l, temp_reg
    ld temp_reg, Z+
    adc word_a_h, temp_reg
    
    ld temp_reg, Z+
    add word_b_l, temp_reg
    ld temp_reg, Z+
    adc word_b_h, temp_reg
    
    ldi loop_c, ROUNDS
    ldi index_i, 1
    
encrypt_loop:
    mov rot_val, word_a_l
    eor rot_val, word_b_l
    mov temp_reg, word_a_h
    eor temp_reg, word_b_h
    
    mov counter, word_b_l
    andi counter, 0x0F
    
    tst counter
    breq skip_a_rot
    
a_rot_loop:
    lsl rot_val
    rol temp_reg
    brcc a_no_carry
    ori rot_val, 1
a_no_carry:
    dec counter
    brne a_rot_loop
skip_a_rot:
    
    ldi ZL, low(s_table)
    ldi ZH, high(s_table)
    mov counter, index_i
    lsl counter
    add ZL, counter
    adc ZH, zero_reg
    
    ld counter, Z+
    add rot_val, counter
    ld counter, Z+
    adc temp_reg, counter
    
    mov word_a_l, rot_val
    mov word_a_h, temp_reg
    
    mov rot_val, word_b_l
    eor rot_val, word_a_l
    mov temp_reg, word_b_h
    eor temp_reg, word_a_h
    
    mov counter, word_a_l
    andi counter, 0x0F
    
    tst counter
    breq skip_b_rot
    
b_rot_loop:
    lsl rot_val
    rol temp_reg
    brcc b_no_carry
    ori rot_val, 1
b_no_carry:
    dec counter
    brne b_rot_loop
skip_b_rot:
    
    ld counter, Z+
    add rot_val, counter
    ld counter, Z+
    adc temp_reg, counter
    
    mov word_b_l, rot_val
    mov word_b_h, temp_reg
    
    inc index_i
    dec loop_c
    brne encrypt_loop
    
    sts result_a, word_a_l
    sts result_a+1, word_a_h
    sts result_b, word_b_l
    sts result_b+1, word_b_h
    ret

; ===== DECRYPTION =====
perform_decryption:
    lds word_a_l, result_a
    lds word_a_h, result_a+1
    lds word_b_l, result_b
    lds word_b_h, result_b+1
    
    ldi loop_c, ROUNDS
    ldi index_i, ROUNDS
    
decrypt_loop:
    ldi ZL, low(s_table)
    ldi ZH, high(s_table)
    
    mov temp_reg, index_i
    lsl temp_reg
    ldi counter, 2
    add temp_reg, counter
    add ZL, temp_reg 
    adc ZH, zero_reg
    
    ld temp_reg, Z+
    sub word_b_l, temp_reg
    ld temp_reg, Z+
    sbc word_b_h, temp_reg
    
    mov rot_val, word_a_l
    andi rot_val, 0x0F
    
    tst rot_val
    breq skip_b_right_rot
    
b_right_rot_loop:
    bst word_b_l, 0
    lsr word_b_h
    ror word_b_l
    brtc b_right_no_carry
    ori word_b_h, 0x80
b_right_no_carry:
    dec rot_val
    brne b_right_rot_loop
skip_b_right_rot:
    
    eor word_b_l, word_a_l
    eor word_b_h, word_a_h
    
    ldi ZL, low(s_table)
    ldi ZH, high(s_table)
    mov temp_reg, index_i
    lsl temp_reg
    add ZL, temp_reg
    adc ZH, zero_reg
    
    ld temp_reg, Z+
    sub word_a_l, temp_reg
    ld temp_reg, Z+
    sbc word_a_h, temp_reg
    
    mov rot_val, word_b_l
    andi rot_val, 0x0F
    
    tst rot_val
    breq skip_a_right_rot
    
a_right_rot_loop:
    bst word_a_l, 0
    lsr word_a_h
    ror word_a_l
    brtc a_right_no_carry
    ori word_a_h, 0x80
a_right_no_carry:
    dec rot_val
    brne a_right_rot_loop
skip_a_right_rot:
    
    eor word_a_l, word_b_l
    eor word_a_h, word_b_h
    
    dec index_i
    dec loop_c
    brne decrypt_loop
    
    ldi ZL, low(s_table)
    ldi ZH, high(s_table)
    
    ld temp_reg, Z+
    sub word_a_l, temp_reg
    ld temp_reg, Z+
    sbc word_a_h, temp_reg
    
    ld temp_reg, Z+
    sub word_b_l, temp_reg
    ld temp_reg, Z+
    sbc word_b_h, temp_reg
    
    sts plaintext_a, word_a_l
    sts plaintext_a+1, word_a_h
    sts plaintext_b, word_b_l
    sts plaintext_b+1, word_b_h
    ret

; ===== LCD FUNCTIONS =====
lcd_init:
    sbi LCD_RS_DDR, LCD_RS_BIT
    sbi LCD_EN_DDR, LCD_EN_BIT
    sbi LCD_D4_DDR, LCD_D4_BIT
    sbi LCD_D5_DDR, LCD_D5_BIT
    sbi LCD_D6_DDR, LCD_D6_BIT
    sbi LCD_D7_DDR, LCD_D7_BIT
    
    cbi LCD_RS_PORT, LCD_RS_BIT
    cbi LCD_EN_PORT, LCD_EN_BIT
    
    rcall delay_100ms
    rcall delay_100ms
    
    ldi temp_reg, 0x03
    rcall lcd_send_nibble
    rcall delay_5ms
    
    ldi temp_reg, 0x03
    rcall lcd_send_nibble
    rcall delay_5ms
    
    ldi temp_reg, 0x03
    rcall lcd_send_nibble
    rcall delay_5ms
    
    ldi temp_reg, 0x02
    rcall lcd_send_nibble
    rcall delay_5ms
    
    ldi temp_reg, 0x28
    rcall lcd_send_command
    rcall delay_5ms
    
    ldi temp_reg, 0x0F
    rcall lcd_send_command
    rcall delay_5ms
    
    rcall lcd_clear
    rcall delay_5ms
    
    ldi temp_reg, 0x06
    rcall lcd_send_command
    rcall delay_5ms
    ret

lcd_send_nibble:
    push temp_reg
    
    sbrc temp_reg, 0
    sbi LCD_D4_PORT, LCD_D4_BIT
    sbrs temp_reg, 0
    cbi LCD_D4_PORT, LCD_D4_BIT
    
    sbrc temp_reg, 1
    sbi LCD_D5_PORT, LCD_D5_BIT
    sbrs temp_reg, 1
    cbi LCD_D5_PORT, LCD_D5_BIT
    
    sbrc temp_reg, 2
    sbi LCD_D6_PORT, LCD_D6_BIT
    sbrs temp_reg, 2
    cbi LCD_D6_PORT, LCD_D6_BIT
    
    sbrc temp_reg, 3
    sbi LCD_D7_PORT, LCD_D7_BIT
    sbrs temp_reg, 3
    cbi LCD_D7_PORT, LCD_D7_BIT
    
    sbi LCD_EN_PORT, LCD_EN_BIT
    rcall delay_1us
    rcall delay_1us
    cbi LCD_EN_PORT, LCD_EN_BIT
    rcall delay_100us
    
    pop temp_reg
    ret

lcd_send_command:
    push temp_reg
    
    cbi LCD_RS_PORT, LCD_RS_BIT
    
    mov rot_val, temp_reg
    swap rot_val
    andi rot_val, 0x0F
    mov temp_reg, rot_val
    rcall lcd_send_nibble
    
    pop temp_reg
    push temp_reg
    andi temp_reg, 0x0F
    rcall lcd_send_nibble
    
    rcall delay_5ms
    
    pop temp_reg
    ret

lcd_send_char:
    push temp_reg
    
    sbi LCD_RS_PORT, LCD_RS_BIT
    
    mov rot_val, temp_reg
    swap rot_val
    andi rot_val, 0x0F
    mov temp_reg, rot_val
    rcall lcd_send_nibble
    
    pop temp_reg
    push temp_reg
    andi temp_reg, 0x0F
    rcall lcd_send_nibble
    
    rcall delay_100us
    
    pop temp_reg
    ret

lcd_print_string:
    push temp_reg
    
lcd_print_loop:
    lpm temp_reg, Z+
    tst temp_reg
    breq lcd_done_printing
    
    rcall lcd_send_char
    rjmp lcd_print_loop
    
lcd_done_printing:
    pop temp_reg
    ret

lcd_clear:
    ldi temp_reg, 0x01
    rcall lcd_send_command
    rcall delay_5ms
    
    ldi temp_reg, 0x02
    rcall lcd_send_command
    rcall delay_5ms
    ret

; ===== DISPLAY FUNCTIONS =====
display_values:
    ldi temp_reg, 0xC0       ; Move to second line
    rcall lcd_send_command
    
    ; Display plaintext_a (0x1C34)
    lds temp_reg, plaintext_a+1  ; High byte (0x1C)
    rcall lcd_print_hex
    lds temp_reg, plaintext_a    ; Low byte (0x34)
    rcall lcd_print_hex
    
    ldi temp_reg, ' '           ; Space separator
    rcall lcd_send_char
    
    ; Display plaintext_b (0xA2C3)
    lds temp_reg, plaintext_b+1  ; High byte (0xA2)
    rcall lcd_print_hex
    lds temp_reg, plaintext_b    ; Low byte (0xC3)
    rcall lcd_print_hex
    ret

display_encrypted:
    ldi temp_reg, 0xC0       ; Move to second line
    rcall lcd_send_command
    
    ; Display result_a (encrypted)
    lds temp_reg, result_a+1
    rcall lcd_print_hex
    lds temp_reg, result_a
    rcall lcd_print_hex
    
    ldi temp_reg, ' '        ; Space separator
    rcall lcd_send_char
    
    ; Display result_b (encrypted)
    lds temp_reg, result_b+1
    rcall lcd_print_hex
    lds temp_reg, result_b
    rcall lcd_print_hex
    ret

lcd_print_hex:
    push temp_reg
    push rot_val
    
    mov rot_val, temp_reg
    swap rot_val
    andi rot_val, 0x0F
    cpi rot_val, 10
    brlo high_digit
    subi rot_val, -('A'-'0'-10)
high_digit:
    subi rot_val, -'0'
    mov temp_reg, rot_val
    rcall lcd_send_char
    
    pop rot_val
    andi rot_val, 0x0F
    cpi rot_val, 10
    brlo low_digit
    subi rot_val, -('A'-'0'-10)
low_digit:
    subi rot_val, -'0'
    mov temp_reg, rot_val
    rcall lcd_send_char
    
    pop temp_reg
    ret

; ===== DELAY ROUTINES =====
delay_1us:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ret

delay_100us:
    push r16
    ldi r16, 100
delay_100us_loop:
    rcall delay_1us
    dec r16
    brne delay_100us_loop
    pop r16
    ret

delay_5ms:
    push r16
    push r17
    ldi r16, 50
delay_5ms_outer:
    ldi r17, 100
delay_5ms_inner:
    rcall delay_1us
    dec r17
    brne delay_5ms_inner
    dec r16
    brne delay_5ms_outer
    pop r17
    pop r16
    ret

delay_100ms:
    push r16
    ldi r16, 20
delay_100ms_loop:
    rcall delay_5ms
    dec r16
    brne delay_100ms_loop
    pop r16
    ret

delay_1s:
    push r16
    ldi r16, 10
delay_1s_loop:
    rcall delay_100ms
    dec r16
    brne delay_1s_loop
    pop r16
    ret

	;*********************************************************
; SECURE CLEAR ROUTINE
; Overwrites sensitive memory areas: S_table and expanded_key
;*********************************************************

secure_clear:
    ; Ensure zero_reg (r1) is zero
    clr zero_reg

    ;----------------------------------------
    ; Clear S_table (36 bytes)
    ;----------------------------------------
    ldi ZL, low(s_table)
    ldi ZH, high(s_table)
    ldi temp_reg, 36
clear_s_loop:
    st Z+, zero_reg
    dec temp_reg
    brne clear_s_loop

    ;----------------------------------------
    ; Clear expanded_key (12 bytes)
    ;----------------------------------------
    ldi ZL, low(expanded_key)
    ldi ZH, high(expanded_key)
    ldi temp_reg, 12
clear_l_loop:
    st Z+, zero_reg
    dec temp_reg
    brne clear_l_loop

    ret

