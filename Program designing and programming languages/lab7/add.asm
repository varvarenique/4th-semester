;overlay add
cseg segment para public 'code'
    overlay proc
        assume cs:cseg
         
          add ax, cx     
          
        
        retf;far return from proc
        overlay endp
    cseg ends
end