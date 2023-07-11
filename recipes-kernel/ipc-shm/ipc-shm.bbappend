FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/ipc-shm-aptiv:"

SRC_URI:append:aptiv-cvc = " \
	file://0001-shm-sample-use-strncpy-instead-of-strcpy.patch \
"

COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"
