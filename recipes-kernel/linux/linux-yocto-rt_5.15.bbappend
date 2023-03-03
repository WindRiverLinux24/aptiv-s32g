KBRANCH:aptiv-cvc  = "v5.15/standard/preempt-rt/nxp-sdk-5.10/nxp-s32g"
COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"
TARGET_SUPPORTED_KTYPES:aptiv-cvc = "preempt-rt"
FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/files:"

SRC_URI:append:aptiv-cvc = " \
	file://0001-dts-Aptiv-change-scmi-buf.patch \
"
