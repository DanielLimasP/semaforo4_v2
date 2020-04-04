list p=16f874
	include<p16F874.inc>
;Directivas del compilador
	__CONFIG _XT_OSC & _WDT_OFF ;RC OSC 	---> Oscilador del reloj: XT = cristal de cuarzo 
								;WDT 		---> Watchdog timer
								;PWR 		---> Power Reset. Temporal
								;CP 		---> Code protect

secuencia1	equ		h'1F'			;memoria de datos. En la posición hexa '1f' colocar 'secuencia1'
secuencia2	equ 	h'1E'			;memoria de datos. En la posición hexa '1e' colocar 'secuencia2'
secuencia3	equ		h'1D'
secuencia4	equ		h'1C'

cont1		equ		h'3F'			;Variables de contador en las localidades de memoria 3F - 3C
cont2		equ		h'3E'
cont3		equ		h'3D'
cont4		equ		h'3C'
									;Variables contadoras de los segundos
cont25		equ		h'4E'
cont5		equ		h'4D'
	
		org		0

		;Terminan las directivas del compilador
		;Configurar entradas y salidas. Inicialización del sistema.

		clrf	PORTB
		bsf		STATUS,RP0
		movlw	b'00000000'
		movwf	TRISB
		bcf		STATUS,RP0

		;Terminamos de configurar los puertos
		;Secuencia
		;Rojo - Amarillo - Verde  |	Rojo - Amarillo - Verde
		;1		0			0		0		0		1			-->	25s
		;1		0			0		0		1		0			--> 5s
		;0		0			1		1		0		0			--> 25s
		;0		1			0		1		0		0			--> 5s

		;Incialización de variables
		;movlw	b'00100001' 	Mover a W la primera secuencia del semáforo.
		;movwf 	secuencia1		Mover la secuencia 1 a la variable sec1. Se hará lo mismo con las demás secuencias.
		;movlw	b'00100010' 	
		;movwf 	secuencia2
		;movlw	b'00001100' 	
		;movwf 	secuencia3
		;movlw	b'00010100' 	
		;movwf 	secuencia4

	;------------->Nota 1: Vea que el PIC está trabajando con un oscilador de 20MHz. Teniendo en cuenta que un ciclo de 
				   ;máquina equivale a 4 ciclos de reloj, tenemos que le tomaría 1 microsegundo ejecutar 5 instrucciones
				   ;por lo cual hay que retrasar al PIC de manera que ejecute 100x100x500 instrucciones en un segundo.
		
	;------------->;Nota 2: Dado que es muy lento el proceso de prueba para este programa, los tiempos tienen que ser modificados ligeramente,
				   ;de manera que los contadores de los segundos tengan su valor original (5 y 25 en lugar de 125 y 25) y los contadores
				   ;de los loops trabajen con un 1 en lugar de 100. De esta manera se puede ver cómo funcionaría el PIC en el mundo real.  
	
	;------------->;Nota 3: Esta implementación es por fuerza bruta. No es la manera más elegante de hacerlo, pero funciona y está fácil de entender.

		movlw	d'25'	;Iniciarlos con 5 veces el valor de los segundos que requiramos debido a la frecuencia del oscilador
		movwf	cont25	;En el caso del contador de 25 segundos, el valor será de 125. Debido a que es la versión de prueba los inicializamos con su valor verdadero
		movlw	d'5'	;En el caso del contador de 25 segundos, el valor será de 25
		movwf	cont5
	;<--------------------> Comienza el programa con el primer loop
c1: 	movlw	b'00100001'		;Al comenzar el primer loop, ponemos la primera secuencia en el PORTB
		movwf	PORTB
		movlw	d'25'			
		movwf	cont25
		movlw	d'5'
		movwf	cont5
loopb:	movlw 	d'1'			;Es importante mencionar que si queremos la versión que correrá sobre el PIC, es necesario
		movwf	cont1			;cambiar este valor 1 por un 100 debido a la frecuencia del oscilador que maneja el PIC.
loopc: 	movwf 	cont2
loopd:	movwf	cont3
loope:	decfsz	cont3,f
		goto	loope
		decfsz	cont2,f
		goto	loopd
		decfsz	cont1,f
		goto	loopc
		
		decfsz	cont25			;Hasta este punto, se supone que cada vez que se ejecute esta instrucción, habrá pasado un segundo entero
		goto 	loopb			;Al descontar un segundo, saltamos de nuevo al loopb para contar otro segundo
		goto	c2				;En este punto tenemos que mandar el ciclo a una nueva etiqueta que empiece a contar los 5 segundos 
	;<------------------->	Comienza el segundo loop
c2: 	movlw	b'00100010'		;Comenzamos el segundo loop y metemos el siguiente valor de la secuencia en el PORTB
		movwf	PORTB
lb2:	movlw 	d'1'			;Luego volvemos a inicializar los contadores
		movwf	cont1
lc2: 	movwf 	cont2
ld2:	movwf	cont3
le2:	decfsz	cont3,f
		goto	le2
		decfsz	cont2,f
		goto	ld2
		decfsz	cont1,f
		goto	lc2
		decfsz	cont5			;Hasta este punto, se supone que cada vez que se ejecute esta instrucción, habrá pasado un segundo entero
		goto 	lb2				;Al descontar un segundo, saltamos de nuevo al lb2 para contar otro segundo
		goto	c3				;En este punto tenemos que mandar el ciclo a una nueva etiqueta que empiece a contar los 25 segundos de nuevo
	;<---------------------> Comienza el tercer loop		
c3: 	movlw	b'00001100'		;por lo cual ponemos el valor de la secuencia 3 en el PORTB
		movwf	PORTB
	;En este punto tenemos que reiniciar los contadores de 5 y 25 segundos
		movlw	d'25'			
		movwf	cont25
		movlw	d'5'
		movwf	cont5
lb3:	movlw 	d'1'	;Reiniciamos los contadores de los loops anidados. Recordar que la versión de prueba del programa trabaja con 		
		movwf	cont1	;un 1 en lugar de un 100, que sería el valor real de los contadores de los loops anidados.
lc3: 	movwf 	cont2
ld3:	movwf	cont3
le3:	decfsz	cont3,f
		goto	le3
		decfsz	cont2,f
		goto	ld3
		decfsz	cont1,f
		goto	lc3
		decfsz	cont25			;Se decrementa el valor del 25
		goto 	lb3			
		goto	c4				;En este punto llamamos al ciclo de la última secuencia
	;<----------------------> Comienza el cuarto loop
c4: 	movlw	b'00010100'		
		movwf	PORTB
lb4:	movlw 	d'1'			;Luego volvemos a inicializar los contadores
		movwf	cont1
lc4: 	movwf 	cont2
ld4:	movwf	cont3
le4:	decfsz	cont3,f
		goto	le4
		decfsz	cont2,f
		goto	ld4
		decfsz	cont1,f
		goto	lc4
		decfsz	cont5			
		goto 	lb4				
		goto	c1	
		
		end