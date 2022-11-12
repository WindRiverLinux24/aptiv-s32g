FILESEXTRAPATHS:prepend:aptiv_cvc_sousa := "${THISDIR}/u-boot-s32-aptiv:" 

SRC_URI:append:aptiv_cvc_sousa = " \
	file://0001-u-boot-s32-Aptiv-add-u-boot-support-for-Aptiv-CVC-bo.patch \
	file://0002-set-gmac-to-right-speed-of-the-phy-if-autoneg-works.patch \
	file://0003-s32g-aptiv-usb-Use-specific-TARGET_APTIV_CVC_SOUSA-c.patch \
	file://0004-u-boot-s32-enable-CONFIG_XEN_SUPPORT.patch \
	file://0005-u-boot-s32-remove-XEN_EXTRA_ENV_SETTINGS.patch \
	file://0006-s32cc-increate-boot-image-size-to-128MB.patch \
	${@bb.utils.contains('HSE_SEC_ENABLED', '1', 'file://0001-configs-aptiv_cvc_sousa-add-HSE_SECBOOT-config.patch', '', d)} \
"

COMPATIBLE_MACHINE:aptiv_cvc_sousa = "aptiv_cvc_sousa"
