FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/u-boot-s32-aptiv:"

SEC_PATCHES = "file://0001-configs-aptiv_cvc_fl-add-secure-boot-related-configs.patch \
"

SRC_URI:append:aptiv-cvc = " \
	file://0002-set-gmac-to-right-speed-of-the-phy-if-autoneg-works.patch \
	file://0005-u-boot-s32-remove-XEN_EXTRA_ENV_SETTINGS.patch \
	file://0006-s32cc-increate-boot-image-size-to-128MB.patch \
	file://0007-s32-serdes-hwconfig-change-hwconfig-for-CVC-board.patch \
	file://0008-aptiv-cvc-fl-add-support-for-Aptiv-CVC-FL-board.patch \
	file://0009-aptiv-cvc-fl-add-cmd-to-configure-RTL9010-phys.patch \
	file://0010-u-boot-s32-enable-CONFIG_XEN_SUPPORT-for-Aptiv-CVC-FL-board.patch \
	file://0011-aptiv-cvc-fl-add-GPIO_HOG-config.patch \
	${@bb.utils.contains('HSE_SEC_ENABLED', '1', '${SEC_PATCHES}', '', d)} \
"

COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"

do_compile:append:aptiv-cvc() {
    if [ "${HSE_SEC_ENABLED}" = "1" ]; then
        for config in ${UBOOT_MACHINE}; do
            cfgout="${B}/${config}/u-boot-s32.cfgout"
            if [ -e $cfgout ]; then
				sed -i 's|${HSE_FW_DEFAULT_NAME}|${HSE_LOCAL_FIRMWARE_DIR}/${HSE_FW_NAME_S32G3}|g' $cfgout
            fi
        done
    fi
}
