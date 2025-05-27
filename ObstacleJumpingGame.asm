.MODEL SMALL
.STACK 100h

.DATA
    ; Oyuncu
    player_x        db 10
    player_y        db 21
    player_ground   db 21
    jump_height     db 0
    is_jumping      db 0
    selected_char   db 0
    old_player_y    db 21
    
    ; Engeller - farklý baþlangýç konumlarý
    obstacle1_x     db 80
    obstacle2_x     db 110  
    obstacle3_x     db 140
    old_obs1_x      db 80
    old_obs2_x      db 110
    old_obs3_x      db 140
    
    ; Oyun
    player_lives    db 3
    game_over       db 0
    score          dw 0
    old_score      dw 0
    old_lives      db 3
    
    ; Karakterler
    heart_char      db 3
    star_char       db '*'
    grass_char      db 219
    dirt_char       db 177
    moon_char       db 15h

.CODE
MAIN PROC
    mov ax, @data
    mov ds, ax
    
    ; Video modu
    mov ah, 00h
    mov al, 03h
    int 10h
    
    ; Baþlangýç ekraný
    CALL SHOW_START_SCREEN
    
    ; Karakter seçimi
    CALL CHARSEL
    
    ; Oyunu baþlat
    CALL SETUP_GAME
    
GAME_LOOP:
    CMP game_over, 1
    JE GAME_OVER_SCREEN
    
    CALL CHECK_INPUT
    CALL UPDATE_GAME
    CALL DRAW_GAME_FAST
    CALL DELAY_FAST
    
    JMP GAME_LOOP

GAME_OVER_SCREEN:
    CALL SHOW_GAME_OVER
    
WAIT_KEY:
    mov ah, 00h
    int 16h
    
    cmp al, 27      ; ESC
    je EXIT_GAME
    
    cmp al, 'r'
    je RESTART
    cmp al, 'R'
    je RESTART
    
    jmp WAIT_KEY

RESTART:
    ; Deðerleri sýfýrla
    MOV player_x, 10
    MOV player_y, 21
    MOV old_player_y, 21
    MOV jump_height, 0
    MOV is_jumping, 0
    MOV obstacle1_x, 80
    MOV obstacle2_x, 110
    MOV obstacle3_x, 140
    MOV old_obs1_x, 80
    MOV old_obs2_x, 110
    MOV old_obs3_x, 140
    MOV player_lives, 3
    MOV old_lives, 3
    MOV game_over, 0
    MOV score, 0
    MOV old_score, 0
    
    CALL SETUP_GAME
    JMP GAME_LOOP

EXIT_GAME:
    mov ah, 4Ch
    int 21h
MAIN ENDP

; === HIZLI GECIKME ===
DELAY_FAST PROC
    PUSH cx
    
    ; Çok düþük gecikme - yüksek performans için
    MOV cx, 2h
DELAY_LOOP:
    DEC cx
    JNZ DELAY_LOOP
    
    POP cx
    RET
DELAY_FAST ENDP

; === SAYI YAZDIRMA ===
PRINT_NUMBER PROC
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    
    MOV bx, 10
    MOV cx, 0
    
    CMP ax, 0
    JNE DIVIDE_LOOP
    MOV ah, 02h
    MOV dl, '0'
    INT 21h
    JMP PRINT_DONE
    
DIVIDE_LOOP:
    CMP ax, 0
    JE PRINT_DIGITS
    MOV dx, 0
    DIV bx
    ADD dl, '0'
    PUSH dx
    INC cx
    JMP DIVIDE_LOOP
    
PRINT_DIGITS:
    CMP cx, 0
    JE PRINT_DONE
    POP dx
    MOV ah, 02h
    INT 21h
    DEC cx
    JMP PRINT_DIGITS
    
PRINT_DONE:
    POP dx
    POP cx
    POP bx
    POP ax
    RET
PRINT_NUMBER ENDP

; === EKRAN TEMÝZLE ===
CLEARSCR PROC
    push ax
    push bx
    push cx
    push dx
    
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
    
    POP dx
    POP cx
    POP bx
    POP ax
    RET
CLEARSCR ENDP

; === BAÞLANGIÇ EKRANI ===
SHOW_START_SCREEN PROC
    CALL CLEARSCR
    
    ; Zemin önce çiz
    call DRAW_GROUND
    
    ; Ay - sarý
    mov ah, 02h
    mov bh, 0
    mov dh, 4
    mov dl, 8
    int 10h
    mov ah, 09h
    mov al, moon_char
    mov bl, 0Eh     ; Sarý
    mov cx, 1
    int 10h
    
    ; Yýldýzlar - beyaz
    mov ah, 02h
    mov dh, 3
    mov dl, 15
    int 10h
    mov ah, 09h
    mov al, star_char
    mov bl, 0Fh     ; Beyaz
    mov cx, 1
    int 10h
    
    mov ah, 02h
    mov dh, 5
    mov dl, 25
    int 10h
    mov ah, 09h
    mov al, star_char
    mov bl, 0Fh     ; Beyaz
    mov cx, 1
    int 10h
    
    mov ah, 02h
    mov dh, 4
    mov dl, 60
    int 10h
    mov ah, 09h
    mov al, star_char
    mov bl, 0Fh     ; Beyaz
    mov cx, 1
    int 10h
    
    mov ah, 02h
    mov dh, 6
    mov dl, 70
    int 10h
    mov ah, 09h
    mov al, star_char
    mov bl, 0Fh     ; Beyaz
    mov cx, 1
    int 10h
    
    ; ZIPZIP baþlýðý - renkli, ortalanmýþ
    mov ah, 02h
    mov bh, 0
    mov dh, 8
    mov dl, 37
    int 10h
    
    mov ah, 09h
    mov al, 'Z'
    mov bl, 0Bh     ; Cyan
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'I'
    mov bl, 0Eh     ; Sarý
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'P'
    mov bl, 0Ch     ; Kýrmýzý
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'Z'
    mov bl, 0Ah     ; Yeþil
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'I'
    mov bl, 0Dh     ; Magenta
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'P'
    mov bl, 0Bh     ; Cyan
    mov cx, 1
    int 10h
    
    ; SPACE talimatý - ortalanmýþ
    mov ah, 02h
    mov dh, 12
    mov dl, 28
    int 10h
    
    mov ah, 09h
    mov al, 'S'
    mov bl, 0Eh     ; Sarý
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'P'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'A'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'C'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'E'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, ':'
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 32      ; Boþluk
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'Z'
    mov bl, 0Ah     ; Yeþil
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'i'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'p'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'l'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'a'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    
    ; ENTER talimatý - ortalanmýþ
    mov ah, 02h
    mov dh, 14
    mov dl, 26
    int 10h
    
    mov ah, 09h
    mov al, 'E'
    mov bl, 0Ch     ; Kýrmýzý
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'N'
    mov bl, 0Ch
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'T'
    mov bl, 0Ch
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'E'
    mov bl, 0Ch
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'R'
    mov bl, 0Ch
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, ':'
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 32      ; Boþluk
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'K'
    mov bl, 0Bh     ; Cyan
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'a'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'r'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'a'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'k'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 't'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'e'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'r'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    
    ; Enter bekle
WAIT_ENTER:
    mov ah, 00h
    int 16h
    cmp al, 13
    jne WAIT_ENTER
    
    ret
SHOW_START_SCREEN ENDP

; === KARAKTER SEÇÝMÝ - DÜZELTÝLMÝÞ ===
CHARSEL PROC
    CALL CLEARSCR
    
    ; Baþlýk - ortalanmýþ
    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 32
    int 10h
    
    mov ah, 09h
    mov al, 'K'
    mov bl, 0Eh     ; Sarý
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'A'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'R'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'A'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'K'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'T'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'E'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'R'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 32      ; Boþluk
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'S'
    mov bl, 0Ch     ; Kýrmýzý
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'E'
    mov bl, 0Ch
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'C'
    mov bl, 0Ch
    mov cx, 1
    int 10h
    
    mov selected_char, 0

CHAR_SELECT_LOOP:
    ; Karakter alanýný temizle
    mov ah, 02h
    mov bh, 0
    mov dh, 9
    mov dl, 15
    int 10h
    mov cx, 50
CHAR_CLEAR1:
    push cx
    mov ah, 02h
    mov dl, 32
    int 21h
    pop cx
    loop CHAR_CLEAR1
    
    mov ah, 02h
    mov dh, 10
    mov dl, 15
    int 10h
    mov cx, 50
CHAR_CLEAR2:
    push cx
    mov ah, 02h
    mov dl, 32
    int 21h
    pop cx
    loop CHAR_CLEAR2
    
    mov ah, 02h
    mov dh, 11
    mov dl, 15
    int 10h
    mov cx, 50
CHAR_CLEAR3:
    push cx
    mov ah, 02h
    mov dl, 32
    int 21h
    pop cx
    loop CHAR_CLEAR3
    
    mov ah, 02h
    mov dh, 12
    mov dl, 15
    int 10h
    mov cx, 50
CHAR_CLEAR4:
    push cx
    mov ah, 02h
    mov dl, 32
    int 21h
    pop cx
    loop CHAR_CLEAR4
    
    ; Çöp adam - ayaklardan hizalanmýþ, seçilirse kafa kýrmýzý
    mov ah, 02h
    mov bh, 0
    mov dh, 11
    mov dl, 27
    int 10h
    
    ; Ayaklar önce
    mov ah, 09h
    mov al, '/'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 32      ; Boþluk
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, '\'
    mov bl, 0Eh
    mov cx, 1
    int 10h

    ; Gövde - bir satýr yukarý
    mov ah, 02h
    mov dh, 10
    mov dl, 27
    int 10h
    mov ah, 09h
    mov al, '-'
    mov bl, 0Eh     ; Sarý
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, '|'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, '-'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    
    ; Kafa - seçilirse kýrmýzý
    mov ah, 02h
    mov dh, 9
    mov dl, 28
    int 10h
    mov ah, 09h
    mov al, 'O'
    cmp selected_char, 0
    jne CHAR_HEAD_NORMAL1
    mov bl, 0Ch     ; Kýrmýzý (seçili)
    jmp CHAR_HEAD_DRAW1
CHAR_HEAD_NORMAL1:
    mov bl, 0Fh     ; Beyaz (normal)
CHAR_HEAD_DRAW1:
    mov cx, 1
    int 10h
    
    ; Büyücü - ayaklardan hizalanmýþ, seçilirse kafa kýrmýzý
    mov ah, 02h
    mov dh, 11
    mov dl, 47
    int 10h
    
    ; Büyücü ayaklarý önce
    mov ah, 09h
    mov al, '/'
    mov bl, 0Bh     ; Cyan
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 32      ; Boþluk
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, '\'
    mov bl, 0Bh
    mov cx, 1
    int 10h

    ; Büyücü gövdesi - bir satýr yukarý
    mov ah, 02h
    mov dh, 10
    mov dl, 47
    int 10h
    mov ah, 09h
    mov al, '/'
    mov bl, 0Bh     ; Cyan (pelerin)
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, '|'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, '*'
    mov bl, 0Eh     ; Sarý (asa)
    mov cx, 1
    int 10h
    
    ; Büyücü yüzü - seçilirse kýrmýzý
    mov ah, 02h
    mov dh, 9
    mov dl, 48
    int 10h
    mov ah, 09h
    mov al, 'O'
    cmp selected_char, 1
    jne CHAR_HEAD_NORMAL2
    mov bl, 0Ch     ; Kýrmýzý (seçili)
    jmp CHAR_HEAD_DRAW2
CHAR_HEAD_NORMAL2:
    mov bl, 0Fh     ; Beyaz (normal)
CHAR_HEAD_DRAW2:
    mov cx, 1
    int 10h
    
    ; Büyücü þapkasý - en üstte
    mov ah, 02h
    mov dh, 8
    mov dl, 48
    int 10h
    mov ah, 09h
    mov al, '^'
    mov bl, 0Dh     ; Magenta
    mov cx, 1
    int 10h
    
    ; Talimatlar - ortalanmýþ
    mov ah, 02h
    mov dh, 16
    mov dl, 30
    int 10h
    mov ah, 09h
    mov al, 'O'
    mov bl, 0Ah     ; Yeþil
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'K'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 32      ; Boþluk
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'T'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'U'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'S'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'L'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'A'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'R'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'I'
    mov bl, 0Ah
    mov cx, 1
    int 10h
    
    ; ENTER açýklamasý
    mov ah, 02h
    mov dh, 18
    mov dl, 30
    int 10h
    mov ah, 09h
    mov al, 'E'
    mov bl, 0Bh     ; Cyan
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'N'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'T'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'E'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'R'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, ':'
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 32      ; Boþluk
    mov bl, 0Fh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'S'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'E'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    mov ah, 02h
    inc dl
    int 10h
    mov ah, 09h
    mov al, 'C'
    mov bl, 0Bh
    mov cx, 1
    int 10h
    
    ; Klavye giriþi
    mov ah, 00h
    int 16h
    
    cmp ah, 4Bh     ; Sol ok
    je CHAR_LEFT
    cmp ah, 4Dh     ; Sað ok
    je CHAR_RIGHT
    cmp al, 13      ; Enter
    je CHAR_DONE
    
    jmp CHAR_SELECT_LOOP

CHAR_LEFT:
    mov selected_char, 0
    jmp CHAR_SELECT_LOOP

CHAR_RIGHT:
    mov selected_char, 1
    jmp CHAR_SELECT_LOOP

CHAR_DONE:
    RET
CHARSEL ENDP

; === OYUNU HAZIRLA ===
SETUP_GAME PROC
    CALL CLEARSCR
    
    ; Ay - sarý
    mov ah, 02h
    mov bh, 0
    mov dh, 4
    mov dl, 8
    int 10h
    mov ah, 09h
    mov al, moon_char
    mov bl, 0Eh     ; Sarý
    mov cx, 1
    int 10h
    
    ; Yýldýzlar - beyaz
    mov ah, 02h
    mov dh, 3
    mov dl, 15
    int 10h
    mov ah, 09h
    mov al, star_char
    mov bl, 0Fh     ; Beyaz
    mov cx, 1
    int 10h
    
    mov ah, 02h
    mov dh, 5
    mov dl, 25
    int 10h
    mov ah, 09h
    mov al, star_char
    mov bl, 0Fh     ; Beyaz
    mov cx, 1
    int 10h
    
    mov ah, 02h
    mov dh, 4
    mov dl, 60
    int 10h
    mov ah, 09h
    mov al, star_char
    mov bl, 0Fh     ; Beyaz
    mov cx, 1
    int 10h
    
    mov ah, 02h
    mov dh, 6
    mov dl, 70
    int 10h
    mov ah, 09h
    mov al, star_char
    mov bl, 0Fh     ; Beyaz
    mov cx, 1
    int 10h
    
    ; ZIPZIP baþlýðý - rengarenk
    MOV ah, 02h
    MOV bh, 0
    MOV dh, 2
    MOV dl, 37
    INT 10h
    
    MOV ah, 09h
    MOV al, 'Z'
    MOV bl, 0Bh     ; Cyan
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'I'
    MOV bl, 0Eh     ; Sarý
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'P'
    MOV bl, 0Ch     ; Kýrmýzý
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'Z'
    MOV bl, 0Ah     ; Yeþil
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'I'
    MOV bl, 0Dh     ; Magenta
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'P'
    MOV bl, 0Bh     ; Cyan
    MOV cx, 1
    INT 10h
    
    ; Zemin
    CALL DRAW_GROUND
    
    ; Ýlk skor ve can gösterimi
    CALL DRAW_UI
    
    RET
SETUP_GAME ENDP

; === ZEMÝN ÇÝZ - STATÝK VE DÜZELTÝLMÝÞ ===
DRAW_GROUND PROC
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    
    ; Çim - yeþil, tam ekran geniþliði
    MOV ah, 02h
    MOV bh, 0
    MOV dh, 21              ; Çim satýrý
    MOV dl, 0
    INT 10h
    
    MOV cx, 80              ; Tam ekran geniþliði
GRASS_LOOP:
    PUSH cx
    MOV ah, 09h
    MOV al, grass_char      ; - karakteri
    MOV bl, 02h             ; Yeþil renk
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    POP cx
    LOOP GRASS_LOOP
    
    ; Toprak - kahverengi, tam ekran geniþliði
    MOV ah, 02h
    MOV dh, 22              ; Toprak satýrý
    MOV dl, 0
    INT 10h
    
    MOV cx, 80              ; Tam ekran geniþliði
DIRT_LOOP:
    PUSH cx
    MOV ah, 09h
    MOV al, dirt_char       ; - karakteri
    MOV bl, 06h             ; Kahverengi
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    POP cx
    LOOP DIRT_LOOP
    
    ; Alt sýnýr - siyah
    MOV ah, 02h
    MOV dh, 23              ; Alt sýnýr
    MOV dl, 0
    INT 10h
    
    MOV cx, 80
BOTTOM_LOOP:
    PUSH cx
    MOV ah, 09h
    MOV al, dirt_char
    MOV bl, 00h             ; Siyah
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    POP cx
    LOOP BOTTOM_LOOP
    
    POP dx
    POP cx
    POP bx
    POP ax
    RET
DRAW_GROUND ENDP

; === UI ÇÝZ - DÜZELTÝLMÝÞ ===
DRAW_UI PROC
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    
    ; Skor
    MOV ah, 02h
    MOV bh, 0
    MOV dh, 1
    MOV dl, 1
    INT 10h
    
    MOV ah, 02h
    MOV dl, 'S'
    INT 21h
    MOV dl, 'k'
    INT 21h
    MOV dl, 'o'
    INT 21h
    MOV dl, 'r'
    INT 21h
    MOV dl, ':'
    INT 21h
    MOV dl, 32
    INT 21h
    
    MOV ax, score
    CALL PRINT_NUMBER
    
    ; Canlar - pozisyon düzeltildi
    MOV ah, 02h
    MOV dh, 1
    MOV dl, 60
    INT 10h
    
    MOV ah, 02h
    MOV dl, 'C'
    INT 21h
    MOV dl, 'a'
    INT 21h
    MOV dl, 'n'
    INT 21h
    MOV dl, ':'
    INT 21h
    MOV dl, 32
    INT 21h
    
    ; Kalpleri çiz - DÜZELTÝLMÝÞ LOOP
    MOV cl, player_lives    ; CL'yi sayaç olarak kullan
    CMP cl, 0
    JE SKIP_HEARTS_UI
    
    MOV ah, 02h
    MOV dh, 1
    MOV dl, 65              ; Can: yazýsýndan sonra
    INT 10h
    
DRAW_HEARTS_UI_LOOP:
    CMP cl, 0
    JE SKIP_HEARTS_UI
    
    PUSH cx                 ; CX'i kaydet
    MOV ah, 09h
    MOV al, 3               ; Kalp karakteri direkt
    MOV bh, 0               ; Sayfa 0
    MOV bl, 0Ch             ; Kýrmýzý renk
    MOV cx, 1               ; 1 karakter
    INT 10h
    POP cx                  ; CX'i geri al
    
    ; Ýmleci ilerlet
    MOV ah, 02h
    INC dl
    INT 10h
    
    PUSH cx                 ; CX'i tekrar kaydet
    MOV ah, 09h
    MOV al, 32              ; Boþluk
    MOV bl, 07h             ; Normal renk
    MOV cx, 1
    INT 10h
    POP cx                  ; CX'i geri al
    
    ; Ýmleci tekrar ilerlet ve sayacý azalt
    MOV ah, 02h
    INC dl
    INT 10h
    
    DEC cl                  ; Can sayýsýný azalt (CL kullan)
    JMP DRAW_HEARTS_UI_LOOP

SKIP_HEARTS_UI:
    POP dx
    POP cx
    POP bx
    POP ax
    RET
DRAW_UI ENDP

; === KLAVYE ===
CHECK_INPUT PROC
    MOV ah, 01h
    INT 16h
    JZ NO_INPUT
    
    MOV ah, 00h
    INT 16h
    
    CMP al, 32      ; Space
    JE JUMP
    CMP al, 27      ; ESC
    JE EXIT_KEY
    
NO_INPUT:
    RET

JUMP:
    CMP is_jumping, 0
    JNE NO_INPUT
    MOV is_jumping, 1
    MOV jump_height, 6
    RET
    
EXIT_KEY:
    MOV ah, 4Ch
    INT 21h
CHECK_INPUT ENDP

; === GÜNCELLE - HIZLANDIRILMIÞ ===
UPDATE_GAME PROC
    ; Zýplama
    CMP is_jumping, 1
    JNE UPDATE_OBSTACLES
    
    DEC jump_height
    MOV al, player_ground
    SUB al, jump_height
    MOV player_y, al
    
    CMP jump_height, 0
    JG UPDATE_OBSTACLES
    
    MOV is_jumping, 0
    MOV al, player_ground
    MOV player_y, al

UPDATE_OBSTACLES:
    ; ESKÝ POZÝSYONLARI KAYDET (temizlik için)
    MOV al, obstacle1_x
    MOV old_obs1_x, al
    MOV al, obstacle2_x  
    MOV old_obs2_x, al
    MOV al, obstacle3_x
    MOV old_obs3_x, al
    
    ; Engel 1 - sürekli hareket
    SUB obstacle1_x, 2
    CMP obstacle1_x, 254    ; Soldan çýktý mý? 
    JAE RESET_OBS1          
    JMP CHECK_OBS2

RESET_OBS1:
    MOV obstacle1_x, 85     ; Saðdan yeni engel

CHECK_OBS2:
    ; Engel 2 - sürekli hareket
    SUB obstacle2_x, 2
    CMP obstacle2_x, 254
    JAE RESET_OBS2
    JMP CHECK_OBS3

RESET_OBS2:
    MOV obstacle2_x, 100    ; Farklý mesafede yeni engel

CHECK_OBS3:
    ; Engel 3 - sürekli hareket
    SUB obstacle3_x, 2
    CMP obstacle3_x, 254
    JAE RESET_OBS3
    JMP CHECK_SCORE

RESET_OBS3:
    MOV obstacle3_x, 115    ; Farklý mesafede yeni engel

CHECK_SCORE:
    ; SKOR KONTROLÜ - Engeli havada atladým mý?
    ; Y farklý (havada) ve X ayný (engelin üzerinden) geçtiyse skor art
    
    ; Engel 1 - havadayken üzerinden geçtim mi?
    MOV al, player_y
    CMP al, 21              ; Zeminde miyim?
    JE CHECK_SCORE2         ; Evet, zemindeyim - skor verme
    
    MOV al, obstacle1_x
    CMP al, player_x        ; X konumumuz ayný mý?
    JNE CHECK_SCORE2        ; Hayýr, farklý - pas geç
    
    ; Havadayken ayný X konumundayýz = ATLADI!
    CMP old_obs1_x, al      ; Bu engel için daha önce puan verdik mi?
    JE CHECK_SCORE2         ; Evet, tekrar verme
    ADD score, 10           ; BAÞARILI ATLAMA! +10 puan
    MOV old_obs1_x, al      ; Bu engel için puan verildi iþaretle

CHECK_SCORE2:
    ; Engel 2 için ayný kontrol
    MOV al, player_y
    CMP al, 21              
    JE CHECK_SCORE3         ; Zemindeyse pas geç
    
    MOV al, obstacle2_x
    CMP al, player_x        ; X ayný mý?
    JNE CHECK_SCORE3        
    CMP old_obs2_x, al      
    JE CHECK_SCORE3         
    ADD score, 10           
    MOV old_obs2_x, al      

CHECK_SCORE3:
    ; Engel 3 için ayný kontrol
    MOV al, player_y
    CMP al, 21              
    JE CHECK_COLLISION      ; Zemindeyse pas geç
    
    MOV al, obstacle3_x
    CMP al, player_x        ; X ayný mý?
    JNE CHECK_COLLISION     
    CMP old_obs3_x, al      
    JE CHECK_COLLISION      
    ADD score, 10           
    MOV old_obs3_x, al

CHECK_COLLISION:
    ; Çarpýþma kontrolü - sadece zemindeyken VE TEK HÝT KONTROLÜ
    MOV al, player_y
    CMP al, 21              ; Zemin seviyesinde mi?
    JL UPDATE_DONE
    
    ; Engel 1 kontrolü - sadece tam çarpýþma
    CMP obstacle1_x, 0      ; Engel aktif mi?
    JE CHECK_COL2
    MOV al, obstacle1_x
    CMP al, player_x        ; Tam ayný konumda mý?
    JNE CHECK_COL2
    DEC player_lives
    MOV obstacle1_x, 0      ; Engeli devre dýþý býrak
    CMP player_lives, 0
    JE SET_GAME_OVER
    ; Çarpýþma sonrasý engeli yeniden aktif et (5 saniye sonra)
    JMP UPDATE_DONE
                     
CHECK_COL1:
    ; Engel 1 kontrolü - sadece tam çarpýþma
    MOV al, obstacle1_x
    CMP al, player_x        ; Tam ayný konumda mý?
    JNE CHECK_COL2
    DEC player_lives
    MOV obstacle1_x, 85     ; Yeni engel getir
    CMP player_lives, 0
    JE SET_GAME_OVER

CHECK_COL2:
    ; Engel 2 kontrolü - sadece tam çarpýþma
    MOV al, obstacle2_x
    CMP al, player_x        ; Tam ayný konumda mý?
    JNE CHECK_COL3
    DEC player_lives
    MOV obstacle2_x, 100    ; Yeni engel getir
    CMP player_lives, 0
    JE SET_GAME_OVER

CHECK_COL3:
    ; Engel 3 kontrolü - sadece tam çarpýþma
    MOV al, obstacle3_x
    CMP al, player_x        ; Tam ayný konumda mý?
    JNE UPDATE_DONE
    DEC player_lives
    MOV obstacle3_x, 115    ; Yeni engel getir
    CMP player_lives, 0
    JE SET_GAME_OVER

UPDATE_DONE:
    RET

SET_GAME_OVER:
    MOV game_over, 1
    RET
UPDATE_GAME ENDP

; === HIZLI ÇÝZÝM - SADECE DEÐÝÞEN KISIMLARI ===
DRAW_GAME_FAST PROC
    ; Eski karakteri temizle
    CALL CLEAR_OLD_PLAYER
    
    ; Eski engelleri temizle
    CALL CLEAR_OLD_OBSTACLES
    
    ; Yeni karakter pozisyonunu çiz
    CALL DRAW_PLAYER
    
    ; Yeni engelleri çiz
    CALL DRAW_OBSTACLES
    
    ; UI güncelle (sadece deðiþen kýsýmlar)
    CALL UPDATE_UI
    
    ; Eski pozisyonlarý kaydet
    MOV al, player_y
    MOV old_player_y, al
    MOV al, obstacle1_x
    MOV old_obs1_x, al
    MOV al, obstacle2_x
    MOV old_obs2_x, al
    MOV al, obstacle3_x
    MOV old_obs3_x, al
    
    RET
DRAW_GAME_FAST ENDP

; === ESKÝ OYUNCUYU TEMÝZLE ===
CLEAR_OLD_PLAYER PROC
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    
    ; Eski karakterin olduðu yeri tamamen temizle
    CMP selected_char, 1
    JE CLEAR_OLD_WIZARD
    
    ; Çöp adam temizle - 4 satýr
    MOV ah, 02h
    MOV bh, 0
    MOV dh, old_player_y
    SUB dh, 3
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV cx, 4
CLEAR_STICK_LOOP:
    PUSH cx
    MOV ah, 02h
    MOV dl, 32
    INT 21h
    POP cx
    LOOP CLEAR_STICK_LOOP
    
    MOV ah, 02h
    MOV dh, old_player_y
    SUB dh, 2
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV cx, 4
CLEAR_STICK_LOOP2:
    PUSH cx
    MOV ah, 02h
    MOV dl, 32
    INT 21h
    POP cx
    LOOP CLEAR_STICK_LOOP2
    
    MOV ah, 02h
    MOV dh, old_player_y
    DEC dh
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV cx, 4
CLEAR_STICK_LOOP3:
    PUSH cx
    MOV ah, 02h
    MOV dl, 32
    INT 21h
    POP cx
    LOOP CLEAR_STICK_LOOP3
    
    JMP CLEAR_PLAYER_DONE

CLEAR_OLD_WIZARD:
    ; Büyücü temizle - 5 satýr
    MOV ah, 02h
    MOV bh, 0
    MOV dh, old_player_y
    SUB dh, 4
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV cx, 4
CLEAR_WIZ_LOOP1:
    PUSH cx
    MOV ah, 02h
    MOV dl, 32
    INT 21h
    POP cx
    LOOP CLEAR_WIZ_LOOP1
    
    MOV ah, 02h
    MOV dh, old_player_y
    SUB dh, 3
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV cx, 4
CLEAR_WIZ_LOOP2:
    PUSH cx
    MOV ah, 02h
    MOV dl, 32
    INT 21h
    POP cx
    LOOP CLEAR_WIZ_LOOP2
    
    MOV ah, 02h
    MOV dh, old_player_y
    SUB dh, 2
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV cx, 4
CLEAR_WIZ_LOOP3:
    PUSH cx
    MOV ah, 02h
    MOV dl, 32
    INT 21h
    POP cx
    LOOP CLEAR_WIZ_LOOP3
    
    MOV ah, 02h
    MOV dh, old_player_y
    DEC dh
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV cx, 4
CLEAR_WIZ_LOOP4:
    PUSH cx
    MOV ah, 02h
    MOV dl, 32
    INT 21h
    POP cx
    LOOP CLEAR_WIZ_LOOP4

CLEAR_PLAYER_DONE:
    POP dx
    POP cx
    POP bx
    POP ax
    RET
CLEAR_OLD_PLAYER ENDP

; === ESKÝ ENGELLERÝ TEMÝZLE ===
CLEAR_OLD_OBSTACLES PROC
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    
    ; Eski engel 1 - sadece ekran içindeyse temizle
    CMP old_obs1_x, 79
    JAE SKIP_CLEAR_OBS1
    MOV ah, 02h
    MOV bh, 0
    MOV dh, 20              ; Çim seviyesi
    MOV dl, old_obs1_x
    INT 10h
    MOV ah, 02h
    MOV dl, 32
    INT 21h

SKIP_CLEAR_OBS1:
    ; Eski engel 2 - sadece ekran içindeyse temizle
    CMP old_obs2_x, 79
    JAE SKIP_CLEAR_OBS2
    MOV ah, 02h
    MOV dh, 20
    MOV dl, old_obs2_x
    INT 10h
    MOV ah, 02h
    MOV dl, 32
    INT 21h

SKIP_CLEAR_OBS2:
    ; Eski engel 3 - sadece ekran içindeyse temizle
    CMP old_obs3_x, 79
    JAE SKIP_CLEAR_OBS3
    MOV ah, 02h
    MOV dh, 20
    MOV dl, old_obs3_x
    INT 10h
    MOV ah, 02h
    MOV dl, 32
    INT 21h

SKIP_CLEAR_OBS3:
    
    POP dx
    POP cx
    POP bx
    POP ax
    RET
CLEAR_OLD_OBSTACLES ENDP

; === OYUNCU ÇÝZ ===
DRAW_PLAYER PROC
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    
    CMP selected_char, 1
    JE DRAW_ROBOT_PLAYER
    
    ; Çöp adam - düzeltilmiþ, çimin üzerine yerleþtirilmiþ
    MOV ah, 02h
    MOV bh, 0
    MOV dh, player_y
    SUB dh, 3               ; Kafa
    MOV dl, player_x
    INT 10h
    MOV ah, 09h
    MOV al, 'O'
    ; Seçili karakter ise kafa kýrmýzý
    CMP selected_char, 0
    JNE STICK_HEAD_NORMAL
    MOV bl, 0Ch     ; Kýrmýzý (seçili)
    JMP STICK_HEAD_DRAW
STICK_HEAD_NORMAL:
    MOV bl, 0Fh     ; Beyaz (normal)
STICK_HEAD_DRAW:
    MOV cx, 1
    INT 10h
    
    MOV ah, 02h
    MOV dh, player_y
    SUB dh, 2               ; Gövde
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV ah, 09h
    MOV al, '-'
    MOV bl, 0Eh     ; Sarý
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, '|'
    MOV bl, 0Eh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, '-'
    MOV bl, 0Eh
    MOV cx, 1
    INT 10h
    
    MOV ah, 02h
    MOV dh, player_y
    DEC dh                  ; Bacaklar - çimin hemen üstü
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV ah, 09h
    MOV al, '/'
    MOV bl, 0Eh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk (gövde altý)
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, '\'
    MOV bl, 0Eh
    MOV cx, 1
    INT 10h
    
    JMP DRAW_PLAYER_DONE

DRAW_ROBOT_PLAYER:
    ; Büyücü - düzeltilmiþ, çimin üzerine yerleþtirilmiþ
    MOV ah, 02h
    MOV bh, 0
    MOV dh, player_y
    SUB dh, 4               ; Þapka
    MOV dl, player_x
    INT 10h
    MOV ah, 09h
    MOV al, '^'
    MOV bl, 0Dh     ; Magenta (þapka)
    MOV cx, 1
    INT 10h
    
    MOV ah, 02h
    MOV dh, player_y
    SUB dh, 3               ; Yüz
    MOV dl, player_x
    INT 10h
    MOV ah, 09h
    MOV al, 'O'
    ; Seçili karakter ise yüz kýrmýzý
    CMP selected_char, 1
    JNE WIZARD_HEAD_NORMAL
    MOV bl, 0Ch     ; Kýrmýzý (seçili)
    JMP WIZARD_HEAD_DRAW
WIZARD_HEAD_NORMAL:
    MOV bl, 0Fh     ; Beyaz (normal)
WIZARD_HEAD_DRAW:
    MOV cx, 1
    INT 10h
    
    MOV ah, 02h
    MOV dh, player_y
    SUB dh, 2               ; Gövde
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV ah, 09h
    MOV al, '/'
    MOV bl, 0Bh     ; Cyan (pelerin)
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, '|'
    MOV bl, 0Bh     ; Cyan (gövde)
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, '*'
    MOV bl, 0Eh     ; Sarý (asa)
    MOV cx, 1
    INT 10h
    
    MOV ah, 02h
    MOV dh, player_y
    DEC dh                  ; Bacaklar - çimin hemen üstü
    MOV dl, player_x
    DEC dl
    INT 10h
    MOV ah, 09h
    MOV al, '/'
    MOV bl, 0Bh     ; Cyan (bacaklar)
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk (gövde altý)
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, '\'
    MOV bl, 0Bh     ; Cyan (bacaklar)
    MOV cx, 1
    INT 10h

DRAW_PLAYER_DONE:
    POP dx
    POP cx
    POP bx
    POP ax
    RET
DRAW_PLAYER ENDP

; === ENGELLERÝ ÇÝZ - KIRMIZI VE ZEMÝN ÜSTÜNDEKÝ ÇÝMDE ===
DRAW_OBSTACLES PROC
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    
    ; SADECE ESKÝ ENGEL POZÝSYONLARINI TEMÝZLE
    ; Engel 1'in eski pozisyonunu temizle
    CMP old_obs1_x, 79      ; Ekran sýnýrlarý içinde mi?
    JAE SKIP_CLEAR1
    CMP old_obs1_x, 0       ; Devre dýþý mý?
    JE SKIP_CLEAR1
    MOV ah, 02h
    MOV bh, 0
    MOV dh, 20              ; Engel seviyesi
    MOV dl, old_obs1_x
    INT 10h
    MOV ah, 09h
    MOV al, 32              ; Boþluk karakteri
    MOV bl, 02h             ; Çim rengi (yeþil)
    MOV cx, 1
    INT 10h

SKIP_CLEAR1:
    ; Engel 2'nin eski pozisyonunu temizle
    CMP old_obs2_x, 79
    JAE SKIP_CLEAR2
    CMP old_obs2_x, 0       ; Devre dýþý mý?
    JE SKIP_CLEAR2
    MOV ah, 02h
    MOV dh, 20
    MOV dl, old_obs2_x
    INT 10h
    MOV ah, 09h
    MOV al, 32              ; Boþluk
    MOV bl, 02h             ; Çim rengi
    MOV cx, 1
    INT 10h

SKIP_CLEAR2:
    ; Engel 3'ün eski pozisyonunu temizle
    CMP old_obs3_x, 79
    JAE SKIP_CLEAR3
    CMP old_obs3_x, 0       ; Devre dýþý mý?
    JE SKIP_CLEAR3
    MOV ah, 02h
    MOV dh, 20
    MOV dl, old_obs3_x
    INT 10h
    MOV ah, 09h
    MOV al, 32              ; Boþluk
    MOV bl, 02h             ; Çim rengi
    MOV cx, 1
    INT 10h

SKIP_CLEAR3:
    ; YENÝ ENGEL POZÝSYONLARINI ÇÝZ
    ; Engel 1 - kýrmýzý, çim seviyesinde
    CMP obstacle1_x, 79     ; Ekran sýnýrlarý içinde mi?
    JAE SKIP_OBS1
    CMP obstacle1_x, 0      ; Devre dýþý mý?
    JE SKIP_OBS1
    MOV ah, 02h
    MOV bh, 0
    MOV dh, 20              ; Çimin hemen üstü
    MOV dl, obstacle1_x
    INT 10h
    MOV ah, 09h
    MOV al, '#'
    MOV bl, 0Ch     ; Kýrmýzý
    MOV cx, 1
    INT 10h

SKIP_OBS1:
    ; Engel 2 - kýrmýzý, çim seviyesinde
    CMP obstacle2_x, 79
    JAE SKIP_OBS2
    CMP obstacle2_x, 0      ; Devre dýþý mý?
    JE SKIP_OBS2
    MOV ah, 02h
    MOV dh, 20
    MOV dl, obstacle2_x
    INT 10h
    MOV ah, 09h
    MOV al, '#'
    MOV bl, 0Ch     ; Kýrmýzý
    MOV cx, 1
    INT 10h

SKIP_OBS2:
    ; Engel 3 - kýrmýzý, çim seviyesinde
    CMP obstacle3_x, 79
    JAE SKIP_OBS3
    CMP obstacle3_x, 0      ; Devre dýþý mý?
    JE SKIP_OBS3
    MOV ah, 02h
    MOV dh, 20
    MOV dl, obstacle3_x
    INT 10h
    MOV ah, 09h
    MOV al, '#'
    MOV bl, 0Ch     ; Kýrmýzý
    MOV cx, 1
    INT 10h

SKIP_OBS3:
    POP dx
    POP cx
    POP bx
    POP ax
    RET
DRAW_OBSTACLES ENDP

; === UI GÜNCELLE - SADECE DEÐÝÞEN KISIMLARI ===
UPDATE_UI PROC
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    
    ; Skor deðiþti mi?
    MOV ax, score
    CMP ax, old_score
    JE CHECK_LIVES_CHANGE
    
    ; Skor alanýný temizle ve yeniden yaz
    MOV ah, 02h
    MOV bh, 0
    MOV dh, 1
    MOV dl, 7
    INT 10h
    MOV cx, 10
CLEAR_SCORE:
    PUSH cx
    MOV ah, 02h
    MOV dl, 32
    INT 21h
    POP cx
    LOOP CLEAR_SCORE
    
    MOV ah, 02h
    MOV dh, 1
    MOV dl, 7
    INT 10h
    MOV ax, score
    CALL PRINT_NUMBER
    
    MOV ax, score
    MOV old_score, ax

CHECK_LIVES_CHANGE:
    ; Can deðiþti mi?
    MOV al, player_lives
    CMP al, old_lives
    JE UPDATE_UI_DONE
    
    ; Can alanýný tamamen temizle
    MOV ah, 02h
    MOV dh, 1
    MOV dl, 60
    INT 10h
    MOV cx, 20      ; Daha geniþ alan temizle
CLEAR_LIVES:
    PUSH cx
    MOV ah, 02h
    MOV dl, 32
    INT 21h
    POP cx
    LOOP CLEAR_LIVES
    
    ; Can yazýsýný ve kalpleri yeniden yaz
    MOV ah, 02h
    MOV dh, 1
    MOV dl, 60
    INT 10h
    
    MOV ah, 02h
    MOV dl, 'C'
    INT 21h
    MOV dl, 'a'
    INT 21h
    MOV dl, 'n'
    INT 21h
    MOV dl, ':'
    INT 21h
    MOV dl, 32
    INT 21h
    
    ; Kalpleri çiz - DÜZELTÝLMÝÞ LOOP
    MOV cl, player_lives    ; CL'yi sayaç olarak kullan
    CMP cl, 0
    JE SKIP_HEARTS_UPDATE
    
    MOV ah, 02h
    MOV dh, 1
    MOV dl, 65              ; Can: yazýsýndan sonra
    INT 10h
    
DRAW_HEARTS_UPDATE_LOOP:
    CMP cl, 0
    JE SKIP_HEARTS_UPDATE
    
    PUSH cx                 ; CX'i kaydet
    MOV ah, 09h
    MOV al, 3               ; Kalp karakteri direkt
    MOV bh, 0               ; Sayfa 0
    MOV bl, 0Ch             ; Kýrmýzý renk
    MOV cx, 1               ; 1 karakter
    INT 10h
    POP cx                  ; CX'i geri al
    
    ; Ýmleci ilerlet
    MOV ah, 02h
    INC dl
    INT 10h
    
    PUSH cx                 ; CX'i tekrar kaydet
    MOV ah, 09h
    MOV al, 32              ; Boþluk
    MOV bl, 07h             ; Normal renk
    MOV cx, 1
    INT 10h
    POP cx                  ; CX'i geri al
    
    ; Ýmleci tekrar ilerlet ve sayacý azalt
    MOV ah, 02h
    INC dl
    INT 10h
    
    DEC cl                  ; Can sayýsýný azalt (CL kullan)
    JMP DRAW_HEARTS_UPDATE_LOOP
    POP cx
    DEC cl
    JNZ DRAW_HEARTS_UPDATE_LOOP

SKIP_HEARTS_UPDATE:
    MOV al, player_lives
    MOV old_lives, al

UPDATE_UI_DONE:
    POP dx
    POP cx
    POP bx
    POP ax
    RET
UPDATE_UI ENDP

; === GAME OVER - RENKLÝ ===
SHOW_GAME_OVER PROC
    CALL CLEARSCR
    
    ; GAME OVER - renkli her harf
    MOV ah, 02h
    MOV bh, 0
    MOV dh, 8
    MOV dl, 32
    INT 10h
    
    MOV ah, 09h
    MOV al, 'G'
    MOV bl, 0Ch     ; Kýrmýzý
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'A'
    MOV bl, 0Ch
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'M'
    MOV bl, 0Ch
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'E'
    MOV bl, 0Ch
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'O'
    MOV bl, 0Eh     ; Sarý
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'V'
    MOV bl, 0Eh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'E'
    MOV bl, 0Eh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'R'
    MOV bl, 0Eh
    MOV cx, 1
    INT 10h
    
    ; Final skor - mavi
    MOV ah, 02h
    MOV dh, 12
    MOV dl, 28
    INT 10h
    
    MOV ah, 09h
    MOV al, 'F'
    MOV bl, 0Bh     ; Cyan
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'i'
    MOV bl, 0Bh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'n'
    MOV bl, 0Bh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'a'
    MOV bl, 0Bh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'l'
    MOV bl, 0Bh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'S'
    MOV bl, 0Bh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'k'
    MOV bl, 0Bh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'o'
    MOV bl, 0Bh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'r'
    MOV bl, 0Bh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, ':'
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    
    MOV ax, score
    CALL PRINT_NUMBER
    
    ; Seçenekler - yeþil
    MOV ah, 02h
    MOV dh, 16
    MOV dl, 20
    INT 10h
    
    MOV ah, 09h
    MOV al, 'R'
    MOV bl, 0Ah     ; Yeþil
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, ':'
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'T'
    MOV bl, 0Ah
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'e'
    MOV bl, 0Ah
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'k'
    MOV bl, 0Ah
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'r'
    MOV bl, 0Ah
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'a'
    MOV bl, 0Ah
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'r'
    MOV bl, 0Ah
    MOV cx, 1
    INT 10h
    
    ; Boþluk býrak
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    
    ; ESC seçeneði
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'E'
    MOV bl, 0Dh     ; Magenta
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'S'
    MOV bl, 0Dh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'C'
    MOV bl, 0Dh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, ':'
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 32      ; Boþluk
    MOV bl, 0Fh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'C'
    MOV bl, 0Dh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'i'
    MOV bl, 0Dh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'k'
    MOV bl, 0Dh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 'i'
    MOV bl, 0Dh
    MOV cx, 1
    INT 10h
    MOV ah, 02h
    INC dl
    INT 10h
    MOV ah, 09h
    MOV al, 's'
    MOV bl, 0Dh
    MOV cx, 1
    INT 10h
    
    RET
SHOW_GAME_OVER ENDP

END MAIN