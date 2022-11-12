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

do_compile:append:aptiv_cvc_sousa() {
    if [ "${HSE_SEC_ENABLED}" = "1" ]; then
        cfgout="${B}/aptiv_cvc_sousa_defconfig/u-boot-s32.cfgout"
        if [ -e $cfgout ]; then
            sed -i 's|${HSE_FW_DEFAULT_NAME}|${HSE_LOCAL_FIRMWARE_DIR}/${HSE_FW_NAME_S32G2}|g' $cfgout
        fi
    fi
}
