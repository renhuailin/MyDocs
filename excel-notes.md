

## 1. Formula 公式

如何阻止自动填充功能自增公式里的数字。[请参考这里](https://www.extendoffice.com/documents/excel/3215-excel-prevent-cell-reference-from-incrementing-changing.html#a1)

To calculate each number’s percentage of their total, you need to keep the totals (SUM(A2:A15)) static in your formula =A2/SUM(A2:A15). You can do as follows:

In the Cell B2, change your formula with adding **absolute reference** signs “$” to your formula as =A2/SUM($A$2: $A$15), and then drag the Fill Handle down to other cells.

Note: You can click on the reference cell in the Formula Bar, and then press the F4 key to add $ signs to this reference cell in the formula.

Now the absolute reference SUM($A$2: $A$15) is not incrementing when filling down. 

## 2. Functions 函数

###  2.1 vlookup
vlookup的查找范围，要查找的列，必须在这个range的第一列。

### 2.2 SUMPRODUCT
这里的product是乘积的意思。
