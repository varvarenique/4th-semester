;overlay mul
cseg segment para public 'code'
    overlay proc
        assume cs:cseg
        
          mul cx    
          
        
        retf;far return from proc
        overlay endp
    cseg ends
end