include "entorno.asm"

data segment 
    
  DEFINIR_Variables
                                                 
ends

stack segment
    
  DW 128 DUP(0)
  
ends

code segment                                

  DEFINIR_BorrarPantalla
  DEFINIR_ColocarCursor
  DEFINIR_Imprimir
  DEFINIR_LeerTecla
  DEFINIR_ImprimeCaracterColor
  DEFINIR_DibujarIntentos
  DEFINIR_DibujarCodigo
  DEFINIR_DibujarInstrucciones
  DEFINIR_DibujaEntorno    
  DEFINIR_MuestraAciertos
  DEFINIR_MuestraCombinacion
  DEFINIR_MuestraGana    
  
;E: "colum" y "dl" son parametros de entrada de este procedimiento
;S: pone un espacio en blanco en la posicion de la variable "combinacion" 
;   anterior a la actual 
  
  Borrar PROC
    push ax
    push di
    
    ;el proc. no da opcion a borrar el ultimo caracter a introducir
    
    sub colum, 2
    call ColocarCursor
    mov al, 31
    call ImprimeCaracterColor     
    dec dl;decremento de introducidos hasta ahora
    xor dh, dh
    mov di, dx 
    mov combinacion[di], 31;en la posicion anterior de combinacion se pone un espacio en blanco        
    add cx, 2;ya que se ejecutaria el bucle una vez menos y habria que equilibrarlo
    dec si
    
    pop di
    pop ax                
    ret             
  Borrar ENDP                        

;E: no hay parametros de entrada
;S: genera de forma aleatoria un numero que corresponde con las centesimas de 
;   segundo del reloj del equipo, el cual lo divide mod 5 para que asi coincida con una
;   posicion del vector "piezas_letra" y devolver el caracter en "ah"
  
  letraAleat PROC
    push bx 
    push cx
    push dx
        
    mov ah, 2Ch
    int 21h   
             
    xor dh, dh                      
    mov bl, 6    
    mov ax, dx                      
    div bl  
        
    xchg al, ah ;exchange
    xor ah, ah  ;ah almacena el modulo
    mov di, ax                  
    mov ah, piezas_letra[di] 
        
    pop dx
    pop cx
    pop bx
    ret
  letraAleat ENDP
 
;E: numero aleatorio generado por el proc. "letraAleat" y "npiezas" definida
;S: "Juegos" es inicializada con letras aleatorias
 
  genAleat PROC
    push ax 
    push bx  
    push cx;contador
    push dx        
    
    xor ch, ch
    mov cl, npiezas 
    xor bh, bh
     
    comprueba:
       
    call letraAleat                      
             
    call compruebaRepetidoAleat
    cmp dh, 0
    je comprueba
                      
    mov Juegos[si], ah
    
    salirComprueba:
    inc bh
    inc si
    
    loop comprueba
                           
    pop dx                    
    pop cx
    pop bx                    
    pop ax 
    ret
  genAleat ENDP       
  
;E: el registro "bh" indica el num de caracteres introducidos hasta ahora
;S: devuelve el registro "dh" a modo de bool que se encuentra a 1 en caso de que haya
;   un caracter igual al indicado por "di" y a 0 en caso contrario 
  
  compruebaRepetidoAleat PROC
    push cx
    push di                  
    xor ch, ch
    mov cl, bh;introds hasta ahora 
    xor dh, dh              
    xor di, di
        
        cmp bh, 0
        je primerCasoAleat
        
        bucleAleat:                                  
        cmp ah, Juegos[di] 
        je salirRepetidoAleat             
 
        inc di
        loop bucleAleat    
        
        primerCasoAleat:
    
        mov dh, 1          
    
    salirRepetidoAleat:
    pop di
    pop cx
    ret  
  compruebaRepetidoAleat ENDP
  
;E: no hay parametros de entrada
;S: crea el entorno e inicializa mediante un valor introducido por el usuario
;   las variables "indJuego" y "npiezas"                                            
                         
  entornoInicio PROC 
    push bx
    push dx
    
        call BorrarPantalla
         
        mov fila, F_INICIO1
        mov colum, C_INICIO1  
        call ColocarCursor
        lea dx, d_inicio1        
        call Imprimir 
         
        mov fila, F_INICIO2
        mov colum, C_INICIO2 
        call ColocarCursor  
        lea dx, d_inicio2        
        call Imprimir      
        
       noRango1:    
       
        call LeerTecla 
        cmp caracter, '3'
        jl noRango1
        cmp caracter, '6'
        jg noRango1  
        mov al, caracter 
        mov bl, 7;color blanco
        call ImprimeCaracterColor
        mov npiezas, al 
        sub npiezas, '0';convertir a decimal     
        
        mov fila, F_INICIO3
        mov colum, C_INICIO3 
        call ColocarCursor  
        lea dx, d_inicio3       
        call Imprimir
        
       noRango2:  
       
        call LeerTecla 
        cmp caracter, '0'
        jl noRango2
        cmp caracter, '4'
        jg noRango2 
        mov al, caracter
        mov bl, 7
        call ImprimeCaracterColor 
        mov indJuego, al 
        sub indJuego, '0'     
        mov indJuego, 0 ;por la ampliacion de "genAleat", ya que indJuego
                        ;esta siempre indicando al principio de la vble "Juegos"
        call genAleat
        
        mov intento, 0;0 intentos inicialmente
    
    pop bx
    pop dx  
    ret                  
  entornoInicio ENDP
  
;E: en "al" se almacena el caracter 
;S: devuelve 1 en "bh(booleano)" en caso de este el caracter introducido y
;   mueve a "bl" el color del caracter que le corresponde
  
  buscarEnPiezas_letra PROC   
    push ax
    push cx
    push di   
    
    mov al, caracter 
    xor di, di
    xor ch, ch
    mov cl, 6 
    
    buscaLetra:
             
    cmp piezas_letra[di], al
    je encuentraLetra 
    inc di
    
    loop buscaLetra 
    jmp finBuscaEnPiezas_letra
    
    encuentraLetra:
    
    mov bh, 1
    mov bl, piezas_color[di] 
    
    finBuscaEnPiezas_letra:
           
    pop di           
    pop cx                       
    pop ax
    ret
  buscarEnPiezas_letra ENDP   
  
;E: "al" almacena el caracter del vector combinacion que corresponda
;   y "dl" es el contador de caracteres 
;   introducidos hasta ahora
;S: registro "dh" booleano que devuelve 1 en caso de que el caracter este repetido
;   y mueve "caracter" al vector "combinacion" en caso de que no este repetido
 
  compruebaRepetido PROC
    push cx
    push di 
    xor ch, ch
    mov cl, dl 
    xor dh, dh               
    xor di, di
    
        bucleBuscaRepetidos:
        cmp di, cx
        je noRepetido
                                   
        cmp al, combinacion[di] 
        je estaRepetido
 
        inc di
        jmp bucleBuscaRepetidos
    
    noRepetido:
    
    mov dh, 1      
    mov combinacion[si], al    
    call buscarEnPiezas_letra 
    
    estaRepetido:;se sale por aqui tambien aunque no este repetido,  
                 ;la etiqueta es orientativa
    pop di
    pop cx
    ret  
  compruebaRepetido ENDP
  
;E: "indJuego" indica la posicion inicial de la variable "Juegos" y el vector
;   "combinacion" es el vector a comprobar
;S: modifica las variables "aciertosPos" y "aciertosColor", las cuales se usan en este mismo
;   procedimiento llamado a "MuestraAciertos" para imprimir en pantalla los aciertos
;   Tambien devuelve la variable "finJuego" a 1 en caso de que se hayan acertado todas
;   las posiciones
  
  compruebaCombinacion PROC
    push ax
    push cx
    push di;indice de "Juegos"
    push si;indice de "combinacion" 
    
    ;"di" vale la posicion inicial del vector indicado en "indJuego"
    mov al, indJuego
    mov bl, 6
    mul bl               
    mov bx,ax
    
    xor ch, ch
    mov cl, npiezas
    xor si, si             
    mov aciertosPos, 0
    mov aciertosColor, 0
    
    cmpPrimerBucle:             
    mov di, bx
    xor di, di   
    mov al, combinacion[si]     
            
    ;busca en "Juegos"
    push cx      
    push si
    xor ch, ch
    mov cl, npiezas
    add si, di;"di" es "mul" de "indJuegos(indice de Juegos)" y si indice de "combinacion" 

        cmpSecBucle:
        cmp si, di;comparo "Pos" al principio de cada iter. del segundo bucle
        je cmpPosSiCorrect
              
        cmpColor:      
        cmp al, Juegos[di]
        je aciertosColorCorrects      
        jmp cmpIteracion  
        
        cmpPosSiCorrect:
        cmp al, Juegos[di]
        je aciertosPosCorrects                
                       
        cmpIteracion:
        inc di                       
        loop cmpSecBucle  
        
    jmp salirCmpSecBucle  
        
    aciertosPosCorrects:
    inc aciertosPos
    jmp salirCmpSecBucle
        
    aciertosColorCorrects:
    inc aciertosColor
        
    salirCmpSecBucle:       
    pop si
    pop cx             
    
    inc si    
    loop cmpPrimerBucle 
    
    call MuestraAciertos
    
    mov al, aciertosPos
    cmp al, npiezas
    jne cmpSalirPrimerBucle
    mov finJuego, 1
    
    cmpSalirPrimerBucle:
    pop si
    pop di          
    pop cx 
    pop ax 
    ret
  compruebaCombinacion ENDP                  
  
;E: registro "bl" a modo de booleano que indica si el jugador a ganado
;   con un 1 y con un 0 en caso contrario    
;S: lleva a cabo toda las operaciones con los intentos del usuario 
  
  nuevoIntento PROC
    push ax 
    push cx       
    push dx   
    push di
    push si
        
    cmp finJuego, 1
    je terminar
        
    xor ax, ax
    cmp intento, 8
    jg superaIntentos                    
                            
        mov fila, F_INTENTO
        mov colum, C_INTENTO 
        call ColocarCursor           
              
        xor si, si              
        xor ch, ch
        mov cl, npiezas
                
        ;pone al intento en la fila que le corresponde para escribirlo
        push cx
        xor ch, ch
        mov cl, intento 
        cmp cl, 0
        je finIncFila
                    
        incFila:                 
        add fila, 2                  
        loop incFila                 
        finIncFila:
                    
        pop cx  
            
        call ColocarCursor    
        xor dl, dl;contador de los caracteres introducidos usado en el proc. "compruebaRepetido"
                                             
            intentoBucle:                                                   
                
            xor bh, bh;booleano que se encuentra a 1 en caso de que este en vector 
                      ;y a cero en caso contrario    
            call LeerTecla
            mov al, caracter
            
            ;comparaciones para borrar
            cmp dl, 0
            je noPuedeBorrarInic
            cmp al, 8
            je borra 
            
            noPuedeBorrarInic:
                
            call buscarEnPiezas_letra
            cmp bh, 1
            je almacVector
            jmp intentoBucle                            
                
            almacVector:     
                
            call compruebaRepetido
            cmp dh, 0
            je intentoBucle
                                      
            call ImprimeCaracterColor                                    
            inc si    
            inc dl
            add colum, 2
            call ColocarCursor 
            jmp loopIntento
                                
            borra:;ampliacion borrar             
            
            call Borrar
            
            loopIntento:                                                    
                                        
            loop intentoBucle
            
        call compruebaCombinacion
        mov ah, aciertosPos
        cmp ah, npiezas
        je boolGana
                      
        inc intento 
        call ColocarCursor 
            
        jmp finalIntento
            
        superaIntentos:
        
        mov finJuego, 1                      
        call MuestraCombinacion                      
        lea dx, msj_superaIntentos 
        mov fila, F_MENSAJES
        mov colum, C_MENSAJES   
        call ColocarCursor
        call Imprimir   
        call LeerTecla
        jmp finalIntento
     
        boolGana:
    
        mov bl, 1;booleano a true en caso de que haya ganado y a cero en caso contrario
            
    finalIntento:
                   
    pop si                   
    pop di
    pop dx                                            
    pop cx
    pop ax                
    ret
  nuevoIntento ENDP
  
;E: variables "indJuego" y "npiezas" generadas en "entornoInicio" como params. de entrada
;S: lleva a cabo todas las operaciones relacionadas con la estructura principal del juego
  
  entornoJuego PROC
    push ax
    push bx                          
    push dx
    push si 
    
    mov finJuego, 0;finJuego inicializado a 0 para saber si un usuario 
                   ;ha introducido la combinacion ganadora
      comienzoInicio: 
       
        call BorrarPantalla
         
        call DibujaEntorno 
        
      teclasAccion:      
        
        cmp finJuego, 1
        je terminar
        
        call LeerTecla
        cmp caracter, 'I'
        je nIntento
        cmp caracter, 'N'
        je nuevoJuego
        cmp caracter, 'S'
        je resolver    
        cmp caracter, 27
        je escape
        jmp teclasAccion   
        
       escape:
          
        jmp terminar
                                                
       nIntento:;donde la "n" de esta etiqueta se podria interpertar como
                ;el numero que indica en que intento se encuentra el juego
        xor bl, bl;booleano usado en la etiqueta "boolGana" del proc. "nuevoIntento"
        call nuevoIntento
        cmp bl, 1
        je haGanado                          
                          
        jmp teclasAccion
        
       nuevoJuego:
         
        call entornoInicio                         
        
        jmp comienzoInicio
        
       haGanado:    
        
        call MuestraGana
        call LeerTecla
        jmp terminar
                    
       resolver:    
       
        cmp finJuego, 1
        je terminar
            
        call MuestraCombinacion 
        
        mov fila, F_MENSAJES
        mov colum, C_MENSAJES
        call ColocarCursor
        lea dx, msj_teclaAccion
        call Imprimir                                 
        call LeerTecla                                  
                     
        mov finJuego, 1               
                     
       terminar:
            
    pop si 
    pop dx
    pop bx            
    pop ax           
    ret  
  entornoJuego ENDP
                                                               
                                                                                                                                                                      
start:
    mov ax, data
    mov ds, ax
                   
    call entornoInicio 
    
    call entornoJuego                       
           
    mov ax, 4C00h
    int 21h

ends

end start
