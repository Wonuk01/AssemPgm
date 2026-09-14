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

---

# Presentation Subject — PC Hardware & PC Building

기존의 CPU·메모리·System Bus 개념을 실제 PC 하드웨어와 연결해서 이해하기 위한 발표 정리입니다.

## 6. Motherboard (메인보드)

**Motherboard(메인보드)**는 CPU, RAM, GPU, SSD, 각종 입출력 장치를 서로 연결하는 PC의 중심 기판입니다.

```text
                 ┌──────── CPU
                 │
RAM ───────── Motherboard ───────── GPU
                 │
                 ├──────── SSD
                 │
                 └──────── USB / Keyboard / Mouse / Network
```

### 주요 구성 요소

| 구성 요소 | 역할 |
|---|---|
| **CPU Socket** | CPU를 장착하는 위치 |
| **DIMM Slot** | RAM을 장착하는 슬롯 |
| **PCIe Slot** | GPU, 확장 카드 등을 연결 |
| **M.2 Slot** | NVMe SSD 등을 장착 |
| **Chipset** | 여러 장치와 입출력 기능을 관리 |
| **VRM** | CPU 등에 안정적인 전력을 공급 |
| **Rear I/O** | USB, LAN, Audio 등 외부 장치 연결 |

### 핵심 포인트

메인보드를 선택할 때는 **CPU 소켓, 칩셋, RAM 규격, PCIe/M.2 슬롯, 크기 규격(ATX 등)**의 호환성을 확인해야 합니다.

> **Motherboard = PC 부품들을 연결하고 서로 통신할 수 있게 해 주는 중심 기판**

---

## 7. CPU & GPU

### CPU (Central Processing Unit)

CPU는 프로그램의 명령어를 해석하고 계산하며 시스템 전체의 작업을 처리하는 **중앙처리장치**입니다.

CPU의 기본 동작은 다음과 같이 이해할 수 있습니다.

```text
Fetch → Decode → Execute
가져오기 → 해석 → 실행
```

CPU 내부에는 **Register, ALU, Control Unit, Cache** 등이 존재합니다.

| 요소 | 의미 |
|---|---|
| **Core** | 실제 명령을 처리하는 핵심 연산 단위 |
| **Thread** | CPU가 동시에 처리할 수 있는 작업 흐름과 관련된 논리적 실행 단위 |
| **Clock** | CPU 동작 속도를 나타내는 지표 중 하나 |
| **Cache** | 자주 사용하는 데이터를 CPU 가까이에 저장하는 고속 메모리 |

### GPU (Graphics Processing Unit)

GPU는 원래 화면의 그래픽을 빠르게 처리하기 위해 설계된 프로세서이며, 많은 연산을 **병렬로 처리하는 데 강점**이 있습니다.

```text
CPU → 복잡한 명령과 다양한 작업 처리에 강함
GPU → 많은 유사 연산을 동시에 처리하는 데 강함
```

게임에서는 CPU가 게임 로직, 물리 계산, AI 등의 작업을 처리하고 GPU는 3D 모델, 픽셀, 셰이더, 조명 등의 그래픽 연산을 주로 담당합니다.

### CPU와 GPU 비교

| 구분 | CPU | GPU |
|---|---|---|
| 주요 목적 | 범용 연산 및 시스템 제어 | 그래픽·대규모 병렬 연산 |
| 특징 | 복잡하고 다양한 작업에 강함 | 동일·유사 계산을 대량 처리하는 데 강함 |
| 게임 예시 | 게임 로직, AI, 물리 | 렌더링, 셰이더, 그래픽 효과 |

---

## 8. Main Memory & SSD

### Main Memory — RAM

**RAM(Random Access Memory)**은 현재 실행 중인 프로그램과 CPU가 바로 사용할 데이터를 임시로 저장하는 **주기억장치(Main Memory)**입니다.

```text
SSD → RAM → Cache → Register → CPU 연산
      ↑
실행 중인 프로그램과 데이터가 주로 위치
```

RAM은 SSD보다 훨씬 빠르지만 **휘발성 메모리**이므로 전원이 꺼지면 저장된 내용이 사라집니다.

### SSD (Solid State Drive)

SSD는 운영체제, 프로그램, 게임, 문서 등의 데이터를 장기간 저장하는 **보조기억장치(Storage)**입니다.

SSD는 전원이 꺼져도 데이터가 유지되는 **비휘발성 저장장치**입니다.

대표적인 연결 방식은 다음과 같습니다.

| 종류 | 특징 |
|---|---|
| **SATA SSD** | SATA 인터페이스를 사용하는 SSD |
| **NVMe SSD** | 주로 PCIe 기반으로 동작하며 높은 전송 성능 제공 |

### RAM과 SSD 비교

| 구분 | RAM | SSD |
|---|---|---|
| 역할 | 실행 중인 데이터 임시 저장 | 파일과 프로그램 장기 저장 |
| 속도 | 매우 빠름 | RAM보다 느림 |
| 전원 종료 | 데이터 사라짐 | 데이터 유지 |
| 분류 | 주기억장치 | 보조기억장치 |

> 프로그램을 실행하면 SSD에 저장되어 있던 프로그램의 필요한 부분이 RAM으로 올라오고, CPU가 이를 처리합니다.

---

## 9. Keyboard, Mouse, Monitor

키보드와 마우스는 대표적인 **입력장치(Input Device)**이고 모니터는 대표적인 **출력장치(Output Device)**입니다.

```text
Keyboard ─┐
          ├─ 입력 → Computer → 출력 → Monitor
Mouse ────┘
```

### Keyboard

사용자가 문자나 명령을 입력하는 장치입니다. 키를 누르면 해당 입력 정보가 운영체제와 실행 중인 프로그램으로 전달됩니다.

### Mouse

포인터 이동, 클릭, 드래그, 스크롤 등의 입력을 전달합니다. 마우스 센서가 이동을 감지하고 그 정보를 컴퓨터에 전달합니다.

### Monitor

GPU가 생성한 영상 정보를 사람이 볼 수 있도록 화면에 출력합니다.

모니터에서 자주 보는 요소는 다음과 같습니다.

| 항목 | 의미 |
|---|---|
| **Resolution** | 화면을 구성하는 픽셀 수 (예: 1920×1080) |
| **Refresh Rate** | 1초 동안 화면을 갱신하는 횟수 (예: 60Hz, 144Hz) |
| **Response Time** | 픽셀이 상태를 변경하는 데 걸리는 시간과 관련된 지표 |

### 입력과 출력의 흐름

```text
사용자
 │
 ├─ Keyboard
 └─ Mouse
      ↓
     CPU / 프로그램
      ↓
     GPU
      ↓
   Monitor
```

---

## 10. PC Building (PC 조립)

PC 조립에서 가장 중요한 것은 단순히 부품을 연결하는 것이 아니라 **부품 간 호환성, 전원, 냉각, 연결 상태를 확인하는 것**입니다.

### 주요 부품

```text
CPU
Motherboard
RAM
GPU
SSD
Power Supply (PSU)
CPU Cooler
Case
Keyboard / Mouse / Monitor
```

### 조립 전 호환성 확인

| 확인 항목 | 예시 |
|---|---|
| CPU ↔ Motherboard | CPU 소켓과 칩셋 지원 여부 |
| RAM ↔ Motherboard | DDR 규격 및 지원 용량/속도 |
| GPU ↔ Case | 그래픽카드 길이와 두께 |
| Motherboard ↔ Case | ATX / Micro-ATX / Mini-ITX 규격 |
| SSD ↔ Motherboard | M.2 규격 및 인터페이스 지원 여부 |
| PSU ↔ System | 충분한 출력과 필요한 전원 커넥터 |
| Cooler ↔ CPU/Case | 소켓 지원 및 장착 공간 |

### 기본적인 조립 순서

1. 메인보드에 **CPU** 장착
2. **CPU Cooler** 장착
3. **RAM** 장착
4. **M.2 SSD** 장착
5. 메인보드를 **Case**에 장착
6. **Power Supply** 장착 및 전원 케이블 연결
7. **GPU**를 PCIe 슬롯에 장착
8. 케이스의 전원 버튼, USB, 팬 등의 케이블 연결
9. **Monitor / Keyboard / Mouse** 연결
10. 전원을 켜고 BIOS/UEFI에서 CPU, RAM, SSD 등이 정상 인식되는지 확인
11. 운영체제와 필요한 드라이버 설치

### PC가 동작하는 전체 흐름

```text
Keyboard / Mouse
       │
       ▼
┌───────────────────────────────┐
│          Motherboard          │
│                               │
│ CPU ↔ RAM                     │
│  │                            │
│  ├──────── SSD                │
│  │                            │
│  └──────── GPU ────── Monitor │
└───────────────────────────────┘
              ▲
              │
             PSU
        전체 부품에 전력 공급
```

---

## 11. Presentation 핵심 요약

```text
[Motherboard]
모든 주요 PC 부품을 연결하는 중심 기판

[CPU]
프로그램 명령어를 해석하고 범용 연산 수행

[GPU]
그래픽과 대규모 병렬 연산 수행

[Main Memory - RAM]
실행 중인 프로그램과 데이터를 임시 저장
빠르지만 전원을 끄면 데이터가 사라짐

[SSD]
운영체제, 프로그램, 파일을 장기간 저장
전원을 꺼도 데이터가 유지됨

[Keyboard / Mouse]
사용자의 정보를 컴퓨터에 전달하는 입력장치

[Monitor]
컴퓨터의 처리 결과를 화면으로 보여주는 출력장치

[PC Building]
CPU → Cooler → RAM → SSD → Motherboard/Case → PSU → GPU → Cable → Boot
호환성과 전원 연결 확인이 중요
```

## 발표 전체를 한 문장으로 연결하기

> **메인보드는 CPU, GPU, RAM, SSD와 입출력 장치를 연결하고, CPU와 GPU가 데이터를 처리하며, RAM은 실행 중인 데이터를 임시 저장하고 SSD는 데이터를 장기간 보관한다. 키보드와 마우스로 입력한 정보는 컴퓨터에서 처리된 뒤 모니터로 출력되며, PC 조립은 이러한 부품들의 호환성과 연결 관계를 이해하고 하나의 시스템으로 구성하는 과정이다.**
