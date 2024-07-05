FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/u-boot-s32-aptiv:"

SEC_PATCHES = "file://0001-configs-aptiv_cvc_fl-add-secure-boot-related-configs.patch \
"

UBOOT_HVP_PATCHES += "${@bb.utils.contains('MACHINE_FEATURES', 'hvp', 'file://0005-u-boot-s32-remove-XEN_EXTRA_ENV_SETTINGS.patch', '', d)}"
UBOOT_HVP_PATCHES += "${@bb.utils.contains('MACHINE_FEATURES', 'hvp', 'file://xen.cfg', '', d)}"

SRC_URI:append:aptiv-cvc = " \
	file://0006-s32cc-increate-boot-image-size-to-128MB.patch \
	file://0008-aptiv-cvc-fl-add-support-for-Aptiv-CVC-FL-board.patch \
	file://0009-s32-serdes-hwconfig-change-hwconfig-for-CVC-board.patch \
	file://0011-aptiv-cvc-fl-add-GPIO_HOG-config.patch \
	file://0012-support-bootmenu.patch \
	file://0012-u-boot-s32-drop-restriction-of-count-of-SGMII-pfe.patch \
	${@bb.utils.contains('HSE_SEC_ENABLED', '1', '${SEC_PATCHES}', '', d)} \
	${UBOOT_HVP_PATCHES} \
"

COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"

do_compile:append:aptiv-cvc() {
    if [ "${HSE_SEC_ENABLED}" = "1" ]; then
        for config in ${UBOOT_MACHINE}; do
            cfgout="${B}/${config}/u-boot-s32.cfgout"
            if [ -e $cfgout ]; then
				sed -i 's|${HSE_FW_DEFAULT_NAME}|${HSE_LOCAL_FIRMWARE_DIR}/${HSE_FW_VERSION_S32G3}/${HSE_FW_NAME_S32G3}|g' $cfgout
            fi
        done
    fi
}
