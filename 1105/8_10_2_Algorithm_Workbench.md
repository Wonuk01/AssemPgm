# Chapter 8 — 8.10.2 Algorithm Workbench (11문항)

> MASM 32비트, Irvine32 환경. 각 문제에 정답 코드와 간단한 설명을 붙임. 예제들은 독립적인 코드 조각이며 전체 프로젝트에서는 선언/정의를 합쳐 사용한다.

## 1. AddThree 호출 시 EBP를 PUSH한 직후 스택 프레임
```asm
push 10h
push 20h
push 30h
call AddThree
; AddThree 내부: push ebp
```

```text
높은 주소
[EBP+16]  00000010h  ; 첫 번째 push
[EBP+12]  00000020h
[EBP+ 8]  00000030h  ; 마지막 push, 첫 매개변수
[EBP+ 4]  복귀 주소
[EBP   ]  이전 EBP       <-- ESP = EBP
낮은 주소
```
**해설:** 스택은 낮은 주소 방향으로 성장한다. `push ebp` 직후 아직 `mov ebp,esp`를 실행하지 않았더라도 위 오프셋 관계는 새 ESP를 기준으로 성립하며, EBP를 새 프레임 기준으로 설정한 뒤에 `[ebp+8]`처럼 접근한다.

## 2. AddThree: 세 정수 합을 EAX에 반환
```asm
AddThree PROTO a:SDWORD, b:SDWORD, c:SDWORD
AddThree PROC a:SDWORD, b:SDWORD, c:SDWORD
    mov eax, a
    add eax, b
    add eax, c
    ret
AddThree ENDP
; INVOKE AddThree, 30h, 20h, 10h
```
**해설:** PROC 선언 매개변수와 `INVOKE` 순서가 일치해야 한다. 기본 32비트 STDCALL 설정을 전제로 한다.

## 3. DWORD 배열 포인터 pArray 지역 변수
```asm
LOCAL pArray:PTR DWORD
```

## 4. 20바이트 배열 buffer 지역 변수
```asm
LOCAL buffer[20]:BYTE
```

## 5. 부호 없는 16비트 정수 포인터 pwArray 지역 변수
```asm
LOCAL pwArray:PTR WORD
```

## 6. 부호 있는 8비트 정수 myByte 지역 변수
```asm
LOCAL myByte:SBYTE
```

## 7. 20개 DWORD 배열 myArray 지역 변수
```asm
LOCAL myArray[20]:DWORD
```

> 3~7번 `LOCAL`은 반드시 `PROC` 내부에서 사용한다.

## 8. SetColor: 전경색과 배경색
```asm
SetColor PROTO forecolor:DWORD, backcolor:DWORD
SetColor PROC USES ebx, forecolor:DWORD, backcolor:DWORD
    mov eax, backcolor
    shl eax, 4
    or eax, forecolor
    call SetTextColor
    ret
SetColor ENDP
```
**해설:** Irvine32 `SetTextColor`는 EAX의 하위 바이트를 사용하며 배경색은 상위 니블, 전경색은 하위 니블이다. 입력 색상은 0~15로 가정한다.

## 9. WriteColorChar: 문자와 두 색상
```asm
WriteColorChar PROTO char:BYTE, forecolor:DWORD, backcolor:DWORD
WriteColorChar PROC USES eax edx, char:BYTE, forecolor:DWORD, backcolor:DWORD
    INVOKE SetColor, forecolor, backcolor
    mov al, char
    call WriteChar
    ret
WriteColorChar ENDP
```
**해설:** `WriteChar`는 AL의 문자를 출력한다. SetColor 프로시저는 8번을 사용한다.

## 10. DumpMemory: Irvine32 DumpMem 감싸기
```asm
DumpMemory PROTO address:PTR BYTE, itemCount:DWORD, itemSize:DWORD
DumpMemory PROC USES esi ecx ebx, address:PTR BYTE, itemCount:DWORD, itemSize:DWORD
    mov esi, address
    mov ecx, itemCount
    mov ebx, itemSize
    call DumpMem
    ret
DumpMemory ENDP

.data
array DWORD 10h, 20h, 30h
.code
; INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array
```
**해설:** DumpMem의 입력은 ESI=시작 주소, ECX=원소 수, EBX=원소 크기이다.

## 11. MultArray 선언과 PROTO
```asm
MultArray PROTO pFirst:PTR DWORD, pSecond:PTR DWORD, count:DWORD

MultArray PROC pFirst:PTR DWORD, pSecond:PTR DWORD, count:DWORD
    ; 문제는 선언만 요구함. 실제 곱셈 구현은 별도.
    ret
MultArray ENDP
```
**해설:** 두 개의 DWORD 배열 주소와 배열 길이를 받는다.

## 시험 직전 핵심
- `PTR WORD` = 16비트 원소를 가리키는 포인터, 포인터 자체는 32비트.
- `LOCAL arr[20]:DWORD` = 80바이트 지역 배열.
- `USES`는 사용 레지스터를 보존·복원하도록 MASM에 지시한다.
- `INVOKE`는 PROTO의 타입/인수 정보를 사용해 호출 코드를 생성한다.
