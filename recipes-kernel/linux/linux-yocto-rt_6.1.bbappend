KBRANCH:aptiv-cvc  = "v6.1/standard/preempt-rt/nxp-sdk-5.15/nxp-s32g"
COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"
TARGET_SUPPORTED_KTYPES:aptiv-cvc = "preempt-rt"
FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/files:"

LINUX_HVP_PATCH="${@bb.utils.contains('MACHINE_FEATURES', 'hvp', 'file://0001-dts-Aptiv-change-scmi-buf.patch', '', d)}"

SRC_URI:append:aptiv-cvc = " \
	${LINUX_HVP_PATCH} \
	${@bb.utils.contains('MACHINE_FEATURES', 'disable_linux_i2c4', \
	'file://0001-dts-cvc-fl-disable-i2c4-device-node.patch', '', d)} \
	${@bb.utils.contains('MACHINE_FEATURES', 'disable_flexcan0', \
	'file://0002-dts-cvc-fl-disable-can0-device-node.patch', '', d)} \
	${@bb.utils.contains('MACHINE_FEATURES', 'disable_linux_llce', \
	'file://0003-dts-cvc-fl-disable-llce.patch', '', d)} \
"
