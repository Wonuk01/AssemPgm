# Chapter 5 --- Programming Exercises

> 원문의 Programming Exercises 1\~11을 한국어로 번역하고, Irvine32/MASM
> 32비트 환경을 기준으로 예시 답안을 정리했습니다.

## 1. 텍스트 색상 출력 (Draw Text Colors)

**질문:** 반복문을 사용하여 같은 문자열을 서로 다른 네 가지 색상으로
출력하라. 교재 링크 라이브러리의 `SetTextColor` 프로시저를 호출한다.

**답:**

``` asm
INCLUDE Irvine32.inc

.data
msg BYTE "Hello, Assembly!",0
colors BYTE 1,2,4,14

.code
main PROC
    mov esi, OFFSET colors
    mov ecx, 4

L1:
    movzx eax, BYTE PTR [esi]
    call SetTextColor
    mov edx, OFFSET msg
    call WriteString
    call Crlf
    inc esi
    loop L1

    exit
main ENDP
END main
```

## 2. 배열 항목 연결하기 (Linking Array Items)

**질문:** 시작 인덱스, 문자 배열, 링크 인덱스 배열이 주어졌을 때 링크를
따라가며 문자를 올바른 순서로 찾아 새 배열에 복사하라. 예시는 `start=1`,
`chars=HACEBDFG`, `links=04562370`이며 결과는 `ABCDEFGH`가 되어야 한다.
`chars`는 BYTE, `links`는 DWORD로 선언한다.

**답:**

``` asm
INCLUDE Irvine32.inc

.data
start DWORD 1
chars BYTE "HACEBDFG"
links DWORD 0,4,5,6,2,3,7,0
output BYTE 8 DUP(?),0

.code
main PROC
    mov esi, start
    mov edi, OFFSET output
    mov ecx, LENGTHOF chars

L1:
    mov al, chars[esi]
    mov [edi], al
    inc edi
    mov esi, links[esi*4]
    loop L1

    mov edx, OFFSET output
    call WriteString
    call Crlf

    exit
main ENDP
END main
```

## 3. 간단한 덧셈 (1)

**질문:** 화면을 지우고 커서를 화면 중앙 근처로 이동한 뒤, 사용자에게
정수 두 개를 입력받아 더하고 합계를 출력하라.

**답:**

``` asm
INCLUDE Irvine32.inc

.data
prompt1 BYTE "첫 번째 정수: ",0
prompt2 BYTE "두 번째 정수: ",0
resultMsg BYTE "합계: ",0
num1 SDWORD ?

.code
main PROC
    call Clrscr

    mov dh, 10
    mov dl, 25
    call Gotoxy

    mov edx, OFFSET prompt1
    call WriteString
    call ReadInt
    mov num1, eax

    mov edx, OFFSET prompt2
    call WriteString
    call ReadInt
    add eax, num1

    mov edx, OFFSET resultMsg
    call WriteString
    call WriteInt
    call Crlf

    exit
main ENDP
END main
```

## 4. 간단한 덧셈 (2)

**질문:** 3번 프로그램을 기반으로 같은 과정을 세 번 반복하라. 각 반복이
끝난 후 화면을 지운다.

**답:**

``` asm
INCLUDE Irvine32.inc

.data
prompt1 BYTE "첫 번째 정수: ",0
prompt2 BYTE "두 번째 정수: ",0
resultMsg BYTE "합계: ",0
num1 SDWORD ?

.code
main PROC
    mov ecx, 3

L1:
    call Clrscr

    mov edx, OFFSET prompt1
    call WriteString
    call ReadInt
    mov num1, eax

    mov edx, OFFSET prompt2
    call WriteString
    call ReadInt
    add eax, num1

    mov edx, OFFSET resultMsg
    call WriteString
    call WriteInt
    call Crlf

    mov eax, 1000
    call Delay
    loop L1

    call Clrscr
    exit
main ENDP
END main
```

## 5. BetterRandomRange 프로시저

**질문:** Irvine32의 `RandomRange`는 0부터 N-1까지의 난수를 만든다. 이를
개선하여 M부터 N-1까지의 난수를 생성하는 `BetterRandomRange`를 작성하라.
M은 EBX, N은 EAX로 전달한다. 50회 호출하여 결과를 출력하라.

**답:** 범위의 크기 `N-M`을 구해 `RandomRange`에 전달하고, 결과에 M을
더하면 된다.

``` asm
INCLUDE Irvine32.inc

.code
BetterRandomRange PROC
    sub eax, ebx       ; EAX = N - M
    call RandomRange   ; 0 .. (N-M)-1
    add eax, ebx       ; M .. N-1
    ret
BetterRandomRange ENDP

main PROC
    call Randomize
    mov ecx, 50

L1:
    mov ebx, -300
    mov eax, 100
    call BetterRandomRange
    call WriteInt
    call Crlf
    loop L1

    exit
main ENDP
END main
```

## 6. 임의 문자열 생성 (Random Strings)

**질문:** 길이 L의 대문자 임의 문자열을 생성하는 프로시저를 작성하라.
L은 EAX로, 문자열을 저장할 BYTE 배열의 포인터도 전달한다. 프로시저를
20회 호출하여 문자열을 출력하라.

**답:** 아래 예시에서는 EAX에 길이, EDX에 버퍼 주소를 전달한다.

``` asm
INCLUDE Irvine32.inc

.data
buffer BYTE 21 DUP(0)

.code
RandomString PROC USES eax ebx ecx edi
    mov ecx, eax
    mov edi, edx

L1:
    mov eax, 26
    call RandomRange
    add al, 'A'
    mov [edi], al
    inc edi
    loop L1

    mov BYTE PTR [edi], 0
    ret
RandomString ENDP

main PROC
    call Randomize
    mov ebx, 20

L2:
    mov eax, 20
    mov edx, OFFSET buffer
    call RandomString

    mov edx, OFFSET buffer
    call WriteString
    call Crlf

    dec ebx
    jnz L2

    exit
main ENDP
END main
```

## 7. 임의 화면 위치 (Random Screen Locations)

**질문:** 한 문자를 화면의 임의 위치 100곳에 출력하고, 출력 사이에 100ms
지연을 둔다. `GetMaxXY`로 콘솔 크기를 구한다.

**답:**

``` asm
INCLUDE Irvine32.inc

.code
main PROC
    call Randomize
    call GetMaxXY
    ; DL = 최대 열 수, DH = 최대 행 수
    movzx esi, dl
    movzx edi, dh
    mov ecx, 100

L1:
    mov eax, esi
    call RandomRange
    mov dl, al

    mov eax, edi
    call RandomRange
    mov dh, al

    call Gotoxy
    mov al, '*'
    call WriteChar

    mov eax, 100
    call Delay
    loop L1

    exit
main ENDP
END main
```

## 8. 색상 행렬 (Color Matrix)

**질문:** 하나의 문자를 16개의 전경색 × 16개의 배경색, 총 256가지
조합으로 출력하라. 중첩 반복문을 사용한다.

**답:** `SetTextColor`의 색상 값은 하위 4비트가 전경색, 상위 4비트가
배경색이다.

``` asm
INCLUDE Irvine32.inc

.code
main PROC
    mov ebx, 0              ; 배경색

OuterLoop:
    mov ecx, 16
    mov esi, 0              ; 전경색

InnerLoop:
    mov eax, ebx
    shl eax, 4
    or eax, esi
    call SetTextColor

    mov al, 'A'
    call WriteChar
    mov al, ' '
    call WriteChar

    inc esi
    loop InnerLoop

    call Crlf
    inc ebx
    cmp ebx, 16
    jb OuterLoop

    mov eax, 7
    call SetTextColor
    exit
main ENDP
END main
```

## 9. 재귀 프로시저 (Recursive Procedure)

**질문:** 직접 재귀 프로시저를 작성하라. 실행 횟수를 확인할 수 있도록
프로시저 내부에서 카운터를 1씩 증가시킨다. ECX에 허용할 재귀 횟수를
넣고, 조건문 없이 `LOOP` 명령어만 사용하여 정해진 횟수만큼 재귀
호출하라.

**답:**

``` asm
INCLUDE Irvine32.inc

.data
counter DWORD 0

.code
RecursiveProc PROC
    inc counter
    loop DoRecursive
    ret

DoRecursive:
    call RecursiveProc
    ret
RecursiveProc ENDP

main PROC
    mov ecx, 10
    call RecursiveProc

    mov eax, counter
    call WriteDec
    call Crlf

    exit
main ENDP
END main
```

ECX를 10으로 시작하면 `counter`는 최종적으로 10이 된다.

## 10. 피보나치 생성기 (Fibonacci Generator)

**질문:** 피보나치 수열 N개를 생성하여 DWORD 배열에 저장하는 프로시저를
작성하라. 입력은 배열 포인터와 생성할 개수이다. N=47로 테스트하며 첫
값은 1, 마지막 값은 2,971,215,073이어야 한다.

**답:** 아래 예시에서는 ESI에 배열 포인터, ECX에 N을 전달한다.

``` asm
INCLUDE Irvine32.inc

.data
fibArray DWORD 47 DUP(?)

.code
Fibonacci PROC USES eax ebx edx edi
    mov edi, esi

    mov eax, 1
    mov ebx, 1

    mov [edi], eax
    add edi, 4
    dec ecx
    jz Done

    mov [edi], ebx
    add edi, 4
    dec ecx
    jz Done

L1:
    mov edx, eax
    add edx, ebx
    mov [edi], edx
    add edi, 4

    mov eax, ebx
    mov ebx, edx
    loop L1

Done:
    ret
Fibonacci ENDP

main PROC
    mov esi, OFFSET fibArray
    mov ecx, 47
    call Fibonacci

    exit
main ENDP
END main
```

47번째 값은 `2,971,215,073`이며 DWORD의 비트 패턴으로 저장할 수 있다.

## 11. K의 배수 찾기 (Finding Multiples of K)

**질문:** 크기 N의 BYTE 배열에서 N보다 작은 K의 배수를 모두 찾아 해당
인덱스의 배열 요소를 1로 설정하는 프로시저를 작성하라. 배열은 처음에
모두 0으로 초기화한다. 프로시저는 변경하는 레지스터를 저장하고 복원해야
한다. N=50에서 K=2와 K=3으로 각각 호출하라.

**답:** 아래에서는 ESI=배열 주소, EAX=K, ECX=N을 입력으로 사용한다.

``` asm
INCLUDE Irvine32.inc

.data
N = 50
array BYTE N DUP(0)

.code
FindMultiples PROC USES eax ebx ecx edx esi edi
    mov ebx, eax        ; EBX = K
    mov edi, ebx        ; 첫 번째 배수 = K

L1:
    cmp edi, ecx
    jae Done
    mov BYTE PTR [esi+edi], 1
    add edi, ebx
    jmp L1

Done:
    ret
FindMultiples ENDP

main PROC
    mov esi, OFFSET array

    mov eax, 2
    mov ecx, N
    call FindMultiples

    mov eax, 3
    mov ecx, N
    call FindMultiples

    exit
main ENDP
END main
```

실행 후 배열에서 2의 배수 또는 3의 배수에 해당하는 인덱스가 1로
설정된다. 예를 들어 인덱스 2, 3, 4, 6, 8, 9, 10, 12 등이 1이 된다.
