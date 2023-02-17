KBRANCH:aptiv-cvc  = "v5.15/standard/preempt-rt/nxp-sdk-5.10/nxp-s32g"
COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"
TARGET_SUPPORTED_KTYPES:aptiv-cvc = "preempt-rt"
FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/files:"

SRC_URI:append:aptiv-cvc = " \
	file://0001-dts-Aptiv-Add-new-dts-for-Aptiv-CVC-board.patch \
	file://0001-Aptiv-enable-CAN0_STB-and-CAN0_EN-pullup.patch \
	file://0001-dts-Aptiv-enable-flexcan1-3.patch \
	file://0001-dts-Aptiv-change-scmi-buf.patch \
	file://0006-dts-Aptiv-linux-disable-dma-coherent-for-pfe-for-cu.patch \
	file://0007-dts-Aptiv-linux-add-pfe-dts-nodes.patch \
	file://0008-dts-Aptiv-add-s32g274a-aptiv-pfems.dts-to-enable-pf.patch \
	file://0009-aptiv-add-dts-file-for-Aptiv-CVC-FL-board.patch \
	file://0010-dts-cvc-fl-disable-unsupported-device-nodes.patch \
	file://0011-aptiv-dts-add-correct-pinctrls-for-pfe-interfaces-fo.patch \
"
