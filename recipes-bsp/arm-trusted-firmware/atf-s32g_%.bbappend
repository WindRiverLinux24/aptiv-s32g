FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/atf-s32g-aptiv:"

PLATFORM:aptiv-cvc-fl = " aptiv_cvc_fl"

AUTOSAR_SEC_PATCHES = "file://0001-s32-extend-the-DTB-size-for-BL33.patch \
			file://0001-dts-s32-extend-the-hse-reserve-memory-to-8-MB.patch \
"

SRC_URI:append:aptiv-cvc = " \
	file://0003-atf-s32g-Set-CAN-clock-to-FOSC-and-40MHz.patch \
	file://0005-aptiv-s32g-atf-add-xrdc.patch \
	file://0006-aptiv-set-S32_VR5510-for-aptiv-CVC-platform.patch \
	file://0007-aptiv-s32g-atf-s32g-Patch-PFE1-2-SGMII-MDIO-Bus-for-.patch \
	file://0008-aptiv-cvc-fl-add-support-for-Aptiv-CVC-FL-board.patch \
	file://0009-aptiv-cvc-fl-dts-add-mmc-sel-gpio-hog.patch \
"

EXTRA_OEMAKE:append:aptiv-cvc = " S32_HAS_HV=1"

COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"
