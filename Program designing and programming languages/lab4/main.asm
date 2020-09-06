.model small

.stack 100h

.data
         
points db 0
newPoint db 6 dup(0)
videoStart   dw 0B800h 
endOfTheGame     db 'G',0Fh,'A',0Fh,'M',0Fh,'E',0fh,' ',0Fh,'O',0Fh, 'V',0Fh ,'E',0Fh,'R',0Fh                          
score        db 's',0Fh,'c',0Fh,'o',0Fh,'r',0fh,'e',0Fh,':',0Fh, ' ',0Fh ,' ',0Fh,'0',0Fh  
level        db 'l',0Fh,'e',0Fh,'v',0Fh,'e',0fh,'l',0Fh,':',0Fh, ' ',0Fh ,' ',0Fh,'1',0Fh   
levelLocation dw 0064h 
levelValue db 1

speed dw 30000

scoreSize dw 0012h              
pacmanElement           equ db 002h, 00Eh 
pacmanLocation     dw 0EFAh   
enemyElement       equ db 001h,00Dh 
appleElement       equ db 06Fh, 004h 

firstEnemyLocation dw 0142h
secondEnemyLocation dw 0E98h
typeOfMovingFirst db 0 
typeOfMovingSecond db 1 

mazeElement equ db 000h, 1Fh
maze db 1 dup (mazeElement)  
pacman db 1 dup (pacmanElement)
apple db 1 dup (appleElement)
enemy db 1 dup (enemyElement) 

left    equ 4b00h  
right   equ 4d00h  
up      equ 4800h
down    equ 5000h


.code
space macro 
    mov cx, 1
    call solidMaze
    add di, 156
    mov cx, 1
    call solidMaze  
endm
firstTypeOfLine macro    
    mov cx, 1
    call solidMaze
    add di, 8
    mov cx, 1
    call solidMaze
    add di, 2
    mov cx, 4
    call solidMaze
    add di, 2
    mov cx, 10
    call solidMaze 
    add di, 2
    mov cx, 5
    call solidMaze
    add di, 2
    mov cx, 8
    call solidMaze
    add di, 2
    mov cx, 2
    call solidMaze
    add di, 2
    mov cx, 10
    call solidMaze
    add di, 2
    mov cx, 6
    call solidMaze
    add di,2
    mov cx, 10
    call solidMaze
    add di, 2
    mov cx, 10 
    call solidMaze  
endm 
secondTypeOfLine macro
    mov cx, 1
    call solidMaze
    add di, 2
    mov cx, 29
    call solidMaze   
    add di, 2
    mov cx, 20
    call solidMaze
    add di, 2
    mov cx, 25
    call solidMaze 
    add di, 2
    mov cx, 1
    call solidMaze
endm  
thirdTypeOfLine macro
    mov cx, 10
    call solidMaze
    add di, 2
    mov cx, 35
    call solidMaze
    add di, 2
    mov cx, 20
    call solidMaze
    add di, 2
    mov cx, 12
    call solidMaze 
endm 
fourthTypeOfLine macro
    mov cx, 40
    call solidMaze
    add di, 2
    mov cx, 14
    call solidMaze
    add di, 2
    mov cx, 24
    call solidMaze
endm
cleanScreen macro
   
    
   ;mov ah, 06h
   ;mov al, 00h                           
   ;mov dl, 80h              
   ;mov dh, 25h                
   
   ;int 10h 
   xor bx, bx 
   mov ah, 06h
   mov al, 00h              
   mov dl, 80h              
   mov dh, 25h 
   int 10h   
   mov ah,1               
   mov cx, 2000h           
   int 10h
     
endm
main:
	 
	mov ax,@data
    mov ds, ax
    mov ah,00                        
    mov al,03
    int 10h  
    push 0B800h
    pop es
	cleanScreen

	call drawScore 
	call drawLevel           
    call drawMaze
    call drawPacman
    call drawApple  
    call drawEnemy
    start: 
    xor cx, cx 
    mov cx, speed         
  waitSymbol:  
    push cx
   enemyWaiting:
    mov ah, 01h           
    int 16h
    jnz moveAll 
    loop enemyWaiting
    jmp EnemyStep
    moveAll:
    call movePacman 
    EnemyStep:
    call moveEnemy 
    mov cx, speed
    pop cx
    jmp waitSymbol 
       
    mov ax, 4C00h
    int 21h    
movePacman proc            
        mov ah, 00h           
        int 16h 
        cmp ax, RIGHT
        je  goRight
        cmp ax, LEFT
        je  goLeft
        cmp ax, up
        je goUp
        cmp ax, down
        je goDown
        ret
     goUp:         
        mov bx, [pacmanLocation] 
        sub bx, 160  
        cmp es:[bx+1], 01Fh              
        je movePacman
        cmp es:[bx+1], 004h  
        je appleMarkUp
        jmp continueUp 
        appleMarkUp:
        call drawApple
        call changeScore
        continueUp:
        add bx, 160   
        mov es:[bx],20h
        mov es:[bx+1],0h 
        sub bx, 160  
        mov es:[bx],002h
        mov es:[bx+1], 00Eh         
        mov [pacmanLocation], bx
        jmp endOfMovingPacman
     goDown:
        mov bx, [pacmanLocation]       
        add bx, 160   
        cmp es:[bx+1], 01Fh              
        je movePacman 
        cmp es:[bx+1], 004h  
        je  appleMarkDown
        jmp continueDown 
        appleMarkDown:
        call drawApple
        call changeScore
        continueDown:
        sub bx, 160 
        mov es:[bx],20h            
        mov es:[bx+1],0h 
        add bx, 160            
        mov es:[bx],002h       
        mov es:[bx+1], 00Eh 
        mov [pacmanLocation], bx      
        jmp endOfMovingPacman
     goRight:                      
        mov bx, [pacmanLocation]       
        add bx, 2      
        cmp es:[bx+1], 01Fh              
        je movePacman
        cmp es:[bx+1], 004h  
        je  appleMarkRigth
        jmp continueRigth 
        appleMarkRigth:
        call drawApple 
        call changeScore
        continueRigth:
        sub bx, 2   
        mov es:[bx],20h            
        mov es:[bx+1],0h 
        add bx, 2        
        mov es:[bx],002h       
        mov es:[bx+1], 00Eh 
        mov [pacmanLocation], bx      
        jmp endOfMovingPacman
     goLeft:                      
        mov bx, [pacmanLocation] 
        sub bx, 2
        cmp es:[bx+1], 01Fh              
        je movePacman 
        cmp es:[bx+1], 004h  
        je appleMarkLeft
        jmp continueLeft 
        appleMarkLeft:
        call drawApple  
        call changeScore
        continueLeft:       
        add bx, 2       
        mov es:[bx],20h
        mov es:[bx+1],0h 
        sub bx, 2          
        mov es:[bx],002h
        mov es:[bx+1], 00Eh 
        mov [pacmanLocation], bx
        jmp endOfMovingPacman 
     endOfMovingPacman:  
        ret
endp                      
drawPacman proc 
    
    mov di, [pacmanLocation]  
    mov si, offset pacman 
    mov cx, 2 
    cld
    movsb
    ret
endp
drawMaze proc 
    mov di, 00A0h    
    mov cx, 80
    call solidMaze 
    space  
    firstTypeOfLine
    space  
    secondTypeOfLine
    secondTypeOfLine 
    space 
    thirdTypeOfLine
    thirdTypeOfLine 
    space
    fourthTypeOfLine 
    space   
    firstTypeOfLine
    firstTypeOfLine 
    space
    fourthTypeOfLine
    fourthTypeOfLine
    fourthTypeOfLine
    space
    secondTypeOfLine
    space
    firstTypeOfLine
    space
    mov cx, 80
    call solidMaze
    ret
endp 
solidMaze proc
drawLine:
    mov si, offset maze
    push cx
    mov cx, 2 
    cld
    rep movsb     
    pop cx
loop drawLine 
ret
endp         
drawScore proc
    mov di, 00h
    lea si, score
    mov cx, 18
    rep movsb
    ret
endp
drawApple proc
    mov di, [pacmanLocation]
    sub di, 400 
    cmp di, 0140h
    jle drawDown  
    compareWithWall:
    cmp es:[di+1], 01Fh
    je subtract
    mov si,offset apple
    mov cx, 2
    rep movsb  
    ret 
endp
    drawDown:
    add di, 3200
    jmp compareWithWall 
    subtract:
    sub di, 2
    jmp compareWithWall    
changeScore proc 
    push bx
    push di
    push si
    push ax
    push cx
    push es  
    xor ax, ax
    xor bx, bx
    mov di, offset newPoint
    mov al, points
    inc al  
    xor cx, cx
    mov points, al  
    mov bl, 10
    convert:
    inc cx  
    cmp al, 9h 
    jle endOfConvert
    div bl
    add al, 30h 
    mov [di], al
    mov [di+1], 0Fh
    add di, 2 
    mov al, ah
    jmp convert 
    endOfConvert:
    add al, 30h     
    mov [di], al
    mov [di+1], 0Fh   
    mov di, offset newPoint
    mov si, offset score 
    add cx, cx
    mov bx, scoreSize
    sub bx, cx
    add si, bx
    writeScore: 
        mov bl, [di]
        mov [si], bl
        inc di
        inc si
    loop writeScore
    mov cx, 18
    mov di, 0000h
    mov si, offset score
    rep movsb 
    cmp al, 33h
    je levelUp 
    cmp al, 39h
    je levelUp
    endOfthisPart:
    pop es
    pop cx
    pop ax
    pop si
    pop di
    pop bx
    ret 
    levelUp: 
    call changeLevel
    mov bx, speed
    sub bx, 10000
    mov speed, bx
    jmp endOfthisPart
endp  
changeLevel proc 
    push bx
    push di
    push si
    push ax
    push cx
    push es  
    xor ax, ax
    xor bx, bx
    mov di, offset newPoint
    mov al, levelValue
    inc al  
    xor cx, cx
    mov levelValue, al  
    mov bl, 10
    convertLevel:
    inc cx
    add al, 30h     
    mov [di], al
    mov [di+1], 0Fh   
    mov di, offset newPoint
    mov si, offset level 
    add cx, cx
    mov bx, scoreSize
    sub bx, cx
    add si, bx
    writeLevel: 
        mov bl, [di]
        mov [si], bl
        inc di
        inc si
    loop writeLevel
    mov cx, 18
    mov di, levelLocation
    mov si, offset level
    rep movsb 
    pop es
    pop cx
    pop ax
    pop si
    pop di
    pop bx
    ret 
endp 
drawEnemy proc  
    mov di, [firstEnemyLocation]
    mov si, offset enemy 
    mov cx, 2 
    rep movsb 
    mov si, offset enemy
    mov di, [secondEnemyLocation]
    mov cx, 2
    rep movsb 
    
    ret
endp 
moveEnemy proc 
enemyMoving:
    push bx
    mov bl, typeOfMovingFirst
    cmp bl, 0
    je movingDown
    cmp bl, 1
    je movingRight
    cmp bl, 2
    je movingUp
    cmp bl, 3
    je movingLeft  
    movingDown:
        mov bx, [firstEnemyLocation]       
        add bx, 160 
        mov [firstEnemyLocation], bx  
        cmp es:[bx+1], 004h  
        je  moveWithAppleDown 
        cmp es:[bx+1], 00Eh  
        je GameOver
        jmp continueMovingDown
        moveWithAppleDown:
        sub bx, 160 
        mov es:[bx],06Fh            
        mov es:[bx+1],004h 
        jmp contDown
        continueMovingDown:
        sub bx, 160 
        mov es:[bx],20h            
        mov es:[bx+1],0h 
        contDown:
        add bx, 160            
        mov es:[bx],001h       
        mov es:[bx+1], 00Dh 
        cmp bx, 0462h
        je markOfChageToOneFirst
        cmp bx, 0654h
        je markOfChageToOneFirst 
        jmp secondEnemyMoving
   MovingUp:         
        mov bx, [firstEnemyLocation] 
        sub bx, 160  
        mov [firstEnemyLocation], bx
        cmp es:[bx+1], 004h  
        je  moveWithAppleUp
        cmp es:[bx+1], 00Eh  
        je GameOver
        jmp continueMovingUp 
        moveWithAppleUp:
        add bx, 160   
        mov es:[bx],06Fh
        mov es:[bx+1],004h 
        jmp contUp
        continueMovingUp:
        add bx, 160   
        mov es:[bx],20h
        mov es:[bx+1],0h
        contUp: 
        sub bx, 160  
        mov es:[bx],001h
        mov es:[bx+1], 00Dh         
        cmp bx, 04E6h  
        je markOfChageToTreeFirst
        cmp bx, 02E8h
        je markOfChageToTreeFirst
        cmp bx, 01A6h
        je markOfChageToTreeFirst
        jmp secondEnemyMoving
   MovingRight:                      
        mov bx, [firstEnemyLocation]     
        add bx, 2     
        mov [firstEnemyLocation], bx 
        cmp es:[bx+1], 004h  
        je  moveWithAppleRight 
        cmp es:[bx+1], 00Eh  
        je GameOver  
        jmp continueMovingRight   
        moveWithAppleRight:
        sub bx, 2   
        mov es:[bx],06Fh            
        mov es:[bx+1],004h
        jmp contRight
        continueMovingRight:        
        sub bx, 2   
        mov es:[bx],20h            
        mov es:[bx+1],0h  
        contRight:
        add bx, 2        
        mov es:[bx],001h       
        mov es:[bx+1], 00Dh 
        cmp bx, 0474h
        je markOfChageToZeroFirst
        cmp bx, 06C6h
        je markOfChageToTwoFirst
        jmp secondEnemyMoving 
    MovingLeft:                     
        mov bx, [firstEnemyLocation] 
        sub bx, 2
        mov [firstEnemyLocation], bx 
        cmp es:[bx+1], 004h  
        je  moveWithAppleLeft
        cmp es:[bx+1], 00Eh  
        je GameOver  
        jmp continueMovingLeft
        moveWithAppleLeft:
        add bx, 2       
        mov es:[bx],06Fh
        mov es:[bx+1],004h 
        jmp contLeft
        continueMovingLeft:   
        add bx, 2       
        mov es:[bx],20h
        mov es:[bx+1],0h
        contLeft: 
        sub bx, 2          
        mov es:[bx],001h
        mov es:[bx+1], 00Dh 
        cmp bx, 04C8h
        je markOfChageToTwoFirst
        cmp bx, 02E6h
        je markOfChageToTwoFirst
        cmp bx, 0142h
        je markOfChageToZeroFirst
        jmp secondEnemyMoving 
    secondEnemyMoving:
        mov bl, typeOfMovingSecond
        cmp bl, 0
        je movingDownSecond
        cmp bl, 1
        je movingRightSecond
        cmp bl, 2
        je movingUpSecond
        cmp bl, 3
        je movingLeftSecond  
    movingDownSecond:
        mov bx, [secondEnemyLocation]       
        add bx, 160 
        mov [secondEnemyLocation], bx  
        cmp es:[bx+1], 004h  
        je  moveWithAppleDownSecond 
        cmp es:[bx+1], 00Eh  
        je GameOver
        jmp continueMovingDownSecond
        moveWithAppleDownSecond:
        sub bx, 160 
        mov es:[bx],06Fh            
        mov es:[bx+1],004h 
        jmp contDownSecond
        continueMovingDownSecond:
        sub bx, 160 
        mov es:[bx],20h            
        mov es:[bx+1],0h 
        contDownSecond:
        add bx, 160            
        mov es:[bx],001h       
        mov es:[bx+1], 00Dh 
        cmp bx, 0C30h
        je markOfChageToTreeSecond
        cmp bx, 0D5Eh
        je markOfChageToTreeSecond 
        cmp bx, 0E62h
        je markOfChageToOneSecond
        jmp endOfMoving
   movingUpSecond:         
        mov bx, [secondEnemyLocation] 
        sub bx, 160  
        mov [secondEnemyLocation], bx
        cmp es:[bx+1], 004h  
        je  moveWithAppleUpSecond
        cmp es:[bx+1], 00Eh  
        je GameOver
        jmp continueMovingUpSecond 
        moveWithAppleUpSecond:
        add bx, 160   
        mov es:[bx],06Fh
        mov es:[bx+1],004h 
        jmp contUpSecond
        continueMovingUpSecond:
        add bx, 160   
        mov es:[bx],20h
        mov es:[bx+1],0h
        contUpSecond: 
        sub bx, 160  
        mov es:[bx],001h
        mov es:[bx+1], 00Dh         
        cmp bx, 0DAAh  
        je markOfChageToTreeSecond
        cmp bx, 0C48h
        je markOfChageToOneSecond
        cmp bx, 09CEh
        je markOfChageToTreeSecond
        jmp endOfMoving
   MovingRightSecond:                      
        mov bx, [secondEnemyLocation]     
        add bx, 2     
        mov [secondEnemyLocation], bx 
        cmp es:[bx+1], 004h  
        je  moveWithAppleRightSecond 
        cmp es:[bx+1], 00Eh  
        je GameOver  
        jmp continueMovingRightSecond   
        moveWithAppleRightSecond:
        sub bx, 2   
        mov es:[bx],06Fh            
        mov es:[bx+1],004h
        jmp contRight
        continueMovingRightSecond:        
        sub bx, 2   
        mov es:[bx],20h            
        mov es:[bx+1],0h  
        contRightSecond:
        add bx, 2        
        mov es:[bx],001h       
        mov es:[bx+1], 00Dh 
        cmp bx, 0EEAh
        je markOfChageToTwoSecond
        cmp bx, 0C4Eh
        je markOfChageToTwoSecond   
        jmp endOfMoving 
    MovingLeftSecond:                     
        mov bx, [secondEnemyLocation] 
        sub bx, 2
        mov [secondEnemyLocation], bx 
        cmp es:[bx+1], 004h  
        je  moveWithAppleLeftSecond
        cmp es:[bx+1], 00Eh  
        je GameOver  
        jmp continueMovingLeftSecond
        moveWithAppleLeftSecond:
        add bx, 2       
        mov es:[bx],06Fh
        mov es:[bx+1],004h 
        jmp contLeftSecond
        continueMovingLeftSecond:   
        add bx, 2       
        mov es:[bx],20h
        mov es:[bx+1],0h
        contLeftSecond: 
        sub bx, 2          
        mov es:[bx],001h
        mov es:[bx+1], 00Dh 
        cmp bx, 0D88h
        je markOfChageToTwoSecond
        cmp bx, 09B0h
        je markOfChageToZeroSecond
        cmp bx, 0C1Eh
        je markOfChageToZeroSecond 
        cmp bx, 0D22h
        je markOfChageToZeroSecond
        jmp endOfMoving 
        endOfMoving:
        pop bx
    ret 
    markOfChageToOneFirst:
        mov bl, typeOfMovingFirst 
        mov bl, 1
        mov typeOfMovingFirst, bl
        jmp secondEnemyMoving
    markOfChageToTwoFirst: 
        mov bl, typeOfMovingFirst 
        mov bl, 2
        mov typeOfMovingFirst, bl
        jmp secondEnemyMoving
    markOfChageToTreeFirst: 
        mov bl, typeOfMovingFirst 
        mov bl, 3
        mov typeOfMovingFirst, bl
        jmp secondEnemyMoving
    markOfChageToZeroFirst:
        mov bl, typeOfMovingFirst 
        mov bl, 0
        mov typeOfMovingFirst, bl
        jmp secondEnemyMoving
    markOfChageToOneSecond:
        mov bl, typeOfMovingSecond 
        mov bl, 1
        mov typeOfMovingSecond, bl
        jmp endOfMoving
    markOfChageToTwoSecond: 
        mov bl, typeOfMovingSecond 
        mov bl, 2
        mov typeOfMovingSecond, bl
        jmp endOfMoving
    markOfChageToTreeSecond:
        mov bl, typeOfMovingSecond 
        mov bl, 3
        mov typeOfMovingSecond, bl
        jmp endOfMoving
    markOfChageToZeroSecond: 
        mov bl, typeOfMovingSecond 
        mov bl, 0
        mov typeOfMovingSecond, bl
        jmp endOfMoving
endp
drawLevel proc  
    mov di, levelLocation
    mov si, offset level
    mov cx, 18
    rep movsb
    ret
endp 
    GameOver: 
        cleanScreen
        mov di, 00C8h
        mov si, offset endOfTheGame
        mov cx, 18
        rep movsb  
        mov di, 0208h
        mov si, offset score
        mov cx, 18
        rep movsb 
        mov ax, 4C00h
        int 21h 
        int 10h   
        mov ah,1               
        mov cx, 0100h           
        int 10h
        
end main                  
