# Chapter 4 — Programming Exercises

> Data Transfers, Addressing, and Arithmetic  
> Programming Exercises 및 직전 Data Definition 연습문제 정리

## Data Definition Exercises (Questions 12–18)

``` asm
.data
myBytes BYTE 10h,20h,30h,40h
myWords WORD 3 DUP(?),2000h
myString BYTE "ABCDE"
```

------------------------------------------------------------------------

## 12. myBytes를 짝수 주소에 정렬

``` asm
.data
ALIGN 2
myBytes BYTE 10h,20h,30h,40h
```

------------------------------------------------------------------------

## 13. TYPE / LENGTHOF / SIZEOF

### (a)

``` asm
mov eax,TYPE myBytes
```

``` text
EAX = 1
```

### (b)

``` asm
mov eax,LENGTHOF myBytes
```

``` text
EAX = 4
```

### (c)

``` asm
mov eax,SIZEOF myBytes
```

``` text
EAX = 4
```

### (d)

``` asm
mov eax,TYPE myWords
```

``` text
EAX = 2
```

### (e)

``` asm
mov eax,LENGTHOF myWords
```

`3 DUP(?)` + `2000h`이므로 총 4개이다.

``` text
EAX = 4
```

### (f)

``` asm
mov eax,SIZEOF myWords
```

``` text
4 × 2 = 8 bytes
EAX = 8
```

### (g)

``` asm
mov eax,SIZEOF myString
```

`"ABCDE"`는 5바이트이고 별도의 null terminator가 선언되지 않았다.

``` text
EAX = 5
```

### 암기

``` text
TYPE     = 원소 1개의 크기
LENGTHOF = 원소 개수
SIZEOF   = TYPE × LENGTHOF
```

------------------------------------------------------------------------

## 14. myBytes 첫 두 바이트 → DX

메모리:

``` text
10 20
```

Little Endian으로 WORD를 읽으면:

``` text
DX = 2010h
```

### Answer

``` asm
mov dx,WORD PTR myBytes
```

------------------------------------------------------------------------

## 15. myWords의 두 번째 byte → AL

### Answer

``` asm
mov al,BYTE PTR [myWords+1]
```

------------------------------------------------------------------------

## 16. myBytes 전체 → EAX

### Answer

``` asm
mov eax,DWORD PTR myBytes
```

Little Endian이므로:

``` text
EAX = 40302010h
```

------------------------------------------------------------------------

## 17. myWords를 DWORD로 접근하는 LABEL

### Answer

``` asm
myWordsD LABEL DWORD
myWords WORD 3 DUP(?),2000h
```

이제 다음과 같이 접근할 수 있다.

``` asm
mov eax,myWordsD
```

------------------------------------------------------------------------

## 18. myBytes를 WORD로 접근하는 LABEL

### Answer

``` asm
myBytesW LABEL WORD
myBytes BYTE 10h,20h,30h,40h
```

예:

``` asm
mov ax,myBytesW
```

결과:

``` text
AX = 2010h
```

------------------------------------------------------------------------


---


## 1. Big Endian → Little Endian

### Given

``` asm
.data
bigEndian BYTE 12h,34h,56h,78h
littleEndian DWORD ?
```

### Goal

`littleEndian`의 DWORD 값:

``` text
12345678h
```

Little Endian 메모리에는 다음 순서로 저장되어야 한다.

``` text
78 56 34 12
```

### Answer

``` asm
mov al,bigEndian[0]
mov BYTE PTR littleEndian[3],al

mov al,bigEndian[1]
mov BYTE PTR littleEndian[2],al

mov al,bigEndian[2]
mov BYTE PTR littleEndian[1],al

mov al,bigEndian[3]
mov BYTE PTR littleEndian[0],al
```

------------------------------------------------------------------------

## 2. 배열의 인접 원소 교환

### Goal

``` text
[A,B,C,D,E,F]
→
[B,A,D,C,F,E]
```

### Answer

``` asm
.data
array DWORD 10,20,30,40,50,60

.code
mov esi,0
mov ecx,LENGTHOF array / 2

L1:
    mov eax,array[esi]
    xchg eax,array[esi+TYPE array]
    mov array[esi],eax

    add esi,TYPE array * 2
    loop L1
```

결과:

``` text
20,10,40,30,60,50
```

------------------------------------------------------------------------

## 3. 배열 원소 사이 Gap의 합

### Example

``` text
0,2,5,9,10
```

Gap:

``` text
2-0 = 2
5-2 = 3
9-5 = 4
10-9 = 1
```

합:

``` text
10
```

### Answer

``` asm
.data
array DWORD 0,2,5,9,10

.code
xor eax,eax
mov esi,0
mov ecx,LENGTHOF array - 1

L1:
    mov edx,array[esi+TYPE array]
    sub edx,array[esi]
    add eax,edx

    add esi,TYPE array
    loop L1
```

최종:

``` text
EAX = 10
```

------------------------------------------------------------------------

## 4. WORD Array → DWORD Array

### Answer

``` asm
.data
source WORD 1000h,2000h,3000h,4000h
target DWORD LENGTHOF source DUP(?)

.code
mov esi,0
mov edi,0
mov ecx,LENGTHOF source

L1:
    movzx eax,source[esi]
    mov target[edi],eax

    add esi,TYPE source
    add edi,TYPE target
    loop L1
```

`MOVZX`를 사용하므로 unsigned WORD가 DWORD로 zero-extension 된다.

------------------------------------------------------------------------

## 5. Fibonacci Numbers

### Goal

``` text
1, 1, 2, 3, 5, 8, 13
```

### Answer

``` asm
.data
fib DWORD 7 DUP(?)

.code
mov fib[0],1
mov fib[4],1

mov eax,1
mov ebx,1
mov esi,8
mov ecx,5

L1:
    mov edx,eax
    add edx,ebx

    mov fib[esi],edx

    mov eax,ebx
    mov ebx,edx

    add esi,TYPE fib
    loop L1
```

최종 배열:

``` text
1,1,2,3,5,8,13
```

------------------------------------------------------------------------

## 6. 배열을 제자리에서 Reverse

### Answer

``` asm
.data
array DWORD 10,20,30,40,50

.code
mov esi,0
mov edi,SIZEOF array - TYPE array
mov ecx,LENGTHOF array / 2

L1:
    mov eax,array[esi]
    xchg eax,array[edi]
    mov array[esi],eax

    add esi,TYPE array
    sub edi,TYPE array
    loop L1
```

결과:

``` text
50,40,30,20,10
```

`SIZEOF`, `TYPE`, `LENGTHOF`를 사용하므로 배열의 크기나 원소 타입이
바뀌어도 수정량이 적다.

------------------------------------------------------------------------

## 7. 문자열 역순 복사

### Given

``` asm
source BYTE "This is the source string",0
target BYTE SIZEOF source DUP('#')
```

### Answer

``` asm
mov esi,0
mov edi,LENGTHOF source - 2
mov ecx,LENGTHOF source - 1

L1:
    mov al,source[edi]
    mov target[esi],al

    inc esi
    dec edi
    loop L1

mov target[esi],0
```

결과:

``` text
"gnirts ecruos eht si sihT"
```

마지막에는 null terminator `0`을 저장한다.

------------------------------------------------------------------------

## 8. 배열을 앞으로 한 칸 회전

### Example

``` text
[10,20,30,40]
→
[40,10,20,30]
```

### Answer

``` asm
.data
array DWORD 10,20,30,40

.code
mov eax,array[SIZEOF array - TYPE array]

mov esi,SIZEOF array - TYPE array
mov ecx,LENGTHOF array - 1

L1:
    mov edx,array[esi-TYPE array]
    mov array[esi],edx

    sub esi,TYPE array
    loop L1

mov array[0],eax
```

결과:

``` text
40,10,20,30
```

------------------------------------------------------------------------
