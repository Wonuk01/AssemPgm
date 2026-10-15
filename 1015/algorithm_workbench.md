# Chapter 6 Conditional Processing --- Algorithm Workbench

> 문제를 한국어로 옮기고, 가능한 한 간단한 어셈블리 정답과 이유를 함께
> 정리했습니다.

## 1. ASCII 숫자를 이진 숫자값으로 변환

**질문:** AL에 ASCII 숫자 `'0'`\~`'9'`가 있으면 대응하는 0\~9 값으로
변환하라. AL이 이미 `00h`\~`09h`라면 그대로 두어라.

**답:**

``` asm
and al,0Fh
```

**풀이:** ASCII `'0'`\~`'9'`는 `30h`\~`39h`이고 하위 4비트가 실제
숫자값이다. 이미 0\~9인 값도 하위 4비트가 그대로이므로 한 명령으로
처리할 수 있다.

------------------------------------------------------------------------

## 2. 32비트 메모리 피연산자의 패리티 계산

**질문:** `B0 XOR B1 XOR B2 XOR B3` 공식을 사용하여 32비트 메모리 값의
네 바이트를 XOR하라.

**답 예시:**

``` asm
mov al,BYTE PTR value
xor al,BYTE PTR value+1
xor al,BYTE PTR value+2
xor al,BYTE PTR value+3
```

**풀이:** 최종 AL은 4개 바이트를 모두 XOR한 값이다. 이후 AL의 패리티
플래그(PF)를 검사하면 전체 비트 패리티를 판단할 수 있다.

------------------------------------------------------------------------

## 3. SetX에는 있지만 SetY에는 없는 원소

**질문:** 비트맵 집합 `SetX`, `SetY`가 있을 때 `SetX - SetY`를 나타내는
비트 문자열을 EAX에 만들어라.

**답:**

``` asm
mov eax,SetY
not eax
and eax,SetX
```

**풀이:** 집합 차집합은 `SetX AND (NOT SetY)`로 표현할 수 있다.

------------------------------------------------------------------------

## 4. unsigned DX \<= CX이면 L1으로 점프

**답:**

``` asm
cmp dx,cx
jbe L1
```

**풀이:** `JBE`는 unsigned 기준 Below or Equal이다.

------------------------------------------------------------------------

## 5. signed AX \> CX이면 L2로 점프

**답:**

``` asm
cmp ax,cx
jg L2
```

**풀이:** `JG`는 signed 기준 Greater이다.

------------------------------------------------------------------------

## 6. AL의 bit 0과 bit 1을 지우고 결과에 따라 분기

**질문:** AL의 0번, 1번 비트를 먼저 0으로 만든다. 결과가 0이면 L3,
아니면 L4로 점프하라.

**답:**

``` asm
and al,11111100b
jz L3
jmp L4
```

**풀이:** AND 명령 자체가 ZF를 갱신하므로 별도의 CMP가 필요 없다.

------------------------------------------------------------------------

## 7. AND 조건의 short-circuit 구현

**의사코드:**

``` text
if (val1 > ecx) AND (ecx > edx)
    X = 1
else
    X = 2
```

**답:** signed 비교라고 가정하면 다음과 같이 작성할 수 있다.

``` asm
mov eax,val1
cmp eax,ecx
jle ElsePart

cmp ecx,edx
jle ElsePart

mov X,1
jmp EndIf

ElsePart:
mov X,2

EndIf:
```

**핵심:** 첫 조건이 거짓이면 두 번째 조건을 검사하지 않고 바로 else로
이동한다.

------------------------------------------------------------------------

## 8. OR 조건의 short-circuit 구현

**의사코드:**

``` text
if (ebx > ecx) OR (ebx > val1)
    X = 1
else
    X = 2
```

**답:** signed 비교라고 가정한다.

``` asm
cmp ebx,ecx
jg TruePart

cmp ebx,val1
jg TruePart

mov X,2
jmp EndIf

TruePart:
mov X,1

EndIf:
```

**핵심:** 첫 조건이 참이면 두 번째 조건을 검사할 필요 없이 TruePart로
이동한다.

------------------------------------------------------------------------

## 9. 복합 AND/OR 조건의 short-circuit 구현

**의사코드:**

``` text
if (ebx > ecx AND ebx > edx) OR (edx > eax)
    X = 1
else
    X = 2
```

**답:** signed 비교라고 가정한다.

``` asm
cmp ebx,ecx
jle CheckSecondGroup

cmp ebx,edx
jg TruePart

CheckSecondGroup:
cmp edx,eax
jg TruePart

mov X,2
jmp EndIf

TruePart:
mov X,1

EndIf:
```

------------------------------------------------------------------------

## 10. while 및 복합 조건 구현

**의사코드:**

``` text
while N > 0
    if N != 3 AND (N < A OR N > B)
        N = N - 2
    else
        N = N - 1
```

**답:** 문제에서 A, B, N은 32비트 signed 정수이다.

``` asm
WhileLoop:
    cmp N,0
    jle EndWhile

    cmp N,3
    je SubOne

    mov eax,N
    cmp eax,A
    jl SubTwo

    cmp eax,B
    jg SubTwo

SubOne:
    sub N,1
    jmp WhileLoop

SubTwo:
    sub N,2
    jmp WhileLoop

EndWhile:
```

**핵심:** `N == 3`이면 AND 조건 전체가 거짓이므로 즉시 `N-1`로 이동한다.
`N != 3`일 때만 `(N < A OR N > B)`를 검사한다.
