# Chapter 3 Algorithm Workbench 정답

## 3.9.2 Algorithm Workbench

### 1. 정수 25를 10진수, 2진수, 8진수, 16진수 형식으로 나타내는 기호 상수 네 개를 정의하라.

``` asm
DECIMAL_25 = 25
BINARY_25  = 11001b
OCTAL_25   = 31o
HEX_25     = 19h
```

네 상수는 모두 동일한 정수 값 **25**를 나타낸다.

### 2. 하나의 프로그램이 여러 개의 Code Segment와 Data Segment를 가질 수 있는지 확인하라.

**가능하다.** MASM에서는 여러 세그먼트를 선언할 수 있다. 다만 일반적인
32비트 flat memory model에서는 `.code`, `.data`를 이용해 단순하게
구성하는 경우가 많으며, 실제 배치와 결합은 어셈블러와 링커의 세그먼트
처리 규칙에 따른다.

### 3. Doubleword를 메모리에 Big Endian 형식으로 저장하는 데이터 정의를 작성하라.

예를 들어 `12345678h`를 Big Endian 바이트 순서로 저장하려면 직접 바이트
순서를 지정한다.

``` asm
bigEndian BYTE 12h, 34h, 56h, 78h
```

x86은 기본적으로 Little Endian이므로 단순히 다음과 같이 쓰면:

``` asm
value DWORD 12345678h
```

메모리에는 `78h 56h 34h 12h` 순서로 저장된다. 따라서 Big Endian 형태가
필요하면 바이트 단위로 원하는 순서를 정의할 수 있다.

### 4. DWORD 형식의 변수에 음수를 대입할 수 있는지 확인하라. 이것은 어셈블러의 타입 검사에 대해 무엇을 알려주는가?

다음과 같은 선언을 시험할 수 있다.

``` asm
value DWORD -1
```

MASM에서는 이러한 선언이 가능하며 `-1`은 32비트 2의 보수 값인
`FFFFFFFFh`로 저장될 수 있다.

이는 어셈블러의 데이터 타입 검사가 고급 언어처럼 엄격하게
**signed/unsigned 의미를 강제하지 않는 경우가 있음**을 보여준다.
`DWORD`는 기본적으로 32비트 크기를 나타내는 것이 핵심이며, signed 의미를
명확히 표현하려면 `SDWORD`를 사용하는 것이 좋다.

### 5. EAX에 5를 더하는 명령과 EDX에 5를 더하는 명령을 작성하고 Listing File의 기계어를 비교하라.

``` asm
add eax, 5
add edx, 5
```

일반적인 인코딩 예:

``` text
83 C0 05    add eax, 5
83 C2 05    add edx, 5
```

두 명령은 수행하는 연산과 즉시값 `05`는 같지만, **대상 레지스터를
지정하는 ModR/M 바이트가 다르다.**\
즉 EAX를 나타내는 부분과 EDX를 나타내는 부분 때문에 기계어 일부가
달라진다.

> 실제 Listing File의 바이트는 사용한 MASM 버전과 어셈블러가 선택한
> 동등한 인코딩 방식에 따라 표현이 달라질 수 있다.

### 6. `456789ABh`의 바이트를 Little Endian 순서로 나열하라.

원래 바이트:

``` text
45 67 89 AB
```

Little Endian 메모리 순서:

``` text
AB 89 67 45
```

### 7. 초기화되지 않은 unsigned doubleword 값 120개를 갖는 배열을 선언하라.

``` asm
dArray DWORD 120 DUP(?)
```

### 8. 알파벳의 첫 다섯 글자로 초기화된 byte 배열을 선언하라.

``` asm
letters BYTE 'A', 'B', 'C', 'D', 'E'
```

또는:

``` asm
letters BYTE "ABCDE"
```

### 9. 32비트 signed integer 변수를 선언하고 표현 가능한 가장 작은 음의 10진수 값으로 초기화하라.

32비트 signed integer의 최소값은 **-2,147,483,648**이다.

``` asm
minValue SDWORD -2147483648
```

### 10. 세 개의 초기값을 사용하는 `wArray`라는 unsigned 16비트 정수 변수를 선언하라.

``` asm
wArray WORD 10, 20, 30
```

`WORD`는 각 원소가 16비트 크기이다.

### 11. 좋아하는 색상의 이름을 포함하는 null-terminated 문자열을 선언하라.

예를 들어 파란색(Blue)을 사용하면:

``` asm
favoriteColor BYTE "Blue", 0
```

마지막의 `0`이 문자열 종료를 나타내는 null 문자이다.

### 12. `dArray`라는 이름으로 초기화되지 않은 signed doubleword 50개의 배열을 선언하라.

``` asm
dArray SDWORD 50 DUP(?)
```

### 13. `"TEST"`라는 단어가 500번 반복되는 문자열 변수를 선언하라.

``` asm
testString BYTE 500 DUP("TEST")
```

`"TEST"`는 4바이트이므로 전체 문자열 데이터의 크기는 2000바이트이다.

### 14. `bArray`라는 unsigned byte 20개짜리 배열을 만들고 모든 원소를 0으로 초기화하라.

``` asm
bArray BYTE 20 DUP(0)
```

### 15. 다음 doubleword 변수의 바이트가 메모리의 낮은 주소에서 높은 주소 순서로 어떻게 저장되는지 나타내라.

``` asm
val1 DWORD 87654321h
```

값을 바이트 단위로 나누면:

``` text
87 65 43 21
```

x86은 Little Endian 방식이므로 실제 메모리의 **낮은 주소 → 높은 주소**
순서는:

``` text
21h 43h 65h 87h
```
