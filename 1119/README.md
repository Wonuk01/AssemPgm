# 2026년 11월 19일 수업 및 실습내용입니다.

## Chapter 10 — Structures and Macros

이번 수업에서는 어셈블리 언어의 **구조체(Structures)**와 **매크로(Macros)**를 학습하고, 매크로를 활용한 반복 코드 작성 및 조건부 어셈블리 방법을 정리했습니다.

## 파일 구성

| 파일명 | 내용 |
|---|---|
| [Short_Answer.md](Short_Answer.md) | 10.7.1 단답형 문제 번역, 정답 및 해설 |
| [Algorithm_Workbench.md](Algorithm_Workbench.md) | 10.7.2 알고리즘 문제 번역, MASM 코드 및 풀이 |
| [Programming_Exercises.md](Programming_Exercises.md) | 10.8 프로그래밍 실습 문제 번역, 구현 방향 및 핵심 코드 |

## 학습 내용

### 1. Structures
- `STRUCT`, `ENDS`를 사용한 구조체 정의
- 구조체 변수 선언 및 초기화
- 중첩 구조체와 구조체 배열
- `TYPE`, `SIZEOF`, `LENGTHOF`를 이용한 데이터 크기 확인

### 2. Macros
- 매크로 정의 및 매개변수 전달
- `LOCAL`을 이용한 지역 레이블 선언
- 매크로 기본 인수
- `&`, `!`, `%` 연산자 활용
- 매크로 확장 코드 확인

### 3. Conditional Assembly
- `IF`, `ELSE`, `ENDIF`
- 상수 Boolean 표현식
- 관계 연산자 `EQ`, `NE`, `LT`, `LE`, `GT`, `GE`
- 어셈블리 단계 메시지 출력

### 4. Programming Exercises
- 키 입력 및 문자열 출력 매크로
- 정수 입력·출력 매크로
- 메모리 데이터 이동 및 곱셈
- 무작위 이동 시뮬레이션
- `SHLD`, `SHRD`를 이용한 다중 DWORD 비트 이동
- 3-피연산자 산술 연산 매크로

## 참고 및 실행 환경

- Assembly: 32-bit MASM
- Library: Irvine32
- 문제 출처: Chapter 10, Sections 10.7–10.8

> 참고: 코드 예시는 Irvine32 및 MASM 환경을 기준으로 작성했습니다. 교재의 매크로 라이브러리 버전, 매크로 인수 규칙, 프로시저의 반환 레지스터에 따라 일부 코드는 조정이 필요할 수 있습니다.
