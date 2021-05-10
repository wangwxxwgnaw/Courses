#################################################################
#   Copyright: Wang Weixiao, Department of EE, THU              #
#   e-mail: 944955921@qq.com / wx-wang19@mails.tsinghua.edu.cn  #
#   All rights reserved.                                        #
#################################################################

# get address (%addr + %count << %pow + %bi); 
# can be used to get addr of an element(with size 0x1 << %pow) in an array
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
    ble     %iter, %to, BREAK
	%body   ()
	sub     %iter, %iter, 1
    j       LOOP
BREAK:
.end_macro

# an inverse-iter "for" with custom label; can be used in nested loops
.macro for_inv_l(%iter, %from, %to, %body, %lp, %brk)
    add     %iter, $zero, %from
%lp:
    ble     %iter, %to, BREAK
	%body   ()
	sub     %iter, %iter, 1
    j       LOOP
%brk:
.end_macro

# move %src(reg/immed) to %targ; very universal
.macro mov(%targ, %src)
    addu    %targ, $zero, %src
.end_macro

# allocate space at %gp;
% number of allocated bytes: %count * (0x1 << %pow)
.macro  new(%targ, %count, %pow)
    mov     %targ, %count
    sll     %targ, %targ, %pow
    addu    $gp, $gp, %targ
    subu    %targ, $gp, %targ
.end_macro

# open file %name and store the file identifier in %targ;
# %name: .data, %targ: reg
.macro open(%targ, %name, %flag)
    li      $v0, 13
    la      $a0, %name
    li      $a1, %flag
    syscall
    mov     %targ, $v0
.end_macro

# print the int in $a0; sometimes can be used to simplify steps
.macro print_a0()
    li      $v0, 1
    syscall
.end_macro

# print the int in %src;
# %src: reg/immed
.macro print_int(%src)
    li      $v0, 1
    mov     $a0, %src
    syscall
.end_macro

# print the str in %name; %name: .data
.macro print_str(%name)
    li      $v0, 4
    la      $a0, %name
    syscall
.end_macro

# read from file identifier %file and store data to %buffer; 
# %file: reg, %buffer: reg
.macro read(%file, %buf, %size_i)
    li      $v0, 14
    mov     $a0, %file
    la      $a1, (%buf)
    li      $a2, %size_i
    syscall
.end_macro

# read one word from buffer;
# address to be read: %addr + %count << %pow; 
.macro read_buf(%targ, %addr, %count, %pow) 
    mov     %targ, %count                
    sll     %targ, %targ, %pow
    addu    %targ, %targ, %addr
    lw      %targ, (%targ)
.end_macro

# read one word from buffer with a bias;
# address to be read: %addr + %count << %pow + %bi; 
.macro read_buf_b(%targ, %addr, %count, %pow, %bi)
    mov     %targ, %count
    sll     %targ, %targ, %pow
    addu    %targ, %targ, %addr
    addu	%targ, %targ, %bi
    lw      %targ, (%targ)
.end_macro

# scanf an int to %targ
.macro scan_int(%targ)
    li      $v0, 5
    syscall
    mov     %targ, $v0
.end_macro

# scanf an int to $v0 only
.macro scan_v0()
    li      $v0, 5
    syscall
.end_macro

# write to file %file from %buffer with size %size_i;
# %file: reg, file identifier, %size_i: reg/immed
.macro write(%file, %buffer, %size_i)
    li      $v0, 15
    mov     $a0, %file
    mov     $a1, %buffer
    mov     $a2, %size_i
    syscall
.end_macro

# write one word to buffer; need a reg(%t) to temporarily store data
# address to be written: %addr + %count << %pow
.macro write_buf(%src, %t, %addr, %count, %pow) 
    mov     %t, %count                
    sll     %t, %t, %pow
    addu    %t, %t, %addr
    sw      %src, (%t)
.end_macro

# write one word to buffer with a bias; need a reg(%t) to temporarily store data
# address to be written: %addr + %count << %pow + %bi
.macro write_buf(%src, %t, %addr, %count, %pow, %bi) 
    mov     %t, %count                
    sll     %t, %t, %pow
    addu    %t, %t, %addr
    addu    %t, %t, %bi
    sw      %src, (%t)
.end_macro

##############################################
#             function related               #
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
