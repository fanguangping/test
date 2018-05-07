################################################################################
# fscheme (C) Copyright funnyos@qq.com 2018
#
# This software is freely distributable under the terms of the MIT 
# License. See the file LICENSE for details.
################################################################################
.data
heap:          .space  0x10000
memory.hp:     .space  4  #heap pointer
code:          .asciiz   "   (define  abc  (\"ASymbol\"@00 \"A String\"@01 . \"123\"@03)  )"
errmsg:        .asciiz   "An error occured!\n"

nil:           .word 0x00, 0x00, 0x00
true:          .word 0x01, 0x01, 0x00
false:         .word 0x01, 0x00, 0x00

ASymbol:       .asciiz   "\"ASymbol\"@00"
AString:       .asciiz   "\"A String\"@01"
BTrue:         .asciiz   "\"t\"@02"
BFalse:        .asciiz   "\"f\"@02"
IPositive:     .asciiz   "\"123\"@03"
IZero:         .asciiz   "\"0\"@03"
INegtive:      .asciiz   "\"-123\"@03"
FPositive:     .asciiz   "\"2/3\"@04"
FNegtive:      .asciiz   "\"-2/3\"@04"
DPositive:     .asciiz   "\".123\"@05"
DZero:         .asciiz   "\"0.0\"@05"
DNegtive:      .asciiz   "\"-.123\"@05"
AChar:         .asciiz   "\"c\"@06"
AProcedure:    .asciiz   "\"#+\"@07"

################################################################################
.text

.globl main

################################################################################
# main()
# entry point
################################################################################
main:
    la   $t0, heap
    la   $t1, memory.hp
    sw   $t0, 0($t1)

    la   $a0, ASymbol
    jal  read_atom
    #print

################################################################################
# read_atom()
# 
################################################################################
read_atom:
    # push
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $t1, 12($sp)
    sw   $t0, 8($sp)
    sw   $s1, 4($sp)
    sw   $s0, 0($sp)
    
    addi $a0, $a0, 1
    jal  read_string
    move $s0, $v0
    lbu  $t0, 0($a0)
    li   $t1, '@'
    beq  $t0, $t1, read_atom.read_anum
    la   $a0, errmsg
    jal  error
read_atom.read_anum:
    addi $a0, $a0, 1
    jal  read_enum
    move $s1, $v0
read_atom.lex_symbol:
    bne  $s0, $zero, read_atom.lex_string
    move $a0, $s1
    jal  lex_symbol
    j    read_atom.exit
read_atom.lex_string:
    li   $t1, 01
    bne  $s0, $t1, read_atom.lex_boolean
    move $a0, $s1
    jal  lex_string
    j    read_atom.exit
read_atom.lex_boolean:
    li   $t1, 02
    bne  $s0, $t1, read_atom.lex_integer
    move $a0, $s1
    jal  lex_boolean
    j    read_atom.exit
read_atom.lex_integer:
    li   $t1, 03
    bne  $s0, $t1, read_atom.lex_fraction
    move $a0, $s1
    jal  lex_integer
    j    read_atom.exit
read_atom.lex_fraction:
    li   $t1, 04
    bne  $s0, $t1, read_atom.lex_decimal
    move $a0, $s1
    jal  lex_fraction
    j    read_atom.exit
read_atom.lex_decimal:
    li   $t1, 05
    bne  $s0, $t1, read_atom.lex_character
    move $a0, $s1
    jal  lex_decimal
    j    read_atom.exit
read_atom.lex_character:
    li   $t1, 06
    bne  $s0, $t1, read_atom.lex_procedure
    move $a0, $s1
    jal  lex_character
    j    read_atom.exit
read_atom.lex_procedure:
    li   $t1, 07
    bne  $s0, $t1, read_atom.exit
    move $a0, $s1
    jal  lex_procedure
read_atom.exit:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $t0, 8($sp)
    lw   $t1, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra

#
# TODO
# 
#
################################################################################
# read_string()
# 
################################################################################
read_string:
    # push
	la   $t2, memory.hp
    
read_string.loop:
    lbu  $t0, 0($a0)
	li   $t1, '"'
	beq  $t0, $t1, read_string.exit
	li   $t1, "\\"
	bne  $t0, $t1, read_string.eos
	addi $a0, $a0, 1
	lbu  $t0, 0($a0)
	li   $t1, "n"
	bne  $t0, $t1, read_string.tab
	li   $s0, '\n'
read_string.tab
	li   $t1, "t"
	bne  $t0, $t1, read_string.backslash
	li   $s0, '\t'
read_string.backslash
    li   $t1, "\\"
	bne  $t0, $t1, read_string.quote
	li   $s0, '\\'
read_string.quote
    li   $t1, "\""
	bne  $t0, $t1, read_string.quote
	li   $s0, '"'
	j    read_string.store
read_string.eos
	la   $a0, errmsg
    jal  error
read_string.store
    lw   $t0, 0($t2)
	bgt  ($t0 - memory.hp), MAX, read_string.overflow
	sw   $s0, 0($t0)
    addi $t0, $t0, 1
	j    read_string.loop
read_string.overflow
    la   $a0, errmsg
    jal  error
	j    read_string.loop
    addi $a0, $a0, 1
read_string.exit:

    # pop
    jr   $ra

################################################################################
# read_enum()
# 
################################################################################
read_enum:
    # push
    
	move $t0, $a0
	move $t1, $zero
read_enum.L1:
    lbu  $t2, 0($t0)
	move $a0, $t2
	jal  hex_value
	move $t2, $v0
	beq  $t2, -1, read_enum.exit
    sll  $t1, 4
	add  $t1, $t1, $t2
read_enum.L2:
	lbu  $t2, 0($t0)
	move $a0, $t2
	jal  hex_value
	move $t2, $v0
	beq  $t2, -1, read_enum.exit
    sll  $t1, 4
	add  $t1, $t1, $t2
read_enum.exit:
    move $v0, $t1
	
    # pop
    jr   $ra

################################################################################
# hex_value()
# 
################################################################################
hex_value:
    # push
    
	move $t0, $zero
	
	
    # pop
    jr   $ra

################################################################################
# lex_symbol()
# 
################################################################################
lex_symbol:
    # push
    
    # pop
    jr   $ra

################################################################################
# lex_string()
# 
################################################################################
lex_string:
    # push
    
    # pop
    jr   $ra

################################################################################
# lex_boolean()
# 
################################################################################
lex_boolean:
    # push
    
    # pop
    jr   $ra

################################################################################
# lex_integer()
# 
################################################################################
lex_integer:
    # push
    
    # pop
    jr   $ra

################################################################################
# lex_fraction()
# 
################################################################################
lex_fraction:
    # push
    
    # pop
    jr   $ra

################################################################################
# lex_decimal()
# 
################################################################################
lex_decimal:
    # push
    
    # pop
    jr   $ra

################################################################################
# lex_character()
# 
################################################################################
lex_character:
    # push
    
    # pop
    jr   $ra

################################################################################
# lex_procedure()
# 
################################################################################
lex_procedure:
    # push
    
    # pop
    jr   $ra



