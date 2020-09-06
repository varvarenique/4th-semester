;overlay sub
cseg segment para public 'code'
    overlay proc
        assume cs:cseg
        
          sub ax, cx     
          
        
        retf;far return from proc
        overlay endp
    cseg ends
end