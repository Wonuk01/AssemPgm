# Chapter 1 --- 알고리즘 실습 문제

## 1.7.2 Algorithm Workbench

> **사용 언어:** Java\
> 문제에서 요구한 변환 작업을 자동으로 수행하는
> `Integer.parseInt(..., radix)` 등의 내장 함수는 사용하지 않았습니다.

------------------------------------------------------------------------

### 1. 16비트 이진 문자열 → 정수

**문제:** 16비트 이진 정수가 들어 있는 문자열을 전달받아 해당 문자열의
정수 값을 반환하는 함수를 작성하시오.

> **핵심 아이디어:** 왼쪽부터 한 자리씩 읽으면서 기존 값에 2를 곱하고
> 현재 비트를 더한다.

``` java
static int binaryToInt(String binary) {
    if (binary == null || binary.length() != 16) {
        throw new IllegalArgumentException("16비트 이진 문자열이 필요합니다.");
    }

    int value = 0;

    for (int i = 0; i < binary.length(); i++) {
        char c = binary.charAt(i);

        if (c != '0' && c != '1') {
            throw new IllegalArgumentException("올바르지 않은 이진수입니다.");
        }

        value = value * 2 + (c - '0');
    }

    return value;
}
```

**실행 예시**

``` text
입력 : 0000000000110101
출력 : 53
```

> **정답 핵심:** `value = value × 2 + 현재 비트`를 반복한다.

------------------------------------------------------------------------

### 2. 32비트 16진 문자열 → 정수

**문제:** 32비트 16진 정수가 들어 있는 문자열을 전달받아 해당 문자열의
정수 값을 반환하는 함수를 작성하시오.

> **핵심 아이디어:** 16진수는 밑이 16이므로 기존 값에 16을 곱하고 현재
> 숫자의 값을 더한다. 모든 unsigned 32비트 값을 안전하게 담기 위해
> Java의 `long`을 사용한다.

``` java
static long hexToInteger(String hex) {
    if (hex == null || hex.length() != 8) {
        throw new IllegalArgumentException("8자리 16진 문자열이 필요합니다.");
    }

    long value = 0;

    for (int i = 0; i < hex.length(); i++) {
        char c = hex.charAt(i);
        int digit;

        if (c >= '0' && c <= '9') {
            digit = c - '0';
        } else if (c >= 'A' && c <= 'F') {
            digit = c - 'A' + 10;
        } else if (c >= 'a' && c <= 'f') {
            digit = c - 'a' + 10;
        } else {
            throw new IllegalArgumentException("올바르지 않은 16진수입니다.");
        }

        value = value * 16 + digit;
    }

    return value;
}
```

**실행 예시**

``` text
입력 : 0000002A
출력 : 42
```

> **정답 핵심:** `value = value × 16 + 현재 16진수 값`을 반복한다.

------------------------------------------------------------------------

### 3. 정수 → 이진 문자열

**문제:** 정수를 전달받아 해당 정수의 이진수 표현이 들어 있는 문자열을
반환하는 함수를 작성하시오.

> **핵심 아이디어:** 정수를 계속 2로 나누면서 나머지를 역순으로
> 연결한다.

``` java
static String integerToBinary(int value) {
    if (value == 0) {
        return "0";
    }

    if (value < 0) {
        throw new IllegalArgumentException("이 구현은 0 이상의 정수를 사용합니다.");
    }

    String result = "";

    while (value > 0) {
        int remainder = value % 2;
        result = (char) ('0' + remainder) + result;
        value /= 2;
    }

    return result;
}
```

**실행 예시**

``` text
입력 : 53
출력 : 110101
```

> **정답 핵심:** **2로 나누고 나머지를 앞쪽에 붙이는 과정**을 몫이 0이
> 될 때까지 반복한다.

------------------------------------------------------------------------

### 4. 정수 → 16진 문자열

**문제:** 정수를 전달받아 해당 정수의 16진수 표현이 들어 있는 문자열을
반환하는 함수를 작성하시오.

``` java
static String integerToHex(int value) {
    if (value == 0) {
        return "0";
    }

    if (value < 0) {
        throw new IllegalArgumentException("이 구현은 0 이상의 정수를 사용합니다.");
    }

    final char[] DIGITS = "0123456789ABCDEF".toCharArray();
    String result = "";

    while (value > 0) {
        int remainder = value % 16;
        result = DIGITS[remainder] + result;
        value /= 16;
    }

    return result;
}
```

**실행 예시**

``` text
입력 : 255
출력 : FF
```

> **정답 핵심:** **16으로 반복해서 나눈 뒤 나머지 0\~15를 `0~9`, `A~F`로
> 변환한다.**

------------------------------------------------------------------------

### 5. 최대 1,000자리인 base-b 숫자 문자열 두 개 더하기

**문제:** 밑이 `b`인 두 숫자 문자열을 더하는 함수를 작성하시오.
`2 ≤ b ≤ 10`이며 각 문자열은 최대 1,000자리까지 가능하다. 결과 역시 같은
진법의 문자열로 반환한다.

> **핵심 아이디어:** 우리가 종이에 덧셈하는 것처럼 오른쪽 자리부터
> 더하고 올림(carry)을 처리한다.

``` java
static String addInBase(String a, String b, int base) {
    if (base < 2 || base > 10) {
        throw new IllegalArgumentException("진법은 2 이상 10 이하여야 합니다.");
    }

    int i = a.length() - 1;
    int j = b.length() - 1;
    int carry = 0;
    StringBuilder reversed = new StringBuilder();

    while (i >= 0 || j >= 0 || carry != 0) {
        int x = 0;
        int y = 0;

        if (i >= 0) {
            x = a.charAt(i--) - '0';
            if (x < 0 || x >= base) {
                throw new IllegalArgumentException("진법에 맞지 않는 숫자입니다.");
            }
        }

        if (j >= 0) {
            y = b.charAt(j--) - '0';
            if (y < 0 || y >= base) {
                throw new IllegalArgumentException("진법에 맞지 않는 숫자입니다.");
            }
        }

        int sum = x + y + carry;

        reversed.append((char) ('0' + (sum % base)));
        carry = sum / base;
    }

    return reversed.reverse().toString();
}
```

**실행 예시**

``` text
2진법

  1011
+ 0110
------
 10001
```

> **정답 핵심:** `현재 자리 = sum % base`, `올림 = sum / base`를
> 사용한다.

------------------------------------------------------------------------

### 6. 최대 1,000자리인 16진 문자열 두 개 더하기

**문제:** 최대 1,000자리인 두 16진 문자열을 입력받아 두 수의 합을 16진
문자열로 반환하는 함수를 작성하시오.

``` java
static int hexValue(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;

    throw new IllegalArgumentException("올바르지 않은 16진수입니다.");
}

static char hexDigit(int value) {
    return "0123456789ABCDEF".charAt(value);
}

static String addHex(String a, String b) {
    int i = a.length() - 1;
    int j = b.length() - 1;
    int carry = 0;

    StringBuilder reversed = new StringBuilder();

    while (i >= 0 || j >= 0 || carry != 0) {
        int x = (i >= 0) ? hexValue(a.charAt(i--)) : 0;
        int y = (j >= 0) ? hexValue(b.charAt(j--)) : 0;

        int sum = x + y + carry;

        reversed.append(hexDigit(sum % 16));
        carry = sum / 16;
    }

    return reversed.reverse().toString();
}
```

**실행 예시**

``` text
6B4 + 3FE = AB2
```

> **정답 핵심:** 일반 덧셈과 동일하지만 **16진법 기준으로 올림을
> 처리**한다.

------------------------------------------------------------------------

### 7. 한 자리 16진수 × 최대 1,000자리 16진 문자열

**문제:** 한 자리 16진수와 최대 1,000자리인 16진 문자열을 곱하고, 결과를
16진 문자열로 반환하는 함수를 작성하시오.

``` java
static String multiplyHex(char singleDigit, String hex) {
    int multiplier = hexValue(singleDigit);

    if (multiplier == 0 || hex.equals("0")) {
        return "0";
    }

    int carry = 0;
    StringBuilder reversed = new StringBuilder();

    for (int i = hex.length() - 1; i >= 0; i--) {
        int product = hexValue(hex.charAt(i)) * multiplier + carry;

        reversed.append(hexDigit(product % 16));
        carry = product / 16;
    }

    while (carry > 0) {
        reversed.append(hexDigit(carry % 16));
        carry /= 16;
    }

    return reversed.reverse().toString();
}
```

**실행 예시**

``` text
F × 10 = F0
```

> **정답 핵심:** 오른쪽 자리부터 한 자리씩 곱하면서 **16진법의
> 올림(carry)** 을 다음 자리로 전달한다.

------------------------------------------------------------------------

### 8. Java 코드 작성 후 `javap -c`로 바이트코드 분석

**문제:** 다음 계산을 포함하는 Java 프로그램을 작성하고 `javap -c`
명령으로 코드를 디스어셈블하시오. 각 명령이 어떤 역할을 하는지 주석으로
설명하시오.

``` java
int y;
int x = (y = 4) * 3;
```

**Java 프로그램**

``` java
public class Calculation {
    public static void main(String[] args) {
        int y;
        int x = (y = 4) * 3;
    }
}
```

**컴파일 및 확인 명령**

``` bash
javac Calculation.java
javap -c Calculation
```

대표적인 `main` 바이트코드 흐름은 다음과 같다.

``` text
iconst_4        // 정수 상수 4를 operand stack에 넣는다.
dup             // 4를 복제한다. y 저장과 곱셈에서 모두 필요하기 때문이다.
istore_1        // 4를 지역 변수 y에 저장한다.
iconst_3        // 정수 상수 3을 stack에 넣는다.
imul            // stack의 4와 3을 곱한다. 결과는 12이다.
istore_2        // 결과 12를 지역 변수 x에 저장한다.
return          // main 메서드를 종료한다.
```

> **정답 핵심:** JVM은 **스택 기반 방식**으로 `4`를 넣고 `y`에 저장한 뒤
> `3`을 넣어 곱셈을 수행하고, 결과 `12`를 `x`에 저장한다.

**참고:** Java 컴파일러/JDK 버전이나 주변 코드에 따라 지역 변수 번호
또는 일부 명령이 달라질 수 있으므로, 실제 제출 시에는 자신의 환경에서
실행한 `javap -c Calculation` 결과를 기준으로 확인하는 것이 좋다.

------------------------------------------------------------------------

### 9. 부호 없는 이진수 뺄셈

**문제:** 부호 없는 이진수를 빼는 방법을 고안하시오. `10000000`에서
`00000001`을 빼서 `01111111`이 나오는지 확인하고, 작은 수를 큰 수에서
빼는 다른 두 가지 예제도 테스트하시오.

> **핵심 아이디어:** 오른쪽에서 왼쪽으로 뺄셈한다. 현재 위쪽 비트가
> 아래쪽 비트보다 작으면 왼쪽 자리에서 `1`을 빌린다. 이진법에서 빌려온
> `1`은 현재 자리에서 `10₂`, 즉 10진수 `2`의 값을 가진다.

``` java
static String subtractBinary(String a, String b) {
    if (a.length() != b.length()) {
        throw new IllegalArgumentException("두 이진수의 길이가 같아야 합니다.");
    }

    int borrow = 0;
    StringBuilder reversed = new StringBuilder();

    for (int i = a.length() - 1; i >= 0; i--) {
        if ((a.charAt(i) != '0' && a.charAt(i) != '1') ||
            (b.charAt(i) != '0' && b.charAt(i) != '1')) {
            throw new IllegalArgumentException("올바르지 않은 이진수입니다.");
        }

        int top = (a.charAt(i) - '0') - borrow;
        int bottom = b.charAt(i) - '0';

        if (top < bottom) {
            top += 2;
            borrow = 1;
        } else {
            borrow = 0;
        }

        reversed.append(top - bottom);
    }

    if (borrow != 0) {
        throw new IllegalArgumentException("결과가 음수가 됩니다.");
    }

    return reversed.reverse().toString();
}
```

**필수 테스트**

``` text
  10000000   (128)
- 00000001   (1)
----------
  01111111   (127)
```

**추가 테스트 1**

``` text
  00110101   (53)
- 00010100   (20)
----------
  00100001   (33)
```

**추가 테스트 2**

``` text
  11110000   (240)
- 00110001   (49)
----------
  10111111   (191)
```

> **정답 핵심:** 10진수 뺄셈과 같은 방식으로 빌림(borrow)을 사용하지만,
> 이진법에서는 한 자리에서 빌려오면 현재 자리에 **`10₂ (= 2)`** 를
> 더한다.

------------------------------------------------------------------------

## 문제별 핵심 정리

    문제 주제                  **핵심 방법**
  ------ --------------------- --------------------------------------
       1 이진수 → 정수         누적값에 2를 곱하고 현재 비트 더하기
       2 16진수 → 정수         누적값에 16을 곱하고 현재 값 더하기
       3 정수 → 이진수         2로 반복 나누기
       4 정수 → 16진수         16으로 반복 나누기
       5 긴 base-b 숫자 덧셈   오른쪽부터 덧셈 + 올림
       6 긴 16진수 덧셈        16진법 기준 올림
       7 16진수 곱셈           자리별 곱셈 + 올림
       8 Java 바이트코드       `javac` + `javap -c`
       9 이진수 뺄셈           오른쪽부터 뺄셈 + 빌림
