    .def _CNTL_3P3Z_F_ASM

_CNTL_3P3Z_F_ASM

; because of C calling convention
; XAR4 has the cntl3p3z coeff structure pointer
; XAR5 has the cntl3p3z data buff internal pointer
; Save R4H in Out memory address
	;save R4H
    MOV32 @XAR6,R4H
    PUSH XAR6

; calculate error (Ref - Fdbk)
    MOV     AR0,#14
    MOV32   R0H,*+XAR5[AR0]
    MOV     AR0,#16
    MOV32   R1H,*+XAR5[AR0]
    SUBF32  R0H,R0H,R1H             ; R0H = Ref(R0H) - Fdbk(R1H)= error(R0H)
    NOP

; store error in DBUFF
    MOV32   *+XAR5[6], R0H
                                    ; e(n) = ACC = error Q{30}
; compute 2P2Z filter
    MOV     AR0,#12
    MOV32   R0H, *+XAR5[AR0]        ; R0H = e(n-3)
    MOV32   R1H, *XAR4++            ; R1H = B3
    MPYF32  R2H,R0H,R1H             ; R2H = e(n-3)*B(3)
||  MOV32          R1H,*XAR4++      ; R1H = B2

    MOV     AR0,#10
    MOVD32  R0H,*+XAR5[AR0]         ; R0H = e(n-2) and e(n-3)=e(n-2)
    MPYF32  R3H,R0H,R1H             ; R3H = e(n-2)*B2
||  MOV32 R1H,*XAR4++               ; R1H = B1

    MOV     AR0,#8
    MOVD32  R0H,*+XAR5[AR0]         ; R0H = e(n-1) and e(n-2)=e(n-1)
    MPYF32  R4H,R0H,R1H             ; R4H = e(n-1)*B1 ,
||  ADDF32  R2H,R2H,R3H             ; R2H = e(n-2)*B2+e(n-3)*B3

    MOVD32  R0H,*+XAR5[6]           ; R0H = e(n) and e(n-1)=e(n)
    MOV32   R1H,*XAR4++             ; R1H = B0
    MPYF32  R3H,R0H,R1H             ; R3H = e(n)*B0 ,
||  ADDF32  R2H,R2H,R4H             ; R2H = e(n-1)*B1+e(n-2)*B2+e(n-3)*B3

    MOV32   R0H,*+XAR5[4]           ; R0H = u(n-3)
    MOV32   R1H,*XAR4++             ; R1H = A3
    MPYF32  R4H,R0H,R1H             ; R4H = u(n-3)*A3 ,
||  ADDF32  R2H,R2H,R3H             ; R2H = e(n)*B0+e(n-1)*B1+e(n-2)*B2+e(n-3)*B3

    MOVD32  R0H,*+XAR5[2]           ; R0H = u(n-2), u(n-3) = u(n-2)
    MOV32   R1H,*XAR4++             ; R1H = A2
    MPYF32  R3H,R0H,R1H             ; R3H = u(n-2)*A2 ,
||  ADDF32  R2H,R2H,R4H             ; R2H = u(n-3)*A3+e(n)*B0+e(n-1)*B1+e(n-2)*B2+e(n-3)*B3

    MOVD32  R0H,*+XAR5[0]           ; R0H = u(n-1), u(n-2) = u(n-1)
    MOV32   R1H,*XAR4++             ; R1H = A1
    MPYF32  R4H,R0H,R1H             ; R4H = u(n-1)*A1 ,
||  ADDF32  R2H,R2H,R3H             ; R2H = u(n-2)*A2+u(n-3)*A3+e(n)*B0+e(n-1)*B1+e(n-2)*B2+e(n-3)*B3

    MOV32   R0H,*XAR4++             ; R0H = Maximum Value

    ADDF32  R2H,R2H,R4H             ; R2H = u(n-1)*A1+u(n-2)*A2+u(n-3)*A3+e(n)*B0+e(n-1)*B1+e(n-2)*B2+e(n-3)*B3
    MOV32   R1H,*XAR4++             ; R1H = Internal minimum value

    MINF32  R2H,R0H                                                                                                         ; R2H = min (R0H{maximum value}, R2H {computed value})
    MOV32   R3H,*XAR4++             ; R3H = Output minimum value
    MAXF32  R2H,R1H                                                                                                           ;             R2H = Max(R2H

    MOV32   *+XAR5[0],R2H           ; store the internal min saturate value in the data buffer
    MAXF32  R2H,R3H                                                                                                           ; saturate result to the output min value

; store the result in the output terminal
    MOV     AR0,#18
    MOV32   *+XAR5[AR0],R2H

    ;restore R4H
	POP ACC
	MOV32	R4H,ACC

    LRETR
