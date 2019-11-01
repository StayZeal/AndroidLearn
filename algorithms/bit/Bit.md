& 与运算：相同位的两个数字都为1，则为1；若有一个不为1，则为0
| 或运算：相同位只要一个为1即为1
^ 异或运算：如果某位不同则该位为1, 否则该位为0
~ 取反：

<<左移：变大
/>>右移：变小

含义	Pascal语言	C语言	Java
按位与	a and b	a & b	a & b
按位或	a or b	a | b	a | b
按位异或	a xor b	a ^ b	a ^ b
按位取反	not a	~a	~a
左移	a shl b	a << b	a << b
带符号右移	a shr b	a >> b	a >> b
无符号右移	/	/	a>>> b
