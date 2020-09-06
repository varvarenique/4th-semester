.model small
.stack 100h

.data 
numberOfLine db 0   
shiftLine db 0
counter db 0
buffer db ?   
line dw 00A0h 

emptyLine db 13, 10, 'No parametrs in cmd$' 
success db 13, 10, 'Success!$' 
TooMany db 13, 10, 'Too many arguments. You should input name of one file$'  
notOpen db 13, 10, 'Can not open this file$'
fileName db 30 dup('$') 

up      equ 4800h
down    equ 5000h
esc     equ 011bh 

hex1 db ?    
hex2 db '  $'   
               

.code 
showString macro string  
    lea dx, string
    mov ah, 09h
    int 21h
endm
start:  
    mov ax, @data           
    mov ds, ax 
    call getNameOfFile     
    continue: 
    showString fileName
    showString success  
    call openFile 
    call showData     
    call closeFile
    
    exit:  
    mov ax,4c00h
    int 21h  
        
getNameOfFile proc  
    xor cx, cx
    mov cl, es:[80h]  ;this adress contains size of cmd 
    cmp cl, 0 
    je emptyCommandLine
    mov di, 82h       ;start of cmd
    lea si, filename
getSymbols:
    mov al, es:[di]    
    cmp al, 0Dh       ;compare with end  
    je continue  
    cmp al, ' '
    je TooManyArgs
    mov [si], al       
    inc di            
    inc si            
    jmp getSymbols          
    ret
    emptyCommandLine:
    showString emptyLine 
    jmp exit 
    TooManyArgs:
    showString TooMany
    jmp exit
endp  


openFile proc 
    mov dx, offset fileName
    mov ah, 3Dh
    mov al, 00h
    int 21h 
    jc fileNotOpen
    ret  
    fileNotOpen:
    showString notOpen
    jmp exit
endp
closeFile proc  
    mov ah, 3Eh
    int 21h
    ret
endp 

showData proc  
show:
    mov numberOfLine, 0 
    mov ah, 06h
    mov al, 00h              
    mov dl, 80h              
    mov dh, 25h 
    int 10h      
    
    mov ah,00                        
    mov al,03
    int 10h
    push 0B800h   
    pop es 
    
    mov bx, 0000h
checkScroll:  
    mov ah, shiftLine
    cmp ah, counter 
    jne count 
read_data: 
    call readData      
    mov  si, offset buffer

    cmp [si], 0Dh
    je Enter 
    cmp [si], 0Ah
    je read_data 
       
    mov  dl, [si] 
    and  dl, 00001111b
    call convert 
    mov  hex2, dl
     
    mov  dl, [si] 
    shr  dl, 4 
    call convert 
    mov  hex1, dl 
  
    lea di, hex1 
    mov cx, 3

writeText:
    mov dx, [di] 
    cmp bx, line
    je newLine  
    continueWrite:
    mov es:[bx],dx
    mov es:[bx+1], 0Fh 
    cmp bx, 4000
    je endShow 
    add bx, 2
    inc di 
loop writeText 
    jmp read_data
                                                           
endShow:
        
waitToEnter: 
    mov counter, 0
    mov ah, 00h
    int 16h
 
    cmp ax, esc
    je escExit
    cmp ax, up
    je upScroll
    cmp ax, down
    je DownScroll
    jmp waitToEnter  
escExit:
    mov ah, 06h
    mov al, 00h              
    mov dl, 80h              
    mov dh, 25h 
    int 10h   
    mov ah,00                        
    mov al,03
    int 10h
    jmp exit
upScroll:
    
    cmp shiftLine, 0
    je  waitToEnter 
 
    mov ah, 42h
    mov al, 00h
    mov cx, 00h
    mov dx, 00h
    mov bx, 0005h
    int 21h
    dec shiftLine 
    mov line, 00A0h
    jmp show
    showString success
    jmp waitToEnter
downScroll:
    mov ah, 42h
    mov al, 01h
    mov cx, 00h
    mov dx, 00h
    mov bx, 0005h
    int 21h
    mov ah, 06  
    mov al, 1
    mov dl, 80h              
    mov dh, 25h
    int 10h 
    mov bx, 3840
    dec numberOfLine 
    sub line, 160 
    inc shiftLine
    jmp read_data
    ret 
count:
    call readData  
    mov  si, offset buffer
    cmp [si], 0Dh
    je incCounter
    jmp checkScroll
    incCounter:
    inc counter
    jmp checkScroll
Enter:
    mov bx, line 
    add line, 160

    inc numberOfLine
    cmp numberOfLine, 25
    je endShow
    jmp read_data 
newLine:
    inc numberOfLine
    add line, 160  
    jmp continueWrite   
endp 
   

readData proc  
    push bx 
    push ax
    
    mov ax, 0005h
    mov bx, ax
    mov cx, 1
    mov dx,offset buffer
    mov ah, 3Fh
    int 21h  
    mov cx, ax
    cmp cx, 0
    je endShow
    pop ax
    pop bx
    ret
endp 

proc convert       
  cmp dl, 9
  jle digit 
  add dl, 55 
  jmp finish  
digit:  
  add dl, 48 
finish:
  ret
endp 
end start
