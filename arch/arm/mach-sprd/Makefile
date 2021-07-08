# SPDX-License-Identifier: GPL-2.0+
#
# Copyright (c) 2014 Google, Inc
# Copyright (c) 2019 Rockchip Electronics Co., Ltd.

# We don't want the bootrom-helper present in a full U-Boot build, as
# this may have entered from ATF with the stack-pointer pointing to
# inaccessible/protected memory (and the bootrom-helper assumes that
# the stack-pointer is valid before switching to the U-Boot stack).
obj-spl-$(CONFIG_SPRD_BROM_HELPER) += bootrom.o
obj-spl-$(CONFIG_SPL_SPRD_COMMON_BOARD) += spl.o spl-boot-order.o
obj-tpl-$(CONFIG_SPRD_BROM_HELPER) += bootrom.o
obj-tpl-$(CONFIG_TPL_SPRD_COMMON_BOARD) += tpl.o
obj-tpl-$(CONFIG_SPRD_PX30) += px30-board-tpl.o

obj-spl-$(CONFIG_SPRD_RK3036) += rk3036-board-spl.o

ifeq ($(CONFIG_SPL_BUILD)$(CONFIG_TPL_BUILD),)

# Always include boot_mode.o, as we bypass it (i.e. turn it off)
# inside of boot_mode.c when CONFIG_BOOT_MODE_REG is 0.  This way,
# we can have the preprocessor correctly recognise both 0x0 and 0
# meaning "turn it off".
obj-y += boot_mode.o
obj-$(CONFIG_SPRD_COMMON_BOARD) += board.o
obj-$(CONFIG_MISC_INIT_R) += misc.o
endif

ifeq ($(CONFIG_TPL_BUILD),)
obj-$(CONFIG_DISPLAY_CPUINFO) += cpu-info.o
endif

obj-$(CONFIG_$(SPL_TPL_)RAM) += sdram.o

obj-$(CONFIG_SPRD_UMS312) += ums312/


# Clear out SPL objects, in case this is a TPL build
obj-spl-$(CONFIG_TPL_BUILD) =

# Now add SPL/TPL objects back into the main build
obj-$(CONFIG_SPL_BUILD) += $(obj-spl-y)
obj-$(CONFIG_TPL_BUILD) += $(obj-tpl-y)
