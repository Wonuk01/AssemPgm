# MASM Average Calculator

A simple 32-bit x86 assembly program that reads **five integers**, stores them in an array, calculates their sum, and prints their average to **two decimal places**.

## Features
- Read five signed integers using `ReadInt`.
- Store inputs in a `SDWORD` array.
- Calculate the sum using a `LOOP` instruction.
- Calculate the exact two-decimal average using signed division (`IDIV`).
- Print the sum and average with Irvine32 console procedures.

## Requirements
- Windows
- MASM (32-bit x86 toolchain, `ml.exe`)
- `Irvine32.inc`, `Irvine32.lib` and their required supporting libraries
- A MASM/Irvine32 project configured in Visual Studio, or a working MASM command-line build setup

## Build and run from VSCode on Windows
1. Install Visual Studio Build Tools with the **Desktop development with C++** workload (including MSVC, MASM and the linker).
2. Obtain a compatible **32-bit Irvine32** distribution and its required libraries (commonly `Irvine32.lib`, `kernel32.lib`, and `user32.lib`).
3. Open the **x86 Native Tools Command Prompt for VS**, then run `code .` in this folder to open VSCode with the build environment.
4. Update the paths below to the folder containing `Irvine32.inc` and `Irvine32.lib`:

```bat
ml /nologo /c /coff /I "C:\Irvine" AverageCalculator.asm
link /nologo /SUBSYSTEM:CONSOLE /MACHINE:X86 /LIBPATH:"C:\Irvine" AverageCalculator.obj Irvine32.lib kernel32.lib user32.lib
AverageCalculator.exe
```

Depending on the Irvine32 package, additional supporting libraries may be required. A normal PowerShell session may not have `ml` and `link` on PATH; use the x86 developer prompt.

## Run
1. Create a 32-bit MASM project configured for Irvine32.
2. Add `AverageCalculator.asm` to the project.
3. Assemble, link and run the project.

> This program uses `INCLUDE Irvine32.inc` and Irvine32 routines; it will not build with plain MASM alone. Ensure Irvine32 include and library paths are configured in your environment.

## Example
```text
Enter integer #1: 10
Enter integer #2: 20
Enter integer #3: 30
Enter integer #4: 40
Enter integer #5: 53
Sum: +153
Average: +30.60
```

`WriteInt` may show a leading `+` for the sum, depending on the Irvine32 implementation. The average uses `WriteDec` to avoid an extra sign.

## How it works
1. `ReadInt` reads each integer into `EAX`.
2. `ESI` points to the current array element; `TYPE numbers` advances the pointer by four bytes.
3. `ECX` and `LOOP` control the five iterations.
4. `ADD` accumulates the values in `EBX`.
5. The signed sum is divided by 5 using `CDQ` and `IDIV`. The absolute remainder is multiplied by 20 to obtain the two-digit fractional part (because 1/5 = 0.20).
6. The whole-number magnitude and two-digit fractional part are printed separately, with a minus sign for negative averages.

## Key assembly instructions
| Instruction | Purpose |
|---|---|
| `MOV` | Transfer values between registers and memory |
| `ADD` | Add numbers or advance an array pointer |
| `LOOP` | Decrement `ECX` and repeat while nonzero |
| `IMUL` | Signed multiplication |
| `CDQ` | Sign-extend `EAX` into `EDX:EAX` |
| `IDIV` | Signed division; quotient in `EAX`, remainder in `EDX` |

## Limitations
- Uses signed 32-bit arithmetic; large input values may overflow the 32-bit sum.
- Assumes valid integer input.
- Intended for educational use in a 32-bit MASM/Irvine32 environment.

## Files
- [`AverageCalculator.asm`](./AverageCalculator.asm): program source
- [`README.md`](./README.md): project documentation
