section .rodata
  STD_OUT       equ 1
  STD_ERROR     equ 2

  SYS_EXIT      equ 1
  SYS_READ      equ 3
  SYS_WRITE     equ 4
  SYS_OPEN      equ 5
  SYS_CLOSE     equ 6

  O_RDONLY      equ 0

  EXIT_SUCCESS  equ 0
  EXIT_ERROR    equ 1

section .data
  BUFFLEN       equ 16384
  NUMLEN        equ 2000          ;SHOULD BE THE NUMBER OF LINES OF THE INPUT FILE
  TMPBUFLEN     equ 32
  error_msg     db 'Error!', 0x0a, 0
  len_error_msg equ $-error_msg
  part1         db 'Part 1: ', 0
  len_part     equ $-part1
  part2         db 'Part 2: ', 0

  new_line      db 0x0a

section .bss
  fd_in             resb 1
  buffer            resb BUFFLEN
  tmpbuf            resb TMPBUFLEN
  numbers           resd NUMLEN
  first_floor_pos   resb 4
  has_been_reached  resb 1

section .text
  global _start

_start:
  ;init
  mov eax, 0
  mov [first_floor_pos], eax
  mov [has_been_reached], eax
  xor edi, edi

  ;argument handling
  pop ecx                       ;put argc in ecx
  cmp ecx, 2                    ;2 for the binary and the input file
  jne error                     ;error if not 2

  pop ebx                       ;pop the binary name
  pop ebx                       ;store the filename in ebx

  ;open input file
  mov eax, SYS_OPEN
  mov ecx, O_RDONLY
  int 0x80                      ;call kernel

  cmp eax, 0                    ;check sys_open retval
  jl  error                     ;if != 0, error!
  mov [fd_in], eax              ;move the result (fd) in fd_in

  ; start reading the input file
  mov ebx, [fd_in]              ;fd in ebx register
  lea ecx, [buffer]             ;buffer for what is read
  mov edx, BUFFLEN              ;max amount to be read
.read:
  ;read from file
  mov eax, SYS_READ
  int 0x80                      ;call kernel

  cmp eax, 0                    ;check sys_read retval
  jl close_fd_and_error         ;<0 is an error!
  je .read_done                 ;read returns 0, we are done

  add ecx, eax                  ;move the pointer by num read
  sub edx, eax                  ;sub max buff by num read
  jmp .read                     ;otherwise continue

.read_done:
  inc ecx
  mov [ecx], byte 0             ;add 0 at end of buffer to make it null terminated

  ;calc len of string read
  mov edx, ecx
  sub edx, buffer

  xor eax, eax                  ;will be the start of the next sub string
  xor ebx, ebx                  ;will be the counter for the int array
  xor ecx, ecx                  ;will be the counter
  lea esi, [buffer]             ;pointer to first

.parse_next_int:
  mov al, byte [esi]            ;get the next byte
  inc esi                       ;increment our inputbuffer string index
  cmp al, 0xa                   ;check if the byte is a newline
  je .to_int                    ;if yes, we can convert that string to 

  mov [tmpbuf+ecx], al          ;get the byte into the temporary buffer
  inc ecx                       ;move to next byte
  jmp .parse_next_int           ;continue

.to_int:
  lea edi, [tmpbuf]             ;load the address of the temporary buffer into edi (our atoi spec)
  call atoi                     ;call our atoi function
  mov [numbers+ebx*4], eax      ;move the result into the next slot of the int array (numbers)

  ;clear the temp buf
  xor eax, eax                  ;eax back to 0
  lea edi, [tmpbuf]             ;move the address of numberbuf into rdi
                                ;stosb will store al (which is 0) at address edi (tmpbuf)
  repe stosb                    ;rep will repeat stosb until ecx is decremented to 0

  inc ebx                       ;move to the next index for our numbers
  xor ecx, ecx                  ;ecx is back to 0
  cmp ebx, NUMLEN               ;check if we have gone through all numbers (thanks AOC for non variables input)
  jl .parse_next_int            ;if any left, we are back at it!

  ;otherwise lets move on to the exercise
  xor edi, edi                  ;will be the counter
  mov eax, 1                    ;will be the index
  mov esi, [numbers]            ;store the first value

.part1:
  cmp eax, NUMLEN               ;check if we went through all numbers
  je .part1_done                ;we did, we are done with part1

  mov edx, [numbers+eax*4]      ;store current value
  inc eax                       ;move to next index
  cmp esi, edx                  ;check if increased or not
  jl .part1_increased           ;increase our result
  mov esi, edx
  jmp .part1                    ;otherwise continue

.part1_increased:
  inc edi                       ;increment the result
  mov esi, edx
  jmp .part1                    ;and continue

.part1_done:
  ;print 'Part 1:'
  mov eax, SYS_WRITE
  mov ebx, STD_OUT
  mov ecx, part1
  mov edx, len_part
  int 0x80                      ;call kernel
  mov eax, edi
  call print_result

  ;part 2!
  xor edi, edi                  ;will be the counter
  mov eax, 1                    ;will be the index
  mov esi, [numbers]            ;store the first value
  add esi, [numbers+eax*4]      ;add to it the second value
  add esi, [numbers+(eax+1)*4]  ;finally add the third value

.part2:
  mov ecx, eax
  add ecx, 2
  cmp ecx, NUMLEN               ;check if we went through all numbers
  je .part2_done                ;we did, we are done with part2

  mov edx, [numbers+eax*4]      ;store current value
  add edx, [numbers+(eax+1)*4]  ;add to it the second value
  add edx, [numbers+(eax+2)*4]  ;finally add the third value
  inc eax                       ;move to next index
  cmp esi, edx                  ;check if increased or not
  jl .part2_increased           ;increase our result
  mov esi, edx
  jmp .part2                    ;otherwise continue
.part2_increased:
  inc edi                       ;increment the result
  mov esi, edx
  jmp .part2

.part2_done:
  ;print 'Part 2:'
  mov eax, SYS_WRITE
  mov ebx, STD_OUT
  mov ecx, part2
  mov edx, len_part
  int 0x80                      ;call kernel
  mov eax, edi
  call print_result

done:
  call close_file
  mov	eax, SYS_EXIT
  mov ebx, EXIT_SUCCESS
  int	0x80                      ;call kernel

close_fd_and_error:
  call close_file
  call error

error:
  call close_file
  mov eax, SYS_WRITE
  mov ebx, STD_ERROR
  mov ecx, error_msg
  mov edx, len_error_msg
  int 0x80                      ;call kernel

  mov	eax, SYS_EXIT
  mov ebx, EXIT_ERROR
  int	0x80                      ;call kernel

close_file:
  ; close the file
  mov eax, SYS_CLOSE
  mov ebx, [fd_in]
  int 0x80                      ;call kernel
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_result:
  xor esi, esi                  ;we will store some counter in esi

.loop:
  mov edx, 0
  mov ebx, 10
  div ebx                       ;div by 10 on eax
  add edx, 48                   ;add 48 to the remainder to make is char
  push edx                      ;push the remainder on the stack
  inc esi                       ;inc esi by one to keep track of nb of items on the stack
  cmp eax, 0                    ;should be continue?
  jz .next                      ;no, let's start printing
  jmp .loop                     ;yes, there is more

.next:
  cmp esi, 0                    ;nothing to print?
  jz .done                      ;finished
  dec esi                       ;dec esi as we are poping one from the stack
  mov eax, SYS_WRITE
  mov ebx, STD_OUT
  mov ecx, esp                  ;top
  mov edx, 1
  int 0x80                      ;call kernel
  add esp, 4
  jmp .next                     ;again

.done:
  mov eax, SYS_WRITE
  mov ebx, STD_OUT
  mov ecx, new_line
  mov edx, 1
  int 0x80                      ;call kernel
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;edi needs to have the pointer to the start of the string
;result will be in eax
atoi:
    ; set rdx and rax to 0
    xor eax, eax
    xor edx, edx

.next_byte:
    mov dl, byte [edi]          ;get the next byte
    cmp edx, 0                  ;are we at the end of the string?
    je .done                    ;We are done
    sub edx, 0x30               ;subtract '0' so it converts char to digit
    imul eax, 0xa               ;multiply the current sum by 10 to make space
    add eax, edx                ;add the digit to the sum
    inc edi                     ;move our pointer
    jmp .next_byte              ;continue

.done:
  ret