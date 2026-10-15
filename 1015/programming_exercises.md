# Chapter 6 Conditional Processing --- Programming Exercises

> 각 문제를 한국어로 정리하고 구현 방향과 대표적인 MASM/Irvine32 형태의
> 답안을 제시했습니다.\
> **주의:** 제공된 원문에서 3번의 학점 범위 표와 4번이 참조하는 Section
> 6.7.3의 기존 등록 판정 조건은 누락되어 있습니다. 따라서 그 두 문제는
> 원문에서 확인 가능한 범위까지만 답안을 작성했습니다.

## 1. 배열 채우기 (Filling an Array)

**질문:** DWORD 배열을 N개의 난수로 채우는 프로시저를 작성하라. 난수는
`j...k` 범위(양 끝 포함)에 있어야 한다. 배열 포인터, N, j, k를 전달하고
모든 레지스터 값을 보존한다. 서로 다른 j, k 값으로 두 번 호출하여
검사한다.

**핵심 답안:** - 난수 범위의 크기: `k - j + 1` - `RandomRange`로
`0...(k-j)`를 얻은 뒤 j를 더한다. - ESI에 배열 주소, ECX에 원소 개수를
둘 수 있다. - 프로시저에서 사용하는 레지스터는 `USES` 또는 PUSH/POP으로
보존한다.

``` asm
FillArray PROC USES eax ebx ecx edx esi
; 예시 호출 규약:
; ESI = 배열 주소
; ECX = N
; EBX = j
; EDX = k

L1:
    mov eax,edx
    sub eax,ebx
    inc eax              ; eax = k-j+1
    call RandomRange     ; eax = 0 .. (k-j)
    add eax,ebx          ; eax = j .. k
    mov [esi],eax
    add esi,TYPE DWORD
    loop L1
    ret
FillArray ENDP
```

------------------------------------------------------------------------

## 2. 지정 범위에 속하는 배열 원소의 합

**질문:** signed DWORD 배열에서 `j...k` 범위에 포함되는 원소만 더하여
EAX로 반환하는 프로시저를 작성하라. 배열 포인터, 배열 크기, j, k를
전달하며 EAX를 제외한 레지스터는 보존한다.

**핵심 답안:**

``` asm
; 예시:
; ESI = 배열 주소
; ECX = 배열 길이
; EBX = j
; EDX = k
; 반환값 EAX = 합계

CalcSum PROC USES ecx esi edi
    xor edi,edi          ; sum = 0

L1:
    mov eax,[esi]

    cmp eax,ebx
    jl Skip              ; value < j

    cmp eax,edx
    jg Skip              ; value > k

    add edi,eax

Skip:
    add esi,TYPE SDWORD
    loop L1

    mov eax,edi
    ret
CalcSum ENDP
```

**핵심:** signed 배열이므로 범위 비교에 `JL`, `JG`를 사용한다.

------------------------------------------------------------------------

## 3. 시험 점수 평가 (Test Score Evaluation)

**질문:** `CalcGrade` 프로시저가 0\~100의 정수를 받아 AL에 대문자 학점을
반환하도록 작성한다. 50\~100 사이의 난수 10개를 만들어 각각 CalcGrade에
전달한다.

**원문 누락 사항:** 제공된 자료에는 "다음 범위에 따라 학점을
반환한다"라는 문장은 있지만 실제 **점수별 A/B/C/D/F 범위 표가 빠져
있다.** 따라서 정확한 분기 기준은 이 자료만으로 확정할 수 없다.

**구현 골격:**

``` asm
CalcGrade PROC
    ; 입력 점수가 들어 있는 레지스터를
    ; 원문의 점수 범위 표와 CMP로 비교한다.

    ; 예:
    ; cmp eax,<A의 최소 점수>
    ; jge GradeA
    ; cmp eax,<B의 최소 점수>
    ; jge GradeB
    ; ...

GradeA:
    mov al,'A'
    ret

GradeB:
    mov al,'B'
    ret
CalcGrade ENDP
```

**테스트 핵심:** `RandomRange`를 사용할 때 50\~100을 포함하려면 범위
크기 51로 난수를 만든 뒤 50을 더한다.

``` asm
mov eax,51
call RandomRange
add eax,50
```

------------------------------------------------------------------------

## 4. 대학 등록 판정 (College Registration)

**질문:** Section 6.7.3의 College Registration 예제를 기반으로 다음을
수행한다.

-   `.IF`, `.ELSEIF` 대신 `CMP`와 조건부 점프를 사용한다.
-   credits는 1\~30만 허용한다.
-   잘못된 credits이면 오류 메시지를 출력한다.
-   사용자에게 grade average와 credits를 입력받는다.
-   "등록 가능/등록 불가" 결과를 출력한다.

**원문 누락 사항:** 현재 제공된 자료에는 Section 6.7.3의 **grade
average와 credits를 이용한 원래 등록 판정 조건**이 포함되어 있지 않다.
따라서 정확한 전체 판정 코드는 확정할 수 없다.

**확실히 구현할 수 있는 credits 검증:**

``` asm
cmp credits,1
jl InvalidCredits

cmp credits,30
jg InvalidCredits

; 여기서 Section 6.7.3의 등록 판정 조건 실행
jmp CheckRegistration

InvalidCredits:
    ; "잘못된 학점 수" 메시지 출력
```

------------------------------------------------------------------------

## 5. Boolean Calculator (1)

**질문:** 다음 메뉴를 가진 32비트 정수용 Boolean Calculator를 작성한다.

1.  x AND y
2.  x OR y
3.  NOT x
4.  x XOR y
5.  종료

사용자가 메뉴를 선택하면 수행할 연산 이름을 표시하는 프로시저를
호출한다. 이 선택 프로시저는 **Table-Driven Selection** 방식으로
구현한다.

**핵심 답안 구조:**

``` asm
.data
CaseTable BYTE 1
          DWORD AND_case
EntrySize = ($ - CaseTable)
          BYTE 2
          DWORD OR_case
          BYTE 3
          DWORD NOT_case
          BYTE 4
          DWORD XOR_case
NumberOfEntries = 4

.code
; 입력값을 테이블의 키와 비교하고
; 일치하면 저장된 프로시저 주소로 간접 CALL
```

**핵심:** 긴 IF/ELSE 체인 대신 `[선택값, 프로시저 주소]` 쌍을 테이블에
저장하여 검색한다.

------------------------------------------------------------------------

## 6. Boolean Calculator (2)

**질문:** 5번 프로그램에 실제 Boolean 연산 프로시저를 추가한다.

### AND_op

``` asm
; 두 16진수 입력
call ReadHex
mov ebx,eax
call ReadHex
and eax,ebx
call WriteHex
```

### OR_op

``` asm
call ReadHex
mov ebx,eax
call ReadHex
or eax,ebx
call WriteHex
```

### NOT_op

``` asm
call ReadHex
not eax
call WriteHex
```

### XOR_op

``` asm
call ReadHex
mov ebx,eax
call ReadHex
xor eax,ebx
call WriteHex
```

**핵심:** 모든 연산은 32비트 EAX/EBX를 사용하고 결과를 16진수로
표시한다.

------------------------------------------------------------------------

## 7. 확률과 색상 (Probabilities and Colors)

**질문:** 20줄의 텍스트를 출력하되 각 줄의 색상을 무작위로 선택한다.

-   흰색: 30%
-   파란색: 10%
-   초록색: 60%

**답안 원리:** 0\~9 난수를 생성하여 구간을 나눈다.

``` asm
mov eax,10
call RandomRange

cmp eax,2
jbe WhiteColor       ; 0,1,2 = 30%

cmp eax,3
je BlueColor         ; 3 = 10%

jmp GreenColor       ; 4~9 = 60%
```

**풀이:** 10개의 동일확률 결과 중 3개를 흰색, 1개를 파란색, 6개를
초록색에 배정하면 각각 30%, 10%, 60%가 된다.

------------------------------------------------------------------------

## 8. 메시지 암호화 (Message Encryption)

**질문:** 여러 문자로 이루어진 키를 사용해 평문을 암호화/복호화하라.
평문의 각 바이트와 키의 대응 바이트를 XOR하며, 키가 끝나면 처음부터
반복한다.

예시 키: `"ABXmv#7"`

**핵심 알고리즘:**

``` text
messageIndex = 0
keyIndex = 0

while messageIndex < messageLength
    message[messageIndex] =
        message[messageIndex] XOR key[keyIndex]

    messageIndex++
    keyIndex++

    if keyIndex == keyLength
        keyIndex = 0
```

**어셈블리 구현 핵심:**

``` asm
mov al,[esi]      ; 메시지 바이트
xor al,[edi]      ; 키 바이트와 XOR
mov [esi],al

inc esi
inc edi
```

키 끝에 도달하면 EDI를 키 시작 주소로 되돌린다.

**중요:** XOR는 같은 키로 두 번 적용하면 원래 값으로 돌아오므로 동일
프로시저를 암호화와 복호화에 사용할 수 있다.

------------------------------------------------------------------------

## 9. PIN 검증 (Validating a PIN)

**질문:** 5자리 PIN의 각 자리별 허용 범위는 다음과 같다.

  자리     최소   최대
  ------ ------ ------
  1           5      9
  2           2      5
  3           4      8
  4           1      4
  5           3      6

`Validate_PIN` 프로시저는 5바이트 PIN 배열의 포인터를 받는다. 잘못된
숫자가 있으면 그 자리 번호(1\~5)를 EAX에 즉시 반환하고, 모두 유효하면
0을 반환한다. 다른 레지스터는 보존한다.

**답안 예시:**

``` asm
.data
minVals BYTE 5,2,4,1,3
maxVals BYTE 9,5,8,4,6

.code
Validate_PIN PROC USES ebx ecx edx esi edi
    ; ESI = PIN 배열 주소
    mov edi,0
    mov ecx,5

CheckDigit:
    movzx eax,BYTE PTR [esi+edi]

    movzx ebx,minVals[edi]
    cmp eax,ebx
    jb Invalid

    movzx ebx,maxVals[edi]
    cmp eax,ebx
    ja Invalid

    inc edi
    loop CheckDigit

    xor eax,eax
    ret

Invalid:
    mov eax,edi
    inc eax              ; 인덱스 0~4 -> 자리 번호 1~5
    ret
Validate_PIN ENDP
```

**예시:** `52413`은 유효하므로 EAX=0. 첫 번째 숫자가 범위를 벗어나면
EAX=1을 반환한다.

------------------------------------------------------------------------

## 10. 패리티 검사 (Parity Checking)

**질문:** 바이트 배열 전체의 1비트 개수가 짝수이면 EAX=1(True), 홀수이면
EAX=0(False)을 반환하는 프로시저를 작성한다. 배열 포인터와 길이를
전달하고 다른 레지스터는 보존한다.

**핵심 아이디어:** 모든 바이트를 XOR한 뒤 최종 XOR 결과의 패리티를
검사한다.

``` asm
; ESI = 배열 주소
; ECX = 배열 길이

CheckParity PROC USES ebx ecx edx esi
    xor al,al

XorLoop:
    xor al,[esi]
    inc esi
    loop XorLoop

    ; TEST가 PF를 최종 AL 기준으로 설정
    test al,al
    jpo OddParity

    mov eax,1
    ret

OddParity:
    mov eax,0
    ret
CheckParity ENDP
```

**풀이:** 여러 바이트를 XOR하면 전체 데이터의 패리티 관계를 하나의
바이트로 축약할 수 있다. 마지막 `TEST AL,AL` 직후 PF를 검사해야 하며, 그
사이에 PF를 변경하는 명령을 넣지 않는 것이 중요하다.

------------------------------------------------------------------------

# 정리

이 장의 핵심은 다음과 같다.

-   `AND`, `OR`, `XOR`, `NOT`, `TEST`
-   `CMP`와 조건 플래그
-   signed / unsigned 조건부 점프 구분
-   short-circuit evaluation
-   비트맵 집합 연산
-   조건 분기와 반복문을 어셈블리로 구현하는 방법
