.data	
	String1:	.asciiz	"                                              *************   \n"
	String2:	.asciiz	" ****************                            *3333333333333*  \n"
	String3:	.asciiz	" *2222222222222222*                          *33333********   \n"
	String4:	.asciiz	" *22222*******222222*                        *33333*          \n"
	String5:	.asciiz	" *22222*      *222222*                       *33333********   \n"
	String6:	.asciiz	" *22222*       *222222*      *************   *3333333333333*  \n"
	String7:	.asciiz	" *22222*       *222222*    **11111*****111*  *33333********   \n"
	String8:	.asciiz	" *22222*       *222222*   *1111**      ***   *33333*          \n"
	String9:	.asciiz	" *22222*      *222222*   *1111*              *33333********   \n"
	String10:	.asciiz	" *22222*******222222*   *11111*              *3333333333333*  \n"
	String11:	.asciiz	" *2222222222222222*     *11111*               *************   \n"
	String12:	.asciiz	" ****************       *11111*                               \n"
	String13:	.asciiz	"      ---                *1111*                               \n"
	String14:	.asciiz	"    / o o \\              *1111****   *****                    \n"
	String15:	.asciiz	"    \\   > /               **111111***111*                     \n"
	String16:	.asciiz	"     -----                   ***********     dce.hust.edu.vn  \n"

	Message0:	.asciiz	"\n\n------------Ve hinh bang ki tu ASCII------------\n"
	Option1:	.asciiz	"1. Hien thi hinh anh\n"
	Option2:	.asciiz	"2. Hien thi hinh anh ko co mau\n"
	Option3:	.asciiz	"3. Doi vi tri cua D va E\n"
	Option4:	.asciiz	"4. Doi mau\n"
	Exit_Menu:	.asciiz	"5. Thoat\n"
	Select:		.asciiz	"Select option: "
	StringD:	.asciiz	"4.1. Mau moi cua D (0->9): "
	StringC:	.asciiz	"4.2. Mau moi cua C (0->9): "
	StringE:	.asciiz	"4.3. Mau moi cua E (0->9): "

.text

# Màu cũ của các chữ 
li	$t7, 50	# original color of D
li	$t8, 49	# original color of C
li	$t9, 51	# original color of E

MENU:
	la	$a0, Message0
	li	$v0, 4
	syscall
	la	$a0, Option1
	li	$v0, 4
	syscall
	la	$a0, Option2
	li	$v0, 4
	syscall
	la	$a0, Option3
	li	$v0, 4
	syscall
	la	$a0, Option4
	li	$v0, 4
	syscall
	la	$a0, Exit_Menu
	li	$v0, 4
	syscall
	la	$a0, Select
	li	$v0, 4
	syscall
	li	$v0, 5	# Read user's selsection 
	syscall


# Cases handler
CASE1:
	addi	$v1, $0, 1
	bne	$v0, $v1, CASE2
	j	MENU1
CASE2:
	addi	$v1, $0, 2
	bne	$v0, $v1, CASE3
	j	MENU2
CASE3:
	addi	$v1, $0, 3
	bne	$v0, $v1, CASE4
	j	MENU3
CASE4:
	addi	$v1, $0, 4
	bne	$v0, $v1, CASE5
	j	MENU4
CASE5:
	addi	$v1, $0, 5
	bne	$v0, $v1, DEFAULT
	j	EXIT
DEFAULT:
	j	MENU


#--------------------------------------------------------
# Option 1: Hiển thị hình ảnh 
# Ý tưởng: Hình ảnh gồm có 16 dòng, mỗi dòng 64 kí tự.
# 	   Duyệt lần lượt và in từng dòng ra màn hình 
# Ý nghĩa các thanh ghi:
# $s0: Biến đếm số hàng hiện tại.
# $s1: Tổng số hàng (16).
# $s2: Chứa chuỗi tương ứng của hàng hiện tại.
#--------------------------------------------------------
MENU1:	
	addi	$s0, $0, 0	# init $s0 = 0
	addi	$s1, $0, 16
	la	$s2, String1	# load string
LOOP_MENU1:	
	beq	$s1, $s0, MENU	# if ($s0 == 16) then (jump MENU)
	addi	$a0, $s2, 0	# else (print String)
	li	$v0, 4	    
	syscall

	addi	$s2, $s2, 64  	# line = next_line
	addi	$s0, $s0, 1   	# count++
	j	LOOP_MENU1
	


#--------------------------------------------------------
# Option 2: Hiển thị hình ảnh không có màu
# Ý tưởng: Duyệt theo từng dòng, nếu kí tự là chữ số thì
# 	   chỉ in ra dấu cách, nếu không thì giữ nguyên.
# Ý nghĩa các thanh ghi:
# $s0: Biến đếm số hàng hiện tại.
# $s1: Tổng số hàng (16).
# $s2: Địa chỉ kí tự hiện tại.
# $t0: Đếm vị trí kí tự hiện tại trong dòng.
# $t1: Số kí tự mỗi dòng (64).
# $t2: Kí tự hiện tại.
#--------------------------------------------------------
MENU2:
	addi	$s0, $0, 0	# init $s0 = 0
	addi	$s1, $0, 16
	la	$s2, String1	# load string
			
LOOP_MENU2:
	beq	$s1, $s0, MENU
	addi	$t0, $0, 0
	addi	$t1, $0, 64
	
MENU2_PRINT_ONE_ROW:
	beq	$t1, $t0, MENU2_ENDLINE
	lb	$t2, 0($s2)			# load kí tự 
	bge	$t2, '0', MENU2_COMPARE_WITH_9
	j	MENU2_PRINT_CHAR   		# Kí tự < '0' thì in ra

MENU2_COMPARE_WITH_9: 	
	bgt	$t2, '9', MENU2_PRINT_CHAR
	addi	$t2, $0, 0x20			# '0' <= char <= '9' -> In ra space (0x20)
	j	MENU2_PRINT_CHAR

MENU2_PRINT_CHAR:	
	li	$v0, 11
	addi	$a0, $t2, 0
	syscall

	addi	$s2, $s2, 1	# Kí tự tiếp theo.
	addi	$t0, $t0, 1
	j	MENU2_PRINT_ONE_ROW

MENU2_ENDLINE:
	addi	$s0, $s0, 1	# Dòng tiếp theo	
	j	LOOP_MENU2



#--------------------------------------------------------
# Option 3: Đổi vị trí D và E
# Ý tưởng: Chia hình ảnh ra thành 4 phần:
# 	   Phần 1: Cột 0 đến 23  -> chữ D
# 	   Phần 2: Cột 24 đến 44 -> chữ C
# 	   Phần 3: Cột 45 đến 61 -> chữ E
# 	   Phần 4: Còn lại (space và \n)
#	Sau đó in hàng theo thứ tự 3-2-1-4
# Ý nghĩa các thanh ghi:
# $s0: Biến đếm số hàng hiện tại.
# $s1: Tổng số hàng (16).
# $s2: Địa chỉ hàng hiện tại.
# $t0: Kí tự space (0x20)
#--------------------------------------------------------
MENU3:	
	addi	$s0, $0, 0	# init $s0 = 0
	addi	$s1, $0, 16
	la	$s2, String1	# load string
	addi	$t0, $0, 0x20
MENU3_LOOP:	
	beq	$s1, $s0, MENU
	# Chia 4 phần 
	sb	$0 23($s2)	# string[23] = null (hết D)
	sb	$0 44($s2)	# string[44] = null (hết C)
	sb	$0 61($s2)	# string[61] = null (hết E)
	# In E
	li	$v0, 11
	addi	$a0, $t0, 0
	syscall			# In ra kí tự space đã bị thay bằng null
	li	$v0, 4             
	la	$a0, 45($s2)
	syscall
	
	# In C
	li	$v0, 11
	addi	$a0, $t0, 0
	syscall			# In ra kí tự space đã bị thay bằng null
	li	$v0, 4 
	la	$a0, 24($s2)
	syscall
	
	# In D
	li	$v0, 11
	addi	$a0, $t0, 0
	syscall			# In ra kí tự space đã bị thay bằng null
	li	$v0, 4 
	la	$a0, 0($s2)
	syscall
	
	# In phần còn lại của dòng 
	li	$v0, 4
	la	$a0, 62($s2)
	syscall

	# Trả lại những giá trị space vừa bị thay bằng null
	sb	$t0, 23($s2)
	sb	$t0, 44($s2)
	sb	$t0, 61($s2)
	
	addi	$s0, $s0, 1
	addi	$s2, $s2, 64	# line = next_line
	j	MENU3_LOOP


#-------------------------------------------------------------------------------------------
# Option 4: Đổi màu chữ
# Ý tưởng: Nhận mã màu mới của từng chữ từ người dùng, duyệt kết hợp với kiểm tra 
#	   theo từng vùng tương tự với option 3. Tiến hành thay mã màu mới vào các
#	   vùng tương ứng (D, C, E).
# Ý nghĩa các thanh ghi:
# $s0: Biến đếm số hàng hiện tại.
# $s1: Tổng số hàng (16).
# $s2: Địa chỉ hàng hiện tại.
# $t7: Màu cũ của D
# $t8: Màu cũ của C
# $t9: Màu cũ của E
#-------------------------------------------------------------------------------------------
MENU4: 
INPUT_D_COLOR:	
	li 	$v0, 4		
	la 	$a0, StringD
	syscall
	li 	$v0, 5
	syscall

	blt	$v0, 0, INPUT_D_COLOR	# if (new_color < 0) then (re_type)
	bgt	$v0, 9, INPUT_D_COLOR	# if (new_color > 9) then (re_type)
	addi	$s3, $v0, 48		# Lưu màu mới vào $s3
		
INPUT_C_COLOR:
	li 	$v0, 4		
	la 	$a0, StringC
	syscall	
	li 	$v0, 5
	syscall

	blt	$v0, 0, INPUT_C_COLOR
	bgt	$v0, 9, INPUT_C_COLOR
	addi	$s4, $v0, 48		# Lưu màu mới vào $s4
		
INPUT_E_COLOR:
	li 	$v0, 4		
	la 	$a0, StringE
	syscall
	li 	$v0, 5
	syscall

	blt	$v0, 0, INPUT_C_COLOR
	bgt	$v0, 9, INPUT_C_COLOR
	addi	$s5, $v0, 48		# Lưu màu mới vào $s5

	
# Khởi tạo giá trị cho vòng lặp
addi	$s0, $0, 0
addi	$s1, $0, 16
la	$s2, String1

LOOP_CHANGE_COLOR:	
	beq	$s1, $s0, UPDATE_COLOR_CODE
	addi	$t0, $0, 0
	addi	$t1, $0, 64
	
LOOP_CHANGE_COLOR_ROW:
	beq	$t1, $t0, END_CHANGE_COLOR_ROW
	lb	$t2, 0($s2)			# Load kí tự hiện tại
	
# D - vị trí từ 0 đến 23
CHECK_D:
	bgt	$t0, 23, CHECK_C		# vị trí > 23 -> CHECK_C
	beq	$t2, $t7, FIX_D			# Kí tự là màu của D -> FIX 
	j	NEXT_CHAR

# C - vị trí từ 24 đến 44
CHECK_C:
	bgt	$t0, 44, CHECK_E
	beq	$t2, $t8, FIX_C
	j	NEXT_CHAR
	
# E - vị trí từ 45 đến 63
CHECK_E:
	beq	$t2, $t9, FIX_E
	j	NEXT_CHAR
FIX_D:
	sb	$s3, 0($s2)		# Gán màu mới cho kí tự hiện tại
	j	NEXT_CHAR
FIX_C:
	sb	$s4, 0($s2)
	j	NEXT_CHAR
FIX_E:
	sb	$s5, 0($s2)
	j	NEXT_CHAR
	
NEXT_CHAR:
	addi	$s2, $s2, 1	# Kí tự hiện tại.
	addi	$t0, $t0, 1	# Tăng counter 
	j LOOP_CHANGE_COLOR_ROW
		
END_CHANGE_COLOR_ROW:	
	addi	$s0, $s0, 1	# Tăng counter dòng 
	j LOOP_CHANGE_COLOR

UPDATE_COLOR_CODE:
	move	$t7, $s3
	move	$t8, $s4
	move	$t9, $s5 
	j	MENU1

EXIT: