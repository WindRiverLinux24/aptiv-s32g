FILESEXTRAPATHS:prepend:aptiv_cvc_sousa := "${THISDIR}/ipc-shm-aptiv:"

SRC_URI:append:aptiv_cvc_sousa = " \
	file://0001-shm-sample-use-strncpy-instead-of-strcpy.patch \
"

COMPATIBLE_MACHINE:aptiv_cvc_sousa = "aptiv_cvc_sousa"
