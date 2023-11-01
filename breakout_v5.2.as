;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		    EQU     FFFCh
CURSOR_INIT		EQU		FFFFh
ROW_POSITION	EQU		0d
COL_POSITION	EQU		0d
ROW_SHIFT		EQU		8d
COLUMN_SHIFT	EQU		8d

MAPLINESIZE		EQU  	80d
LINENUMBER	 	EQU 	24d	

BAR_LINE		EQU 	21d

WALL_LEFT		EQU     0d
WALL_RIGHT 		EQU  	79d
WALL_UP			EQU   	5d
WALL_DOWN   	EQU  	23d


UPRIGHT  	EQU  1d
DOWNRIGHT   EQU  2d
UPLEFT    	EQU  3d
DOWNLEFT    EQU  4d

TIMER_UNITS     EQU     FFF6h
ACTIVATE_TIMER  EQU     FFF7h

ON 				EQU     1d 
OFF             EQU     0d

SPACE_CHAR 		EQU     ' '
BALL_CHAR		EQU  	'O'

BALL_SIZE

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

                ORIG    8000h
VarMap0             STR     '                                BREAKOUT/ARKANOID                               ' 
VarMap1             STR     '                                                                                ' 
VarMap2             STR     '   Pontos:0000   Vidas: 0000                                                    ' 
VarMap3             STR     'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' 
VarMap4             STR     'x                                                                              x' 
VarMap5             STR     'x                                                                              x' 
VarMap6             STR     'x                                                                              x' 
VarMap7             STR     'x     ====================================================================     x' 
VarMap8             STR     'x     ====================================================================     x' 
VarMap9             STR     'x     ====================================================================     x' 
VarMap10            STR     'x     ====================================================================     x' 
VarMap11            STR     'x                                                                              x' 
VarMap12            STR     'x                                                                              x' 
VarMap13            STR     'x                                                                              x' 
VarMap14            STR     'x                                                                              x'
VarMap15            STR     'x                                                                              x'
VarMap16            STR     'x                                                                              x'
VarMap17            STR     'x                                                                              x'
VarMap18            STR     'x                                                                              x'
VarMap19            STR     'x                                                                              x'
VarMap20            STR     'x                                     O                                        x'
VarMap21            STR     'x                           XXXXXXXXXXXXXXXXXXXXX                              x'
VarMap22            STR     'x                                                                              x'
VarMap23            STR     'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', FIM_TEXTO

lineToPrint		WORD	0d 
lineIndex		WORD 	0d 

bar_left  		WORD 	28d
bar_right  		WORD  	48d

ball_direction  WORD  	UPRIGHT  

ball_column		WORD  	38d
ball_line		WORD  	20d

Character       WORD     'A'

;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0            WORD    mover_barra_esq
INT1            WORD    mover_barra_dir

				ORIG    FE0Fh
INT15			WORD    timer

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;------------------------------------------------------------------------------
; ZONA V: definicao de interrupções
;------------------------------------------------------------------------------

timer: PUSH R1
	   PUSH R2
	   PUSH R3

	MOV R1, M[ ball_direction ]

	CMP R1, UPRIGHT 
	CALL.Z move_up_right

	CMP R1, UPLEFT 
	CALL.Z move_up_left

	CMP R1, DOWNRIGHT 
	CALL.Z move_down_right

	CMP R1, DOWNLEFT 
	CALL.Z move_down_left

	CALL ConfigureTimer
	
	POP R3
	POP R2
	POP R1
	RTI

; /-/-/-/-/-/- Movimentar barra pra direita -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

mover_barra_dir:  	PUSH R1
					PUSH R2
					PUSH R3
					PUSH R4

	MOV 	R1, M[ bar_left ]
	MOV 	R2, M[ bar_right ]
	MOV  	R3, BAR_LINE 				

	CMP 	R2, 78d
	JMP.Z 	end_mover_barra_esq;

; 	right side

	MOV  	R4, 'X'

	MOV R2, M[ bar_right ] 
	INC R2
	MOV M[ bar_right ], R2

	SHL		R3, 8d 
	OR  	R3, R2
	MOV  	M[ CURSOR ], R3	
	MOV  	M[ IO_WRITE ], R4


; 	left side

	MOV  	R4, ' '
	MOV 	R3, BAR_LINE

	SHL		R3, 8d 
	OR  	R3, R1
	MOV  	M[ CURSOR ], R3
	MOV  	M[ IO_WRITE ], R4

	MOV R1, M[ bar_left ] 
	INC R1
	MOV M[ bar_left ], R1

end_mover_barra_dir:	POP R4
						POP R3
     					POP R2
						POP R1
						RTI


; /-/-/-/-/-/- Movimentar barra pra esquerda -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

mover_barra_esq:  	PUSH R1;	bar_left  == coluna
					PUSH R2;	bar_right == coluna
					PUSH R3;	BAR_LINE  == linha
					PUSH R4;	CHAR 


	MOV 	R1, M[ bar_left ]
	MOV 	R2, M[ bar_right ]
	MOV  	R3, BAR_LINE 

	CMP 	R1, 1d
	JMP.Z 	end_mover_barra_esq

;	left side  	
	
	MOV  	R4, 'X'  

	MOV R1, M[ bar_left ] 
	DEC R1
	MOV M[ bar_left ], R1

	SHL		R3, 8d 
	OR  	R3, R1
	MOV  	M[ CURSOR ], R3
	MOV  	M[ IO_WRITE ], R4

; 	right side 

	MOV 	R4, ' ' 
	MOV  	R3, BAR_LINE

	SHL		R3, 8d 
	OR  	R3, R2
	MOV  	M[ CURSOR ], R3
	MOV  	M[ IO_WRITE ], R4

	MOV R2, M[ bar_right ] 
	DEC R2
	MOV M[ bar_right ], R2


end_mover_barra_esq:	POP R4
						POP R3
						POP R2
						POP R1
						RTI

;------------------------------------------------------------------------------
; ZONA VI: definicao de funções
;------------------------------------------------------------------------------

; /-/-/-/-/-/- Esqueleto de funções -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

esqueleto:	PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4

			POP R4
			POP R3
			POP R2
			POP R1
			RET


ConfigureTimer: PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4

			MOV R1, 5d
			MOV M[ TIMER_UNITS ], R1

			MOV R1, ON 
			MOV M[ ACTIVATE_TIMER ], R1

			POP R4
			POP R3
			POP R2
			POP R1
			RET

; /-/-/-/-/-/- Print de linha -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

print_line_map:	PUSH 	R1
				PUSH 	R2
				PUSH 	R3
				PUSH 	R4
				PUSH 	R5
			
			MOV  	R3, 0d
			MOV 	R5, MAPLINESIZE

ciclo_print_line_map:	MOV 	R1, M[ lineToPrint ]
						MOV  	R2, M[ lineIndex ]

			ADD		R1, R3
			MOV     R4, M[R1]

			SHL R2, 8d
			OR  R2, R3
			MOV M[ CURSOR ], R2
			MOV M[ IO_WRITE ], R4	

			INC R3	
			CMP R3, R5
			JMP.Z end_print_line_map
			JMP ciclo_print_line_map

end_print_line_map:	POP R5			
					POP R4
					POP R3
					POP R2
					POP R1
					RET

; /-/-/-/- Print de Mapa -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

print_map: 		PUSH 	R1
				PUSH 	R2
				PUSH 	R3
				PUSH 	R4
				PUSH 	R5

				MOV R3, LINENUMBER
				MOV R2, 0d
				MOV R1, VarMap0
				MOV R4, MAPLINESIZE

ciclo_print_map:	MOV M[ lineToPrint ], R1

		MOV M[ lineIndex ], R2
		CALL 	print_line_map	

		CMP  	R3, R2
		JMP.Z  	end_print_map

		INC R2
		ADD R1, R4

		JMP  	ciclo_print_map

end_print_map:	POP R5			
			POP R4
			POP R3
			POP R2
			POP R1
			RET

; /-/-/-/- Movimento up-right -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

move_up_right:	PUSH R1; linha
				PUSH R2; coluna

;-> comparar prox. posição com paredes				

	MOV R1, M[ ball_line ]
	INC R1
	CMP R1, WALL_UP
	JMP.NZ  continue_up_right
	MOV R2, DOWNRIGHT
	MOV M[ ball_direction ], R2
	JMP end_move_up_right

	MOV R1, M[ ball_column ]
	INC R1
	CMP R1, WALL_RIGHT
	JMP.NZ continue_up_right
	MOV R2, UPLEFT
	MOV M[ ball_direction ], R2
	JMP end_move_up_right

;-> apagar a bola em [x|y]	

continue_up_right:	MOV R1, M[ ball_line ]
					MOV R2, M[ ball_column ]

	SHL R1, 8d 
	OR  R1, R2
	MOV M[ CURSOR ], R1

	MOV R1, SPACE_CHAR
	MOV M[ IO_WRITE ], R1

;-> inc de x e dec de y

	MOV R1, M[ ball_line ]
	DEC R1
	MOV M[ ball_line ], R1

	MOV R1, M[ ball_column ]
	INC R1
	MOV M[ ball_column ], R1

;-> print da bola em novo [x|y]

	MOV R1, M[ ball_line ]
	MOV R2, M[ ball_column ]

	SHL R1, 8d                                     
	OR  R1, R2
	MOV M[ CURSOR ], R1

	MOV R1, BALL_CHAR
	MOV M[ IO_WRITE ], R1

end_move_up_right:	POP R2
					POP R1
					RET

; /-/-/-/- Movimento up-left -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

move_up_left: PUSH R1; 
			  PUSH R2;  

;-> comparar prox. posição com paredes				

	MOV R1, M[ ball_line ]
	INC R1
	CMP R1, WALL_UP
	JMP.NZ  continue_up_left
	MOV R2, DOWNLEFT
	MOV M[ ball_direction ], R2
	JMP end_move_up_left

	MOV R1, M[ ball_column ]
	INC R1
	CMP R1, WALL_LEFT
	JMP.NZ  continue_up_left
	MOV R2, UPRIGHT
	MOV M[ ball_direction ], R2
	JMP end_move_up_left

;-> apagar a bola em [x|y]	

continue_up_left:	MOV R1, M[ ball_line ]
					MOV R2, M[ ball_column ]

	SHL R1, 8d 
	OR  R1, R2
	MOV M[ CURSOR ], R1

	MOV R1, SPACE_CHAR
	MOV M[ IO_WRITE ], R1

;-> dec de x e dec de y

	MOV R1, M[ ball_line ]
	DEC R1
	MOV M[ ball_line ], R1

	MOV R1, M[ ball_column ]
	DEC R1
	MOV M[ ball_column ], R1

;-> print da bola em novo [x|y]

	MOV R1, M[ ball_line ]
	MOV R2, M[ ball_column ]

	SHL R1, 8d                                     
	OR  R1, R2
	MOV M[ CURSOR ], R1

	MOV R1, BALL_CHAR
	MOV M[ IO_WRITE ], R1

end_move_up_left:	POP R2
					POP R1
					RET

; /-/-/-/- Movimento down-right -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

move_down_right: PUSH R1; 
			     PUSH R2;  

;-> comparar prox. posição com paredes				

 	MOV R1, M[ ball_column ]
	INC R1
	CMP R1, WALL_RIGHT
	JMP.NZ  continue_down_right
	MOV R2, DOWNLEFT
	MOV M[ ball_direction ], R2
	JMP end_move_down_right


;-> apagar a bola em [x|y]	

continue_down_right:	MOV R1, M[ ball_line ]
						MOV R2, M[ ball_column ]

	SHL R1, 8d 
	OR  R1, R2
	MOV M[ CURSOR ], R1

	MOV R1, SPACE_CHAR
	MOV M[ IO_WRITE ], R1

;-> inc de x e inc de y

	MOV R1, M[ ball_line ]
	INC R1
	MOV M[ ball_line ], R1

	MOV R1, M[ ball_column ]
	INC R1
	MOV M[ ball_column ], R1

;-> print da bola em novo [x|y]

	MOV R1, M[ ball_line ]
	MOV R2, M[ ball_column ]

	SHL R1, 8d                                     
	OR  R1, R2
	MOV M[ CURSOR ], R1

	MOV R1, BALL_CHAR
	MOV M[ IO_WRITE ], R1

end_move_down_right:	POP R2
						POP R1
						RET


; /-/-/-/- Movimento down-left -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

move_down_left: PUSH R1
				PUSH R2

;-> comparar prox. posição com paredes				

 	MOV R1, M[ ball_column ]
	INC R1
	CMP R1, WALL_left
	JMP.NZ  continue_down_left
	MOV R2, DOWNRIGHT
	MOV M[ ball_direction ], R2
	JMP end_move_down_left


;-> apagar a bola em [x|y]	

continue_down_left:	MOV R1, M[ ball_line ]
					MOV R2, M[ ball_column ]

	SHL R1, 8d 
	OR  R1, R2
	MOV M[ CURSOR ], R1

	MOV R1, SPACE_CHAR
	MOV M[ IO_WRITE ], R1

;-> inc de x e inc de y

	MOV R1, M[ ball_line ]
	INC R1
	MOV M[ ball_line ], R1

	MOV R1, M[ ball_column ]
	DEC R1
	MOV M[ ball_column ], R1

;-> print da bola em novo [x|y]

	MOV R1, M[ ball_line ]
	MOV R2, M[ ball_column ]

	SHL R1, 8d                                     
	OR  R1, R2
	MOV M[ CURSOR ], R1

	MOV R1, BALL_CHAR
	MOV M[ IO_WRITE ], R1

end_move_down_left:	POP R2
					POP R1
					RET


; /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/


Main:			ENI
				MOV		R1, INITIAL_SP
				MOV		SP, R1		 		; We need to initialize the stack
				MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
				MOV		M[ CURSOR ], R1		; with value CURSOR_INIT

				CALL    print_map
				CALL    ConfigureTimer


Cycle: 			BR		Cycle	
Halt:           BR		Halt





