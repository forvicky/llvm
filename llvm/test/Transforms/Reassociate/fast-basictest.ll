; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -reassociate -gvn -instcombine -S | FileCheck %s

; With reassociation, constant folding can eliminate the 12 and -12 constants.
define float @test1(float %arg) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[ARG_NEG:%.*]] = fsub fast float -0.000000e+00, [[ARG:%.*]]
; CHECK-NEXT:    ret float [[ARG_NEG]]
;
  %t1 = fsub fast float -1.200000e+01, %arg
  %t2 = fadd fast float %t1, 1.200000e+01
  ret float %t2
}

; Check again using the minimal subset of FMF.
; Both 'reassoc' and 'nsz' are required.
define float @test1_minimal(float %arg) {
; CHECK-LABEL: @test1_minimal(
; CHECK-NEXT:    [[TMP1:%.*]] = fsub reassoc nsz float -0.000000e+00, [[ARG:%.*]]
; CHECK-NEXT:    ret float [[TMP1]]
;
  %t1 = fsub reassoc nsz float -1.200000e+01, %arg
  %t2 = fadd reassoc nsz float %t1, 1.200000e+01
  ret float %t2
}

; Verify the fold is not done with only 'reassoc' ('nsz' is required).
define float @test1_reassoc(float %arg) {
; CHECK-LABEL: @test1_reassoc(
; CHECK-NEXT:    [[T1:%.*]] = fsub reassoc float -1.200000e+01, [[ARG:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = fadd reassoc float [[T1]], 1.200000e+01
; CHECK-NEXT:    ret float [[T2]]
;
  %t1 = fsub reassoc float -1.200000e+01, %arg
  %t2 = fadd reassoc float %t1, 1.200000e+01
  ret float %t2
}

define float @test2(float %reg109, float %reg1111) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[REG115:%.*]] = fadd float [[REG109:%.*]], -3.000000e+01
; CHECK-NEXT:    [[REG116:%.*]] = fadd float [[REG115]], [[REG1111:%.*]]
; CHECK-NEXT:    [[REG117:%.*]] = fadd float [[REG116]], 3.000000e+01
; CHECK-NEXT:    ret float [[REG117]]
;
  %reg115 = fadd float %reg109, -3.000000e+01
  %reg116 = fadd float %reg115, %reg1111
  %reg117 = fadd float %reg116, 3.000000e+01
  ret float %reg117
}

define float @test3(float %reg109, float %reg1111) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[REG117:%.*]] = fadd fast float [[REG109:%.*]], [[REG1111:%.*]]
; CHECK-NEXT:    ret float [[REG117]]
;
  %reg115 = fadd fast float %reg109, -3.000000e+01
  %reg116 = fadd fast float %reg115, %reg1111
  %reg117 = fadd fast float %reg116, 3.000000e+01
  ret float %reg117
}

define float @test3_reassoc(float %reg109, float %reg1111) {
; CHECK-LABEL: @test3_reassoc(
; CHECK-NEXT:    [[REG115:%.*]] = fadd reassoc float [[REG109:%.*]], -3.000000e+01
; CHECK-NEXT:    [[REG116:%.*]] = fadd reassoc float [[REG115]], [[REG1111:%.*]]
; CHECK-NEXT:    [[REG117:%.*]] = fadd reassoc float [[REG116]], 3.000000e+01
; CHECK-NEXT:    ret float [[REG117]]
;
  %reg115 = fadd reassoc float %reg109, -3.000000e+01
  %reg116 = fadd reassoc float %reg115, %reg1111
  %reg117 = fadd reassoc float %reg116, 3.000000e+01
  ret float %reg117
}

@fe = external global float
@fa = external global float
@fb = external global float
@fc = external global float
@ff = external global float

define void @test4() {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[A:%.*]] = load float, float* @fa, align 4
; CHECK-NEXT:    [[B:%.*]] = load float, float* @fb, align 4
; CHECK-NEXT:    [[C:%.*]] = load float, float* @fc, align 4
; CHECK-NEXT:    [[T1:%.*]] = fadd fast float [[B]], [[A]]
; CHECK-NEXT:    [[T2:%.*]] = fadd fast float [[T1]], [[C]]
; CHECK-NEXT:    store float [[T2]], float* @fe, align 4
; CHECK-NEXT:    store float [[T2]], float* @ff, align 4
; CHECK-NEXT:    ret void
;
  %A = load float, float* @fa
  %B = load float, float* @fb
  %C = load float, float* @fc
  %t1 = fadd fast float %A, %B
  %t2 = fadd fast float %t1, %C
  %t3 = fadd fast float %C, %A
  %t4 = fadd fast float %t3, %B
  ; e = (a+b)+c;
  store float %t2, float* @fe
  ; f = (a+c)+b
  store float %t4, float* @ff
  ret void
}

define void @test5() {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[A:%.*]] = load float, float* @fa, align 4
; CHECK-NEXT:    [[B:%.*]] = load float, float* @fb, align 4
; CHECK-NEXT:    [[C:%.*]] = load float, float* @fc, align 4
; CHECK-NEXT:    [[T1:%.*]] = fadd fast float [[B]], [[A]]
; CHECK-NEXT:    [[T2:%.*]] = fadd fast float [[T1]], [[C]]
; CHECK-NEXT:    store float [[T2]], float* @fe, align 4
; CHECK-NEXT:    store float [[T2]], float* @ff, align 4
; CHECK-NEXT:    ret void
;
  %A = load float, float* @fa
  %B = load float, float* @fb
  %C = load float, float* @fc
  %t1 = fadd fast float %A, %B
  %t2 = fadd fast float %t1, %C
  %t3 = fadd fast float %C, %A
  %t4 = fadd fast float %t3, %B
  ; e = c+(a+b)
  store float %t2, float* @fe
  ; f = (c+a)+b
  store float %t4, float* @ff
  ret void
}

define void @test6() {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[A:%.*]] = load float, float* @fa, align 4
; CHECK-NEXT:    [[B:%.*]] = load float, float* @fb, align 4
; CHECK-NEXT:    [[C:%.*]] = load float, float* @fc, align 4
; CHECK-NEXT:    [[T1:%.*]] = fadd fast float [[B]], [[A]]
; CHECK-NEXT:    [[T2:%.*]] = fadd fast float [[T1]], [[C]]
; CHECK-NEXT:    store float [[T2]], float* @fe, align 4
; CHECK-NEXT:    store float [[T2]], float* @ff, align 4
; CHECK-NEXT:    ret void
;
  %A = load float, float* @fa
  %B = load float, float* @fb
  %C = load float, float* @fc
  %t1 = fadd fast float %B, %A
  %t2 = fadd fast float %t1, %C
  %t3 = fadd fast float %C, %A
  %t4 = fadd fast float %t3, %B
  ; e = c+(b+a)
  store float %t2, float* @fe
  ; f = (c+a)+b
  store float %t4, float* @ff
  ret void
}

define float @test7(float %A, float %B, float %C) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[REASS_ADD1:%.*]] = fadd fast float [[C:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[REASS_MUL2:%.*]] = fmul fast float [[A:%.*]], [[A]]
; CHECK-NEXT:    [[REASS_MUL:%.*]] = fmul fast float [[REASS_MUL2]], [[REASS_ADD1]]
; CHECK-NEXT:    ret float [[REASS_MUL]]
;
  %aa = fmul fast float %A, %A
  %aab = fmul fast float %aa, %B
  %ac = fmul fast float %A, %C
  %aac = fmul fast float %ac, %A
  %r = fadd fast float %aab, %aac
  ret float %r
}

define float @test7_reassoc(float %A, float %B, float %C) {
; CHECK-LABEL: @test7_reassoc(
; CHECK-NEXT:    [[AA:%.*]] = fmul reassoc float [[A:%.*]], [[A]]
; CHECK-NEXT:    [[AAB:%.*]] = fmul reassoc float [[AA]], [[B:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc float [[A]], [[A]]
; CHECK-NEXT:    [[AAC:%.*]] = fmul reassoc float [[TMP1]], [[C:%.*]]
; CHECK-NEXT:    [[R:%.*]] = fadd reassoc float [[AAB]], [[AAC]]
; CHECK-NEXT:    ret float [[R]]
;
  %aa = fmul reassoc float %A, %A
  %aab = fmul reassoc float %aa, %B
  %ac = fmul reassoc float %A, %C
  %aac = fmul reassoc float %ac, %A
  %r = fadd reassoc float %aab, %aac
  ret float %r
}

; (-X)*Y + Z -> Z-X*Y

define float @test8(float %X, float %Y, float %Z) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[A:%.*]] = fmul fast float [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fsub fast float [[Z:%.*]], [[A]]
; CHECK-NEXT:    ret float [[C]]
;
  %A = fsub fast float 0.0, %X
  %B = fmul fast float %A, %Y
  %C = fadd fast float %B, %Z
  ret float %C
}

define float @test8_unary_fneg(float %X, float %Y, float %Z) {
; CHECK-LABEL: @test8_unary_fneg(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fsub fast float [[Z:%.*]], [[TMP1]]
; CHECK-NEXT:    ret float [[C]]
;
  %A = fneg fast float %X
  %B = fmul fast float %A, %Y
  %C = fadd fast float %B, %Z
  ret float %C
}

define float @test8_reassoc(float %X, float %Y, float %Z) {
; CHECK-LABEL: @test8_reassoc(
; CHECK-NEXT:    [[A:%.*]] = fsub reassoc float 0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[B:%.*]] = fmul reassoc float [[A]], [[Y:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fadd reassoc float [[B]], [[Z:%.*]]
; CHECK-NEXT:    ret float [[C]]
;
  %A = fsub reassoc float 0.0, %X
  %B = fmul reassoc float %A, %Y
  %C = fadd reassoc float %B, %Z
  ret float %C
}

define float @test9(float %X) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[FACTOR:%.*]] = fmul fast float [[X:%.*]], 9.400000e+01
; CHECK-NEXT:    ret float [[FACTOR]]
;
  %Y = fmul fast float %X, 4.700000e+01
  %Z = fadd fast float %Y, %Y
  ret float %Z
}

; Check again with 'reassoc' and 'nsz' ('nsz' not technically required).
define float @test9_reassoc_nsz(float %X) {
; CHECK-LABEL: @test9_reassoc_nsz(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc nsz float [[X:%.*]], 9.400000e+01
; CHECK-NEXT:    ret float [[TMP1]]
;
  %Y = fmul reassoc nsz float %X, 4.700000e+01
  %Z = fadd reassoc nsz float %Y, %Y
  ret float %Z
}

; TODO: This doesn't require 'nsz'.  It should fold to X * 94.0
define float @test9_reassoc(float %X) {
; CHECK-LABEL: @test9_reassoc(
; CHECK-NEXT:    [[Y:%.*]] = fmul reassoc float [[X:%.*]], 4.700000e+01
; CHECK-NEXT:    [[Z:%.*]] = fadd reassoc float [[Y]], [[Y]]
; CHECK-NEXT:    ret float [[Z]]
;
  %Y = fmul reassoc float %X, 4.700000e+01
  %Z = fadd reassoc float %Y, %Y
  ret float %Z
}

; Side note: (x + x + x) and (3*x) each have only a single rounding.  So
; transforming x+x+x to 3*x is always safe, even without any FMF.
; To avoid that special-case, we have the addition of 'x' four times, here.
define float @test10(float %X) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[FACTOR:%.*]] = fmul fast float [[X:%.*]], 4.000000e+00
; CHECK-NEXT:    ret float [[FACTOR]]
;
  %Y = fadd fast float %X ,%X
  %Z = fadd fast float %Y, %X
  %W = fadd fast float %Z, %X
  ret float %W
}

; Check again with 'reassoc' and 'nsz' ('nsz' not technically required).
define float @test10_reassoc_nsz(float %X) {
; CHECK-LABEL: @test10_reassoc_nsz(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc nsz float [[X:%.*]], 4.000000e+00
; CHECK-NEXT:    ret float [[TMP1]]
;
  %Y = fadd reassoc nsz float %X ,%X
  %Z = fadd reassoc nsz float %Y, %X
  %W = fadd reassoc nsz float %Z, %X
  ret float %W
}

; TODO: This doesn't require 'nsz'.  It should fold to 4 * x
define float @test10_reassoc(float %X) {
; CHECK-LABEL: @test10_reassoc(
; CHECK-NEXT:    [[Y:%.*]] = fadd reassoc float [[X:%.*]], [[X]]
; CHECK-NEXT:    [[Z:%.*]] = fadd reassoc float [[Y]], [[X]]
; CHECK-NEXT:    [[W:%.*]] = fadd reassoc float [[Z]], [[X]]
; CHECK-NEXT:    ret float [[W]]
;
  %Y = fadd reassoc float %X ,%X
  %Z = fadd reassoc float %Y, %X
  %W = fadd reassoc float %Z, %X
  ret float %W
}

define float @test11(float %W) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[FACTOR:%.*]] = fmul fast float [[W:%.*]], 3.810000e+02
; CHECK-NEXT:    ret float [[FACTOR]]
;
  %X = fmul fast float %W, 127.0
  %Y = fadd fast float %X ,%X
  %Z = fadd fast float %Y, %X
  ret float %Z
}

; Check again using the minimal subset of FMF.
; Check again with 'reassoc' and 'nsz' ('nsz' not technically required).
define float @test11_reassoc_nsz(float %W) {
; CHECK-LABEL: @test11_reassoc_nsz(
; CHECK-NEXT:    [[Z:%.*]] = fmul reassoc nsz float [[W:%.*]], 3.810000e+02
; CHECK-NEXT:    ret float [[Z]]
;
  %X = fmul reassoc nsz float %W, 127.0
  %Y = fadd reassoc nsz float %X ,%X
  %Z = fadd reassoc nsz float %Y, %X
  ret float %Z
}

; TODO: This doesn't require 'nsz'.  It should fold to W*381.0.
define float @test11_reassoc(float %W) {
; CHECK-LABEL: @test11_reassoc(
; CHECK-NEXT:    [[X:%.*]] = fmul reassoc float [[W:%.*]], 1.270000e+02
; CHECK-NEXT:    [[Y:%.*]] = fadd reassoc float [[X]], [[X]]
; CHECK-NEXT:    [[Z:%.*]] = fadd reassoc float [[X]], [[Y]]
; CHECK-NEXT:    ret float [[Z]]
;
  %X = fmul reassoc float %W, 127.0
  %Y = fadd reassoc float %X ,%X
  %Z = fadd reassoc float %Y, %X
  ret float %Z
}

define float @test12(float %X) {
; CHECK-LABEL: @test12(
; CHECK-NEXT:    [[FACTOR:%.*]] = fmul fast float [[X:%.*]], -3.000000e+00
; CHECK-NEXT:    [[Z:%.*]] = fadd fast float [[FACTOR]], 6.000000e+00
; CHECK-NEXT:    ret float [[Z]]
;
  %A = fsub fast float 1.000000e+00, %X
  %B = fsub fast float 2.000000e+00, %X
  %C = fsub fast float 3.000000e+00, %X
  %Y = fadd fast float %A ,%B
  %Z = fadd fast float %Y, %C
  ret float %Z
}

; Check again with 'reassoc' and 'nsz' ('nsz' not technically required).
define float @test12_reassoc_nsz(float %X) {
; CHECK-LABEL: @test12_reassoc_nsz(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc nsz float [[X:%.*]], 3.000000e+00
; CHECK-NEXT:    [[TMP2:%.*]] = fsub reassoc nsz float 6.000000e+00, [[TMP1]]
; CHECK-NEXT:    ret float [[TMP2]]
;
  %A = fsub reassoc nsz float 1.000000e+00, %X
  %B = fsub reassoc nsz float 2.000000e+00, %X
  %C = fsub reassoc nsz float 3.000000e+00, %X
  %Y = fadd reassoc nsz float %A ,%B
  %Z = fadd reassoc nsz float %Y, %C
  ret float %Z
}

; TODO: This doesn't require 'nsz'.  It should fold to (6.0 - 3.0*x)
define float @test12_reassoc(float %X) {
; CHECK-LABEL: @test12_reassoc(
; CHECK-NEXT:    [[A:%.*]] = fsub reassoc float 1.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[B:%.*]] = fsub reassoc float 2.000000e+00, [[X]]
; CHECK-NEXT:    [[C:%.*]] = fsub reassoc float 3.000000e+00, [[X]]
; CHECK-NEXT:    [[Y:%.*]] = fadd reassoc float [[A]], [[B]]
; CHECK-NEXT:    [[Z:%.*]] = fadd reassoc float [[C]], [[Y]]
; CHECK-NEXT:    ret float [[Z]]
;
  %A = fsub reassoc float 1.000000e+00, %X
  %B = fsub reassoc float 2.000000e+00, %X
  %C = fsub reassoc float 3.000000e+00, %X
  %Y = fadd reassoc float %A ,%B
  %Z = fadd reassoc float %Y, %C
  ret float %Z
}

define float @test13(float %X1, float %X2, float %X3) {
; CHECK-LABEL: @test13(
; CHECK-NEXT:    [[REASS_ADD:%.*]] = fsub fast float [[X3:%.*]], [[X2:%.*]]
; CHECK-NEXT:    [[REASS_MUL:%.*]] = fmul fast float [[REASS_ADD]], [[X1:%.*]]
; CHECK-NEXT:    ret float [[REASS_MUL]]
;
  %A = fsub fast float 0.000000e+00, %X1
  %B = fmul fast float %A, %X2   ; -X1*X2
  %C = fmul fast float %X1, %X3  ; X1*X3
  %D = fadd fast float %B, %C    ; -X1*X2 + X1*X3 -> X1*(X3-X2)
  ret float %D
}

define float @test13_unary_fneg(float %X1, float %X2, float %X3) {
; CHECK-LABEL: @test13_unary_fneg(
; CHECK-NEXT:    [[TMP1:%.*]] = fsub fast float [[X3:%.*]], [[X2:%.*]]
; CHECK-NEXT:    [[D:%.*]] = fmul fast float [[TMP1]], [[X1:%.*]]
; CHECK-NEXT:    ret float [[D]]
;
  %A = fneg fast float %X1
  %B = fmul fast float %A, %X2   ; -X1*X2
  %C = fmul fast float %X1, %X3  ; X1*X3
  %D = fadd fast float %B, %C    ; -X1*X2 + X1*X3 -> X1*(X3-X2)
  ret float %D
}

define float @test13_reassoc(float %X1, float %X2, float %X3) {
; CHECK-LABEL: @test13_reassoc(
; CHECK-NEXT:    [[A:%.*]] = fsub reassoc float 0.000000e+00, [[X1:%.*]]
; CHECK-NEXT:    [[B:%.*]] = fmul reassoc float [[A]], [[X2:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fmul reassoc float [[X1]], [[X3:%.*]]
; CHECK-NEXT:    [[D:%.*]] = fadd reassoc float [[B]], [[C]]
; CHECK-NEXT:    ret float [[D]]
;
  %A = fsub reassoc float 0.000000e+00, %X1
  %B = fmul reassoc float %A, %X2   ; -X1*X2
  %C = fmul reassoc float %X1, %X3  ; X1*X3
  %D = fadd reassoc float %B, %C    ; -X1*X2 + X1*X3 -> X1*(X3-X2)
  ret float %D
}

define float @test14(float %X1, float %X2) {
; CHECK-LABEL: @test14(
; CHECK-NEXT:    [[TMP1:%.*]] = fsub fast float [[X1:%.*]], [[X2:%.*]]
; CHECK-NEXT:    [[D1:%.*]] = fmul fast float [[TMP1]], 4.700000e+01
; CHECK-NEXT:    ret float [[D1]]
;
  %B = fmul fast float %X1, 47.   ; X1*47
  %C = fmul fast float %X2, -47.  ; X2*-47
  %D = fadd fast float %B, %C    ; X1*47 + X2*-47 -> 47*(X1-X2)
  ret float %D
}

; (x1 * 47) + (x2 * -47) => (x1 - x2) * 47
; Check again with 'reassoc' and 'nsz' ('nsz' not technically required).
define float @test14_reassoc_nsz(float %X1, float %X2) {
; CHECK-LABEL: @test14_reassoc_nsz(
; CHECK-NEXT:    [[TMP1:%.*]] = fsub reassoc nsz float [[X1:%.*]], [[X2:%.*]]
; CHECK-NEXT:    [[D1:%.*]] = fmul reassoc nsz float [[TMP1]], 4.700000e+01
; CHECK-NEXT:    ret float [[D1]]
;
  %B = fmul reassoc nsz float %X1, 47.   ; X1*47
  %C = fmul reassoc nsz float %X2, -47.  ; X2*-47
  %D = fadd reassoc nsz float %B, %C    ; X1*47 + X2*-47 -> 47*(X1-X2)
  ret float %D
}

; TODO: This doesn't require 'nsz'.  It should fold to ((x1 - x2) * 47.0)
define float @test14_reassoc(float %X1, float %X2) {
; CHECK-LABEL: @test14_reassoc(
; CHECK-NEXT:    [[B:%.*]] = fmul reassoc float [[X1:%.*]], 4.700000e+01
; CHECK-NEXT:    [[C:%.*]] = fmul reassoc float [[X2:%.*]], 4.700000e+01
; CHECK-NEXT:    [[D1:%.*]] = fsub reassoc float [[B]], [[C]]
; CHECK-NEXT:    ret float [[D1]]
;
  %B = fmul reassoc float %X1, 47.   ; X1*47
  %C = fmul reassoc float %X2, -47.  ; X2*-47
  %D = fadd reassoc float %B, %C    ; X1*47 + X2*-47 -> 47*(X1-X2)
  ret float %D
}

define float @test15(float %arg) {
; CHECK-LABEL: @test15(
; CHECK-NEXT:    [[T2:%.*]] = fmul fast float [[ARG:%.*]], 1.440000e+02
; CHECK-NEXT:    ret float [[T2]]
;
  %t1 = fmul fast float 1.200000e+01, %arg
  %t2 = fmul fast float %t1, 1.200000e+01
  ret float %t2
}

define float @test15_reassoc(float %arg) {
; CHECK-LABEL: @test15_reassoc(
; CHECK-NEXT:    [[T2:%.*]] = fmul reassoc float [[ARG:%.*]], 1.440000e+02
; CHECK-NEXT:    ret float [[T2]]
;
  %t1 = fmul reassoc float 1.200000e+01, %arg
  %t2 = fmul reassoc float %t1, 1.200000e+01
  ret float %t2
}

; (b+(a+1234))+-a -> b+1234
define float @test16(float %b, float %a) {
; CHECK-LABEL: @test16(
; CHECK-NEXT:    [[TMP1:%.*]] = fadd fast float [[B:%.*]], 1.234000e+03
; CHECK-NEXT:    ret float [[TMP1]]
;
  %1 = fadd fast float %a, 1234.0
  %2 = fadd fast float %b, %1
  %3 = fsub fast float 0.0, %a
  %4 = fadd fast float %2, %3
  ret float %4
}

define float @test16_unary_fneg(float %b, float %a) {
; CHECK-LABEL: @test16_unary_fneg(
; CHECK-NEXT:    [[TMP1:%.*]] = fadd fast float [[B:%.*]], 1.234000e+03
; CHECK-NEXT:    ret float [[TMP1]]
;
  %1 = fadd fast float %a, 1234.0
  %2 = fadd fast float %b, %1
  %3 = fneg fast float %a
  %4 = fadd fast float %2, %3
  ret float %4
}

define float @test16_reassoc(float %b, float %a) {
; CHECK-LABEL: @test16_reassoc(
; CHECK-NEXT:    [[TMP1:%.*]] = fadd reassoc float [[A:%.*]], 1.234000e+03
; CHECK-NEXT:    [[TMP2:%.*]] = fadd reassoc float [[TMP1]], [[B:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = fsub reassoc float 0.000000e+00, [[A]]
; CHECK-NEXT:    [[TMP4:%.*]] = fadd reassoc float [[TMP3]], [[TMP2]]
; CHECK-NEXT:    ret float [[TMP4]]
;
  %1 = fadd reassoc float %a, 1234.0
  %2 = fadd reassoc float %b, %1
  %3 = fsub reassoc float 0.0, %a
  %4 = fadd reassoc float %2, %3
  ret float %4
}

; Test that we can turn things like X*-(Y*Z) -> X*-1*Y*Z.

define float @test17(float %a, float %b, float %z) {
; CHECK-LABEL: @test17(
; CHECK-NEXT:    [[E:%.*]] = fmul fast float [[A:%.*]], 1.234500e+04
; CHECK-NEXT:    [[F:%.*]] = fmul fast float [[E]], [[B:%.*]]
; CHECK-NEXT:    [[G:%.*]] = fmul fast float [[F]], [[Z:%.*]]
; CHECK-NEXT:    ret float [[G]]
;
  %c = fsub fast float 0.000000e+00, %z
  %d = fmul fast float %a, %b
  %e = fmul fast float %c, %d
  %f = fmul fast float %e, 1.234500e+04
  %g = fsub fast float 0.000000e+00, %f
  ret float %g
}

define float @test17_unary_fneg(float %a, float %b, float %z) {
; CHECK-LABEL: @test17_unary_fneg(
; CHECK-NEXT:    [[D:%.*]] = fmul fast float [[A:%.*]], 1.234500e+04
; CHECK-NEXT:    [[E:%.*]] = fmul fast float [[D]], [[B:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[E]], [[Z:%.*]]
; CHECK-NEXT:    ret float [[TMP1]]
;
  %c = fneg fast float %z
  %d = fmul fast float %a, %b
  %e = fmul fast float %c, %d
  %f = fmul fast float %e, 1.234500e+04
  %g = fneg fast float %f
  ret float %g
}

define float @test17_reassoc(float %a, float %b, float %z) {
; CHECK-LABEL: @test17_reassoc(
; CHECK-NEXT:    [[C:%.*]] = fsub reassoc float 0.000000e+00, [[Z:%.*]]
; CHECK-NEXT:    [[D:%.*]] = fmul reassoc float [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[E:%.*]] = fmul reassoc float [[D]], [[C]]
; CHECK-NEXT:    [[F:%.*]] = fmul reassoc float [[E]], 1.234500e+04
; CHECK-NEXT:    [[G:%.*]] = fsub reassoc float 0.000000e+00, [[F]]
; CHECK-NEXT:    ret float [[G]]
;
  %c = fsub reassoc float 0.000000e+00, %z
  %d = fmul reassoc float %a, %b
  %e = fmul reassoc float %c, %d
  %f = fmul reassoc float %e, 1.234500e+04
  %g = fsub reassoc float 0.000000e+00, %f
  ret float %g
}

define float @test18(float %a, float %b, float %z) {
; CHECK-LABEL: @test18(
; CHECK-NEXT:    [[E:%.*]] = fmul fast float [[A:%.*]], 4.000000e+01
; CHECK-NEXT:    [[F:%.*]] = fmul fast float [[E]], [[Z:%.*]]
; CHECK-NEXT:    ret float [[F]]
;
  %d = fmul fast float %z, 4.000000e+01
  %c = fsub fast float 0.000000e+00, %d
  %e = fmul fast float %a, %c
  %f = fsub fast float 0.000000e+00, %e
  ret float %f
}

define float @test18_unary_fneg(float %a, float %b, float %z) {
; CHECK-LABEL: @test18_unary_fneg(
; CHECK-NEXT:    [[E:%.*]] = fmul fast float [[A:%.*]], 4.000000e+01
; CHECK-NEXT:    [[F:%.*]] = fmul fast float [[E]], [[Z:%.*]]
; CHECK-NEXT:    ret float [[F]]
;
  %d = fmul fast float %z, 4.000000e+01
  %c = fneg fast float %d
  %e = fmul fast float %a, %c
  %f = fneg fast float %e
  ret float %f
}

define float @test18_reassoc(float %a, float %b, float %z) {
; CHECK-LABEL: @test18_reassoc(
; CHECK-NEXT:    [[D:%.*]] = fmul reassoc float [[Z:%.*]], 4.000000e+01
; CHECK-NEXT:    [[C:%.*]] = fsub reassoc float 0.000000e+00, [[D]]
; CHECK-NEXT:    [[E:%.*]] = fmul reassoc float [[C]], [[A:%.*]]
; CHECK-NEXT:    [[F:%.*]] = fsub reassoc float 0.000000e+00, [[E]]
; CHECK-NEXT:    ret float [[F]]
;
  %d = fmul reassoc float %z, 4.000000e+01
  %c = fsub reassoc float 0.000000e+00, %d
  %e = fmul reassoc float %a, %c
  %f = fsub reassoc float 0.000000e+00, %e
  ret float %f
}

; It is not safe to reassociate unary fneg without nnan.
define float @test18_reassoc_unary_fneg(float %a, float %b, float %z) {
; CHECK-LABEL: @test18_reassoc_unary_fneg(
; CHECK-NEXT:    [[C:%.*]] = fmul reassoc float [[Z:%.*]], -4.000000e+01
; CHECK-NEXT:    [[E:%.*]] = fmul reassoc float [[C]], [[A:%.*]]
; CHECK-NEXT:    [[F:%.*]] = fneg reassoc float [[E]]
; CHECK-NEXT:    ret float [[F]]
;
  %d = fmul reassoc float %z, 4.000000e+01
  %c = fneg reassoc float %d
  %e = fmul reassoc float %a, %c
  %f = fneg reassoc float %e
  ret float %f
}

; With sub reassociation, constant folding can eliminate the 12 and -12 constants.
define float @test19(float %A, float %B) {
; CHECK-LABEL: @test19(
; CHECK-NEXT:    [[Z:%.*]] = fsub fast float [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    ret float [[Z]]
;
  %X = fadd fast float -1.200000e+01, %A
  %Y = fsub fast float %X, %B
  %Z = fadd fast float %Y, 1.200000e+01
  ret float %Z
}

define float @test19_reassoc(float %A, float %B) {
; CHECK-LABEL: @test19_reassoc(
; CHECK-NEXT:    [[X:%.*]] = fadd reassoc float [[A:%.*]], -1.200000e+01
; CHECK-NEXT:    [[Y:%.*]] = fsub reassoc float [[X]], [[B:%.*]]
; CHECK-NEXT:    [[Z:%.*]] = fadd reassoc float [[Y]], 1.200000e+01
; CHECK-NEXT:    ret float [[Z]]
;
  %X = fadd reassoc float -1.200000e+01, %A
  %Y = fsub reassoc float %X, %B
  %Z = fadd reassoc float %Y, 1.200000e+01
  ret float %Z
}

; With sub reassociation, constant folding can eliminate the uses of %a.
define float @test20(float %a, float %b, float %c) nounwind  {
; FIXME: Should be able to generate the below, which may expose more
;        opportunites for FAdd reassociation.
; %sum = fadd fast float %c, %b
; %t7 = fsub fast float 0, %sum
; CHECK-LABEL: @test20(
; CHECK-NEXT:    [[B_NEG:%.*]] = fsub fast float -0.000000e+00, [[B:%.*]]
; CHECK-NEXT:    [[T7:%.*]] = fsub fast float [[B_NEG]], [[C:%.*]]
; CHECK-NEXT:    ret float [[T7]]
;
  %t3 = fsub fast float %a, %b
  %t5 = fsub fast float %t3, %c
  %t7 = fsub fast float %t5, %a
  ret float %t7
}

define float @test20_reassoc(float %a, float %b, float %c) nounwind  {
; CHECK-LABEL: @test20_reassoc(
; CHECK-NEXT:    [[T3:%.*]] = fsub reassoc float [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[T5:%.*]] = fsub reassoc float [[T3]], [[C:%.*]]
; CHECK-NEXT:    [[T7:%.*]] = fsub reassoc float [[T5]], [[A]]
; CHECK-NEXT:    ret float [[T7]]
;
  %t3 = fsub reassoc float %a, %b
  %t5 = fsub reassoc float %t3, %c
  %t7 = fsub reassoc float %t5, %a
  ret float %t7
}

