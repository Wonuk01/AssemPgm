TITLE Student Information (StudentInfo.asm)
INCLUDE Irvine32.inc

.data
    studentID BYTE "20260001", 0
    studentName BYTE "Hong Gildong", 0
    idMsg BYTE "Student ID: ", 0
    nameMsg BYTE "Name: ", 0

.code
main PROC
    mov edx, OFFSET idMsg
    call WriteString
    mov edx, OFFSET studentID
    call WriteString
    call Crlf

    mov edx, OFFSET nameMsg
    call WriteString
    mov edx, OFFSET studentName
    call WriteString
    call Crlf

    exit
main ENDP
END main
