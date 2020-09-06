;overlay div
cseg segment para public 'code'
    overlay proc
        assume cs:cseg
          xor dx, dx
          div cx
           
          
        
        retf;far return from proc
        overlay endp
    cseg ends
end