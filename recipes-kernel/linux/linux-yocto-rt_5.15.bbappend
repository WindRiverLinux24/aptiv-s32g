require linux-yocto-aptiv_cvc_sousa.inc

KBRANCH:aptiv_cvc_sousa  = "v5.15/standard/preempt-rt/nxp-sdk-5.10/nxp-s32g"

LINUX_VERSION:aptiv_cvc_sousa ?= "5.15.x"

SRC_URI:append:aptiv_cvc_sousa = " \
	file://0001-dts-Aptiv-Add-new-dts-for-Aptiv-CVC-board.patch \
	file://0001-Aptiv-enable-CAN0_STB-and-CAN0_EN-pullup.patch \
	file://0001-dts-Aptiv-enable-flexcan1-3.patch \
	file://0001-dts-Aptiv-change-scmi-buf.patch \
"
