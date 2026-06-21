[org 0x100]

jmp start_of_game

paddle_A : dw 0
paddle_B : dw 0
paddle_A_row : dw 0
paddle_B_row : dw 24
paddle_A_col : dw 30
paddle_B_col : dw 30
paddle_size : dw 20
ball_row : dw 22
ball_col : dw 40
ball : dw 0
ball_vertical_direction : db 'U'
ball_horizontal_direction : db 'R'
paddle_A_flag : dw 1
paddle_B_flag : dw 0
count : dw 1
oldkeyboardisr : dd 0,0
oldtimerisr : dd 0,0
A_score : dw 0
B_score : dw 0

clear_screen:
push es
push ax
push cx
push di

mov ax,0xB800           
mov es,ax
xor di,di
mov ax,0x0720
mov cx,2000

cld
rep stosw

pop di
pop cx
pop ax
pop es
ret

position_calculator:
push bp
mov bp,sp

push ax
push bx

mov al,80
mul byte [bp+6]
mov bx,[bp+4]
add ax,bx
shl ax,1

mov [bp+8],ax

pop bx
pop ax
pop bp
ret 4

initializing_paddle_and_ball:
push di
push cx
push es
push ax

mov ax,0xB800
mov es,ax

sub sp,2
push word [paddle_A_row]
push word [paddle_A_col]
call position_calculator
pop word [paddle_A]

sub sp,2
push word [paddle_B_row]
push word [paddle_B_col]
call position_calculator
pop word [paddle_B]

sub sp,2
push word [ball_row]
push word [ball_col]
call position_calculator
pop word [ball]

mov cx,[paddle_size]
mov di,[paddle_A]

paddle_A_print:
mov word [es:di] , 0x7800
add di,2
loop paddle_A_print

mov cx,[paddle_size]
mov di,[paddle_B]

paddle_B_print:
mov word [es:di] , 0x7800
add di,2
loop paddle_B_print

mov di,[ball]
mov word [es:di],0x0720

pop ax
pop es
pop cx
pop di
ret

playerA_miss_Ball:
push bp
mov bp,sp
push dx
push bx

mov bx , [cs:ball]
mov dx , [cs:paddle_A]
sub bx,160

cmp bx,dx
jb increaseAscore

add dx,40
cmp bx,dx
ja increaseAscore

jmp noincreaseAscore
mov word [bp+4],0

increaseAscore:
inc word [cs:B_score]
mov word [bp+4],1

noincreaseAscore:
pop bx 
pop dx
pop bp
ret

playerB_miss_Ball:
push bp
mov bp,sp
push dx
push bx

mov bx , [cs:ball]
mov dx , [cs:paddle_B]
add bx,160

cmp bx,dx
jb increaseBscore

add dx,40
cmp bx,dx
ja increaseBscore

mov word [bp+4],0
jmp noincreaseBscore

increaseBscore:
inc word [cs:A_score]
mov word [bp+4],1

noincreaseBscore:
pop bx
pop dx
pop bp
ret

ball_movement:
push es
push ax
push di

mov ax,0xB800
mov es,ax

sub sp,2
push word [cs:ball_row]
push word [cs:ball_col]
call position_calculator
pop word [cs:ball]

mov di,[cs:ball]
mov word [es:di],0x0720

cmp word [cs:ball_row],1
jne check_ball_lastrow
mov byte [cs:ball_vertical_direction],'D'
mov word [cs:paddle_B_flag],1
mov word [cs:paddle_A_flag],0

sub sp,2
call playerA_miss_Ball
pop ax
cmp ax,1
jne notintializingtoB
mov byte [cs:ball_vertical_direction],'U'
mov word [cs:paddle_B_flag],0
mov word [cs:paddle_A_flag],1
mov word [cs:ball_row],22
mov word [cs:ball_col],40
notintializingtoB:

jmp check_ball_firstcol
check_ball_lastrow:
cmp word [cs:ball_row],23
jne check_ball_firstcol
mov byte [cs:ball_vertical_direction],'U'
mov word [cs:paddle_B_flag],0
mov word [cs:paddle_A_flag],1

sub sp,2
call playerB_miss_Ball
pop ax

cmp ax,1
jne notintializingtoA
mov byte [cs:ball_vertical_direction],'D'
mov word [cs:paddle_B_flag],1
mov word [cs:paddle_A_flag],0
mov word [cs:ball_row],2
mov word [cs:ball_col],40
notintializingtoA:

check_ball_firstcol:
cmp word [cs:ball_col],0
jne check_ball_lastcol
mov byte [cs:ball_horizontal_direction],'R'
jmp moving
check_ball_lastcol:
cmp word [cs:ball_col],79
jne moving
mov byte [cs:ball_horizontal_direction],'L'

moving:

cmp byte [cs:ball_vertical_direction],'U'
jne check_down_direction 
cmp byte [cs:ball_horizontal_direction],'R'
jne check_left_up_direction

dec word [cs:ball_row]
inc word [cs:ball_col]

sub sp,2
push word [cs:ball_row]
push word [cs:ball_col]
call position_calculator
pop word [cs:ball]

mov di,[cs:ball]
mov word [es:di],0x072A

jmp check_down_direction

check_left_up_direction:

dec word [cs:ball_row]
dec word [cs:ball_col]

sub sp,2
push word [cs:ball_row]
push word [cs:ball_col]
call position_calculator
pop word [cs:ball]

mov di,[cs:ball]
mov word [es:di],0x072A

check_down_direction:
cmp byte [cs:ball_vertical_direction],'D'
jne last_ball_movement

cmp byte [cs:ball_horizontal_direction],'L'
jne check_right_down_direction

inc word [cs:ball_row]
dec word [cs:ball_col]

sub sp,2
push word [cs:ball_row]
push word [cs:ball_col]
call position_calculator
pop word [cs:ball]

mov di,[cs:ball]
mov word [es:di],0x072A

jmp last_ball_movement

check_right_down_direction:
cmp byte [cs:ball_horizontal_direction],'R'
jne last_ball_movement

inc word [cs:ball_row]
inc word [cs:ball_col]

sub sp,2
push word [cs:ball_row]
push word [cs:ball_col]
call position_calculator
pop word [cs:ball]

mov di,[cs:ball]
mov word [es:di],0x072A

last_ball_movement:

mov al,0x20
out 0x20,al

pop di
pop ax
pop es

;cmp word [cs:A_score],5
;je jumptooldtimerisr

;cmp word [cs:B_score],5
;jne iretballmovement

;jumptooldtimerisr:
;jmp far [cs:oldtimerisr]

;iretballmovement:
iret

moving_paddle_A:
push ax
push es
push di
push cx
    
mov ax, 0xB800
mov es, ax
 
mov di, [cs:paddle_A]
mov cx, [cs:paddle_size]

clear_paddle_A:
mov word [es:di], 0x0720
add di, 2
loop clear_paddle_A
    
sub sp, 2
push word [cs:paddle_A_row]
push word [cs:paddle_A_col]
call position_calculator
pop word [cs:paddle_A]
    
mov di, [cs:paddle_A]
mov cx, [cs:paddle_size]
draw_paddle_A:
mov word [es:di], 0x7800
add di, 2
loop draw_paddle_A
    
pop cx	
pop di
pop es
pop ax

ret

moving_paddle_B:
push ax
push es
push di
push cx
    
mov ax, 0xB800
mov es, ax
 
mov di, [cs:paddle_B]
mov cx, [cs:paddle_size]

clear_paddle_B:
mov word [es:di], 0x0720
add di, 2
loop clear_paddle_B
    
sub sp, 2
push word [cs:paddle_B_row]
push word [cs:paddle_B_col]
call position_calculator
pop word [cs:paddle_B]
    
mov di, [cs:paddle_B]
mov cx, [cs:paddle_size]
draw_paddle_B:
mov word [es:di], 0x7800
add di, 2
loop draw_paddle_B
    
pop cx	
pop di
pop es
pop ax

ret

paddles_movement:

push es
push ax
push di
push cx

mov ax,0xB800
mov es,ax

in al,0x60

cmp al,0x4B
jne check_right_movement

cmp word [cs:paddle_A_flag],1
jne paddle_B_left_code

cmp word [cs:paddle_A_col], 0    
jbe last_paddle_movement
dec word [cs:paddle_A_col]
call moving_paddle_A

jmp last_paddle_movement

paddle_B_left_code:
cmp word [cs:paddle_B_flag],1
jne last_paddle_movement

cmp word [cs:paddle_B_col],0    
jbe last_paddle_movement
dec word [cs:paddle_B_col]
call moving_paddle_B

jmp last_paddle_movement

check_right_movement:
cmp al,0x4D
jne last_paddle_movement

cmp word [cs:paddle_A_flag],1
jne paddle_B_right_code

cmp word [cs:paddle_A_col], 60    
jae last_paddle_movement
inc word [cs:paddle_A_col]
call moving_paddle_A

jmp last_paddle_movement

paddle_B_right_code:
cmp word [cs:paddle_B_flag],1
jne last_paddle_movement

cmp word [cs:paddle_B_col],60    
jae last_paddle_movement
inc word [cs:paddle_B_col]
call moving_paddle_B

last_paddle_movement:

mov al,0x20
out 0x20,al

pop cx
pop di
pop ax
pop es

;cmp word [cs:A_score],5
;je jumptooldkeyboardisr

;cmp word [cs:B_score],5
;jne iretpaddlemovement

;jumptooldkeyboardisr:
;jmp far [cs:oldkeyboardisr]

;iretpaddlemovement:
iret

start_of_game:

call clear_screen
call initializing_paddle_and_ball

mov di,[cs:ball]
mov word [es:di],0x0720

cli
xor ax,ax 
mov es,ax
mov word ax,[es:0x08*4]
mov [cs:oldtimerisr],ax
mov word ax ,[es:0x08*4+2]
mov [cs:oldtimerisr+2],ax
xor ax,ax
mov es,ax
mov word [es:0x08*4],ball_movement
mov word [es:0x08*4+2],cs
sti

cli
xor ax,ax
mov es,ax
mov word ax,[es:0x09*4]
mov [cs:oldkeyboardisr],ax
mov word ax,[es:0x09*4+2]
mov [cs:oldkeyboardisr+2],ax
xor ax,ax
mov es,ax
mov word [es:0x09*4],paddles_movement
mov word [es:0x09*4+2],cs
sti

terminate_check_loop:

cmp word [cs:A_score],5
je end_game
cmp word [cs:B_score],5
je end_game

jmp terminate_check_loop

end_game:

cli                   
xor ax, ax
mov es, ax
mov ax, [cs:oldtimerisr]
mov [es:0x08*4], ax;
mov ax, [cs:oldtimerisr+2]
mov [es:0x08*4+2], ax
mov ax, [cs:oldkeyboardisr]
mov [es:0x09*4], ax
mov ax, [cs:oldkeyboardisr+2]
mov [es:0x09*4+2], ax
sti                  

call clear_screen

mov dx,start_of_game
add dx,15
shr dx,4

mov ax,0x3100
int 0x21