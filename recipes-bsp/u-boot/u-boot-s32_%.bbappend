FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/u-boot-s32-aptiv:"

SEC_PATCHES = "file://0001-configs-aptiv_cvc_sousa-add-HSE_SECBOOT-config.patch \
			   file://0001-configs-aptiv_cvc_sousa-enable-CONFIG_FIT_SIGNATURE-.patch \
			   file://0001-configs-aptiv_cvc_fl-add-secure-boot-related-configs.patch \
"

AUTOSAR_SEC_PATCHES = "file://0001-configs-s32g2xxaevb-add-NXP_HSE_SUPPORT-config.patch \
			file://0002-configs-s32g274ardb2-add-NXP_HSE_SUPPORT-config.patch \
			file://0003-configs-s32g399ardb3-add-NXP_HSE_SUPPORT-config.patch \
			file://0004-configs-s32g3xxaevb-add-NXP_HSE_SUPPORT-config.patch \
			file://0001-configs-aptiv_cvc_sousa-add-HSE_SECBOOT-config.patch \
			file://0001-configs-aptiv_cvc_sousa-enable-CONFIG_FIT_SIGNATURE-.patch \
			file://0001-configs-aptiv_cvc_fl-add-secure-boot-related-configs.patch \
			file://0001-configs-s32g2xx-enable-CONFIG_FIT_SIGNATURE-for-secu.patch \
			file://0001-arch-mach-s32-extend-the-DTB-size-for-BL33.patch \
			file://0001-Revert-hse-secboot-remove-unused-u-boot-secboot-code.patch \
			file://0002-u-boot-secboot-correct-the-secure-boot-config.patch \
			file://0003-s32-hse-support-secure-boot-feature-on-both-S32G2-an.patch \
"

SRC_URI:append:aptiv-cvc = " \
	file://0001-u-boot-s32-Aptiv-add-u-boot-support-for-Aptiv-CVC-bo.patch \
	file://0002-set-gmac-to-right-speed-of-the-phy-if-autoneg-works.patch \
	file://0003-s32g-aptiv-usb-Use-specific-TARGET_APTIV_CVC_SOUSA-c.patch \
	file://0004-u-boot-s32-enable-CONFIG_XEN_SUPPORT.patch \
	file://0005-u-boot-s32-remove-XEN_EXTRA_ENV_SETTINGS.patch \
	file://0006-s32cc-increate-boot-image-size-to-128MB.patch \
	file://0007-s32-serdes-hwconfig-change-hwconfig-for-CVC-board.patch \
	file://0008-aptiv-cvc-fl-add-support-for-Aptiv-CVC-FL-board.patch \
	file://0009-aptiv-cvc-fl-add-cmd-to-configure-RTL9010-phys.patch \
	file://0010-u-boot-s32-enable-CONFIG_XEN_SUPPORT-for-Aptiv-CVC-FL-board.patch \
	file://0011-aptiv-cvc-fl-add-GPIO_HOG-config.patch \
	${@bb.utils.contains('HSE_SEC_ENABLED', '1', '${SEC_PATCHES}', '', d)} \
	${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', '${AUTOSAR_SEC_PATCHES}', '', d)} \
"

COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"

do_compile:append:aptiv-cvc() {
    if [ "${HSE_SEC_ENABLED}" = "1" ]; then
        for config in ${UBOOT_MACHINE}; do
            cfgout="${B}/${config}/u-boot-s32.cfgout"
            if [ -e $cfgout ]; then
                if [ $config = "aptiv_cvc_sousa_defconfig" ]; then
                    sed -i 's|${HSE_FW_DEFAULT_NAME}|${HSE_LOCAL_FIRMWARE_DIR}/${HSE_FW_NAME_S32G2}|g' $cfgout
                else
                    sed -i 's|${HSE_FW_DEFAULT_NAME}|${HSE_LOCAL_FIRMWARE_DIR}/${HSE_FW_NAME_S32G3}|g' $cfgout
                fi
            fi
        done
    fi

    if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
        for config in ${UBOOT_MACHINE}; do
            cfgout="${B}/${config}/u-boot-s32.cfgout"
            if [ -e $cfgout ]; then
                sed -i '/HSE_FW/d' $cfgout
            fi
        done
    fi
}
