# 컴퓨터 구조 기초 정리

## 1. System Bus (시스템 버스)

**System Bus**는 CPU, 메모리, 입출력 장치(I/O) 사이에서 **정보를 전달하는 통로**입니다.

시스템 버스는 크게 다음 3가지로 나뉩니다.

| 종류 | 역할 | 쉽게 이해하면 |
|---|---|---|
| **Data Bus (데이터 버스)** | 실제 데이터를 전달 | "무엇을 보낼 것인가?" |
| **Address Bus (주소 버스)** | 데이터가 저장되거나 읽힐 메모리 주소를 전달 | "어디로 보낼 것인가?" |
| **Control Bus (제어 버스)** | 읽기/쓰기 등의 제어 신호를 전달 | "무엇을 할 것인가?" |

### 예시

CPU가 메모리의 특정 위치에서 데이터를 읽는 경우:

1. **Address Bus** → CPU가 읽고 싶은 메모리 주소를 전달
2. **Control Bus** → `READ` 신호를 전달
3. **Data Bus** → 해당 주소에 저장된 데이터가 CPU로 전달

```text
CPU
 │
 ├── Address Bus ──> 메모리 주소 전달
 ├── Control Bus ──> Read / Write 제어
 └── Data Bus    <─> 실제 데이터 전달
 │
Memory / I/O
```

### 핵심 암기

```text
Address Bus = 어디?
Data Bus    = 무엇을?
Control Bus = 어떻게?
```

---

## 2. C언어의 메모리 구조

C 프로그램이 실행되면 메모리는 대표적으로 다음 영역으로 구분됩니다.

```text
높은 주소
┌─────────────────────┐
│        Stack        │  지역 변수, 매개변수
├─────────────────────┤
│                     │
│     Free Space      │
│                     │
├─────────────────────┤
│         Heap        │  동적 할당
├─────────────────────┤
│     Data / BSS      │  전역 변수, static 변수
├─────────────────────┤
│        Text         │  실행할 프로그램 코드
└─────────────────────┘
낮은 주소
```

| 영역 | 저장되는 것 | 특징 |
|---|---|---|
| **Text(Code)** | 실행할 프로그램 명령어 | 프로그램 코드 저장 |
| **Data** | 초기값이 있는 전역/static 변수 | 프로그램 종료까지 유지 |
| **BSS** | 초기화되지 않았거나 0으로 초기화되는 전역/static 변수 | 프로그램 종료까지 유지 |
| **Heap** | `malloc`, `calloc` 등으로 할당한 메모리 | 개발자가 직접 관리 |
| **Stack** | 지역 변수, 함수 매개변수, 호출 정보 | 함수 호출과 반환에 따라 자동 관리 |

### 간단한 예제

```c
#include <stdio.h>
#include <stdlib.h>

int global = 10;       // Data 영역
int global2;           // BSS 영역

int main(void)
{
    int number = 5;            // Stack 영역
    int *ptr = malloc(sizeof(int)); // ptr은 Stack, 할당 공간은 Heap

    *ptr = 100;

    printf("%d\n", *ptr);

    free(ptr);

    return 0;
}
```

### 핵심 암기

```text
Text  = 코드
Data  = 초기화된 전역/static 변수
BSS   = 초기화되지 않은 전역/static 변수
Heap  = 동적 메모리
Stack = 지역 변수 / 함수 호출
```

---

## 3. Register (레지스터)

**Register(레지스터)**는 **CPU 내부에 존재하는 매우 빠른 기억장치**입니다.

CPU가 계산을 수행할 때 필요한 값이나 주소, 명령어 등을 잠시 저장합니다.

```text
CPU 내부

┌─────────────────────┐
│         CPU         │
│                     │
│   ┌─────────────┐   │
│   │  Register   │   │ ← 매우 빠름
│   └─────────────┘   │
│          │          │
│         ALU         │
└─────────────────────┘
          │
        Cache
          │
         RAM
          │
      SSD / HDD
```

일반적으로 CPU와 가까울수록 **속도가 빠르지만 용량은 작습니다.**

```text
Register → Cache → RAM → SSD/HDD
   빠름                    느림
   작음                    큼
```

### 대표적인 레지스터

| 레지스터 | 역할 |
|---|---|
| **PC (Program Counter)** | 다음에 실행할 명령어의 주소 저장 |
| **IR (Instruction Register)** | 현재 실행 중인 명령어 저장 |
| **SP (Stack Pointer)** | 현재 스택의 위치를 가리킴 |
| **General Purpose Register** | 연산에 필요한 데이터 등을 임시 저장 |

---

## 4. 전체 관계 이해하기

CPU가 프로그램을 실행한다고 생각하면 다음과 같이 연결할 수 있습니다.

```text
              System Bus
CPU  <────────────────────────>  Memory
 │
 ├─ Register
 │    └─ 현재 계산에 필요한 값을 빠르게 저장
 │
 ├─ Address Bus
 │    └─ 접근할 메모리 위치 지정
 │
 ├─ Control Bus
 │    └─ READ / WRITE 등의 명령 전달
 │
 └─ Data Bus
      └─ 실제 데이터 전달
```

C 프로그램의 변수와 코드는 메모리의 **Text / Data / BSS / Heap / Stack** 등에 배치되고, CPU는 **System Bus**를 통해 메모리에 접근합니다.

CPU 내부에서는 필요한 값을 **Register**에 가져와 빠르게 연산합니다.

---

## 5. 시험 직전 핵심 요약

```text
[System Bus]
Data Bus    → 실제 데이터 전달
Address Bus → 주소 전달
Control Bus → Read/Write 등의 제어 신호 전달

[C언어 메모리]
Text  → 프로그램 코드
Data  → 초기화된 전역/static 변수
BSS   → 초기화되지 않은 전역/static 변수
Heap  → 동적 메모리 할당
Stack → 지역 변수, 매개변수, 함수 호출

[Register]
CPU 내부의 매우 빠른 기억장치
연산에 필요한 데이터, 주소, 명령어 등을 임시 저장
```

## 한 문장으로 연결하기

> **CPU는 System Bus를 통해 메모리와 데이터를 주고받으며, 실행에 필요한 값은 CPU 내부의 빠른 Register에 저장하여 연산한다. C 프로그램의 데이터는 용도에 따라 Text, Data/BSS, Heap, Stack 영역에 배치된다.**
