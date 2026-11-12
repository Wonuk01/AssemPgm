# Chapter 9 — Algorithm Workbench (9.9.2)
원문 12문항 순서 유지 · 32비트 MASM/Irvine32 기준, 별도 표기 시 64비트

## 1. 32비트 base-index 피연산자 예시
```asm
mov eax, [ebx+esi]
```
베이스 EBX + 인덱스 ESI.

## 2. 32비트 base-index-displacement 예시
```asm
mov eax, [ebx+esi+12]
```
주소 = EBX + ESI + 12.

## 3. DWORD 2차원 배열(3행×4열), 2행 3열(0부터 시작)
```asm
; ESI = 행 인덱스 1, EDI = 열 인덱스 2
mov eax, [myArray + esi*16 + edi*4]
```
한 행=4개×4바이트=16바이트. 단, x86 주소 모드에서 두 개의 scaled index를 동시에 사용할 수 **없다**. 위 식은 주소 계산 설명용이며 실제 MASM에서는 아래처럼 작성한다.
```asm
mov eax, esi
imul eax, 16
lea ebx, myArray
add ebx, eax
mov eax, [ebx+edi*4]
```

## 4. CMPSW로 sourcew와 targetw 비교
```asm
cld
mov esi, OFFSET sourcew
mov edi, OFFSET targetw
mov ecx, LENGTHOF sourcew
repe cmpsw
; ZF=0: 불일치 / ECX=0이고 ZF=1: 전부 일치
```
두 배열 길이가 같다는 전제.

## 5. SCASW로 0100h 검색, 일치 원소 주소를 EAX로
```asm
cld
mov edi, OFFSET wordArray
mov ecx, LENGTHOF wordArray
mov ax, 0100h
repne scasw
jnz notFound
lea eax, [edi-2]
; EAX = 일치 word 주소
notFound:
```
찾은 뒤 EDI가 2 증가하므로 2를 뺀다. 실제로는 배열이 비어 있지 않아야 한다.

## 6. Str_compare로 큰 문자열 출력
```asm
; 사전순 비교, Str_compare가 ESI/EDI 문자열 비교 후 플래그 설정
mov esi, OFFSET str1
mov edi, OFFSET str2
call Str_compare
ja firstLarger     ; 비교 결과가 unsigned 기준일 때
mov edx, OFFSET str2
jmp showIt
firstLarger:
mov edx, OFFSET str1
showIt:
call WriteString
```
문자열 비교의 대소 기준과 Irvine32 구현의 플래그 반환 규약을 확인한다.

## 7. Str_trim으로 끝의 @ 제거
```asm
mov esi, OFFSET myString
mov al, '@'
call Str_trim
```
예: `ABC@@@` → `ABC`.

## 8. Str_ucase를 소문자 변환으로 수정
```asm
; 개념적 핵심 로직: AL이 'A'..'Z'일 때만 20h 더함
cmp al, 'A'
jb skip
cmp al, 'Z'
ja skip
add al, 20h
skip:
```
원본 프로시저의 문자열 순회 구조는 유지하고 변환 범위/연산을 변경한다.

## 9. 64비트 Str_trim 예시 (RCX=문자열 주소, DL=제거 문자라는 사용자 정의 규약)
```asm
Str_trim64 PROC
    mov r8, rcx
findEnd:
    cmp byte ptr [rcx], 0
    je gotEnd
    inc rcx
    jmp findEnd
gotEnd:
    cmp rcx, r8
    je done
scanBack:
    dec rcx
    cmp byte ptr [rcx], dl
    jne done
    mov byte ptr [rcx], 0
    cmp rcx, r8
    jne scanBack
done:
    ret
Str_trim64 ENDP
```
Windows x64에서 DL은 일반적인 두 번째 정수 인수 레지스터가 아니다. **호출자가 DL에 문자를 넣는 별도 약속**으로 작성한 예시다. 표준 Windows x64 호출 규약을 따르려면 두 번째 인수인 RDX의 하위 8비트 DL을 사용하므로 이 코드는 해당 규약과도 호환된다.

## 10. 64비트 base-index 예시
```asm
mov rax, [rbx+rsi]
```

## 11. EBX=행, EDI=열, DWORD 배열 원소를 EAX로
```asm
; COLS는 한 행의 열 개수로 정의된 상수
mov eax, ebx
imul eax, COLS
lea edx, myArray
lea edx, [edx+eax*4]
mov eax, [edx+edi*4]
```
원문에는 열 개수가 없어 `COLS`가 필요하다. 한 문장만 요구하면 **행 크기가 2의 거듭제곱 배수 등 주소 모드에 맞는 경우에 한해** `mov eax, myArray[ebx*행바이트수 + edi*4]` 형태를 사용할 수 있다. 일반적인 행 크기에서는 단일 x86 명령으로 두 변수 인덱스의 곱을 모두 계산할 수 없다.

## 12. RBX=행, RDI=열, QWORD 배열 원소를 RAX로
```asm
; COLS = 한 행의 열 개수
mov rax, rbx
imul rax, COLS
lea rdx, myArray
lea rdx, [rdx+rax*8]
mov rax, [rdx+rdi*8]
```
원문에는 열 개수가 없으므로 일반적인 단일 명령 답안은 확정 불가. 행 오프셋을 미리 계산했다면 `mov rax, [myArray + rbx + rdi*8]`처럼 가능하다.

> **주의:** x86/x64 메모리 주소 피연산자는 일반적으로 `base + index*scale + displacement`이며 scale은 1,2,4,8 중 하나다. 서로 다른 두 인덱스에 동시에 배율을 줄 수 없다.
