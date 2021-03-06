; RUN: llc -verify-machineinstrs -mcpu=pwr7 -mtriple powerpc-ibm-aix-xcoff \
; RUN: -code-model=small -stop-after=machine-cp < %s | FileCheck \
; RUN: --check-prefix=32SMALL-MIR %s

; RUN: llc -verify-machineinstrs -mcpu=pwr7 -mtriple powerpc-ibm-aix-xcoff \
; RUN: -code-model=large -stop-after=machine-cp < %s | FileCheck \
; RUN: --check-prefix=32LARGE-MIR %s

; RUN: llc -verify-machineinstrs -mcpu=pwr7 -mtriple powerpc64-ibm-aix-xcoff \
; RUN: -code-model=small -stop-after=machine-cp < %s | FileCheck \
; RUN: --check-prefix=64SMALL-MIR %s

; RUN: llc -verify-machineinstrs -mcpu=pwr7 -mtriple powerpc64-ibm-aix-xcoff \
; RUN: -code-model=large -stop-after=machine-cp < %s | FileCheck \
; RUN: --check-prefix=64LARGE-MIR %s

; RUN: llc -mtriple powerpc-ibm-aix-xcoff -code-model=small < %s | FileCheck \
; RUN: --check-prefixes=32SMALL-ASM,CHECK %s

; RUN: llc -mtriple powerpc-ibm-aix-xcoff -code-model=large < %s | FileCheck \
; RUN: --check-prefixes=32LARGE-ASM,CHECK %s

; RUN: llc -mtriple powerpc64-ibm-aix-xcoff -code-model=small < %s | FileCheck \
; RUN: --check-prefixes=64SMALL-ASM,CHECK %s

; RUN: llc -mtriple powerpc64-ibm-aix-xcoff -code-model=large < %s | FileCheck \
; RUN: --check-prefixes=64LARGE-ASM,CHECK %s

  define i32 @jump_table(i32 %a) {
  entry:
    switch i32 %a, label %sw.epilog [
      i32 1, label %sw.bb
      i32 2, label %sw.bb1
      i32 3, label %sw.bb2
      i32 4, label %sw.bb3
    ]

  sw.bb:
    tail call void asm sideeffect "", ""()
    br label %sw.epilog

  sw.bb1:
    tail call void asm sideeffect "", ""()
    br label %sw.epilog

  sw.bb2:
    tail call void asm sideeffect "", ""()
    br label %sw.epilog

  sw.bb3:
    tail call void asm sideeffect "", ""()
    br label %sw.epilog

  sw.epilog:
    ret i32 0
  }


; 32SMALL-MIR: renamable $r[[REG1:[0-9]+]] = LWZtoc %jump-table.0, $r2 :: (load 4 from got)
; 32SMALL-MIR: renamable $r[[REG3:[0-9]+]] = RLWINM killed renamable $r[[REG2:[0-9]+]], 2, 0, 29
; 32SMALL-MIR: renamable $r[[REG4:[0-9]+]] = LWZX killed renamable $r[[REG3]], renamable $r[[REG1]] :: (load 4 from jump-table)
; 32SMALL-MIR: renamable $r[[REG5:[0-9]+]] = ADD4 killed renamable $r[[REG4]], killed renamable $r[[REG1]]

; 32LARGE-MIR: renamable $r[[REG1:[0-9]+]] = ADDIStocHA $r2, %jump-table.0
; 32LARGE-MIR: renamable $r[[REG2:[0-9]+]] = LWZtocL %jump-table.0, killed renamable $r[[REG1]], implicit $r2 :: (load 4 from got)
; 32LARGE-MIR: renamable $r[[REG4:[0-9]+]] = RLWINM killed renamable $r[[REG3:[0-9]+]], 2, 0, 29
; 32LARGE-MIR: renamable $r[[REG5:[0-9]+]] = LWZX killed renamable $r[[REG4]], renamable $r[[REG2]] :: (load 4 from jump-table)
; 32LARGE-MIR: renamable $r[[REG6:[0-9]+]] = ADD4 killed renamable $r[[REG5]], killed renamable $r[[REG2]]

; 64SMALL-MIR: renamable $x[[REG1:[0-9]+]] = LDtocJTI %jump-table.0, $x2 :: (load 8 from got)
; 64SMALL-MIR: renamable $x[[REG3:[0-9]+]] = RLDIC killed renamable $x[[REG2:[0-9]+]], 2, 30
; 64SMALL-MIR: renamable $x[[REG4:[0-9]+]] = LWAX killed renamable $x[[REG3]], renamable $x[[REG1]] :: (load 4 from jump-table)
; 64SMALL-MIR: renamable $x[[REG6:[0-9]+]] = ADD8 killed renamable $x[[REG4]], killed renamable $x[[REG1]]

; 64LARGE-MIR: renamable $x[[REG1:[0-9]+]] = ADDIStocHA8 $x2, %jump-table.0
; 64LARGE-MIR: renamable $x[[REG2:[0-9]+]] = LDtocL %jump-table.0, killed renamable $x[[REG1]], implicit $x2 :: (load 8 from got)
; 64LARGE-MIR: renamable $x[[REG4:[0-9]+]] = RLDIC killed renamable $x[[REG3:[0-9]+]], 2, 30
; 64LARGE-MIR: renamable $x[[REG5:[0-9]+]] = LWAX killed renamable $x[[REG4]], renamable $x[[REG2]] :: (load 4 from jump-table)
; 64LARGE-MIR: renamable $x[[REG6:[0-9]+]] = ADD8 killed renamable $x[[REG5]], killed renamable $x[[REG2]]

; 32SMALL-ASM-LABEL: jump_table
; 32SMALL-ASM: .jump_table:
; 32SMALL-ASM:      addi 3, 3, -1
; 32SMALL-ASM: 	    cmplwi 3, 3
; 32SMALL-ASM: 	    bgt	0, LBB0_6
; 32SMALL-ASM: 	    lwz 4, LC0(2)
; 32SMALL-ASM: 	    slwi 3, 3, 2
; 32SMALL-ASM: 	    lwzx 3, 3, 4
; 32SMALL-ASM: 	    add 3, 3, 4
; 32SMALL-ASM: 	    mtctr 3
; 32SMALL-ASM: 	    bctr
; 32SMALL-ASM: LBB0_2:
; 32SMALL-ASM: LBB0_3:
; 32SMALL-ASM: LBB0_4:
; 32SMALL-ASM: LBB0_5:
; 32SMALL-ASM: LBB0_6:
; 32SMALL-ASM: 	    li 3, 0
; 32SMALL-ASM: 	    blr
; 32SMALL-ASM: 	    .csect .rodata[RO]
; 32SMALL-ASM: 	    .align  2
; 32SMALL-ASM: .LJTI0_0:
; 32SMALL-ASM: 	    .long   LBB0_2-.LJTI0_0
; 32SMALL-ASM: 	    .long   LBB0_3-.LJTI0_0
; 32SMALL-ASM: 	    .long   LBB0_4-.LJTI0_0
; 32SMALL-ASM: 	    .long   LBB0_5-.LJTI0_0

; 32LARGE-ASM-LABEL: jump_table
; 32LARGE-ASM: .jump_table:
; 32LARGE-ASM:      addi 3, 3, -1
; 32LARGE-ASM:      cmplwi  3, 3
; 32LARGE-ASM:      bgt     0, LBB0_6
; 32LARGE-ASM: 	    addis 4, LC0@u(2)
; 32LARGE-ASM: 	    slwi 3, 3, 2
; 32LARGE-ASM:      lwz 4, LC0@l(4)
; 32LARGE-ASM:      lwzx 3, 3, 4
; 32LARGE-ASM:      add 3, 3, 4
; 32LARGE-ASM:      mtctr 3
; 32LARGE-ASM:      bctr
; 32LARGE-ASM: LBB0_2:
; 32LARGE-ASM: LBB0_3:
; 32LARGE-ASM: LBB0_4:
; 32LARGE-ASM: LBB0_5:
; 32LARGE-ASM: LBB0_6:
; 32LARGE-ASM:      li 3, 0
; 32LARGE-ASM:      blr
; 32LARGE-ASM:      .csect .rodata[RO]
; 32LARGE-ASM:      .align  2
; 32LARGE-ASM: .LJTI0_0:
; 32LARGE-ASM:      .long   LBB0_2-.LJTI0_0
; 32LARGE-ASM:      .long   LBB0_3-.LJTI0_0
; 32LARGE-ASM:      .long   LBB0_4-.LJTI0_0
; 32LARGE-ASM:      .long   LBB0_5-.LJTI0_0

; 64SMALL-ASM-LABEL: jump_table
; 64SMALL-ASM: .jump_table:
; 64SMALL-ASM:      addi 3, 3, -1
; 64SMALL-ASM:      cmplwi  3, 3
; 64SMALL-ASM:      bgt     0, LBB0_6
; 64SMALL-ASM:      ld 4, LC0(2)
; 64SMALL-ASM:      rldic 3, 3, 2, 30
; 64SMALL-ASM:      lwax 3, 3, 4
; 64SMALL-ASM:      add 3, 3, 4
; 64SMALL-ASM:      mtctr 3
; 64SMALL-ASM:      bctr
; 64SMALL-ASM: LBB0_2:
; 64SMALL-ASM: LBB0_3:
; 64SMALL-ASM: LBB0_4:
; 64SMALL-ASM: LBB0_5:
; 64SMALL-ASM: LBB0_6:
; 64SMALL-ASM:      li 3, 0
; 64SMALL-ASM:      blr
; 64SMALL-ASM:      .csect .rodata[RO]
; 64SMALL-ASM:      .align  2
; 64SMALL-ASM: .LJTI0_0:
; 64SMALL-ASM:      .long   LBB0_2-.LJTI0_0
; 64SMALL-ASM:      .long   LBB0_3-.LJTI0_0
; 64SMALL-ASM:      .long   LBB0_4-.LJTI0_0
; 64SMALL-ASM:      .long   LBB0_5-.LJTI0_0

; 64LARGE-ASM-LABEL: jump_table
; 64LARGE-ASM: .jump_table:
; 64LARGE-ASM:      addi 3, 3, -1
; 64LARGE-ASM:      cmplwi  3, 3
; 64LARGE-ASM:      bgt     0, LBB0_6
; 64LARGE-ASM:      addis 4, LC0@u(2)
; 64LARGE-ASM:      rldic 3, 3, 2, 30
; 64LARGE-ASM:      ld 4, LC0@l(4)
; 64LARGE-ASM:      lwax 3, 3, 4
; 64LARGE-ASM:      add 3, 3, 4
; 64LARGE-ASM:      mtctr 3
; 64LARGE-ASM:      bctr
; 64LARGE-ASM: LBB0_2:
; 64LARGE-ASM: LBB0_3:
; 64LARGE-ASM: LBB0_4:
; 64LARGE-ASM: LBB0_5:
; 64LARGE-ASM: LBB0_6:
; 64LARGE-ASM:      li 3, 0
; 64LARGE-ASM:      blr
; 64LARGE-ASM:      .csect .rodata[RO]
; 64LARGE-ASM:      .align  2
; 64LARGE-ASM: .LJTI0_0:
; 64LARGE-ASM:      .long   LBB0_2-.LJTI0_0
; 64LARGE-ASM:      .long   LBB0_3-.LJTI0_0
; 64LARGE-ASM:      .long   LBB0_4-.LJTI0_0
; 64LARGE-ASM:      .long   LBB0_5-.LJTI0_0

; CHECK: .toc
; CHECK: .tc .LJTI0_0[TC],.LJTI0_0
