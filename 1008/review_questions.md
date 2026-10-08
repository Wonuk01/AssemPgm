# Chapter 5 --- Review Questions

> 원문의 Review Questions 1\~20을 한국어로 번역하고 답을 정리했습니다.

## 1

**질문:** 32비트 범용 레지스터를 모두 스택에 저장하는 명령어는 무엇인가?

**답:** `PUSHAD`

## 2

**질문:** 32비트 EFLAGS 레지스터를 스택에 저장하는 명령어는 무엇인가?

**답:** `PUSHFD`

## 3

**질문:** 스택의 값을 EFLAGS 레지스터로 복원하는 명령어는 무엇인가?

**답:** `POPFD`

## 4

**질문:** NASM에서는 `PUSH EAX EBX ECX`처럼 여러 특정 레지스터를 지정할
수 있다. 이런 방식이 MASM의 `PUSHAD`보다 좋은 이유는 무엇인가?

**답:** 필요한 레지스터만 선택해서 저장할 수 있기 때문이다. `PUSHAD`는
8개의 32비트 범용 레지스터를 모두 저장하므로, 일부 레지스터만 보존하면
되는 경우 불필요한 스택 공간과 실행 시간이 사용된다.

## 5

**질문:** `PUSH` 명령어가 없다고 가정하자. `push eax`와 같은 동작을 하는
두 개의 명령어를 작성하라.

**답:**

``` asm
sub esp, 4
mov [esp], eax
```

## 6

**질문:** 참/거짓 --- `RET` 명령어는 스택의 최상단 값을 명령어 포인터로
꺼낸다.

**답:** 참(True). 32비트 모드에서는 반환 주소를 `EIP`로 복원한다.

## 7

**질문:** 참/거짓 --- Microsoft 어셈블러에서는 프로시저 정의에 `NESTED`
연산자를 사용하지 않으면 중첩 프로시저 호출이 허용되지 않는다.

**답:** 거짓(False). 프로시저는 다른 프로시저를 정상적으로 호출할 수
있다.

## 8

**질문:** 참/거짓 --- 보호 모드에서 각 프로시저 호출은 최소 4바이트의
스택 공간을 사용한다.

**답:** 참(True). 32비트 `CALL`은 4바이트 반환 주소를 스택에 저장한다.

## 9

**질문:** 참/거짓 --- 32비트 매개변수를 프로시저에 전달할 때 ESI와 EDI
레지스터는 사용할 수 없다.

**답:** 거짓(False). 호출자와 피호출자 사이의 규칙만 정해져 있다면
사용할 수 있다.

## 10

**질문:** 참/거짓 --- Section 5.2.5의 `ArraySum` 프로시저는 임의의 DWORD
배열을 가리키는 포인터를 전달받는다.

**답:** 참(True).

## 11

**질문:** 참/거짓 --- `USES` 연산자를 사용하면 프로시저 내부에서
변경되는 레지스터들을 지정할 수 있다.

**답:** 참(True). 지정한 레지스터를 프로시저 시작 시 저장하고 종료 시
복원하도록 코드를 생성한다.

## 12

**질문:** 참/거짓 --- `USES` 연산자는 `PUSH` 명령어만 생성하므로 `POP`은
직접 작성해야 한다.

**답:** 거짓(False). 필요한 저장과 복원 코드를 모두 생성한다.

## 13

**질문:** 참/거짓 --- `USES` 지시문의 레지스터 목록은 쉼표로 구분해야
한다.

**답:** 거짓(False). MASM에서는 공백으로 구분한다. 예:
`USES eax ebx ecx`

## 14

**질문:** `ArraySum`이 16비트 WORD 배열의 합을 계산하도록 하려면 어떤
부분을 수정해야 하는가? 해당 버전을 작성하라.

**답:** 요소를 32비트가 아닌 16비트로 읽어야 하므로 `mov eax,[esi]` 대신
`movzx eax, WORD PTR [esi]`를 사용하고, 다음 요소로 이동할 때 ESI를 4가
아니라 2 증가시킨다.

``` asm
ArraySum PROC USES esi ecx
    mov eax, 0
L1:
    movzx edx, WORD PTR [esi]
    add eax, edx
    add esi, 2
    loop L1
    ret
ArraySum ENDP
```

`EAX`에 합계를 누적하는 구현이다.

## 15

**질문:** 다음 명령 실행 후 EAX의 최종 값은 무엇인가?

``` asm
push 5
push 6
pop eax
pop eax
```

**답:** `5`

스택은 LIFO이므로 첫 번째 `pop eax`에서 6, 두 번째에서 5가 EAX에
들어간다.

## 16

**질문:** 다음 코드 실행 결과로 올바른 것은?

``` asm
main PROC
    push 10
    push 20
    call Ex2Sub
    pop eax
    INVOKE ExitProcess,0
main ENDP

Ex2Sub PROC
    pop eax
    ret
Ex2Sub ENDP
```

a.  6행에서 EAX=10\
b.  10행에서 런타임 오류\
c.  6행에서 EAX=20\
d.  11행에서 런타임 오류

**답:** **d. 11행에서 런타임 오류**

`CALL`이 반환 주소를 스택에 넣지만 10행의 `pop eax`가 그 반환 주소를
제거한다. 따라서 `RET`은 원래 인수였던 20을 반환 주소처럼 사용하게 되어
잘못된 위치로 이동한다.

## 17

**질문:** 다음 코드 실행 결과로 올바른 것은?

``` asm
main PROC
    mov eax,30
    push eax
    push 40
    call Ex3Sub
    INVOKE ExitProcess,0
main ENDP

Ex3Sub PROC
    pusha
    mov eax,80
    popa
    ret
Ex3Sub ENDP
```

a.  EAX=40\
b.  6행에서 런타임 오류\
c.  EAX=30\
d.  13행에서 런타임 오류

**답:** **c. EAX=30**

`PUSHA`/`POPA`가 레지스터 값을 저장하고 복원하므로 프로시저 안에서
`EAX=80`으로 바꿔도 `POPA` 후에는 원래 값 30이 복원된다.

## 18

**질문:** 다음 코드 실행 결과로 올바른 것은?

``` asm
main PROC
    mov eax,40
    push offset Here
    jmp Ex4Sub
Here:
    mov eax,30
    INVOKE ExitProcess,0
main ENDP

Ex4Sub PROC
    ret
Ex4Sub ENDP
```

a.  7행에서 EAX=30\
b.  4행에서 런타임 오류\
c.  6행에서 EAX=30\
d.  11행에서 런타임 오류

**답:** **a. 7행에서 EAX=30**

`push offset Here`가 `Here`의 주소를 스택에 넣고 `jmp`로 프로시저에
이동한다. `RET`은 그 주소를 꺼내 `Here`로 돌아오므로 `mov eax,30`이
실행된다.

## 19

**질문:** 다음 코드 실행 결과로 올바른 것은?

``` asm
main PROC
    mov edx,0
    mov eax,40
    push eax
    call Ex5Sub
    INVOKE ExitProcess,0
main ENDP

Ex5Sub PROC
    pop eax
    pop edx
    push eax
    ret
Ex5Sub ENDP
```

a.  EDX=40\
b.  13행에서 런타임 오류\
c.  EDX=0\
d.  11행에서 런타임 오류

**답:** **a. EDX=40**

10행에서 반환 주소를 EAX로 꺼내고, 11행에서 스택에 있던 40을 EDX로
꺼낸다. 12행에서 반환 주소를 다시 스택에 넣기 때문에 `RET`도 정상
동작한다.

## 20

**질문:** 다음 코드 실행 시 배열에 어떤 값들이 기록되는가?

``` asm
.data
array DWORD 4 DUP(0)

.code
main PROC
    mov eax,10
    mov esi,0
    call proc_1
    add esi,4
    add eax,10
    mov array[esi],eax
    INVOKE ExitProcess,0
main ENDP

proc_1 PROC
    call proc_2
    add esi,4
    add eax,10
    mov array[esi],eax
    ret
proc_1 ENDP

proc_2 PROC
    call proc_3
    add esi,4
    add eax,10
    mov array[esi],eax
    ret
proc_2 ENDP

proc_3 PROC
    mov array[esi],eax
    ret
proc_3 ENDP
```

**답:** 배열의 최종 값은 다음과 같다.

``` text
array = [10, 20, 30, 40]
```

`proc_3`에서 10, `proc_2`로 복귀하여 20, `proc_1`에서 30, `main`에서
40이 순서대로 저장된다.
