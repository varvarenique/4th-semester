.model small
.stack 100h
.data
buffer db 4,0,4 dup (?)   
matrix dw 30, 0, 30 dup (0) 
arrayToShow 4 dup (?)  
column dw 3
row dw 2
offerToInputMatrix db 0Ah, 0Dh,'Input elements of your matrix (5 rows and 6 columns, only digits, you can input 3 symbols): $'   
offerToInputDigit db 0Ah, 0Dh, 'Input digit: $'
messageOfNew db 0Ah, 0Dh, 'New matrix: $'
errorMsg db 0Ah, 0Dh,'You can input only digits. Continue (last element was removed): $'
enter db 0Ah, 0Dh, '$' 
arrayOfDel dw 30, 0, 30 dup (0)

outputString macro string     
    mov ah, 09h
    lea dx, string
    int 21h
endm
  

.code
start: 
    mov ax, @data
    mov ds, ax
    outputString offerToInputMatrix
    inputMatrix:
    
   mov cx, row
    xor si,si 
    enteringRows: 
    push cx         
    mov cx, column     
    enteringColumns:  
    continueEntering:
    call inputDigit  
    
    push cx              
    mov cl, [buffer+1]   
          
    xor ax, ax 
    xor di, di 
    
    mov dl,[buffer+2]  
    cmp dl, 2Dh   
    je negative
 
    convert:
        mov dx, 10
        mul dx
        mov dl,[buffer+2+di]  
        
        cmp dl, 30h
        jl errorMessage
        cmp dl, 39h
        jg errorMessage  
        sub dl, 30h
        add al, dl
        inc di     
    loop convert 
          
    mov matrix[si], ax 
     
    mov cl, [buffer+1] 
    dec cx
    mov bx, 10
    mov ax, 1  
    cmp cx, 0
    je skip
    getNumber: 
    mul bx
    loop getNumber 
    skip:
    mov arrayOfDel[si], ax   
    continueAfterNegative: 
    add si, 2
    pop cx
    loop enteringColumns 
    pop cx               ;cx=rows
loop EnteringRows   
    
    call showMatrix
    call sort        
    outputString messageOfNew
    call showMatrix
    exit:
        mov ax,4c00h
        int 21h
    errorMessage:  
        outputString errorMsg  
        pop cx
        jmp continueEntering
    negative:
        inc di
        dec cx 
       
        convertNeg:
        mov dl, 10
        mul dl
        mov dl,[buffer+2+di] 
        cmp dl, 30h
        jl errorMessage
        cmp dl, 39h
        jg errorMessage  
        sub dl, 30h
        add al, dl
        inc di     
    loop convertNeg 
    neg ax     
    mov matrix[si], ax 
    
    mov cl, [buffer+1] 
    sub cx, 2
    mov bx, 10
    mov ax, 1  
    cmp cx, 0
    je skipNeg
    getNumberNeg: 
    mul bx
    loop getNumberNeg
    skipNeg: 
    mov arrayOfDel[si], ax
    jmp continueAfterNegative


inputDigit proc  
    
    outputString offerToInputDigit
    mov ah, 0Ah
    lea dx, buffer
    int 21h  
    mov ah, 02h
    mov dx, ' '
    int 21h   
 ret    
inputDigit endp 
                  
sort proc
  xor si,si
 
       mov cx, row  
       loop3: 
       push cx
       mov bx, 1
       mov cx,column
       dec cx
       loop1:
       push cx
       add si, 2
       mov di, si
       mov cx, bx
       loop2:
       sub di, 2
       mov dx, matrix[di]
       add di, 2    
       cmp dx, matrix[di] 
       jg change
       jmp continue
       change:
       push si
       mov si, di
       sub si,2
       mov ax, matrix[di]
       mov matrix[di], dx
       mov matrix[si], ax 
       mov ax, arrayOfDel[di] 
       mov dx, arrayOfDel[si]
       mov arrayOfDel[di], dx
       mov arrayOfDel[si], ax
       pop si
       continue:
       sub di, 2    
       loop loop2
       inc bx
       pop cx
       loop loop1
       pop cx
       add si, 2 
       loop loop3
  ret
sort endp       
              
showMatrix proc
    
       mov cx, row
       xor si,si
       showRows:
       mov ah, 09h
       lea dx, enter
       int 21h
       push cx
       mov cx, column 
       
       showColumns:
       
       
      
       mov ax, matrix[si] 
       push cx 
        
       mov bl, 10 
       lea di, arrayToShow  
       mov cx, 4
       mov dx, arrayOfDel[si] 
       push dx
       mov dx, 0
       cmp ax, dx
       jl showNegative 
       pop dx
       findNumber:
         cmp dl, 1h
         jle finishDiv
         div dl
         mov [di], al
         mov al, ah
         
         xor ah, ah
         inc di 
         push ax
         mov ax, dx
         div bl
         mov dx, ax
         pop ax
        
       loop findNumber
       finishDiv:
       mov [di], al
       dec cx
       mov bx, 4
       sub bx, cx
       mov cx, bx
       push si
       lea si, arrayToShow   
       cmp [si], 2Dh
       je incCx
       showAll:
       
       lodsb 
       
       mov dl, al
       add dl, 30h 
       mov ah, 02h
       int 21h   
       loop showAll 
       pop si
       mov dl, ' '
       int 21h 
       add si, 2 
       pop cx
       loop showColumns
       pop cx
       loop showRows
    ret   
    showNegative:
    mov [di], 2Dh
    inc di 
    neg ax 
    pop dx
    jmp findNumber  
    incCx:
    lodsb 
    mov dl, al
    mov ah, 02h
    int 21h 
    jmp showAll
showMatrix endp            
              
              
 
end start                                   
   
  
