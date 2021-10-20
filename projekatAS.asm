data segment
    pozX dw ? 
    pozY dw ?
    posX db ?
    posY db ? 
    adresa dw ?
    sirina dw ?
    visina dw ?  
    boja db ? 
    znak db 178 ;znak popunjenog pravougaonika
    ;Ekran dimenzija 80x25 bojimo crtajuci praovugaonik tih dimenzija
    ;Tjemena pravougaonika:
    pozX1 dw 0
    pozY1 dw 0
    pozX2 dw 79
    pozY2 dw 24  
    ;Korisnik ne nakon bojenja ekrana nalazi na poziciji (0,0)
    korX db 0
    korY db 0
    ;Znakove je potrebno obrisati- vratiti na prazne
    znak2 db 032 ;space (prazan znak)
    pravac db ?
    poruka db 'Greska! Mozete se kretati u jednom pravcu najvise tri puta$'
data ends 

stek segment stack
    dw 127 dup(?)
stek ends

code segment
macro initGraph
    push ax
    mov ax, 0B800h
    mov es, ax
    mov pozX, 0
    mov pozY, 0 
    mov adresa, 0
    mov sirina, 80 
    mov visina, 25
    mov boja, 7
    pop ax
endm 

macro setXY x y
    push ax
    push bx
    push dx
    mov pozX, x
    mov pozY, y
    mov ax, pozY
    mov bx, sirina
    shl bx, 1
    mul bx
    mov bx, pozX
    shl bx, 1
    add ax, bx
    mov adresa, ax 
    
    pop dx
    pop bx
    pop ax
endm
 
;postavljanje tekuce pozicije na poziciju (x,y)              
macro setXY2 x y
     push ax
     push dx
     mov posX, x
     mov posY, y
     
     mov dx, sirina
     shl dx, 1
     mov ax, dx
     mov ah, posY
     mul ah
     mov dl, posX  
     shl dl, 1
     add ax, dx
   
     mov adresa, ax
     pop dx
     pop ax
endm

macro setColor b
    mov boja, b
endm 

writeString macro str
    LOCAL petlja, kraj
    push ax
    push bx
    push si
    mov si, 0
    mov ah, boja
    mov bx, adresa
petlja:
    mov al, str[si]
    cmp al, '$'
    je kraj
    mov es:[bx], al
    mov es:[bx+1], ah
    add bx, 2
    add si, 1
    jmp petlja
kraj:
    mov ax, si
    add al, posX
    mov ah, posY
    setXY2 al ah
    pop si
    pop bx
    pop ax
endm

keyPress macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm 

readkey macro c
    push ax
    mov ah, 08
    int 21h
    mov c, al
    pop ax
endm

macro Write c
    push bx 
    push dx
    mov bx, adresa
    mov es:[bx], c
    mov dl, boja
    mov es:[bx+1], dl
    pop dx
    pop bx
endm 


krajPrograma macro
    mov ax, 4c02h
    int 21h
endm

        
obojiEkran macro x1 y1 x2 y2
     LOCAL petlja1, petlja2
     push ax
     push bx
     push cx
     push dx
     push si
     
     mov ax, x1
     mov bx, y1
     setXY ax bx
     mov bx, adresa
     
     mov al, 178  ;znak popunjenog praovugaonika
     mov ah, boja
     
     mov dx, x2
     sub dx, x1
     add dx, 1
     
     mov cx, y2
     sub cx, y1
     add cx, 1
     
petlja1:
     push cx
     mov cx, dx
     mov si, 0
     
petlja2:
     mov es:[bx+si], al
     mov es:[bx+si+1], ah
     add si, 2
     loop petlja2
     
     pop cx
     add bx, 160
     loop petlja1
     
     pop si
     pop dx
     pop cx
     pop bx
     pop ax
endm

macro clrScreen
    LOCAL petlja
    push bx
    push cx
    mov bx, 0
    mov cx, 2000
petlja:
    mov es: [bx], ' '
    mov es: [bx+1], 7
    add bx, 2
    loop petlja
    pop cx 
    pop bx
endm

writeLn proc
    push ax
    push bx
    mov bx, pozY
    add bx, 1
    mov ax, 0
    setXY ax, bx
    pop bx
    pop ax
    ret
writeLn endp 



strtoint proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov bp,sp
    mov bx, [bp+14]
    mov ax, 0
    mov cx, 0
    mov si, 10
petlja1: 
    mov cl, [bx]
    cmp cl, '$'
    je kraj1
    mul si
    sub cx, 48
    add ax, cx
    inc bx
    jmp petlja1
kraj1:
    mov bx, [bp+12]
    mov [bx], ax
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
strtoint endp
    
readString macro str
    LOCAL unos, nastavi, kraj
    push ax
    push bx
    push cx
    push dx
    push si
    mov si, 0
    mov bx, adresa
    mov cx, pozX
    mov dx, pozY
unos:
    readKey znak
    cmp znak, 13
    je kraj
    cmp znak, 8
    jne nastavi
    cmp si, 0
    je unos
    sub cx, 1
    setXY cx dx
    write ' '
    dec si
    jmp unos
nastavi:
    mov al, znak
    mov str[si], al
    write al
    add cx, 1
    setXY cx, dx
    inc si
    jmp unos
kraj:
    mov str[si], '$'
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
endm  
start:
    assume cs:code, ss:stek
    mov ax, data
    mov ds, ax
    
    initGraph
    setColor 5
    obojiEkran pozX1 pozY1 pozX2 pozY2   
    ;Korisnika postavljamo na poziciju (0,0)
    mov al, korX
    mov ah, korY
    setXY2 al, ah
    mov al, znak2 ;prazan znak-space
    write al
    petlja:
       readKey pravac
       cmp pravac, '2'
       je dole
       cmp pravac, '4'
       je lijevo
       cmp pravac, '6'
       je desno
       cmp pravac, '8' 
       je gore  
       
       jmp kraj     
          
       dole:             
       add korY, 1     
       jmp dalje             
       
       lijevo:             
       sub korX, 1
       jmp dalje
       
       desno:            
       add korX, 1
       jmp dalje
       
       gore:            
       sub korY, 1
       jmp dalje
          
       
       dalje:            
       mov al, korX    
       mov ah, korY
       setXY2 al ah
       mov bx, adresa    
       mov al, es:[bx]
       ;provjeravamo da li smo isti pravac unijeli tri puta 
       cmp korX, 3
       je kraj
       cmp korY, 3
       je kraj
       mov al, znak2      
       write al

     loop petlja
                
    kraj:
    setXY 1 23
    setColor 14
    writeString poruka
    keyPress
    krajPrograma
code ends
end start