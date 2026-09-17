# Chapter 3 Programming Exercises 정답

## 3.10 Programming Exercises

> 아래 예제는 교재의 MASM/Irvine 스타일을 기준으로 정리한 예시 답안이다.
> 개발 환경에 따라 include/lib 경로나 32비트·64비트 설정은 달라질 수
> 있다.

## 1. Integer Expression Calculation

### 문제

레지스터를 사용하여 다음 식을 계산한다.

``` text
A = (A + B) - (C + D)
```

EAX, EBX, ECX, EDX에 각각 정수 값을 대입한다.

### 답안

``` asm
INCLUDE Irvine32.inc

.code
main PROC
    mov eax, 10         ; A = 10
    mov ebx, 20         ; B = 20
    mov ecx, 5          ; C = 5
    mov edx, 3          ; D = 3

    add eax, ebx        ; EAX = A + B
    add ecx, edx        ; ECX = C + D
    sub eax, ecx        ; EAX = (A + B) - (C + D)

    exit
main ENDP
END main
```

계산 결과:

``` text
(10 + 20) - (5 + 3)
= 30 - 8
= 22
```

따라서 최종적으로 `EAX = 22`이다.

------------------------------------------------------------------------

## 2. Symbolic Integer Constants

### 문제

일주일의 7개 요일에 대한 기호 상수를 만들고, 이 기호들을 초기값으로
사용하는 배열을 생성한다.

### 답안

``` asm
INCLUDE Irvine32.inc

SUNDAY    = 1
MONDAY    = 2
TUESDAY   = 3
WEDNESDAY = 4
THURSDAY  = 5
FRIDAY    = 6
SATURDAY  = 7

.data
week BYTE SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY

.code
main PROC
    exit
main ENDP
END main
```

기호 상수를 사용하면 숫자 `1~7`을 직접 사용하는 것보다 각 값의 의미를
쉽게 알 수 있다.

------------------------------------------------------------------------

## 3. Data Definitions

### 문제

Table 3-2에 나오는 각 데이터 형식의 변수를 정의하고 해당 타입에 맞는
값으로 초기화한다.

### 답안 예시

``` asm
INCLUDE Irvine32.inc

.data
byteVal   BYTE   255
sbyteVal  SBYTE  -128

wordVal   WORD   65535
swordVal  SWORD  -32768

dwordVal  DWORD  4294967295
sdwordVal SDWORD -2147483648

fwordVal  FWORD  123456789ABC_h
qwordVal  QWORD  123456789ABCDEF0h
tbyteVal  TBYTE  123456789ABCDEF01234h

real4Val  REAL4  1.5
real8Val  REAL8  1.23456789
real10Val REAL10 3.141592653589793238

.code
main PROC
    exit
main ENDP
END main
```

핵심 데이터 크기:

  지시어                    크기
  ---------------- -------------
  BYTE / SBYTE             8비트
  WORD / SWORD            16비트
  DWORD / SDWORD          32비트
  FWORD                   48비트
  QWORD                   64비트
  TBYTE                   80비트
  REAL4              32비트 실수
  REAL8              64비트 실수
  REAL10             80비트 실수

> 일부 MASM 버전에서는 매우 큰 정수 리터럴의 표기나 `FWORD`/`TBYTE`
> 초기값에 제약이 있을 수 있으므로, 실제 실습에서는 사용 중인 어셈블러의
> 문법에 맞게 값을 조정하면 된다.

------------------------------------------------------------------------

## 4. Symbolic Text Constants

### 문제

여러 문자열 리터럴에 기호 이름을 정의하고, 각 기호 이름을 변수 정의에서
사용한다.

### 답안

``` asm
INCLUDE Irvine32.inc

str1 TEXTEQU <"Assembly Language">
str2 TEXTEQU <"Computer Architecture">
str3 TEXTEQU <"MASM">

.data
msg1 BYTE str1, 0
msg2 BYTE str2, 0
msg3 BYTE str3, 0

.code
main PROC
    exit
main ENDP
END main
```

`TEXTEQU`는 텍스트를 기호 이름에 연결할 수 있게 해준다. 이후 데이터
정의에서 해당 기호를 사용할 수 있다.

------------------------------------------------------------------------

## 5. Listing File for AddTwoSum

### 문제

AddTwoSum 프로그램의 Listing File을 생성하고 각 명령어에서 생성된
machine code byte를 설명한다.

### 예제 프로그램

``` asm
INCLUDE Irvine32.inc

.code
main PROC
    mov eax, 5
    add eax, 6

    exit
main ENDP
END main
```

환경에 따라 `exit` 매크로가 추가 명령으로 확장될 수 있지만 핵심 두
명령의 대표적인 인코딩은 다음과 같이 볼 수 있다.

### `mov eax, 5`

대표적인 기계어:

``` text
B8 05 00 00 00
```

설명:

-   `B8` : EAX에 즉시값을 이동하는 `MOV` 명령의 opcode
-   `05 00 00 00` : 정수 5의 32비트 Little Endian 표현

즉:

``` text
5 = 00000005h
메모리/명령 스트림의 바이트 = 05 00 00 00
```

### `add eax, 6`

어셈블러가 선택하는 인코딩에 따라 대표적으로 다음과 같은 형태가 나올 수
있다.

``` text
83 C0 06
```

설명:

-   `83` : 부호 확장된 8비트 immediate 값을 레지스터/메모리에 더하는
    계열 opcode
-   `C0` : 대상이 EAX임을 나타내는 ModR/M 바이트
-   `06` : 더할 즉시값 6

따라서 Listing File을 보면 어셈블리 명령어가 실제 CPU가 실행할 수 있는
opcode와 operand byte로 변환되는 것을 확인할 수 있다.

> 정확한 Listing File의 바이트 배열은 MASM 버전과 최적 인코딩 선택에
> 따라 다를 수 있으므로 제출할 때는 자신의 `.lst` 파일에 실제 출력된
> 값을 기준으로 설명하는 것이 가장 정확하다.

------------------------------------------------------------------------

## 6. AddVariables Program --- 64비트 변수 사용

### 문제

AddVariables 프로그램을 64비트 변수를 사용하도록 수정하고, 발생하는
syntax error와 해결 방법을 설명한다.

### 핵심 변경 사항

32비트 코드에서 일반적으로 다음과 같이 사용했다면:

``` asm
.data
first  DWORD 20000h
second DWORD 11111h
third  DWORD 22222h
sum    DWORD ?

.code
mov eax, first
add eax, second
add eax, third
mov sum, eax
```

64비트 변수로 변경할 때는 데이터 타입을 `QWORD`로 변경한다.

``` asm
.data
first  QWORD 20000h
second QWORD 11111h
third  QWORD 22222h
sum    QWORD ?
```

그리고 64비트 데이터를 처리하기 위해 32비트 `EAX` 대신 64비트 `RAX`를
사용한다.

``` asm
mov rax, first
add rax, second
add rax, third
mov sum, rax
```

### 64비트 형태의 핵심 예시

``` asm
.data
first  QWORD 20000h
second QWORD 11111h
third  QWORD 22222h
sum    QWORD ?

.code
main PROC
    mov rax, first
    add rax, second
    add rax, third
    mov sum, rax

    ; 64비트 Windows 환경의 종료 코드는
    ; 사용하는 라이브러리/프로젝트 설정에 맞게 처리한다.
main ENDP
END
```

### 발생할 수 있는 오류와 원인

#### 1. Operand size mismatch

예를 들어 다음과 같이 작성하면 문제가 발생할 수 있다.

``` asm
mov eax, first
```

`EAX`는 32비트인데 `first`는 `QWORD`, 즉 64비트이기 때문이다.

**해결:**

``` asm
mov rax, first
```

처럼 64비트 레지스터를 사용한다.

#### 2. 32비트 전용 프로젝트 설정 문제

`Irvine32.inc`, 32비트 라이브러리, `.model flat, stdcall` 등의 설정은
64비트 MASM 프로젝트에서 그대로 사용할 수 없다.

**해결:** 64비트용 프로젝트로 설정하고 64비트 환경에 맞는 라이브러리 및
호출 방식을 사용한다.

#### 3. 32비트와 64비트 레지스터 혼용

64비트 변수 전체를 계산하면서 `EAX`, `EBX` 등의 32비트 레지스터를
사용하면 상위 32비트가 보존되지 않는다.

**해결:** `RAX`, `RBX`, `RCX`, `RDX` 등 64비트 레지스터를 사용한다.

### 정리

64비트 변수로 변경할 때 가장 중요한 점은 다음과 같다.

1.  `DWORD` → `QWORD`
2.  `EAX` 등의 32비트 레지스터 → `RAX` 등의 64비트 레지스터
3.  프로젝트를 64비트 MASM 환경에 맞게 구성
4.  32비트 전용 라이브러리와 호출 규약을 그대로 사용하지 않기

즉, 단순히 변수 선언만 `QWORD`로 바꾸는 것이 아니라 **데이터 크기,
레지스터 크기, 라이브러리 및 호출 환경을 모두 64비트에 맞춰야 한다.**
