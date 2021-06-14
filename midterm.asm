#----------------------------------------------------------------------------------------------------
# Given some integer, find the maximal number you can obtain by deleting
# exactly one digit of the given number.
# Example
# For n = 152, the output should be 52
# For n = 1001, the output should be 101
#----------------------------------------------------------------------------------------------------

.data
Array:		.word -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
Message:	.asciiz "Nhap so nguyen: "
Message1:	.asciiz "Result: "
Message2:	.asciiz "Khong the loai bo them chu so nao nua\n"

.text
li		$v0, 51
la		$a0, Message
syscall

addi	$s0, $a0, 0
la		$s1, Array		 

addi	$t0, $0, 10
div		$s0, $t0
mflo	$t1
beqz	$t1, ONE_DIGIT_NUMBER	
bltz	$s0, NEGATIVE_INTEGER

addi	$a0, $s0, 0
addi	$a1, $s1, 0	
jal		PARSE_INTEGER

addi	$a1, $v1, 0
addi	$a2, $v0, 0
jal		FIND_MAX
j		EXIT

#--------------------------------------------------------------------------------------------------------------
# Trong trường hợp số nhập vào âm, ta lấy giá trị tuyệt đối của nó và tìm số nhỏ nhất
# nhận được khi bỏ 1 chữ số, thay vì dùng FIND_MAX, ta dùng FIND_MIN
#--------------------------------------------------------------------------------------------------------------
NEGATIVE_INTEGER:
	sub		$s0, $0, $s0
	addi	$a0, $s0, 0
	addi	$a1, $s1, 0	
	jal		PARSE_INTEGER

	addi	$a1, $v1, 0
	addi	$a2, $v0, 0
	jal		FIND_MIN
	sub		$v0, $0, $v0
	j		EXIT
	

EXIT:
	addi	$a1, $v0, 0
	li		$v0, 56
	la		$a0, Message1
	syscall

	li		$v0, 10
	syscall


ONE_DIGIT_NUMBER:
	li		$v0, 55
	la		$a0, Message2
	syscall

	li		$v0, 10
	syscall
	


#--------------------------------------------------------------------------------------------------------------
# Hàm PARSE_INTEGER
# Giá trị nhân vào: $a0 - Số nguyên đã cho
#                   $a1 - Địa chỉ mảng đã khởi tạo
# Trả về:           $v0 - Vị trí phần tử cuối cùng của mảng
#                   $v1 - Mảng chứa các chữ số của số nguyên 
# Ý nghĩa các thanh ghi:
# $t0: 10
# $t1: Iterator của $a1
# $t2: Chứa giá trị của phần tử mà $t1 trỏ tới
#--------------------------------------------------------------------------------------------------------------
PARSE_INTEGER:
	addi	$t0, $0, 10
	addi	$t1, $a1, 0 
	WHILE:
		beq		$a0, $0, END_WHILE
		div		$a0, $t0
		mflo	$a0 
		mfhi	$t2

		sw		$t2, 0($t1)
		addi	$t1, $t1, 4			
		j		WHILE
	END_WHILE:

	addi	$v0, $t1, -4
	addi	$v1, $a1, 0
	jr		$ra
	
	
#--------------------------------------------------------------------------------------------------------------
# Hàm FIND_MAX
# Tham số nhận vào: $a1 - Mảng chứa các phần tử là các chữ số của số nguyên đã cho
#					$a2 - Địa chỉ vị trí kết thúc mảng
# Trả về: 			$v0 - Giá trị lớn nhất nhận được khi xóa một chữ số
# Ý nghĩa các thanh ghi:
#	$v0: Giá trị lớn nhất tìm được và cũng là giá trị trả về	
#	$t0: Iterator của mảng
#	$t1: Phần tử sau $t0
#	$t2: Giá trị của $t0
#	$t3: Giá trị của $t1
#	$t4: Ban đầu bằng 1, sau mỗi vòng lặp tăng lên 10 lần
#	$t5: value = 10
#   $t9: Vị trí chữ số cần xóa
#--------------------------------------------------------------------------------------------------------------
# Chú ý: Mảng nhận vào đã bị đảo ngược thứ tự các chữ số
#--------------------------------------------------------------------------------------------------------------

FIND_MAX:
	addi	$v0, $0, 0			
	addi	$t0, $a2, 0         # $t0 = phần tử cuối mảng
	addi	$t1, $a2, -4		# $t1 = phần tử sau $t0
	addi	$t4, $0, 1
	addi	$t5, $0, 10
	addi	$t9, $a1, 0

    # Duyệt mảng theo chiều ngược để tìm vị trí của chữ số cần xóa
    # Vị trí i phù hợp là vị trí có A[i] < A[i+1]
    WHILE2:
        beq     $t0, $a1, END_WHILE2    
	    lw		$t2, 0($t0)
        lw      $t3, 0($t1)
        bge		$t2, $t3, NORMAL        # A[i] >= A[i+1] -> Continue
        addi    $t9, $t0, 0				# Else -> Found
        j		END_WHILE2				
        
        NORMAL:
        addi    $t0, $t0, -4
        addi    $t1, $t1, -4
        j		WHILE2
        
    END_WHILE2:

    # Duyệt mảng theo chiều xuôi để ghép các chữ số lại
		addi	$t0, $a1, 0
    addi    $a2, $a2, 4
    WHILE3:
        beq     $t0, $a2, END_WHILE3
        bne     $t0, $t9, NORMAL1
        addi    $t0, $t0, 4             # Bỏ qua vị trí vừa tìm được 
        j		WHILE3
        
        NORMAL1:
        lw      $t2, 0($t0)

		mult	$t2, $t4
		mflo	$t2
		add		$v0, $v0, $t2			# Num = Num + $t2 * $t4

		mult	$t4, $t5
		mflo	$t4						# $t4 = $t4 * 10
		
		addi	$t0, $t0, 4
		j		WHILE3			

    END_WHILE3:
	jr		$ra

#--------------------------------------------------------------------------------------------------------------
# Hàm FIND_MIN: Tương tự FIND_MAX nhưng ngược lại
#--------------------------------------------------------------------------------------------------------------
FIND_MIN:
	addi	$v0, $0, 0				
	addi	$t0, $a2, 0
	addi	$t1, $a2, -4
	addi	$t3, $0, 0
	addi	$t4, $0, 1
	addi	$t5, $0, 10
	addi	$t9, $a1, 0

    WHILE5:
        beq     $t0, $a1, END_WHILE5
	    lw		$t2, 0($t0)
        lw      $t3, 0($t1)
        ble		$t2, $t3, NORMAL2       # A[i] <= A[i+1] -> Continue
        addi    $t9, $t0, 0				# Else -> Found
        j		END_WHILE5		
        
        NORMAL2:
        addi    $t0, $t0, -4
        addi    $t1, $t1, -4
        j		WHILE5
        
    END_WHILE5:

	addi	$t0, $a1, 0
    addi    $a2, $a2, 4
    WHILE4:
        beq     $t0, $a2, END_WHILE4
        bne     $t0, $t9, NORMAL3
        addi    $t0, $t0, 4
        j		WHILE4				# jump to WHILE3
        
        NORMAL3:
        lw      $t2, 0($t0)

		mult	$t2, $t4
		mflo	$t2
		add		$v0, $v0, $t2			# Num = Num + $t2 * $t4

		mult	$t4, $t5
		mflo	$t4						# $t4 = $t4 * 10
		
		addi	$t0, $t0, 4
		j		WHILE4	

    END_WHILE4:
	jr		$ra
