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

LEAF(lowlevel_display)
        .set noat
        move    AT, ra
        la      v0, COM1_BASE_ADDR
        bal     1f
        nop
        jr      AT
        nop

1:
        lbu     v1, NSREG(NS16550_LSR)(v0)
        and     v1, LSR_TXRDY
        beqz    v1, 1b
        nop

        sb      a0, NSREG(NS16550_DATA)(v0)
        j       ra
        nop
        .set at
END(lowlevel_display)

