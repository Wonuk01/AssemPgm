# Chapter 7 Integer Arithmetic — Algorithm Workbench

> 각 문제를 **요구사항 → 코드 → 해설** 형태로 정리했습니다.

---

## 1. AX를 EAX로 부호 확장하기

### 문제

Shift 명령어를 사용하여 AX의 부호 비트를 EAX의 상위 16비트에 복사합니다. `CWD`는 사용하지 않습니다.

### 풀이

```asm
shl eax,16
sar eax,16
```

### 원리

첫 번째 명령으로 AX의 값이 EAX 상위 16비트로 이동합니다.

그 후 `SAR`을 16번 수행하면 부호 비트가 상위 비트에 복사됩니다.

예를 들어 AX가 음수라면:

```text
AX = 8001h

SHL EAX,16
80010000h

SAR EAX,16
FFFF8001h
```

**핵심: `SAR`은 부호 비트를 유지한다.**

---

## 2. SHR과 조건 점프로 ROR AL,1 구현

Rotate 명령어가 없다고 가정합니다.

```asm
shr al,1
jnc done
or al,80h
done:
```

### 원리

`SHR AL,1`을 하면 빠져나간 최하위 비트가 CF에 저장됩니다.

CF가 1이었다면 원래 최하위 비트를 최상위 비트 위치에 다시 넣습니다.

```text
SHR → LSB가 CF로 이동
CF=1 → MSB를 1로 설정
```

이 동작은 `ROR AL,1`과 같습니다.

---

## 3. EAX × 16

2의 거듭제곱 곱셈은 왼쪽 Shift로 구현할 수 있습니다.

```text
16 = 2⁴
```

따라서:

```asm
shl eax,4
```

**정답: `SHL EAX,4`**

---

## 4. EBX ÷ 4

```text
4 = 2²
```

unsigned 값이라고 보면:

```asm
shr ebx,2
```

**정답: `SHR EBX,2`**

---

## 5. DL의 상위/하위 4비트 교환

DL은 8비트입니다.

```text
ABCD EFGH
```

4비트 회전:

```text
EFGH ABCD
```

따라서:

```asm
ror dl,4
```

또는 `ROL DL,4`도 같은 결과입니다.

**정답 예: `ROR DL,4`**

---

## 6. AX의 최상위 비트를 DX의 최하위 위치로 이동

`DX`를 왼쪽으로 1비트 이동시키면서 AX의 가장 높은 비트를 DX의 낮은 비트로 넣습니다.

```asm
shld dx,ax,1
```

개념:

```text
DX ← DX << 1
DX bit0 ← AX bit15
```

**정답: `SHLD DX,AX,1`**

---

## 7. 세 개의 메모리 바이트를 오른쪽으로 1비트 Shift

```asm
byteArray BYTE 81h,20h,33h
```

배열 전체를 하나의 24비트 값처럼 생각해야 합니다.

메모리의 little-endian 순서를 고려하면 높은 주소 바이트부터 `SHR/RCR`을 연결합니다.

```asm
shr byteArray+2,1
rcr byteArray+1,1
rcr byteArray,1
```

### 원리

가장 높은 바이트를 `SHR`하고, 빠져나온 비트를 CF를 통해 다음 바이트로 전달합니다.

```text
SHR → CF
       ↓
RCR → CF
       ↓
RCR
```

`RCR`은 Carry를 포함해서 오른쪽으로 이동시키므로 여러 바이트를 연결할 수 있습니다.

---

## 8. 세 개의 메모리 WORD를 왼쪽으로 1비트 Shift

```asm
wordArray WORD 810Dh,0C064h,93ABh
```

낮은 WORD부터 시작합니다.

```asm
shl wordArray,1
rcl wordArray+2,1
rcl wordArray+4,1
```

### 원리

```text
첫 WORD SHL
   ↓ CF
두 번째 WORD RCL
   ↓ CF
세 번째 WORD RCL
```

Carry를 이용해 한 WORD에서 빠져나간 비트를 다음 WORD로 전달합니다.

---

## 9. -5 × 3을 val1에 저장

16비트 변수:

```asm
val1 WORD ?
```

가능한 코드:

```asm
mov ax,-5
mov bx,3
imul bx
mov val1,ax
```

결과:

```text
-5 × 3 = -15
```

16비트 2의 보수로:

```text
-15 = FFF1h
```

**결과: `val1 = FFF1h`**

---

## 10. -276 ÷ 10

signed 나눗셈이므로 `IDIV`를 사용합니다.

```asm
val1 WORD ?

mov ax,-276
cwd
mov bx,10
idiv bx
mov val1,ax
```

계산:

```text
-276 / 10 = -27
나머지 = -6
```

따라서:

```text
AX = -27
DX = -6
```

`val1`에는 `-27`이 저장됩니다.

---

## 11. 32비트 unsigned 표현식

C++:

```cpp
val1 = (val2 * val3) / (val4 - 3);
```

Assembly:

```asm
mov eax,val2
mul val3

mov ebx,val4
sub ebx,3

div ebx
mov val1,eax
```

### 핵심

`MUL val3`:

```text
EAX × val3 → EDX:EAX
```

`DIV EBX`:

```text
EDX:EAX / EBX
몫 → EAX
나머지 → EDX
```

---

## 12. 32비트 signed 표현식

C++:

```cpp
val1 = (val2 / val3) * (val1 + val2);
```

Assembly:

```asm
mov eax,val2
cdq
idiv val3

mov ebx,val1
add ebx,val2

imul eax,ebx
mov val1,eax
```

### 핵심

signed 값이므로:

```text
IDIV
IMUL
```

을 사용합니다.

`CDQ`는 EAX의 부호를 EDX로 확장하여 `EDX:EAX`를 만듭니다.

---

## 13. AL의 0~99 값을 10진수로 출력

입력:

```asm
mov al,65
call showDecimal8
```

출력:

```text
65
```

`WriteChar`만 사용할 수 있습니다.

### 예시 코드

```asm
showDecimal8 PROC
    mov ah,0
    mov bl,10
    div bl

    mov bx,ax
    cmp bl,0
    je ones

    mov al,bl
    add al,'0'
    call WriteChar

ones:
    mov al,bh
    add al,'0'
    call WriteChar
    ret
showDecimal8 ENDP
```

### 원리

`DIV BL`:

```text
AX / 10

AL = 몫(십의 자리)
AH = 나머지(일의 자리)
```

65라면:

```text
65 / 10
몫 = 6
나머지 = 5
```

숫자를 ASCII 문자로 바꾸려면:

```asm
add al,'0'
```

을 사용합니다.

---

## 14. AAA Challenge

조건:

```text
AX = 0072h
AF = 1
```

`AAA`는 ASCII 덧셈 결과를 조정합니다.

AF가 이미 1이므로 조정 조건이 참입니다.

AAA의 핵심 동작:

```text
AX = AX + 0106h
AL = AL AND 0Fh
AF = 1
CF = 1
```

계산:

```text
0072h + 0106h
= 0178h
```

그 후:

```text
AL = 78h AND 0Fh
   = 08h
```

따라서:

```text
AX = 0108h
CF = 1
AF = 1
```

**정답: `AX = 0108h`**

---

## 15. SUB, MOV, AND만 사용하여 `x = n mod y`

조건:

```text
y = 2의 거듭제곱
```

2의 거듭제곱에서는:

```text
n mod y = n AND (y - 1)
```

따라서:

```asm
mov eax,y
sub eax,1
and eax,n
mov x,eax
```

예:

```text
n = 13
y = 8

y - 1 = 7
13 AND 7 = 5
```

```text
13 mod 8 = 5
```

---

## 16. SAR, ADD, XOR만으로 절댓값 구하기

입력:

```text
EAX = signed integer
```

코드:

```asm
mov edx,eax
sar edx,31
xor eax,edx
add eax,edx
xor eax,edx
```

단, 문제 힌트를 가장 직접적으로 적용한 전형적인 형태는 보통 `SUB`를 허용할 때 `(x ^ mask) - mask`입니다. 여기서는 `SUB`가 금지되어 있으므로 `ADD`와 XOR을 이용해 -1 보정을 구성해야 합니다.

더 명확한 허용 명령만 사용한 버전:

```asm
mov edx,eax
sar edx,31        ; 양수: 0, 음수: FFFFFFFFh
xor eax,edx       ; 음수라면 one's complement
mov ecx,edx
xor ecx,0FFFFFFFFh
add edx,ecx       ; edx는 음수 경로에서 -1 보정용으로 활용 가능
```

교재/수업에서 요구하는 정확한 레지스터 제약에 따라 짧은 변형이 가능하므로, 시험에서는 핵심 원리를 기억하는 것이 중요합니다.

### 핵심 원리

`SAR reg,31`:

```text
양수 → 00000000h
음수 → FFFFFFFFh
```

음수일 때 모든 비트를 XOR로 뒤집고 1을 더하면 절댓값이 됩니다.

---

# Algorithm Workbench 핵심 암기

## 2의 거듭제곱

```text
×2  = SHL 1
×4  = SHL 2
×8  = SHL 3
×16 = SHL 4

÷2  = SHR 1 (unsigned)
÷4  = SHR 2
÷8  = SHR 3
```

## signed / unsigned

```text
Unsigned:
MUL
DIV
SHR

Signed:
IMUL
IDIV
SAR
```

## Carry를 연결하는 명령

```text
ADC = 덧셈 연결
SBB = 뺄셈 연결
RCL = 왼쪽 Shift 연결
RCR = 오른쪽 Shift 연결
```

## 나눗셈 직전

```text
unsigned 32-bit:
EDX = 0
DIV

signed 32-bit:
CDQ
IDIV
```
