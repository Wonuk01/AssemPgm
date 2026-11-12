# Chapter 9 — Programming Exercises (9.10)
원문 14문항 순서 유지 · 문제 번역, 구현 핵심, 테스트 기준

**공통 조건:** 32비트 또는 64비트로 구현 가능. 문자열은 널 종료(`0`) 방식. 각 프로시저에 대한 짧은 테스트용 드라이버 프로그램을 작성해야 한다. 아래 예시는 주로 32비트 MASM/Irvine32을 기준으로 한다.

## 1. Improved Str_copy Procedure — Str_copyN
**요구:** 복사 가능한 최대 문자 수를 추가 인수로 받는 문자열 복사 함수.

**구현:** 소스/대상 포인터와 최대 문자 수 N을 받는다. 소스가 널을 만나거나 N개 복사하면 종료하고 대상에 널을 기록한다. **대상 버퍼에는 N+1바이트 이상** 있어야 한다.

**테스트:** `"ABCDE"`, N=3 → `"ABC"`; N=0 → 빈 문자열.

## 2. Str_concat
**요구:** 원본 문자열을 대상 문자열 끝에 연결한다. 대상 공간은 충분하다고 가정.
```asm
targetStr BYTE "ABCDE",10 DUP(0)
sourceStr BYTE "FGH",0
INVOKE Str_concat, ADDR targetStr, ADDR sourceStr
; 결과: "ABCDEFGH"
```
**구현:** 대상의 종료 널을 찾아 그 위치부터 소스를 복사하고 새 종료 널까지 쓴다.

## 3. Str_remove
**요구:** 문자열의 지정 주소부터 N글자를 제거한다.
```asm
target BYTE "abcxxxxdefghijklmop",0
INVOKE Str_remove, ADDR [target+3], 4
; 결과: "abcdefghijklmop"
```
**구현:** 삭제 시작 주소부터 N칸 뒤에 있는 내용을 널까지 포함하여 앞으로 당긴다 (`REP MOVSB` 응용 가능). 삭제 범위가 문자열 끝을 넘지 않도록 검사.

## 4. Str_find
**요구:** 대상 안에서 소스 부분 문자열의 첫 등장 주소를 찾는다. 찾으면 **ZF=1**, EAX=해당 위치, 없으면 **ZF=0**, EAX 미정.
```asm
target BYTE "123ABC342432",0
source BYTE "ABC",0
INVOKE Str_find, ADDR source, ADDR target
jnz notFound
; 발견 시 EAX는 target+3
```
**구현:** 대상의 각 시작 위치에서 소스 문자열을 순차 비교한다. 반환 직전에 `CMP`/`TEST` 등으로 요구된 ZF를 명시적으로 설정. 빈 소스 문자열의 처리 규칙도 정한다.

## 5. Str_nextWord
**요구:** 처음 만나는 구분 문자를 널로 바꾸고, **ZF=1**, EAX=구분 문자 바로 다음 주소를 반환. 없으면 **ZF=0**.
```asm
target BYTE "Johnson,Calvin",0
INVOKE Str_nextWord, ADDR target, ','
; target 앞부분은 "Johnson", EAX는 'C' 주소
```
**구현:** 널 종료까지 검사, 구분자 발견 시 `mov byte ptr [esi],0`, `lea eax,[esi+1]`. 반환 직전 플래그 설정에 유의.

## 6. Constructing a Frequency Table — Get_frequencies
**요구:** 문자열과 **0으로 초기화된 DWORD 256개** 배열 주소를 받는다. 문자 ASCII 코드에 해당하는 인덱스의 빈도를 증가시킨다.
```asm
target BYTE "AAEBDCFBBC",0
freqTable DWORD 256 DUP(0)
INVOKE Get_frequencies, ADDR target, ADDR freqTable
; A=2, B=3, C=2, D=1, E=1, F=1
```
**구현 핵심:** `movzx eax, byte ptr [esi]` 후 `inc dword ptr [edi+eax*4]`. 널 문자는 세지 않는다.

## 7. Sieve of Eratosthenes — 에라토스테네스의 체
**요구:** 65,000바이트 배열을 미초기화 데이터 영역에 선언, `STOSB`로 0 초기화, 2~65,000의 모든 소수를 출력한다.

**구현 순서:** (1) 배열 초기화 (2) p=2부터 p*p≤65000까지 미표시된 p에 대해 p*p, p*p+p ... 위치를 1로 표시 (3) 2~65000 중 표시 0인 인덱스 출력. 0과 1은 소수가 아니다.

**시험 포인트:** `CLD` + `REP STOSB`, 중첩 반복문, 배수 표시.

## 8. Bubble Sort — 교환 플래그 최적화
**요구:** 내부 반복에서 두 값을 교환하면 `exchangeFlag=1`로 설정. 전체 한 차례 순회에서 교환이 없으면 조기 종료.

**의사코드:**
```text
for pass in 0..n-2:
    swapped = 0
    for j in 0..n-2-pass:
        if a[j] > a[j+1]:
            swap(a[j], a[j+1])
            swapped = 1
    if swapped == 0: break
```
**테스트:** 이미 정렬된 배열은 한 번의 패스 후 종료.

## 9. Binary Search — 레지스터로 first/mid/last 관리
**요구:** 기존 이진 탐색의 `first`, `mid`, `last`를 메모리 변수가 아닌 레지스터에 저장하고 역할을 주석으로 표시.

**레지스터 예시:** ESI=first, EDI=last, EBX=mid, EAX=찾을 값, EDX=배열 주소. mid=(first+last)/2, 비교 후 범위 축소. **배열은 오름차순 정렬 전제.** 찾지 못한 경우 first>last가 되면 종료.

## 10. Letter Matrix — 모음 확률 50%의 4×4 행렬
**요구:** 대문자 4×4 행렬을 생성한다. 각 칸은 50% 확률로 모음(A,E,I,O,U), 50% 확률로 자음(나머지 21개). 이를 **5번** 생성하여 출력.

**구현:** `RandomRange 2`로 모음/자음 분기, 각각 균등 선택 후 16개 출력. 행마다 줄바꿈.

## 11. Letter Matrix/Sets with Vowels
**요구:** 위 행렬을 하나 만들고, 각 행 4개, 각 열 4개, 두 대각선 2개를 검사하여 **모음이 정확히 2개인 4글자 집합**만 출력.

**구현:** 총 10개 후보를 검사. A/E/I/O/U에 속하는 글자를 세고 개수가 2일 때 출력.

**원문 예시:**
```text
P O A Z
A E A U
G K A E
I A G D
```
출력 예: `POAZ, GKAE, IAGD, PAGI, ZUED, PEAD, ZAKI`.

## 12. Calculating the Sum of an Array Row — calc_row_sum
**요구:** 2차원 BYTE/WORD/DWORD 배열의 지정 행 합계를 계산하여 EAX 반환. **스택 매개변수**: 배열 주소, 행 크기, 배열 자료형, 행 인덱스. `INVOKE` 및 확장 `PROC` 매개변수 문법 금지.

**구현:** 행 시작 주소 = 배열 시작 + 행 인덱스×(행 원소 수×원소 바이트 수). 해당 행 원소를 `MOVZX` (BYTE/WORD) 또는 `MOV` (DWORD)로 읽어 누적. 호출자가 `PUSH`로 인수 전달, 프로시저는 `[EBP+8]` 등으로 접근한다. `EBP` 보존과 스택 정리 규약을 명시한다.

**테스트:** 사용자에게 행 인덱스를 입력받아 BYTE/WORD/DWORD 각각 합계 출력.

## 13. Trimming Leading Characters
**요구:** 문자열 **앞부분**에 연속해서 있는 지정 문자를 모두 제거한다.

**예:** `"###ABC"`에서 `'#'` 제거 → `"ABC"`.

**구현:** 첫 번째 다른 문자 위치까지 전진 후, 나머지 문자열을 원래 시작 주소로 널 포함 이동한다. 앞부분만 제거해야 하므로 `"#A#B"` → `"A#B"`.

## 14. Trimming a Set of Characters
**요구:** 문자열 **끝부분**에 연속해서 나타나는 문자 중, 필터 문자열에 속하는 문자들을 전부 제거한다.

**예:** `"ABC#$&"`, 필터 `"%#!;$&*"` → `"ABC"`.

**구현:** 문자열 끝에서 역방향으로 한 글자씩 검사. 현재 문자가 필터에 포함되면 널로 바꾸고 계속 진행. 포함되지 않는 첫 문자에서 종료. 필터에 없는 중간 문자는 제거하지 않는다.

---

## 시험 대비 우선순위 (학습 제안, 원문 출제 예고 아님)
- **우선:** 2(연결), 3(삭제), 4(검색), 5(구분자), 6(빈도표), 8(버블 정렬), 9(이진 검색)
- **다음:** 1(제한 복사), 12(스택 매개변수), 13~14(앞/뒤 trim)
- **확장:** 7(소수 체), 10~11(랜덤 행렬)

> **범위 안내:** 첨부 원문에는 9.5절의 BubbleSort/BinarySearch 프로시저 본문이 없어, 그 원본 코드의 정확한 수정 위치는 확인할 수 없다. 이 파일은 해당 문항의 요구사항과 구현 알고리즘을 정리한 학습 가이드이며 14개 완성 실행 프로그램을 제공하는 것은 아니다.
