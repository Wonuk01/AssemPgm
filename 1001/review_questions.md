# Chapter 4 — Review Questions and Exercises

> Data Transfers, Addressing, and Arithmetic  
> 질문별 정답과 핵심 풀이 정리


## 1. MOVSX와 부호 확장

### Question

``` asm
.data
one WORD 8002h
two WORD 4321h

.code
mov edx,21348041h
movsx edx,one     ; (a)
movsx edx,two     ; (b)
```

### Answer

**(a)**

``` text
EDX = FFFF8002h
```

`8002h`는 16비트 signed 값으로 보면 최상위 비트가 `1`이므로 음수이다.\
`MOVSX`는 부호 확장을 수행하므로 상위 16비트를 `FFFFh`로 채운다.

**(b)**

``` text
EDX = 00004321h
```

`4321h`의 부호 비트는 `0`이므로 상위 비트를 `0`으로 채운다.

------------------------------------------------------------------------

## 2. INC와 부분 레지스터

### Question

``` asm
mov eax,1002FFFFh
inc ax
```

### Answer

``` text
EAX = 10020000h
```

`INC AX`는 EAX 전체가 아니라 하위 16비트인 AX만 증가시킨다.

``` text
AX: FFFFh → 0000h
```

상위 16비트 `1002h`는 그대로 유지된다.

------------------------------------------------------------------------

## 3. DEC와 부분 레지스터

### Question

``` asm
mov eax,30020000h
dec ax
```

### Answer

``` text
EAX = 3002FFFFh
```

``` text
AX: 0000h → FFFFh
```

------------------------------------------------------------------------

## 4. NEG

### Question

``` asm
mov eax,1002FFFFh
neg ax
```

### Answer

``` text
EAX = 10020001h
```

16비트에서:

``` text
FFFFh = -1
NEG -1 = +1
```

따라서 AX는 `0001h`가 된다.

------------------------------------------------------------------------

## 5. Parity Flag

### Question

``` asm
mov al,1
add al,3
```

### Answer

``` text
AL = 04h
PF = 0
```

`1 + 3 = 4`

``` text
04h = 00000100b
```

1의 개수가 1개로 홀수이므로 Parity Flag는 0이다.

> PF = 1 → 하위 바이트의 1 비트 개수가 짝수\
> PF = 0 → 하위 바이트의 1 비트 개수가 홀수

------------------------------------------------------------------------

## 6. EAX와 Sign Flag

### Question

``` asm
mov eax,5
sub eax,6
```

### Answer

``` text
EAX = FFFFFFFFh
SF = 1
```

``` text
5 - 6 = -1
```

32비트 `-1`은 `FFFFFFFFh`이고 최상위 비트가 1이므로 Sign Flag가
설정된다.

------------------------------------------------------------------------

## 7. Overflow Flag와 signed byte

### Question

``` asm
mov al,-1
add al,130
```

### Answer

`130`은 signed byte 범위인 `-128 ~ +127`에 들어가지 않는다.

8비트 비트 패턴으로 `130`은:

``` text
130 = 82h
```

이를 signed byte로 해석하면 `-126`이다.

따라서 실제 8비트 연산은 비트 수준에서:

``` text
FFh + 82h = 81h
```

`81h`는 signed byte로 `-127`이다.

두 음수를 더해서 음수가 나왔으므로 이 연산 자체에서는 signed overflow를
나타내는 `OF`가 설정되지 않는다.

``` text
OF = 0
```

즉, **Overflow Flag만 보고 원래 의도했던 +130이라는 값이 signed byte
범위를 벗어났다는 사실을 판단할 수 없다.**\
피연산자 자체가 이미 signed byte 범위를 벗어나 있기 때문이다.

------------------------------------------------------------------------

## 8. 64비트 RAX

### Question

``` asm
mov rax,44445555h
```

### Answer

``` text
RAX = 0000000044445555h
```

------------------------------------------------------------------------

## 9. DWORD와 RAX

### Question

``` asm
.data
dwordVal DWORD 84326732h

.code
mov rax,0FFFFFFFF00000000h
mov rax,dwordVal
```

### Answer / 주의점

교재가 의도한 핵심이 **32비트 값을 64비트 레지스터로 가져오면서 상위
비트를 0으로 만드는 것**이라면 결과는:

``` text
RAX = 0000000084326732h
```

실제 x86-64 코드에서는 크기를 명확하게 하기 위해 보통 다음과 같이
작성한다.

``` asm
mov eax,dwordVal
```

`EAX`에 값을 기록하면 `RAX`의 상위 32비트는 자동으로 0이 된다.

``` text
RAX = 0000000084326732h
```

> 사용하는 MASM/교재 문법에 따라 `mov rax,dwordVal` 자체는 operand-size
> 문제로 진단될 수 있으므로 실제 코딩에서는 `mov eax,dwordVal`처럼
> 크기를 명확히 하는 것이 안전하다.

------------------------------------------------------------------------

## 10. WORD PTR

### Question

``` asm
.data
dVal DWORD 12345678h

.code
mov ax,3
mov WORD PTR dVal+2,ax
mov eax,dVal
```

### Answer

``` text
EAX = 00035678h
```

초기 DWORD:

``` text
12345678h
```

Little Endian 메모리:

``` text
78 56 34 12
```

`dVal+2`부터 WORD `0003h`를 저장하면:

``` text
78 56 03 00
```

따라서:

``` text
EAX = 00035678h
```

------------------------------------------------------------------------

## 11. WORD PTR와 Little Endian

### Question

``` asm
.data
dVal DWORD ?

.code
mov dVal,12345678h
mov ax,WORD PTR dVal+2
add ax,3
mov WORD PTR dVal,ax
mov eax,dVal
```

### Answer

처음:

``` text
dVal = 12345678h
```

``` asm
mov ax,WORD PTR dVal+2
```

상위 WORD를 읽으므로:

``` text
AX = 1234h
```

``` asm
add ax,3
```

``` text
AX = 1237h
```

이 값을 dVal의 하위 WORD에 저장:

``` text
dVal = 12341237h
```

따라서:

``` text
EAX = 12341237h
```

------------------------------------------------------------------------

## 12. 서로 다른 부호를 더할 때 Overflow?

### Question

Positive integer + Negative integer에서 OF가 설정될 수 있는가?

### Answer

``` text
No
```

signed overflow는 같은 부호의 두 수를 더했는데 결과의 부호가 달라질 때
발생한다.

------------------------------------------------------------------------

## 13. 음수 + 음수 = 양수

### Answer

``` text
Yes
```

두 음수를 더했는데 양수가 나오면 signed overflow이다.

``` text
OF = 1
```

------------------------------------------------------------------------

## 14. NEG가 Overflow Flag를 설정할 수 있는가?

### Answer

``` text
Yes
```

가장 작은 signed 정수는 양수로 표현할 수 없다.

예: 8비트

``` text
80h = -128
NEG 80h → 80h
OF = 1
```

------------------------------------------------------------------------

## 15. Sign Flag와 Zero Flag가 동시에 1일 수 있는가?

### Answer

``` text
No
```

ZF=1이면 결과는 0이다.

0의 최상위 비트는 0이므로 SF=0이다.

------------------------------------------------------------------------

# Questions 16--19 Data

``` asm
.data
var1 SBYTE -4,-2,3,1
var2 WORD 1000h,2000h,3000h,4000h
var3 SWORD -16,-42
var4 DWORD 1,2,3,4,5
```

------------------------------------------------------------------------

## 16. Valid / Invalid

  -----------------------------------------------------------------------
  Instruction             Result                  Reason
  ----------------------- ----------------------- -----------------------
  `mov ax,var1`           Invalid                 BYTE → WORD 크기 불일치

  `mov ax,var2`           Valid                   WORD → AX

  `mov eax,var3`          Invalid                 WORD → DWORD 크기
                                                  불일치

  `mov var2,var3`         Invalid                 memory → memory MOV
                                                  불가

  `movzx ax,var2`         Invalid                 MOVZX의 목적지는
                                                  원본보다 커야 함

  `movzx var2,al`         Invalid                 MOVZX 목적지는
                                                  레지스터여야 함

  `mov ds,ax`             Valid                   AX → segment register
                                                  가능

  `mov ds,1000h`          Invalid                 immediate → segment
                                                  register 직접 이동 불가
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 17. var1 접근

### (a)

``` asm
mov al,var1
```

`var1[0] = -4`

``` text
AL = FCh
```

### (b)

``` asm
mov ah,[var1+3]
```

`var1[3] = 1`

``` text
AH = 01h
```

이전 AL 값까지 포함하면:

``` text
AX = 01FCh
```

------------------------------------------------------------------------

## 18. var2 / var3 접근

### (a)

``` asm
mov ax,var2
```

``` text
AX = 1000h
```

### (b)

``` asm
mov ax,[var2+4]
```

WORD 하나는 2바이트이다.

``` text
var2+0 → 1000h
var2+2 → 2000h
var2+4 → 3000h
```

따라서:

``` text
AX = 3000h
```

### (c)

``` asm
mov ax,var3
```

`var3[0] = -16`

16비트 2의 보수:

``` text
AX = FFF0h
```

### (d)

``` asm
mov ax,[var3-2]
```

`var3` 바로 앞에는 `var2`의 마지막 WORD인 `4000h`가 있다.

``` text
AX = 4000h
```

------------------------------------------------------------------------

## 19. MOVZX / MOVSX

### (a)

``` asm
mov edx,var4
```

``` text
EDX = 00000001h
```

### (b)

``` asm
movzx edx,var2
```

``` text
EDX = 00001000h
```

### (c)

``` asm
mov edx,[var4+4]
```

DWORD 하나는 4바이트이므로 두 번째 원소를 읽는다.

``` text
EDX = 00000002h
```

### (d)

``` asm
movsx edx,var1
```

`var1[0] = -4 = FCh`

부호 확장:

``` text
EDX = FFFFFFFCh
```

------------------------------------------------------------------------
