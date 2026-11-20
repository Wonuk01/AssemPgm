# Programming Exercises — Chapter 10.8

> 2026년 11월 19일 수업 및 실습 자료  
> 주제: MASM 매크로 프로그래밍

이 문서는 문제의 한글 번역, 구현 방향, 핵심 코드 및 테스트 방법을 정리한다. 각 실습은 Irvine32 라이브러리를 사용하는 32비트 MASM 환경을 기준으로 한다.

## 1. mReadkey 매크로

**문제 번역:** 키 입력을 기다렸다가 눌린 키의 ASCII 코드와 키보드 스캔 코드를 반환하는 매크로를 작성한다. 매크로는 두 인수로 ASCII 코드 저장 변수와 스캔 코드 저장 변수를 받는다. 교재 링크 라이브러리의 `ReadChar`를 호출한다.

**사용 예시:**

```asm
.data
ascii BYTE ?
scan  BYTE ?

.code
mReadkey ascii, scan
```

**구현 방향:**
1. `ReadChar`를 호출한다.
2. 반환되는 ASCII 코드와 스캔 코드를 각각 매크로 인수의 메모리 변수에 저장한다.
3. `ReadChar`가 실제로 어떤 레지스터에 두 값을 반환하는지 교재 라이브러리 정의를 확인한다.

**주의:** Irvine32의 일반적인 `ReadChar`는 AL에 입력 문자를 반환한다. 스캔 코드까지 반환하는 인터페이스는 교재의 링크 라이브러리 구현을 확인해야 하므로, 반환 레지스터를 임의로 가정하면 안 된다.

## 2. mWriteStringAttr 매크로

**문제 번역:** 지정한 텍스트 색상으로 널 종료 문자열을 출력하는 매크로를 작성한다. 매개변수는 문자열 이름과 색상이다. `SetTextColor`를 호출한다.

**사용 예시:**

```asm
.data
myString BYTE "Here is my string",0

.code
mWriteStringAttr myString, white
```

**구현 방향 예시:**

```asm
mWriteStringAttr MACRO stringName, colorValue
    push eax
    push edx

    mov eax, colorValue
    call SetTextColor

    mov edx, OFFSET stringName
    call WriteString

    pop edx
    pop eax
ENDM
```

**테스트:** 서로 다른 문자열에 `white`, `lightGreen`, `lightRed` 등 서로 다른 색상을 적용하여 출력한다. 색상 상수 이름은 사용하는 Irvine32 라이브러리에서 지원하는지 확인한다.

## 3. mMove32 매크로

**문제 번역:** 32비트 메모리 피연산자 두 개를 전달받아 원본 값을 목적지에 복사하는 `mMove32` 매크로를 작성한다.

**핵심 코드:**

```asm
mMove32 MACRO destination, source
    push eax
    mov eax, source
    mov destination, eax
    pop eax
ENDM
```

**테스트 예시:**

```asm
.data
sourceVal DWORD 123456
destVal   DWORD ?

.code
mMove32 destVal, sourceVal
```

**해설:** x86의 `MOV` 명령은 일반적으로 메모리에서 메모리로 직접 이동할 수 없다. 따라서 레지스터를 중간에 사용한다. 두 피연산자는 모두 32비트 메모리 변수여야 한다.

## 4. mMult32 매크로

**문제 번역:** 두 개의 32비트 메모리 피연산자를 곱하고 32비트 결과를 생성하는 `mMult32` 매크로를 작성한다.

**핵심 코드:**

```asm
mMult32 MACRO destination, source
    push eax
    mov eax, destination
    imul eax, source
    mov destination, eax
    pop eax
ENDM
```

**테스트 예시:**

```asm
.data
value1 DWORD 10
value2 DWORD 20

.code
mMult32 value1, value2
; value1 = 200
```

**해설:** `imul`의 2피연산자 형식은 첫 번째 피연산자에 곱셈 결과를 저장한다. 이 예시는 결과를 첫 번째 변수에 덮어쓴다. 부호 없는 정수의 곱셈이 필요하다면 `mul` 사용 여부와 상위 32비트 처리도 고려해야 한다.

## 5. mReadInt 매크로

**문제 번역:** 표준 입력에서 16비트 또는 32비트 부호 있는 정수를 읽어 지정한 변수에 저장하는 `mReadInt` 매크로를 작성한다. 조건부 연산자를 이용해 결과 변수 크기에 맞게 동작하도록 한다.

**구현 방향:**
- `TYPE destination`으로 변수의 크기를 확인한다.
- `ReadInt`로 정수를 입력받는다.
- WORD 변수라면 AX의 하위 16비트를 저장한다.
- DWORD 변수라면 EAX 전체를 저장한다.
- BYTE까지 지원할 필요가 있다면 문제에서 요구한 범위(WORD/DWORD)와 별도로 처리한다.

**핵심 코드 예시:**

```asm
mReadInt MACRO destination
    call ReadInt
    IF TYPE destination EQ 2
        mov WORD PTR destination, ax
    ELSEIF TYPE destination EQ 4
        mov DWORD PTR destination, eax
    ELSE
        %OUT <mReadInt: unsupported operand size>
    ENDIF
ENDM
```

**테스트 예시:**

```asm
.data
smallValue SWORD ?
largeValue SDWORD ?

.code
mReadInt smallValue
mReadInt largeValue
```

## 6. mWriteInt 매크로

**문제 번역:** `WriteInt` 라이브러리 프로시저를 호출하여 부호 있는 정수를 출력하는 `mWriteInt` 매크로를 작성한다. 인수는 BYTE, WORD, DWORD가 될 수 있으며 조건부 연산자로 크기에 맞게 처리한다.

**구현 방향:**
- `TYPE`으로 피연산자의 크기를 확인한다.
- BYTE 또는 WORD는 EAX로 부호 확장한다.
- DWORD는 EAX에 그대로 전달한다.
- `WriteInt`를 호출한다.

**핵심 코드 예시:**

```asm
mWriteInt MACRO source
    push eax

    IF TYPE source EQ 1
        movsx eax, BYTE PTR source
    ELSEIF TYPE source EQ 2
        movsx eax, WORD PTR source
    ELSEIF TYPE source EQ 4
        mov eax, DWORD PTR source
    ELSE
        %OUT <mWriteInt: unsupported operand size>
    ENDIF

    call WriteInt
    pop eax
ENDM
```

**테스트 예시:**

```asm
.data
byteVal SBYTE -10
wordVal SWORD -300
dwordVal SDWORD -50000

.code
mWriteInt byteVal
call Crlf
mWriteInt wordVal
call Crlf
mWriteInt dwordVal
call Crlf
```

## 7. The Professor's Lost Phone

**문제 번역:** 교수가 캠퍼스를 무작위로 걷는 Drunkard's Walk 프로그램에서 휴대전화를 잃어버리도록 수정한다. 걷는 동안 무작위 시간 간격이 지난 시점에 휴대전화를 떨어뜨리며, 실행할 때마다 휴대전화를 잃어버리는 시점과 위치가 달라져야 한다.

**구현 방향:**
1. 걷기 시작 전에 휴대전화를 떨어뜨릴 걸음 수를 무작위로 정한다.
2. 이동할 때마다 걸음 수를 증가시킨다.
3. 현재 걸음 수가 목표 걸음 수와 같아지면 현재 좌표에 휴대전화가 떨어졌음을 표시한다.
4. 휴대전화를 떨어뜨린 뒤에는 다시 떨어뜨리지 않도록 Boolean 플래그를 둔다.

**핵심 코드 예시:**

```asm
call Randomize

mov eax, 100
call RandomRange
inc eax                 ; 1~100
mov dropStep, eax

; 이동 루프 안에서
inc currentStep
mov eax, currentStep
cmp eax, dropStep
jne NotDropped

mov phoneDropped, 1
; 현재 위치에 휴대전화 표시

NotDropped:
```

`dropStep`, `currentStep`, `phoneDropped`는 데이터 영역에 선언해야 한다.

## 8. Drunkard's Walk with Probabilities

**문제 번역:** 이전 프로그램에서는 네 방향으로 이동할 확률이 동일하여 시작 지점에서 멀리 벗어나지 않는 경향이 있다. 다음 확률을 적용하도록 수정한다.

- 50%: 이전과 같은 방향으로 계속 이동
- 10%: 반대 방향으로 이동
- 20%: 오른쪽으로 회전
- 20%: 왼쪽으로 회전

루프가 시작되기 전에 기본 시작 방향을 지정한다.

**구현 방향:**
1. `RandomRange 10`으로 0~9의 난수를 만든다.
2. 0~4이면 같은 방향(50%).
3. 5이면 반대 방향(10%).
4. 6~7이면 오른쪽(20%).
5. 8~9이면 왼쪽(20%).
6. 방향을 0~3의 값으로 관리하면 회전과 반대 방향 계산이 간단하다.

**방향 계산 예시:**

```asm
; direction: 0~3
; 난수는 EAX에 0~9로 생성되어 있다고 가정

cmp eax, 5
jb KeepDirection

cmp eax, 6
jb ReverseDirection

cmp eax, 8
jb TurnRight

; 8~9: TurnLeft
inc direction
and direction, 3
jmp DirectionDone

KeepDirection:
jmp DirectionDone

ReverseDirection:
add direction, 2
and direction, 3
jmp DirectionDone

TurnRight:
inc direction
and direction, 3

DirectionDone:
```

**주의:** 위 예시는 방향 번호의 순서를 시계 방향으로 정의한 경우이다. 실제 이동 코드의 방향 번호와 일치하도록 오른쪽/왼쪽 계산을 맞춰야 한다.

## 9. Shifting Multiple Doublewords

**문제 번역:** `SHRD`와 `SHLD` 명령을 사용하여 32비트 정수 배열을 지정한 비트 수만큼 오른쪽 또는 왼쪽으로 이동시키는 매크로를 작성한다. 같은 배열을 양방향으로 이동해 결과를 출력한다. 배열은 리틀 엔디안 순서라고 가정한다.

**매크로 형식:**

```asm
mShiftDoublewords MACRO arrayName, direction, numberOfBits
```

**구현 방향:**
- 배열의 DWORD들을 하나의 연속된 비트열처럼 취급한다.
- 왼쪽 이동은 낮은 인덱스에서 높은 인덱스 방향으로 carry 역할을 할 인접 DWORD를 고려한다.
- 오른쪽 이동은 반대 순서로 처리한다.
- `SHLD`와 `SHRD`는 인접한 레지스터의 비트를 가져오므로 배열 경계와 처리 순서가 중요하다.
- 단순히 각 DWORD에 독립적으로 `SHL`/`SHR`을 적용하는 것은 배열 전체의 비트 이동과 다르다.

**주의:** 이 문제는 레지스터 보존, 배열 길이, 비트 수(0~31), 방향 인수의 유효성 검사를 포함해야 한다. `SHLD`/`SHRD`를 이용할 때 각 DWORD의 이웃 값이 올바른 레지스터에 들어가도록 구성해야 한다.

## 10. Three-Operand Instructions

**문제 번역:** 일부 명령어 집합에서 지원하는 3-피연산자 산술 연산을 매크로로 구현한다. EAX는 매크로 연산 전용이며 보존하지 않아도 된다. 매크로에서 수정하는 다른 레지스터는 보존해야 한다. 모든 인수는 부호 있는 메모리 DWORD이다.

작성할 매크로:
- `add3 destination, source1, source2`
- `sub3 destination, source1, source2` — destination = source1 - source2
- `mul3 destination, source1, source2`
- `div3 destination, source1, source2` — destination = source1 / source2

**핵심 코드 예시:**

```asm
add3 MACRO destination, source1, source2
    mov eax, source1
    add eax, source2
    mov destination, eax
ENDM

sub3 MACRO destination, source1, source2
    mov eax, source1
    sub eax, source2
    mov destination, eax
ENDM

mul3 MACRO destination, source1, source2
    mov eax, source1
    imul eax, source2
    mov destination, eax
ENDM

div3 MACRO destination, source1, source2
    ; 0으로 나누는 경우는 호출 측에서 방지해야 함
    mov eax, source1
    cdq
    idiv source2
    mov destination, eax
ENDM
```

**해설:**
- `add3`: 두 값을 더한다.
- `sub3`: 첫 번째 값에서 두 번째 값을 뺀다.
- `mul3`: 부호 있는 곱셈을 수행한다.
- `div3`: `CDQ`로 EAX의 부호를 EDX:EAX로 확장한 다음 `IDIV`를 실행한다. 몫은 EAX에 저장된다.
- EAX는 매크로 전용이므로 보존하지 않는다. 위 코드에서 다른 레지스터는 변경하지 않는다.

**테스트 예시:**

```asm
.data
w DWORD 10
y DWORD 5
z DWORD 3
temp DWORD ?
x DWORD ?

.code
add3 temp, w, y       ; temp = 10 + 5 = 15
mul3 x, temp, z       ; x = 15 * 3 = 45
```

**추가 테스트 권장 사항:**
- 덧셈: 양수 + 음수
- 뺄셈: 결과가 음수인 경우
- 곱셈: 음수 × 양수
- 나눗셈: 나누어떨어지는 경우와 나머지가 있는 경우
- 나누는 값이 0인 경우는 실행 전에 검사

---

## 실습 전체 점검표

- [ ] 매크로 인수의 자료형과 크기를 확인했는가?
- [ ] 매크로 내부에서 사용하는 레이블에 `LOCAL`을 적용했는가?
- [ ] 필요한 레지스터를 보존했는가?
- [ ] `ReadInt`, `WriteInt`, `ReadString`, `WriteString`의 인수 및 반환 규칙을 확인했는가?
- [ ] 배열을 순회할 때 `LENGTHOF`, `SIZEOF`, `TYPE`을 구분해서 사용했는가?
- [ ] 조건부 어셈블리 `IF`와 실행 중 분기 명령을 혼동하지 않았는가?
