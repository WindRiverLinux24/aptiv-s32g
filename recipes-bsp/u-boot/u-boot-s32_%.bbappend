FILESEXTRAPATHS:prepend:aptiv_cvc_sousa := "${THISDIR}/u-boot-s32-aptiv:" 

SRC_URI:append:aptiv_cvc_sousa = " \
	file://0001-u-boot-s32-Aptiv-add-u-boot-support-for-Aptiv-CVC-bo.patch \
	file://0002-set-gmac-to-right-speed-of-the-phy-if-autoneg-works.patch \
	file://0003-s32g-aptiv-usb-Use-specific-TARGET_APTIV_CVC_SOUSA-c.patch \
"

COMPATIBLE_MACHINE:aptiv_cvc_sousa = "aptiv_cvc_sousa"
