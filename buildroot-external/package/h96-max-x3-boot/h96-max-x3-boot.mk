################################################################################
#
# H96 Max X3 pre-built U-Boot (Amlogic S905X3)
#
# Uses the community-maintained pre-built U-Boot from ophub which includes
# proper DDR calibration, BL2, BL30, BL31 and BL33 for the H96 Max X3.
#
################################################################################

H96_MAX_X3_BOOT_VERSION = 2a4e31e3fde9bced8a150d338aa397a0362df191
H96_MAX_X3_BOOT_SOURCE = $(H96_MAX_X3_BOOT_VERSION).tar.gz
H96_MAX_X3_BOOT_SITE = https://github.com/hardkernel/u-boot/archive
H96_MAX_X3_BOOT_LICENSE = GPL-2.0+
H96_MAX_X3_BOOT_LICENSE_FILES = Licenses/gpl-2.0.txt
H96_MAX_X3_BOOT_INSTALL_IMAGES = YES
H96_MAX_X3_BOOT_DEPENDENCIES = uboot

H96_MAX_X3_BOOT_BINS += u-boot.sm1

define H96_MAX_X3_BOOT_BUILD_CMDS
	# Download pre-built U-Boot from ophub community repository
	curl -L -o $(@D)/h96maxx3-u-boot.bin.sd.bin \
		"https://github.com/ophub/u-boot/raw/main/u-boot/amlogic/bootloader/h96maxx3-u-boot.bin.sd.bin"
	cp $(@D)/h96maxx3-u-boot.bin.sd.bin $(@D)/u-boot.sm1
endef

define H96_MAX_X3_BOOT_INSTALL_IMAGES_CMDS
	$(foreach f,$(H96_MAX_X3_BOOT_BINS), \
			cp -dpf $(@D)/$(f) $(BINARIES_DIR)/ \
	)
endef

$(eval $(generic-package))
