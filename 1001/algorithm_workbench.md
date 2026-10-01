# Chapter 4 — Algorithm Workbench

> Data Transfers, Addressing, and Arithmetic  
> 문제별 MASM 예제 코드와 핵심 설명


## 1. DWORD의 상위/하위 WORD 교환

### Question

DWORD 변수 `three`의 상위 WORD와 하위 WORD를 MOV 명령어만 사용해
교환하라.

### Answer

``` asm
mov ax, WORD PTR three
mov bx, WORD PTR three+2
mov WORD PTR three,bx
mov WORD PTR three+2,ax
```

------------------------------------------------------------------------

## 2. A,B,C,D → B,C,D,A

예를 들어:

``` text
AL=A
BL=B
CL=C
DL=D
```

### Answer

``` asm
xchg al,bl
xchg bl,cl
xchg cl,dl
```

결과:

``` text
AL=B
BL=C
CL=D
DL=A
```

------------------------------------------------------------------------

## 3. Parity Flag로 메시지 검사

### Given

``` text
AL = 01110101b
```

1의 개수는 5개이므로 odd parity이다.

### Answer

``` asm
add al,0
```

값은 변하지 않지만 플래그가 갱신된다.

``` text
PF = 0
```

따라서 메시지는 odd parity이다.

------------------------------------------------------------------------

## 4. 두 음수를 더해 Overflow 발생

### Answer

``` asm
mov al,-100
add al,-50
```

수학적으로:

``` text
-100 + -50 = -150
```

signed byte 범위:

``` text
-128 ~ +127
```

범위를 벗어나므로:

``` text
OF = 1
```

------------------------------------------------------------------------

## 5. Zero와 Carry를 동시에 설정

### Answer

``` asm
mov al,0FFh
add al,1
```

결과:

``` text
AL = 00h
ZF = 1
CF = 1
```

------------------------------------------------------------------------

## 6. SUB로 Carry Flag 설정

### Answer

``` asm
mov al,0
sub al,1
```

unsigned 관점에서 borrow가 필요하므로:

``` text
CF = 1
```

------------------------------------------------------------------------

## 7. 산술식 구현

### Expression

``` text
EAX = -val2 + 7 - val3 + val1
```

### Answer

``` asm
mov eax,val2
neg eax
add eax,7
sub eax,val3
add eax,val1
```

------------------------------------------------------------------------

## 8. DWORD 배열 합계

### Answer

``` asm
xor eax,eax
xor esi,esi
mov ecx,LENGTHOF array

L1:
    add eax,array[esi*TYPE array]
    inc esi
    loop L1
```

결과:

``` text
EAX = 배열 원소의 합
```

`TYPE array`가 DWORD 배열이면 4이므로 `ESI*4` 형태의 scaled indexed
addressing이 된다.

------------------------------------------------------------------------

## 9. 산술식 구현

### Expression

``` text
AX = (val2 + BX) - val4
```

### Answer

``` asm
mov ax,val2
add ax,bx
sub ax,val4
```

------------------------------------------------------------------------

## 10. Carry와 Overflow를 동시에 설정

### Answer

``` asm
mov al,80h
add al,80h
```

결과:

``` text
80h + 80h = 100h
AL = 00h
CF = 1
OF = 1
```

signed 관점에서도:

``` text
-128 + -128
```

은 표현 범위를 벗어난다.

------------------------------------------------------------------------

## 11. INC / DEC와 Zero Flag

`INC`와 `DEC`는 Carry Flag를 변경하지 않는다.

### INC unsigned wraparound 검사

``` asm
mov al,0FFh
inc al
```

결과:

``` text
AL = 00h
ZF = 1
```

`FFh → 00h`가 되었으므로 unsigned 증가에서 wraparound가 발생했음을 ZF로
확인할 수 있다.

### DEC의 경우

``` asm
mov al,0
dec al
```

결과:

``` text
AL = FFh
ZF = 0
```

따라서 `DEC`의 `00h → FFh` underflow는 **ZF 하나만으로 직접 검출할 수
없다.**

> 핵심: `INC`/`DEC`는 CF를 보존하므로 unsigned overflow/underflow 검출
> 시 플래그 특성을 주의해야 한다.

------------------------------------------------------------------------
