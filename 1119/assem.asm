
INCLUDE Irvine32.inc

.data
    msg1 BYTE "Enter first number: ", 0
    msg2 BYTE "Enter second number: ", 0

    addMsg BYTE "Addition: ", 0
    subMsg BYTE "Subtraction: ", 0
    mulMsg BYTE "Multiplication: ", 0
    divMsg BYTE "Division: ", 0

    axMsg BYTE "AX = ", 0
    bxMsg BYTE "BX = ", 0
    cxMsg BYTE "CX = ", 0
    dxMsg BYTE "DX = ", 0

    num1 DWORD ?
    num2 DWORD ?

.code
main PROC

    ; 첫 번째 숫자 입력
    mov edx, OFFSET msg1
    call WriteString
    call ReadInt
    mov num1, eax

    ; 두 번째 숫자 입력
    mov edx, OFFSET msg2
    call WriteString
    call ReadInt
    mov num2, eax

    ; 덧셈
    mov eax, num1
    add eax, num2
    mov ax, ax

    mov edx, OFFSET addMsg
    call WriteString
    call WriteInt
    call Crlf

    ; 뺄셈
    mov eax, num1
    sub eax, num2

    mov edx, OFFSET subMsg
    call WriteString
    call WriteInt
    call Crlf

    ; 곱셈
    mov eax, num1
    mul num2

    mov edx, OFFSET mulMsg
    call WriteString
    call WriteInt
    call Crlf

    ; 나눗셈
    mov eax, num1
    cdq
    mov ebx, num2
    cmp ebx, 0
    je SkipDiv

    idiv ebx

    mov edx, OFFSET divMsg
    call WriteString
    call WriteInt
    call Crlf

SkipDiv:

    ; 레지스터 값 설정 및 출력
    mov ax, WORD PTR num1
    mov bx, WORD PTR num2
    mov cx, ax
    add cx, bx
    mov dx, 0

    mov edx, OFFSET axMsg
    call WriteString
    movzx eax, ax
    call WriteDec
    call Crlf

    mov edx, OFFSET bxMsg
    call WriteString
    movzx eax, bx
    call WriteDec
    call Crlf

    mov edx, OFFSET cxMsg
    call WriteString
    movzx eax, cx
    call WriteDec
    call Crlf

    mov edx, OFFSET dxMsg
    call WriteString
    movzx eax, dx
    call WriteDec
    call Crlf

    exit
main ENDP
END main
