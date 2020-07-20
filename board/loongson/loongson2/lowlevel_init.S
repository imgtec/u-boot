/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Copyright (C) 2016 Imagination Technologies
 */

#include <config.h>

#include <asm/addrspace.h>
#include <asm/asm.h>
#include <asm/mipsregs.h>
#include <asm/regdef.h>

#include "boston-regs.h"

.data

msg_ddr_cal:	.ascii "DDR Cal "
msg_ddr_ok:	.ascii "DDR OK  "

.text

LEAF(lowlevel_init)
	move	s0, ra

	PTR_LA	a0, msg_ddr_cal
	bal	lowlevel_display

	PTR_LI	t0, BOSTON_PLAT_DDR3STAT
1:	lw	t1, 0(t0)
	andi	t1, t1, BOSTON_PLAT_DDR3STAT_CALIB
	beqz	t1, 1b

	PTR_LA	a0, msg_ddr_ok
	bal	lowlevel_display

	jr	s0
	END(lowlevel_init)

LEAF(__lowlevel_display)
	.set	push
	.set	noat
	PTR_LI	AT, BOSTON_LCD_BASE
#ifdef CONFIG_64BIT
	ld	k1, 0(a0)
	sd	k1, 0(AT)
#else
	lw	k1, 0(a0)
	sw	k1, 0(AT)
	lw	k1, 4(a0)
	sw	k1, 4(AT)
#endif
	.set	pop
	jr	ra
END(__lowlevel_display)

/* How to use it?
   Adjust TextBase to FFFFFFFF81000000

	li   a0, 'A'
	bal  lowlevel_display
	nop
*/

#define COM1_BASE_ADDR 0xbfe00000
#define LSR_TXRDY       0x20    /* transmitter ready */
#define NSREG(x)        (x) 
#define      NS16550_LSR     5 
#define      NS16550_DATA    0 
#define      NS16550_CFCR    3
#define      CFCR_DLAB       0x80    /* divisor latch */

LEAF(lowlevel_display)
	li	t0, COM1_BASE_ADDR

1:	lbu     t1, NSREG(NS16550_LSR)(t0)
        and     t1, t1, LSR_TXRDY
        beq	t1, zero, 1b
          nop

        sb	a0, NSREG(NS16550_DATA)(t0)
        jr	ra
	  nop
END(lowlevel_display)

LEAF(lowlevel_display_gpio)
// PWM 3 2 1
// GPIO ???
// make sure we are gpio.
	li	t0, 0xBfe10420
	lw	t1, 0(t0)
	li	t2, ~0x0000f000
	and	t1, t1, t2

//	li	t1, 0x00000d19 // 强制GPIO，过会改回来吧
	sw	t1, 0(t0)
// direction output
	li	t0, 0xBfe10500
	lw	t1, 0(t0)
	li	t2, ~0x00f00000
	and	t1, t1, t2

//	li	t1, 0xff0ffff6 // 暴力输出
	sw	t1, 0(t0)

// tongle
111:
	lw	t1, 0x10(t0)
	li	t2, 0x00f00000
	xor	t1, t1, t2
	sw	t1, 0x10(t0)

	jr	ra
	  nop
END(lowlevel_display_gpio)



LEAF(watchdog_close)
	//disable watch DOG.
	/*gpio 3 output zero*/
	li t1,0xbfe10500

	li t2,(1 << 3)
	not t2,t2
	lw t3,0x0(t1)
	and t2,t3
	sw t2,0x0(t1)

	li t2,(1 << 3)
	lw t3,0x10(t1)
	not t2,t2
	and t2,t3
	sw t2,0x10(t1)
	nop

	jr		ra
	nop
END(watchdog_close)

#define COP_0_PRID          $15
LEAF(ls2k_version)
	.set    mips32
	mfc0    a0, COP_0_PRID

	.set    mips3
	andi    a0, a0, 0xf
	li	a1, 0x3
	bne     a0, a1, 2f
	li	v0, 0
	li	v0, 0x1
2:
	jr	ra
	  nop
END(ls2k_version)



LEAF(ls2k_fix_hardware)

#if 1 //fix the hardware poweroff error.

	bal	ls2k_version
	nop
	bnez	v0,2f
	nop

	.set    mips32
	mfc0    t0, $15, 1      #EBASE
	.set    mips3
	andi    t0, t0, 0x3ff
	bnez    t0, 2f
	nop

	lui	t0, 0xba00
	lui	t1, 0x1fe0
	sw	t1, 0x1010(t0) /* config bar for APB */
	lw	t2, 0x1004(t0)
	ori	t2, t2, 0x2
	sw	t2, 0x1004(t0)

	li t0,0xbfe0700c
	lw t1,0x0(t0)
	and t2,t1,(1 << 11)
	beqz  t2,2f
	nop

	li t0,0xbfe0700c
	lw t1, 0x0(t0)
	sw t1,0x0(t0)
	li t2,0x3c00
	li t0,0xbfe07014
	sw t2,0x0(t0)
2:

	jr	ra
	  nop
#endif
END(ls2k_fix_hardware)





LEAF(initserial)
#if 0   //mtf add
	li	t0, COM1_BASE_ADDR
	li	t1, CFCR_DLAB
	sb	t1, NSREG(NS16550_CFCR)(t0)

	li	t1, 0
	sb	t1, 1(t0)
	li	t1, 0x36	# divider, highest possible baud rate
	sb	t1, 0(t0)

1:
	lb	a1, 0(t0)
	bne	a1, t1, 1b
	  nop

	li	t1, 3		#CFCR_8BITS
	sb	t1, 3(t0)	#NSREG(NS16550_CFCR)(v0)

	li	t1, 71
	sb	t1, 2(t0)
#endif
 
        jr       ra
          nop
END(initserial)



