.model small       
.stack 100h          
 
.data
offerToEnterString    db "Enter string: $"
offerToEnterWord    db 0Ah, 0Dh, "Enter word to find and delete word after that: $"
messageOfResult   db 0Ah, 0Dh, "Result string: $"
enter       db 0Ah, 0Dh, "$"

bufferString equ $
        maxLengthS db 200
        lengthS db 0
        string db 200 dup ('$')    
bufferWord equ $
        maxLengthW db 200
        lengthW db 0
        word db 200 dup ('$')

 
.code
start:
    mov ax, @data                           ; ax contains physical address of data segment
    mov ds, ax
    
    mov ah, 09h                             ; enter and reading string
    lea dx, offerToEnterString            
    int 21h
    lea dx, enter               
    int 21h  
    mov ah, 0ah
    lea dx, bufferString           
    int 21h
    mov ah, 09h
    lea dx, enter
    int 21h
    
    mov ah, 09h                             ; enter and reading word
    lea dx, offerToEnterWord            
    int 21h
    lea dx, enter
    int 21h                                                                                  
    mov ah, 0ah
    lea dx, bufferWord           
    int 21h
    mov ah, 09h
    lea dx, enter
    int 21h
    
    lea si, string                          ; si get address on beginning of string
    dec si                                  
    jmp searchOfword
     
searchOfword:
    inc si                                  
    cmp [si],' '                            
    je searchOfword                         ; if ' ' continue search
    lea di, word                            
    call compareSymbols                   
    jmp continueSearchSpace
     
continueSearchSpace:            
    inc si                                  ; search new word (after ' ')
    cmp [si], ' '                           
    je searchOfword    
    cmp [si], '$'                           
    je exit          
    jmp continueSearchSpace         
     
    
compareSymbols proc
    push si
    
    xor cx, cx                              ; cx=0                                           
    mov cl, lengthW                         ; length of word          
    
    compareWhileEqual:  
        mov ah, [si] 
        cmp ah, [di]
        jne NotEqual 
        inc si
        inc di   
    loop compareWhileEqual
                
CheckOfEnd:
    cmp [si], ' ' 
    je Equal
    jne NotEqual
                

Equal:
    call deleteWord
    call compareSymbols
    
NotEqual:
    pop si                     
    ret
    
compareSymbols endp        
 
deleteWord proc
    inc si                                  ; first symbol of next word
    mov ax,si                               
    dec si                                  ; ' ' before first symbol
     
skipSpace:                                  ; check of spaces before next word
    inc si  
    cmp [si], ' '
    je skipSpace 
searchOfend:
    inc si                                  ; second symbol (and others)
    cmp [si], ' '                           
    je countLength         
    cmp [si], '$'                           
    je countLength                             
    jmp searchOfEnd     
countLength:
    push si                                 ; si=' ' (after next word)
    sub si,ax                               ; ' '-'first symbol of next word' and get length
    mov bx,si                               ; bx=length 
    
    pop si                                  ; si= ' ' after next word 
       
move:

    lea ax, string     
    add al, lengthS                         ; end of string
    sub ax,si                               ; length of string after next word
    mov cx,ax         
    add cx,2                                 
 
    inc bx                                  ; word with ' '
    loopMove:
        inc si              
        mov ah,[si]                         ; ah = first symbol after next word
        sub si, bx                          ; begin of next word                       
       
        mov [si], ah 
        add si, bx
        
    loop loopMove  
    ret
deleteWord endp      

 
exit:  
    mov ah, 09h  
    lea dx, messageOfResult
    int 21h   
    lea dx, string   
    int 21h
    mov ax,4c00h
    int 21h
 
end start
