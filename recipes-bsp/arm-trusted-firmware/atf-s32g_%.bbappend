FILESEXTRAPATHS:prepend:aptiv_cvc_sousa := "${THISDIR}/atf-s32g-aptiv:" 

PLATFORM:aptiv_cvc_sousa = " aptiv_cvc_sousa"

SRC_URI:append:aptiv_cvc_sousa = " \
	file://0001-s32g-Aptiv-move-imem_cfg.c-into-the-board-mk-files.patch \
	file://0002-s32g-Aptiv-add-ddr-parameter-files-of-CVC-board.patch \
	file://0003-atf-s32g-Set-CAN-clock-to-FOSC-and-40MHz.patch \
	file://0004-aptiv-s32g-atf-add-aptiv-cvc-dts-file.patch \
	file://0005-aptiv-s32g-atf-add-xrdc.patch \
"

COMPATIBLE_MACHINE:aptiv_cvc_sousa = "aptiv_cvc_sousa"
