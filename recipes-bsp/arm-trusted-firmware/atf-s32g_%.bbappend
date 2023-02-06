FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/atf-s32g-aptiv:"

PLATFORM:aptiv_cvc_sousa = " aptiv_cvc_sousa"
PLATFORM:aptiv-cvc-fl = " aptiv_cvc_fl"

SKIP_MMC_INIT_PATCH = "${@bb.utils.contains('APTIV_FEATURES', 'skip_mmc_init', 'file://0001-aptiv-s32g-atf-s32g-don-t-initialize-mmc-in-atf.patch','', d)}"

SRC_URI:append:aptiv-cvc = " \
	file://0001-s32g-Aptiv-move-imem_cfg.c-into-the-board-mk-files.patch \
	file://0002-s32g-Aptiv-add-ddr-parameter-files-of-CVC-board.patch \
	file://0003-atf-s32g-Set-CAN-clock-to-FOSC-and-40MHz.patch \
	file://0004-aptiv-s32g-atf-add-aptiv-cvc-dts-file.patch \
	file://0005-aptiv-s32g-atf-add-xrdc.patch \
	file://0006-aptiv-set-S32_VR5510-for-aptiv-CVC-platform.patch \
	file://0007-aptiv-s32g-atf-s32g-Patch-PFE1-2-SGMII-MDIO-Bus-for-.patch \
	file://0008-aptiv-cvc-fl-add-support-for-Aptiv-CVC-FL-board.patch \
	${SKIP_MMC_INIT_PATCH} \
"

EXTRA_OEMAKE:append:aptiv_cvc_sousa = " S32_HAS_HV=1"

COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"
