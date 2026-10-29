# Chapter 7 Integer Arithmetic — Review Questions 정리

> 시험 공부용으로 **문제 → 핵심 개념 → 풀이 → 정답** 순서로 정리했습니다.

---

## 1. Shift / Rotate 결과

초기값은 매번 `AL = D4h`입니다.

`D4h = 1101 0100₂`

### (a) `SHR AL,1`

```asm
mov al,0D4h
shr al,1
```

`SHR`은 **논리적 오른쪽 시프트**입니다. 오른쪽으로 1비트 이동하고 왼쪽에는 0이 들어갑니다.

```text
1101 0100
↓ SHR 1
0110 1010
```

`0110 1010₂ = 6Ah`

**정답: `AL = 6Ah`**

### (b) `SAR AL,1`

```asm
mov al,0D4h
sar al,1
```

`SAR`은 **산술적 오른쪽 시프트**이며 최상위 부호 비트를 유지합니다.

```text
1101 0100
↓ SAR 1
1110 1010
```

**정답: `AL = EAh`**

### (c) `SAR AL,4`

```asm
mov al,0D4h
sar al,4
```

`1101 0100₂`의 최상위 비트가 1이므로 왼쪽을 계속 1로 채웁니다.

```text
1101 0100
1110 1010   ; 1회
1111 0101   ; 2회
1111 1010   ; 3회
1111 1101   ; 4회
```

**정답: `AL = FDh`**

### (d) `ROL AL,1`

```asm
mov al,0D4h
rol al,1
```

`ROL`은 왼쪽으로 밀려난 최상위 비트를 최하위 비트로 다시 넣습니다.

```text
1101 0100
↓ ROL 1
1010 1001
```

**정답: `AL = A9h`**

### 최종 정답

| 항목 | 결과 |
|---|---|
| a | `6Ah` |
| b | `EAh` |
| c | `FDh` |
| d | `A9h` |

---

## 2. Rotate 결과

초기값은 매번 `AL = D4h = 1101 0100₂`입니다.

### (a) `ROR AL,3`

```asm
mov al,0D4h
ror al,3
```

오른쪽으로 3번 회전합니다.

```text
1101 0100
0110 1010
0011 0101
1001 1010
```

**정답: `AL = 9Ah`**

### (b) `ROL AL,7`

8비트 값에서 왼쪽 7회 회전은 오른쪽 1회 회전과 같습니다.

```text
1101 0100 → 0110 1010
```

**정답: `AL = 6Ah`**

### (c) `RCL AL,1`

```asm
stc
mov al,0D4h
rcl al,1
```

`STC`로 `CF = 1`.

`RCL`은 Carry Flag까지 포함하여 회전합니다.

```text
CF | AL
 1 | 1101 0100

RCL 1

CF = 기존 AL의 MSB = 1
AL = 1010 1001
```

**정답: `AL = A9h`, `CF = 1`**

### (d) `RCR AL,3`

초기 상태:

```text
CF = 1
AL = 1101 0100
```

Carry까지 포함한 9비트 값을 오른쪽으로 3회 회전합니다.

```text
초기 : 1 | 1101 0100
1회  : 0 | 1110 1010
2회  : 0 | 0111 0101
3회  : 1 | 0011 1010
```

**정답: `AL = 3Ah`, `CF = 1`**

### 최종 정답

| 항목 | AL |
|---|---|
| a | `9Ah` |
| b | `6Ah` |
| c | `A9h` |
| d | `3Ah` |

---

## 3. `MUL` 결과

```asm
mov dx,0
mov ax,222h
mov cx,100h
mul cx
```

16비트 `MUL CX`는

```text
AX × CX → DX:AX
```

입니다.

```text
0222h × 0100h = 00022200h
```

따라서:

```text
DX = 0002h
AX = 2200h
```

**정답: `DX = 0002h`, `AX = 2200h`**

---

## 4. `DIV BL`

```asm
mov ax,63h
mov bl,10h
div bl
```

8비트 DIV 형식:

```text
AX ÷ BL
몫 → AL
나머지 → AH
```

`63h = 99`, `10h = 16`

```text
99 ÷ 16 = 6 ... 3
```

따라서:

```text
AL = 06h
AH = 03h
```

AX 전체는:

```text
AX = 0306h
```

**정답: `AX = 0306h`**

---

## 5. 32비트 `DIV`

```asm
mov eax,123400h
mov edx,0
mov ebx,10h
div ebx
```

32비트 `DIV EBX`:

```text
EDX:EAX ÷ EBX
몫 → EAX
나머지 → EDX
```

계산:

```text
00123400h ÷ 10h
= 00012340h
```

나머지는 0입니다.

**정답**

```text
EAX = 00012340h
EDX = 00000000h
```

---

## 주요 산술 / Shift 명령어 정리

| 명령어 | 의미 |
|---|---|
| `DIV` | 부호 없는 나눗셈 |
| `IDIV` | 부호 있는 나눗셈 |
| `MUL` | 부호 없는 곱셈 |
| `IMUL` | 부호 있는 곱셈 |
| `ROL` | 왼쪽 회전 |
| `ROR` | 오른쪽 회전 |
| `RCL` | Carry 포함 왼쪽 회전 |
| `RCR` | Carry 포함 오른쪽 회전 |
| `SHL` | 논리적 왼쪽 Shift |
| `SAL` | 산술적 왼쪽 Shift (`SHL`과 동일) |
| `SHR` | 논리적 오른쪽 Shift, 왼쪽에 0 |
| `SAR` | 산술적 오른쪽 Shift, 부호 비트 유지 |
| `SHLD` | 이중 정밀도 왼쪽 Shift |
| `SHRD` | 이중 정밀도 오른쪽 Shift |
| `SBB` | Carry/Borrow를 포함한 뺄셈 |

---

## 6. `DIV BX`

```asm
mov ax,4000h
mov dx,500h
mov bx,10h
div bx
```

16비트 `DIV BX`는:

```text
DX:AX ÷ BX
```

를 수행하며 몫은 AX에 저장되어야 합니다.

하지만 `DX:AX = 0500:4000h`를 `0010h`으로 나누면 몫이 16비트 AX에 들어갈 수 있는 범위를 초과합니다.

따라서 **Divide Error(나눗셈 오버플로 예외)**가 발생합니다.

**정답: 정상적인 AX/DX 결과가 생성되지 않고 Divide Error 발생**

---

## 7. `ADC`

```asm
mov bx,5
stc
mov ax,60h
adc bx,ax
```

`STC`:

```text
CF = 1
```

`ADC`:

```text
BX = BX + AX + CF
```

따라서:

```text
0005h + 0060h + 1
= 0066h
```

**정답: `BX = 0066h`**

---

## 8. 64비트 DIV

```asm
.data
dividend_hi QWORD 00000108h
dividend_lo QWORD 33300020h
divisor QWORD 00000100h

.code
mov rdx,dividend_hi
mov rax,dividend_lo
div divisor
```

64비트 `DIV`는:

```text
RDX:RAX ÷ divisor
몫 → RAX
나머지 → RDX
```

피제수:

```text
0000000000000108:0000000033300020h
```

제수:

```text
100h = 256
```

하지만 상위 절반인 `RDX = 108h`가 제수 `100h`보다 크거나 같으므로, 계산된 몫은 64비트 `RAX`에 들어갈 수 없습니다.

**정답: Divide Error가 발생합니다.**

> `DIV`에서 몫이 목적 레지스터 크기를 초과해도 divide exception이 발생한다는 점을 기억하세요.

---

## 9. Extended Subtraction 코드 오류 수정

원본:

```asm
mov cx,8
mov esi,val1
mov edi,val2
clc
top:
mov al,BYTE PTR[esi]
sbb al,BYTE PTR[edi]
mov BYTE PTR[esi],al
dec esi
dec edi
loop top
```

### 문제점

1. `mov esi,val1`은 주소가 아니라 값을 읽는 형태가 될 수 있습니다. 주소를 얻으려면 `OFFSET`을 사용해야 합니다.
2. 다중 바이트 뺄셈은 **최하위 바이트부터 최상위 바이트 방향**으로 진행해야 합니다.
3. 따라서 인덱스는 감소(`DEC`)가 아니라 증가(`INC`)해야 합니다.
4. 결과를 별도의 `result` 변수에 저장해야 합니다.
5. 결과 주소를 위한 포인터가 필요합니다.

### 수정 코드

```asm
mov ecx,8
mov esi,OFFSET val1
mov edi,OFFSET val2
mov ebx,OFFSET result
clc

top:
    mov al,BYTE PTR [esi]
    sbb al,BYTE PTR [edi]
    mov BYTE PTR [ebx],al

    inc esi
    inc edi
    inc ebx
    loop top
```

핵심은 `SBB`가 이전 바이트에서 발생한 borrow(CF)를 다음 바이트 계산에 반영한다는 것입니다.

---

## 10. `IMUL`

```asm
.data
multiplicand QWORD 0001020304050000h

.code
imul rax,multiplicand,4
```

계산:

```text
0001020304050000h × 4
= 0004080C10140000h
```

따라서:

**정답: `RAX = 0004080C10140000h`**

---

# 시험 직전 핵심 암기

```text
SHR = 오른쪽 이동 + 왼쪽 0
SAR = 오른쪽 이동 + 부호 유지

SHL/SAL = 왼쪽 이동
ROL/ROR = 비트 자체가 순환
RCL/RCR = CF까지 포함해서 순환

MUL = unsigned 곱셈
IMUL = signed 곱셈
DIV = unsigned 나눗셈
IDIV = signed 나눗셈

ADC = ADD + Carry
SBB = SUB - Carry(Borrow)
```

특히 구분:

```text
SHR  : 빠져나간 비트는 CF로 가지만 다시 들어오지 않음
ROR  : 빠져나간 비트가 반대쪽으로 다시 들어옴
RCR  : 빠져나간 비트가 CF를 포함한 경로로 순환
```
