IMAGE_INSTALL += "linuxptp linuxptp-configs"
IMAGE_INSTALL += "can-utils"
IMAGE_INSTALL += "i2c-tools"
IMAGE_INSTALL += "u-boot-s32"
IMAGE_INSTALL += "atf-s32g"
IMAGE_INSTALL += "vsomeip"
IMAGE_INSTALL += "watchdog"
IMAGE_INSTALL += "libfci libfci-cli"
IMAGE_INSTALL += "libp11"

APTIV_CVC_WIC_INC:aptiv-cvc = "${@bb.utils.contains('MACHINE_FEATURES', 'm7_boot', 'make_aptiv_m7_boot_wic.inc', 'make_aptiv_cvc_wic.inc', d)}"

require conf/${APTIV_CVC_WIC_INC}
