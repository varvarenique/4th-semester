.model tiny   
.code
org 100h  

start: 
    jmp main
oldTimerOffset dw ?
oldTimerSegment dw ?         
oldKeyboardOffset dw ?
oldKeyboardSegment dw ?
counter dw 0 
time dw 0  
element equ db 002h, 00Eh
symbol db 1 dup (element)   
currentScreenLine1 db 800 dup(?) 
currentScreenLine2 db 800 dup(?)
currentScreenLine3 db 800 dup(?)
currentScreenLine4 db 800 dup(?)
currentScreenLine5 db 800 dup(?) 
stringFromCmd db 80 dup('$')  
emptyLine db 13, 10, 'No parametrs in cmd$'
tooMany db 13, 10, 'Too many arguments. You should input one string$'   
wrongParametrs db 13, 10, 'Wrong parametrs in comand line$'

newKeyboardInterrupt proc far
    cli
    pusha
    
    push ds
    push dx
    
    push cs
    pop ds
    
    mov ax, time
    cmp counter, ax
    jl endOfKeyboardInterrupt
    push es

    push 0B800h
	pop es   
	
	mov di, 0000h
	mov cx, 800   
	lea si, currentScreenLine1  
	rep movsb 
	mov cx, 800   
	lea si, currentScreenLine2  
	rep movsb  
	mov cx, 800   
	lea si, currentScreenLine3  
	rep movsb 
	mov cx, 800   
	lea si, currentScreenLine4  
	rep movsb 
	mov cx, 800   
	lea si, currentScreenLine5  
	rep movsb   
	
	pop es    
	
    endOfKeyboardInterrupt:
    mov counter, 0
    pop dx
    pop ds
    
    popa 
    sti
    jmp dword ptr cs:[oldKeyboardOffset]  
endp
newTimerInterrupt proc far 
    cli
    pusha  
    
    push ds
    push dx
   
    push cs
    pop ds
     
    inc counter
    mov ax, time  
    cmp counter, ax
    jne endOfTimerInterrupt
    
    push es 
    
    push 0B800h
	pop es   
	
	mov bx, 0000h

	mov di, 0000h 
	mov si, 0000h        
    mov cx, 400
	   
    saveScreenLine1: 
    mov ax, es:[di]
    mov [currentScreenLine1+si], al    
    mov [currentScreenLine1+si+1], ah  
    add di, 2 
    add si, 2
    loop saveScreenLine1 
    mov si, 0000h  
    mov cx, 400
	saveScreenLine2: 
    mov ax, es:[di]
    mov [currentScreenLine2+si], al    
    mov [currentScreenLine2+si+1], ah  
    add di, 2 
    add si, 2
    loop saveScreenLine2 
    mov si, 0000h
    mov cx, 400
    saveScreenLine3: 
    mov ax, es:[di]
    mov [currentScreenLine3+si], al    
    mov [currentScreenLine3+si+1], ah  
    add di, 2   
    add si, 2
    loop saveScreenLine3  
    mov si, 0000h
    mov cx, 400
    saveScreenLine4: 
    mov ax, es:[di]
    mov [currentScreenLine4+si], al    
    mov [currentScreenLine4+si+1], ah  
    add di, 2
    add si, 2
    loop saveScreenLine4
    mov si, 0000h
    mov cx, 400 
    saveScreenLine5: 
    mov ax, es:[di]
    mov [currentScreenLine5+si], al    
    mov [currentScreenLine5+si+1], ah  
    add di, 2 
    add si, 2
    loop saveScreenLine5  
     
	mov di, 00h
	mov cx, 2000
    writeScreen: 
    push cx   
    mov cx,2 
    mov si,offset symbol
    rep movsb 
    pop cx
    loop writeScreen 
	pop es
    endOfTimerInterrupt:
     
      
    
    pop dx
    pop ds
    
    popa 
    sti
    jmp dword ptr cs:[oldTimerOffset]  
endp

main: 

    call getString
    call checkCmd
    call convert
    mov bx, 19;1092
    mul bx  
    mov time, ax
    
    mov ax, 3508h
    int 21h
    mov oldTimerOffset, bx
    mov oldTimerSegment, es
    
    mov ax, 2508h
    mov dx, offset newTimerInterrupt
    int 21h  
    
    mov ax, 3509h
    int 21h
    mov oldKeyboardOffset, bx
    mov oldKeyboardSegment, es
    
    mov ax, 2509h
    mov dx, offset newKeyboardInterrupt
    int 21h
    
    mov dx, offset main
    int 27h  
    
showString macro string  
    lea dx, string
    mov ah, 09h
    int 21h
endm 
exit proc  
    mov ax, 4C00h
    int 21h 
    ret
endp
convert  proc   
    push di 
    push dx
    xor ax, ax
    xor dx, dx
    mov di, 10
    lea si, stringFromCmd
convertOne:
    cmp [si], '$'
    je allConvert
    mul di
    mov dl, [si]
    sub dl, 30h
    add ax, dx
    inc si 
    loop convertOne  
    allConvert:
    pop dx 
    pop di
    ret
endp convert  

getString proc  
    xor cx, cx
    mov cl, es:[80h]  ;this adress contains size of cmd 
    cmp cl, 0 
    je emptyCommandLine
    mov di, 82h       ;start of cmd
    lea si, stringFromCmd     
    getSymbols:
    mov al, es:[di]    
    cmp al, 0Dh       ;compare with end  
    je endGet  
    cmp al, ' '
    je TooManyArgs
    mov [si], al       
    inc di            
    inc si            
    jmp getSymbols 
    endGet:         
    ret
    emptyCommandLine:
    showString emptyLine 
    call exit 
    TooManyArgs:
    showString TooMany 
    call exit
endp 
 
checkCmd proc 
    lea si, stringFromCmd 
    cmp [si], 30h
    je checkFailed
    startOfCheck:
    cmp [si], '$'
    je endOfCheck
    cmp [si], 30h
    jl checkFailed  
    cmp [si], 39h
    jg checkFailed 
    jmp checkPassed
    checkFailed:
    showString wrongParametrs
    call exit  
    checkPassed:
    inc si
    jmp startOfCheck  
    endOfCheck:  
    ret
endp 
end start
