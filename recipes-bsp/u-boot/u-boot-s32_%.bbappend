FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/u-boot-s32-aptiv:"

SRC_URI:append:aptiv-cvc = " \
	file://0001-u-boot-s32-Aptiv-add-u-boot-support-for-Aptiv-CVC-bo.patch \
	file://0002-set-gmac-to-right-speed-of-the-phy-if-autoneg-works.patch \
	file://0003-s32g-aptiv-usb-Use-specific-TARGET_APTIV_CVC_SOUSA-c.patch \
	file://0004-u-boot-s32-enable-CONFIG_XEN_SUPPORT.patch \
	file://0005-u-boot-s32-remove-XEN_EXTRA_ENV_SETTINGS.patch \
	file://0006-s32cc-increate-boot-image-size-to-128MB.patch \
	file://0007-s32-serdes-hwconfig-change-hwconfig-for-CVC-board.patch \
	file://0008-aptiv-cvc-fl-add-support-for-Aptiv-CVC-FL-board.patch \
	${@bb.utils.contains('HSE_SEC_ENABLED', '1', 'file://0001-configs-aptiv_cvc_sousa-add-HSE_SECBOOT-config.patch', '', d)} \
	${@bb.utils.contains('HSE_SEC_ENABLED', '1', 'file://0001-configs-aptiv_cvc_sousa-enable-CONFIG_FIT_SIGNATURE-.patch', '', d)} \
"

COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"

do_compile:append:aptiv-cvc() {
    if [ "${HSE_SEC_ENABLED}" = "1" ]; then
        cfgout="${B}/${UBOOT_MACHINE}/u-boot-s32.cfgout"
        if [ -e $cfgout ]; then
            sed -i 's|${HSE_FW_DEFAULT_NAME}|${HSE_LOCAL_FIRMWARE_DIR}/${HSE_FW_NAME_S32G2}|g' $cfgout
        fi
    fi
}
