TITLE Average Calculator (AverageCalculator.asm)
INCLUDE Irvine32.inc

.data
prompt BYTE "Enter integer #", 0
colon BYTE ": ", 0
sumMsg BYTE "Sum: ", 0
avgMsg BYTE "Average: ", 0
numbers SDWORD 5 DUP(?)
sum SDWORD 0
wholePart DWORD ?
fractionPart DWORD ?
inputIndex DWORD 1

.code
main PROC
    mov esi, OFFSET numbers
    mov ecx, LENGTHOF numbers

inputLoop:
    push ecx                    ; protect LOOP counter across library calls
    mov edx, OFFSET prompt
    call WriteString
    mov eax, inputIndex
    call WriteDec
    mov edx, OFFSET colon
    call WriteString
    call ReadInt
    mov [esi], eax
    add esi, TYPE numbers
    inc inputIndex
    pop ecx
    loop inputLoop

    mov esi, OFFSET numbers
    mov ecx, LENGTHOF numbers
    xor eax, eax
sumLoop:
    add eax, [esi]
    add esi, TYPE numbers
    loop sumLoop
    mov sum, eax

    mov edx, OFFSET sumMsg
    call WriteString
    mov eax, sum
    call WriteInt
    call Crlf

    ; Signed sum / 5. Each fractional fifth equals 20 hundredths.
    mov eax, sum
    cdq
    mov ecx, 5
    idiv ecx
    mov ebx, eax               ; signed whole part
    mov eax, edx               ; signed remainder (-4..4)
    cmp eax, 0
    jge positiveFraction
    neg eax
positiveFraction:
    imul eax, 20
    mov fractionPart, eax
    mov wholePart, ebx

    mov edx, OFFSET avgMsg
    call WriteString
    mov eax, sum
    cmp eax, 0
    jge nonnegativeAverage
    mov al, '-'
    call WriteChar
nonnegativeAverage:
    mov eax, wholePart
    cmp eax, 0
    jge positiveWhole
    neg eax
positiveWhole:
    call WriteDec              ; unsigned magnitude, no extra '+' sign
    mov al, '.'
    call WriteChar
    mov eax, fractionPart
    cmp eax, 10
    jae twoDigits
    mov al, '0'
    call WriteChar
twoDigits:
    mov eax, fractionPart
    call WriteDec
    call Crlf
    exit
main ENDP
END main
