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

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

                ORIG    8000h
Text			STR     'Hello World', FIM_TEXTO
RowIndex		WORD	0d
ColumnIndex		WORD	0d
TextIndex		WORD	0d

VarMap0             STR     '                                BREAKOUT/ARKANOID                               '
VarMap1             STR     '                                                                                '
VarMap2             STR     '   Pontos:0000   Vidas: 0000                                                    '
VarMap3             STR     'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
VarMap4             STR     'x                                                                              x'
VarMap5             STR     'x                                                                              x'
VarMap6             STR     'x                                                                              x'
VarMap7             STR     'x                                                                              x'
VarMap8             STR     'x                                                                              x'
VarMap9             STR     'x                                                                              x'
VarMap10            STR     'x                                                                              x'
VarMap11            STR     'x                                                                              x'
VarMap12            STR     'x                                                                              x'
VarMap13            STR     'x                                                                              x'
VarMap14            STR     'x                                                                              x'
VarMap15            STR     'x                                                                              x'
VarMap16            STR     'x                                                                              x'
VarMap17            STR     'x                                                                              x'
VarMap18            STR     'x                                                                              x'
VarMap19            STR     'x                                                                              x'
VarMap20            STR     'x                                                                              x'
VarMap21            STR     'x                                                                              x'
VarMap22            STR     'x                                                                              x'
VarMap23            STR     'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', FIM_TEXTO





;------------------------------------------------------------------------------
; ZONA III: definicao de funções
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

; /-/-/-/-/-/- Print de linha -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/

startup_ciclo_print_string:	PUSH R1		; char_adress
							PUSH R2		; linha 
							PUSH R3		; coluna
							PUSH R4		; char_counter
							MOV R2, R0
							MOV R3, R0	
							MOV R4, R0


ciclo_print_string:		MOV R1, M[ R4 + Text ]
						MOV R2, R0
						CMP R1, FIM_TEXTO
						JMP.Z end_ciclo_print_string

						SHL R2, 8d
						OR  R2, R3

						MOV M[ CURSOR ], R2
						MOV M[ IO_WRITE ], R1		

						INC R4
						INC R3
						JMP ciclo_print_string

end_ciclo_print_string: POP R4
						POP R3
						POP R2
						POP R1
						RET

; /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/







;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

Main:			ENI
				MOV		R1, INITIAL_SP
				MOV		SP, R1		 		; We need to initialize the stack
				MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
				MOV		M[ CURSOR ], R1		; with value CURSOR_INIT

				CALL    startup_ciclo_print_string				

Cycle: 			BR		Cycle	
Halt:           BR		Halt





