FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/files:"

SRC_URI:append:aptiv_cvc_sousa = " \
	file://0001-Disable-creating-of-default-logical-interface-in-cas.patch \
"
COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"
