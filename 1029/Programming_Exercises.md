# Chapter 7 Integer Arithmetic — Programming Exercises

> Programming Exercises는 단순 정답보다는 **무엇을 구현해야 하는지 + 핵심 알고리즘 + MASM 예제 구조** 중심으로 정리했습니다.

---

# 1. Display ASCII Decimal — WriteScaled

## 문제

ASCII 숫자 문자열에 **암시된 소수점(implied decimal point)**을 삽입해 출력하는 `WriteScaled` 프로시저를 작성합니다.

예:

```asm
DECIMAL_OFFSET = 5

decimal_one BYTE "100123456789765"
```

출력:

```text
1001234567.89765
```

입력 레지스터:

```text
EDX = 문자열 주소
ECX = 문자열 길이
EBX = 오른쪽에서부터 소수점 위치
```

---

## 핵심 아이디어

전체 길이가 15이고 decimal offset이 5라면:

```text
15 - 5 = 10
```

10개의 문자를 출력한 뒤 `.`을 출력하고 나머지 5개를 출력하면 됩니다.

---

## 예제 구조

```asm
WriteScaled PROC
    push eax
    push esi

    mov esi,edx
    sub ecx,ebx

L1:
    mov al,[esi]
    call WriteChar
    inc esi
    loop L1

    mov al,'.'
    call WriteChar

    mov ecx,ebx

L2:
    mov al,[esi]
    call WriteChar
    inc esi
    loop L2

    pop esi
    pop eax
    ret
WriteScaled ENDP
```

### 핵심

```text
앞부분 출력
→ '.'
→ 뒤의 decimal_offset만큼 출력
```

---

# 2. Extended Subtraction Procedure

## 문제

임의 크기의 두 binary integer를 빼는 프로시저 `Extended_Sub`를 작성합니다.

조건:

- 두 정수 크기는 같아야 함
- 크기는 32비트의 배수
- 테스트 값은 최소 10바이트 이상

---

## 핵심 명령어

```asm
SBB
```

`SBB`는 이전 뺄셈에서 발생한 borrow를 다음 계산에 반영합니다.

예:

```asm
sub eax,ebx
sbb edx,ecx
```

하위 DWORD에서 빌림이 발생하면 CF가 1이 되고, 다음 `SBB`가 이를 반영합니다.

---

## 기본 구조

```asm
Extended_Sub PROC
    clc

L1:
    mov eax,[esi]
    sbb eax,[edi]
    mov [edx],eax

    add esi,4
    add edi,4
    add edx,4

    loop L1

    ret
Extended_Sub ENDP
```

레지스터 역할 예:

```text
ESI = 첫 번째 정수
EDI = 두 번째 정수
EDX = 결과
ECX = DWORD 개수
```

---

# 3. Packed Decimal Conversion

## 문제

4바이트 packed decimal integer를 ASCII 숫자 문자열로 변환하는 `PackedToAsc` 프로시저를 작성합니다.

Packed decimal에서는 한 바이트에 숫자 두 개가 저장됩니다.

예:

```text
12h → "12"
34h → "34"
```

즉:

```text
12345678

packed:
12 34 56 78
```

---

## 핵심 원리

한 바이트:

```text
0110 0101
^^^^      → 상위 nibble
     ^^^^ → 하위 nibble
```

상위 숫자:

```asm
mov al,[esi]
shr al,4
```

하위 숫자:

```asm
mov al,[esi]
and al,0Fh
```

ASCII 변환:

```asm
add al,'0'
```

---

## 알고리즘

```text
1. byte 읽기
2. 상위 nibble 추출
3. '0' 더하기
4. 버퍼에 저장
5. 하위 nibble 추출
6. '0' 더하기
7. 버퍼에 저장
8. 다음 byte
```

4바이트라면 총 **8개의 ASCII 숫자**가 만들어집니다.

---

# 4. Encryption Using Rotate Operations

## 문제

각 plaintext byte를 key에 따라 서로 다른 방향과 크기로 회전시켜 암호화합니다.

Key:

```asm
key BYTE -2,4,1,0,-3,5,2,-4,-4,6
```

규칙:

```text
음수 → 왼쪽 회전
양수 → 오른쪽 회전
0 → 변화 없음
```

---

## 예

key:

```text
-2
```

이면:

```asm
rol al,2
```

key:

```text
4
```

이면:

```asm
ror al,4
```

---

## 알고리즘

```text
plaintext 한 byte 읽기
        ↓
key 한 byte 읽기
        ↓
key < 0 ?
 ├─ Yes → ROL
 └─ No
     ↓
key > 0 ?
 ├─ Yes → ROR
 └─ No → 그대로
        ↓
다음 문자
```

key는 10바이트마다 다시 처음으로 돌아갑니다.

---

## 핵심 코드 형태

변수 shift count는 `CL`을 사용합니다.

```asm
mov al,[esi]
mov cl,[edi]

cmp cl,0
je next
jg rotateRight

neg cl
rol al,cl
jmp next

rotateRight:
ror al,cl

next:
mov [esi],al
```

---

# 5. Prime Numbers — Sieve of Eratosthenes

## 문제

2~1000 사이의 모든 소수를 **에라토스테네스의 체**를 사용해 출력합니다.

---

## 소수란?

1과 자기 자신으로만 나누어지는 수입니다.

예:

```text
2,3,5,7,11,13,17...
```

---

## 에라토스테네스의 체

2부터 시작합니다.

```text
2 → 2의 배수 제거
3 → 3의 배수 제거
5 → 5의 배수 제거
...
```

남은 숫자가 소수입니다.

---

## 배열 방식

```asm
sieve BYTE 1001 DUP(0)
```

의미:

```text
0 = 아직 소수 후보
1 = 합성수
```

예:

```text
2 → 유지
4 → 제거
6 → 제거
8 → 제거

3 → 유지
6 → 이미 제거
9 → 제거
12 → 제거
```

---

## 알고리즘

```text
for p = 2 ...
    p가 제거되지 않았다면 소수

    p²부터 시작하여
    p의 배수들을 제거
```

1000의 제곱근은 약 31.6이므로 31 정도까지만 배수 제거 작업을 해도 됩니다.

---

# 6. Greatest Common Divisor (GCD)

## 문제

두 정수의 최대공약수를 구합니다.

주어진 C++ 형태:

```cpp
int GCD(int x, int y)
{
    x = abs(x);
    y = abs(y);

    do {
        int n = x % y;
        x = y;
        y = n;
    } while(y > 0);

    return x;
}
```

---

## 핵심: 유클리드 호제법

예:

```text
GCD(48,18)

48 % 18 = 12
18 % 12 = 6
12 % 6  = 0

GCD = 6
```

---

## Assembly 핵심

나머지는 `DIV/IDIV` 후 EDX에 저장됩니다.

32비트 unsigned 형태라면:

```asm
GCD PROC
L1:
    mov edx,0
    div ebx

    mov eax,ebx
    mov ebx,edx

    cmp ebx,0
    jne L1

    ret
GCD ENDP
```

개념적으로:

```text
EAX = x
EBX = y

EDX = x % y
EAX = y
EBX = 나머지

나머지가 0이 될 때까지 반복
```

원문처럼 음수 입력까지 허용하려면 먼저 두 피연산자의 절댓값을 만든 뒤 같은 과정을 수행하면 됩니다.

---

# 7. Bitwise Multiplication

## 문제

`BitwiseMultiply` 프로시저를 작성합니다.

조건:

```text
EAX = multiplicand
EBX = multiplier
```

사용 가능:

```text
Shift
Addition
```

일반적인 `MUL`을 사용하지 않습니다.

---

## 핵심 원리

이진수 곱셈을 이용합니다.

예:

```text
13 × 5

13 = 1101₂
5  = 0101₂
```

5의 1비트가 있는 위치에 맞춰 13을 Shift하여 더합니다.

```text
13 × 1 = 13
13 × 4 = 52

13 + 52 = 65
```

---

## 가장 이해하기 쉬운 알고리즘

```text
result = 0

multiplier의 LSB 확인

1이면:
    result += multiplicand

multiplicand <<= 1
multiplier >>= 1

multiplier가 0이 될 때까지 반복
```

---

## Assembly 예시

```asm
BitwiseMultiply PROC
    push ecx
    push edx

    mov ecx,eax
    xor edx,edx

L1:
    test ebx,1
    jz skipAdd

    add edx,ecx

skipAdd:
    shl ecx,1
    shr ebx,1

    cmp ebx,0
    jne L1

    mov eax,edx

    pop edx
    pop ecx
    ret
BitwiseMultiply ENDP
```

최종 결과:

```text
EAX = product
```

> 문제의 핵심은 **이진수의 각 1비트가 multiplicand의 2의 거듭제곱 배수를 선택한다**는 것입니다.

---

# 8. Add Packed Integers

## 문제

`AddPacked`를 확장하여 임의 크기의 두 packed decimal integer를 더합니다.

지원 크기:

```text
4 byte
8 byte
16 byte
```

권장 레지스터:

```text
ESI = 첫 번째 숫자
EDI = 두 번째 숫자
EDX = 결과
ECX = byte 개수
```

---

## Packed Decimal 복습

예:

```text
45 decimal
```

Packed decimal:

```text
45h
```

각 nibble이 한 자리 숫자를 나타냅니다.

```text
0100 0101
  4    5
```

---

## 핵심

Packed decimal 덧셈은 일반 binary 덧셈 후 각 decimal digit을 보정해야 합니다.

교재의 `AddPacked` 방식에서는 바이트별 덧셈과 decimal adjustment를 연결합니다.

개념:

```text
첫 byte 더하기
↓
Carry 발생
↓
다음 byte ADC
↓
decimal adjustment
↓
다음 byte
```

---

## 프로시저 구조

```asm
AddPacked PROC
    clc

L1:
    mov al,[esi]
    adc al,[edi]

    ; packed decimal adjustment
    ; 교재의 AddPacked에서 사용한 보정 로직 적용

    mov [edx],al

    inc esi
    inc edi
    inc edx

    loop L1

    ret
AddPacked ENDP
```

### 중요한 점

다중 바이트 연산에서는 Carry가 다음 바이트로 전달되어야 합니다.

따라서:

```text
ADD만 반복 ❌
ADC를 이용해 Carry 연결 ⭕
```

---

# Programming Exercises 핵심 정리

| 번호 | 주제 | 핵심 |
|---|---|---|
| 1 | WriteScaled | 문자열 + 소수점 삽입 |
| 2 | Extended Sub | `SBB` |
| 3 | PackedToAsc | nibble 분리 + ASCII |
| 4 | Encryption | `ROL`, `ROR` |
| 5 | Prime | 에라토스테네스의 체 |
| 6 | GCD | 나머지 반복 |
| 7 | Bitwise Multiply | `SHL`, `SHR`, `ADD` |
| 8 | AddPacked | `ADC` + decimal 보정 |

---

# 시험에서 특히 알아둘 명령어

## SBB

```asm
sbb eax,ebx
```

의미:

```text
EAX = EAX - EBX - CF
```

여러 바이트/워드로 이루어진 큰 정수의 뺄셈에서 중요합니다.

---

## ADC

```asm
adc eax,ebx
```

의미:

```text
EAX = EAX + EBX + CF
```

여러 바이트의 덧셈에서 중요합니다.

---

## ROL / ROR

```text
ROL = 왼쪽 회전
ROR = 오른쪽 회전
```

Shift와 달리 빠져나간 비트가 반대편으로 다시 들어옵니다.

---

## MUL / DIV

```text
MUL = unsigned multiplication
DIV = unsigned division

IMUL = signed multiplication
IDIV = signed division
```

---

# Chapter 7 전체에서 우선 공부할 부분

시험 대비 우선순위를 잡는다면 다음 내용을 먼저 확실히 이해하는 것이 좋습니다.

**1순위 — Shift / Rotate**

```text
SHL
SHR
SAR
ROL
ROR
RCL
RCR
```

**2순위 — 곱셈 / 나눗셈**

```text
MUL
IMUL
DIV
IDIV
```

특히 결과가 어느 레지스터에 들어가는지 중요합니다.

```text
8-bit DIV:
AX / r8
AL = quotient
AH = remainder

16-bit DIV:
DX:AX / r16
AX = quotient
DX = remainder

32-bit DIV:
EDX:EAX / r32
EAX = quotient
EDX = remainder

64-bit DIV:
RDX:RAX / r64
RAX = quotient
RDX = remainder
```

**3순위 — Carry 활용**

```text
ADC = Carry 포함 덧셈
SBB = Borrow 포함 뺄셈
RCL/RCR = Carry 포함 Rotate
```

이 세 영역은 Review Questions와 Algorithm Workbench 양쪽에서 반복해서 등장하므로 우선적으로 연습하는 것이 좋습니다.
