#################################################################
#   Copyright: Wang Weixiao, Department of EE, THU              #
#   e-mail: 944955921@qq.com / wx-wang19@mails.tsinghua.edu.cn  #
#   All rights reserved.                                        #
#################################################################

# get address (%addr + %count << %pow + %bi); can be used to get addr of an element(with size pow(2, %pow)) in an array
.macro addr_buf(%targ, %addr, %count, %pow, %bi)
    mov     %targ, %count
    sll     %targ, %targ, %pow
    addu    %targ, %targ, %bi
    addu    %targ, %targ, %addr
.end_macro

# close a file
.macro close(%file)
    li      $v0, 16
    syscall
.end_macro

# exit
.macro exit()
    li      $v0, 17
    syscall
.end_macro

# loop "for"; iter from %from to %to
.macro for(%iter, %from, %to, %body)
    add     %iter, $zero, %from
LOOP:
    bge     %iter, %to, BREAK
	%body   ()
	add     %iter, %iter, 1
    j       LOOP
BREAK:
.end_macro

# "for" with custom label; can be used in nested loops
.macro for_l(%iter, %from, %to, %body, %lp, %brk)
    add     %iter, $zero, %from
%lp:
    bge     %iter, %to, %brk
	%body   ()
	add     %iter, %iter, 1
    j       %lp
%brk:
.end_macro

# an inverse-iter "for"
.macro for_inv(%iter, %from, %to, %body)
    add     %iter, $zero, %from
LOOP:
    ble     %iter, %to, BREAK_INV
	%body   ()
	sub     %iter, %iter, 1
    j       LOOP_INV
BREAK:
.end_macro

# move a reg/im to %targ
.macro mov(%targ, %src)
    addu    %targ, $zero, %src
.end_macro

# get space at %gp. Bytes: %count * pow(2, %pow)
.macro  new(%targ, %count, %pow)
    mov     %targ, %count
    sll     %targ, %targ, %pow
    addu    $gp, $gp, %targ
    subu    %targ, $gp, %targ
.end_macro

# open file %name to %targ
.macro open(%targ, %name, %flag)
    li      $v0, 13
    la      $a0, %name
    li      $a1, %flag
    syscall
    mov     %targ, $v0
.end_macro

# print the num in $a0
.macro print_a0()               # printf the int in $a0 immediately
    li      $v0, 1
    syscall
.end_macro

# print the int in %src
.macro print_int(%src)          # printf the int from %src, can be an immediate num
    li      $v0, 1
    mov     $a0, %src
    syscall
.end_macro

# print the str in %name, .data
.macro print_str(%name)
    li      $v0, 4
    la      $a0, %name
    syscall
.end_macro

# read from %file, reg to %buffer
.macro read(%file, %buf, %size_i)
    li      $v0, 14
    mov     $a0, %file
    la      $a1, (%buf)
    li      $a2, %size_i
    syscall
.end_macro

# read from buffer %addr[count]; %pow must be 2 because of "lw"
.macro read_buf(%targ, %addr, %count, %pow) # read data from a buffer to %targ
    mov     %targ, %count                # force: move count to reg
    sll     %targ, %targ, %pow
    addu    %targ, %targ, %addr
    lw      %targ, (%targ)
.end_macro

# read from buffer with a bias
.macro read_buf_b(%targ, %addr, %count, %pow, %bi)
    mov     %targ, %count                # force: move count to reg
    sll     %targ, %targ, %pow
    addu    %targ, %targ, %addr
	addu	%targ, %targ, %bi
    lw      %targ, (%targ)
.end_macro

.macro scan_int(%targ)          # scanf an int to %targ
    li      $v0, 5
    syscall
    mov     %targ, $v0
.end_macro

.macro scan_v0()                # scanf to $v0 only
    li      $v0, 5
    syscall
.end_macro

.macro write(%file, %buffer, %size_i)
    li      $v0, 15
    mov     $a0, %file
    mov     $a1, %buffer
    li      $a2, %size_i
    syscall
.end_macro

.macro write_buf(%src, %addr, %count, %pow) # write data to a buffer from %src
    mov     sub_temp, %count                # force: move count to reg
    sll     sub_temp, sub_temp, %pow
    addu    sub_temp, sub_temp, %addr
    sw      %src, (sub_temp)
.end_macro

##############################################

.macro push_stk(%src)
	sw      %src, ($sp)
	subu    $sp, $sp, 4
.end_macro

.macro pop_stk(%targ)
	addu    $sp, $sp, 4
	lw      %targ, ($sp)
.end_macro

.macro push_t_hf1()		# push the first half of $t into stack
	push_stk    $t0
	push_stk    $t1
	push_stk    $t2
	push_stk    $t3
	push_stk    $t4
.end_macro

.macro push_t_hf2()		# push the second half of $t into stack
	push_stk    $t5
	push_stk    $t6
	push_stk    $t7
	push_stk    $t8
	push_stk    $t9
.end_macro

.macro push_t()			# push $t into stack
	push_t_hf1
	push_t_hf2
.end_macro

.macro push_s_hf1()		# push the first half of $s into stack
	push_stk    $s0
	push_stk    $s1
	push_stk    $s2
	push_stk    $s3
.end_macro

.macro push_s_hf2()		# push the second half of $s into stack
	push_stk    $s4
	push_stk    $s5
	push_stk    $s6
	push_stk    $s7
.end_macro

.macro  push_s()		# push $s into stack
	push_s_hf1
	push_s_hf2
.end_macro

.macro push_ra()		# push $ra into stack  
	push_stk    $ra
.end_macro

.macro pop_t_hf1()		# pop stack to the first of of $t
	pop_stk     $t4
	pop_stk     $t3
	pop_stk     $t2
	pop_stk     $t1
	pop_stk     $t0
.end_macro

.macro pop_t_hf2()		# pop stack to the second of of $t
	pop_stk     $t9
	pop_stk     $t8
	pop_stk     $t7
	pop_stk     $t6
	pop_stk     $t5
.end_macro

.macro pop_t()
	pop_t_hf2
	pop_t_hf1
.end_macro
	
.macro pop_s_hf1()
	pop_stk		$s3
	pop_stk		$s2
	pop_stk		$s1
	pop_stk		$s0
.end_macro

.macro pop_s_hf2()
	pop_stk		$s7
	pop_stk		$s6
	pop_stk		$s5
	pop_stk		$s4
.end_macro

.macro pop_s()
	pop_s_hf2
	pop_s_hf1
.end_macro

.macro pop_ra()
	pop_stk		$ra
.end_macro

.macro push_ts_hf()
	push_t_hf1
	push_s_hf1
	push_ra
.end_macro

.macro pop_ts_hf()
	pop_ra
	pop_s_hf1
	pop_t_hf1
.end_macro

.macro return(%src, %pop)
	mov		$v0, %src
	%pop
	jr		$ra
.end_macro

# return directly
.macro return_v0(%pop)
	%pop
	jr		$ra
.end_macro
