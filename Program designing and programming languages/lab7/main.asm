.model small                       
.stack 100h                     


.data  
           
EPB dw ?   
dw 0     
run_address dw 0

overlaySeg dw ?
pathMul db "mul.exe", 0 
pathDiv db "div.exe", 0
pathAdd db "add.exe", 0
pathSub db "sub.exe", 0 
emptyLine db 13, 10, 'No parametrs in cmd$'
enter db 13, 10, '$' 
tooMany db 13, 10, 'Too many arguments. You should input one string$'   
stringFromCmd db 80 dup('$') 
;stringFromCmd db '8/2/2$' 
stringOfResult db 13, 10, 'result: $'    
stringZero db 13, 10, 'You can not divide by zero!$' 
wrongParametrs db 13, 10, 'Wrong parametrs in comand line$'
overflowString db 13, 10, 'Too big numbers. Can not do your operation$'  
operations db 80 dup ('$')  
numbers dw 80 dup('$')
result db 80 dup('$')
bigPart db '63556$' 
negNum dw 0 
notNegNum dw 0
regSiBeg dw ?
regSiEnd dw ?
lastOperation db ? 
optimazeOn dw 0
.code  
              
showString macro string  
    lea dx, string
    mov ah, 09h
    int 21h
endm  
shiftNumbers proc   
    shiftN:
    add si, 2
    mov bx,[numbers+si+2]
    mov [numbers+si], bx
    cmp bx, '$'
    jne shiftN
    ret
endp  
shiftOperations proc   
    shiftO: 
    mov bl,[operations+si+1]
    mov [operations+si], bl
    inc si   
    cmp bl, '$'
    jne shiftO 
    ret
endp 
runOverlay proc    
   
    cmp [optimazeOn], 1 
    je optimaze
    mov ax, es;PSP      
    mov bx, zseg
    sub bx, ax
    mov ah, 4Ah
    int 21h       

    mov bx, 1000h;64Kb 
    mov ah, 48h        
    int 21h  

    mov EPB, ax  
    mov EPB+2, ax 
    mov overlaySeg, ax
    mov ax, ds   ;! 
          
    mov es, ax
    mov bx, offset EPB 
    mov ax, 4B03h 
    int 21h   
    
    Optimaze: 
     
    mov [regSiBeg], si
      
    mov ax,si 
    mov dl, 2
    mul dl
    mov si, ax   
    mov [regSiEnd], si 
    
   

    mov ax, [numbers+si]  
    mov cx, [numbers+si+2]
    mov [negNum], 0  
    
    call dword ptr run_address    
 
    
    js negative
    jo overflow 
 
    
    cont:
    
    xor dx, dx
    mov si, [regSiEnd]
    mov [numbers+si], ax  
  
   
    call shiftNumbers   
    
    mov si, [regSiBeg]
    
    call shiftOperations    
    
      
    
    mov si, [regSiBeg]
    ret 
    overflow:  
    
    showString overflowString
    jmp exit  
    negative: 
    jo overflow
    mov [negNum], 1
    jmp cont
endp
start:  
    mov ax, @data           
    mov ds, ax 
    call getString     
    continue: 
    showString stringFromCmd 
    call checkCmd 
    call setNumbers 
    call makeOperation     
    call show   
    
    exit:
    mov ax,4c00h
    int 21h 
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
checkCmd proc 
    lea si, stringFromCmd
    cmp [si], 30h
    jl checkFailed 
    cmp [si], 39h 
    jg checkFailed
    inc si
    startOfCheck:
    cmp [si], '$'
    je endOfCheck
    cmp [si], 30h
    jl checkOperations  
    cmp [si], 39h
    jg checkOperations 
    jmp checkPassed
    checkOperations:
    cmp [si], '+'
    je checkPassedOperation
    cmp [si], '-'
    je checkPassedOperation
    cmp [si], '*' 
    je checkPassedOperation
    cmp [si], '/'  
    je checkPassedDiv 
    checkFailed:
    showString wrongParametrs
    jmp exit 
    checkPassedOperation: 
    cmp [si+1], 30h
    jl checkFailed
    inc si
    jmp startOfCheck 
    checkPassed:
    inc si
    jmp startOfCheck  
    checkPassedDiv: 
    cmp [si+1], 30h
    je checkFailedZero 
    cmp [si+1], 30h
    jl checkFailed
    inc si
    jmp startOfCheck 
    checkFailedZero:
    showString stringZero
    jmp exit
    endOfCheck:  
    cmp [si-1], 30h
    jl checkFailed 
    cmp [si-1], 39h 
    jg checkFailed
    ret
endp    

makeOperation proc 
    xor si,si  
    
    find:
     
    cmp [operations+si], '$' 
    je othersOperations
    cmp [operations+si] , '*' 
    je makeMul
    cmp [operations+si] , '/' 
    je makeDiv
    inc si
    jmp find
    endMake:
ret
makeMul:
mov dx, offset pathMul 
cmp [lastOperation], '*'
je optimazeOnMul
mov [lastOperation], '*'   
contMul:
mov [optimazeOn], 0 
call runOverlay 
jmp find 
optimazeOnMul:
mov [optimazeOn], 1 
jmp contMul
makeDiv: 
mov dx, offset pathDiv  
cmp [lastOperation], '/'
je optimazeOnDiv   
mov [lastOperation], '/' 
mov [optimazeOn], 0  
contDiv:
call runOverlay 
jmp find
optimazeOnDiv:
mov [optimazeOn], 1 
jmp contDiv  
makeAdd: 
mov dx, offset pathAdd 
cmp [lastOperation], '+'
je optimazeOnAdd
mov [lastOperation], '+' 
mov [optimazeOn], 0
contAdd:
call runOverlay 
jmp makeItAll  
optimazeOnAdd:
mov [optimazeOn], 1 
jmp contAdd
makeSub:  
mov dx, offset pathSub
cmp [lastOperation], '-'
je optimazeOnSub
mov [lastOperation], '-'  
mov [optimazeOn], 0
contSub:
call runOverlay
jmp makeItAll 
optimazeOnSub:
mov [optimazeOn], 1 
jmp contSub
othersOperations: 

xor si, si
makeItAll:
   cmp [operations+si], '$' 
   je endMake
   cmp [operations+si], '+' 
   je makeAdd   
   cmp [operations+si], '-' 
   je makeSub
endp
setNumbers proc 
  xor di, di
  xor ax,ax 
  xor si, si
  convert:
        mov dl,[stringFromCmd+di]  
        cmp dl, '$'
        je ready   
        cmp dl, 30h
        jl setOperation
        cmp dl, 39h
        jg setOperation
        push dx
        
        mov dx, 10
        mul dx
        jo overflow 
        pop dx
         
        sub dx, 30h
        add ax, dx 
        inc di     
  loop convert   
    
  ready:  
  push ax 
  mov ax,si 
  mov dl, 2
  mul dl
  mov si, ax   
  pop ax 
  
  mov [numbers+si], ax 
  cmp ax, 0
  jl notNegNumberEnd
  endOfConvert:
  ret 
  notNegNumber:
  cmp [notNegNum], 1  
  je  changeNotNegNumber
  mov [notNegNum], 1  
  jmp continueConvert
  changeNotNegNumber:
  mov [notNegNum], 0  
  jmp continueConvert 
  notNegNumberEnd:
  cmp [notNegNum], 1  
  je  changeNotNegNumberEnd
  mov [notNegNum], 1  
  jmp endOfConvert
  changeNotNegNumberEnd:
  mov [notNegNum], 0  
  jmp endOfConvert

  setOperation: 
  mov dl,[stringFromCmd+di]
  mov [operations+si], dl 
  push si
  push ax 
  mov ax,si 
  mov dl, 2
  mul dl
  mov si, ax   
  pop ax   
  mov [numbers+si], ax  
  cmp ax, 0
  jl notNegNumber
  continueConvert: 
  pop si 
  inc si
  inc di
  xor ax, ax
  jmp convert
endp
   show proc 
    
    lea si, numbers 
    xor di, di   
    mov  ax, [si]  
    cmp [notNegNum], 0
    jne addBigPart
    cmp [negNum], 0
    jne negChange 
    
    loop1:
     
    mov bx, 10
    div bx
    add dl, 30h
    mov  [result+di], dl 
    inc di
    cmp ax, 0
    je showAll
    xor dl, dl
    jmp loop1 
   
    showAll:
    showString stringOfResult   
    cmp [negNum], 0
    jne addMinus
    showResult: 
    cmp di, 0
    je endShow
    dec di
    mov dl, [result+di]
    mov ah, 02h
    int 21h 
    jmp showResult
    endShow: 
 ret 
 addBigPart: 
    neg ax
    loop2:
    mov bx, 10
    div bx
    mov cl, [bigPart+di] 
    sub cl, 30h
    sub dl, cl 
    cmp dl, 0
    jg subTen
    returnBack:
    neg dx  
    
    add dl, 30h
    mov  [result+di], dl 
    inc di
    cmp di, 5
    je showAll
    xor dx, dx
    jmp loop2 
 subTen: 
    push di
    sub dx, 10
    startsubTen: 
    sub [bigPart+di+1], 1 
    cmp [bigPart+di+1], 30h
    jl another
    EndsubTen: 
    pop di
    jmp returnBack
    another:
    add [bigPart+di+1], 1 
    inc di
    jmp subTen
 addMinus:
    cmp [notNegNum], 0
    jne showResult 
     mov  [result+di], '-'  
     inc di
     jmp showResult
 negChange:
    
    neg ax 
    jmp loop1
endp
zseg segment
zseg ends 
end start  
