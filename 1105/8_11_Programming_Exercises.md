# Chapter 8 — 8.11 Programming Exercises (10문항)

> 32비트 MASM + Irvine32, `INCLUDE Irvine32.inc` 사용. 아래는 **문항별 핵심 정답 프로시저와 테스트 호출 예시**를 정리한 학습용 코드이다. 서로 다른 문항의 `main`은 독립적으로 실행해야 한다. 색상은 Irvine32의 4비트 속성 기준이다.

## 1. FindLargest ★★
**요구:** 부호 있는 DWORD 배열에서 최댓값을 EAX에 반환. 세 배열로 테스트.
```asm
FindLargest PROTO pArr:PTR SDWORD, n:DWORD
FindLargest PROC USES esi ecx ebx, pArr:PTR SDWORD, n:DWORD
    mov esi, pArr
    mov ecx, n
    test ecx, ecx
    jz emptyArray              ; 길이 0은 예외적으로 0 반환
    mov eax, [esi]
    add esi, 4
    dec ecx
L1:
    test ecx, ecx
    jz done
    mov ebx, [esi]
    cmp ebx, eax
    jle skip                   ; signed 비교
    mov eax, ebx
skip:
    add esi, 4
    dec ecx
    jmp L1
emptyArray:
    xor eax, eax
done:
    ret
FindLargest ENDP

.data
a1 SDWORD -9, -2, -30
a2 SDWORD 4, -8, 17, 0
a3 SDWORD -100, 45, 7, 99, -1
.code
; main 내부
INVOKE FindLargest, ADDR a1, LENGTHOF a1 ; EAX=-2
INVOKE FindLargest, ADDR a2, LENGTHOF a2 ; EAX=17
INVOKE FindLargest, ADDR a3, LENGTHOF a3 ; EAX=99
```
**포인트:** 부호 있는 비교 `jle`, EAX 외 변경 레지스터 `USES` 보존. 배열 길이는 1 이상을 권장한다.

## 2. Chess Board ★
**요구:** 8×8 흰색/회색 칸, 전역변수 없이 매개변수로 그리기.
```asm
DrawSquare PROTO x:BYTE, y:BYTE, color:DWORD
DrawSquare PROC USES eax edx, x:BYTE, y:BYTE, color:DWORD
    mov eax, color
    shl eax, 4
    call SetTextColor
    mov dl, x
    mov dh, y
    call Gotoxy
    mov al, ' '
    call WriteChar
    call WriteChar
    ret
DrawSquare ENDP

DrawBoard PROTO colored:DWORD
DrawBoard PROC USES eax ebx ecx edx esi edi, colored:DWORD
    xor esi, esi              ; row
rowLoop:
    xor edi, edi              ; col
colLoop:
    mov eax, esi
    add eax, edi
    and eax, 1
    mov ebx, white
    test eax, eax
    jz paint
    mov ebx, colored
paint:
    mov eax, edi
    shl eax, 1
    mov edx, esi
    INVOKE DrawSquare, al, dl, ebx
    inc edi
    cmp edi, 8
    jb colLoop
    inc esi
    cmp esi, 8
    jb rowLoop
    ret
DrawBoard ENDP
```
`white`와 `gray`는 Irvine32 색상 상수다. 색상 복구는 필요 시 `SetTextColor`로 수행한다.

## 3. Chess Board with Alternating Colors ★
**요구:** 0~15 배경색을 500ms마다 표시, 흰 칸 고정. 2번의 DrawBoard 사용.
```asm
    mov esi, 0
again:
    INVOKE DrawBoard, esi
    mov eax, 500
    call Delay
    inc esi
    cmp esi, 16
    jb again
```
**해설:** 16번 다시 그리며 짝수 칸은 white로 유지한다. 루프 레지스터 ESI는 main에서 사용.

## 4. FindThrees ★★★
**요구:** 연속된 3이 3개 있으면 EAX=1, 없으면 0.
```asm
FindThrees PROTO pArr:PTR DWORD, n:DWORD
FindThrees PROC USES esi ecx, pArr:PTR DWORD, n:DWORD
    mov esi, pArr
    mov ecx, n
    xor eax, eax
    cmp ecx, 3
    jb done
    sub ecx, 2
scan:
    cmp DWORD PTR [esi], 3
    jne next
    cmp DWORD PTR [esi+4], 3
    jne next
    cmp DWORD PTR [esi+8], 3
    jne next
    mov eax, 1
    jmp done
next:
    add esi, 4
    loop scan
done:
    ret
FindThrees ENDP
; [1,3,3,3,2] => 1 / [3,3,2,3] => 0
```

## 5. DifferentInputs ★★
**요구:** 세 인수가 모두 다르면 1, 중복되면 0. 다섯 번 테스트.
```asm
DifferentInputs PROTO a:DWORD, b:DWORD, c:DWORD
DifferentInputs PROC a:DWORD, b:DWORD, c:DWORD
    mov eax, a
    cmp eax, b
    je notDifferent
    cmp eax, c
    je notDifferent
    mov eax, b
    cmp eax, c
    je notDifferent
    mov eax, 1
    ret
notDifferent:
    xor eax, eax
    ret
DifferentInputs ENDP
; 테스트 (1,2,3)->1 (1,1,2)->0 (1,2,1)->0
;       (2,1,1)->0 (-1,0,1)->1
```

## 6. Exchanging Integers ★★
**요구:** 연속된 정수 쌍을 Swap으로 교환.
```asm
Swap PROTO p1:PTR DWORD, p2:PTR DWORD
Swap PROC USES esi edi eax, p1:PTR DWORD, p2:PTR DWORD
    mov esi, p1
    mov edi, p2
    mov eax, [esi]
    xchg eax, [edi]
    mov [esi], eax
    ret
Swap ENDP

.data
nums DWORD 7,2,9,4,1,8
.code
    mov esi, OFFSET nums
    mov ecx, LENGTHOF nums / 2
pairLoop:
    lea eax, [esi+4]
    INVOKE Swap, esi, eax
    add esi, 8
    loop pairLoop
```
홀수 길이의 마지막 원소는 그대로 둔다.

## 7. Greatest Common Divisor ★★
**요구:** 재귀 유클리드 알고리즘. 5개 쌍 테스트.
```asm
GCD PROTO a:DWORD, b:DWORD
GCD PROC USES ebx edx, a:DWORD, b:DWORD
    mov ebx, b
    test ebx, ebx
    jnz recurse
    mov eax, a
    ret
recurse:
    mov eax, a
    xor edx, edx
    div ebx
    INVOKE GCD, ebx, edx
    ret
GCD ENDP
; (5,20)=5, (24,18)=6, (11,7)=1,
; (432,226)=2, (26,13)=13
```
**포인트:** `a % b`를 EDX에서 얻고 `GCD(b, a%b)` 재귀 호출. 0 이상의 정수 입력 전제.

## 8. CountMatches ★★
**요구:** 같은 위치에서 동일한 DWORD 개수 반환.
```asm
CountMatches PROTO pX:PTR SDWORD, pY:PTR SDWORD, n:DWORD
CountMatches PROC USES esi edi ecx ebx, pX:PTR SDWORD, pY:PTR SDWORD, n:DWORD
    mov esi, pX
    mov edi, pY
    mov ecx, n
    xor eax, eax
    jecxz done
L1:
    mov ebx, [esi]
    cmp ebx, [edi]
    jne skip
    inc eax
skip:
    add esi, 4
    add edi, 4
    loop L1
done:
    ret
CountMatches ENDP
; INVOKE CountMatches, ADDR arr1, ADDR arr2, LENGTHOF arr1
```

## 9. CountNearMatches ★★
**요구:** 각 쌍의 절댓값 차이가 diff 이하이면 개수 증가.
```asm
CountNearMatches PROTO pX:PTR SDWORD, pY:PTR SDWORD, n:DWORD, diff:DWORD
CountNearMatches PROC USES esi edi ecx ebx edx, pX:PTR SDWORD, pY:PTR SDWORD, n:DWORD, diff:DWORD
    mov esi, pX
    mov edi, pY
    mov ecx, n
    xor eax, eax
    jecxz done
L1:
    mov ebx, [esi]
    mov edx, [edi]
    cmp ebx, edx
    jae xGreater             ; unsigned 값만을 위한 간단 구현
    xchg ebx, edx
xGreater:
    sub ebx, edx
    cmp ebx, diff
    ja skip
    inc eax
skip:
    add esi, 4
    add edi, 4
    loop L1
done:
    ret
CountNearMatches ENDP
```
**중요:** 위 `jae` 비교 방식은 **부호 있는 SDWORD의 극단값을 포함할 때에도** 두 값의 비트 패턴 간 차이를 32비트로 구하지만, 실제 수학적 차이가 `2^32-1`까지 가능하여 뺄셈 오버플로로 잘못 판정할 수 있다. **일반적인 작은 정수 데이터에서만 사용**하고, 전체 SDWORD 범위의 정확성이 필요하면 64비트 확장 산술로 구현한다. 원문 마지막 `CountMatches` PROTO는 문맥상 `CountNearMatches`의 오기로 보인다.

## 10. Show Procedure Parameters ★★★
**요구:** 호출한 프로시저의 매개변수 주소와 16진수 값을 낮은 주소부터 출력.

```asm
ShowParams PROTO n:DWORD
ShowParams PROC USES esi ecx eax edx, n:DWORD
    ; 현재 ShowParams의 [EBP]는 호출자 EBP를 저장함
    mov esi, [ebp]          ; 호출자(MySample)의 EBP
    add esi, 8              ; 첫 번째 매개변수 주소
    mov ecx, n
    jecxz done
L1:
    mov edx, OFFSET addrLabel
    call WriteString
    mov eax, esi
    call WriteHex
    mov edx, OFFSET equalLabel
    call WriteString
    mov eax, [esi]
    call WriteHex
    call Crlf
    add esi, 4
    loop L1
done:
    ret
ShowParams ENDP

.data
addrLabel BYTE 'Address ',0
equalLabel BYTE ' = ',0
.code
MySample PROC first:DWORD, second:DWORD, third:DWORD
    INVOKE ShowParams, 3
    ret
MySample ENDP
; INVOKE MySample, 1234h, 5000h, 6543h
```
**해설:** 출력 주소는 실행마다 다르다. 예: `Address 0012FF80 = 00001234`. `ShowParams`에서 표준 EBP 프레임을 사용하는 환경이 전제이며, `MySample`도 EBP 프레임을 유지해야 한다. 호출자 프레임의 `[EBP+8]`부터 인수들이 있다.

---
## 시험 핵심 요약
- `PROTO` 선언 → `PROC` 구현 → `INVOKE` 호출 순서.
- `EAX` 반환, 다른 변경 레지스터는 `USES` 등으로 보존.
- 배열 포인터는 주소, `LENGTHOF`는 원소 수, `TYPE`은 원소 바이트 크기.
- signed 최댓값은 `jg/jle`; 반복 비교는 경계값(길이 0·1·2) 점검.
- `EBP+8`부터 인수, `EBP+4` 복귀 주소, `EBP` 이전 프레임 포인터.
