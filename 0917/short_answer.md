# Chapter 3 Short Answer 정답

## 3.9.1 Review Questions

### 1. 서로 다른 명령어 니모닉(mnemonic) 세 가지의 예를 들어라.

`MOV`, `ADD`, `SUB` 등이 있다.

### 2. 호출 규약(calling convention)이란 무엇이며, 어셈블리 언어 선언에서 어떻게 사용되는가?

호출 규약은 프로시저를 호출할 때 **인수를 전달하는 방법, 레지스터 사용
방법, 스택 정리 방법, 반환값 전달 방법** 등을 정한 규칙이다.\
MASM에서는 `.model flat, stdcall`과 같이 선언하여 사용할 호출 규약을
지정할 수 있다.

### 3. 프로그램에서 스택 공간은 어떻게 예약하는가?

`.STACK` 지시어를 사용한다.

``` asm
.stack 4096
```

위 예는 스택을 위해 4096바이트의 공간을 예약한다.

### 4. 왜 "assembler language"라는 표현은 정확하지 않은가?

**Assembler**는 어셈블리 언어로 작성된 소스 코드를 기계어로 변환하는
**프로그램**이고, 언어 자체는 **assembly language(어셈블리 언어)**이기
때문이다.

### 5. Big Endian과 Little Endian의 차이를 설명하고, 용어의 기원도 설명하라.

-   **Little Endian**: 가장 낮은 주소에 **최하위 바이트(LSB)**를
    저장한다.
-   **Big Endian**: 가장 낮은 주소에 **최상위 바이트(MSB)**를 저장한다.

예를 들어 `12345678h`를 저장하면:

-   Little Endian: `78 56 34 12`
-   Big Endian: `12 34 56 78`

Big-endian과 little-endian이라는 명칭은 조너선 스위프트의 소설
**《걸리버 여행기(Gulliver's Travels)》**에서 달걀을 큰 쪽(Big End) 또는
작은 쪽(Little End)부터 깨는 두 집단의 논쟁에서 유래했다. 컴퓨터
분야에서는 바이트 순서의 차이를 비유하기 위해 이 표현을 사용하게 되었다.

### 6. 정수 리터럴 대신 기호 상수(symbolic constant)를 사용하는 이유는 무엇인가?

숫자의 의미를 이름으로 표현할 수 있어 코드의 **가독성, 유지보수성, 수정
편의성**이 높아진다. 같은 값이 여러 곳에서 사용되더라도 상수 정의 한
곳만 수정하면 된다.

### 7. Source File과 Listing File의 차이는 무엇인가?

-   **Source File**: 프로그래머가 작성한 어셈블리 언어 원본 코드이다.
-   **Listing File**: 어셈블러가 생성하며, 소스 코드와 함께 주소, 기계어
    코드, 심볼 정보 등이 포함될 수 있다.

### 8. Data Label과 Code Label은 어떻게 다른가?

-   **Data Label**: 변수나 데이터가 저장된 메모리 위치를 나타낸다.
-   **Code Label**: 실행 명령어가 위치한 주소를 나타내며 점프나 분기의
    목적지로 사용된다.

### 9. (True/False) 식별자는 숫자로 시작할 수 없다.

**True**

### 10. (True/False) 16진수 리터럴은 `0x3A`와 같이 작성할 수 있다.

**True** --- MASM에서는 C 스타일의 `0x` 표기법도 사용할 수 있다.
전통적인 MASM 표기인 `3Ah`도 사용할 수 있다.

### 11. (True/False) 어셈블리 언어 지시어(directive)는 런타임에 실행된다.

**False** --- 지시어는 어셈블 과정에서 어셈블러가 처리한다.

### 12. (True/False) 어셈블리 언어 지시어는 대문자와 소문자를 자유롭게 조합하여 작성할 수 있다.

**True** --- 일반적인 MASM 소스에서는 대소문자를 구분하지 않는다.

### 13. 어셈블리 언어 명령문의 네 가지 기본 구성 요소를 쓰시오.

1.  Label
2.  Instruction mnemonic
3.  Operand(s)
4.  Comment

일반적인 형태:

``` asm
[label:] mnemonic [operands] [; comment]
```

### 14. (True/False) `MOV`는 명령어 니모닉의 예이다.

**True**

### 15. (True/False) Code Label 뒤에는 콜론(`:`)이 붙지만 Data Label 뒤에는 콜론이 붙지 않는다.

**True**

예:

``` asm
count DWORD 10     ; Data Label
L1: mov eax, count ; Code Label
```

### 16. Block Comment의 예를 보이시오.

MASM의 `COMMENT` 지시어를 사용할 수 있다.

``` asm
COMMENT !
이 부분은
여러 줄로 작성된
블록 주석이다.
!
```

### 17. 변수를 접근할 때 숫자 주소를 직접 사용하는 것이 좋지 않은 이유는 무엇인가?

변수의 실제 메모리 주소는 프로그램의 배치나 수정에 따라 달라질 수 있다.
숫자 주소를 직접 사용하면 코드가 이해하기 어렵고 수정에도 취약하다. 변수
이름과 같은 **기호 주소(symbolic address)**를 사용하는 것이 안전하다.

### 18. `ExitProcess` 프로시저에는 어떤 형식의 인수를 전달해야 하는가?

프로세스의 **종료 코드(exit code)**를 나타내는 32비트 정수 값, 즉
`DWORD` 값을 전달한다.

예:

``` asm
INVOKE ExitProcess, 0
```

### 19. 프로시저를 끝내는 지시어는 무엇인가?

`ENDP`

``` asm
main PROC
    ; ...
main ENDP
```

### 20. 32비트 모드에서 `END` 지시어에 있는 식별자의 목적은 무엇인가?

프로그램의 **실행 시작점(entry point)**을 지정한다.

``` asm
END main
```

여기서 `main`이 프로그램의 시작 프로시저이다.

### 21. `PROTO` 지시어의 목적은 무엇인가?

프로시저를 호출하기 전에 프로시저의 **이름과 매개변수 형식 등을
선언(프로토타입 선언)**하는 데 사용한다. 이를 통해 `INVOKE` 등이 올바른
인수를 전달하는지 어셈블러가 검사할 수 있다.

### 22. (True/False) Object File은 Linker가 생성한다.

**False** --- Object File은 **Assembler**가 생성한다.

### 23. (True/False) Listing File은 Assembler가 생성한다.

**True**

### 24. (True/False) Link Library는 Executable File을 생성하기 직전에 프로그램에 추가된다.

**True** --- 링커가 필요한 라이브러리 코드를 오브젝트 파일과 연결하여
실행 파일을 만든다.

### 25. 32비트 signed integer 변수를 만드는 데이터 지시어는?

`SDWORD`

``` asm
value SDWORD -100
```

### 26. 16비트 signed integer 변수를 만드는 데이터 지시어는?

`SWORD`

``` asm
value SWORD -100
```

### 27. 64비트 unsigned integer 변수를 만드는 데이터 지시어는?

`QWORD`

``` asm
value QWORD 100
```

### 28. 8비트 signed integer 변수를 만드는 데이터 지시어는?

`SBYTE`

``` asm
value SBYTE -10
```

### 29. 10바이트 packed BCD 변수를 만드는 데이터 지시어는?

`TBYTE`

`TBYTE`는 10바이트(80비트) 크기의 데이터를 정의할 때 사용한다.
