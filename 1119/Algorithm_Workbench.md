# Algorithm Workbench — Chapter 10.7.2

> 2026년 11월 19일 수업 자료  
> 주제: Structures and Macros (구조체와 매크로)

아래 코드는 Irvine32 라이브러리와 MASM 문법을 사용하는 예시이다. 교재의 매크로 라이브러리에서 제공하는 매크로 이름이나 인수 규칙은 사용하는 버전에 따라 확인해야 한다.

## 1. SampleStruct 구조체 정의

**문제:** `field1`은 16비트 WORD 하나, `field2`는 32비트 DWORD 20개로 구성된 구조체를 정의한다.

**정답:**

```asm
SampleStruct STRUCT
    field1 WORD ?
    field2 DWORD 20 DUP(?)
SampleStruct ENDS
```

**해설:** `?`는 초기값을 지정하지 않는다는 뜻이다. `DUP(?)`는 초기화되지 않은 항목을 20개 만든다.

## 2. SYSTEMTIME 구조체의 wHour 필드 가져오기

**정답 예시:**

```asm
mov ax, systemTime.wHour
```

**해설:** `systemTime`은 SYSTEMTIME 형식의 구조체 변수라고 가정한다. `wHour`는 WORD 필드이므로 16비트 레지스터인 AX에 가져온다. 32비트 레지스터를 사용하려면 `movzx eax, systemTime.wHour`를 사용할 수 있다.

## 3. Triangle 구조체의 꼭짓점 초기화

**문제:** 꼭짓점을 `(0,0)`, `(5,0)`, `(7,6)`으로 초기화한다.

**정답:**

```asm
Triangle STRUCT
    Vertex1 COORD <>
    Vertex2 COORD <>
    Vertex3 COORD <>
Triangle ENDS

myTriangle Triangle <
    <0,0>,
    <5,0>,
    <7,6>
>
```

**해설:** `COORD`는 X와 Y 좌표를 WORD로 저장하는 구조체이다. 중첩 구조체를 초기화할 때 각 필드에 해당하는 값을 순서대로 지정한다.

## 4. Triangle 배열의 Vertex1을 무작위 좌표로 초기화

**정답 예시:**

```asm
.data
triangles Triangle 5 DUP(<>)
.code
    call Randomize

    mov esi, OFFSET triangles
    mov ecx, LENGTHOF triangles

L1:
    ; X 좌표: 0~10
    mov eax, 11
    call RandomRange
    mov [esi].Triangle.Vertex1.X, ax

    ; Y 좌표: 0~10
    mov eax, 11
    call RandomRange
    mov [esi].Triangle.Vertex1.Y, ax

    add esi, SIZEOF Triangle
    loop L1
```

**해설:** `RandomRange`는 EAX에 전달한 범위 n에 대해 0부터 n-1까지의 난수를 반환한다. 따라서 0~10을 얻으려면 EAX에 11을 넣는다. `Triangle`의 크기만큼 주소를 이동하면서 각 배열 원소를 처리한다.

## 5. mPrintChar 매크로 작성

**문제:** 문자와 반복 횟수를 받아 문자를 반복 출력한다.

**정답 예시:**

```asm
mPrintChar MACRO charVal, repeatCount
    LOCAL L1
    push eax
    push ecx

    mov al, charVal
    mov ecx, repeatCount

L1:
    call WriteChar
    loop L1

    pop ecx
    pop eax
ENDM
```

**호출 예시:**

```asm
mPrintChar 'X', 20
```

**해설:** `LOCAL`로 반복 레이블을 고유하게 만들고, `ECX`를 반복 횟수로 사용한다. `WriteChar`는 AL에 들어 있는 문자를 출력한다.

## 6. mGenRandom 매크로 작성

**문제:** n을 전달받아 0부터 n-1까지의 난수를 생성한다.

**정답 예시:**

```asm
mGenRandom MACRO n
    mov eax, n
    call RandomRange
ENDM
```

**사용 예시:**

```asm
mGenRandom 100     ; EAX에 0~99 난수 반환
```

## 7. mPromptInteger 매크로 작성

**문제:** 문자열 프롬프트를 출력하고 정수를 입력받아 DWORD 변수에 저장한다.

**정답 예시:**

```asm
mPromptInteger MACRO promptText, targetVar
    push edx
    mov edx, OFFSET promptText
    call WriteString
    call ReadInt
    mov targetVar, eax
    pop edx
ENDM
```

**사용 예시:**

```asm
.data
promptText BYTE "Enter the minimum value: ",0
minVal DWORD ?

.code
mPromptInteger promptText, minVal
```

**주의:** 교재의 예시처럼 문자열 리터럴을 직접 매크로 인수로 전달하려면 매크로 안에서 문자열 데이터를 생성하는 방식이 필요할 수 있다. 위 코드는 문자열 변수를 전달하는 형태이다.

## 8. mWriteAt 매크로 작성

**문제:** 커서를 지정한 위치로 이동한 뒤 문자열을 출력한다.

**정답 예시:**

```asm
mWriteAt MACRO xPos, yPos, textLabel
    mGotoxy xPos, yPos
    mWriteString textLabel
ENDM
```

**호출 예시:**

```asm
mWriteAt 10, 5, message
```

**해설:** `mGotoxy`로 커서 위치를 지정하고 `mWriteString`으로 문자열을 출력한다. 실제 인수 순서는 교재 매크로 라이브러리의 정의를 확인한다.

## 9. mWriteString 매크로 확장 코드

**문제:** `mWriteStr namePrompt`의 전처리기 확장 결과를 작성한다.

**일반적인 확장 예시:**

```asm
push edx
mov edx, OFFSET namePrompt
call WriteString
pop edx
```

**해설:** 매크로가 EDX를 보존하면서 문자열 주소를 EDX에 넣고 `WriteString`을 호출하는 형태라고 가정한 예시이다. 교재 Section 10.2.5의 실제 정의에 따라 확장 코드는 달라질 수 있다.

## 10. mReadString 매크로 확장 코드

**문제:** `mReadStr customerName`의 전처리기 확장 결과를 작성한다.

**일반적인 확장 예시:**

```asm
push edx
push ecx
mov edx, OFFSET customerName
mov ecx, SIZEOF customerName
call ReadString
pop ecx
pop edx
```

**해설:** `ReadString`은 EDX에 버퍼 주소, ECX에 버퍼 크기를 전달하는 Irvine32 입력 루틴이다. 실제 매크로가 사용하는 레지스터 보존 방식과 버퍼 크기 계산은 교재 정의를 기준으로 확인한다.

## 11. mDumpMemx 매크로 작성

**문제:** 변수 이름 하나를 받아 해당 변수의 주소, 항목 개수, 항목 크기를 `mDumpMem`에 전달한다.

**정답 예시:**

```asm
mDumpMemx MACRO varName
    mDumpMem OFFSET varName, LENGTHOF varName, TYPE varName
ENDM
```

**사용 예시:**

```asm
.data
numbers DWORD 10, 20, 30, 40

.code
mDumpMemx numbers
```

**해설:**
- `OFFSET`: 변수의 시작 주소
- `LENGTHOF`: 배열의 항목 개수
- `TYPE`: 항목 하나의 크기(바이트)

## 12. 기본 인수를 갖는 매크로 예시

**정답 예시:**

```asm
mShow MACRO textLabel, colorVal:=white
    ; colorVal을 생략하면 white가 기본값으로 사용됨
ENDM

mShow message
mShow message, lightGreen
```

**해설:** `:=` 뒤에 기본 인수를 지정한다. 두 번째 인수를 생략하면 기본값이 사용된다.

## 13. IF, ELSE, ENDIF 사용 예시

```asm
COUNT = 5

IF COUNT GT 3
    ; COUNT가 3보다 크면 이 부분이 어셈블됨
ELSE
    ; 그렇지 않으면 이 부분이 어셈블됨
ENDIF
```

## 14. Z가 0보다 작은지 검사하고 어셈블리 중 메시지 출력

**정답 예시:**

```asm
IF Z LT 0
    %OUT <Error: Z is invalid>
ENDIF
```

**해설:** `IF`는 어셈블리 시점에 상수 조건을 검사한다. 조건이 참이면 `%OUT` 메시지가 어셈블 과정에서 표시된다.

## 15. & 연산자 사용 예시

```asm
mMakeLabel MACRO number
    label&number BYTE "Example",0
ENDM

mMakeLabel 1
mMakeLabel 2
```

**확장 결과 예시:**

```asm
label1 BYTE "Example",0
label2 BYTE "Example",0
```

**해설:** `&`는 매개변수 `number`와 주변 텍스트를 연결하여 서로 다른 레이블 이름을 만든다.

## 16. mLocate 매크로 확장 결과

주어진 매크로:

```asm
mLocate MACRO xval,yval
    IF xval LT 0
        EXITM
    ENDIF
    IF yval LT 0
        EXITM
    ENDIF

    mov bx,0
    mov ah,2
    mov dh,yval
    mov dl,xval
    int 10h
ENDM
```

### (1) `mLocate -2,20`

**확장 결과:** 첫 번째 조건 `-2 LT 0`이 참이므로 `EXITM`에서 매크로 확장이 종료된다.

```asm
; 생성되는 실행 명령 없음
```

### (2) `mLocate 10,20`

**확장 결과:**

```asm
mov bx,0
mov ah,2
mov dh,20
mov dl,10
int 10h
```

**설명:** 두 값 모두 0 이상이므로 BIOS 인터럽트를 호출하는 코드가 생성된다.

### (3) `mLocate col,row`

주어진 데이터:

```asm
.data
row BYTE 15
col BYTE 60
```

**주의:** `IF`는 어셈블리 시점의 상수 표현식을 검사한다. `col`, `row`가 메모리 변수 이름이라면 그 안에 저장된 실행 시점의 값 60과 15를 조건식에서 읽어 검사하는 것은 아니다. 따라서 이 호출은 상수 인수 호출과 동일하게 단순 치환할 수 있다고 가정하면 안 된다. 교재의 MASM 버전과 매크로 인수 처리 규칙에 따라 조건식 오류가 발생할 수 있다.

**핵심:** 매크로의 `IF`는 실행 중의 `if`문이 아니라 어셈블 단계의 조건부 처리이다.
